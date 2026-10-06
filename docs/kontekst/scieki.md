# Ścieki (sewer) — stan na 2026-10-06

Gałąź **`sewer-gen-v2`** w submodule CienMgly (`modules/quiz_rpg`), najnowszy commit `cbe4b35` (host: commit `46e3b1f`).
Zawiera nową architekturę strukturalnego generatora ścieków (Structured Generator v2), pełny determinizm PRNG,
separację koryt suchych i ścieków szumem 0/1, gwarancję 1 składowej spójnej przez `BridgeConnectivityResolver`,
ochronę prepassów ścian 3H, oddzielenie korytarzy serwisowych ścianami oraz blokadę kładek na zakrętach.
Generowanie terenu / układu korytarzy wstrzymane do dalszej pracy z Claude Opus.

W hoście niezacommitowane (zastrzeżone, nie dotykać!): `Tiles.png`, `Props.png`, `Gemini_Generated_Image_*`.

## Pliki
- `resources/maps/sewer.tres` — TileSet (UID `c73m68vj3lqr3`), źródło 0 = `sewer/Assets/Tiles.png`, źródło 1 =
  `Props.png` (kładki). Tereny autora: `floor` (0), `void`, `dark_floor`, `foliage` (mech), `ridges`.
  Kolizje ścian / obrzeży kanału dopisywane wprost w tekście pliku (autor edytuje go w edytorze — nie
  przepisywać ResourceSaverem; builder robi to tylko z `BUILD_TILESET=1`).
- `resources/maps/profile/sewer_map_tiles.tres` — profil Named TileSet (`sewer`), budowany przez
  `tests/build_sewer_resources.gd` (tests/ poza gitem). Moduły lica z przesunięciem -1 (`FS`).
- `resources/maps/config/sewer.json` — flagi i parametry układu ścieków. Eksplorator map: pozycja „Ścieki” (F4).
- `scripts/generation/structured/structured_layout_generator.gd` — główny pipeline strukturalnego układu ścieków.
- `scripts/generation/structured/linear_network_generator.gd` — generator szkieletu sieci koryt i tuneli.
- `scripts/generation/structured/structured_zoning.gd` — strefowanie sal, kompleksów i koryt.
- `scripts/generation/structured/bridge_connectivity_resolver.gd` — gwarancja osiągalności i kładek o dł. 6.
- `scripts/generation/topology/canal_pass.gd` — wyznaczanie odcinków koryta, kładek i podziału na suche/ścieki.
- `scripts/generation/tiling/canal_placer.gd` — kafelkowanie wody, brzegów, dna suchego koryta i kładek.

## Kafle (atlas Tiles.png)
- Lico 3H: wiersze 5 (góra = dół bloku) / 6 (krata) / 7 (cokół), końce kol. 0 i 2. Lico 4H: wiersze 8–11
  (top, krata, krata, cokół), końce kol. 0 i 2. Kap (ściana z podłogą na N): 1,3 / 4,3; końce 0,3 / 2,3.
  Boki: 3,1-3,2 (podłoga na E), 5,1-5,2 (na W). Rama pokoju: 3,0 / 5,0 / 3,3 / 5,3. Pustka 1,4.
- Podłoga: teren `floor` (blok 3–5 × 4–9 z brzegami); środek pełną maską mają tylko 4,5 i 6,6.
- Kanał: kwas 9-slice 11–13 × 0–2 (z własną szyną od brzegu), narożniki wewnętrzne 14,0 / 16,0 / 14,2 / 16,2,
  animacja 4 klatek (co 3 wiersze). Lico brzegu 4,13 (końce 3,13 / 5,13, przy ścianie 6,13 / 8,13).
  Obrzeża na podłodze: 4,10 (kanał na N), 4,12 (na S), 5,11 (na E), 3,11 (na W), rogi 3,10 / 5,10 / 3,12 /
  5,12, wklęsłe 13,12 / 14,12 / 13,13 / 14,13 (dodane przez nas do PNG), ciemne końce przy ścianie 6,11 / 8,11,
  6,12 / 8,12, 9,3 / 9,5, 10,3 / 10,5. Kładki (Props.png): pionowa 4–5 × 9–14, pozioma 6–10 × 12–13.

