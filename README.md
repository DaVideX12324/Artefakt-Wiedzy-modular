# Artefakt Wiedzy — platforma modularna

Platforma edukacyjno-techniczna zbudowana w **Godot 4.x**. Host wykrywa i uruchamia niezależne moduły (gry, quizy, narzędzia edukacyjne) bez znajomości ich wewnętrznej struktury. Każdy moduł może działać zarówno osadzony w hoście, jak i standalone.

> Repo: [github.com/DaVideX12324/Artefakt-Wiedzy-modular](https://github.com/DaVideX12324/Artefakt-Wiedzy-modular)

Moduły są submodułami gita — klonuj razem z nimi:

```bash
git clone --recurse-submodules https://github.com/DaVideX12324/Artefakt-Wiedzy-modular.git
# istniejąca kopia: git submodule update --init --recursive
```

## Moduły

| Moduł | Repo | Status |
|-------|------|--------|
| **BitBomber** | [github.com/DaVideX12324/BitBomber](https://github.com/DaVideX12324/BitBomber) | W migracji |
| **Cień Mgły** (Quiz RPG) | [github.com/DaVideX12324/CienMgly](https://github.com/DaVideX12324/CienMgly) (submoduł w `modules/quiz_rpg`) | W rozwoju |

BitBomber to gra 2D typu bomberman-like z wbudowanym systemem quizów edukacyjnych — pierwszy artefakt wykonawczy platformy.

Cień Mgły (moduł Quiz RPG) to gra RPG z eksploracją, walką turową i quizami edukacyjnymi wplecionymi w mechanikę — party, ekwipunek, save sloty, generowany świat. Opis: [`modules/quiz_rpg/README.md`](modules/quiz_rpg/README.md).

## Edytor quizów

Menu główne platformy zawiera dedykowany przycisk **"Moje quizy"** — globalny edytor quizów dostępny niezależnie od uruchomionego modułu.

Użytkownik może:
- przeglądać istniejące quizy załadowane przez `QuizService`,
- tworzyć nowe quizy i zapisywać je jako pliki `.json`,
- edytować pytania: treść, typ (`multiple_choice`, `true_false`, `fill_text`, `fill_tiles`, `matching`), trudność (1–5), kategorię i wyjaśnienie,
- importować quizy z zewnętrznych plików `.json`.

Quizy stworzone w edytorze są dostępne we wszystkich modułach platformy przez `QuizService` — wystarczy podać odpowiednie `quiz_id` przy starcie quizu w danym module.

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
│   │   ├── window_service.gd    # Tryb okna, rozdzielczość, monitor, rozmiar okna
│   │   ├── audio_service.gd     # Muzyka i efekty (szyny Master / Music / SFX)
│   │   ├── cheat_service.gd     # Cheaty deweloperskie
│   │   └── dev_menu.gd          # Menu deweloperskie (F1 / ~)
│   └── compat/                  # Adaptery kompatybilności dla modułów legacy
├── modules/
│   ├── BitBomber/               # Git submodule → github.com/DaVideX12324/BitBomber
│   ├── quiz_rpg/                # Git submodule → github.com/DaVideX12324/CienMgly (Cień Mgły)
│   └── _template/               # Szablon startowy do tworzenia nowych modułów
├── scenes/                      # Sceny hosta (launcher, menu modułów, okno opcji, edytor quizów)
├── scripts/                     # Skrypty hosta (m.in. core/input_binds.gd — zmiana klawiszy)
├── resources/                   # Zasoby hosta
├── docs/
│   ├── module_contract.md       # Kontrakt modułu — co musi zawierać
│   ├── migration_plan.md        # Plan migracji istniejących modułów
│   ├── kontekst/                # Bieżący stan prac (na start sesji), opisy tematyczne
│   └── znane_problemy.md        # Do zrobienia, pułapki, rozwiązane
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
| `WindowService` | Tryb okna (okno / bez ramki / pełny ekran), rozdzielczość, monitor; zapamiętuje ręczny rozmiar i maksymalizację okna |
| `AudioService` | Muzyka i efekty dźwiękowe, głośności szyn |
| `CheatService` | Cheaty i menu deweloperskie (F1 / ~) |
| `ModuleRegistry` | Wykrywanie i rejestracja modułów |
| `InputBinds` (klasa) | Zmienione klawisze akcji per moduł (zakładka „Sterowanie”) |

## Okno opcji

Wspólne okno opcji hosta (`scenes/ui/options_menu.tscn`) ma zakładki Ekran, Dźwięk, Motyw, Pytania i Sterowanie.
Zmiany ekranu wymagają potwierdzenia z odliczaniem, reszta zapisuje się od razu. Moduł może wbudować treść
okna we własne menu (`embed_in(kontener)`); zakładki Motyw i Sterowanie biorą dane z aktywnego modułu
(metody `get_ui_skins` / `get_ui_options` / `get_ui_bar_styles` i pola manifestu poniżej).

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

Pola opcjonalne używane przez okno opcji:

- `controls` — sekcje zakładki „Sterowanie”: `[{label, actions: [akcje InputMap]}]` albo `{label, keys: "opis"}`;
- `action_labels` — nazwy akcji do wyświetlenia (`{akcja: nazwa}`);
- `control_options` — listy wyboru nad klawiszami (`[{key, label, default, options: [{id, name}]}]`), zapis
  w `SettingsService.set_module(<id>, key, …)` (np. domyślny chód / bieg w Cieniu Mgły).

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

Cień Mgły robi to inaczej: zamiast `ModuleConfig` ma `QuizRpgPaths`, kopie usług hosta w `_host/` i
`project.godot.off`, a samodzielny projekt tworzy `modules/quiz_rpg/tools/make_standalone.sh` — opis w
[`modules/quiz_rpg/README.md`](modules/quiz_rpg/README.md).

## Tworzenie nowego modułu

Nowe moduły startują z gotowego szablonu w [`modules/_template/`](modules/_template/README.md):

1. Skopiuj `modules/_template` do `modules/<TwojModul>`.
2. Podmień `TEMPLATE_MODULE_ID` i `Template Module` w plikach szablonu.
3. Rozwijaj gameplay lokalnie w folderze modułu, korzystając z `ModuleRuntime.path(...)` i globalnych serwisów hosta.

Szablon zawiera manifest, cienki wrapper `module_root`, minimalną scenę startową i `START_PROMPT.md` do generowania nowej gry.

## Migracja istniejących modułów

Plan migracji: [`docs/migration_plan.md`](docs/migration_plan.md)

Kolejność:
1. `BitBomber` — moduł z adapterem dla autoloadów i mapy inputu
2. Kolejne moduły według ustalonego szablonu

## Wymagania

- Godot 4.7 (GL Compatibility renderer)
- Brak zewnętrznych zależności
