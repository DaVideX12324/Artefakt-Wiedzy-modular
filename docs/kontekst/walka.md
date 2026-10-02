# Walka: UI, pola walki, podgląd (stan na 2026-09-30)

## UI walki (styl RPG Makera, WYSIWYG)
- Scena `scenes/quiz/quiz_combat_ui.tscn`, kontroler `scripts/quiz/quiz_combat_controller.gd` tylko
  przełącza fazy i tryby dolnego pasa (`Band`: PARTY_COMMAND / ACTOR_COMMAND / STATUS_ONLY; szerokości
  i liczba linii logu jako eksporty). Wysokość dolnego pasa = `BattleWindow.offset_top` w scenie.
- Pytanie i log bitwy u góry (`TopWindow`), komunikaty po bitwie w dolnym pasie (`VictoryLog`),
  tura / seria w rogu (`CornerInfo`) — wzór: zrzuty w `fnafb/`.
- Motyw `resources/ui/quiz_theme.tres` (typy QuizWindow / QuizLog / QuizMenuItem, styl „selected”),
  czcionka Jersey 15 (`resources/ui/jersey15_pixel.res`) w całym quiz_rpg przez `QuizTheme.apply()` —
  rozmiary na siatce 27 px (`QuizTheme.snap`). Oba pliki generuje `tests/build_quiz_theme.gd`.
- Przebieg tury: Walcz / Uciekaj (lewo) → **wybór postaci** — kursor (styl „selected” pod wierszem)
  na liście drużyny w prawym oknie, mysz / strzałki, martwe pomijane → komendy tej postaci
  (`_active_actor_index`: koszty SP/TP, przedmioty) → cel. Esc cofa o krok (komendy → wybór postaci →
  Walcz). Kursory menu prowadzi kontroler — przyciski komend mają `FOCUS_NONE` (fokus Godota zjadał
  strzałki / Enter).
- Quiz (`scripts/shared/quiz/quiz_panel_controller.gd`): nawigacja odpowiedzi wg `MC_Box.columns`
  (w scenie 1 kolumna; wcześniej zakładała 2×2 i strzałka w dół skakała o 2).
- **Asset UI od usera** (tło okien) -> jedno miejsce: `quiz_theme.tres`, typ QuizWindow.
- XP dodawane tylko na ekranie walki; po wygranej gracz rusza od razu, 5 s nietykalności
  (`player.grant_encounter_immunity`, miganie). Komunikaty zwycięstwa czekają (Enter pomija) — decyzja usera.

## Wybór tła walki
- `battle_background.gd`: klucz mapy jak folder ekranu ładowania — `get_map_key()` mapy (ProceduralLevel:
  `loading_screen_key` albo biom z typu poziomu: cave / castle / forest), `biome`/`theme`…, nazwa pliku
  sceny mapy ręcznej (`tutorial_area`), na końcu słowa w ścieżce skryptu / nazwie węzła.
- Grafiki z folderu mapy (`folder_battle_background.gd`): `battle_backgrounds/<klucz>/` albo
  `battle_backgrounds/pixel_crawler/<klucz>/`, losowy wariant; `KEY_ALIASES` (forest -> fairy_forest).
  Brak folderu z grafikami = tło w kodzie (`world_map`, `default`). Lista przez
  `ResourceLoader.list_directory` (działa w eksporcie). Wcześniej jaskinie generowane dostawały `default`.

## Pola walki per tło
- Plik `<grafika>_layout.tres` obok grafiki tła (`BattleBackgroundLayout`: `texture`, `fields`);
  generatory teł dają `get_layout_key()`, tło -> `get_layout()` + sygnał `layout_changed`.
- `BattleField`: `quad` (4 narożniki, sortowane: przód-lewy, przód-prawy, tył-prawy, tył-lewy;
  NaN odrzucany), `rows` 1–3, `row_capacity`, `front_scale`, `auto_depth_scale` / `back_scale`.
  Współrzędne w px obszaru bitwy przy 1920 px (`REF_AREA` = 1920×830 nad paskiem 250 px).
- Rozstawienie: `assign()` losuje rzędy z wolnym miejscem (preferencje „front” / „back” z danych wroga);
  w rzędzie z n wrogami stopy k-tego w (k + 0,5) / n linii rzędu — skrajni nigdy na samym boku pola.
  Skala = `enemy_scale(liczba wrogów)` × skala rzędu.
- 13 plików układu; trapezy z ręczną skalą tyłu 0.82 (wygląd jak przed trapezami). Plik
  `tutorial_area/variant_2_training_layout.tres` edytuje user (nie commitować bez prośby).

