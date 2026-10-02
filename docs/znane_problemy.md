# Znane problemy i rzeczy odłożone (quiz_rpg — generator jaskiń)

> Spisane 2026-09-25. Każdy punkt: co jest nie tak, dlaczego zostało jak jest, kiedy do tego wrócić.
> Po naprawie punkt usuwamy albo przenosimy do „Rozwiązane” z numerem commita.

## Odłożone świadomie

(brak)

## Do zrobienia (zgłoszone, następnym razem)

### Nisze przy ścianie 3H: bez narożników wewnętrznych na górze (przejście), bez sekretnego pokoju
- Zgłoszenie 2026-09-29, przykład: `…/scratchpad/bulge_po_zmianach/bulge_103107_160_0.png` (seed 103107 160×160,
  okolice (83–100, 104–119); przypadek jest po obu stronach porównania, więc występuje też bez spłaszczania
  wybrzuszeń — ten seed nadaje się do testu).
- W skrypcie nisz (`tiling/niche_placer.gd`, kandydaci w `EdgeAnalyzer` — `is_niche_candidate` /
  `is_secret_niche_candidate`) dodać warunek: jeśli ściana ma wysokość 3 przynajmniej na jednej części niszy,
  **nie stawiać narożników wewnętrznych na górze** — powstaje wtedy ładne przejście.
- Taka nisza **nie może mieć sekretnego pokoju** (ani przejścia do niego) — por. wpis o zawartości nisz out.

### Tryb walki: interfejs, pozycje wrogów, marginesy per tło, losowe spotkania
- Zgłoszenie 2026-09-29. Scena `scenes/quiz/quiz_combat_ui.tscn`, logika `scripts/quiz/quiz_combat_controller.gd`,
  tła `scripts/quiz/battle_background.gd` + `background_generators/*`.
- **Interfejs walki** — zrobiony w stylu RPG Makera (2026-09-30), WYSIWYG; zostały okna Umiejętności /
  Przedmioty w starym wyglądzie i niesprawdzone w grze typy pytań bossów (wpisywanie, kafelki, dopasowanie).
  Tło okien = asset UI od usera -> resources/ui/quiz_theme.tres (QuizWindow).
- **Losowe spotkania jak w JRPG**: wrogowie niewidoczni na mapie, walka zaczyna się nagle podczas chodzenia.
  Tryb obok obecnego (wrogowie widoczni) — np. włącza się po pokonaniu wszystkich wrogów na mapie; zasada
  do ustalenia (per mapa / per biom, szansa na krok, strefy bez spotkań: portale, schody, sekretne pokoje).

### Zawartość nisz out, sekretne pokoje, klucze i wytrychy do skrzyń
- Zgłoszenie 2026-09-29. Dziś nisze z modułów out (`tiling/niche_placer.gd`, szansa
  `secret_niche_spawn_chance`, kandydaci `EdgeContext.is_secret_niche_candidate`) są tylko kaflami ścian.
- **Każda nisza out ma zawartość, losowaną**: przedmiot na ziemi, skrzynia albo **przejście do
  sekretnego pokoju**. Sekretny pokój: osobna mała mapa / podpokój z nagrodą — mocny przedmiot, miniboss
  z dobrym lootem albo inna niespodzianka (lista do rozbudowy). Wagi losowania do ustalenia.
- **Klucze i wytrychy do skrzyń** — oba wypadają z potworów, **klucze dużo rzadziej**.
  - Klucz: otwiera skrzynię od razu.
  - Wytrych: otwarcie uruchamia **sekcję quizu**; **tier skrzyni** wyznacza trudność i liczbę pytań
    (porażka — do ustalenia: wytrych przepada / skrzynia się blokuje / można spróbować znowu).
- Punkty zaczepienia: `scripts/interactables/chest.gd` (`lock_id`, `is_locked`, `chest_item_id`),
  skrzynie z generatora obiektów (INTERACTIVE `chest`, `unique_id` "<id>_<x>_<y>"), loot z wrogów
  (`autoloads/loot_manager.gd`, `enemy_data.encounter_tier`), quiz (`scripts/quiz/` — kontrolery
  walki / zagadki, `quiz_door.gd` jako wzór bramki quizowej).
