# Kontrakt modulu

Minimalny modul musi miec manifest:

```json
{
  "id": "quiz_rpg",
  "name": "Quiz RPG",
  "description": "Krotki opis",
  "version": "0.1.0",
  "entry_scene": "scenes/module_entry_embedded.tscn",
  "quiz_path": "resources/quizzes",
  "asset_path": "assets",
  "standalone_project_template": "standalone_project.godot.example"
}
```

Scena wejscia moze, ale nie musi, implementowac:

```gdscript
func embedded_start(host_api, manifest: Dictionary) -> void:
	pass

func embedded_stop() -> void:
	pass
```

Do wyjscia z modulu:

```gdscript
host_api.request_exit()
```

albo:

```gdscript
signal exit_requested
exit_requested.emit()
```

## Sceny embedded i standalone

Godot nie ma aliasow dla `res://`, a `.tscn` przechowuje sciezki wzgledem aktywnego `project.godot`. Dlatego akceptujemy dwa cienkie wrappery:

- embedded: `res://modules/<module_id>/...`
- standalone: `res://...`

Nie duplikujemy logiki gry. Duplikacja dotyczy tylko sceny wejscia albo adaptera.

Wazne: w folderze modulu wewnatrz hosta nie moze lezec prawdziwy `project.godot`, bo Godot potraktuje to jako osobny projekt i zignoruje folder z punktu widzenia hosta. Uzywamy pliku `standalone_project.godot.example`, ktory dopiero po skopiowaniu modulu poza hosta mozna nazwac `project.godot`.

## Reguly dla gier standalone i embedded

- Modul nie zaklada, ze jego root to zawsze `res://`.
- Sciezki zasobow przechodza przez `ModuleConfig.path(...)`.
- Wspolne systemy ida przez globalne services hosta: `QuizService`, `SettingsService`, `UIScaleService`, `WindowService`, `AssetService`.
- Singletony specyficzne dla konkretnej gry maja nazwy prefiksowane nazwa gry albo sa dziecmi sceny modulu.
- Zapis `user://` ma prefiks gry, np. `user://quiz_rpg_savegame.json`.
- Input actions modulu maja prefiks gry, np. `bb_p1_up`, `qrpg_interact`.

## Services

Host automatycznie rejestruje modul w:

```gdscript
AssetService.register_module(manifest)
QuizService.register_module(manifest)
```

Domyslne sciezki:

- quizy: `resources/quizzes`
- assety: `assets`

Przyklady uzycia w module embedded:

```gdscript
var ids = host_api.get_quiz_ids()
var question = host_api.start_quiz("informatyka")
var result = host_api.answer_current_quiz({ "index": 0 })
var texture = host_api.get_texture("sprites/player.png")
```

Przyklady uzycia bezposrednio:

```gdscript
QuizService.start_quiz("bitbomber", "informatyka")
AssetService.get_texture("bitbomber", "sprites/player_1.png")
SettingsService.set_module("bitbomber", "bot_difficulty", 1)
```
