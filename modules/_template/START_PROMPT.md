Skopiuj ten prompt i podmien placeholdery przed rozpoczeciem pracy nad nowa gra:

```text
Tworzymy nowy modul do projektu Godot 4 "Artefakt Wiedzy modular".

Kontekst:
- nowy modul ma mieszkac od poczatku w `modules/<MODULE_ID>/`
- ma dzialac w dwoch trybach:
  1. embedded w hoście
  2. standalone po skopiowaniu folderu poza hosta i zmianie `project.godot.off.example` na `project.godot`
- nie robimy osobnego projektu poza modulem

Wymagania architektoniczne:
- zachowaj `module_manifest.json`, `module_root.tscn`, `module_root.gd`
- uzywaj `scripts/module_runtime.gd` do sciezek host/standalone
- nie zakladaj, ze `res://scenes/...` zawsze oznacza to samo w hoście i standalone
- wspolne systemy bierz z hosta, jesli sa dostepne:
  - `QuizService`
  - `SettingsService`
  - `UIScaleService`
  - `WindowService`
- jesli potrzebna jest zgodnosc ze starym API, zrob cienki adapter zamiast porozrzucanych `if`-ow

Cel modulu:
- nazwa: <MODULE_NAME>
- id: <MODULE_ID>
- opis: <KRÓTKI_OPIS>
- typ gry: <TYP_GRY>
- czy ma quizy: <TAK/NIE>
- czy ma lokalny multiplayer: <TAK/NIE>

Co chcemy zrobic najpierw:
1. przygotowac strukture scen i skryptow
2. zrobic minimalny flow start -> gameplay -> exit
3. upewnic sie, ze modul dziala w hoście bez psucia standalone

Pracuj zgodnie z istniejacymi wzorcami z `modules/BitBomber` i `modules/quiz_rpg`,
ale wybieraj prostsze rozwiazanie, jesli nowy modul nie potrzebuje calej ich zlozonosci.
```
