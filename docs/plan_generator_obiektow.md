# Plan: generator obiektów statycznych i interaktywnych (jaskinie)

> Spisane 2026-09-25. Cel: dużo obiektów na mapie — od dużych przeszkód po drobne sprite'y — bez
> spowalniania generowania i gry, deterministycznie (seed), z zachowaniem osiągalności. Skrzynie
> przechodzą z `SpawnPlanner` do nowego generatora.

## Stan wyjściowy

- Skrzynie: `spawn/spawn_planner.gd` — środek co drugiego pokoju pośredniego, potem `_nudge_off_plateau`
  (zsuwanie z barier płaskowyżu). Instancje w `MapGeneratorBase.spawn_entities` (węzeł `Objects`,
  y-sort, porcje `ENTITY_CHUNK` między klatkami). Id skrzyni (`Chest._generate_unique_id`) z pozycji.
- Wrogowie: też `SpawnPlanner` (boss w pokoju wyjścia, 2–4 wrogów w co drugim pokoju).
- Dekoracja podłogi: tylko kafle terenu (FloorDecor). `scenes/objects/barrel.tscn` istnieje, nikt go nie stawia.
- Nawigacja: `setup_navigation_region` — obrys mapy + bake (parsuje kolizje).
- Ograniczenia z płaskowyżów: `PlateauLayout.blocked` (bariery, stopy lic), schody, strefy portali.

## Zasada wydajności: trzy klasy obiektów, trzy tanie ścieżki

Koszt w Godocie (rząd wielkości): węzeł ze sceny ~20–60 µs + koszt co klatkę (process, sygnały),
element `RenderingServer` ~2–5 µs i zero kosztu logiki, kafel `TileMapLayer` ~1 µs (batchowane
rysowanie i kolizje w kwadrantach). Dlatego o ścieżce decyduje to, czego obiekt POTRZEBUJE:

| Klasa | Przykłady | Render | Kolizja | Węzły |
|---|---|---|---|---|
| **DECAL** (płaski, pod postaciami) | kamyki, kości, plamy, trawa, grzyby niskie | kafle na warstwie `Decals` (z = pod encjami) | brak | 0 |
| **PROP** (stoi, y-sort, bez logiki) | stalagmity, kryształy, beczki dekoracyjne, duże głazy | kafel z `y_sort_origin` na warstwie `Props` (y-sort) albo — gdy nie pasuje do siatki — `RenderingServer` canvas item pod y-sortowanym węzłem | kafel: warstwa fizyki TileSetu; nie-siatkowy: kształty w jednym `PhysicsServer2D` body na fragment mapy | 0 |
| **INTERACTIVE** (logika, stan) | skrzynie, niszczalne beczki, dźwignie, kapliczki | scena | w scenie | 1 na obiekt |

- Tysiące DECAL/PROP kosztują tyle co kafle — bez węzłów, bez `_process`.
- INTERACTIVE jest mało (dziesiątki), instancje porcjami jak dziś. Gdyby było ich dużo: później
  leniwe tworzenie (proxy = kafel/canvas item, scena powstaje, gdy gracz podejdzie).
- Duże przeszkody wielokratkowe: grafika jako jeden kafel/tekstura z `y_sort_origin` u podstawy,
  kolizja tylko na kratkach podstawy (footprint), nie na całej wysokości sprite'a.

## Tryb rozmieszczania: siatka albo free placement

Każdy obiekt ma `placement`, ustawiany w JSON-ie per obiekt albo dziedziczony z **grupy** (grupa
ustala domyślne wartości dla wielu obiektów naraz, obiekt może je nadpisać):

| `placement` | Pozycja | Render (DECAL/PROP) | Kolizja | Zajętość |
|---|---|---|---|---|
| `grid` | środek / kotwica kratki | kafel (`Decals` / `Props`) | warstwa fizyki TileSetu | kratki footprintu |
| `grid_jitter` | kratka + losowe przesunięcie do `jitter` px | canvas item (`RenderingServer`) | kształt w body fragmentu | kratki footprintu (jak `grid`) |
| `free` | dowolna pozycja w pikselach w dozwolonym obszarze | canvas item | kształt w body fragmentu | koło/prostokąt w px → kratki, które pokrywa (zachowawczo) |

- Ta sama grafika działa w obu trybach: canvas item rysuje region atlasu TileSetu (bez osobnych tekstur),
  więc przełączenie obiektu z `grid` na `free` to zmiana jednej wartości w JSON-ie.
- INTERACTIVE (sceny): tryb decyduje tylko o pozycji instancji (środek kratki albo pozycja w px).
- `free` — próbkowanie Poisson-disk w pikselach (min. odstęp `spacing_px`), przyspieszone kubełkami
  siatki (sprawdzamy sąsiednie kratki, nie całą listę); kandydaci nadal z masek cech (kratka punktu),
  więc reguły kontekstu działają tak samo. Opcjonalnie `flip_h`, skala z zakresu.
