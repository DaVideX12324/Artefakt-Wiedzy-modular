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
(`step_placer`) → skos 2H (`WALL_2H_SLOPE`, `StepPlacer.place_slope`) albo narożnik schodka 3H (3 kafle).

**Reguła skosu 2H (od 2026-10-03, decyzja usera)** — `EdgeAnalyzer.slope_2h_step` / `slope_2h_end_side` →
`slope_2h_run`: skos dostaje cały ukośny ciąg kolumn schodzących po 1 rząd (fasada / schodek 3H), jeśli
któraś kolumna ciągu ma w (x, y-3) narożnik wewnętrzny w kierunku skosu — NORTH_WEST dla skosu schodzącego
w lewo, NORTH_EAST w prawo. Dotyczy schodka (wyższy sąsiad z jednej strony) i górnego końca skosu (płaska
kolumna z sąsiadem o 1 niżej z dokładnie jednej strony); szczyt (niżej z obu stron) zostaje 3H. Bez warunku
grubości. Do tego `SlopeThicknessPass` (flaga `enable_slope_thickness`, P11a po `DiagonalTouchPass`): stopa w
ukośnym ciągu >= 3 stóp z dokładnie 3 kratkami ściany dostaje ścianę w (x, y-4), gdy nad nią są 2 kratki
podłogi i nie powstaje „ząb” ponad sąsiada po wyższej stronie. Przykłady: seed 103107 160×160 (82–83 i 89–90,
113–114) — pojedyncze schodki na poziomej fasadzie → 3H; seed 119 160×160 (69–72, 56–59) — cały klin skosem
(prepass pogrubił 71–72); seed 118945 160×160 (15–17, 52–54) — skos mimo grubości 6.

**Dawna reguła (usunięta 2026-10-03 — gdyby trafił się edge case, w którym była lepsza)**: skos 2H, gdy
grubość ściany 3–5 (`slope_2h_depth`) i schodek o 1 z przynajmniej jednej strony (skok 1 do wyższego sąsiada
albo sąsiad naprzeciw o 1 niżej — `slope_2h_steps`); górny koniec: płaska kolumna o grubości 3–5 z sąsiadem o 1
niżej z dokładnie jednej strony. Bez narożnika i bez ciągu, więc łapała też pojedyncze schodki (zgłoszenie
103107) i odrzucała grube ukosy (118945). Ostatnia wersja z nią: CienMgly `cce3314` — za flagą
`slope_2h_corner_rule = false` (razem z `enable_slope_thickness = false` = stan sprzed zmian co do kafla).
Porównania renderów: `tests/render_area.gd` (lokalnie).

## Nisze-przejścia (2026-10-03)

- Nisza (`tiling/niche_placer.gd`) = 2 kolumny × rzędy 0..-2 (BASE / MID / TOP) + korona w rzędzie -3.
  Gdy nad którąś kolumną ściana ma głębokość <= 3 (`EdgeAnalyzer.measure_solid_depth`), rząd -3 to szczyt
  ściany: nisza jest typu OUT, **bez korony** (szczyt kładzie RimPlacer, kolumna głębsza dostaje zwykłą koronę
  lica 3H — `FacadePlacer.place_3h_crown`), nigdy sekretna, z szansą `passage_niche_spawn_chance`.
- Kratki przejścia (`ctx.passage_cells`: OUT obu kolumn + szczyt nad kolumną o głębokości 3) oznacza
  `NichePlacer.mark_passages` po wszystkich placerach; `TilePlacementExecutor` wstawia tam alternatywę
  `NichePlacer.PASSAGE_ALT` (1), jeśli TileSet ją ma — inne kolizje, ta sama grafika. W `caves.tres` są
  alternatywy kafli OUT (skała i korzenie): TOP z wąskim paskiem z zewnątrz, MID / BASE obcięte do zewnętrznej
  połowy. Wariant RIM (alternatywa 1) robi user.
- Test: `tests/diag_passage_niche.gd` (`CASES="seed,size;…"`) — kratki z alternatywą i jak wysoko dochodzi
  kapsuła gracza idąca na północ.

## Siatka po preprocessingu

- `DiagonalTouchPass` (koniec P11a, po `ShortLedgeRaisePass`): skośny styk podłóg przez ścianę
  (100/000/001, 1 = podłoga) → górny narożnik zasypany. Ta sama reguła jest w `WallThicknessPass`
  (P5–P7), ale podniesienie wypustki potrafi styk odtworzyć (seed 119 160×160, (68, 58)).

## Przydatne miejsca

- `scripts/generation/edge/edge_analyzer.gd` — klasyfikacja, `small_wall_islands`, `slope_2h_depth`.
- `scripts/generation/tiling/step_placer.gd`, `plateau_renderer.gd` (`_absorbed`, `_on_wall_top`).
- `scripts/generation/preprocess/` — przebiegi siatki; kolejność w `topology/interior_room_layout_generator.gd`.
