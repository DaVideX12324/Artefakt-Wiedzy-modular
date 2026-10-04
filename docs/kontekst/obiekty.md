# Obiekty (generator obiektów)

Pliki: `scripts/generation/objects/` (planer, katalog, bake, realizer), katalog jaskiń
`resources/maps/config/objects_caves.json`. Plan faz: `docs/plan_generator_obiektow.md`.

## Poprawki z 2026-09-29 (commit 8e0248a)

1. **Duże obiekty nie zakrywają ścian**
   - `ObjectBake.visual` — obrys sprite'ów względem origin sceny; `ObjectDef.visual_rect` — obrys
     względem punktu obiektu (sceny: suma wariantów, origin pół kratki nad punktem; kafle: `size`).
   - `ObjectDef.is_large()`: podstawa > 1 kratka albo grafika > 1,5 kratki (24 px) w szerokości/wysokości.
     W katalogu jaskiń: duże/średnie/małe fioletowe grzyby, koralowce czerwone, stalagmity, glow_plant.
   - `ObjectPlanner._visual_on_wall`: żadna kratka pod obrysem (pomniejszonym o 3 px, obie strony przy
     `flip_h`) nie może być ścianą ani leżeć poza mapą. Sprawdzane w `_try_place` i `_try_free`.
2. **Skrzynie mają wolne wejście**
   - Skrzynie (INTERACTIVE, priorytet 500) stawiane są przed przeszkodami.
   - `ObjectPlanner._reserve_access` (z `_finish`): BFS od wolnych sąsiadów skrzyni (bez barier
     i obiektów) do najbliższej kratki RESERVED / wejścia; droga poszerzona o 1 → RESERVED na kratkach
     niezajętych przez obiekty (katalogi, gdzie przeszkody mają wyższy priorytet niż skrzynia, nie
     dostają przejścia pod już postawionym obiektem). Przeszkody z `keep_paths`
     nie zachodzą na RESERVED nawet częściowo (`_shape_on_reserved`); wcześniej zajętość liczona
     środkami kratek przepuszczała kamień w połowie wejścia do niszy.
   - „Nisza” = tag kontekstu (podłoga ze ścianami z 3 stron), nie dekoracyjne nisze kafli ścian.

Wynik na 21 mapach (bez spłaszczania): duże obiekty na ścianie 2421 → 0, zasłonięte skrzynie 7 → 0.
Dużych obiektów ~20% mniej (7919 zamiast 10029) — jeśli za pusto, podnieść gęstość w katalogu.
Nie oglądane jeszcze w grze.

## Obiekty na licu ściany i katalog ścieków (2026-10-04, gałąź `sewer-tileset`)

- `"mount": "facade"` w katalogu -> `ObjectCatalog.wall_defs` (planer podłogi ich nie widzi), stawia je
  `objects/wall_decor_planner.gd` po `ObjectPlanner` (dopisuje do tego samego `ObjectPlan`). Kotwica = dolna
  kratka lica nad podłogą (z `facade_base_on_wall`; bez niej pierwsza kratka podłogi — nieużywane w
  jaskiniach). Wymaga ciągłego lica (ściana >= 3) w kolumnach obiektu i 1 kolumnie po bokach, poza
  portalami; tagi `over_floor` / `over_canal`; `density` (na 100 kolumn lica) / `count`, `spacing`, `size`
  (szerokość w kratkach). Bez kolizji i zajętości. Realizer sortuje je tuż nad podłogą pod licem
  (`WALL_SORT_DROP`). Origin sceny = środek kratki cokołu.
- `pebble_large` przeniesiony do sprite'ów bez kolizji (main 4480fff, baseline parytetu zaktualizowany).
- Katalog ścieków `resources/maps/config/objects_sewer.json` + sceny `scenes/objects/sewer/{static,sprites,wall}`
  (wycięte skryptem z `Props.png` / `Tiles.png` ścieków; dół grafiki przy podstawie, kolizja przy podstawie).
  Render z obiektami: `tests/render_sewer.gd` (rysuje wypieczone sceny; `RS_CROP=x,y,w,h` = zbliżenie ×2).

Zostało w planie generatora: F5 (niszczalne beczki, dźwignie, leniwe sceny), podgląd (nakładka zajętości /
przejść, statystyki), obejrzenie kafli wielokratkowych na `Props`. Dla ścieków: barierki przy kanałach,
mech (teren foliage), filary w licu, skrzynia w grafice ścieków.

Test: `tests/diag_object_access.gd` (w zestawie `run_plateau_suite.sh`). Parytet: zmieniło się tylko
pole `spawns` (spawny zsuwane z przeszkód) — baseline zaktualizowany.
