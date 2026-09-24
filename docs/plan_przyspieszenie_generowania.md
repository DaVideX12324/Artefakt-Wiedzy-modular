# Plan: przyspieszenie generowania map (jaskinie)

> Spisane 2026-09-24 na podstawie pomiarów (seed 184356, Godot 4.7.2 headless, jeden przebieg,
> wartości ~15 ms to w dużej części szum od `print`). Cel: gra nie zamarza podczas generowania,
> a mapa 250×250 z płaskowyżami generuje się w ~2 s zamiast ~5 s — bez zmiany wyniku (parytet).

## Stan realizacji (2026-09-25)

Zrobione — parytet (42 digesty: ściany + ścieżka z płaskowyżami) IDENTICAL po każdym kroku,
z jedną świadomą zmianą (2a-A). Pomiar: `bash modules/quiz_rpg/tests/run_gen_profile.sh`
(minimum z 3 przebiegów po rozgrzewce), sama generacja bez encji:

| Mapa | przed | po |
|---|---:|---:|
| 150×150 | ~1,1 s | 0,82 s |
| 150×150 + płaskowyże | ~1,8 s | 1,03 s |
| 250×250 | ~3,2 s | 2,25 s |
| 250×250 + płaskowyże | ~4,9 s | 2,75 s |

- **Krok 0** — `core/gen_progress.gd`: znaczniki `GenProgress.begin(&"etap")` / `sub(0..1)` w generatorze;
  ten sam mechanizm mierzy czasy etapów (profil) i napędza pasek ładowania. Parytet: linie `DIGESTP`
  (flagi z caves.json, warstwa Platforms, maska płaskowyżu), wzorzec `tests/parity_baseline.txt`.
- **Krok 1** — generowanie w tle: `ProceduralLevel.generate_level_async()` (domyślnie, `async_generation`),
  topologia + plan kafli w `WorkerThreadPool` (`CaveGenerator.plan_cave_tiles`), kafle porcjami
  (`PAINT_CHUNK`), encje porcjami (`ENTITY_CHUNK`), sygnał `generation_finished`; ekran ładowania
  `scripts/ui/generation_loading_overlay.gd`; `level_manager` czeka na koniec (gracz zamrożony),
  podgląd też czeka. `apply_cave_tiles` = `plan_cave_tiles` + `prepare_cave_layers` + `execute_cave_tiles`.
- **Krok 2a** — `PlateauRenderer` skanuje rozłączne okna skupisk płaskowyżów (`ctx.scan_rect`,
  współrzędne globalne). Świadoma zmiana (A): wariant A/B ściany bocznej płaskowyżu z hasha pozycji
  zamiast `tile_rng` w kolejności skanu (inaczej okna zmieniałyby losowanie). 1440 → ~360 ms.
- **Krok 2b** — `SolidFillPlacer`: cache wyniku resolvera po (zestaw kratki, roll);
  `TileResolver.own_tileset_id`. 620 → ~300 ms.
- **Krok 2c (część)** — `EdgeAnalyzer`: sąsiedztwo 3×3 z płaskiej tablicy bajtów (`_walkable_bytes`),
  dokładne warunki konieczne w przebiegach 5B (ściana boczna / narożnik wewnętrzny). 1320 → ~600 ms.
- **Krok 2d** — `TilePlacementExecutor` bez sortowania + `place_range` (porcje). 400 → ~200 ms.

Odkrycie: w pełnej ścieżce gry najdroższe są encje (~0,8–1 s przy 250×250) — `slime_tutorial.tscn`
wymaga odtworzenia przy każdej instancji („A node in the scene this one inherits from has been
removed or moved… re-save this scene”). Naprawa: otworzyć scenę w edytorze i zapisać.

