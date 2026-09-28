# Zasady pracy

- **Commit po każdej zakończonej i sprawdzonej zmianie**, osobno. **Bez pusha.**
- Stopka commita:
  ```
  Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
  ```
- **Nie commitować** plików, które user zmienia w edytorze, chyba że wprost poprosi:
  `modules/quiz_rpg/resources/maps/caves.tres`, `assets/textures/tilesets/tutorial_area.tres`,
  `modules/quiz_rpg/scenes/maps/tutorial_area.tscn`, sceny/zasoby wrogów, `project.godot`, grafiki
  w `loading_screens/<mapa>/` (Gemini). Przed commitem zawsze `git status` i dodawać pliki po nazwie.
- Kafle jaskini są już z `environments/cave` (archiwum `_versions_archive/cave_v1` usunięte, c205e80);
  stare ścieżki `cave_v1` zostały tylko w dokumentach md.
- Wrogowie: sceny dziedziczą po `scenes/enemies/enemy.tscn` — zmiany wspólne tylko w bazie.
- Obiekt z kolizją: `StaticBody2D` jako korzeń sceny.
- User pisze po polsku, odpowiadać po polsku.

## Testy (headless)

```
G="F:/Programy/Godot/Godot_v4.7.2-stable_win64_console.exe"
"$G" --headless --path . --import                      # po dodaniu nowego class_name
"$G" --headless --path . -s res://modules/quiz_rpg/tests/<skrypt>.gd
bash modules/quiz_rpg/tests/run_plateau_suite.sh 10    # pełny zestaw (~110 s)
```

- `modules/quiz_rpg/tests/` jest w `.gitignore` (żyje tylko lokalnie).
- Zestaw: golden płaskowyżów, runtime, maski, wrogowie, nawigacja, obiekty, `diag_object_access`,
  parytet (`tests/parity_baseline.txt`) i e2e `diag_plateaus`.
- **Parytet**: po zamierzonej zmianie siatki/kafli zaktualizować baseline (`cat parity_*.log | grep "^DIGEST"
  | sort` z katalogu logów zestawu). Baseline z 2026-09-29 odpowiada stanowi po c205e80.
- `diag_enemy_chase` (część tutorial_area) jest losowy — pojedynczy FAIL to nie regresja.