- Do ustalenia przy realizacji: skąd tier skrzyni (głębokość / poziom mapy / nisza vs pokój), zapis stanu (otwarte skrzynie / odwiedzone
  sekretne pokoje per save, jak pokonani bossowie).

### Spójna ścieżka postępu między mapami (kierunki wejść i wyjść)
- Zgłoszenie 2026-09-30. Kolejne mapy mają układać się w jedną ciągłą trasę: jeśli mapa ma wejście na
  południu i wyjście na północy, następna musi mieć wejście na południu (przyszliśmy z jej południa), a nie
  wyjście na południe — inaczej mapy „nakładają się” w wyobrażonej przestrzeni świata. Tak samo przy
  powrocie (mapy wstecz): wyjście poprzedniej = wejście bieżącej po przeciwnej stronie.
- Dziś krawędź portalu wybiera `PortalGenerator.carve_portal_alcove` (najbliższa krawędź pokoju, wyjście
  tylko `avoid_edge` = inna niż wejście) — bez wiedzy o sąsiednich mapach. Punkty zaczepienia: łańcuch map
  (`ProceduralLevel.next_level_path` / `level_key`, seedy w `lsm.set_map_seed`), `level_manager.change_level`.
- Pomysł: zapisywać per mapa krawędź wejścia i wyjścia (albo pozycję mapy na siatce świata) i przekazywać
  generatorowi wymuszoną krawędź wejścia (= przeciwna do wyjścia poprzedniej) oraz dozwolone krawędzie
  wyjścia (nie w stronę już odwiedzonych pól siatki).

### Nowe flagi generatora: kształt pokoi, wejście na środku mapy
- Zgłoszenie 2026-09-30.
- **Kształt pokoi** do wyboru flagą (np. organiczne jak dziś / prostokątne / okrągłe / mieszane) — dziś
  pokoje rzeźbi `OrganicCaveRoomCarver` przez `RoomCarverFactory`; flaga w `GenerationFlags` + `caves.json`
  i wybór carvera w fabryce.
- **Wejście na środku mapy** (zamiast przy krawędzi) — szczególnie dla map ścieków (np. zejście włazem
  z góry). Dziś `PortalGenerator.carve_portal_alcove` zawsze wycina wnękę przy krawędzi mapy; potrzebny
  tryb portalu w pokoju (strefa wejścia bez wnęki), zgodny z płaskowyżami (`_portal_area`) i spawnami.

### Minimapa z fog of war
- Zgłoszenie 2026-09-30. W projekcie nie ma jeszcze minimapy.
- Minimapa w rogu ekranu (opcjonalnie pełna mapa pod klawiszem), odkrywana w miarę chodzenia: kratki
  w promieniu widzenia gracza przechodzą z „nieznane” na „odkryte” (fog of war); odkryte zostają.
- Źródło danych: wynik generacji (`GenerationResult.grid`, płaskowyże — bariery / schody, portale),
  np. jako `Image` W×H rysowany raz, plus maska odkrycia (`PackedByteArray`) aktualizowana przy ruchu.
  Znaczniki: gracz, wejście / wyjście, opcjonalnie skrzynie i odwiedzone nisze.
- Do ustalenia: promień odkrywania (z linią wzroku po ścianach czy bez), zapis maski odkrycia per mapa
  w save (jak seedy map), mapy ręczne (tutorial_area) — z TileMapLayer zamiast z wyniku generacji.

### Mapy otwarte z uniwersalnego generatora (las zamiast ścian)
- Zgłoszenie 2026-10-01. Pomysł: mapy otwarte (las, Fairy Forest, Dense Forest…) z tego samego generatora co
  jaskinie — topologia (pokoje, korytarze, płaskowyże) bez zmian, ale **teren (podłoga, wzniesienia) na całej
  mapie**, a tam, gdzie jaskinia ma ściany, **gęsto drzewa**, przez które nie da się przejść.
