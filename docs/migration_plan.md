# Plan migracji BitBomber i Quiz RPG

## Etap 1: Quiz RPG

- Skopiowac projekt do `modules/quiz_rpg`.
- Nie kopiowac aktywnego `project.godot` do folderu modulu. Jesli trzeba, zachowac go jako `standalone_project.godot.example`.
- Dodac `module_manifest.json`.
- Dodac `scripts/module_config.gd`.
- Zmienic sciezki `res://scenes/...`, `res://scripts/...`, `res://resources/...` na `ModuleConfig.path(...)` albo `host_api.path(...)`.
- Przepiac quizy z lokalnego `QuizManager` na globalny `QuizService`.
- `GameManager`, `PlayerStats`, `DifficultyManager` zostawic jako node'y pod rootem modulu albo prefiksowane singletony, jesli beda specyficzne dla Quiz RPG.
- Zmienic `user://savegame.json` na `user://quiz_rpg_savegame.json`.

## Etap 2: BitBomber

- Skopiowac projekt do `modules/bitbomber`.
- Nie kopiowac aktywnego `project.godot` do folderu modulu. Jesli trzeba, zachowac go jako `standalone_project.godot.example`.
- Dodac `module_manifest.json`.
- Zostawic obecny `host_module` jako punkt zaczepienia, ale przeniesc go do oficjalnego `embedded_start(host_api, manifest)`.
- Zmienic sciezki przez `ModuleConfig.path(...)`.
- Przepiac wspolne autoloady na globalne services hosta:
  - `QuizManager` -> `QuizService`
  - `SpriteLoader` -> `AssetService`
  - `SettingsManager` -> `SettingsService`
  - `UIScaleManager` -> `UIScaleService`
  - `WindowManager` -> `WindowService`
- Zostawic specyficzne rzeczy gry lokalnie:
  - `GameManager`
  - `RoundManager`
- Przeniesc input mapy do prefiksowanych akcji `bb_*`, zeby nie kolidowaly z innymi grami.

## Decyzja architektoniczna

Nie kopiujemy ustawien gry do glownego `project.godot` hosta. Host ma byc neutralny. Gdy modul potrzebuje akcji input albo warstw fizyki, rejestruje je przy starcie modulu albo ma prefiksowane ustawienia zaakceptowane w projekcie hosta.
