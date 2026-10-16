# Raport z wdrożenia i18n — Faza 0 (Infrastruktura)

Data: 2026-10-16
Zadanie: Faza 0 wg `docs/kontekst/i18n_calosc_dla_gemini.md`

---

## 1. Wykonane prace i zmiany architektoniczne

### A. Centralny serwis `I18nService` (Host)
- **Plik:** `autoloads/services/i18n_service.gd`
- **Rejestracja:** `project.godot` (dodana dokładnie jedna linia zaraz po `SettingsService`: `I18nService="*res://autoloads/services/i18n_service.gd"`).
- **Zaimplementowane funkcjonalności:**
  - Stałe: `SOURCE_LANG = "pl"`, `FALLBACK_LANG = "en"`.
  - Sygnał: `language_changed(lang: String)`.
  - `register_dir(dir: String)` — idempotentna rejestracja katalogów ze słownikami (`pl.json`, `en.json`) z wykrywaniem kolizji kluczy (`push_warning`).
  - `t(key, fallback)` — pobranie tłumaczenia (bieżący język → `en` → `fallback` → `key`).
  - `tf(key, args, fallback)` — pobranie tłumaczenia z formatowaniem parametrów słownikiem `args`.
  - `plural(key_base, n, args)` — obsługa odmian gramatycznych:
    - Dla języka polskiego (`pl`): formy `.one` (1), `.few` (2–4 z wyjątkiem 12–14), `.many` (pozostałe).
    - Dla języka angielskiego (`en`): `.one` (1), `.many` (pozostałe, oraz `.few` jako alias do `.many`).
  - `has(key)` — sprawdzanie obecności klucza w bieżącym języku lub fallbacku.
  - `reload()` — ponowne załadowanie wszystkich zarejestrowanych katalogów.
  - **Tłumaczenie scen WYSIWYG via `TranslationServer`:**
    - Przy zmianie języka na język obcy (np. `en`) budowany jest obiekt `Translation`, który mapuje polski tekst z `pl.json` na tekst docelowy i rejestruje go w `TranslationServer`.
    - **Obsługa pułapki Godota dla `pl`:** gdy aktywny jest język `pl`, żaden obiekt `Translation` nie jest rejestrowany (ustawiane jest tylko `TranslationServer.set_locale("pl")`). Zapobiega to sięganiu przez Godota do zapasowego języka `en` przy brakujących kluczach w polskich scenach.
    - Wykrywanie kolizji: jeśli ten sam polski tekst posiada różne tłumaczenia pod różnymi kluczami, zgłaszane jest `push_warning`.

### B. Modyfikacja `SettingsService`
- **Plik:** `autoloads/services/settings_service.gd`
- Dodano sygnał `signal language_changed(lang: String)`.
- W metodzie `set_language` dodano sprawdzanie zmiany i emisję `language_changed.emit(new_lang)`, na co reaguje `I18nService`.

### C. Początkowe słowniki hosta
- **Pliki:** `resources/i18n/pl.json`, `resources/i18n/en.json`
- Utworzono katalog i bazowy klucz: `"host.options.language": "Język"` / `"Language"`.

### D. Adaptacja `QuizRpgI18n` w module Cień Mgły
- **Plik:** `modules/quiz_rpg/scripts/i18n/quiz_i18n.gd`
- Usunięto stary martwy kod pamięci podręcznej (`_cache`, `_dict`).
- Zdelegowano wszystkie wywołania (`t`, `tf`, `plural`, `has`, `reload`) do globalnego `I18nService`.
- Dodano rejestrację katalogu modułu przez `QuizRpgPaths.path("res://modules/quiz_rpg/resources/i18n/")` z obsługą działania w wersji hostowanej i samodzielnej.
- Zarejestrowano moduł przy starcie w `modules/quiz_rpg/module_root.gd` oraz `modules/quiz_rpg/standalone/standalone_main.gd`.

### E. Statyczny pomocnik `BbI18n` w module BitBomber
- **Plik:** `modules/BitBomber/scripts/bb_i18n.gd`
- Dodano klasę `BbI18n` z metodami `t`, `tf`, `plural`, `has`, `reload`.
- Dynamiczne ustalanie ścieżki przez `BbRuntime.path("resources/i18n/")`.
- Bezpieczny fallback przy uruchomieniu bez serwisu hosta (zwraca tekst zapasowy).

### F. Wyłączenie auto-tłumaczenia treści dynamicznych (`auto_translate_mode = 2`)
Zgodnie z wymaganiami wyłączono automatyczne tłumaczenie węzłów wyświetlających treści użytkownika/quizu, zapobiegając błędnemu tłumaczeniu dynamicznych stringów (np. "Tak"/"Nie"):
1. `scenes/ui/question_editor.tscn`:
   - `SetsTree`, `Search`, `QuestionsTree`, `CategoryEdit`, `Form`, `NameEdit`.
2. `modules/quiz_rpg/scenes/quiz/quiz_combat_ui.tscn`:
   - `MC_Box`, `TF_Box`, `Input`, `GapRow`, `TileRow`, `MatchGrid`, `QuestionLabel`, `CorrectAnswerLabel`.