- Dziś mapy otwarte robi osobny `overworld_forest_generator.gd` (szum + polany + ścieżki, ~170 linii) — nowa
  ścieżka by go zastąpiła i dała lasom płaskowyże, teren, obiekty, nawigację i postęp ładowania jak w jaskiniach.
- Proponowany podział:
  - **Kolizja z siatki, nie z drzew:** kratki ścian zostają blokujące (niewidoczna warstwa kolizji / Walls bez
    grafiki); drzewa tylko rysują. Gęsto stawiane drzewa z małymi kształtami pni i tak zostawiałyby szczeliny,
    a nawigacja (`NavOutlines`) już liczy z siatki.
  - **Pas brzegowy** (1–3 kratki od podłogi): drzewa jako obiekty (`ObjectPlanner`, katalog np.
    `objects_forest.json`, kontekst przy ścianie), z y-sortem — postać może wejść „za” pień.
  - **Głąb lasu:** nie kafle koron, które muszą do siebie pasować (korony są szersze niż kratka → luki albo
    niedopasowane krawędzie), tylko **całe drzewa nachodzące na siebie** — jak w makiecie
    `assets/pixel_crawler/environments/world_build/MockUps/Trees.png`: duże kafle wielokratkowe (sprite drzewa
    z `Tree.png` Fairy Forest) w rozstawie mniejszym niż szerokość korony (np. co 2–3 kratki), z y-sortem
    (przednie przykrywają tylne) i przesunięciem przez kafle alternatywne z innym `texture_origin`.
    Na TileMapLayer, nie jako obiekty — przy 500×500 to setki tysięcy kratek.
  - **Ciemne podłoże pod lasem** (kafel cienia zamiast trawy) — ewentualna szczelina między koronami wygląda
    wtedy jak cień, nie jak dziura. W `Tree.png` są też same korony w 6 odcieniach aż do prawie czarnego —
    ciemniejsze głębiej w lesie.
  - **Wariacja mimo siatki** (autor chce drzew nie w równym gridzie), do połączenia:
    - kafle alternatywne w TileSecie — każdy może mieć własny `texture_origin` (przesunięcie o kilka px),
      odbicie, `modulate` (odcień) i `y_sort_origin`; generator losuje alternatywę → drzewa „poza siatką”;
    - osobny TileSet warstwy drzew z drobniejszą kratką (np. 8 px zamiast 16) — więcej możliwych pozycji;
    - w pasie brzegowym (blisko gracza) drzewa jako obiekty w trybie `free` — pełna dowolność pozycji;
      wypieczona scena (`ObjectBake`) pozwala złożyć drzewo z wielu sprite'ów jak „moduł”.
    - Sprawdzone (Godot 4.7.2): `texture_origin` przesuwa **tylko grafikę** — kolizja alternatywy zostaje
      na kratce (każda alternatywa ma własne kształty, więc trzeba by je przesuwać ręcznie). Przy kolizji
      z siatki to bez znaczenia; tylko na brzegu przesunięcie w stronę polany ograniczyć, żeby rysunek pnia
      nie wchodził na kratki podłogi.
  - Do sprawdzenia: kafle wielokratkowe na warstwie z y-sortem (por. „Do sprawdzenia w grze” → kafle
    wielokratkowe na `Props`) i koszt rysowania przy 500×500.
  - Autotiling ścian (`EdgeAnalyzer`, fasady 2H/3H) wyłączony dla tego stylu — flaga stylu ścian
    (kafle skalne / las) w `GenerationFlags` + JSON biomu (por. wpis „Nowe flagi generatora”).
- Do ustalenia: krawędzie płaskowyżów pod drzewami (klify widoczne tylko na polanach?), wyjścia mapy w lesie
  (przecinka w pasie drzew), wygląd przejścia polana → las (krzaki, pojedyncze drzewa przed ścianą).

### Ustawienia sterowania per moduł, wybór modułu w menu głównym
- Zgłoszenie 2026-10-01. Dziś jedna lista w opcjach hosta (`scripts/ui/options_menu.gd`, `BINDS`) miesza
  akcje BitBombera (`p1_*`, `p2_*`) i Quiz RPG (`move_*`, `interact`) i tylko je **wyświetla** (bez zmiany
  klawiszy).
