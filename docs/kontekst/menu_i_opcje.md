# Menu, opcje, menu Esc, audio (stan na 2026-10-04)

## Okno (`autoloads/services/window_service.gd`, autoload `WindowService`; 2026-10-04)
- Jeden autoload (zdublowany `WindowManager` usunięty, 9ce79cc). Start: okno na **zapisanym** monitorze;
  monitor pod kursorem tylko przy pierwszym uruchomieniu (brak pliku ustawień).
- Okno: obszar roboczy = rozdzielczość, całe okno z ramką w obszarze roboczym ekranu (nad paskiem zadań),
  wyśrodkowane. `window_set_position` ustawia róg obszaru roboczego — pozycja przez `_set_outer_position`.
- Okno — lista rozdzielczości (2f6cbe3): tylko takie, które z ramką mieszczą się nad paskiem zadań, na końcu
  „maks. okno” (`get_max_windowed_size`; ramka mierzona z okna, domyślnie typowa Windows 16x39). Zapisana
  rozdzielczość = faktyczny obszar roboczy.
- Okno — ręczna zmiana rozmiaru (przeciąganie, maksymalizacja): po 0,4 s spokoju rozmiar i monitor do ustawień,
  zapis, `resolution_changed` (+ SettingsService dla skali UI) i `window_resized_by_user`; w opcjach pozycja
  „(własny)”, otwarte opcje odświeżają listę bez odliczania.
- Okno zmaksymalizowane: `window_maximized` w ustawieniach (display); start / „Zastosuj” z tym samym rozmiarem
  przywraca maksymalizację, inny rozmiar = zwykłe okno. W opcjach pozycja „(zmaksymalizowane)”; brak wartości
  na liście -> najbliższa pozycja (nie pierwsza).
- Okno bez ramki na cały ekran Godot zgłasza jako EXCLUSIVE_FULLSCREEN i cofa przejście do okna, dopóki flaga
  „bez ramki” jest włączona — `_to_plain_window()` zdejmuje flagę przed zmianą trybu.
- Bez ramki: po zdjęciu ramki Windows potrafi zmaksymalizować okno — `_leave_fullscreen()` przed rozmiarem.
- Pełny ekran: `window_set_current_screen` + EXCLUSIVE_FULLSCREEN, UI w rozdzielczości (stretch canvas_items);
  zmiana rozdzielczości w pełnym ekranie bez przechodzenia przez okno.
- Flagi `--windowed/--resolution/--screen` są zjadane przez silnik (nie ma ich w `OS.get_cmdline_args`),
  więc zapisane ustawienia okna i tak je nadpisują.
- Test na żywym oknie: `tests/diag_window_service.gd` (z `--screen 1 --windowed`).

## Menu deweloperskie (`autoloads/services/dev_menu.gd`, F1 / ~; 2026-10-04, c71bcee)
- Własny motyw z czcionką hosta (`gui/theme/custom_font`) — nie dziedziczy pikselowej czcionki modułu.
- Rozmiary bazowe przy 1x (tekst 18, opisy 15, karty 18, tytuł 22, okno 880x600) przez `_font` / `_min_height`
  (meta) i `UIScaleService.px`; `_apply_scale` po `scale_changed` i zmianie rozmiaru okna.

## Opcje hosta (`scenes/ui/options_menu.tscn`, `scripts/ui/options_menu.gd`)
- Jedna treść opcji dla menu głównego hosta (osobne okno), BitBombera (okno) i Cienia Mgły: w menu Esc
  w prawym panelu, w menu głównym gry na ekranie treści — **wbudowana** (`embed_in(kontener)` — zakładki i „Zastosuj” w panelu modułu,
  bez tytułu / tła / „Zamknij”; Esc -> `closed`), 2026-10-04.
- **Zatwierdzanie tylko ustawień ekranu** (2026-10-04): „Zastosuj” wyłącznie na zakładce Ekran, odliczanie
  „Zachować?” tylko gdy zmienił się tryb okna / monitor / rozdzielczość / skalowanie (porównanie wyborów
  w kontrolkach z chwili otwarcia); „Gra bez quizów”, dźwięk, motyw, pytania, sterowanie — zapis od razu.
- **Menu główne Cienia Mgły** (2026-10-04, wzór FNaFB): menu niezależne od wybranej opcji — sam panel na środku
  (`Center/Panel`). „Wczytaj grę” (sloty), „Statystyki”, „Opcje” otwierają osobny ekran na całe okno
  (`ScreenPanel`, QuizWindow, tytuł + treść), menu znika; Esc wraca do menu. Lewa lista + prawy panel tylko w menu Esc.
- Zakładki: Ekran, Dźwięk, **Motyw**, **Pytania**, **Sterowanie**.
- Rozmiar tekstu: `_fs(base)` dopasowuje do czcionki aktywnego modułu (`snap_font_size` w module_root —
  quiz_rpg: siatka Jersey 15, 27 px). Wcześniej w skali 1x tekst był za mały (56692f5).
