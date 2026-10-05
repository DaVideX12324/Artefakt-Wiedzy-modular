# Plan: generator ścieków na poziomie makiet autora paczki

Zatwierdzony 2026-10-05 (po dwóch rundach recenzji). Ważne todo (1a) z [znane_problemy.md](znane_problemy.md).
Stan wyjściowy: [kontekst/scieki.md](kontekst/scieki.md), obiekty: [kontekst/obiekty.md](kontekst/obiekty.md).
Makiety: `assets/pixel_crawler/environments/sewer/Social/` — warstwy w Eksploratorze Aseprite.

## Kontekst
Ważne todo (1a). Wynik generatora ścieków (seed 119) to duże jednolite podłogi, void dookoła, jeden prosty
kanał i rozrzucone drobiazgi bez rytmu. Makiety autora (`sewer/Social/MockUp-01`, `MockUp-02`, Extended
`exc.aseprite` klatka 0; 25 × 25 kratek) budują obraz z powtarzalnych przęseł lica, brzegów kanału z barierkami
i małych kompozycji rekwizytów. Cel: okna oceny (def. niżej) z mapy wyglądają jak makieta, przy obecnych
rozmiarach map (120–250) i bez psucia grywalności.

Przyczyny (zbadane): ścieki idą przez `topology/interior_room_layout_generator.gd` (pokoje poly + korytarze
+ przejścia czyszczące pod jaskinie); `CanalPass` dokłada kanały na gotową podłogę; `ObjectPlanner` /
`WallDecorPlanner` stawiają pojedyncze obiekty bez rytmu i kompozycji; brak barierek, rur, filarów, czapek,
mchu, ciemnych plam; brak miary „makieta vs wynik”. Sama zmiana `ObjectPlanner` nie wystarczy.

## Decyzje usera (2026-10-05)
- Niebieskie kafle w korycie Extended to **teren `foliage`** (Tiles 17–19 × 0–2) na dnie. Dopasowanie exc:
  dno 17–19 × 7–9, **doły 17,10 (23 kratki), 18,11** — wszystko już w atlasie.
- Rozmiary map bez zmian.
- Dzbany / worki: **wyciąć z warstwy MockUp-01** do atlasu (jak koryto), kafle do `sewer.tres` tekstowo.
- Recenzja planu (zewnętrzna, przyjęta): okna oceny, kontrakt rezerwacji pól, kontrola osiągalności,
  miękkie progi, test kafli osobno od pikseli, pionowy wycinek przed F2–F5, portale osobnym commitem.

## Analiza makiet (gramatyka do odtworzenia)

Makiety mają 400 × 400 px = 25 × 25 kratek (PNG w paczce to skala ×4). Warstwy rozkłada Eksplorator
Aseprite albo `ase_dump.py`.

### Skala i zagęszczenie
- Prawie brak pustki: między pomieszczeniami są **grube ściany 2–3 kratki** (ciemny grzbiet z ramą), a nie
  pola voidu. Podłoga i kanały zajmują ok. 60–70 % okna.
- Pomieszczenia małe i średnie (6–14 kratek), przylegają do siebie, połączone przejściami w ścianach
  i chodnikami przy kanałach. U nas: sale 16–28 kratek + korytarze 8 → wielkie puste pola i voidy.

### Kanały — kręgosłup mapy
- Sieć: pień + odnogi z zakrętami **L, T i +** (MockUp-01: pionowy kanał krzyżuje się z poziomym, dalej
  skręca). Szerokość wody 3–4 kratki. Kanał biegnie też **wzdłuż ściany** (brzeg tylko z jednej strony).
- Brzeg od strony chodnika: obrzeże (1 kratka) + lico brzegu, a na chodniku **barierka** (Props 6–9 × 4)
  ciągnąca się wzdłuż całego brzegu. Barierka ma **przerwę przy kładce** (1 kratka po każdej stronie)
  i **zawinięte końce** przy przerwie oraz przy ścianach.
- Kładki w obu orientacjach: pionowa przez kanał poziomy (2 kratki szerokości) i pozioma przez kanał pionowy
  (2 kratki wysokości, ~5 długości). W MockUp-02 jedna kładka na ~25 kratek kanału.