- Cel: każdy moduł ma własną sekcję sterowania (lista akcji z modułu, np. w `module_manifest.json` albo
  z prefiksu akcji — por. `docs/module_contract.md`: akcje z prefiksem gry), a w opcjach z menu głównego
  jest **select modułu** (Quiz RPG / BitBomber / …), który przełącza listę.
- Przy okazji: zmiana klawiszy (rebind) z zapisem per moduł w `SettingsService.set_module(...)`.

### Ustawienia w menu Quiz RPG
- Zgłoszenie 2026-10-01. Menu modułu (`modules/quiz_rpg/scenes/ui/main_menu.tscn`, `pause_menu.tscn`)
  nie ma opcji. Dodać wejście do ustawień (najlepiej ten sam panel co z menu głównego hosta, od razu
  z wybranym modułem Quiz RPG — patrz wpis wyżej) — także z pauzy w trakcie gry.

### Modularność assetów i autoloadów (moduł samodzielny bez dublowania w eksporcie)
- Zgłoszenie 2026-10-01. Pomysł: moduł trzyma też kopie assetów i autoloadów, które w hoście zapewnia
  główny projekt (żeby dało się go uruchomić samodzielnie), a w hoście te kopie są ignorowane — nie ma
  dublowania w edytorze ani w eksporcie.
- Wykonalne: kopie w jednym folderze modułu (np. `modules/<id>/_standalone/`) z plikiem `.gdignore` —
  host w ogóle go nie widzi (bez importu, bez eksportu, bez konfliktów `class_name` i UID). Wersja
  samodzielna: `project.godot.off` -> `project.godot` + usunięcie `_standalone/.gdignore` (skrypt
  „make standalone”), autoloady z kopii zarejestrowane w `project.godot.off`.
- Kopie z tymi samymi UID co oryginały (kopiować razem z `.uid` / `.import`) — sceny modułu odwołują się
  po `uid://`, więc trafią w oryginał w hoście i w kopię w wersji samodzielnej, mimo innej ścieżki.
- Tryb pracy (decyzja usera): zmiany assetów / zasobów / skryptów robione w hoście, co jakiś czas
  synchronizowane do modułów — skrypt synchronizacji (host -> `_standalone`) zamiast ręcznego kopiowania.
- Stan ścieżek (2026-10-01, quiz_rpg): prawie wszystko to bezwzględne `res://` — ~350 odwołań w
  `.tscn`/`.tres` do assetów hosta (`res://assets/pixel_crawler`, `res://assets/textures`, `res://assets/fonts`),
  335 do `res://modules/quiz_rpg/...`, w `.gd` m.in. `res://scenes/ui/options_menu.tscn` (pause_menu),
  `res://scripts/shared/quiz/...` (quiz_combat_controller), `res://resources/items` (inventory_service),
  ścieżki `Tiles.png` w generatorach. Względne są tylko: 1 `preload("../…")` w `quiz_combat_controller.gd`
  i 3 w `scenes/enemies/ork_3.tscn`. Względne ścieżki w `.tscn` edytor i tak zamienia na `res://` przy
  zapisie, więc nie są sposobem na przenośność scen; w `.gd` (`preload("../x.gd")`) działają.
  UID ma 601 z 692 `ext_resource` — reszta po zmianie ścieżki by się nie znalazła (ponowny zapis sceny
  w edytorze dopisuje UID).
