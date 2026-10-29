# Changelog — Artefakt Wiedzy

Istotne zmiany platformy (host) i aktualizacje dołączonych modułów. Szczegóły zmian gier są w changelogach ich repo
(`modules/quiz_rpg/CHANGELOG.md`, `modules/BitBomber/CHANGELOG.md`). Zasady numerów i etapów:
[`docs/wersjonowanie.md`](docs/wersjonowanie.md).

## [Unreleased]

## [0.9.7-beta] — 2026-10-29

Cień Mgły 0.9.7-beta (zapis pozycji, trwała śmierć wrogów, bez pauzy w walce, klawisze, balans), BitBomber bez zmian.

### Zmieniono
- Wszystkie klawisze gry zmienialne w Opcje → Sterowanie: nowe akcje zatwierdź / wróć (Z / X), odpowiedzi 1–4,
  zakładki (Q / E), mapa i zoom (M, = / -); panel quizu korzysta z akcji (Enter, spacja, Esc i strzałki działają zawsze).
- Nazwy klawiszy numerycznych w Sterowaniu („Num 1” zamiast „End” przy wyłączonym NumLocku), „=” / „-”.

### Naprawiono
- Skala UI wracała po restarcie mimo „Zastosuj” i „Zatwierdź” (zapis szedł przed ustawieniem skali); skala działa
  i zapisuje się od razu po wyborze.

## [0.9.6-beta] — 2026-10-29

Cień Mgły 0.9.6-beta (poprawki z testów: ekran śmierci, pauza, balans, ekwipunek, losowe spotkania), BitBomber bez zmian.

### Dodano
- Skala UI 1,25 („Średnie”); zapisany wybór „Duże” / „4K” przenosi się bez zmian.

### Zmieniono
- Opcje: zakładki przewijane, okno ma stałą wysokość przy każdej skali (wcześniej zakładki zmieniały jego rozmiar).
- Quiz: pytania z lukami z klawiatury; najechanie myszą po odpowiedzi nie kasuje podświetlenia wyniku.

### Naprawiono
- Opcje → Dźwięk: font grup efektów (interfejs, walka, otoczenie) nie skalował się ze skalą UI.

## [0.9.5-beta] — 2026-10-29

Cień Mgły 0.9.5-beta (słabszy boss samouczka, wrogowie nad UI walki), BitBomber bez zmian.

## [0.9.4-beta] — 2026-10-29

Cień Mgły 0.9.4-beta, BitBomber bez zmian.

### Zmieniono
- Ikona aplikacji w eksporcie Windows; utwory w `music_tracks.json` (bez `world_map`, inne przypisania `cave` / `castle`).
- Usunięte szczegółowe scenariusz i formularz ewaluacji etapu 2.

## [0.9.3-beta] — 2026-10-29

Cień Mgły 0.9.3-beta, BitBomber bez zmian.

### Dodano
- Ekran „Autorzy” w menu głównym: credits hosta i modułów (pole `credits` w manifeście).

## [0.9.0-beta] — 2026-10-29

Cień Mgły 0.9.0-beta (CienMgly 2caf7a2e, tag v0.9.0-beta), BitBomber 0.9.0-beta. Eksport na Androida (preset, podpis wydania lokalnie).

### Dodano
- Opcje → Dźwięk: osobne suwaki grup efektów pod „Efekty dźwiękowe” — interfejs, walka, otoczenie. Szyny `SFX_UI`,
  `SFX_Combat`, `SFX_Env` wysyłają do `SFX` (główny suwak skaluje wszystkie); `AudioService.play_sfx_by_name` wybiera
  grupę wg nazwy dźwięku albo parametru `bus`, `play_sfx` przyjmuje szynę (domyślnie `SFX`, np. BitBomber).
- Menu deweloperskie → Drużyna: usuwanie towarzyszy (pojedynczo albo wszystkich).
- Menu deweloperskie → „🥚 Easter eggi imion”: przełącznik odsłaniający ukryte opcje ekranu imienia w Cieniu Mgły
  (`CheatService.name_eggs_revealed`).
- Preset eksportu „Windows Desktop” (`export_presets.cfg`, w repo): jeden plik `build/windows/ArtefaktWiedzy.exe`
  (~340 MB, paczka wbudowana) bez folderów roboczych, testów i narzędzi; wersja pliku Windows `0.8.0.0`.

### Naprawiono
- Quiz: pytania z kafelkami pokazywały zdanie z lukami dwa razy (nad paskiem czasu i w wierszu luk) — wczytywanie
  wpisuje zdanie do treści pytania, więc wcześniejsza poprawka nie działała; teraz nad lukami polecenie „Uzupełnij luki
  kafelkami”. Pary bez treści: „Połącz w pary” w bieżącym języku zamiast stałego „Dopasuj elementy.”.
- Brakujące polskie znaki w menu głównym, oknie opcji i podpowiedziach quizu („Wybierz moduł”, „Wyjście”,
  „Rozdzielczość”, „Głośność ogólna” itd.).

### Moduły
- Cień Mgły: commit `267d98fa` — wyjście ze ścieków zamknięte do pokonania bossa, drabiny przejść zawsze przy ścianie,
  koniec gry po wyjściu ze ścieków na cmentarzysko (nie po bossie), poprawka łupu wrogów bez tabeli, wrogowie
  dochodzą do celu poza siatką nawigacji, imię bohatera przy nowej grze (z easter eggami).

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