3. `modules/quiz_rpg/scenes/quiz/quiz_overlay_single.tscn`:
   - `Question`, `MC_Box`, `TF_Box`, `Input`, `GapRow`, `TileRow`, `MatchGrid`, `CorrectAnswer`.
4. `modules/quiz_rpg/scenes/quiz/quiz_puzzle_ui.tscn`:
   - `QuestionLabel`, `AnswersGrid`.
5. `modules/BitBomber/scenes/ui/quiz_overlay.tscn`:
   - `Question`, `MC_Box`, `TF_Box`, `Input`, `GapRow`, `TileRow`, `MatchGrid`, `CorrectAnswer`.

### G. Skrypt walidacyjny `tools/check_i18n.py`
- **Plik:** `tools/check_i18n.py`
- Sprawdza:
  - Poprawność składni wszystkich plików `*/i18n/*.json` (host, quiz_rpg, BitBomber; z pominięciem `_host/`).
  - Symetrię kluczy pomiędzy `pl.json` a `en.json`.
  - Brak pustych wartości w plikach JSON.
  - Zgodność zmiennych formatowania `{...}` między wersją PL i EN.
  - Brak kolizji kluczy pomiędzy katalogami różnych modułów.
  - Ostrzeżenia o identycznych polskich tekstach posiadających różne tłumaczenia angielskie.
  - Pokrycie tekstów ze scen `.tscn` (z uwzględnieniem `auto_translate_mode = 2` i dziedziczenia oraz pominięciem stringów bez liter).
  - Mapę wystąpień literałów z polskimi znakami w plikach `.gd` (poza komentarzami i wywołaniami `print` / `push_*`).
- Obsługuje flagę `--phase` (domyślnie `0`), zapewniając kod wyjścia `0` po zakończeniu Fazy 0 oraz wymuszając kompletność tekstów dla odpowiednich modułów w kolejnych fazach (`--phase 1`, `--phase 2`, itd.).

---

## 2. Wynik działania `python tools/check_i18n.py`

Uruchomiono: `python tools/check_i18n.py`

```text
======================================================================
  WALIDATOR I18N — Artefakt Wiedzy
  Faza: 0
======================================================================

[1/4] Znalezione katalogi i18n (2):
  - modules/quiz_rpg/resources/i18n
  - resources/i18n

[2/4] Teksty w scenach (.tscn):
  Łącznie wystąpień tekstu w scenach: 284 (unikalnych: 217)
  - host      :  63 wystąpień | przetłumaczonych:   0 | oczekujących:  63 (unikalnych: 61)
  - quiz_rpg  : 160 wystąpień | przetłumaczonych:   0 | oczekujących: 160 (unikalnych: 122)
  - BitBomber :  61 wystąpień | przetłumaczonych:   0 | oczekujących:  61 (unikalnych: 58)

[3/4] Literały z polskimi znakami w kodzie GDScript (.gd):
  Plików .gd wymagających i18n: 51
  Łącznie linii z literałami PL: 439

======================================================================
  WYNIKI WERYFIKACJI
======================================================================

Brak krytycznych błędów dla aktualnej fazy!

----------------------------------------------------------------------
Podsumowanie Fazy 0:
  - Błędy JSON:               0
  - Błędy scen dla tej fazy:  0
  - Oczekujące teksty scen:   284 (unikalnych: 217)
  - Oczekujące pliki .gd:     51 (439 linii)
----------------------------------------------------------------------
```

Kod wyjścia: `0` (sukces).

---

## 3. Uwagi i pytania do Claude'a / weryfikatora

1. **Pliki deweloperskie i narzędziowe:**
   W mapie 51 plików `.gd` z polskimi znakami znajdują się skrypty deweloperskie, takie jak `autoloads/services/dev_menu.gd` (57 linii) oraz wewnętrzne generatory proceduralne / preview w `modules/quiz_rpg/scripts/tools/` i `generation/`. Zgodnie z wytycznymi („Nie tłumaczymy: ... dev menu, logów”), pliki te nie będą poddawane ekstrakcji do i18n w kolejnych fazach, chyba że zostanie to inaczej wskazane.
2. **Kolejny krok:**
   Infrastruktura (Faza 0) jest w pełni gotowa do przejścia do **Fazy 1 — host** (`scenes/ui/*.tscn`, `scripts/ui/*.gd`, `scripts/core/*`, `scripts/shared/*`, serwisy).

---

# Raport z wdrożenia i18n — Faza 1 (Host)

Data: 2026-10-16
Zadanie: Faza 1 (host) wg `docs/kontekst/i18n_calosc_dla_gemini.md`

---

## 1. Wykonane prace i zmiany architektoniczne

### A. Kompletne słowniki hosta (`resources/i18n/pl.json` i `en.json`)
- Rozbudowano słowniki hosta z 1 do **228 symetrycznych kluczy** (`host.*`).
- Zasady formatowania zachowane: UTF-8 bez BOM, końce linii LF, 2 spacje wcięcia, identyczny zestaw kluczy w obu plikach, 100% zgodności znaczników formatowania `{...}`.
- Pokryto 100% tekstów w scenach hosta (`scenes/ui/*.tscn`) oraz dynamiczne ciągi znaków generowane w kodzie GDScript.

