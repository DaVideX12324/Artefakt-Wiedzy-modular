# Znane problemy i rzeczy odłożone (quiz_rpg — generator jaskiń)

> Spisane 2026-09-25. Każdy punkt: co jest nie tak, dlaczego zostało jak jest, kiedy do tego wrócić.
> Po naprawie punkt usuwamy albo przenosimy do „Rozwiązane” z numerem commita.

## Odłożone świadomie

(brak)

## Do zrobienia (zgłoszone, następnym razem)

### ⚠ WAŻNE: (1) tilesety kolejnych map — najpierw ścieki
- Zgłoszenie 2026-10-03, priorytet z 2026-10-04: **pierwsze z trzech ważnych todo, przede wszystkim ścieki
  (sewer)**. Kolejność map w grze: jaskinia -> miasto -> ścieki; w ściekach przejście raczej drabiną, pod E
  (`next/previous_portal_use_key` + `_prompt` w scenie dziedziczonej po `procedural_level`).
- **Do zrobienia przez autora:** tilesety (TileSet `.tres` + companion-JSON zachowania
  w `resources/maps/config/`, jak `caves.tres` / `caves.json`) dla kolejnych map z generatora.
- Są: jaskinie (`resources/maps/caves.tres`), ścieki (`resources/maps/sewer.tres`, `config/sewer.json` — na razie
  z profilem kafli jaskiń). Kolejne wg kolejności stref (`docs/game_design.md`): Cemetery, Fairy Forest
  (las — por. wpis „Mapy otwarte z uniwersalnego generatora”), Desert / Desert Temple, Volcano / Forge,
  Dense Forest / biom zimowy, Library, Garden, Castle.
- **Stan 2026-10-04:** ścieki w toku na gałęzi `sewer-tileset` (CienMgly) — tileset, profil, układ, ściany 3H/4H,
  podłoga z terenu, kanały z kładkami; szczegóły i lista flag: [kontekst/scieki.md](kontekst/scieki.md).
- Przypomnienie na start sesji (hook) znika, gdy ten nagłówek zniknie albo straci znacznik „⚠ WAŻNE”.

### ⚠ WAŻNE: (1a) przebudowa generowania ścieków — osobna sesja na dużo wyższym effort
- Zgłoszenie 2026-10-05. Autor chce przerobić generowanie ścieków w osobnej sesji z **dużo wyższym effort**
  (max lub podobnym), z **MCP Godota** (autor go dodaje — podgląd sceny / gry zamiast samych renderów headless).
- Obecny wynik (eksplorator, seed 119, 160×160) jest pusty w porównaniu z makietami autora paczki
  (`sewer/Social/MockUp-01`, `MockUp-02`; warstwy podejrzysz w Eksploratorze Aseprite). Różnice zauważone
  przy porównaniu:
  - lico: makiety dzielą długie ściany **filarami** (Tiles 7, 3–6) z łańcuchem / lampą na filarze, łuki
    odpływów między filarami, pionowe rury z lica na posadzkę (Tiles 6–8 × 8–9), rura przy ścianie bocznej;
  - kanały: **barierki** wzdłuż brzegu (Props 6–9 × 4, przerwa i zagięte końce przy kładce), zakręty L i T,
    kanał wzdłuż ściany (brzeg tylko z jednej strony), szersza sieć; puste koryto już jest (`canal_dry_chance`);
  - posadzka: ciemniejsze plamy (teren `dark_floor`), **mech** (teren `foliage`) w kątach i przy ścianach,
    rzędy otworów 2 × N, gruz w małych skupiskach;
  - rekwizyty w kompozycjach: stół + krzesła + regał / schody (Props 0–1 × 6–8) przy ścianie, stosy skrzynek
    2 × 2, grupy beczek, skrzynia ścieków (Props 8–9 × 2–3) i otwarta (8–9 × 0–1); dzbany / worki z makiety
    nie występują w atlasach paczki;
  - skala: makieta 25 × 25 kratek mieści kilka pokoi i kanały, u nas sale 16–28 kratek są puste.
