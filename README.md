# Artefakt Wiedzy Modular

Czysty host dla modulow gier edukacyjnych w Godot 4.

Ten projekt celowo nie dziedziczy struktury starego `Artefakt Wiedzy`. Host ma tylko launcher, rejestr modulow i loader scen. Konkretne gry trzymamy w `modules/<module_id>/`.

## Zasada

Kazdy modul ma:

- `module_manifest.json`
- scene embedded wskazana w manifiescie
- scene standalone do uzycia poza projektem hosta
- opcjonalny `project.godot`, jezeli ma dzialac standalone

Host:

1. Szuka manifestow w `res://modules/*/module_manifest.json`.
2. Rejestruje zasoby modulu w globalnych services.
3. Laduje `entry_scene`.
4. Jesli scena ma metode `embedded_start(host_api, manifest)`, przekazuje jej API hosta.
5. Modul wraca do launchera przez `host_api.request_exit()` albo sygnal `exit_requested`.

## Globalne services

Wspolne mechanizmy platformy sa globalnymi autoloadami hosta:

- `QuizService` - wspolny silnik quizow z namespace per modul
- `SettingsService` - ustawienia globalne i ustawienia per modul
- `UIScaleService` - wspolne skalowanie UI
- `WindowService` - tryb okna, rozdzielczosc i monitor
- `AssetService` - ladowanie assetow z katalogu modulu
- `ModuleRegistry` - wykrywanie manifestow

Moduly nie powinny tworzyc wlasnych globalnych `QuizManager`, `SettingsManager`, `UIScaleManager`, `WindowManager` ani `SpriteLoader`. Zamiast tego uzywaja tych services.

## Dwie cienkie sceny wejscia

Godot zapisuje sciezki w `.tscn` wzgledem aktualnego `project.godot`. Dodatkowo host ignoruje podfolder, jesli w srodku wykryje kolejne `project.godot`. Dlatego modul w hostcie nie moze miec aktywnego pliku `project.godot`.

Modul moze potrzebowac dwoch malych scen-wejsc:

- `scenes/module_entry_embedded.tscn` z pathami typu `res://modules/<id>/...`
- `scenes/module_entry_standalone.tscn` z pathami typu `res://...`

To powinny byc tylko wrappery. Wlasciwa logika i zasoby gry maja przechodzic przez `ModuleConfig.path(...)`.

Jesli modul ma dzialac standalone, trzymaj przy nim `standalone_project.godot.example`. Do standalone development kopiujesz modul poza hosta i tam zmieniasz ten plik na `project.godot`.

## Najwazniejsza konwencja

Nie piszemy w module twardo:

```gdscript
"res://scenes/game.tscn"
```

Piszemy przez helper modulu:

```gdscript
ModuleConfig.path("scenes/game.tscn")
```

W standalone da to `res://scenes/game.tscn`. W hoscie da `res://modules/<module_id>/scenes/game.tscn`.

W trybie embedded mozna tez uzywac API hosta:

```gdscript
host_api.start_quiz("informatyka")
host_api.get_texture("sprites/player.png")
host_api.asset_path("sprites/player.png")
```

## Migracja istniejacych gier

Nie przenosimy wszystkiego naraz. Najpierw robimy wrapper i `ModuleConfig`, potem poprawiamy sciezki i singletony.

Kolejnosc:

1. `quiz_rpg` jako prostszy modul.
2. `bitbomber` jako modul z osobnym adapterem dla autoloadow i input mapy.
3. Dopiero potem template dla kolejnych gier traktujemy jako stabilny.