- Każdy moduł ma być osobnym repo podpiętym jako submoduł w `modules/<id>/` (jak BitBomber), więc wersja
  samodzielna = korzeń repo modułu jako `res://`. Plan:
  - **Kopie z hosta w lustrzanym układzie wewnątrz modułu** — host `res://assets/X` -> `modules/<id>/assets/X`,
    host `res://autoloads/...` -> `modules/<id>/autoloads/...`, każdy taki folder z `.gdignore` (host go nie
    widzi). Samodzielnie (korzeń modułu = `res://`) ścieżki hosta pasują 1:1; „make standalone” usuwa
    `.gdignore` i zmienia `project.godot.off` -> `project.godot`.
  - **Własne pliki modułu** (`res://modules/<id>/...` w hoście, `res://...` samodzielnie): UID w scenach
    (Godot szuka najpierw po `uid://`), względne `preload("../…")` w `.gd`, a ścieżki składane w kodzie przez
    przełącznik korzenia — jak `bb_runtime.gd` w BitBomberze (`HOST_MODULE_ROOT` / `STANDALONE_ROOT`).
    Względne `path="…"` w `.tscn` działają przy wczytaniu, ale zapis sceny (edytor, `ResourceSaver`) zmienia
    je na `res://modules/<id>/…` — sprawdzone na `ork_3.tscn`; zostaje wtedy tylko UID.
  - BitBomber już tak robi (względne ścieżki, 20/22 `ext_resource` z UID, `bb_runtime.gd`); quiz_rpg nie
    (patrz stan ścieżek wyżej).
  - Sprawdzone 2026-10-01 (Godot 4.7.2): `.tres` też przyjmuje względne `path="../…"` przy wczytaniu (ten sam
    format tekstowy co `.tscn`), ale zapis zmienia je na `res://…` — w praktyce zostają pełne ścieżki.
    Scena z błędną ścieżką do skryptu, ale poprawnym UID, wczytuje właściwy skrypt (fallback po UID działa).
  - **Blokada: `*.import` jest w `.gitignore`** (w repo tylko 4 pliki `.import`, `.uid` — 191). UID obrazków,
    fontów i dźwięków żyje w `.import`, więc każdy świeży klon generuje własne, losowe UID-y — odwołania
    `uid://` do assetów w scenach / `.tres` są wtedy nieważne („invalid UID - using text path”) i działa tylko
    ścieżka. Ginęłyby też ustawienia importu per plik. Godot zaleca commitować `.import`; zrobić to
    **z maszyny autora** (tam UID-y zgadzają się ze scenami) — usunąć `*.import` z `.gitignore`
    i dodać pliki `.import`. Bez tego fallback po UID nie obejmie własnych assetów modułu.

## Do sprawdzenia w grze (testy headless tego nie widzą)
- **Kafle wielokratkowe na warstwie `Props`** (obiekt z `"atlas"` i `size` > 1×1, placement `grid`) —
  ścieżka jest, ale nie była oglądana; kafel TileSetu rysuje się względem swojej kratki, więc duży kafel
  może być przesunięty względem podstawy. Obiekty ze scen (obecny katalog caves) tego nie dotyczy.
- **Kapelusze dużych grzybów nad ścianą** — y-sort po nodze trzonu, więc kapelusz rysuje się nad kaflami
  ściany na północ od niego (tak jak na mockupie). Sprawdzić, czy nie zasłania czegoś ważnego (portale,
  schody płaskowyżu).
- **Pozycja scen INTERACTIVE** — środek kratki kotwicy (dolny wiersz podstawy), jak dotychczasowe
  skrzynie; większe sceny interaktywne mogą wymagać własnego originu.

## Wydajność
- **Wypiekanie siatki nawigacji** — w kawałkach 64×64 kratek (`NavOutlines.build_chunks`, jeden
  `NavigationRegion2D` na kawałek pod węzłem `NavigationRegion2D`), w wątku roboczym, etap „Ścieżki
  przeciwników”. Cała mapa naraz rosła dużo szybciej niż pole przez obrysy przeszkód (seed 184356:
  250×250 7 s, 500×500 ~5,5 min w wolnym kontenerze, u autora ~63 s); w kawałkach 0,2 s / 0,7 s.
  Brzegi kawałków bez zwężania o promień agenta (`baking_rect` + `border_size`), regiony łączy serwer
  nawigacji. Ścieżki vs cała mapa: 250×250 400/400 par osiągalnych w obu, średnio 0,995 długości, żadna
  przez ścianę; 500×500 382 w obu, 0 tylko w całej, 5 tylko w kawałkach. Ostrzeżenia „edge error(s)” przy
  synchronizacji były już przy całej mapie (cienkie przejścia). Mapa nawigacji wczytuje regiony
  asynchronicznie (kilka klatek fizyki) — do tego czasu wróg bez ścieżki idzie prosto tylko przy czystej linii.
