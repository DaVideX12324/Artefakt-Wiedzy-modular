# Obiekty (generator obiektów)

Pliki: `scripts/generation/objects/` (planer, katalog, bake, realizer), katalog jaskiń
`resources/maps/config/objects_caves.json`. Plan faz: `docs/plan_generator_obiektow.md`.

## Poprawki z 2026-09-29 (commit 8e0248a)

1. **Duże obiekty nie zakrywają ścian**
   - `ObjectBake.visual` — obrys sprite'ów względem origin sceny; `ObjectDef.visual_rect` — obrys
     względem punktu obiektu (sceny: suma wariantów, origin pół kratki nad punktem; kafle: `size`).
   - `ObjectDef.is_large()`: podstawa > 1 kratka albo grafika > 1,5 kratki (24 px) w szerokości/wysokości.
     W katalogu jaskiń: duże/średnie/małe fioletowe grzyby, koralowce czerwone, stalagmity, glow_plant.
   - `ObjectPlanner._visual_on_wall`: żadna kratka pod obrysem (pomniejszonym o 3 px, obie strony przy
     `flip_h`) nie może być ścianą ani leżeć poza mapą. Sprawdzane w `_try_place` i `_try_free`.
2. **Skrzynie mają wolne wejście**
   - Skrzynie (INTERACTIVE, priorytet 500) stawiane są przed przeszkodami.
   - `ObjectPlanner._reserve_access` (z `_finish`): BFS od wolnych sąsiadów skrzyni (bez barier
     i obiektów) do najbliższej kratki RESERVED / wejścia; droga poszerzona o 1 → RESERVED na kratkach
     niezajętych przez obiekty (katalogi, gdzie przeszkody mają wyższy priorytet niż skrzynia, nie
     dostają przejścia pod już postawionym obiektem). Przeszkody z `keep_paths`
     nie zachodzą na RESERVED nawet częściowo (`_shape_on_reserved`); wcześniej zajętość liczona
     środkami kratek przepuszczała kamień w połowie wejścia do niszy.
   - „Nisza” = tag kontekstu (podłoga ze ścianami z 3 stron), nie dekoracyjne nisze kafli ścian.

Wynik na 21 mapach (bez spłaszczania): duże obiekty na ścianie 2421 → 0, zasłonięte skrzynie 7 → 0.
Dużych obiektów ~20% mniej (7919 zamiast 10029) — jeśli za pusto, podnieść gęstość w katalogu.
Nie oglądane jeszcze w grze.

## Obiekty na licu ściany i katalog ścieków (2026-10-04, gałąź `sewer-tileset`)

- `"mount": "facade"` w katalogu -> `ObjectCatalog.wall_defs` (planer podłogi ich nie widzi), stawia je
  `objects/wall_decor_planner.gd` po `ObjectPlanner` (dopisuje do tego samego `ObjectPlan`). Kotwica = dolna
  kratka lica nad podłogą (z `facade_base_on_wall`; bez niej pierwsza kratka podłogi — nieużywane w
  jaskiniach). Wymaga ciągłego lica (ściana >= 3) w kolumnach obiektu i 1 kolumnie po bokach, poza
  portalami; tagi `over_floor` / `over_canal`; `density` (na 100 kolumn lica) / `count`, `spacing`, `size`
  (szerokość w kratkach). Bez kolizji i zajętości. Realizer sortuje je tuż nad podłogą pod licem
  (`WALL_SORT_DROP`). Origin sceny = środek kratki cokołu.