- `grid_jitter` — tani środek: kandydaci jak w siatce (maski, footprint), a na ekranie bez sztywnego
  rastra; dobre dla drobnicy (kamyki, grzyby).
- Zajętość zawsze w kratkach (wspólna dla wszystkich trybów, dla wrogów i testu osiągalności); obiekt
  `free` z kolizją blokuje kratki, które jego kształt pokrywa w ≥ połowie (bez kolizji — tylko odstęp).

## Architektura

```
topologia + płaskowyże ──> ObjectPlanner (wątek roboczy) ──> ObjectPlan ──> ObjectRealizer (główny wątek)
                              │   katalog ObjectDef (.tres)            │   kafle: TilePlacementPlan (porcje PAINT_CHUNK)
                              │   mapy cech + zajętość (płaskie)       │   canvas items / physics: porcje
                              └── SpawnPlanner (wrogowie) czyta zajętość └ sceny: porcje ENTITY_CHUNK
```

### Dane
- **Katalog w JSON-ie** per biom (`resources/maps/config/objects_caves.json`, wskazany z `caves.json`),
  wczytywany jak `GeneratorBehaviourConfig`: sekcja `groups` (domyślne wartości) i `objects` (każdy
  obiekt ma `group` i może nadpisać dowolne pole). Przykład:
  ```json
  {
    "groups": {
      "rubble":  { "class": "DECAL", "placement": "grid_jitter", "jitter": 5, "density": 3.0,
                   "cluster": { "size": [3, 6], "radius": 2 } },
      "boulders": { "class": "PROP", "placement": "free", "spacing_px": 40, "collision": "shape",
                   "context": ["room"], "keep_paths": true }
    },
    "objects": [
      { "id": "pebbles_a", "group": "rubble", "atlas": [12, 20], "variants": 4 },
      { "id": "boulder_big", "group": "boulders", "atlas": [14, 22], "size": [2, 2],
        "footprint": [[0, 1], [1, 1]], "shape": { "rect": [28, 12], "offset": [0, -6] } },
      { "id": "stalagmite", "group": "boulders", "placement": "grid", "context": ["wall_s"] },
      { "id": "chest", "class": "INTERACTIVE", "placement": "grid", "scene": "chest",
        "context": ["dead_end", "niche", "wall_any"], "levels": ["ground", "plateau_top"] }
    ]
  }
  ```
  Walidacja przy wczytaniu (nieznane pola, brakujące atlasy/sceny, konflikt trybu z kolizją kafla).
- **`ObjectDef`** (sparsowany obiekt po scaleniu z grupą): `id`, `klasa`
  (DECAL/PROP/INTERACTIVE), `placement`, `footprint` (maska kratek podstawy), `render` (atlas coords + zestaw /
  tekstura + region / scena), warianty (lista + wagi), `collision` (brak / kafel / kształt), reguły:
  poziomy wysokości (ziemia, góra płaskowyżu, dół), tagi kontekstu (przy ścianie N/S/E/W, narożnik,
  środek pokoju, korytarz, ślepy zaułek, nisza, przy licu płaskowyżu), motyw (rock/roots), gęstość
  na 100 kratek, klastry (rozmiar, rozrzut), min. odstęp od swoich i od innych klas, priorytet.
- **`ObjectPlan`** (czyste dane, bez węzłów): lista `{def, cell, offset_px, variant, flip}` + `occupancy`
  (`offset_px` = 0 dla `grid`, przesunięcie w kratce dla `grid_jitter`/`free`).
  Liczony w wątku roboczym razem z planem kafli — gotowy, zanim główny wątek zacznie malować.

### Mapy cech (raz na mapę, płaskie `PackedInt32Array`/`PackedByteArray` W×H)
Wszystkie reguły to odczyt O(1) z tablic — żadnych BFS-ów na obiekt:
- odległość do ściany (transformata odległości, 2 przebiegi), kierunki sąsiednich ścian (bity N/S/E/W),
  narożniki wklęsłe;
- id pokoju / korytarz / ślepy zaułek (stopień w grafie podłogi), wysokość (`PlateauLayout.height_of`),
  krawędź płaskowyżu;
- **zajętość**: ściany, bariery i stopy lic płaskowyżu, schody + ich podejścia, strefa portali z
  pierścieniem, spawn gracza, wcześniej postawione obiekty (z odstępami).

### Algorytm rozmieszczania (deterministyczny)
1. **Rezerwacja przejść**: najkrótsze ścieżki (BFS po ruchu z wysokościami — ten sam co w płaskowyżach)
   wejście→wyjście, wejście→każde schody, wejście→pokoje; poszerzone o 1 kratkę → zajętość „tylko
   DECAL”. Przeszkody nigdy nie zatkają głównych dróg.
2. **Kolejność klas**: duże PROP (przeszkody) → INTERACTIVE (skrzynie itd.) → małe PROP → DECAL.
   Wrogowie (SpawnPlanner) po obiektach, omijają zajętość.