## Architektura i kluczowe reguły (2026-10-05)

### 1. 100% Determinizm generatora
- Wszystkie wywołania `Array.shuffle()` (wbudowane, nieseedowane) zastąpiono deterministycznym Fisher-Yates
  `MapGeneratorBase.shuffle_array(arr, rng)` w `linear_network_generator.gd`, `structured_zoning.gd`,
  `structured_room_packer.gd` i `canal_pass.gd`. Identyczny seed daje 100% identyczny wynik.

### 2. Spójność koryt i brak zakręcania w ścianę
- **Przyczyna skręcania w ścianę:** w `canal_placer.gd` pomocnicza funkcja `_acid` zwracała `not GridUtils.is_walkable`,
  co powodowało traktowanie ściany sąsiadującej z korytem jako kwasu i wywijanie piany/narożników w mur.
  Zmieniono na `return false` — brzeg koryta przy ścianie jest idealnie prosty (W/E).
- **Dowolna szerokość korytarzy wokół koryta (w tym 0 = styk ze ścianą):**
  - Chodniki `lanes` o stałej szerokości obowiązują wyłącznie dla tuneli tranzytowych (`kind == "tunnel"`).
  - W salach i kompleksach dopuszczalne jest `want[pk] = 0` (brak chodnika, woda dochodzi do litej ściany).
  - Całkowicie wycięto funkcję `_ensure_canal_clearance` z `structured_layout_generator.gd`, która wymuszała sztuczny
    pas podłogi wokół wszystkich koryt i niszczyła prepassy ścian.

### 3. Prepassy ścian 1H i 2H (Wall3HPass, Remove1hWallsPass, WallThicknessPass)
- Reguły prepassów działają w `_run_wall_shape_passes` przed kładkami.
- W `wall_3h_pass.gd` funkcja `_can_fill` sprawdza `not canals.cells.has(p)` — zapobiega to wylewaniu się ścian
  w koryto, dzięki czemu ściany 2H powiększają się do 3H wyłącznie w stronę podłogi pokoju (z dala od wody).
- Usunięcie `_ensure_canal_clearance` sprawiło, że po prepassach nie powstają już nowe niepoprawione ściany 1H/2H.

### 4. Podwójny szum (suche koryto vs ścieki)
- Zastosowano dwupoziomowy szum binarny (0 i 1) do partycjonowania sieci kanałów na poziomie skrzyżowań:
  koryta z poziomem 1 są puste (`dry_cells`), a z poziomem 0 zawierają ścieki.
- Suche koryta są całkowicie odseparowane od kwasu (min dystans $\ge 17.0$ kratek w testach).

### 5. Gwarancja przejść i kładki na osobnej warstwie (Bridges)
- **Dedykowana warstwa kładek (`Bridges`):**
  - Kładki (`BRIDGE_V`, `BRIDGE_H`) zostały wydzielone ze wspólnej warstwy `FloorDecor` na osobną warstwę TileMapLayer `Bridges` (`z_index = -1`, `y_sort_enabled = true`).
  - Kolejność nanoszenia warstw: `Floor` -> `FloorDecor` (obrzeża/dekoracje) -> `Bridges` (kładki nad korytem) -> `Walls` -> `Platforms`.
  - Warstwa jest w pełni obsługiwana przez `CaveGenerator` (`prepare_cave_layers`, `execute_cave_tiles`), `ProceduralLevel` (`_prepare_layers`, `_apply_job_async`) oraz podgląd eksploratora (`MapGeneratorPreview` posiada checkbox widoczności oraz inspekcję kafla kładki w HUD).
