# Changelog — Artefakt Wiedzy

Istotne zmiany platformy (host) i aktualizacje dołączonych modułów. Szczegóły zmian gier są w changelogach ich repo
(`modules/quiz_rpg/CHANGELOG.md`, `modules/BitBomber/CHANGELOG.md`). Zasady numerów i etapów:
[`docs/wersjonowanie.md`](docs/wersjonowanie.md).

## [Unreleased]

## [0.8.0-alpha] — 2026-10-24

Pierwsza wersjonowana Alpha — punkt odniesienia (wcześniej zastępcze „v0.1-dev”). Opisuje stan platformy, nie zmiany
względem poprzedniego wydania.

### Platforma
- Wykrywanie modułów z `module_manifest.json`, uruchamianie embedded z ekranem przejścia i powrotem do menu.
- Wspólne serwisy: quizy (namespace per moduł), ustawienia globalne i per moduł, audio, skala UI, okno, tłumaczenia PL / EN.
- Okno opcji: obraz, dźwięk, język, sterowanie (zmiana klawiszy, opcje modułów z manifestu), pytania.
- Edytor pytań w menu głównym: zestawy, 5 typów pytań, import / eksport JSON, nadpisywanie wbudowanych zestawów,
  wybór aktywnych pytań.
- Sesja modułu w obie strony: konfiguracja do modułu (`session_config`), wynik z modułu (`finish_session`),
  historia `SessionResults` („Ostatnio: …” przy module w menu).
- Wersje w menu: platforma (prawy dolny róg) i każdy moduł (przycisk modułu) — z `project.godot` i manifestów.

### Moduły w tym wydaniu
- Cień Mgły `0.8.0-alpha`, commit `7e55c84e` (Alpha — miasto w budowie).
- BitBomber `0.9.0-beta`, commit `37b52ab` (Beta — zakres gry meczowej kompletny).

### Znane ograniczenia
- Paczka jest w Alphie, bo zawiera Cień Mgły w Alphie; platforma sama jest gotowa do testów (etap 1 ewaluacji:
  platforma + edytor pytań + BitBomber, [`docs/ewaluacja/`](docs/ewaluacja/etap1_scenariusz.md)).
- Assety są w prywatnym submodule — publicznie dostępny jest tylko zbudowany plik wykonywalny.