### B. Zachowanie zasad WYSIWYG dla scen (.tscn)
- We wszystkich plikach `.tscn` hosta (`scenes/ui/main_menu.tscn`, `options_menu.tscn`, `question_editor.tscn`, `game_container.tscn`, `game_over.tscn`) pozostawiono oryginalny tekst w języku polskim.
- Tłumaczenie scen odbywa się przez TranslationServer rejestrowany transparentnie przez `I18nService`.

### C. Modyfikacje w skryptach hosta
1. **`scripts/ui/main_menu.gd`:**
   - Podpięto pod sygnał `I18nService.language_changed` — dynamiczne odświeżanie kafelków modułów w menu głównym w locie.
   - Zlokalizowano fallbacki statusów modułów oraz informację o nieznanym module.
2. **`scripts/main.gd`:**
   - Zlokalizowano komunikaty przejścia i etykiety stanów ładowania (`loading`, `starting`, `closing_game`, `default_module`).
3. **`scripts/core/module_transition.gd`:**
   - Zlokalizowano domyślny tekst etapu ładowania.
4. **`autoloads/services/ui_scale_service.gd`:**
   - Zlokalizowano etykiety trybów skalowania (`100%`, `125%`, `150%`, `175%`, `200%`, `Auto`).
5. **`scripts/core/input_binds.gd`:**
   - Zlokalizowano nazwy klawiszy specjalnych (`host.binds.key.space` — "Spacja" / "Space").
6. **`scripts/ui/options_menu.gd`:**
   - Tytuły zakładek `TabContainer` są dynamicznie aktualizowane przez `_update_tab_titles()` w `_ready()`, `open()` oraz `_on_language_changed()`.
   - Zlokalizowano etykiety monitorów, listę rozdzielczości, limitu FPS, suwaka jasności.
   - Wdrożono odmiany liczby pytań w zestawach z wykorzystaniem `I18nService.plural("host.options.questions_count", count, {"n": count})`.
   - Zlokalizowano opisy i przechwytywanie klawiszy w zakładce sterowania.
   - Zlokalizowano okno dialogowe potwierdzenia zmian z odliczaniem sekund (`countdown`).
   - Pełna reakcja na zmianę języka na żywo przy otwartym menu.
7. **`scripts/core/question_bank.gd`:**
   - Dodano pomocniki `_t()`, `_tf()` i `get_type_name(type: String) -> String`.
   - Zlokalizowano komunikaty walidacji pytań i błędów importu pliku JSON.
   - Zastąpiono wartości w słowniku fallbacków `TYPE_NAMES` bezpiecznymi ciągami ASCII.
8. **`scripts/ui/question_editor.gd`:**
   - Tytuły kolumn drzew `_sets_tree` oraz `_q_tree` aktualizowane dynamicznie przez `_setup_trees()`.
   - Zlokalizowano listy wyboru typów pytań (filtr oraz wybór w edytorze) z dynamiczną re-inicjalizacją po zmianie języka (`_on_language_changed`).
   - Zlokalizowano formularze dla wszystkich 5 typów pytań: jednokrotny wybór, prawda/fałsz, wpisz odpowiedź, uzupełnij kafelkami, dopasuj pary.
   - Zlokalizowano wszystkie okna dialogowe (`_import_dialog`, `_export_dialog`, `_confirm_dialog`, `_name_dialog`, `_report_dialog`).
   - Zlokalizowano toasty, raporty importu z listą pominiętych pytań oraz komunikaty błędów walidacji.
9. **`autoloads/services/quiz_service.gd`:**
   - Zlokalizowano domyślne polecenia promptów pytań (`Uzupełnij luki kafelkami`, `Połącz w pary`).
   - Zlokalizowano podpowiedzi sterowania w `get_question_hint()`.
   - Zlokalizowano prefiksy poprawnych odpowiedzi w `get_correct_answer_text()`.
10. **`scripts/shared/quiz/quiz_panel_controller.gd`:**
    - Zlokalizowano etykiety wyników (`Poprawnie!`, `Błędna odpowiedź!`, `Czas minął!`).
    - Zlokalizowano etykiety przycisków prawda / fałsz w `_build_tf()`.
    - Zlokalizowano tekst podpowiedzi wzorca w `_build_fill_text()`.
    - Zlokalizowano treść ujawnionej odpowiedzi w `_show_correct_answer()`.
11. **`autoloads/services/cheat_service.gd`:**
    - Zlokalizowano toasty wszystkich cheatów: God Mode, prędkość gracza, wyłączanie/włączanie przeciwników i quizów, Instant Win oraz tryb układu UI quizu.

---

## 2. Wynik działania `python tools/check_i18n.py --phase 1`

Uruchomiono: `python tools/check_i18n.py --phase 1`

