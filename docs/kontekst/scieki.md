# Ścieki (sewer) — stan na 2026-10-10

Gałąź **`sewer-structured`** w submodule CienMgly (`modules/quiz_rpg`), założona z `sewer-tileset`; z `sewer-gen-v2`
przeniesione tylko wybrane elementy (F0b / F1a / F1b), `sewer-gen-v2` zostaje jako odniesienie — nie mergować.
(Uwaga: bieżący rozwój systemu drużyny, skilli i przedmiotów prowadzony jest na gałęzi `druzyna-balans`, która zawiera te zmiany).
Gra używa **nowej paczki Sewer** (pliki bez dopisku wersji: `sewer.tres`, `sewer.json`, `sewer_map_tiles.tres`,
`objects_sewer.json`); stara paczka jako `sewer_old.*`, grafika w hoście `assets/pixel_crawler/environments/sewer`
(nowa) i `environments/sewer_old` (stara). Plan i reguły układu: `docs/plan_generator_sciekow.md`. Znaczenie kafli
atlasu: pamięć `quiz-rpg-sewer-v2-atlas`.

## Pliki
- `resources/maps/sewer.tres` — TileSet. Źródła: 0 `Tiles.png`, 1 `Props.png`, 2 `Water.png`, 3 `Dungeon_Tiles`
  free packa (puste koryto), 4 `Extras.png` (ręczne kafle), 5 `Furniture` free packa, 6 „Filary” (`Tiles.png`).
  Tereny: `floor`, `void`, `dark_floor`, `foliage` (3), `grating` (5), `empty_canal` (6). User edytuje plik
  w edytorze — zmiany tekstowe, nie przez ResourceSaver.
- `resources/maps/profile/sewer_map_tiles.tres` — profil Named TileSet; edytor przypisań
  `scenes/tools/tile_profile_editor.tscn` (@tool, od strony atlasu: kafel -> rola / wariant / przesunięcie / warstwa).
- `resources/maps/config/sewer.json` — `"layout": "structured"`, sekcje `structured_layout` (w tym `platforms`),
  `facade_rhythm`, `facade_material`, `platform_tiles`, `tiling`, `scenes` (m.in. `chest` = skrzynia ścieków).
  Eksplorator map: „Ścieki” (F4).
- `resources/maps/config/objects_sewer.json` — katalog obiektów, `vignettes` (winiety), sekcja `gates`,
  `big_canal_gap`, `area_weights`.
- Układ: `scripts/generation/structured/` — `structured_layout_generator.gd` (pipeline), `linear_network_generator.gd`,
  `structured_zoning.gd`, `structured_room_packer.gd`, `structured_pathfinder.gd`, `structured_reservations.gd`,
  `structured_platforms.gd` (kształt platform), `core/linear_feature_layout.gd` (nakładka `canals`),
  `core/structured_state.gd`. Schody i osiągalność platform: `topology/plateau_pass.gd` (wspólne z jaskiniami).
- Kafle: `scripts/generation/tiling/` — `canal_placer.gd`, `facade_placer.gd`, `facade_material_planner.gd`,
  `rim_placer.gd`, `curb_placer.gd`, `grating_planner.gd`, `wall_1w_placer.gd`, `terrain_mask_planner.gd`,
  `plateau_renderer.gd` / `plateau_placer.gd` (platformy).
- Obiekty: `scripts/generation/objects/` — `object_planner.gd`, `wall_decor_planner.gd`, `gate_planner.gd`;
  sceny `scenes/objects/sewer/` (kolce, bariery bram, zamek, klucz, płyta naciskowa, skrzynia ścieków).
- Interaktywne: `scripts/interactables/` — `spike_trap.gd`, `gate_state.gd`, `gate_key.gd`, `gate_lock.gd`,
  `pressure_plate.gd`.