- **Na 500×500 ~1/3 losowych par kratek nie miało ścieżki** (seed 184356) — wyjaśnione 2026-09-30
  (`tests/diag_nav_reach.gd`, lokalnie): to **limit zapytania Godota `path_search_max_polygons` = 4096**
  (map_get_path / query_path — po nim ścieżka do punktu najbliższego celu), nie siatka. Obiekty mnożą
  wielokąty (dziury), więc długie zapytania przez 500×500 go przekraczają. Bez limitu: 1 / 300 (rzadkie
  prawdziwe zwężenie przez przeszkodę), po zmianie w planerze (osiągalność jak dla wroga, niżej) 0 / 300.
  Wrogowie też pytają z limitem 4096 (`enemy_base.gd`, pościg / wałęsanie), ale ich ścieżki są krótkie.
  Podniesienie limitu u nich — tylko gdy pojawią się długie trasy (bez limitu nieosiągalny cel przeszukuje
  całą mapę przy każdym przeliczeniu ścieżki).
- **Planer obiektów sprawdza osiągalność jak wróg** (`ObjectPlanner._clearance` / `_bfs_agent`): po środkach
  kratek, z odstępem promienia agenta (7 px) od dokładnych obrysów przeszkód (`NavOutlines.placement_outlines`,
  te same co siatka); odcięty teren -> zdejmowane przeszkody w promieniu 2 kratek. 250×250: -18 z 2623 obiektów,
  etap osiągalności 26 -> 40 ms.
- **Pętla naprawy płaskowyżów** (`PlateauPass._solve`) ~750 ms na 250×250 (BFS po mapie × ~8 iteracji) —
  kandydat na płaskie tablice (jak w `ObjectPlanner`).
- **Planer obiektów** ~95–110 ms na 250×250 przy ~500 obiektach, ale z pełnym katalogiem caves
  (~3,4 tys. obiektów z towarzyszami) ~340 ms — w wątku roboczym, ale wydłuża ładowanie. Najdroższe:
  cechy mapy (`ObjectFeatures`, ~40 ms), BFS rezerwacji przejść, pętle kandydatów dla gęstych DECAL-i.
- **Kształtowanie masek terenu** (`TerrainMaskPlanner.shape_mask`) ~130 ms na 250×250 (dwie maski).
- **Etap `entities`** jest ciężki przez odtwarzanie sceny `slime_tutorial` przy każdej instancji
  (ostrzeżenie „re-save this scene”) — po ponownym zapisie sceny w edytorze powinno spaść.
