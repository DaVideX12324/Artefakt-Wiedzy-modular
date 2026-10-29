# Universal Interior Generator — podsumowanie refaktoru

> Status: **W TOKU** (2026-10-29). Pełna dokumentacja: [`archiwum/universal_interior_generator_refactor_pelny.md`](archiwum/universal_interior_generator_refactor_pelny.md).  
> Dodatkowe plany: [`plan_generator_sciekow.md`](plan_generator_sciekow.md), [`plan_generator_obiektow.md`](plan_generator_obiektow.md).

---

## Architektura etapowa — pipeline generatora

```
GenerationContext
      │
      ▼
TopologyGenerator          ← pokoje, korytarze, wejścia/wyjścia
      │
      ▼
EdgeAnalyzer               ← 7 przebiegów; wynik: EdgeAnalysisResult
      │
      ▼
TilePlacementPlanner       ← orkiestrator placer-ów
      │
      ├── SolidFillPlacer
      ├── FloorPlacer
      ├── FacadePhasePlanner → FacadePlacer / StepPlacer / OutCornerPlacer / ConnectorPlacer
      ├── SideWallPlacer
      ├── RimPlacer
      ├── CornerPlacer
      └── PortalClearPlacer
      │
      ▼
TerrainPaintExecutor       ← autotile podłogi, terenu, masek
      │
      ▼
ObjectPlanner              ← katalogi JSON → spawny wrogów / skrzyń / dekoracji
```

---

## Stan faz (sprawdzony w kodzie 2026-10-29)

| Etap | Opis | Stan |
|------|------|------|
| 0 | Stabilizacja, infrastruktura testów | ✅ ZROBIONE |
| 1 | Snapshoty bazowe (`run_tests.gd`, `dump_plan.gd`) | ✅ ZROBIONE |
| 2 | Wydzielenie `core/` (`GenerationFlags`, `GridUtils`, `GenerationContext`, `TilePlacementPlan`, `PlacementPriority`, `TerrainPaintPlan`, `SeededNoise`) | ✅ ZROBIONE |
| 3 | `EdgeAnalyzer` jako osobna klasa | ✅ ZROBIONE |
| 4 | Placery (po jednym pliku na kafelek: `RimPlacer`, `FacadePlacer`, `CornerPlacer` itd.) | ✅ ZROBIONE |
| 5 | `TilePlacementPlanner` jako orkiestrator | ✅ ZROBIONE |
| 6 | Segmentacja rimów, orientacje (`EdgeContext.orientation`), motywy `rock`/`roots` | ✅ ZROBIONE |
| 7 | Profile terenu JSON (`caves.json`, `sewer.json`) + `GeneratorBehaviourConfig` | ✅ ZROBIONE |
| 8 | `CaveGenerator` jako wrapper ≤ 120 linii; `TerrainGenerator` jako fasada | ⬜ ZOSTAŁO |
| 9 | Jakość: `SpawnPlanner` BFS, optymalizacja `near_floor`, usunięcie aliasów | ⬜ ZOSTAŁO |
| 10 | Filary (`PillarDetector`/`PillarPlacer`), schodki 2H, zakończenia rimu roots | ⬜ ZOSTAŁO |
| 11 | Zamek i biblioteka (`castle_default.json`, `library_default.json`) | ⬜ ZOSTAŁO |
| 12 | `ObjectGenerator` jako osobny system (strategie, executor) | ⬜ ZOSTAŁO (częściowo: `ObjectPlanner`, `ObjectRealizer` istnieją) |

---

## Kluczowe typy (aktualne)

| Typ | Plik | Rola |
|-----|------|------|
| `EdgeContext` | `edge_context.gd` | Jeden obiekt na komórkę: `edge_kind`, `orientation`, `height`, `segment`, `theme` |
| `EdgeAnalysisResult` | `edge_analysis_result.gd` | `{ edges: Dict[Vector2i→EdgeContext], facade_cols, sorted_xs, facade_segments }` |
| `GenerationContext` | `generation_context.gd` | Wejście dla analizatora i placer-ów: `grid`, `width`, `height`, `seed_value`, `flags`, strefy portali |
| `GenerationResult` | `map_generator_base.gd` | Wyjście `generate()`: `entrance_zone`, `exit_zone`, `entrance_pos`, `exit_pos`, `seed_used`, `flags_used` |
| `TilePlacementPlan` | `tile_placement_plan.gd` | Deterministyczny plan kafli; `compute_digest()` do testów parytetu |
| `GenerationFlags` | `generation_flags.gd` | Flagi biomu (kształt pokoi, styl ścian, szanse niszy, tryb wejścia itd.) |

---

## Testy

- **`run_tests.gd`** — runner headless; determinizm + 6 snapshotów. Wszystkie PASS (7/7).
- **`dump_plan.gd`** — przebudowuje snapshoty. Uruchamiać po każdej zmianie wpływającej na kafelkowanie.
- **`test_edge_analyzer.gd`** — 27 testów F-01..F-26 + parytet Oracle. Wszystkie PASS.
- Snapshoty: `tests/snapshots/etap1/*.sha256`.

---

## Otwarte kwestie projektowe

- `CaveGenerator` nadal ma > 120 linii — wymaga Etapu 8 (wydzielenie `TerrainGenerator`).
- `CellType.ENTRANCE` / `EXIT` są redundantnie w siatce i w `entrance_zone` / `exit_zone` — do ujednolicenia w Etapie 12 (decyzja autora).
- `overworld_forest_generator.gd` nadal istnieje — usunięcie dopiero po Etapie 12.10 (decyzja autora).