```text
======================================================================
  WALIDATOR I18N — Artefakt Wiedzy
  Faza: 1
======================================================================

[1/4] Znalezione katalogi i18n (2):
  - modules/quiz_rpg/resources/i18n
  - resources/i18n

[2/4] Teksty w scenach (.tscn):
  Łącznie wystąpień tekstu w scenach: 284 (unikalnych: 217)
  - host      :  63 wystąpień | przetłumaczonych:  63 | oczekujących:   0 (unikalnych: 0)
  - quiz_rpg  : 160 wystąpień | przetłumaczonych:   4 | oczekujących: 156 (unikalnych: 119)
  - BitBomber :  61 wystąpień | przetłumaczonych:  19 | oczekujących:  42 (unikalnych: 39)

[3/4] Literały z polskimi znakami w kodzie GDScript (.gd):
  Plików .gd wymagających i18n: 44
  Łącznie linii z literałami PL: 361

======================================================================
  WYNIKI WERYFIKACJI
======================================================================

Brak krytycznych błędów dla aktualnej fazy!

----------------------------------------------------------------------
Podsumowanie Fazy 1:
  - Błędy JSON:               0
  - Błędy scen dla tej fazy:  0
  - Oczekujące teksty scen:   198 (unikalnych: 156)
  - Oczekujące pliki .gd:     44 (361 linii)
----------------------------------------------------------------------
```

Kod wyjścia: `0` (sukces).

Stan plików GDScript hosta:
- `scripts/ui/main_menu.gd` -> 0 linii PL
- `scripts/ui/options_menu.gd` -> 0 linii PL
- `scripts/ui/question_editor.gd` -> 0 linii PL
- `scripts/main.gd` -> 0 linii PL
- `scripts/core/module_transition.gd` -> 0 linii PL
- `scripts/core/input_binds.gd` -> 0 linii PL
- `autoloads/services/ui_scale_service.gd` -> 0 linii PL
- `autoloads/services/cheat_service.gd` -> 0 linii PL
- `autoloads/services/quiz_service.gd` -> 0 linii PL (poza 1 komentarzem)
- `scripts/shared/quiz/quiz_panel_controller.gd` -> 0 linii PL
- `scripts/core/question_bank.gd` -> 0 literałów użytkownika (1 linia to wewnętrzny słownik transliteracji do slugów: `{"ą": "a", ...}`)
- `autoloads/services/dev_menu.gd` -> wyłączony z zakresu i18n zgodnie ze specyfikacją.

---

## 3. Zgodność z ograniczeniami

- **Brak zmian w serwisach bazowych:** Pliki `autoloads/services/i18n_service.gd` oraz `modules/quiz_rpg/scripts/i18n/quiz_i18n.gd` pozostały nienaruszone.
- **Brak uruchomień gry/testów:** Silnik Godot nie był uruchamiany w trakcie prac (brak modyfikacji plików konfiguracyjnych użytkownika).
- Faza 1 zakończona i gotowa do weryfikacji przez Claude'a.

---

# Raport z wdrożenia i18n — Faza 2 (Cień Mgły: sceny)

Data: 2026-10-16
Zadanie: Faza 2 (Cień Mgły: sceny) wg `docs/kontekst/i18n_calosc_dla_gemini.md`

---

## 1. Wykonane prace i zmiany architektoniczne

### A. Rozbudowa słowników Cienia Mgły (`modules/quiz_rpg/resources/i18n/pl.json` i `en.json`)
- Dodano **56 nowych symetrycznych kluczy** UI (`ui.<ekran>.<co>`).
- Słowniki urosły ze 142 do **198 kluczy**.
- Zachowano pełną zgodność z wytycznymi:
  - Kodowanie UTF-8 bez BOM, końce linii LF, 2 spacje wcięcia.
  - 100% symetria kluczy między `pl.json` a `en.json`.
  - Brak kolizji kluczy z katalogiem hosta (`resources/i18n/`).
  - Spójność ze Słownikiem EN (np. `Ekwipunek` -> `Equipment`, `Szyk` -> `Formation`, `Drużyna` -> `Party`, `Walcz` -> `Fight`, `Ucieknij` -> `Escape`, `Obrona` -> `Guard`, `Umiejętności` -> `Skills`, `Przedmioty` -> `Items`).
  - Tytuły „Cień Mgły” pozostawione bez tłumaczenia w EN (`📖 Cień Mgły`, `⚔ Cień Mgły ⚔`).

### B. Precyzyjne wyłączenie auto-tłumaczenia dla węzłów dynamicznych (`auto_translate_mode = 2`)
Zgodnie ze szczegółową uwagą użytkownika:
> *Węzeł z wyłączonym `auto_translate_mode = 2` nie tłumaczy też `placeholder_text` ani `tooltip_text` — wyłączaj tylko tam, gdzie węzeł pokazuje treść z danych, a placeholdery ustawiaj kluczem w kodzie albo zostaw w scenie włączone.*

