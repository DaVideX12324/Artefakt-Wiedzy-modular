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
