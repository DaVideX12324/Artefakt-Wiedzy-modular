# Kontrakt modulu

Minimalny modul musi miec manifest:

```json
{
  "id": "quiz_rpg",
  "name": "Cień Mgły",
  "description": "Krotki opis",
  "version": "0.1.0",
  "entry_scene": "module_root.tscn",
  "quiz_path": "resources/quizzes",
  "asset_path": "assets"
}
```

Wymagane sa tylko `id`, `name` i `entry_scene` (`ModuleRegistry.REQUIRED_FIELDS`); reszta jest opcjonalna. Pola dla okna opcji hosta
(`controls`, `action_labels`, `control_options`) opisuje glowny README.

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

## Sesja: konfiguracja z hosta i wynik

Host moze uruchomic modul z gotowymi ustawieniami sesji (`ModuleHost.start_module(manifest, parent, session_config)`,
w `main.gd` drugi argument `_start_module`). Modul czyta je w `embedded_start`:

```gdscript
var config: Dictionary = host_api.get_session_config()   # {} = zwykle menu modulu
```

Klucze ustala modul (BitBomber: README modulu, sekcja „Sesja z hosta”). Na koniec sesji modul oddaje wynik:

```gdscript
host_api.finish_session({
	"completed": true,
	"winner": {"id": 1, "name": "Gracz 1", "is_bot": false},
	"players": [...],                       # per gracz: wygrane, odpowiedzi
	"answers": {"correct": 4, "wrong": 1},
	"duration_s": 312.5,
	"summary": "Gracz 1 wygral · 3 rundy",  # przetlumaczony tekst do menu hosta
})
```

`ModuleHost` dopisuje `module_id` i `finished_at` (czas uniksowy), zapisuje wpis w `SessionResults`
(`user://artefakt_wiedzy_sessions.json`, ostatnie 200) i emituje `module_session_finished(module_id, result)`.
Menu hosta pokazuje pod przyciskiem modulu „Ostatnio: <summary>”. Odczyt: `SessionResults.get_history(module_id)`,
`SessionResults.get_last(module_id)`; testy podmieniaja `SessionResults.save_path`.

## Sceny embedded i standalone

Godot nie ma aliasow dla `res://`, a `.tscn` przechowuje sciezki wzgledem aktywnego `project.godot`. Ten sam kod dziala wiec w dwoch ukladach:

- embedded: `res://modules/<module_id>/...`
- standalone: `res://...`

Nie duplikujemy logiki gry. Sciezki do wlasnych plikow modul sklada przez maly pomocnik (`ModuleRuntime` w szablonie, `BBRuntime` w BitBomberze, `QuizRpgPaths` w Cieniu Mgly — kazdy ladowany przez `preload`), a sceny odwoluja sie do zasobow po UID.

Wazne: w folderze modulu wewnatrz hosta nie moze lezec prawdziwy `project.godot`, bo Godot potraktuje to jako osobny projekt i zignoruje folder z punktu widzenia hosta. Dlatego plik leży jako `project.godot.off` (w szablonie `project.godot.off.example`) i dopiero po skopiowaniu modulu poza hosta zmieniamy mu nazwe na `project.godot`.

### Kopie zasobow hosta (`_host/`) — wzor: quiz_rpg

Modul, ktory korzysta z zasobow / autoloadow hosta, trzyma ich kopie w `modules/<id>/_host/` z plikiem
`.gdignore` (host ich nie widzi: bez importu, eksportu i konfliktow UID / `class_name`).
- Kopie robi skrypt w hoscie (host = zrodlo prawdy; zmiany zawsze w hoscie, potem synchronizacja):
  `Godot --headless --path <host> -s res://modules/quiz_rpg/tools/sync_host_copies.gd [-- --dry-run]`.
  Zakres = domkniecie zaleznosci (sciezki w plikach modulu, klasy globalne, autoloady z `project.godot`);
  w kopiach `res://X` -> `res://_host/X`, UID-y jak w oryginalach. Generuje tez `project.godot.off`.
- Sceny modulu wskazuja zasoby hosta po UID (kazdy `ext_resource` ma UID), wiec trafiaja w kopie.
  Sciezki w kodzie: `scripts/quiz_rpg_paths.gd` — `path("scenes/x.tscn")` dla plikow modulu,
  `host("res://assets/...")` dla zasobow hosta, `localize()` / `canonical()` dla sciezek zapisanych w plikach
  (JSON konfiguracji trzyma forme hosta `res://modules/quiz_rpg/...`). Wlasne skrypty: `preload("../x.gd")`.
- Uruchomienie samodzielne: `modules/quiz_rpg/tools/make_standalone.sh <katalog poza hostem>` (kopia bez
  `.gdignore`, `project.godot.off` -> `project.godot`); start: `standalone/standalone_main.tscn` uruchamia
  modul przez kopie `ModuleHost`, `ModuleRegistry` widzi manifest w korzeniu projektu.

## Reguly dla gier standalone i embedded

- Modul nie zaklada, ze jego root to zawsze `res://`.
- Sciezki zasobow przechodza przez pomocnik modulu (`ModuleRuntime.path(...)`, `BBRuntime.path(...)`, `QuizRpgPaths.path(...)`).
- Wspolne systemy ida przez globalne services hosta: `QuizService`, `SettingsService`, `UIScaleService`, `WindowService`, `AssetService`.
- Singletony specyficzne dla konkretnej gry maja nazwy prefiksowane nazwa gry albo sa dziecmi sceny modulu.
- Zapis `user://` ma prefiks gry, np. `user://quiz_rpg_saves/` (sloty zapisu Cienia Mgly).
- Input actions modulu nie moga kolidowac z akcjami innych modulow. Dzis: BitBomber uzywa `p1_*` / `p2_*` / `quiz_p1_*` / `quiz_p2_*` i `pause` (rejestruje je w `module_root.gd`), Cien Mgly `move_*`, `interact`, `sprint`. Opis klawiszy do zakladki „Sterowanie” — pola `controls` i `action_labels` w manifescie.

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