- `BridgeConnectivityResolverScript.resolve(ctx, canal_layout)` uruchamia się przed dresingiem i nawigacją.
- Gwarantuje dokładnie 1 składową spójną całej mapy. Wszystkie kładki mają stałą długość 6 kratek i opierają się
  stabilnie na podłodze `FLOOR`. Kładka pozioma `BRIDGE_H` ma w atlasie `Props.png` pełne 6 kratek szerokości
  (`origin = Vector2i(5, 12)`, `size = Vector2i(6, 2)`), zapewniając oparcie z obu stron 4-kratkowego koryta.

### 6. Ciągłość opuszczonej krawędzi kanału (CANAL_FACE)
- W `canal_placer.gd` funkcja `_is_face(ctx, water, p)` sprawdza wyłącznie `not water.has(n)` (gdzie `n = p + (0, -1)`).
- Wcześniejszy warunek `and GridUtils.is_walkable(ctx.grid, n)` powodował, że gdy koryto biegło wzdłuż ściany
  budynku, lico uskoku (`CANAL_FACE`, kafel 4, 13) nie było generowane, a kwas wdzierał się 1 kratkę wyżej aż pod sam
  mur, tworząc dziurę w krawędzi (np. seed 324091, kafelek 74, 241).
- Po poprawce lico uskoku biegnie w sposób w 100% ciągły wzdłuż całego północnego biegu koryta, a tafla kwasu
  poniżej (`CANAL_WATER N`, kafel 12, 0) układa się w prostą, nieprzerwaną linię brzegową.

### 7. Skalowanie sieci liniowej i dressing kanałów (Faza F2)
- **Barierki ochronne na całej mapie (`CanalDressing`):**
  - W `StructuredReservations._can_claim_cell` odblokowano stawianie obiektów `RAIL` na pasach ruchu `LANE` (`blocks_movement = true`). Dzięki temu barierki generują się wzdłuż wszystkich chodników przy korycie (wzrost z 2 odcinków do 36–44 odcinków, 400–700 kratek na planszę).
  - W `CanalPlacer` barierki nanoszone są na warstwę `Walls` z y-sortem i kolizjami `physics_layer_0` z atlasu `Props.png`, nie kolidując z obrzeżem `CANAL_BANK` na `FloorDecor`.
- **Czarne doły (`pits`) w suchym korycie:**
  - Dodano pola `pits: Array[Rect2i]` oraz `pit_cells: Dictionary` w `LinearFeatureLayout`.
  - W `CanalDressing._place_pits` wprowadzono bezpieczny algorytm generowania dołów w suchych segmentach koryta z zachowaniem marginesów od kładek, prześwitów i skrzyżowań.
  - Zdefiniowano nową rolę `CANAL_PIT` w `TileModuleRole` oraz profilu `sewer_map_tiles.tres` z wariantami:
    - `TOP`: `Vector2i(18, 10)` (górna krawędź uskoku w dół),
    - `TOP_B`: `Vector2i(19, 10)` (wariant alternatywny górnej krawędzi),
    - `VOID`: `Vector2i(17, 10)` (czarna otchłań / dno dołu),
    - `BOTTOM`: `Vector2i(18, 11)` (dolna krawędź dna dołu).
  - `CanalPlacer` nanosi kafle dołów na warstwie `Floor`, zachowując pełną ciągłość `CANAL_FACE`.

- Katalog `objects_sewer.json` (włączony w `sewer.json`): skrzynie (alias `chest`), stół + krzesła
  (towarzysze), skrzynki / beczki przy ścianach (skupiska), wraki, bloki miedzi, kratki ściekowe 2×2–4×4
  (DECAL na całej podstawie), otwory w posadzce, drobnica, butelki / kubki — wszystko kafle `sewer.tres`; na licu (`mount: facade`):
  lampy, okrągłe kratki, przełączniki, łuki odpływów. Opis mechanizmu: `kontekst/obiekty.md`.
- Nieużyte z atlasu: regał / schody (Props 0–1 × 6–8 — wygląda na wyjście, może grafika portalu),
  skrzynia ścieków (8–9 × 0–3), łańcuch (10, 0–2), filar (Tiles 7, 3–6), rury.