3. **Próbkowanie per def**: kandydaci z reguł (maska z map cech) → wybór blue-noise
   (siatka z jitterem / hash pozycji, bez sortowania całej mapy) → test footprintu i odstępów w
   zajętości → wstaw. RNG seedowany `hash(seed, def.id)` — dodanie nowego obiektu do katalogu nie
   przelosowuje pozostałych.
4. **Klastry**: dla defów z `cluster` — punkt zarodkowy + kilka sztuk w promieniu (np. grzyby,
   kamienie, kryształy).
5. **Weryfikacja osiągalności**: jeden BFS po ruchu na końcu; teren odcięty przez przeszkody → usuń
   przeszkody graniczące z odciętym kawałkiem (rzadkie, bo przejścia są zarezerwowane).

### Realizacja (główny wątek, porcjami — pasek ładowania żyje)
- DECAL/PROP-kafle: do `TilePlacementPlan` (nowe warstwy `Decals` z pod encjami, `Props` y-sort) —
  ten sam wykonawca co ściany (`place_range`, `PAINT_CHUNK`), kolizje z warstwy fizyki TileSetu.
- PROP spoza siatki: canvas items `RenderingServer` pod węzłem `Props` (y-sort) + jedno statyczne body
  na fragment (np. 32×32 kratki) z wieloma kształtami. RID-y trzymane w tablicy, zwalniane przy
  regeneracji (podgląd, reroll).
- INTERACTIVE: sceny porcjami do `Objects` (jak dziś skrzynie).
- Nawigacja: przeszkody z kolizją wchodzą do bake (parsowanie kolizji); DECAL-e nie mają kolizji,
  więc nie kosztują nic.

## Skrzynie w nowym generatorze
- `ObjectDef` „chest” (INTERACTIVE, scena `chest_scene`): reguły — pokój pośredni (nie wejście/wyjście),
  preferencja: ślepy zaułek / nisza / przy ścianie, także góra płaskowyżu (nagroda za wejście),
  nigdy na barierze/schodach/portalu, osiągalna. Liczba jak dziś (co drugi pokój) albo z gęstości.
- `SpawnPlanner`: zostaje tylko dla wrogów; `_nudge_off_plateau` dla skrzyń znika (zajętość to załatwia).
- Id skrzyni: deterministyczne z `def.id` + kratki (nie z pozycji w pikselach /10) — stan otwarcia
  (`LevelStateManager`) przetrwa regenerację tej samej mapy.

## Fazy (każda z testami i osobnymi commitami)
1. **F0 — infrastruktura**: katalog JSON (grupy + obiekty, scalanie, walidacja), `ObjectDef`,
   `ObjectPlan`, tryby `grid` / `grid_jitter` / `free`, mapy cech + zajętość (płaskie),
   `ObjectPlanner` w wątku (etap `GenProgress` `objects`), `ObjectRealizer` z trzema ścieżkami (na
   start pusta). Test: determinizm (digest planu), czas etapu.
2. **F1 — skrzynie**: przeniesienie z `SpawnPlanner`, nowe reguły, stabilne id. Testy: skrzynie
   osiągalne, poza barierami/schodami/portalami, liczba jak wcześniej; `diag_level_platforms` (runtime).
3. **F2 — przeszkody (PROP-kafle)**: rezerwacja przejść, footprinty, kolizje z TileSetu, weryfikacja
   osiągalności, nawigacja. Testy: osiągalność 100%, wrogowie nie na przeszkodach, nav omija.
4. **F3 — drobnica (DECAL + małe PROP)**: klastry, gęstości, motyw rock/roots, wysokości.
5. **F4 — sprite'y spoza siatki** (`RenderingServer` + `PhysicsServer2D`), sprzątanie RID-ów.
6. **F5 — kolejne interaktywne** (beczki niszczalne, dźwignie…), ewentualnie leniwe tworzenie scen.
7. **Podgląd**: przełącznik „Obiekty” + nakładka zajętości i zarezerwowanych przejść; statystyki
   (liczba per klasa, czas etapu).

## Pomiar / kryteria
- Plan obiektów w wątku: < 100 ms dla 250×250 przy ~2–3 tys. obiektów.
- Realizacja: DECAL/PROP jako kafle ~ koszt malowania ścian; INTERACTIVE ≤ kilkadziesiąt instancji.
- Testy w `run_plateau_suite.sh`: nowy `diag_objects.gd` (osiągalność, zakazane kratki, determinizm,
  gęstości, czasy), digest planu obiektów w parytecie.

## Do ustalenia z userem
- Grafika obiektów: jeden atlas (→ kafle, najtaniej) czy osobne tekstury (→ canvas items / sceny)?
- Czy statyczne przeszkody mają być niszczalne / reagować (→ INTERACTIVE, węzły)?
- Czy wrogowie mają omijać drobne przeszkody (nav) czy wystarczą kolizje?
- Gęstości i lista obiektów na start (co wchodzi do katalogu caves w F2–F3).
