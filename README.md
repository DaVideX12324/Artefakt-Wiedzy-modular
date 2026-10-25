# Artefakt Wiedzy — platforma modularna

Platforma edukacyjno-techniczna zbudowana w **Godot 4.7**. Host wykrywa i uruchamia niezależne moduły (gry, quizy, narzędzia edukacyjne) bez znajomości ich wewnętrznej struktury. Każdy moduł może działać zarówno osadzony w hoście, jak i standalone.

> Repo: [github.com/DaVideX12324/Artefakt-Wiedzy-modular](https://github.com/DaVideX12324/Artefakt-Wiedzy-modular)

Moduły są submodułami gita — klonuj razem z nimi:

```bash
git clone --recurse-submodules https://github.com/DaVideX12324/Artefakt-Wiedzy-modular.git
# istniejąca kopia: git submodule update --init --recursive
```

> **`assets/` to prywatny submoduł** ([Artefakt-Wiedzy-assets](https://github.com/DaVideX12324/Artefakt-Wiedzy-assets)):
> licencje części paczek (m.in. Glionox, kupione zestawy) zabraniają redystrybucji, więc pliki assetów nie są
> publiczne. Bez dostępu do tego repo `--recurse-submodules` zgłosi błąd przy `assets`; kod i dokumentację da się pobrać
> zwykłym `git clone` (+ `git submodule update --init modules/BitBomber modules/quiz_rpg`), ale gra bez assetów się
> nie uruchomi. Publicznie dostępny jest tylko zbudowany plik wykonywalny.

## Wersja

**Artefakt Wiedzy `0.8.0-alpha`** (Alpha). Platforma jest gotowa do testów; paczka pozostaje w Alphie, dopóki Cień Mgły
nie przejdzie do Bety (mapa miasta w budowie). Zasady numerów i plan wydań: [`docs/wersjonowanie.md`](docs/wersjonowanie.md),
zmiany: [`CHANGELOG.md`](CHANGELOG.md).

## Moduły

| Moduł | Repo | Wersja |
|-------|------|--------|
| **BitBomber** | [github.com/DaVideX12324/BitBomber](https://github.com/DaVideX12324/BitBomber) (submoduł w `modules/BitBomber`) | `0.9.0-beta` (Beta) |
| **Cień Mgły** (Quiz RPG) | [github.com/DaVideX12324/CienMgly](https://github.com/DaVideX12324/CienMgly) (submoduł w `modules/quiz_rpg`, id `quiz_rpg`) | `0.8.0-alpha` (Alpha) |

BitBomber to gra 2D typu bomberman-like z quizami wplecionymi w rozgrywkę (ostatnia szansa, pytanie-bonus, quiz odrodzenia) — pierwszy artefakt wykonawczy platformy. Tryby Ostatni żywy i Zabójstwa, 28 map, AI botów, grafika i dźwięk wzorowane na Bomb It 7 (zasoby generowane skryptami). Opis: [`modules/BitBomber/README.md`](modules/BitBomber/README.md).

Cień Mgły (moduł Quiz RPG) to gra RPG z eksploracją, walką turową i quizami edukacyjnymi wplecionymi w mechanikę — drużyna, ekwipunek, sloty zapisu, generowany świat (jaskinie, ścieki), NPC miasta z usługami (sklepy, kowal, nauczyciel umiejętności) i wersja PL / EN. Opis: [`modules/quiz_rpg/README.md`](modules/quiz_rpg/README.md) (plik jest w repo modułu — widoczny po pobraniu submodułów).

> **Submoduły w pracy:** zmiany w pliku modułu (np. README Cienia Mgły) commituje się w **repo modułu**, a w hoście
> trzeba potem zacommitować nowy wskaźnik submodułu (`git add modules/quiz_rpg`). Sam host zapisuje tylko hash
> commita, a `docs/` hosta opisuje także prace w modułach.

## Pytania i edytor pytań

Menu główne hosta ma przycisk **„Pytania”** — globalny edytor zestawów pytań, dostępny niezależnie od uruchomionego modułu
(w Opcjach jest też zakładka **Pytania** do wyboru zestawów używanych w grze).

Użytkownik może:
- przeglądać zestawy: wbudowane (`resources/quizzes/<id>.json`, tylko do odczytu) i własne (`user://quizzes/<id>.json`),
- tworzyć nowe zestawy, edytować pytania (także wbudowanych — własny plik o tym samym id przesłania oryginał,
  „Przywróć oryginał” go usuwa),
- edytować pytania pięciu typów: `multiple_choice`, `true_false`, `fill_text`, `fill_tiles`, `matching` (treść, trudność 1–5,
  wyjaśnienie, odpowiedzi),
- importować zestawy z plików `.json` (okno plików albo przeciągnięcie pliku na okno; błędne pytania są pomijane
  i raportowane) oraz je eksportować,
- włączać i wyłączać całe zestawy i pojedyncze pytania (zapis w `user://quiz_selection.json`, globalnie dla wszystkich modułów).

Zestawy są dostępne we wszystkich modułach przez `QuizService` — moduł podaje `quiz_id` przy starcie quizu; gdy zestaw
nie istnieje albo jest wyłączony, pytania losuje się ze wszystkich aktywnych zestawów. Szczegóły:
[`docs/kontekst/pytania.md`](docs/kontekst/pytania.md).

## Architektura hosta

Host nie zna wewnętrznej logiki modułów. Jego rola:

1. Skanuje `res://modules/*/module_manifest.json` przez `ModuleRegistry` (foldery zaczynające się od `_` lub `.` — np. `_template` — są pomijane; moduł otwarty samodzielnie ma manifest w korzeniu projektu).
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
│   │   ├── i18n_service.gd      # Tłumaczenia PL / EN (języki, TranslationServer)
│   │   ├── asset_service.gd     # Ładowanie assetów z katalogu modułu
│   │   ├── ui_scale_service.gd  # Wspólne skalowanie UI
│   │   ├── window_service.gd    # Tryb okna, rozdzielczość, monitor, rozmiar okna
│   │   ├── audio_service.gd     # Muzyka i efekty (szyny Master / Music / SFX)
│   │   ├── cheat_service.gd     # Cheaty deweloperskie (tylko build debugowy)
│   │   └── dev_menu.gd          # Menu deweloperskie (F1 / ~)
│   └── compat/                  # Adaptery kompatybilności (CoreManager, QuizManager, SettingsManager, UIScaleManager)
├── modules/
│   ├── BitBomber/               # Git submodule → github.com/DaVideX12324/BitBomber
│   ├── quiz_rpg/                # Git submodule → github.com/DaVideX12324/CienMgly (Cień Mgły)
│   └── _template/               # Szablon startowy do tworzenia nowych modułów
├── scenes/                      # main.tscn + ui/ (menu główne, okno opcji, edytor pytań)
├── scripts/
│   ├── core/                    # module_host(+_api), module_transition (ekran przejścia), module_paths, input_binds (zmiana klawiszy), question_bank,
│   │                            #   session_results (historia wyników sesji)
│   ├── ui/                      # menu główne, okno opcji, edytor pytań
│   └── shared/quiz/             # wspólny kontroler panelu quizu
├── resources/                   # Zasoby hosta (quizzes/, fonts/, audio/, i18n/)
├── tools/                       # Narzędzia pomocnicze (check_i18n.py — kontrola kluczy tłumaczeń)
├── addons/object_catalog_sync/  # Wtyczka edytora (katalogi obiektów generatora Cienia Mgły) — nie jest zależnością gry
├── assets/                      # PRYWATNY submoduł (Artefakt-Wiedzy-assets): paczki Pixel Crawler, tilesety, ikony;
│                                #   nieużywane leżą w assets/_nieuzywane/ (z .gdignore, wyłączone z projektu i eksportu)
├── .claude/                     # Hook startowy Claude Code (przypomnienia o ważnych todo)
├── docs/
│   ├── README.md                # Indeks całej dokumentacji (statusy plików)
│   ├── wersjonowanie.md         # Numery wersji, etapy, plan wydań, changelogi
│   ├── module_contract.md       # Kontrakt modułu — co musi zawierać
│   ├── zakres_inzynierka.md     # Zakres pracy inżynierskiej i stan kodu względem niego
│   ├── ewaluacja/               # Scenariusze i formularze testów z użytkownikami (etap 1 i 2)
│   ├── game_design.md           # Projekt gry Cień Mgły (fabuła, strefy, mechaniki)
│   ├── plan_*.md                # Plany techniczne (generator ścieków / obiektów, przyspieszenie, zapis map)
│   ├── migration_plan.md        # Plan migracji istniejących modułów (historyczny)
│   ├── kontekst/                # Bieżący stan prac (handoffy sesji), opisy tematyczne
│   ├── prototypy/               # Narzędzia pomocnicze (makieta miasta)
│   ├── archiwum/                # Dzienniki sesji i przeniesione notatki
│   └── znane_problemy.md        # Do zrobienia, pułapki, rozwiązane
├── CHANGELOG.md                 # Zmiany platformy i wersje dołączonych modułów
└── project.godot                # Wersja Artefaktu: application/config/version
```

## Serwisy globalne

Nowe moduły **nie tworzą własnych** `QuizManager`, `SettingsManager`, `UIScaleManager`, `WindowManager` ani `SpriteLoader` — używają serwisów hosta (stare nazwy to tylko adaptery w `autoloads/compat/`). Wyjątek z czasów migracji: BitBomber ma własne autoloady `GameManager`, `RoundManager` i `SpriteLoader`, zarejestrowane w `project.godot` hosta.

| Serwis | Odpowiedzialność |
|--------|------------------|
| `QuizService` | Silnik quizów z namespace per moduł |
| `SettingsService` | Ustawienia globalne i per moduł |
| `I18nService` | Tłumaczenia PL / EN całego Artefaktu (host i moduły; klucze w `resources/i18n/`, kontrola: `tools/check_i18n.py`) |
| `AssetService` | Ładowanie assetów z katalogu modułu |
| `UIScaleService` | Skalowanie UI |
| `WindowService` | Tryb okna (okno / bez ramki / pełny ekran), rozdzielczość, monitor; zapamiętuje ręczny rozmiar i maksymalizację okna |
| `AudioService` | Muzyka i efekty dźwiękowe, głośności szyn |
| `CheatService` | Cheaty i menu deweloperskie (F1 / ~; F9–F11) — tylko w buildzie debugowym |
| `ModuleRegistry` | Wykrywanie i rejestracja modułów |
| `InputBinds` (klasa) | Zmienione klawisze akcji per moduł (zakładka „Sterowanie”) |
| `QuestionBank` (klasa) | Zestawy pytań: wbudowane i własne, import / eksport, wybór aktywnych (ładuje je `QuizService`) |
| `SessionResults` (klasa) | Historia wyników sesji modułów (`user://artefakt_wiedzy_sessions.json`); menu hosta pokazuje „Ostatnio: …” |

## Okno opcji

Wspólne okno opcji hosta (`scenes/ui/options_menu.tscn`) ma zakładki Ogólne (gra bez quizów, język), Ekran, Dźwięk, Motyw,
Pytania i Sterowanie. Zmiany ekranu wymagają potwierdzenia z odliczaniem, reszta zapisuje się od razu. Moduł może
wbudować treść okna we własne menu (`embed_in(kontener)`); zakładki Motyw i Sterowanie biorą dane z aktywnego modułu
(metody `get_ui_skins` / `get_ui_options` / `get_ui_bar_styles` i pola manifestu poniżej). W menu głównym zakładka
Sterowanie ma listę „Gra:” wyboru modułu, w menu modułu pokazuje tylko jego klawisze.

## Kontrakt modułu

Każdy moduł musi zawierać `module_manifest.json`:

```json
{
  "id": "bitbomber",
  "name": "BitBomber",
  "version": "0.9.0-beta",
  "entry_scene": "module_root.tscn"
}
```

Wymagane: `id`, `name`, `entry_scene`. Opcjonalne m.in. `description`, `version` (wg
[`docs/wersjonowanie.md`](docs/wersjonowanie.md), pokazywana na przycisku modułu w menu hosta), `quiz_path` (zestawy pytań modułu),
`asset_path` (assety dla `AssetService`).

Pola opcjonalne używane przez okno opcji:

- `controls` — sekcje zakładki „Sterowanie”: `[{label, actions: [akcje InputMap]}]` albo `{label, keys: "opis"}`;
- `action_labels` — nazwy akcji do wyświetlenia (`{akcja: nazwa}`);
- `control_options` — listy wyboru nad klawiszami (`[{key, label, default, options: [{id, name}]}]`), zapis
  w `SettingsService.set_module(<id>, key, …)` (np. domyślny chód / bieg w Cieniu Mgły).

Sesja: host może uruchomić moduł z ustawieniami (`ModuleHost.start_module(manifest, parent, session_config)`, w module
`host_api.get_session_config()`), a moduł oddaje wynik przez `host_api.finish_session(result)` — host zapisuje go
w `SessionResults` i emituje `module_session_finished`. Przykład: sekcja „Sesja z hosta” w README BitBombera.

Szczegóły kontraktu: [`docs/module_contract.md`](docs/module_contract.md)

## Konwencja ścieżek

Moduł nie zakłada, że jego korzeniem jest `res://` — w hoście leży w `res://modules/<id>/`, samodzielnie jest korzeniem
projektu. Dlatego ścieżek własnych plików nie piszemy na twardo, tylko przez mały pomocnik modułu (host nie ma jednego
wspólnego — każdy moduł dostarcza własny, ładowany przez `preload`, bez globalnego `class_name`):

```gdscript
# ŹLE
"res://modules/<id>/scenes/game.tscn"

# DOBRZE (szablon modułu)
const ModuleRuntime = preload("res://modules/<id>/scripts/module_runtime.gd")   # albo względny: preload("../scripts/…")
ModuleRuntime.path("scenes/game.tscn")
```

| Moduł | Pomocnik |
|-------|----------|
| `_template` | `scripts/module_runtime.gd` — `ModuleRuntime.path("…")` |
| BitBomber | `scripts/bb_runtime.gd` — `BBRuntime.path("…")` |
| Cień Mgły | `scripts/quiz_rpg_paths.gd` — `QuizRpgPaths.path("…")` (pliki modułu) i `QuizRpgPaths.host("res://…")` (zasoby hosta) |

Sceny odwołują się do zasobów po UID (`uid://`), więc przeżywają przeniesienie modułu; sam host ma tylko
`ModulePaths.join(root, relative)`. W trybie embedded można też używać API hosta:

```gdscript
host_api.start_quiz("informatyka")
host_api.asset_path("sprites/player.png")
```

## Dwa tryby działania modułu

Ten sam kod działa **w hoście** (ścieżki `res://modules/<id>/...`) i **samodzielnie** (repo modułu jako projekt Godota,
ścieżki `res://...`). Host wchodzi w moduł przez `entry_scene` z manifestu (zwykle `module_root.tscn`) i woła opcjonalne
`embedded_start(host_api, manifest)` / `embedded_stop()`.

Plik `project.godot` leży w repo modułu jako **`project.godot.off`** (szablon: `project.godot.off.example`) — aktywny
`project.godot` w podfolderze hosta sprawiłby, że Godot potraktuje go jako osobny projekt i pominie. Do pracy
samodzielnej kopiujesz moduł poza hosta i zmieniasz nazwę pliku na `project.godot`.

Cień Mgły ma do tego skrypt: kopie usług hosta leżą w `_host/` (z `.gdignore`), a samodzielny projekt tworzy
`modules/quiz_rpg/tools/make_standalone.sh` — opis w [`modules/quiz_rpg/README.md`](modules/quiz_rpg/README.md).
Kopie assetów (`_host/assets`) nie są w repo modułu (assety są prywatne) — generuje je `sync_host_copies.gd`
z lokalnego `assets/` hosta.

## Tworzenie nowego modułu

Nowe moduły startują z gotowego szablonu w [`modules/_template/`](modules/_template/README.md):

1. Skopiuj `modules/_template` do `modules/<TwojModul>`.
2. Podmień `TEMPLATE_MODULE_ID` i `Template Module` w plikach szablonu.
3. Rozwijaj gameplay lokalnie w folderze modułu, korzystając z `ModuleRuntime.path(...)` i globalnych serwisów hosta.
4. Docelowo każdy moduł to **osobne repo** podpięte jako submoduł (tak jak BitBomber i Cień Mgły):
   `git submodule add <url-repo> modules/<id>`.

Szablon zawiera manifest, cienki wrapper `module_root`, minimalną scenę startową i `START_PROMPT.md` do generowania nowej gry.

## Migracja istniejących modułów

Plan migracji (historyczny — zrealizowany na starcie): [`docs/migration_plan.md`](docs/migration_plan.md).
BitBomber i Cień Mgły są już modułami hosta; kolejne powstają według szablonu.

## Wymagania

- Godot 4.7 (GL Compatibility renderer) — projekt zapisany w 4.7; zapis starszym Godotem (np. 4.6) przestawia wersję projektu i format niektórych zasobów
- Git z obsługą submodułów (`git clone --recurse-submodules`)
- Brak zewnętrznych zależności (wtyczka `object_catalog_sync` to tylko narzędzie edytora)

## Dokumentacja

Indeks dokumentów ze statusami: [`docs/README.md`](docs/README.md). Do zrobienia i znane problemy:
[`docs/znane_problemy.md`](docs/znane_problemy.md); stan ostatniej sesji Cienia Mgły (handoff):
[`docs/kontekst/sesja_2026-10-24.md`](docs/kontekst/sesja_2026-10-24.md), BitBombera: `modules/BitBomber/docs/zadania.md`.
Wersje i plan wydań: [`docs/wersjonowanie.md`](docs/wersjonowanie.md), zmiany: [`CHANGELOG.md`](CHANGELOG.md).
