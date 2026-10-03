# Menu, opcje, menu Esc, audio (stan na 2026-10-04)

## Opcje hosta (`scenes/ui/options_menu.tscn`, `scripts/ui/options_menu.gd`)
- Jedna treść opcji dla menu głównego hosta (osobne okno), BitBombera (okno) i Cienia Mgły: w menu Esc
  i menu głównym gry **wbudowana w prawy panel** (`embed_in(kontener)` — zakładki i „Zastosuj” w panelu modułu,
  bez tytułu / tła / „Zamknij”; Esc -> `closed`), 2026-10-04.
- **Zatwierdzanie tylko ustawień ekranu** (2026-10-04): „Zastosuj” wyłącznie na zakładce Ekran, odliczanie
  „Zachować?” tylko gdy zmienił się tryb okna / monitor / rozdzielczość / skalowanie (porównanie wyborów
  w kontrolkach z chwili otwarcia); „Gra bez quizów”, dźwięk, motyw, pytania, sterowanie — zapis od razu.
- **Menu główne Cienia Mgły** (2026-10-04): układ jak menu Esc — lewy panel QuizWindow z przyciskami, prawy
  panel z „Wczytaj grę” (sloty), „Statystyki”, „Opcje”; ponowny klik / Esc zamyka panel.
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
  (`[{label, actions, keys?}]`). Z menu głównego: wszystkie moduły (nagłówek na moduł); z modułu
  (`CoreManager.get_active_module`): tylko jego. Nazwy akcji z opcjonalnego pola manifestu
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