- **Extended (exc, klatka 0)** — ten sam układ co MockUp-01, ale kanał to **puste koryto**: dno z cegły,
  plamy terenu `foliage` (niebieskawe kafle 17–19 × 0–2 — nie woda), **czarne doły z ceglaną krawędzią** (stąd kafle dołów
  `Tiles.png` 17–20 × 10, 17–18 × 11 — doły to prostokąty 2–4 kratki z krawędzią u góry), **mech na dnie**
  przy brzegach. Barierki i kładki zostają jak przy kwasie.

### Lico ścian — rytm
- Wysokość 3 (grzbiet, krata z mchem, cokół); długie ściany dzielone **filarami** (Tiles 7, 3–6) w stałym
  odstępie: **5 kratek** (MockUp-02 góra: filar, łuk 3 kratki, filar…) albo **4 kratki** (MockUp-02 dół:
  filar, mały łuk 2 kratki, filar…). Filar wystaje kapturem ponad grzbiet ściany.
- Na filarze: **łańcuch z hakiem** albo **lampa**. Między filarami jedna ozdoba na przęsło: duży łuk odpływu,
  mały łuk, okrągła kratka, para lamp, przełączniki — w obrębie jednej ściany **powtarzana albo
  naprzemienna** (A-B-A-B), symetrycznie względem środka ściany.
- **Rury**: 2–4 równoległe miedziane rury schodzące z lica na posadzkę (MockUp-01 prawy górny róg, dół),
  rura w kształcie U wzdłuż ściany bocznej (MockUp-01 lewa ściana).
- Grzbiety ścian: **szare kostki (czapki)** w regularnych odstępach (co 4–5 kratek, w osi filarów).

### Posadzka
- **Kratki ściekowe w osi przęseł** (MockUp-02: trzy kratki 2 × 4 pod trzema łukami), duże kraty 6 × 3,
  4 × 4 w środku sal.
- **Rzędy otworów** 2 × N (pionowe przy ścianie) i N × 2 (poziome, 10 × 2 w MockUp-02).
- **Mech** (teren `foliage`) w kątach, przy ścianach i pod rekwizytami — plamy organiczne, nie kropki.
- **Ciemne plamy** (teren `dark_floor`) — rozmyte smugi na środku sal i przy przejściach.
- Gruz: 3–8 drobin w luźnym skupisku przy rekwizycie, ścianie albo w przejściu — nigdy równomiernie.

### Kompozycje rekwizytów (winiety)
| Winieta | Skład (makieta) | Miejsce |
|---|---|---|
| Wyjście | schody / regał (Props 0–1 × 6–8) między dwoma filarami z lampami | środek ściany N |
| Jadalnia | stół 3 × 2 + 2–4 krzesła po bokach | kąt sali |
| Piramida beczek | 3 + 2 beczki | kąt przy ścianie |
| Stos skrzyń | 2 × 2 skrzynki | przy ścianie, obok filaru |
| Zakątek | wiadro + skrzynka + gruz | kąt N |
| Skrzynia | skrzynia ścieków zamknięta (Props 8–9 × 2–3) / otwarta (8–9 × 0–1) | przy ścianie, często w mchu |
| Przy kanale | dzbany + worki | przy barierce (**brak w atlasie free** — zamiennik: beczki / skrzynki) |

## Podejście
Nowy generator układu `scripts/generation/sewer/` zwracający ten sam `GenerationResult` (grid, rooms, canals,
objects, terrain_masks, portale, strefy, spawny) — tiling (Named TileSet, `FacadePlacer`, `CanalPlacer`),
`NavOutlines`, `SpawnPlanner`, `ObjectRealizer` bez zmian. Wybór flagą `"layout": "sewer"` w `sewer.json`
(gałąź w `cave_generator.gd:generate()` obok `InteriorRoomLayoutGenerator.generate_layout`).
Każdy pass ma własny RNG `hash([seed, "nazwa"])` (wzór z `WallDecorPlanner`).

### Kontrakt rezerwacji pól (`sewer/sewer_reservations.gd`)
Jedna mapa zajętości dzielona przez wszystkie passy. Każda kratka ma dwie niezależne cechy:
- `reserved_for_placement` — nie wolno tu postawić obiektu danej klasy (portal_zone, lanes,
  bridge_clearance: **przechodnie**, tylko zakaz stawiania);