Dalej (nie zrobione): krok 3 (płaska siatka w topologii — „smoothing” ~370 ms, „plateaus” ~250 ms),
przebieg 1 `EdgeAnalyzera` (obiekt `EdgeContext` na każdą kratkę, ~350 ms), krok 4 (C++/C#).

## Gdzie idzie czas

| Etap | 150×150 | 150×150 + płaskowyże | 250×250 | 250×250 + płaskowyże |
|---|---:|---:|---:|---:|
| **Topologia** (`CaveGen.generate`) | **~220 ms** | **~320 ms** | **~530 ms** | **~770 ms** |
| · pokoje + korytarze | 30 | 40 | 40 | 45 |
| · wygładzanie skrzyżowań + preprocess 1 | 120 | 120 | 350 | 350 |
| · naprawa spójności | 20 | 20 | 40 | 30 |
| · portale + preprocess 2 | 80 | 80 | 140 | 140 |
| · `PlateauPass` | – | 100 | – | 230 |
| **Kafle** (`apply_cave_tiles`) | **~900 ms** | **~1470 ms** | **~2660 ms** | **~4130 ms** |
| · `EdgeAnalyzer.analyze` | 430 | 450 | 1240 | 1230 |
| · `SolidFillPlacer` | 230 | 230 | 610 | 620 |
| · `FloorPlacer` | 60 | 70 | 160 | 160 |
| · pozostałe placery (teren, fasady, boki, rimy, narożniki) | ~70 | ~70 | ~200 | ~200 |
| · **`PlateauPlacer`** (drugi pipeline ścian) | – | **545** | – | **1440** |
| · wykonawcy `set_cell` (Floor, teren, Walls, Platforms) | 120 | 130 | 360 | 360 |
| · sprzątanie po planach (zwalnianie obiektów) | 65 | 70 | 165 | 165 |
| **Razem** | **~1,1 s** | **~1,8 s** | **~3,2 s** | **~4,9 s** |

Wnioski:
- ~80% czasu to kafle, nie topologia. Trzy największe pozycje: `PlateauPlacer`, `EdgeAnalyzer`, `SolidFillPlacer`.
- `PlateauPlacer` (przez `PlateauRenderer`) buduje syntetyczny grid **całej mapy** i puszcza po nim cały
  `EdgeAnalyzer` + placery, choć płaskowyże zajmują ułamek mapy.
- `EdgeAnalyzer` tworzy obiekt `EdgeContext` z sąsiedztwem 3×3 dla **każdej** komórki (62,5 tys. przy
  250×250), także dla głębokiej skały, której nikt potem nie czyta.
- `SolidFillPlacer` woła `TileResolver.resolve_module_parts` i tworzy `TilePlacement` osobno dla
  każdej kratki skały — wynik zależy tylko od (zestaw, roll 0..99), więc da się go zapamiętać.
- Mikrotest: sąsiedzi 4-kierunkowi na 250×250 ×20 — `Dictionary[Vector2i]` 472 ms,
  `PackedByteArray` 126 ms (~3,7× szybciej). Płaska siatka pomoże, ale sama nie da „kilkunastu ms”:
  koszt siedzi w obiektach na kratkę i w podwójnym pipeline, a GDScript ma swój narzut na operację.

## Zabezpieczenie (przed każdym krokiem i po nim)

- `bash modules/quiz_rpg/tests/run_plateau_suite.sh` — parytet ścian (21 digestów vs
  `tests/parity_baseline.txt`) + e2e płaskowyżów + golden + runtime + podgląd. **Każda optymalizacja
  musi dać IDENTICAL i ALL OK** — to refaktory wydajności, nie zmiany wyniku.
- Parytet płaskowyżów: dopisać do `diag_parity_digest` digest warstwy Platforms i maski płaskowyżu
  (dziś parytet liczony jest z wyłączonymi płaskowyżami) — bez tego krok 2a nie ma siatki bezpieczeństwa.
- Pomiar: `tests/diag_gen_timing.gd` (całość) + profiler z kroku 0 (etapy).

## Krok 0 — stały profiler (~30 min)

- `core/gen_profiler.gd`: `GenProfiler.begin(&"etap")` / `end()`, sumy w słowniku, **bez `print` w trakcie**
  (print zawyża pomiar o ~15 ms), wypisanie tabeli na końcu. Wyłączony = pojedynczy `if` (flaga
  `GenerationFlags.profile` albo env `GEN_PROFILE`).
- Wpiąć w etapy z tabeli powyżej; `diag_gen_profile.gd` wypisuje tabelę dla 4 konfiguracji
  (150/250 × z płaskowyżami / bez) — to jest pomiar bazowy do porównań.

## Krok 1 — generowanie w tle + ekran ładowania (największa różnica dla gracza)

Nie skraca czasu, ale gra przestaje zamarzać na 1–5 s.
- Topologia + `EdgeAnalyzer` + `TilePlacementPlanner` to czyste dane → do `WorkerThreadPool`
  (`add_task`). Sprawdzić bezpieczeństwo wątków: czy resolver/profil tylko **czytają** zasoby
  (`MapTileProfile`, `TileSet`) — zapis do zasobów/węzłów z wątku = błąd.
- Na głównym wątku zostają wykonawcy (`set_cell` na `TileMapLayer` należących do drzewa sceny) —
  rozłożyć na klatki (np. N wierszy na klatkę) z paskiem postępu; to ~360 ms przy 250×250.
- `apply_cave_tiles` rozdzielić na `plan_cave_tiles(...) -> plans` (wątek) i `execute_cave_tiles(layers, plans)`
  (główny wątek) — obecne API zostaje jako wrapper (testy/parytet bez zmian).
- `procedural_level.generate_level()` → wersja asynchroniczna z sygnałem `level_ready` + prosta scena
  ładowania (etapy: „Kopanie jaskini…”, „Układanie ścian…”, „Płaskowyże…”). Podgląd
  (`map_generator_preview`) może zostać synchroniczny albo dostać ten sam mechanizm.
- Ryzyko: RNG — każdy wątek ma swój `RandomNumberGenerator` z seeda (już tak jest), globalne `seed()`
  w `apply_cave_tiles` przenieść do części głównej albo usunąć, jeśli nic go już nie używa
  (własny `TerrainAutotileSolver` zamiast `set_cells_terrain_connect`).

## Krok 2 — szybkie zyski w gorących miejscach (parytet 1:1)

**2a. `PlateauRenderer` w oknach (szac. −1,0…1,3 s przy 250×250 z płaskowyżami)**
- Zamiast gridu całej mapy: osobne okno (bbox + `WINDOW_MARGIN`) na każdy komponent / skupisko
  płaskowyżów, grid syntetyczny we **współrzędnych lokalnych** (origin okna = 0,0), analiza i placery
  na małym `sctx.width/height`, na końcu przesunięcie placementów o origin okna.
- Poza oknem i tak jest bryła (`WALL`), więc wynik ma być identyczny — sprawdza to nowy digest Platforms.
- Uwaga na sąsiadujące okna: nakładające się okna scalać w jedno (inaczej krawędź policzona podwójnie).

**2b. `SolidFillPlacer` (szac. −0,3…0,4 s)**
- Pamięć podręczna `resolve_module_parts` po kluczu (tileset_id z pola, roll) — 100 rolli × kilka zestawów
  zamiast 40 tys. wywołań.
- Obramowanie −4..+4 poza mapą: jeden gotowy `TilePlacement`-wzorzec zamiast obiektu na kratkę
  (albo wypełnienie bezpośrednio w wykonawcy).

**2c. `EdgeAnalyzer` (szac. −0,5…0,8 s)**
- Nie tworzyć `EdgeContext` dla kratek, których całe 3×3 to lita skała (głęboki void) — sprawdzić
  wszystkich konsumentów `analysis.edges` (placery, `SolidFillPlacer` dostaje `edges`!), czy nie
  czytają `edges[pos]` bez `get()`. Zamiast tego `edges.get(pos)` → null = void.
- `_populate_neighborhood` na płaskiej siatce (patrz krok 3) zamiast 9× `grid.get(Vector2i)`.

**2d. Wykonawcy (szac. −0,1 s)** — `TilePlacementExecutor` sortuje wszystkie pozycje przed `set_cell`;
kolejność wstawiania nie zmienia wyniku warstwy → sortowanie zbędne (zweryfikować digestem).

## Krok 3 — płaska siatka (`PackedByteArray`) — stopniowo

- `core/grid_view.gd`: `w, h, cells: PackedByteArray`, `idx(x, y) = y * w + x`, `at(x, y)`,
  `walkable(x, y)` (poza mapą = VOID), budowany **raz** z `ctx.grid` po topologii (`ctx.view`).
- Etap kafli tylko czyta grid → tu migracja jest bezpieczna: `EdgeAnalyzer`, placery, `PlateauRenderer`,
  `PlateauPass` (maski `mask/blocked/top` też jako bajty 0/1).
- Topologię (passy preprocess, korytarze, spójność) migrować później, pass po passie, z parytetem po
  każdym — `Dictionary` zostaje źródłem prawdy, dopóki wszystko nie przejdzie.
- Szac. dodatkowo 1,5–2× na etapach czytających siatkę.

## Krok 4 — tylko jeśli nadal za wolno

- `EdgeAnalyzer` + `SolidFill` w C++ (GDExtension) albo C# — tam „kilkanaście ms” jest realne.
- Wielowątkowość w samym etapie kafli (np. placery na pasach wierszy) — dopiero po kroku 3; passy są
  od siebie zależne, zysk mniejszy niż z kroków 2–3.

## Kolejność na jutro

1. Krok 0 (profiler) + digest Platforms w parytecie → nowy baseline.
2. Krok 2a (`PlateauRenderer` w oknach) — największy pojedynczy zysk, mały zakres zmian.
3. Krok 2b (`SolidFill` cache) i 2d (sortowanie) — małe, szybkie.
4. Krok 1 (tło + ekran ładowania) — jeśli zostanie czas; najważniejszy dla gracza.
5. Krok 2c / 3 — osobna sesja (największy zakres, dotyka parytetowego `EdgeAnalyzera`).

Oczekiwany efekt po 1–3: 250×250 z płaskowyżami ~4,9 s → ~2,5 s; po kroku 1 bez zamrożenia gry.
