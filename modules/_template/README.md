# Template nowego modulu

To jest aktualny punkt startowy dla nowych gier w `Artefakt Wiedzy modular`.

## Jak uzyc

1. Skopiuj caly folder `modules/_template` do `modules/<TwojModul>`.
2. Zmien nazwe folderu.
3. Podmien w plikach:
   - `TEMPLATE_MODULE_ID`
   - `Template Module`
4. Jesli chcesz odpalac gre standalone, skopiuj modul poza hosta i zmien
   `project.godot.off.example` na `project.godot`.

## Co dostajesz

- `module_manifest.json` - rejestracja modulu w hoście
- `module_root.tscn` + `module_root.gd` - cienki wrapper modulu
- `scripts/module_runtime.gd` - helper do sciezek host/standalone
- `scenes/game.tscn` + `scripts/game.gd` - minimalna scena startowa
- `START_PROMPT.md` - prompt startowy do tworzenia nowej gry z Codexem

## Zasady

- Gameplay i zasoby trzymaj lokalnie w folderze modulu.
- W kodzie uzywaj `ModuleRuntime.path("scenes/...")` zamiast twardego `res://scenes/...`,
  jesli dany skrypt ma dzialac i w hoście, i standalone.
- Wspolne rzeczy bierz z hosta:
  - `QuizService`
  - `SettingsService`
  - `UIScaleService`
  - `WindowService`
- Jesli potrzebujesz starych nazw typu `SettingsManager` lub `UIScaleManager`,
  traktuj je jako warstwe zgodnosci, a nie nowe zrodlo prawdy.

## Najlepszy workflow

- nowa gra powstaje od poczatku w `modules/<id>/`
- standalone to tylko drugi sposob uruchomienia
- host laduje modul przez `module_manifest.json` i `module_root.tscn`

To jest najbezpieczniejsza droga, jesli chcesz uniknac pozniejszych migracji i walki ze sciezkami.
