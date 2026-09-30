# Ściany i kafle jaskiń

Spłaszczanie wybrzuszeń (`ShortBulgeFlattenPass`) **usunięte** 2026-09-29 — user woli naturalne kształty
ścian; kafle dla nich poprawiają reguły poniżej.

## Zrobione (na main)

| Commit | Co |
|---|---|
| 48972a5 | Fasada płaskowyżu tuż za ścianą jaskini jest wchłaniana: górna kratka kolumny lica na górze modułu ściany (rim / najwyższa część lica, nie narożnik out) — `PlateauRenderer._on_wall_top`. Sąsiednia kolumna dostaje zakończenie lica. Seed 119 250×250, (48–51, 74–75). |
| 9c5b3d2, 07a981a | Małe przekrzywione filary zawsze 2H: `EdgeAnalyzer.small_wall_islands` / `_skewed` → `GenerationContext.force_2h_cells`; w klasyfikacji fasady `force_2h` jak w trybie płaskowyżu (bez łączników 2H↔3H). Warunki: wyspa wolnostojąca, bez brzegu mapy, pole ≤ 25, ≤ 6 kolumn, kolumny ≤ 5, **góry i doły kolumn w różnych rzędach**. Flagi `small_pillar_2h_max_area / _max_width / _max_height`. Filary o równej górze (2/3/3/3/2) i pasy skały zostają 3H. Wyszukiwanie na bajtach chodliwości, ~5 ms na 250×250. |
| 1e0e71b | `ShortLedgeRaisePass` (flaga `enable_ledge_fix`, P11a po czyszczeniu siatki): wąskie (1–2 kolumny) wypustki o grubości 2 obok kolumny 3H+ na tej samej stopie → kratka nad nimi staje się ścianą (3H), gdy zostają nad nią 2 kratki podłogi; inaczej wypustka usuwana. Małe wyspy (≤ 25) pomijane. Zmienia siatkę (parytet zaktualizowany). |

## Jak działa klasyfikacja stopni (dla przypomnienia)

`EdgeAnalyzer` przebieg 4 klasyfikuje każdą stopę fasady osobno, patrząc na sąsiadów:
2H gdy grubość 2 (albo wymuszone); łącznik CONNECTOR przy przejściu 2H↔3H; narożnik out; STEP
(`step_placer`): grubość 3–5 i schodek o 1 z przynajmniej jednej strony (skok 1 do wyższego sąsiada
albo sąsiad naprzeciw o 1 niżej — `EdgeAnalyzer.slope_2h_steps`, od 2026-09-30) → skos 2H, w innym razie
narożnik schodka 3H (3 kafle). Płaska kolumna fasady (grubość 3–5) z sąsiadem o 1 niżej z dokładnie jednej
strony to górny koniec skosu — też kafel skosu 2H (`EdgeAnalyzer.slope_2h_end_side`, `StepPlacer.place_slope`);
szczyt (niżej z obu stron) zostaje 3H.

## Siatka po preprocessingu

- `DiagonalTouchPass` (koniec P11a, po `ShortLedgeRaisePass`): skośny styk podłóg przez ścianę
  (100/000/001, 1 = podłoga) → górny narożnik zasypany. Ta sama reguła jest w `WallThicknessPass`
  (P5–P7), ale podniesienie wypustki potrafi styk odtworzyć (seed 119 160×160, (68, 58)).

## Przydatne miejsca

- `scripts/generation/edge/edge_analyzer.gd` — klasyfikacja, `small_wall_islands`, `slope_2h_depth`.
- `scripts/generation/tiling/step_placer.gd`, `plateau_renderer.gd` (`_absorbed`, `_on_wall_top`).
- `scripts/generation/preprocess/` — przebiegi siatki; kolejność w `topology/interior_room_layout_generator.gd`.