- `closed_chest_tutorial.tscn` ma nieaktualny UID tekstury (ostrzeżenie „invalid UID … using text path”)
  — do ponownego zapisu w edytorze. To samo dotyczy prawie wszystkich `resources/enemies/*.tres`
  (SpriteFrames orków, dzika, bandytów, slime'ów…, sprawdzone 2026-09-30) — grafiki ładują się po ścieżce.

## Pułapki konfiguracji (działa zgodnie z założeniem, ale łatwo się naciąć)
- Wróg z przypisanym `enemy_data` bierze `detection_radius` (i inne statystyki) z niego, nie z inspektora
  sceny — np. Enemy5 w `tutorial_area.tscn` ma pusty `enemy_data`, więc zasięg = domyślne 150.
- **Gęstość obiektu jest per obiekt, nie per grupa.** Warianty jednego rodzaju dawać jako listę scen
  w jednym obiekcie (`"scene": [a, b, c]`), a nie jako osobne obiekty — inaczej gęstość się mnoży.
  Narzędzie/wtyczka katalogu dodaje każdą nową scenę jako osobny obiekt → po dodaniu wariantów scalić
  je ręcznie w listę.
- **Gęstość = sztuk na 100 kratek-kandydatów**, a kandydaci zależą od reguł (`terrain`, `context`).
  Obiekty tylko na trawie skalują się z pokryciem trawą (`terrain_grass_*` w caves.json).
- **Wtyczka Object Catalog Sync** nie usuwa wpisów po skasowanych scenach (robi to narzędzie
  `tools/sync_object_catalogs.gd` z `REMOVE_MISSING = true`) i zostawia grupy bez obiektów w pliku.
- **Skrypty używane w edytorze** (narzędzia, wtyczka) muszą być `@tool`, jeśli mają `static var` —
  edytor nie inicjalizuje statycznych zmiennych skryptów bez `@tool` (stąd leniwe mutexy w
  `ObjectBake` / `ObjectCatalog`).
- **Maski terenu liczone raz** w etapie obiektów (`GenerationResult.terrain_masks`) i używane przez planer
  kafli tylko przy tym samym seedzie — `procedural_level` planuje kafle z `result.seed_used`. Inny seed
  kafli = inne maski niż te, które widziały obiekty.
- **`plateau_smooth` = 2** wycina płaskowyże w wąskich korytarzach — zostaje 1.

## Testy
- Testy (`modules/quiz_rpg/tests/`, w tym `run_plateau_suite.sh`, `diag_objects.gd` i
  `parity_baseline.txt`) są w `.gitignore` — żyją tylko lokalnie. Utrata katalogu = utrata zestawu
  i baseline'u parytetu.
- Baseline parytetu zależy od katalogu obiektów: przeszkody zsuwają spawny wrogów/skrzyń, więc każda
  zmiana `objects_caves.json` z kolizją zmienia pole `spawns` w digestach (ściany/podłoga bez zmian).
- `diag_enemy_chase.gd`, część „poziom ręczny (tutorial_area)” jest losowa (wałęsanie bez seeda):
  „klatki przy ścianie” wahają się od ~30 do ~1300 / 3000 i sprawdzenia czasem nie przechodzą — także
  przed zmianami. Pojedynczy FAIL tam to jeszcze nie regresja; powtórzyć kilka razy.

## Potencjalne problemy (do obserwacji)
- **Tekst UI walki 36 px poza siatką Jersey 15** (2026-10-03, decyzja usera): czcionka pikselowa jest ostra
  w wielokrotnościach 27 px (27 / 54 / 81); przy 36 px (4/3) piksel litery wypada na 1,33 px ekranu, więc
  kreski mogą mieć raz 1, raz 2 px. User w testach nie widział różnicy. Jeśli wyjdą nierówne litery: zmienić
  `QuizTheme.COMBAT_FONT_SIZE` na 27 albo 54 (ekran walki ma własną kopię motywu — `combat_theme()`).

## Rozwiązane (dla kontekstu)
- Edytor pytań (2026-10-02, 278f906, 3866fb5, 3d2108c): menu główne hosta -> „Pytania” (zestawy:
  nowy / import JSON z raportem pominiętych / eksport / nazwa / usuń lub przywróć oryginał; pytania 5 typów:
  dodaj / edytuj / duplikuj / usuń / włącz-wyłącz), Opcje -> „Pytania” (zestawy używane w grze). Dane:
  `scripts/core/question_bank.gd` (user://quizzes, user://quiz_selection.json — wybór globalny). Gra losuje
  z przypisanego zestawu, gdy aktywny, inaczej ze wszystkich aktywnych (domyślnie inf_podst = jak dawniej).
- UI walki WYSIWYG (2026-09-30, 157473c, d914538, 7e61f2f): wygląd w quiz_combat_ui.tscn + motyw
  resources/ui/quiz_theme.tres; pola walki per tło w `<grafika>_layout.tres` (BattleBackgroundLayout:
  lista pól BattleField — trapezy z rzędami, pojemnością i skalą głębi, 622a098) — edycja graficzna w
  scenes/tools/battle_layout_preview.tscn (narożniki „eksplodujące” do NaN — 9b00207; lista grafik
  i liczba wrogów na pole w podglądzie — 169e294; szczegóły: docs/kontekst/walka.md). Dawne „wrogowie za nisko” (kontroler nadpisywał scenę
  wartościami z kodu tła) i „marginesy pola walki per tło jako .tres” — rozwiązane tym samym.
- Freeze po pokonaniu potwora (2026-09-30, aa8d686): na mapie gracz stał, aż wróg zniknie (stan EXPLORING
  dopiero po animacji). Teraz rusza od razu i ma 5 s nietykalności na kolejne walki (miga). Czekanie na
  ekranie walki (komunikaty zwycięstwa, pomijalne Enterem) zostaje — decyzja usera. XP było dodawane dwa
  razy (ekran walki + mapa) — zostało tylko na ekranie walki (1673bde).
- Spłaszczanie wybrzuszeń (`ShortBulgeFlattenPass`, flaga `enable_bulge_flatten`) usunięte 2026-09-29
  (decyzja usera po porównaniu par z przebiegiem / bez): kształty ścian zostają naturalne, a kafle
  poprawiają wymuszone 2H małych filarów i `ShortLedgeRaisePass`.
- Wąskie wypustki 2H przy licu 3H+ (seed 118945 160×160 bez spłaszczania, nad (76, 97)) — kawałek lica
  o grubości 2 i szerokości 1–2 obok kolumny 3H+ na tej samej stopie. `ShortLedgeRaisePass` (flaga
  `enable_ledge_fix`) podnosi go do 3H (kratka nad nim -> ściana, gdy zostają nad nią 2 kratki podłogi),
  inaczej usuwa; małe wolnostojące wyspy (<= 25 kratek) pomija.
- Małe przekrzywione filary (seed 118945 160×160, (118–121, 89–92); bez `ShortBulgeFlattenPass` więcej
  takich, np. (127, 107) 2/4/5/3/2) — mieszanka 2H / łącznik / 3H. Mała wolnostojąca wyspa ściany
  (pole <= 25, <= 6 kolumn, kolumny <= 5 — flagi `small_pillar_2h_*`) z górami i dołami kolumn w różnych
  rzędach dostaje zawsze lico 2H, bez łączników (`EdgeAnalyzer.small_wall_islands` / `_skewed`,
  `GenerationContext.force_2h_cells`). Filary o równej górze (np. 2/3/3/3/2), szersze pasy skały i wysokie
  bryły zostają przy 3H. Siatka bez zmian (tylko kafle).
- Fasada płaskowyżu tuż za ścianą jaskini (seed 119 250×250, (48–51, 74–75)) — lico płaskowyżu, którego
  górna kratka wypada na górze modułu ściany głównej (rim / najwyższa część lica, nie narożnik out), jest
  wchłaniane (`PlateauRenderer._on_wall_top`); sąsiednia kolumna dostaje zakończenie lica.
- Zasięg wykrywania wroga niewidoczny / zły przy „Visible Collision Shapes” — kształt `DetectionArea`
  był współdzielony przez wszystkie instancje `enemy.tscn` (promień ustawiał ostatni wróg). Teraz
  `resource_local_to_scene` + setter `detection_radius` (zmiana w trakcie gry od razu zmienia okrąg).
  Test `diag_detection_radius.gd`. Podglądu w edytorze nie ma (osobny węzeł `@tool`, jeśli potrzebny).
- Nawigacja wrogów bez ścian i przeszkód — siatka nawigacji z generatora (`NavOutlines`, commit b4bb991,
  dokładne kształty przeszkód 0785ade); wrogowie gonią i wałęsają się po niej (0785ade).
- Wróg widział przez ściany — promień jak w Amon-Ra (ściany + przeszkody) + linia po siatce mapy
  (e4192f9). Szczegóły: `docs/analiza_ai_przeciwnikow.md`.
- Pojedyncze kratki / plamy 1×2 / zakręty 1-szerokie błota i trawy (zestaw 13 kafli bez pokrycia) —
  kształtowanie masek pod wierzchołki kafli (commit c4c253f), test `diag_terrain_masks.gd`.
- Twarde cięcia krawędzi błota/trawy = Godot bug #70218 (`set_cells_terrain_connect`) — obejście własnym
  `TerrainAutotileSolver` (commit 2524d2b); zostają pojedyncze niedopasowania narożników (subtelne).
- Losowy seed (≤ 0) dawał kaflom i terenowi inny seed niż topologii — teraz wspólny `result.seed_used`.
- Narzędzie katalogu w edytorze: niezainicjalizowane statyczne mutexy (commit 4cc579f).
