# Miasto — logika (2026-10-22)

Decyzje usera 2026-10-22: trasa **jaskinia → miasto → ścieki**; miastem w grze jest `modules/quiz_rpg/scenes/maps/levels/town.tscn`
(układ user przenosi z desert town). LDtk odpada. Kod nie zależy od układu miasta — wszystko to klocki do ustawienia w edytorze.

## Klocki
| Co | Plik | Jak użyć |
|---|---|---|
| Mapa ręczna w trasie | `scripts/maps/handmade_level.gd` (`QuizRpgHandmadeLevel`) | skrypt korzenia mapy; Inspector: `next/previous_level_path`, `next/previous_spawn_name`, `entry_edge` / `exit_edge` (0 N, 1 E, 2 S, 3 W), `in_route` (wnętrza: false), `music_track`. Przejścia: Area2D `enter_next_level` / `enter_previous_level` (metadana `portal_use_key` = pod E). Sąsiednie mapy liczą się w tle (MapPrefetch). |
| Drzwi do wnętrza / wyjście | `scenes/objects/level_door.tscn` (`QuizRpgLevelDoor`) | `target_level`, `target_spawn` (marker w Spawns celu), `prompt_key` (`prompt.enter` / `prompt.exit`), `required_flag` (zamknięte bez flagi → „Zamknięte”). Przejście pod E. |
| Wnętrze budynku | `scenes/maps/interiors/interior_template.tscn` | duplikować; warstwy Floor / Walls (tileset free packa), `Npcs`, `Spawns/Spawn`, `ExitDoor` (ustawić `target_spawn` = marker przed drzwiami w mieście). Poza trasą map, muzyka miasta. |
| Świat wg flag | `scripts/world/flag_gate.gd` (`QuizRpgFlagGate`) | dziecko obiektu (Add Child Node): `show_flag` (widoczny dopiero z flagą), `hide_flag` (znika z flagą). Ukryty = wyłączony (bez kolizji, rozmowy). Reaguje od razu (`LevelStateManager.story_flag_changed`). |

## Trasa i kierunki (MapLinks)
- Jaskinia: `next_level_path` = miasto, `next_spawn_name` = `Cave-Town`, `next_entry_edge` = S → jaskinia zawsze wychodzi na **N**
  (nowe pole `ProceduralLevel.next_entry_edge`: wyjście po przeciwnej stronie stałego wejścia następnej mapy).
- Miasto: wejście S (`Cave-Town`, obszar `enter_previous_level` na dole), wyjście N (`Sewer-Town`, `enter_next_level` u góry);
  na siatce świata pole na północ od jaskini.
- Ścieki: `previous_level_path` = miasto, `previous_spawn_name` = `Sewer-Town`; wejście od **S**.
- Stare zapisy: jaskinia z innym wyjściem wygeneruje się na nowo (inny klucz mapy) — tylko zapisy deweloperskie.
- Obszary przejść w `town.tscn` stoją wstępnie przy końcach ścieżki (S: 869, 1260; N: 551, 150) — do przesunięcia w edytorze.

## Test
`tests/check_town_logic.gd` (20 sprawdzeń): kierunki trasy, przejścia i powroty przy markerach, drzwi (zamknięte / otwarte),
wnętrze poza trasą, bramka flag.

## Zostało (logika)
- **Decyzja usera 2026-10-22: wnętrza budynków na razie odpadają (za duża robota) — NPC stoją przed domami.** Klocki drzwi / szablonu wnętrza zostają na później.
- ~~Zadania NPC~~ — zrobione 2026-10-22 (`QuizRpgNpcQuest`, dziennik w menu pauzy; opis w `kontekst/npc.md` „Zadania”).
- Prawdziwe flagi etapów sklepów / kowala (dziś zastępcze `boss:*`), punkt zapisu przed ściekami (opcjonalnie).