## Układ (structured)
Kolejność: strefy (`StructuredZoning`: kompleksy, brzegi jako komnaty) -> pakowanie pokoi -> ściany działowe
(`StructuredZoning.partitions`, po pakowaniu, własny RNG — nie zmienia reszty układu) -> siatka -> kanały
(`LinearFeatureLayout`) -> portale -> przejścia czyszczące -> `_drop_walled_canal_cells` -> `_fill_dead_end_slivers`
-> `_raise_facade_protrusions` -> barierki, ściany szer. 1 -> **platformy** -> maski terenu -> kratownice -> obiekty
(`GatePlanner.select` -> `ObjectPlanner` -> `WallDecorPlanner` -> `GatePlanner.emit`) -> spawny.
- **Kanały:** sieć pień + odnogi (R1–R7 z prototypu), mokre / puste wg szumu stref (`zone_frequency` 0.006 —
  drobniejszy dawał błędy zwężeń z korytarzem serwisowym), kładki co 24–28 kratek z prześwitem, barierki z
  przerwami i urwaniami (warstwa `Rails`), doły w pustym korycie, puste koryto terenem `empty_canal` + `foliage`.
- **Końce kanałów:** mogą wpływać pod ścianę we wszystkich kierunkach (`canal_end_under_wall`); 30 % zamkniętych
  (`canal_end_face_chance`), puste zawsze zamknięte. Każdy koniec ma lico kanału — „nad wodą” (zamknięty) albo
  „pod wodą” (widoczny tylko górny rant, `canal_end_face_rim_over_wall`), narożniki ramy IN_SE / IN_SW na `Rails`.
  Nad północnym końcem duża krata w łuku: zwykła, zatopiona (otwarty mokry koniec, przykryta ściekiem) albo
  obniżona na licu kanału (pusty koniec).
- **Kompleksy:** ściany działowe (`complex_partitions`): poprzeczne co 4–7 kratek, równoległe pasy, zawinięcia
  L / U (pokoiki z małym wejściem — decyzja usera: „mogą być, a nawet często”), drzwi 1–3, jedna widoczna grubość
  na ścianę (2 albo 3; pozioma o `facade_extra` 2 kratki grubsza, bo dół zajmuje lico). Grubość 1 user zrobi ręcznie.
- **Pokoje:** 10–17 × 9–14, korytarze z pokojami na zakrętach, ściany szerokości 1 (`wall_1w_*`), krawężniki
  na progach (północne / zachodnie wsunięte w przejście, południowe / wschodnie na linii wylotu).
- **Kratownice** (`grating`): wybierane po platformach i maskach terenu — omijają platformy, foliage najwyżej na
  skraju (tylko kratki obwodu, `foliage_edge` 0.34).
- **Występy ścian:** występ, którego góra spotyka się z górą lica, podnoszony (`_raise_facade_protrusions`).

## Platformy
Podwyższona część pomieszczenia pod jego ścianą — wspólny `PlateauPass` z jaskiniami (parytet jaskiń 42/42).
- **Kształt** (`StructuredPlatforms`, `structured_layout.platforms`): pas pod ścianą (`sides` N / S / E / W) w hali
  kompleksu, komnacie albo pokoju (`sources`: szansa na rodzaj, pokój od `room_min_area`), od ściany do ściany (bez
  drzwi z boku), głębokość `top_rows` + krawędź, przed krawędzią `front` rzędów suchej podłogi; z dala od wody,
  chodników, kładek, barierek, bram, dźwigni, portali. `wobble`: krawędź łamana odcinkami różnej głębokości
  (pod ścianą N odcinki min. 5 — schody z poręczami). Miejsce na „korytarz = schody” (źródło `corridor`).
- **Lico** (`plateau_face_h` 3 + `facade_base_on_wall`): pod ścianą N lico na kratkach platformy — krawędź krzyża
  i 2 rzędy lica (jak moduł FACADE_3H), bez stopy (`PlateauLayout.face_up` 2 / `face_down` 0). Pod ścianami S / E / W
  krawędź to rim / bok krzyża 1 (jeden rząd).
- **Schody:** S z paczki (Tiles 12–16 × 9–11: poręcz, stopnie, poręcz) w losowym miejscu lica, poręcze zawsze na
  flankach (kolumna lica także przy ścianie), kolizja na poręczach. Paczka nie ma schodów N / E / W — w ich miejscu
  przejście w krawędzi (`PlateauPlacer._hole`: kafle platformy wymazane, kratki chodliwe).
