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

Test: `tests/diag_object_access.gd` (w zestawie `run_plateau_suite.sh`). Parytet: zmieniło się tylko
pole `spawns` (spawny zsuwane z przeszkód) — baseline zaktualizowany.