- `blocks_movement` — kratka blokuje ruch (barierka, rekwizyt PROP z kolizją, woda bez kładki).
Do `ObjectPlan.occupancy` (spawny, nawigacja) trafia **tylko `blocks_movement`**, nie każdy claim.
Tabela legalnych nakładek (klasa nowego obiektu × właściciel kratki): DECAL (gruz, kratki, otwory) może leżeć
na posadzce pod lanes / clearance (nie blokuje ruchu), nie na portalu ani wodzie; PROP nigdy na pasie ruchu,
prześwicie, portalu; ozdoby lica (mount facade) nie zajmują posadzki poza kratką pod rurą. Reszta = konflikt.
`claim(cells, owner, klass, flags) -> bool` jest **atomowe**: sprawdza cały obrys (wszystkie kratki obiektu
wielokaflowego + margines) i zapisuje wszystko albo nic. **Bez wypierania:** passy rezerwują od najwyższego
priorytetu w dół, wcześniejszy claim jest ostateczny (nie trzeba nigdy cofać obiektu z `ObjectPlan`).
Priorytet przy konflikcie (to nie kolejność generowania — patrz niżej):
1. woda / dno kanału, kładki **z prześwitem** (kratki przed i za kładką),
2. pasy ruchu (chodnik ≥ 2 kratki wolne wzdłuż kanału, przejścia między pomieszczeniami),
3. portale i ich strefy dojścia (`portal_zone`, `arrival_cell`),
4. brzegi pod barierkę (kwalifikujące się odcinki — `CanalLayout.rail_edges`),
5. kotwice fasady (filary, przęsła, rury: kratki lica + kratka posadzki pod rurą),
6. kratki ściekowe / rzędy otworów (w osi przęseł),
7. winiety (cały obrys + strona dostępu),
8. gruz (tylko DECAL — może leżeć na polach 6, nie na 1–3).
Kolejność generowania jest z tym zgodna: kanały i pasy ruchu powstają pierwsze; **portale wybierane są
potem wyłącznie spośród kandydatów niekolidujących z wodą, kładką, prześwitem i pasami ruchu**; po wyborze
portali rezerwacje 1–3 są finalne i dopiero wtedy passy 4–8 rozstawiają obiekty.
`CanalLayout` dostaje pola: `rail_edges`, `bridge_clearance`, `lanes`. **`ObjectPlan.occupancy` dostaje
wyłącznie blokady ruchu; rezerwacje przechodnie pozostają w `SewerReservations` i służą plannerom oraz
walidacji.**

### Pipeline (`sewer/sewer_layout_generator.gd`)
1. `SewerCanalNetwork` — graf kanałów najpierw: pień + odnogi, L / T / +, kanał przy ścianie, woda 3–4.
2. `SewerZoning` — chodniki 2–4 wzdłuż brzegów (pasy ruchu), strefy, grube ściany 2–3.
3. `SewerRoomPacker` — pomieszczenia 6–14 (BSP / prostokąty + L), przejścia 2–3; potem reużycie
   `_run_wall_shape_passes`, `ConnectivityRepair.repair`, `PortalGenerator`, wspólny wybór wejścia / wyjścia
   (kandydaci filtrowani przez rezerwacje 1–2; finalizacja rezerwacji portali).
   **Kontrola geometrii A:** po naprawie — wejście → wyjście osiągalne, brzegi kanału po naprawie przeliczone
   (naprawa mogła przeciąć brzeg / dodać przejście), `rail_edges` liczone dopiero teraz.
4. `FacadeRhythm` — filary (Tiles 7, 3–6) co 4 / 5 wyśrodkowane, typ przęsła na ścianę (A-A-A / A-B-A),
   łańcuch / lampa na filarze, czapki grzbietów w osi filarów, rury lico → posadzka, rura U przy ścianie bocznej.
5. `CanalDressing` — barierki (Props 6–9 × 4) na `rail_edges`, przerwa przy kładce, zawinięte końce,
   kolizja; kładki w obu osiach; koryto suche wg Extended (`foliage` na dnie przy brzegach, doły 2–4).