- **Kafle** (`platform_tiles`): zestaw `sewer_platform` wyprowadzany w kodzie z `sewer` (top krzyża 2 -> krzyż 1,
  warianty bez cienia, wypełnienie wymazane) — profil bez zmian.
- **Teren:** góra platformy (z rimem / bokiem) malowana osobną partią — cień podłogi przy samej linii krawędzi; pod
  licem i schodami bez terenu, poza górnym rzędem (krawędź krzyża, nad licem wystają tylko poręcze).
- **Obiekty:** nie na barierach, obwódka wokół schodów, rysunek dużych obiektów nie wchodzi na lico ani schody.

## Korytarze-schody i efekt wysokości
- `StructuredStairs` (`structured_layout.corridor_stairs`): prosty pionowy korytarz (ściany po obu stronach, szer. ≤ 4,
  dł. ≥ 4), który jest jedynym przejściem do obszaru na północ (bez wejścia mapy, 30–900 kratek) -> cały to schody
  w górę (`canals.stair_corridors` / `stair_cells`; stopnie L / M / R modułu schodów platform, `CorridorStairsPlacer`).
  Bez obiektów, bram i ich otwieraczy, kratownic, krawężników, platform, mchu.
- `HeightVeil` (`scripts/maps/height_veil.gd`): po wejściu `veil_rows` (4) kratek schodów w górę albo w obszarze nad
  nimi reszta mapy znika pod kolorem voidu (płynnie); widać obszar, schody i ich ściany.

## Ściany i lico
Lico 3H / 4H z wariantami A / B, niezależny top, lico z cieniem we wnęce i przy filarze (tylko w rzędach, do których
filar sięga), łącznik 3H↔4H z kafli paczki, boki ścian wariant C, materiał lica (kaflowe / drewniane) na cały
obszar albo ciąg lica. Filary w rytmie przęseł (3 stany), wolnostojące i od strony rimu; ozdoby przęseł (łuki,
kratki, lampy, ramki), łańcuchy na filarach, rzędy otworów w posadzce pod przęsłami. Narożnik rimu bez wariantu B
bierze A (nie kafel jaskini).

## Obiekty
- Duże obiekty (meble, skrzynie, beczki, wraki, filary wolnostojące, skrzynia quizu) co najmniej kratkę od wody
  (`big_canal_gap` 1; przy ścianie wolno), głównie w pokojach i komnatach (`area_weights`, `room_density`,
  `per_chamber`), zestawy z odstępem liczonym po całym rysunku (jadalnia / magazyn / złom / szafa), krzesła przodem
  do stołu. Stoły 3 / 4 / 5 kratek, najwyżej jeden na pokój (`room_group`); filary wolnostojące z odstępem od mebli.
- Winiety (`vignettes`): kompozycje z makiet (skład pod licem, stos / kąt skrzyń, beczki) i wzory skupisk skrzyń
  (`cluster.patterns`, `pattern_chance`), tylko w halach, z wolnym pierścieniem.
- Wraki (grupa `wrecks`) to duże obiekty, gęstość 0.15. Połamane skrzynie z Furniture (`debris_src5`) usunięte —
  duplikat wraków z Props. Drobnica (`clutter`: deski, patyki, miedź) bez ograniczeń.
- Wyłączone: przełączniki na ścianie (`wall_switches`), bloki miedzi (miedziane kwadraty to płyty naciskowe).
- Na licu: ramki (`wall_frames`) tylko na licu 4H, kratkę nad bazą (`facade_dy` -1). Części obiektów nad bazą lica
  z niższym `y_sort_origin` niż lico (22) idą na warstwę `<warstwa>_up` (y_sort_origin 24) — lico ich nie przykrywa.
- Kontrola osiągalności (`ObjectPlanner._verify_reach`): z każdego odciętego kawałka zdejmowana jedna przeszkoda
  (najmocniej przylegająca), potem od nowa (model wroga, promień 7 px); ostatnie rundy po staremu (wszystko
  w promieniu 2); **kontrola B** z bramami — niżej.

## Kolce i bramy
- **Kolce** (`SpikeTrap`): TIMER (cykl z fazą z pozycji), PROXIMITY (jednorazowo), BARRIER (brama). Obrażenia:
  procent HP drużyny, bez zabijania. Otwory w posadzce zawsze widoczne pod kolcami, bez przesunięcia. Dźwięk
  pozycyjny (`sword-unsheathe2`, zasięg 240 px), przy schowaniu bramy niżej.
