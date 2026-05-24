# Artefakt Wiedzy — platforma modularna

Platforma edukacyjno-techniczna zbudowana w **Godot 4.x**. Host wykrywa i uruchamia niezależne moduły (gry, quizy, narzędzia edukacyjne) bez znajomości ich wewnętrznej struktury. Każdy moduł może działać zarówno osadzony w hoście, jak i standalone.

> Repo: [github.com/DaVideX12324/Artefakt-Wiedzy-modular](https://github.com/DaVideX12324/Artefakt-Wiedzy-modular)

## Moduły

| Moduł | Repo | Status |
|-------|------|--------|
| **BitBomber** | [github.com/DaVideX12324/BitBomber](https://github.com/DaVideX12324/BitBomber) | W migracji |

BitBomber to gra 2D typu bomberman-like z wbudowanym systemem quizów edukacyjnych — pierwszy artefakt wykonawczy platformy.

## Architektura hosta

Host nie zna wewnętrznej logiki modułów. Jego rola:

1. Skanuje `res://modules/*/module_manifest.json` przez `ModuleRegistry`.
2. Rejestruje zasoby modułu w globalnych serwisach.
3. Ładuje `entry_scene` z manifestu.
4. Jeśli scena eksponuje `embedded_start(host_api, manifest)` — przekazuje jej API hosta.
5. Moduł wraca do launchera przez `host_api.request_exit()` lub sygnał `exit_requested`.

## Struktura repo

```
Artefakt-Wiedzy-modular/
├── autoloads/
│   ├── module_registry.gd       # Wykrywa i rejestruje moduły
│   ├── services/
│   │   ├── quiz_service.gd      # Wspólny silnik quizów (namespace per moduł)
│   │   ├── settings_service.gd  # Ustawienia globalne i per moduł
│   │   ├── asset_service.gd     # Ładowanie assetów z katalogu modułu
│   │   ├── ui_scale_service.gd  # Wspólne skalowanie UI
│   │   └── window_service.gd    # Tryb okna, rozdzielczość, monitor
│   └── compat/                  # Adaptery kompatybilności dla modułów legacy
├── modules/
│   └── BitBomber/               # Git submodule → github.com/DaVideX12324/BitBomber
├── scenes/                      # Sceny hosta (launcher, menu modułów)
├── scripts/                     # Skrypty hosta
├── resources/                   # Zasoby hosta
├── docs/
│   ├── module_contract.md       # Kontrakt modułu — co musi zawierać
│   └── migration_plan.md        # Plan migracji istniejących modułów
└── project.godot
```

## Serwisy globalne

Moduły **nie tworzą własnych** `QuizManager`, `SettingsManager`, `UIScaleManager`, `WindowManager` ani `SpriteLoader`. Zamiast tego używają serwisów hosta:

| Serwis | Odpowiedzialność |
|--------|------------------|
| `QuizService` | Silnik quizów z namespace per moduł |
| `SettingsService` | Ustawienia globalne i per moduł |
| `AssetService` | Ładowanie assetów z katalogu modułu |
| `UIScaleService` | Skalowanie UI |
| `WindowService` | Tryb okna, rozdzielczość, monitor |
| `ModuleRegistry` | Wykrywanie i rejestracja modułów |

## Kontrakt modułu

Każdy moduł musi zawierać `module_manifest.json`:

```json
{
  "id": "bitbomber",
  "name": "BitBomber",
  "version": "1.0.0",
  "entry_scene": "scenes/module_entry_embedded.tscn"
}
```

Szczegóły kontraktu: [`docs/module_contract.md`](docs/module_contract.md)

## Konwencja ścieżek

Nigdy nie piszemy ścieżek na twardo:

```gdscript
# ŹLE
"res://scenes/game.tscn"

# DOBRZE
ModuleConfig.path("scenes/game.tscn")
```

`ModuleConfig.path()` zwraca `res://scenes/game.tscn` w standalone i `res://modules/<id>/scenes/game.tscn` w hoscie.

W trybie embedded można też używać API hosta:

```gdscript
host_api.start_quiz("informatyka")
host_api.asset_path("sprites/player.png")
```

## Dwa tryby działania modułu

Moduł posiada dwie sceny wejścia — cienkie wrappery, cała logika przechodzi przez `ModuleConfig.path()`:

- `scenes/module_entry_embedded.tscn` — ścieżki typu `res://modules/<id>/...` (host)
- `scenes/module_entry_standalone.tscn` — ścieżki typu `res://...` (standalone dev)

Jeśli moduł ma działać standalone, przechowuje `standalone_project.godot.example`. Do dev standalone kopiujesz moduł poza hosta i zmieniasz ten plik na `project.godot`.

> **Uwaga:** Host ignoruje podfolder jeśli wykryje w nim aktywny `project.godot`.

## Migracja istniejących modułów

Plan migracji: [`docs/migration_plan.md`](docs/migration_plan.md)

Kolejność:
1. `BitBomber` — moduł z adapterem dla autoloadów i mapy inputu
2. Kolejne moduły według ustalonego szablonu

## Wymagania

- Godot 4.x (GL Compatibility renderer)
- Brak zewnętrznych zależności