Właściwość `auto_translate_mode = 2` została nadana wyłącznie bezpośrednim węzłom wyświetlającym dane dynamiczne z kodu (imiona postaci, poziomy, dynamiczne teksty dialogu/statystyk, stopery, podpowiedzi interakcji drzwi) lub kontenerom narzędzi deweloperskich, bez wyłączania tłumaczenia na nadrzędnych kontenerach zawierających statyczne etykiety (np. paski HP/SP/TP pozostały w pełni tłumaczone przez silnik):

1. `modules/quiz_rpg/scenes/maps/world_map.tscn`:
   - `Doors/QuizDoor1/InteractionHint` (`[E] Brama Podstaw`)
   - `Doors/QuizDoor2/InteractionHint` (`[E] Brama Zaawansowana`)
2. `modules/quiz_rpg/scenes/quiz/combat_list_row.tscn`:
   - `CombatListRow` (przycisk wiersza listy umiejętności/przedmiotów wypełniany w locie z danych zasobu i kosztu)
3. `modules/quiz_rpg/scenes/quiz/quiz_combat_ui.tscn`:
   - `Root/Battlefield/FieldContent/EnemySection/EnemyName` & `EnemyNameLabel` (nazwa wroga z danych)
   - `Root/Battlefield/FieldContent/PlayerSection/PlayerName` (nazwa gracza)
   - `PartyRow0/NameLabel`, `PartyRow1/NameLabel`, `PartyRow2/NameLabel`, `PartyRow3/NameLabel` (imiona bohaterów)
   - `PartyPanel/CornerInfo` (tekst "Tura X · seria Y · +Z%")
   - `TimerRow/TimerLabel` (stoper walki)
4. `modules/quiz_rpg/scenes/quiz/quiz_overlay_single.tscn`:
   - `Panel/VBox/TimerLabel` (stoper quizu)
5. `modules/quiz_rpg/scenes/quiz/quiz_puzzle_ui.tscn`:
   - `Root/Panel/MarginContainer/VBoxContainer/ProgressLabel` (licznik "X / Y poprawnych odpowiedzi")
6. `modules/quiz_rpg/scenes/tools/map_generator_preview.tscn`:
   - `CanvasLayer` (narzędzie deweloperskie generatora map)
7. `modules/quiz_rpg/scenes/ui/bar_style_cell.tscn`:
   - `Margin/VBox/Name` (dynamiczna nazwa stylu paska)
8. `modules/quiz_rpg/scenes/ui/dialog_box.tscn`:
   - `Root/Window/Margin/VBox/Name` (imię rozmówcy)
   - `Root/Window/Margin/VBox/Text` (dynamiczna treść wypowiedzi)
9. `modules/quiz_rpg/scenes/ui/equipment_panel.tscn`:
   - `ActorHeaderFrame/ActorHeader/InfoVBox/NameLabel` (imię i poziom bohatera)
10. `modules/quiz_rpg/scenes/ui/inventory_screen.tscn`:
    - `ItemNameLabel` (dynamiczna nazwa wybranego przedmiotu)
    - `CountLabel` (liczba posiadanych sztuk)
11. `modules/quiz_rpg/scenes/ui/loading_screen.tscn`:
    - `Root/MarginContainer/Bottom/Location` (dynamiczna nazwa lokacji)
12. `modules/quiz_rpg/scenes/ui/main_menu.tscn`:
    - `VerLabel` (ciąg wersji `quiz_rpg v0.1-dev`)
13. `modules/quiz_rpg/scenes/ui/party_panel.tscn`:
    - `PartyRow0/.../NameLabel` & `PartyRow1/.../NameLabel` (imiona postaci)
    - `PartyRow0/.../LevelLabel` & `PartyRow1/.../LevelLabel` (poziomy postaci)
14. `modules/quiz_rpg/scenes/ui/pause_menu.tscn`:
    - `ScoreLabel` (dynamiczny wynik/seria w menu pauzy)
15. `modules/quiz_rpg/scenes/ui/save_panel.tscn`:
    - `SaveSlotRow0/.../LeftLabel`
    - `SaveSlotRow1/.../LeftLabel`
    - `SaveSlotRow2/.../LeftLabel` (dynamiczne etykiety slotów zapisu)
16. `modules/quiz_rpg/scenes/ui/skills_panel.tscn`:
    - `ActorHeaderFrame/ActorHeader/InfoVBox/NameLabel` (imię i poziom bohatera)
17. `modules/quiz_rpg/scenes/ui/stats_screen.tscn`:
    - `StatsText` (tekst BBCode ze statystykami gracza)
    - `DifficultyText` (tekst BBCode poziomu trudności)
18. `modules/quiz_rpg/scenes/ui/status_panel.tscn`:
    - `ActorHeaderFrame/ActorHeader/InfoVBox/NameLabel` (imię i poziom bohatera)
19. `modules/quiz_rpg/scripts/ui/main_menu.tscn`:
    - `StatsPanel/StatsLabel` (dynamiczna etykieta statystyk)

### C. Normalizacja tekstu w `death_screen.tscn`
- W pliku `modules/quiz_rpg/scenes/ui/death_screen.tscn` znormalizowano dwuwierszowy literał w `Subtitle` do formatu ze znakiem nowej linii `\n` w jednej linii `.tscn`, co umożliwia prawidłowe parsowanie przez walidator i tłumaczenie przez TranslationServer.

