# Ściany i kafle jaskiń

User woli mapy **bez spłaszczania wybrzuszeń** (`enable_bulge_flatten` wyłączany w eksploratorze map);
poprawki poniżej działają w obu trybach. Domyślnie flaga jest nadal włączona (`caves.json` nie zmieniany).

## Zrobione (na main)

| Commit | Co |
|---|---|
| 48972a5 | Fasada płaskowyżu tuż za ścianą jaskini jest wchłaniana: górna kratka kolumny lica na górze modułu ściany (rim / najwyższa część lica, nie narożnik out) — `PlateauRenderer._on_wall_top`. Sąsiednia kolumna dostaje zakończenie lica. Seed 119 250×250, (48–51, 74–75). |
| 9c5b3d2, 07a981a | Małe przekrzywione filary zawsze 2H: `EdgeAnalyzer.small_wall_islands` / `_skewed` → `GenerationContext.force_2h_cells`; w klasyfikacji fasady `force_2h` jak w trybie płaskowyżu (bez łączników 2H↔3H). Warunki: wyspa wolnostojąca, bez brzegu mapy, pole ≤ 25, ≤ 6 kolumn, kolumny ≤ 5, **góry i doły kolumn w różnych rzędach**. Flagi `small_pillar_2h_max_area / _max_width / _max_height`. Filary o równej górze (2/3/3/3/2) i pasy skały zostają 3H. Wyszukiwanie na bajtach chodliwości, ~5 ms na 250×250. |
| 1e0e71b | `ShortLedgeRaisePass` (flaga `enable_ledge_fix`, P11a po spłaszczaniu): wąskie (1–2 kolumny) wypustki o grubości 2 obok kolumny 3H+ na tej samej stopie → kratka nad nimi staje się ścianą (3H), gdy zostają nad nią 2 kratki podłogi; inaczej wypustka usuwana. Małe wyspy (≤ 25) pomijane. Zmienia siatkę (parytet zaktualizowany). |

## Jak działa klasyfikacja stopni (dla przypomnienia)

`EdgeAnalyzer` przebieg 4 klasyfikuje każdą stopę fasady osobno, patrząc na sąsiadów:
2H gdy grubość 2 (albo wymuszone); łącznik CONNECTOR przy przejściu 2H↔3H; narożnik out; STEP
(`step_placer`): skok 1 i grubość 3–5 z kontynuacją po drugiej stronie → skos 2H, w innym razie
narożnik schodka 3H (3 kafle). Ostatni stopień przed płaskim końcem skosu nie dostaje (świadomie, na razie).

## Przydatne miejsca

- `scripts/generation/edge/edge_analyzer.gd` — klasyfikacja, `small_wall_islands`, `slope_2h_depth`.
- `scripts/generation/tiling/step_placer.gd`, `plateau_renderer.gd` (`_absorbed`, `_on_wall_top`).
- `scripts/generation/preprocess/` — przebiegi siatki; kolejność w `topology/interior_room_layout_generator.gd`.