6. `FloorDetail` — `dark_floor` / `foliage` z pól odległości + szum (`TerrainMaskPlanner` / `TerrainAutotileSolver`),
   kratki w osi przęseł, duże kraty w środku sal, rzędy otworów.
7. `VignettePlanner` — biblioteka winiet (wyjście: schody Props 0–1 × 6–8 między filarami z lampami;
   jadalnia; piramida beczek; stos skrzyń; zakątek; skrzynia ścieków; dzbany + worki przy barierce);
   skrzynie quizów = winieta „Skrzynia”.
8. `ScatterPlanner` — gruz skupiskami.
9. **Kontrola geometrii B** (po barierkach i obiektach): osiągalność wejście → wyjście, wszystkie skrzynie
   quizowe, strefy wymagane dla gracza; przeszkodę odcinającą cel zdejmujemy (mechanizm `removed_for_reach`
   z `ObjectPlanner`), nie przesuwamy celu. Potem `SpawnPlanner`.
   **Definicja ruchu = jak w grze:** gracz to kapsuła r = 3 px (`player.tscn`), wrogowie chodzą po navmeshu
   z `NavOutlines.AGENT_RADIUS` = 7 px. Szybki BFS: 4 kierunki + skos **tylko gdy obie kratki ortogonalne
   są wolne** (bez ścinania rogów), kratka przechodnia = nie `blocks_movement`; kładka przechodnia tylko
   wzdłuż swojej osi (boki kładki = brzeg / barierka); przejście szerokości 1 kratki liczone jako
   przechodnie dla gracza, ale **nie** dla wrogów (agent 7 px wymaga ≥ 1 kratki wolnej z marginesem —
   sprawdzane na navmeshu). Test navmesh na scenie (MCP) po synchronizacji nawigacji
   (`NavigationServer2D.map_changed` z **sprawdzeniem RID właściwej mapy** + kilka klatek fizyki,
   **z timeoutem** — test kończy się błędem zamiast wisieć), nie zaraz po zbudowaniu mapy.

Ozdoby = kafle `sewer.tres` w `ObjectPlan`, kolizje `physics_layer_1`, kształty nawigacji z `"shape"`
w `objects_sewer.json`.

## Okna oceny i metryki
- **Okno kwalifikujące się:** 25 × 25 w granicach mapy z ≥ 60 % powierzchni grywalnej (podłoga + kanał).
  Kategorie: wejście, kanał, sala (bez kanału). Okna wybierane **deterministycznie i warstwowo**
  (siatka z krokiem 12 + losowanie z seeda raportu, stała liczba na kategorię). Raport: mediana i najgorsze
  10 % **osobno na kategorię** (metryki wizualne porównywane z makietą tej samej kategorii — sala nie musi
  mieć barierek), plus **współrzędne najgorszych okien** (seed, rozmiar, x, y) — showcase otwiera je wprost.
- **Twarde testy (błędy):** przerwana barierka na kwalifikującym się odcinku (100 % kwalifikujących się —
  bez kładek, zakończeń i celowych otwarć), barierka „w powietrzu”, zablokowany portal / strefa dojścia,
  nieosiągalne wyjście lub skrzynia quizowa, pokój ze spawnem bez połączenia navmesh, nakładające się obrysy.
- **Miękkie (zakresy / percentyle względem makiet opisanych ręcznie w F0):** udział voidu, gęstość rekwizytów,
  mech / ciemne plamy, filary na 10 kratek lica, przęsła z ozdobą, liczba ról kafli, największy pusty
  prostokąt (miara pustki — percentyl, nie próg; sale do 14 mogą mieć spokojny środek).

## Fazy (commit + push po każdym kroku; gałąź `sewer-gen-v2` z `sewer-tileset`)
- **F0a dokumenty** — uzupełnić i zacommitować `docs/plan_generator_sciekow.md` (napisany, niezacommitowany)
  o decyzje i recenzję.
- **F0b ekstrakcja makiet** — `tools/mockup_extract.py` (z `scratchpad/plan/layer_match.py`) na **źródłowych
  `.aseprite`** (parser, bezstratnie; nie JPEG / PNG ×4) → `resources/maps/mockups/sewer_m1|m2|ext.json`
  (warstwa, kratka, źródło / kafel / odbicie, obiekty spoza siatki z przesunięciem px). Pokrycie dziś 67–100 %:
  nieznane kratki **przeglądam i opisuję ręcznie** (z userem przy wątpliwych) zanim JSON stanie się wzorcem.
  Ręczny opis makiet: strefy, przęsła, winiety, odcinki barierek → wzorce metryk miękkich.