- `pebble_large` przeniesiony do sprite'ów bez kolizji (main 4480fff, baseline parytetu zaktualizowany).
- Katalog ścieków `resources/maps/config/objects_sewer.json` — **wszystko jako kafle** `sewer.tres` (decyzja
  autora: w ściekach obiekty są na siatce z y-sortem). Pola katalogu: `"source"` (źródło atlasu; Props.png = 1),
  `"tiles": [[dx, dy, x, y], …]` (moduł z kilku kafli, np. kratka ściekowa 9-slice, łuki). W `sewer.tres`
  (edycja tekstowa): kafle wielokratkowe Props z kotwicą w lewym-dolnym rogu (`texture_origin` =
  (-(w-1)·8, (h-1)·8)), `y_sort_origin` (płaska drobnica / kratki -8, lico 7, górny rząd łuku 23), kolizja na
  `physics_layer_1` = ObjectCollisions (32). Poligony kafla liczą się od środka kratki kotwicy (Godot nie
  przesuwa ich o texture_origin — test `tests/diag_tile_object_physics.gd`); `"shape"` w katalogu = ten sam
  obrys względem punktu obiektu (planer, nawigacja). Lico (`mount: facade`) zawsze na warstwie Props.
  Render z obiektami: `tests/render_sewer.gd` (`RS_CROP=x,y,w,h` = zbliżenie ×2); runtime w eksploratorze:
  `tests/diag_sewer_objects_runtime.gd`.

**Dźwignie bram (2026-10-21, CienMgly 3540c84):** trzeci otwieracz bramy z kolców obok klucza z zamkiem i płyty —
`GatePlanner` zamienia płytę na dźwignię z szansą `lever_chance` (katalog `gates`: `"lever"`, `"lever_chance"`;
w ściekach 0,5), scena `scenes/objects/sewer/gate_lever.tscn` (Pixel Crawler free pack `Dungeon_Props.png`: rączka
w lewo = off, pion, w prawo = on; bez kolizji) na kratce `canals.levers`, interakcja klawiszem, stan w zapisie jak
zamek (`GateState`), otwiera tylko swoją bramę (nie jest wspólna jak płyta). Test `tests/check_gate_lever.gd`.
W arkuszu są też dźwignie w widoku z boku (rząd 2) — na lico, gdyby były potrzebne.

Zostało w planie generatora: F5 (leniwe sceny), podgląd (nakładka zajętości / przejść, statystyki), obejrzenie
kafli wielokratkowych na `Props`. Dla ścieków: barierki przy kanałach,
mech (teren foliage), filary w licu, skrzynia w grafice ścieków.

Test: `tests/diag_object_access.gd` (w zestawie `run_plateau_suite.sh`). Parytet: zmieniło się tylko
pole `spawns` (spawny zsuwane z przeszkód) — baseline zaktualizowany.

## Zawartość nisz out (2026-10-21)
- Nisze out (sekretne, `NichePlacer`) powstają dopiero przy kaflach ścian, więc zawartość dokłada osobny krok po planie
  kafli: `NichePlacer` zapisuje nisze w `ctx.out_niches` (lewa kolumna pary, rząd stopy = podłoga przed niszą),
  `plan_cave_tiles` przenosi je do `result.out_niches`, a `NicheContentPlanner.plan` (wołany w `ProceduralLevel.GenJob`,
  przed siatką nawigacji i zapisem mapy na dysk) dopisuje obiekty do `result.objects`.
- Rodzaj z wag `niche_content.weights` w JSON mapy (jaskinie: przedmiot 50, skrzynia 35, sekretny pokój 15 — **decyzja
  usera 2026-10-21**); rodzaj z wagą 0 (albo sekretny pokój bez `secret_scene`) wypada, reszta proporcjonalnie — każda
  nisza ma zawartość. RNG z hash(seed mapy, kratka niszy).
- Obiekt stoi w głębi niszy (`OFFSET` (8, −14) px: granica kolumn, nad rzędem stopy); gracz sięga go z podłogi przed
  niszą. Dwa rzędy przed niszą są czyszczone z innych obiektów (zasłaniały zawartość); nisza z obiektem interaktywnym
  przed nią zostaje pusta.