- **Bramy** (`GatePlanner`): w korytarzach serwisowych i na zwykłych korytarzach (odcinek prosty 2–4, odcina
  ≥ 40 kratek z pokojem, odstęp 20, `min_gates` 2). Najpierw brama, potem przełącznik ~14 kratek od niej po
  stronie bliższej wejściu (łańcuch: przełącznik dalszej bramy za bliższą). Otwieracz: płyta naciskowa
  (`plate_chance` 0.5) albo zamek na licu + klucz (klucz pokazuje się w zamku po włożeniu). Za każdą bramą
  płyta-skrót (~4 kratki, strona z geometrii bramy), bramy w okolicy (`plate_share_radius` 12) dzielą płytę.
  Kolce bram: zwykłe w siatce (wariant z przesunięciem wyłączony — nachodził na ściany).
- **Stan:** `GateState` w `LevelStateManager` — klucze `gate_key:<id>`, zużyte `gate_key_used:<id>`, bramy
  `sewer_gate:<id>`; kolce bramy w grupie `gate:<id>`; płyta może mieć kilka id po przecinku.
- **Kontrola B:** przejście z wejścia przy zamkniętych bramach (brama otwiera się po dojściu do płyty albo klucza
  i zamka); brama, której nic osiągalnego nie otwiera, nie powstaje (`gates_dropped_plan` / `_objects`).
- **Nawigacja:** kolce bram SOLID — navmesh omija zamkniętą bramę, spawny nie lądują na kolcach. Po otwarciu
  `GateNav` (`scripts/maps/gate_nav.gd`) przebudowuje kawałki siatki z bramą bez kolców otwartych bram
  (`NavOutlines.rebake_chunks`) — wrogowie przechodzą; bramy otwarte w zapisie od razu przy wczytaniu.

## Do zrobienia
- Rury z cieniem; kolejne winiety (wyjście ze schodami między filarami, skrzynia przy ścianie, dzbany / worki przy
  barierce); schody platform N / E / W (kafle robi user — wtedy role w `platform_tiles`); dziura w licu jako
  odpowiednik nisz OUT (user da przezroczystą teksturę).
- Zdejmowanie obiektów: 250² seed 7 19 (było 56), 160² 0–6.
- Podpięcie ścieków do gry (scena w `levels/`, szczury w puli wrogów).
- Opcjonalnie: region nawigacji przez bramę włączany przy otwarciu; strefy mapy oddzielone bramami (pomysł usera
  — tylko feedback, bez kodu).
- Do wyjaśnienia przez usera: Props (0,4), Props (1,10–12).

## Testy (lokalne, `modules/quiz_rpg/tests/` poza gitem)
- `render_sewer_level.gd` — render poziomu jak w grze (okno, `--screen 1`): `RS_SEED`, `RS_SIZE`, `RS_ENT`,
  `RS_FULL`, `RS_SCALE`, `RS_CROPS`, `RS_OUT`, `RS_JSON` (inny config), `RS_PLAT=1` (wycinki wokół platform).
- `probe_platforms.gd` (pasy, maska, schody), `probe_plat_cells.gd` (mapa znakowa: maska / bariery / schody / teren),
  `probe_grating_foliage.gd` (kratownice pod mchem), `run_plateau_suite.sh` (parytet jaskiń po zmianach PlateauPass).
- `check_gates.gd` — fizyka bram (bariera, zamek bez klucza, klucz, płyta, zapis stanu); `--fixed-fps 60`.
- `probe_gate_reach.gd` (kontrola B, navmesh na kolcach — `NAV=1`, płyty-skróty po złej stronie),
  `check_gate_drop.gd` (wymuszone odrzucenie bramy), `probe_gates.gd`, `probe_gate_objs.gd`, `probe_partitions.gd`,
  `probe_slivers.gd`, `probe_big_gap.gd`, `probe_edge_gap.gd`, `probe_count.gd`, `probe_region.gd` (mapa znakowa).
- Przed testem `--check-only` (błąd parsowania = test wisi), krótkie timeouty.