- Stan wyjściowy i flagi: [kontekst/scieki.md](kontekst/scieki.md), obiekty: [kontekst/obiekty.md](kontekst/obiekty.md).
- **Aktualizacja 2026-10-06:** wdrożono technicznie korytarze serwisowe z bramami (`proto_layout10.py`), separację ścianą, A* Manhattan i blokadę kładek na zakrętach (commit `cbe4b35`). Dopracowanie układu przestrzennego i mentalnego korytarzy wzdłuż koryt odłożone do kolejnej sesji z Claude Opus.


### ⚠ WAŻNE: (2) dokończyć generator obiektów
- Zgłoszenie 2026-10-04 (drugie z trzech ważnych todo). Generator obiektów: dalsze fazy F2–F5 wg
  `docs/plan_generator_obiektow.md` (stan: [kontekst/obiekty.md](kontekst/obiekty.md)). Zostało: F5 (niszczalne
  beczki, dźwignie, leniwe sceny), nakładka podglądu (zajętość / przejścia, statystyki).
- Kamyki bez kolizji — zrobione 2026-10-05 (`pebble_large` w `sprites/`, CienMgly 4480fff).

### ⚠ WAŻNE: (3) tła walki — user robi resztę grafik, gra rysuje je na cały ekran 16:9
- Zgłoszenie 2026-10-05 (przed teammate'ami). User generuje pozostałe tła walki w kadrze 16:9 na cały ekran
  (prompty: `battle_backgrounds/*_prompts.md`, `correction_prompts.md`). Nowe już są: `cave/` i
  `tutorial_area/` `Gemini_Generated_Image_*.jpg` (2752×1536).
- **Dlaczego w edytorze 16:9, a w grze nie:** `folder_battle_background.gd` rysuje tło „cover” tylko
  w obszarze walki nad dolnym paskiem UI (1920×830, proporcje ~2,31:1). Grafika 16:9 jest skalowana do
  szerokości, a góra i dół ucinane (~12 % z każdej strony przy 1376×768); pod paskiem UI tła nie ma.
- Do zrobienia po stronie kodu: rysować tło na cały ekran (1920×1080, pod paskiem UI), przestawić pola
  walki w `<grafika>_layout.tres` (współrzędne się przesuną). Stare grafiki skomponowane pod obcięty kadr —
  albo podmienić je wszystkie, albo flaga w układzie (np. `full_screen`), żeby przejście szło stopniowo.
  Opis stanu: [kontekst/walka.md](kontekst/walka.md) „Tła walki: kadr 16:9”.

### ⚠ WAŻNE: (4) grywalne postacie — teammate'owie
- Zgłoszenie 2026-10-04 (przesunięte za tła walki 2026-10-05). Dziś jest tylko Bohater. Zaczątki: `player.gd` ma tryb
  członka drużyny (`is_party_follower`, podążanie po śladzie lidera, bieg razem z liderem — `is_running()`),
  menu Esc ma wiersze drużyny, komunikaty walki piszą „Bohater i drużyna”.

### ⚠ WAŻNE: (5) miasto z modularnych zasobów paczki free
- Zgłoszenie 2026-10-05 (ostatnie z ważnych todo). Mapa miasta (kolejność map: jaskinia → miasto → ścieki,
  [game_design.md](game_design.md)) zbudowana ze skomplikowanych, modularnych zasobów
  `assets/pixel_crawler/packs/free_pack_2.11/Pixel Crawler - Free Pack/Environment/`:
  - budynki składane z modułów: `Structures/Buildings/` — `Walls`, `Roofs`, `Props`, `Shadows`,
    wnętrza (`Interior/Interior_Walls_01`, `Interior_Props_01`);
  - stacje rzemieślnicze (`Structures/Stations/`: kowadło, piec, ognisko, kuchnia, tartak, alchemia, warsztat —
    część animowana `-Sheet.png`);
  - tilesety `Tilesets/` (`Floors_Tiles`, `Wall_Tiles`, `Wall_Variations`, `Water_tiles`, `Dungeon_Tiles`),
    rekwizyty `Props/Static` (meble, farma, drzewa w rozmiarach, roślinność), animowane `Props/Animated`.
- Przed startem rozłożyć `.aseprite` budynków na warstwy (parser jak przy ściekach) — zasady składania modułów
  (ściana + dach + cień, warianty) wyczytać z warstw, nie zgadywać z PNG. Obiekty przez generator obiektów
  ([kontekst/obiekty.md](kontekst/obiekty.md)), podgląd przez MCP `godot-runtime`.

### Feature: ukryte przejścia między pokojami (tunel pod voidem)
- Zgłoszenie 2026-10-03. Ukryte przejście może łączyć dwa pokoje — gracz wchodzi w nie (np. nisza-przejście,
  sekretna nisza) i wychodzi w innym pokoju, jakby szedł tunelem pod voidem / litą skałą.
- Do ustalenia: jak to pokazać (przejście przez ekran ładowania / ściemnienie i teleport, czy prawdziwy
  korytarz na warstwie pod spodem), dobór par pokoi (odległość, osiągalność — skrót nie może omijać
  zamkniętych drzwi / quizów), wejścia z obu stron, nawigacja wrogów (bez przejść), zapis w seedzie.
  Powiązane: nisze-przejścia (`NichePlacer`, `ctx.passage_cells`), zawartość nisz out i sekretne pokoje.
- Pomysł usera (2026-10-03) na pokazanie tunelu: shader z Amon-Ra robiący kafle częściowo przezroczystymi —
  `assets/shaders/desert_town/desert_town.gdshader` (już skopiowany do hosta; w Amon-Ra materiał
  `desert_town.tres`): koło wokół `player_position` o promieniu `circle_radius`, alfa od `min_alpha` (przy
  graczu) do `max_alpha`, `smoothness`. Gracz idzie po prawdziwym korytarzu pod voidem / skałą, a kafle nad
  nim (warstwa z materiałem, `player_position` ustawiany co klatkę) prześwitują wokół niego.
- Wtedy **pod terenem voidu muszą się też generować ściany tunelu** (kolizje wzdłuż korytarza) — inaczej
  pod voidem dałoby się chodzić po całej mapie. Czyli: korytarz tunelu wycięty w osobnej masce (nie w siatce
  pokoi), własne kolizje ścian tunelu, warstwa voidu / skały nad tunelem z shaderem, wejścia przez
  nisze-przejścia na obu końcach.

### Nisze-przejścia: wariant kafli RIM i częstość
- Generator i kafle OUT gotowe (patrz „Rozwiązane”, 2026-10-03). Zostało: **wariant kafli szczytu ściany (RIM)
  z innymi kolizjami jako alternatywa 1** w `caves.tres` — robi user; executor użyje go sam nad płytszą kolumną.
- Przejść jest mało (seed 103107 160×160 ma 2, pięć innych map 0) — user chce, żeby pojawiały się częściej.
  Sposób do ustalenia (np. celowe wycięcie ściany do głębokości 3 za kandydatem niszy).

### Tryb walki: interfejs, pozycje wrogów, marginesy per tło, losowe spotkania
- Zgłoszenie 2026-09-29. Scena `scenes/quiz/quiz_combat_ui.tscn`, logika `scripts/quiz/quiz_combat_controller.gd`,
  tła `scripts/quiz/battle_background.gd` + `background_generators/*`.
- **Interfejs walki** — zrobiony w stylu RPG Makera (2026-09-30), WYSIWYG; zostały okna Umiejętności /
  Przedmioty w starym wyglądzie i niesprawdzone w grze typy pytań bossów (wpisywanie, kafelki, dopasowanie).
  Tło okien = asset UI od usera -> resources/ui/quiz_theme.tres (QuizWindow).
- **Losowe spotkania jak w JRPG**: wrogowie niewidoczni na mapie, walka zaczyna się nagle podczas chodzenia.
  Tryb obok obecnego (wrogowie widoczni) — np. włącza się po pokonaniu wszystkich wrogów na mapie; zasada
  do ustalenia (per mapa / per biom, szansa na krok, strefy bez spotkań: portale, schody, sekretne pokoje).

### Feedback z zamkniętych testów pre-alpha (tester zewnętrzny)
- Zgłoszenie 2026-10-04 (kolega, klon repo). Żadnego z punktów nie było wcześniej na liście; pkt 4 częściowo
  pokrywa się z „Tryb walki” (okna Umiejętności / Przedmioty jeszcze w starym wyglądzie).
1. **Narzędzia deweloperskie za łatwo dostępne.** `autoloads/services/cheat_service.gd` łapie pojedyncze litery
   zawsze, gdy nie trwa wpisywanie tekstu: K = natychmiastowe zwycięstwo (też w `quiz_combat_controller.gd`
   i `quiz_puzzle_controller.gd`), O = wrogowie wł./wył., P = quizy wł./wył.; menu deweloperskie pod F1 / `~`.
   Nie ma warunku `OS.is_debug_build()` — działa też w eksporcie. Do ustalenia: tylko klawisze F albo skrót
   z modyfikatorem, przełącznik „tryb deweloperski” w opcjach, wyłączenie w buildzie wydaniowym.
2. ~~**Układ ekranu pytania w walce:** pytanie na samej górze, odpowiedzi na dole — wzrok skacze po ekranie.~~
   Zrobione (2026-10-04, CienMgly 13fa303, f79c808 + host 793109f): układ u góry to decyzja autora (styl RPG
   Makera), więc doszła opcja Opcje -> Motyw -> „Pytanie w walce”: „W oknie logu (u góry)” (domyślnie) /
   „W menu walki (nad odpowiedziami)” — pytanie i pasek czasu w panelu quizu pod tytułem, jak przed oknem logu
   (`_apply_question_position`). Menu opcji hosta obsługuje teraz opcje modułu typu `choice`.
3. **Kliknięcie wroga na polu walki nie atakuje**, choć cel się zmienia (podświetlenie działa). Obsługa kliknięcia:
   `_handle_hovered_enemy_click` (tylko w fazie `TARGET_SELECT`: ustawia cel i woła `_confirm_target_selection`).
   Do sprawdzenia: czy klik w ogóle tam dociera (może go przechwytywać GUI albo inna faza).
4. **Mysz nie działa w części menu walki** — „Przedmioty” i „Umiejętności” obsługują tylko klawiaturę, pewnie też
   inne listy (`_list_menu_mode`). Te dwa okna i tak czekają na przeróbkę w stylu RPG Makera (wpis „Tryb walki”) —
   załatwić przy niej; wymaganie dla nowych okien: obsługa i myszą, i klawiaturą.
5. **Brak znacznika celu na starcie wyboru przeciwnika** — pojawia się dopiero po pierwszej zmianie celu.
   Do sprawdzenia: odświeżenie znacznika (`_refresh_target_selection`) przy otwarciu panelu celu.
6. **Kliknięcie w okno, żeby wróciło skupienie (np. z Discorda), wykonało atak.** Klik przywracający fokus idzie
   do gry jak zwykłe wejście (przycisk akcji albo wróg pod kursorem). Pomysł: ignorować kliknięcia przez chwilę
   po `NOTIFICATION_APPLICATION_FOCUS_IN` (albo gdy okno nie miało fokusu w chwili kliknięcia).

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
  - Pliki `.import` są już w repo (zrobione przez usera, 2026-10) — UID-y assetów są wspólne dla klonów.
  - Pierwsza kopia z `.gdignore`: `modules/BitBomber/resources/fonts/` (kopia fontów hosta, te same UID-y —
    896ae62 / ea23bf9). Zostało: `modules/BitBomber/resources/icon.png` ma ten sam UID co `resources/icon.png`
    hosta (ostrzeżenie „UID duplicate” przy imporcie) — leży obok `quizzes/`, więc nie da się ukryć całego
    folderu.

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
- **Kładki na osobnej warstwie i ciągłość opuszczonej krawędzi (ścieki)** (2026-10-05, CienMgly): kładki
  (`BRIDGE_V`, `BRIDGE_H`) wydzielone na dedykowaną warstwę TileMapLayer `Bridges` (`z_index = -1`, y-sort);
  kładka pozioma `BRIDGE_H` rozszerzona w atlasie `Props.png` do 6×2 (kolumny 5–10, `origin = Vector2i(5, 12)`,
  `size = Vector2i(6, 2)`); w `canal_placer.gd` funkcja `_is_face` uniezależniona od przechodniości północnego
  sąsiada (`not water.has(n)`), co gwarantuje 100% ciągłości lica uskoku `CANAL_FACE` (4, 13) wzdłuż całego biegu
  koryta (w tym na seedzie 324091 przy kafelku (74, 241)) bez wcięć kwasu w mur.
- **Mapy jako sceny dziedziczone + seed per zapis + powrót do poprzedniego poziomu** (2026-10-03, CienMgly):
  `procedural_level.tscn` to baza, mapy w `scenes/maps/levels/` (na razie `cave.tscn`; w przyszłości po jaskini
  miasto, potem ścieki). Jeden seed na zapis (`LevelStateManager.world_seed`), seed mapy = hash(seed zapisu,
  nazwa sceny); reroll = nowy seed zapisu i czyste mapy. Wejście mapy (`enter_previous_level`) prowadzi na
  poprzedni poziom do markera `FromNext` przy jego wyjściu (`scripts/maps/level_portal.gd`).
- **Punkty pojawienia się odsunięte od przejść** (2026-10-04, CienMgly 99b3cd4): gracz nie pojawia się w Area2D
  przejścia, tylko przy markerze >= 3 kratki od niego — na mapach generowanych `Spawn` / `FromNext` z
  `MapGeneratorBase.arrival_cell` (podłoga, ta sama wysokość, bez barier i obiektów), w samouczku
  `Spawns/Tutorial-Caves` (marker usera; `cave.tscn` `previous_spawn_name`). Przejście działa od razu po wejściu;
  obszar, w którym gracz stoi po wczytaniu, dopiero po wyjściu. Testy: `diag_level_back`, `diag_arrival_cells`.
- **Przejścia pod E** (2026-10-04): tryb per przejście — w scenie ręcznej metadane Area2D `portal_use_key` (bool)
  i `portal_prompt` (tekst, domyślnie „Przejdź”), na mapach dziedziczonych eksporty `procedural_level`
  `next/previous_portal_use_key` i `next/previous_portal_prompt` (np. drabina w ściekach). Podpowiedź „[E] …”
  nad środkiem kształtu obszaru (`portal_key_listener.gd`). Test: `diag_portal_key`.
- **Zmiana klawiszy (rebind) per moduł** (2026-10-03): zakładka „Sterowanie” w opcjach — 2 pola na akcję,
  przejmowanie klawisza w konflikcie, „Przywróć domyślne”; `InputBinds` + `SettingsService.set_module(…, "binds")`,
  nazwy akcji z `action_labels` w manifestach. Opis: `docs/kontekst/menu_i_opcje.md`.
- **Wymuszone 2H tam, gdzie powinno być 3H** (2026-10-03, seed 103107 160×160, (82–83, 113–114) i (89–90,
  113–114)): to była reguła skosu 2H (`WALL_2H_SLOPE`) — dostawał go każdy schodek o 1 przy grubości 3–5,
  także pojedyncze schodki na poziomej fasadzie. Teraz (`EdgeAnalyzer.slope_2h_run`, CienMgly b9b0cae) skos
  dostaje cały ukośny ciąg kolumn schodzących po 1 rząd, jeśli któraś ma 3 kratki nad stopą INNER_CORNER w
  kierunku skosu (NORTH_WEST schodzący w lewo, NORTH_EAST w prawo). Do tego `SlopeThicknessPass` (P11a):
  ukośna ściana o grubości 3 -> 4 (ciąg >= 3 stóp, bez „zębów”), bo klin seeda 119 160×160 (71–72) nie
  pasował do okna 100/000/001. Potem (CienMgly, „reguła narożnika zastępuje regułę grubości”) usunięty
  warunek grubości 3–5 i „schodka o 1” — skos wyłącznie z narożnika (seed 118945 160×160, (16,53) grubości 6).
  Flagi do porównań: `slope_2h_corner_rule`, `enable_slope_thickness` (caves.json; obie false = stan sprzed zmian).
  Kafli skosu na 10 mapach testowych 56 -> 17; decyzje usera.
- **Cień Mgły (quiz_rpg) samodzielny i jako submoduł** (2026-10-03): ścieżki niezależne od korzenia
  (`scripts/quiz_rpg_paths.gd`, UID w każdym `ext_resource`), kopie hosta w `_host/` z `.gdignore`
  (`tools/sync_host_copies.gd`, opis w `docs/module_contract.md`), `tools/make_standalone.sh`; potem
  `git subtree split` (353 commity) -> repo https://github.com/DaVideX12324/CienMgly, podpięte jako submoduł
  `modules/quiz_rpg` (d32a856). W submodule własne `.gitignore` (`/.godot/`, `/tests/`, `/project.godot`) i
  `.gitattributes` (LF) — reguły hosta go nie obejmują. Diagnostyki `tests/` dalej tylko lokalnie.
  Praca: commit + push w submodule, potem wskaźnik w hoście; po zmianach zasobów hosta — ponowny sync.
- Flagi generatora `room_shape` i `entrance_mode` (2026-10-04): kształt pokoi `organic` (domyślnie, jak dotąd) /
  `rect` / `round` / `mixed` (losowo per pokój) — `RoomCarverFactory` + `RectRoomCarver`, `RoundRoomCarver`,
  `MixedRoomCarver`; wejście `edge` (domyślnie, wnęka przy krawędzi) / `center` — `PortalGenerator.carve_portal_in_room`:
  strefa 5×5 w pokoju najbliżej środka mapy (pokoje o boku ≥ 10, gdy są), bez wnęki; wyjście przy krawędzi w
  pokoju najdalszym od wejścia. Obie flagi w JSON-ie biomu (`flags`), domyślne = wynik bez zmian (MD5 topologii
  3 seedów identyczne). Ścieki (`sewer.json`) używają `entrance_mode: center`
  (decyzja autora, 2026-10-03).
- Etap `entities` i ostrzeżenie „re-save this scene” przy `slime_tutorial` (sprawdzone 2026-10-04): scena
  zapisana ponownie w edytorze (028bafc, c205e80); Godot 4.7.2 tworzy ją bez ostrzeżeń, ~0,2 ms na instancję.
- Kolizje wrogów w `tutorial_area.tscn` (sprawdzone 2026-10-04): nadpisania `collision_mask = 5` usunięte
  w c205e80 — instancje biorą 39 z `enemy.tscn`.
- Nisze przy ścianie o głębokości 3 (2026-10-03, 8649546, 4788812, 56b329f): rząd -3 to tam szczyt ściany,
  a korona niszy wycinała w nim ciemny ząbek (seed 103107 160×160, (85, 113)). Teraz to nisza OUT bez korony,
  nigdy sekretna, będąca przejściem (szansa `passage_niche_spawn_chance`); kafle przejścia dostają alternatywę 1.
- Ostrzeżenia „invalid UID” (2026-10-03, e37c940): 293 odwołania w 37 plikach (wrogowie, kafelki pustyni,
  obiekty, gracz) poprawione na UID-y z `.import`.
- Sterowanie per moduł (2026-10-02, ba3d490): Opcje -> „Sterowanie” — sekcje z pola `controls` w
  `module_manifest.json`; z menu głównego wszystkie moduły, z modułu tylko jego (BitBomber: 7c87f4f).
- Opcje w menu Quiz RPG (2026-10-02, 888d682): przycisk „Opcje” otwiera okno opcji hosta (jak z menu Esc).
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
