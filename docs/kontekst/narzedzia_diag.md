# Skrypty diagnostyczne (`modules/quiz_rpg/tests/`, poza gitem)

Uruchamianie: `"$G" --headless --path . -s res://modules/quiz_rpg/tests/<plik>.gd` (render PNG działa
headless; zrzut z renderowaniem UI — bez `--headless`, z `--resolution 1920x1080`).

| Skrypt | Do czego | Zmienne |
|---|---|---|
| `render_area.gd` | wycinek mapy z kaflami → PNG + `_walls`, `_plat`, `_grid` (wysokości) | `AREA="seed,size,x,y,w,h"`, `OUT`, `SCALE`, `LEDGE=0`, `GF=1` + `ROOMS` (flagi jak w parytecie) |
| `dump_area.gd` | ta sama okolica jako tekst: wysokości, kategorie kafli Walls / Platforms | `AREA` |
| `plat_digest.gd` | kafle Platforms dla zestawu seedów → plik (porównanie przed/po przez `git stash`) | `DIGEST_OUT`, `CASES="seed,size;..."` |
| `diag_small_pillars.gd` | małe wyspy ściany: wysokości, góry/doły kolumn | — |
| `diag_pillar_rule.gd` | które wyspy łapie reguła wymuszonego 2H (stara vs nowa) | — |
| `diag_pillar_shape.gd` | klasyfikacja EdgeAnalyzera dla ręcznego kształtu | `SHAPE="###../.###"`, `FORCE` |
| `diag_ledges.gd` | co zmienia `ShortLedgeRaisePass` na zestawie map | — |
| `diag_object_access.gd` | duże obiekty vs ściany, wolne wejście skrzyń (w zestawie) | — |
| `diag_visual_sizes.gd` | obrysy grafiki obiektów z katalogu | — |
| `time_islands.gd` | czas wyszukiwania wysp | — |
| `diag_loading_screen*.gd`, `shot_loading_*.gd` | ekran ładowania (test, zrzuty) | `SHOT_OUT`, `LOC` |
| `diag_detection_radius.gd` | własny kształt DetectionArea na wroga | — |

Porównanie przed/po: `git stash push -q -- <pliki>` → uruchom → `git stash pop -q` (uważać, żeby nie
stashować zmian usera — zawsze podawać ścieżki).
