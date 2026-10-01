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

## Podgląd / edytor pól: `scenes/tools/battle_layout_preview.tscn`
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