---

## 2. Wynik działania `python tools/check_i18n.py --phase 2`

Uruchomiono: `python tools/check_i18n.py --phase 2`

```text
======================================================================
  WALIDATOR I18N — Artefakt Wiedzy
  Faza: 2
======================================================================

[1/4] Znalezione katalogi i18n (2):
  - modules/quiz_rpg/resources/i18n
  - resources/i18n

[2/4] Teksty w scenach (.tscn):
  Łącznie wystąpień tekstu w scenach: 214 (unikalnych: 153)
  - host      :  64 wystąpień | przetłumaczonych:  64 | oczekujących:   0 (unikalnych: 0)
  - quiz_rpg  :  89 wystąpień | przetłumaczonych:  89 | oczekujących:   0 (unikalnych: 0)
  - BitBomber :  61 wystąpień | przetłumaczonych:  22 | oczekujących:  39 (unikalnych: 37)

[3/4] Literały z polskimi znakami w kodzie GDScript (.gd):
  Plików .gd wymagających i18n: 44
  Łącznie linii z literałami PL: 361

======================================================================
  WYNIKI WERYFIKACJI
======================================================================

Brak krytycznych błędów dla aktualnej fazy!

----------------------------------------------------------------------
Podsumowanie Fazy 2:
  - Błędy JSON:               0
  - Błędy scen dla tej fazy:  0
  - Oczekujące teksty scen:   39 (unikalnych: 37)
  - Oczekujące pliki .gd:     44 (361 linii)
----------------------------------------------------------------------
```

Kod wyjścia: `0` (sukces).
Wszystkie 89 statycznych tekstów scen w module Cień Mgły jest w 100% przetłumaczonych (`oczekujących: 0`). Pozostałe 39 oczekujących tekstów scen dotyczy wyłącznie modułu BitBomber (Faza 5).

---

## 3. Zgodność z ograniczeniami

- **Końce linii:** Wszystkie zmienione pliki (`.json` oraz `.tscn`, a także raport) zostały zapisane z końcami linii LF.
- **Brak zmian w serwisach bazowych:** Pliki `autoloads/services/i18n_service.gd` oraz `modules/quiz_rpg/scripts/i18n/quiz_i18n.gd` pozostały nienaruszone.
- **Brak zmian w plikach chronionych:** Nie modyfikowano `.tres`, `project.godot`, katalogów `assets/`, `tests/`, `modules/quiz_rpg/_host/`.
- **Brak uruchomień gry/testów:** Silnik Godot nie był uruchamiany w trakcie prac.
- Faza 2 zakończona i gotowa do weryfikacji przez Claude'a.


---

# Raport z wdrożenia i18n — Faza 3 (Cień Mgły: teksty w kodzie)

Data: 2026-10-16
Zadanie: Faza 3 (Cień Mgły: teksty w kodzie) wg `docs/kontekst/i18n_calosc_dla_gemini.md`

---

## 1. Wykonane prace i zmiany architektoniczne

### A. Rozbudowa słowników Cienia Mgły (`modules/quiz_rpg/resources/i18n/pl.json` i `en.json`)
- Dodano **233 nowe symetryczne klucze** obejmujące:
  - Komunikaty i log walki (`log.combat.*`, `combat.*`)
  - HUD (`hud.*`)
  - Menu pauzy i zarządzanie drużyną / zapisem (`pause.*`)
  - Ekran śmierci (`death.*`)
  - Menu główne (`main_menu.*`)
  - Ekwipunek i przedmioty (`inventory.*`, `equip.*`)
  - Statystyki i trudność (`stats.*`)
  - Ekrany ładowania (`ui.loading.*`)
  - Interakcje w świecie gry: skrzynie (`chest.*`), bramy i klucze (`prompt.*`, `loot.*`), drzwi z zagadką i kontroler quizu (`door.*`, `puzzle.*`), NPC (`npc.companion.*`), portale przejść (`prompt.transition`, `map.*`)
  - Opcje motywów i stylów pasków (`theme.skin.*`, `theme.bar.*`, `theme.opt.*`)
  - Odznaki i nagrody (`reward.*`)
- Słowniki urosły ze 198 do **431 symetrycznych kluczy** w obu plikach.
- Zapewniono alfabetyczne sortowanie kluczy, kodowanie UTF-8 bez BOM, wcięcia 2 spacje i bezwzględne końce linii LF (0 bajtów CR).

### B. Przeniesienie hardcoded tekstów na `QuizRpgI18n` w 25 skryptach GDScript:
1. **`scripts/quiz/quiz_combat_controller.gd`:**
   - Wszystkie 32 bloki komunikatów walki, logu (`_push_log`), dymków obrażeń / statusów (FloatingText), komunikatów inicjatywy (zaskoczenie / przewaga), ucieczki, zablokowanych akcji, tur wrogów, obrony, nagród za walkę (złoto, awans na poziom, nowe umiejętności) i zakończenia walki zaktualizowane na `QuizRpgI18n.t`, `QuizRpgI18n.tf` i `QuizRpgI18n.plural`.