### 8. Korytarze serwisowe, separacja ścianą i blokada kładek na zakrętach (2026-10-06, commit `cbe4b35`)
- **Sekwencje kompleksów z korytarzami (`proto_layout10.py`):**
  - W `structured_zoning.gd` przywrócono logikę sekwencji `['hall', 'walled', 'hall']` generującą hale rozdzielone wąskimi sekcjami obmurowanych koryt (`walled`).
  - Zaimplementowano drążenie równoległych korytarzy serwisowych z bramami (`gates`) łączących sąsiednie kompleksy.
- **Oddzielenie korytarza serwisowego od ścieków ścianą:**
  - Zdefiniowano strefę ochronną `extra_forb` obejmującą obmurowane koryto (`WALL_H` / `WALL_V`), która wymusza pas litej ściany między korytem a korytarzem serwisowym.
  - Podzielono wybór punktów granicznych na `prev_valid` i `next_valid` leżących po właściwych stronach osi koryta, zapobiegając konieczności przecinania wody.
- **Wzmocnienie A\* pathfindera (`structured_pathfinder.gd`):**
  - Dodano heurystykę Manhattan ($f = g + h$) do kolejki priorytetowej `MinHeap` w A\*, co wyeliminowało błędy wyczerpania limitu 8000 iteracji przy długich trasach.
  - Wprowadzono flagę `forbid_water = true` (aktywną dla korytarzy serwisowych) — A\* bezwzględnie omija komórki wody, a prostoliniowy wlot drzwiowy sprawdza kolizje z wodą i `extra_forb`.
- **Bezwzględny zakaz kładek na zakrętach, narożnikach i w sekcjach `walled`:**
  - W `_add_crossing_bridges` wprowadzono całkowitą blokadę stawiania kładek na segmentach kanału typu `walled`.
  - Wprowadzono margines bezpieczeństwa $\ge 4$ kratek od obu końców segmentu kanału (`seg.from` i `seg.to`), co uniemożliwia generowanie kładek na załamaniach, narożnikach i skrzyżowaniach koryt.
  - Wyłączono generowanie kładek dla korytarzy serwisowych (`is_service == true`).
  - W `canal_dressing.gd` i `bridge_connectivity_resolver.gd` dodano pomijanie odcinków `walled` przy montażu barierek oraz kładek awaryjnych.
- **Status prac nad terenem:**
  - Mimo przejścia testów technicznych (13/13 i 6/6 PASS, 100% determinizm), układ przestrzenny korytarzy wzdłuż koryt nie spełnił jeszcze oczekiwań wizualnych usera (wymaga doprecyzowania oddzielenia ścianami i relacji korytarz-ścieki).
  - Prace nad generowaniem terenu ścieków zostały wstrzymane — zostaną podjęte w kolejnej sesji z modelem Claude Opus.

## Testy diagnostyczne i integracyjne
- `tests/diag_sewer_full_test.gd`:
  - Weryfikuje determinizm 100%, zasięg kanałów (>= 50%), separację suche koryto <-> kwas (odległość >= 17 kratek),
    kładki o długości 6 oparte na podłodze, oraz pełną spójność mapy (dokładnie 1 składowa).
  - Wynik: **PASS** na seedach 119, 42, 777, 2026 (rozmiary 160x160 i 250x250).
- `tests/diag_sewer_slice_fixture.gd`:
  - Weryfikacja 13 asercji integracyjnych: filary lica, barierki z przerwami na kładkach, winieta z wolną strefą dojścia,
    osiągalność geometryczna wejście-wyjście, kolizje barierek i poprawność bakingu NavMesh (ścieżka wejście-wyjście).
  - Wynik: **PASS 13 / FAIL 0**.
- Lokalne skrypty pomocnicze: `render_sewer.gd`, `diag_wall_steps.gd`, `diag_spawn_cells.gd`, `diag_enemy_drift.gd`.