- **Motyw** (wartości modułu przez `SettingsService.set_module`, zmiana na żywo przez sygnał
  `module_setting_changed(module_id, key, value)`):
  - „Motyw” — `get_ui_skins()` aktywnego modułu, klucz `ui_skin`,
  - „Styl pasków” — `get_ui_bar_styles()`, klucz `ui_bar_style`,
  - suwak jasności 50–150 %, klucz `ui_brightness`,
  - `ExtraOptions` — przełączniki z `get_ui_options()` modułu (quiz_rpg: `ui_combat_compact` — UI walki tylko
    na szerokość treści, 1bd9c8e). Szczegóły motywów i pasków: [walka.md](walka.md).
- **Pytania** — zaznaczanie zestawów używanych w grze (QuestionBank) — [pytania.md](pytania.md).
- **Sterowanie** (ba3d490) — sekcje z pola `controls` w `module_manifest.json`
  (`[{label, actions, keys?}]`). Z menu głównego: lista „Gra:” (OptionButton) wybiera jeden moduł
  (dada72e, 2026-10-04); z modułu (`CoreManager.get_active_module`): tylko jego, bez listy. Tekst wierszy
  w rozmiarze innych zakładek (18, f5e31ea).
- **Opcje sterowania z manifestu** (a5bd148, 2026-10-04): `"control_options": [{key, label, default, options: [{id, name}]}]`
  — listy wyboru nad klawiszami modułu w zakładce Sterowanie, zapis od razu (`SettingsService.set_module`).
  Cień Mgły: `move_default` (walk / run) i `sprint_mode` (hold / toggle) + akcja `sprint` (Shift). Klawisz
  odwraca domyślny ruch (domyślny bieg + przytrzymanie = chód); bieg = `run_speed_mult` (1,6x), drużyna
  biegnie z liderem (`player.gd`, CienMgly 427fdbb). Test: `diag_sprint`. Nazwy akcji z opcjonalnego pola manifestu
  `action_labels` (`{akcja: nazwa}`), bez niego id akcji.
  **Zmiana klawiszy (2026-10-03)**: każda akcja ma 2 pola — klik -> „Naciśnij…”, Esc anuluje, Backspace
  czyści pole; klawisz zajęty przez inną akcję tego samego modułu przechodzi do nowej (komunikat w nagłówku);
  „Przywróć domyślne” per moduł (decyzje usera). `scripts/core/input_binds.gd` (`InputBinds`): zapis
  `SettingsService.set_module(<id>, "binds", {akcja: [physical_keycode]})` — tylko akcje różne od domyślnych
  z `project.godot`; nakładanie na InputMap przy starcie (`SettingsService.apply_input_binds`) i po starcie
  modułu (`ModuleHost` — BitBomber dopisuje swoje domyślne klawisze w `_ensure_key_action`). Sekcje bez
  `actions` (sam opis `keys`, np. strzałki w menu) — tylko tekst.
- BitBomber jest submodułem: manifest ze sterowaniem jest na jego gałęzi `main` (7c87f4f). Zmiana
  w submodule = commit + push w nim (na gałęzi, nie detached HEAD), potem commit wskaźnika w repo głównym.

## Menu Esc (`modules/quiz_rpg/scenes/ui/pause_menu.tscn`, 3230daa, 6f0e076)
- Motyw modułu przypięty do sceny: panele LeftPanel / RightPanel mają typ QuizWindow, zaznaczenie
  (`SelectionBox`) styl „selected”, paski statusu / drużyny / umiejętności / ekwipunku to `QuizBar`.
- Panele w proporcji 1:5 (size flags stretch ratio — menu wąskie, rozciągane), tytuł „Menu” 66 px
  bez minimalnej szerokości (zmiana usera).
- **HUD bez panelu statystyk** (8de6001): HP, XP, poziom, punkty, seria tylko w menu Esc. W `hud.gd`
  zostały popup nagrody i `FadeOverlay`. Punkty i seria — na dole lewego panelu menu Esc (`ScoreLabel`,
  771e59f). Punkty: `PlayerStats.on_correct_answer()` = 10 + seria × 5 za dobrą odpowiedź (walka, zagadki);
  zła zeruje serię. Nic nie odblokowują (nagrody liczą poprawne odpowiedzi, serię i poziom).

## Audio (a6b3314)
- Powrót do menu / wyjście z gry przywraca muzykę menu: `modules/quiz_rpg/scripts/ui/main_menu.gd`
  (przy pokazaniu menu) i `scripts/ui/main_menu.gd` hosta (przy zmianie widoczności).

## Eksplorator map (9b54fc1)
- `scripts/tools/map_generator_preview.gd` → `_ensure_module_singletons`: przy spacerze graczem tworzy
  singletony modułu (PlayerStats, ekwipunek…). Bez nich gracz miał 0 HP i walka z podglądu nie działała
  (tak wyglądał błąd „wybór postaci po Walcz nie działa”).

## Git: puste zmiany po reimporcie (6c40d50)
- Godot zapisuje pliki z LF, a `core.autocrlf=true` dawał w GitHub Desktop „zmienione” pliki bez różnic.
  `.gitattributes`: `* text=auto eol=lf` + `git add --renormalize .`. Gdy znów się pojawią: renormalize.