## Podgląd / edytor pól: `scenes/tools/battle_layout_preview.tscn` (instrukcja: docs/battle_layout_preview.md)
- Każde pole = `Polygon2D` „FieldN” — przeciąganie narożników, Ctrl+D nowe pole, Delete usuwa;
  zapis pliku 0,6 s po ostatniej zmianie.
- 9b00207: blokada `_syncing` ustawiana PRZED zapisem do pól — wcześniej sygnał `changed` nadpisywał
  wielokąt w trakcie przeciągania i narożniki „eksplodowały” do NaN (user potwierdził, że działa).
- 169e294: `enemy_sprites` (lista grafik rozdawanych po kolei, klatka postoju jak w EnemyBattleDisplay;
  zastąpiło pojedyncze `enemy_frames`), `field_counts` (ilu wrogów na polu, po rzędach od przedniego;
  brak wpisu / -1 = `preview_per_row` w każdym rzędzie, 0 = puste), rysowanie od najdalszych.
  W grze rzędy są losowe — podgląd pokazuje przykładowy podział, ale miejsca i skala jak w grze.
- Niesprawdzone w edytorze przez usera: Ctrl+D / Delete, `field_counts`; w grze — klikanie wrogów
  przy wyborze celu po przeniesieniu slotów na `EnemyFieldLayer`.
- Ostrzeżenia „invalid UID” przy ładowaniu prawie wszystkich `resources/enemies/*.tres` (orki, dzik,
  bandyci…) — stare, grafiki się ładują; osobna sprawa do uporządkowania.

## Motywy UI (1c368e2)
- Opcje hosta -> zakładka „Motyw”: lista z `get_ui_skins()` aktywnego modułu (module_root -> `QuizTheme.SKINS`),
  suwak jasności 50–150 %. Zapis: `SettingsService.set_module("quiz_rpg", "ui_skin" / "ui_brightness")`,
  zmiana na żywo przez sygnał `module_setting_changed`.
- `QuizTheme.apply_skin(id, jasność)`: `resources/ui/skins/<id>.tres` nadpisuje style typów QuizWindow /
  QuizLog / QuizMenuItem / QuizBar* w motywie modułu (w pamięci; „klasyczny” = sam quiz_theme.tres).
  Jasność mnoży kolor okien i zaznaczenia (paski bez zmian).
- Paski walki mają warianty motywu QuizBarLP / SP / TP / Timer / Enemy (dawniej nadpisania w scenie).
- Motywy st_* (granatowy / jasny × zaokrąglony / kwadratowy × płaski / z głębią) buduje
  `tests/build_ui_skins.gd` z wycinków w `resources/ui/skins/st/` (źródło: assets/UI/UI Assets pack_v.1_st,
  paski: Pixel UI pack 3). Nowy motyw: plik `.tres` + wpis w `QuizTheme.SKINS`.
- Uwaga: `tests/build_quiz_theme.gd` (stary generator quiz_theme.tres) nie zna typów QuizBar* — po jego
  użyciu trzeba ponownie puścić build_ui_skins.gd (bez SKIP_BARS nie zadziała, bo scena nie ma już nadpisań —
  wtedy style pasków brać z historii gita).
- Licencje paczek `_st` i Pixel UI pack 3 — do sprawdzenia (napisy końcowe).

## Style pasków (5e0c9bb)
- Opcje -> Motyw -> „Styl paskow” (klucz ui_bar_style, `QuizTheme.BAR_STYLES`), niezależnie od motywu okien;
  warstwy: styl pasków > motyw okien > quiz_theme.tres. Motywy st_* nie mają już własnych pasków.
- `QuizBar` (scripts/ui/quiz_bar.gd, ProgressBar ze skryptem na 23 paskach walki): ikony motywu
  `bar_under` / `bar_progress` -> shader (środek rozciągany albo powtarzany przy `bar_tile`, końcówki stałe,
  płynne przycinanie wiersz po wierszu); bez ikon — zwykłe style (klasyczne gradienty).
- Tekstury: resources/ui/skins/bars/<styl>_<kolor>_full|empty.png z assets/UI/Pixel UI pack 3/Full.png
  (+ 05.png); style budowane przez tests/build_ui_skins.gd (BAR_STYLES = kolory, BAR_TILED = modułowe).
- Licencja Pixel UI pack 3 (bdragon1727): niekomercyjnie za darmo, komercyjnie — wpłata dowolnej kwoty.