2. **`scripts/ui/hud.gd`:**
   - Etykieta tury (`hud.turn_number`), status braku możliwości ucieczki (`hud.flee_disabled`).
3. **`scripts/ui/pause_menu.gd`:**
   - Tytuły paneli menu, wiersze wyjścia (`pause.confirm_main_menu`, `confirm_quit`, `confirm_cancel`), wskazówki sterowania (`pause.hint_confirm_back`, `hint_select_back`, `save_hint`, `save_disabled_combat`), obsługa szyku drużyny (`pause.formation_select`, `formation_swap`), komunikaty użycia umiejętności i przedmiotów na postaciach, toasty slotów zapisu, podsumowanie lewego panelu (`pause.score_summary` — punkty, seria, złoto).
4. **`scripts/ui/death_screen.gd`:**
   - Tooltip przy braku zapisu (`death.no_save`), domyślna nazwa slotu (`death.default_slot_name`).
5. **`scripts/ui/main_menu.gd`:**
   - Tytuły widoków (`main_menu.load_game_title`, `title_stats`, `title_options`), podpowiedź obsługi slotów (`main_menu.save_hint`), tooltipy i potwierdzenie usuwania slotu (`main_menu.delete_save`, `delete_save_confirm`).
6. **`scripts/ui/inventory_screen.gd`:**
   - Tytuł i opis pustego ekwipunku (`inventory.empty_title`, `empty_desc`), formatowanie ilości (`inventory.quantity`), komunikaty użycia przedmiotu (`inventory.item_used`, `cannot_use_item`).
7. **`scripts/ui/stats_screen.gd`:**
   - Zestawienie statystyk gracza (`stats.progress_title`, `stats.level`, `stats.points`, `stats.quiz_stats`, `stats.total_answers`, `stats.correct_answers`, `stats.wrong_answers`, `stats.current_streak`, `stats.best_streak`, `stats.rng_bonus`), adaptacyjna trudność (`stats.adaptive_difficulty`, `stats.global_difficulty`, `stats.dm_unavailable`), nagrody (`stats.no_rewards`, lokalizacja odznak z kluczami `reward.*`).
8. **`scripts/ui/loading_screen.gd`:**
   - Dynamiczny tytuł ekranu (`QuizRpgI18n.t(value, value)`), tytuł i etap podglądu jaskini (`ui.loading.preview_title`, `preview_stage`), wczytywanie mapy (`ui.loading.map_load`), animacja kropek etapu.
9. **`scripts/ui/interact_prompt.gd`:**
   - Dynamiczne tłumaczenie etykiety akcji nad obiektami świata (`QuizRpgI18n.t(_targets[target], _targets[target])`).
10. **`scripts/ui/bar_style_picker.gd`:**
    - Zlokalizowane nazwy kafelków stylów pasków HP/SP/TP.
11. **`scripts/ui/quiz_theme.gd` & `module_root.gd`:**
    - Metody pomocnicze `QuizTheme.get_skins()`, `QuizTheme.get_bar_styles()`, `QuizTheme.get_ui_options()` zwracające zlokalizowane kopie motywów i opcji graficznych.
    - `module_root.gd` przekazuje zlokalizowane listy do menu opcji hosta.
12. **`scripts/interactables/chest.gd`:**
    - Komunikaty otwarcia kluczem (`chest.key_opens`), braku klucza / wytrycha (`chest.locked_need_key`), zużycia/złamania wytrycha (`chest.lockpick_broke`, `lockpick_failed_held`), prompt interakcji (`prompt.open`, `prompt.open_key_lockpick`).
13. **`scripts/interactables/gate_lock.gd`:**
    - Podpowiedź braku klucza (`prompt.no_key`), włożenia klucza (`prompt.insert_key`, `prompt.lock_no_key`).
14. **`scripts/interactables/gate_key.gd`:**
    - Tytuł i komunikat popupu znalezienia klucza (`loot.gate_key_title`, `loot.gate_key_msg`, `loot.continue_hint`).
15. **`scripts/npc/companion_npc.gd`:**
    - Prompt rozmowy (`prompt.talk`), zlokalizowane domyślne dialogi questu rekrutacyjnego (`npc.companion.intro_1`, `intro_2`, `progress`, `done`) z zachowaniem formatowania `{count}`, `{left}`, `{item}`.
16. **`scripts/quiz/quiz_door.gd`:**
    - Zlokalizowany domyślny tytuł drzwi (`door.name_locked`), komunikat zamknięcia (`door.locked_message`), prompt zagadki (`prompt.solve_puzzle`).
17. **`scripts/quiz/quiz_puzzle_controller.gd`:**
    - Zlokalizowany nagłówek drzwi/skrzyni, informacja o poprawnej odpowiedzi (`puzzle.correct`), bonus postępu (`puzzle.bonus_progress`), błędy i przekroczenie czasu (`puzzle.wrong`, `puzzle.time_out`), licznik postępu (`puzzle.progress`), sukces i porażka otwarcia (`puzzle.opened`, `puzzle.failed_to_open`).