- **Skrzynia** (`niche_chest`, scena-alias `chest` mapy): tier `niche_content.chest_tier` (jaskinie 2 — stalowa, wytrych
  = 4 pytania) i tabela `niche_content.chest_loot` (lepszy sprzęt, mikstury ×2–3), nakładane w
  `ProceduralLevel._apply_niche_content` po zwykłym `chest_tier` / `chest_loot`.
- **Przedmiot na ziemi** (`niche_item`, `scenes/objects/ground_item.tscn`, `QuizRpgGroundItem`): Area2D w grupie
  `interactable` (warstwa 4), ikona przedmiotu z unoszeniem i błyskiem, „Podnieś” (`prompt.pick_up`), toast łupu jak z
  beczki; stan `picked_items` w `LevelStateManager` (`mark_item_picked` / `is_item_picked`). Przedmiot z
  `niche_content.item_loot` wybrany po hash(seed mapy, unique_id) — ta sama mapa, ta sama nisza, ten sam przedmiot.
- **Sekretny pokój** (`niche_secret`, 2026-10-21) — **decyzja usera: osobna mapa z 1 pokoju albo najwyżej 2–3 pokoi
  generatora**:
  - W niszy `scenes/objects/secret_passage.tscn` (`QuizRpgSecretPassage`): ciemny prześwit i mgła, „Wejdź”
    (`prompt.enter_secret`). `_apply_niche_content` ustawia mu `on_enter` = zmiana poziomu na
    `<secret_scene>#<poziom>@<x>,<y>` i stawia przed niszą marker powrotu `Secret_<x>_<y>`.
  - Ścieżka z argumentem (`QuizRpgPaths.level_scene / level_arg / level_name`): scenę wczytuje się z części przed `#`,
    stan poziomu trzyma się całej ścieżki, seed mapy i plik mapy na dysku — `level_name` („cave_secret~cave.tscn@x,y”),
    więc każda nisza ma własną mapę. `level_manager` ustawia `ProceduralLevel.level_path` przed `add_child`; argument
    `<poziom>@<x>,<y>` daje `previous_level_path` / `previous_spawn_name` (powrót wejściem mapy do markera).
  - `scenes/maps/levels/cave_secret.tscn` (jaskinia, nazwa „Ukryta grota”) z `config_overlay = "secret_room"`: sekcja
    `secret_room` w `caves.json` scalana w głąb z resztą pliku — mapa 56×56, pokoje 8–16, liczba pokoi `"rooms": [1, 3]`
    z seeda mapy, flagi `portal_exit: false` (bez wyjścia) i `exit_enemy_tier: 3` (miniboss w najdalszym pokoju zamiast
    bossa, nie przy jednym pokoju), bez płaskowyżów, bez kolejnych sekretnych pokoi.
  - Skarb: `TreasurePlanner` (sekcja `treasure`) — `count` skrzyń w pokoju najdalszym od wejścia, blisko środka, na
    otwartej podłodze; unique_id `treasure_chest_…`, tier 2 i własny łup (stal, łuk, włócznia, amulet, klucz tieru 2,
    mikstury ×3) w `_apply_special_chests`.
- Testy: `check_niche_content` (4 mapy: jedna zawartość na niszę, czysto przed niszą, proporcje, powtarzalność),
  `check_secret_room` (cele i markery przejść, mapy sekretu: rozmiar, pokoje, bez wyjścia i bossa, skarb osiągalny,
  powrót), `check_ground_item`, rendery `render_niche_content` / `render_secret_room` (z oknem), diagnostyka
  `diag_out_niches`.
- Zostało: rzadkie pokoje ze skrzyniami specjalnymi, nisze w ściekach (brak kafli nisz out), sprawdzenie w grze.