- **F0c testy odtworzenia** — (1) **zgodność kafli**: makieta złożona z naszego TileSetu — identyfikatory
  kafli, warstwy, kolejność rysowania / y-sort, pozycje; (2) **zgodność pikseli** jako drugi test, z listą
  wyjątków (cienie ręczne, rekwizyty spoza atlasu).
- **F0d narzędzia** — wycięcie dzbanów / worków do atlasu + kafle w `sewer.tres`; `tests/sewer_showcase.gd`
  (okna oceny + zrzut MCP obok makiety); `tests/diag_sewer_metrics.gd` (twarde + miękkie); pomiar czasu.
- **F1a portale** — wydzielenie wyboru wejścia / wyjścia z `interior_room_layout_generator.gd` P9 do wspólnej
  funkcji — **osobny mały commit + parytet jaskini 42/42** (jedyna zmiana na ścieżce jaskini).
- **F1b układ** — kroki 1–3 + kontrola A, rezerwacje, flaga `layout: "sewer"`.
- **F1c pionowy wycinek = test integracyjny architektury** — wycinek (fixture, stały seed / ręcznie zadany
  graf) z **dwiema kładkami w obu osiach** (kanał poziomy + pionowy z zakrętem), barierkami z końcami
  i przerwami, jednym przęsłem z filarami i jedną winietą z dojściem — minimalne wersje passów 4–9 na
  kontrakcie rezerwacji. Od `GenerationResult` po ruch w grze (MCP: `run_project` → `simulate_input`
  wzdłuż barierek, przez obie kładki, przy końcu barierki, do winiety; zgodność grafiki, fizyki i navmesh
  po synchronizacji; wrogowie przy kanale). Dopiero po akceptacji wycinka skalowanie.
- **F2 skalowanie sieci kanałów** (pełny krok 1 + 5 na całej mapie), **F3 lico** (4), **F4 posadzka** (6),
  **F5 winiety i gruz** (7–8) + kontrola B.
- **F6 rozgrywka i wydajność** — spawny, navmesh z barierkami; czas mierzony **osobno**: generowanie danych
  oraz pełny czas do gotowej sceny (kafle, fizyka, nawigacja) dla 160² i 250²; budżet: obecny + 20 % dla obu.
- **F7 strojenie** — galeria 12 seedów (artefakt „makieta | wynik” + tabela metryk), merge na `main` po akceptacji.

## Pliki
- Nowe: `scripts/generation/sewer/*.gd` (generator, passy, `sewer_reservations.gd`), `tools/mockup_extract.py`,
  `resources/maps/mockups/*.json`, testy lokalne w `tests/`.
- Zmieniane: `cave_generator.gd` (wybór układu), `interior_room_layout_generator.gd` (tylko F1a),
  `core/canal_layout.gd` (`rail_edges`, `bridge_clearance`, `lanes`), `core/generation_flags.gd` +
  `tiles/generator_behaviour_config.gd`, `resources/maps/config/sewer.json`, `objects_sewer.json`,
  `sewer.tres` (tekstowo), `Tiles.png` / `Props.png` (host + `_host/`), `docs/plan_generator_sciekow.md`,
  `docs/kontekst/scieki.md`.

## Weryfikacja
- Po każdej fazie: zrzut MCP `godot-runtime` okien oceny obok makiety (seedy 119 / 7 / 42; 160², 250²),
  raport `diag_sewer_metrics.gd` (twarde = zielone; miękkie = mediana i najgorsze 10 % w zakresie makiet).
- F0c zielony (kafle), piksele w granicach wyjątków.
- F1c: ruch postaci i wrogów na działającej scenie (MCP `simulate_input`, `run_script` z pozycją gracza).
- Regresja: `run_plateau_suite.sh` (parytet jaskini 42/42), `diag_objects`, `diag_tile_object_physics`,
  `diag_sewer_objects_runtime`, `diag_spawn_cells`, `diag_enemy_drift`.
- Czas: dane i pełna scena ≤ obecny + 20 %.