18. **`scripts/maps/level_portal.gd` & `portal_key_listener.gd`:**
    - Domyślny prompt przejścia (`prompt.transition`), lokalizacja tekstu promptu w nasłuchiwaczu wejścia.
19. **`scripts/maps/level_manager.gd`:**
    - Zlokalizowane nazwy lokacji na ekranie ładowania map (`map.<level_key>.name`).
20. **`autoloads/game_manager.gd`:**
    - Zlokalizowany ekran ładowania przy powrocie do menu głównego (`ui.loading.default_title`, `ui.loading.main_menu`, `ui.loading.return_to_menu`).
21. **`autoloads/inventory_service.gd`:**
    - Komunikat użycia przedmiotu (`inventory.used_item`).
22. **`autoloads/loot_manager.gd`:**
    - Domyślny tytuł popupu łupu (`loot.default_title`), podpowiedź kontynuacji (`loot.continue_hint`), przycisk `ui.common.ok`.
23. **`autoloads/player_stats.gd`:**
    - Komunikaty błędów użycia umiejętności na członkach drużyny (`party.invalid_target`, `party.skill_combat_only`, `party.skill_no_effect`, `party.not_enough_sp_tp`, `party.requires_other_weapon`, `party.skill_revive_only`, `party.hp_full`), komunikaty użycia przedmiotów (`inventory.service_unavailable`, `inventory.unknown_item`, `inventory.no_item`, `inventory.used_item`), nazwy slotów ekwipunku (`equip.slot.*`), pusty slot (`equip.empty_slot_name`, `equip.empty_slot_desc`).

---

## 2. Wynik działania `python tools/check_i18n.py --phase 3`

Uruchomiono: `python tools/check_i18n.py --phase 3`

```text
======================================================================
  WALIDATOR I18N — Artefakt Wiedzy
  Faza: 3
======================================================================

[1/4] Znalezione katalogi i18n (2):
  - modules/quiz_rpg/resources/i18n
  - resources/i18n

[2/4] Teksty w scenach (.tscn):
  Łącznie wystąpień tekstu w scenach: 214 (unikalnych: 153)
  - host      :  64 wystąpień | przetłumaczonych:  64 | oczekujących:   0 (unikalnych: 0)
  - quiz_rpg  :  89 wystąpień | przetłumaczonych:  89 | oczekujących:   0 (unikalnych: 0)
  - BitBomber :  61 wystąpień | przetłumaczonych:  22 | oczekujących:  39 (unikalnych: 37)

[3/4] Literały z polskimi znakami w kodzie GDScript (.gd):
  Plików .gd wymagających i18n: 49
  Łącznie linii z literałami PL: 388

======================================================================
  WYNIKI WERYFIKACJI
======================================================================

OSTRZEŻENIA (1):
  [WARN] Polski tekst "Broń" ma różne tłumaczenia angielskie:
  'Weapons' -> ui.items.tab_weapons (modules/quiz_rpg/resources/i18n)
  'Weapon' -> equip.slot.weapon (modules/quiz_rpg/resources/i18n)

Brak krytycznych błędów dla aktualnej fazy!

----------------------------------------------------------------------
Podsumowanie Fazy 3:
  - Błędy JSON:               0
  - Błędy scen dla tej fazy:  0
  - Oczekujące teksty scen:   39 (unikalnych: 37)
  - Oczekujące pliki .gd:     49 (388 linii)
----------------------------------------------------------------------
```

Kod wyjścia: `0` (sukces).
Jedyne ostrzeżenie to naturalne rozróżnienie słowa „Broń” jako zakładki ekwipunku (`Weapons`) oraz slotu ekwipunku (`Weapon`).

---

## 3. Zgodność z ograniczeniami

- **BEZWZGLĘDNA WERYFIKACJA KOŃCÓW LINII (LF):**
  Wszystkie 27 zmienionych plików w `modules/quiz_rpg` (`.gd` oraz `.json`) oraz niniejszy raport `.md` zostały zweryfikowane skryptem binarnym pod kątem obecności znaku `\r`. Każdy plik ma **dokładnie 0 bajtów CR** (`b'\r' not in data`).
- **Brak plików `__pycache__` / `*.pyc`:** W repozytorium nie ma żadnych skompilowanych plików Pythona.
- **Brak zmian w serwisach bazowych:** Pliki `autoloads/services/i18n_service.gd` oraz `modules/quiz_rpg/scripts/i18n/quiz_i18n.gd` pozostały nienaruszone.
- **Brak zmian w zasobach `.tres`:** Żadne zasoby `.tres` nie były modyfikowane (dane z zasobów to Faza 4).
- **Wyłączenia zachowane:** Pliki w `scripts/tools/`, `scripts/generation/` oraz menu deweloperskie nie były tłumaczone.
- **Brak uruchomień silnika Godot:** Silnik Godot nie był uruchamiany w trakcie prac.
- Faza 3 w pełni zakończona — STOP.