## Beczki — łup (2026-10-11)
- Łup z beczki to powiadomienie bez pauzy (`LootManager.show_loot_toast`: ikona + nazwa ×liczba, prawy dolny róg, znika po 3 s, maks. 8 naraz) — bez popupu i klikania. Skrzynie nadal używają popupu (`show_loot_popup`).
- `LootManager.search_barrel(extra_chance, decay, max_items)`: **1. losowanie z tabeli jest gwarantowane**, k-te (k ≥ 2) wypada z szansą `extra_chance × decay^(k−2)` pod warunkiem, że wypadły poprzednie (domyślnie 0,6 / 0,5 / limit 4: P(2+) = 60 %, P(3+) = 18 %, P(4) = 2,7 %, średnio ≈ 1,8 losowania); powtórzenia sumują się w kopie (mikstura 1–3, reszta 1–2). Beczki czytają wartości z metadanej rodzica `barrel_loot` {extra_chance, decay, max_items} albo z eksportu `extra_item_chance` (ujemna = domyślne z LootManager); w `tutorial_area` (węzeł Destructibles) 0,85 / 0,7 / 4 (średnio ≈ 2,8 losowania) — do czasu sklepów (po jaskiniach). Testy `check_barrel_model`, `check_barrel_loot`.

## Klucze i wytrychy (2026-10-11)
- Przedmioty `universal_key` (Klucz Uniwersalny) i `lockpick` (Wytrych), kategoria `key`, ikony z paczki 16×16 (item692 / item712). `PlayerStats.get_item_count`.
- Wszystkie skrzynie zamknięte (także tutorialowa): `Chest.try_open` — wytrych (używany przed kluczem) uruchamia quiz (`quiz_puzzle_ui`; `tier` skrzyni: 2 + tier pytań, tier + 1 poprawnych), udany quiz zużywa wytrych i otwiera; porażka — 50 % szans na złamanie wytrycha (`LOCKPICK_BREAK_CHANCE`), inaczej można spróbować znowu. **Klucz na tier (2026-10-12):** klucz tieru N otwiera skrzynie tieru ≤ N, zużywany jest najsłabszy wystarczający (`KEY_ITEMS`: `key_tier1` brązowy, `key_tier2` srebrny, `key_tier3` szafirowy, `universal_key` złoty = każdy tier); ikony z paczki Kyrise (`key_01a/c/e/d`, `assets/item_icons/`). Bez kluczy i wytrycha toast „Zamknięte. Potrzebny klucz tieru N (lub wyższego) albo wytrych.” **Wygląd na tier:** eksport `tier_frames` skrzyni (indeks tier − 1) w `closed_chest_tutorial.tscn`: tier 1 drewniana (obecna), 2 stalowa, 3 niebieska, 4 złota — arkusz `legacy_amonra/atlases/Chests/RPG Chests.png`, kolumny 6 / 1 / 4 / 7, animacja otwarcia 4 klatki; setter `tier` podmienia wygląd (np. po nałożeniu `chest_tier` z JSON mapy); skrzynia ścieków ma pustą listę (własny wygląd z paczki). Inne skrzynie w paczkach (do ewentualnych wariantów): `RPG Chests.png` ma 9 kolorów (m.in. zielona, czerwona, ozdobna, czaszka), `nieodkryteglebiny_textures/Chests/All Chest Sheet.png` 16×16 (zielona / niebiesko-złota / brązowa ze stalą, z iskrami), pustynia `Props.png` dwie skrzynie, `doors_lever_chest_animation.png` drewno z żelazem. `tier` z JSON mapy (`chest_tier`: jaskinie 1, ścieki 2).
- Źródła: wytrychy z beczek (`LootManager`, waga 30, 1–2 szt.); klucze: z tabel łupu map (`enemy_loot` / `chest_loot` w JSON: jaskinie `key_tier1` 4 / 7 / 11 % wg tieru wroga, boss 30 % `key_tier2`; ścieki `key_tier2`, boss `key_tier3`), a na mapach bez tabeli (tutorial) z `QuizCombatController._roll_item_drops`: `key_tier1`, tier 1 4 %, 2 7 %, 3 11 %, 4/boss 30 %. Testy `check_chest_lock`, `check_loot_tables`.
