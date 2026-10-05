# Ścieki (sewer) — stan na 2026-10-05

Gałąź **`sewer-gen-v2`** w submodule CienMgly (`modules/quiz_rpg`), wypchnięta na remote (commit `22864c4`).
Zawiera nową architekturę strukturalnego generatora ścieków (Structured Generator v2), pełny determinizm PRNG,
separację koryt suchych i ścieków szumem 0/1, gwarancję 1 składowej spójnej przez `BridgeConnectivityResolver`,
oraz ochronę prepassów ścian 3H i prostych koryt przy ścianach.

W hoście niezacommitowane (zastrzeżone, nie dotykać!): `Tiles.png`, `Props.png`, `Gemini_Generated_Image_*`.

## Pliki
- `resources/maps/sewer.tres` — TileSet (UID `c73m68vj3lqr3`), źródło 0 = `sewer/Assets/Tiles.png`, źródło 1 =
  `Props.png` (kładki). Tereny autora: `floor` (0), `void`, `dark_floor`, `foliage` (mech), `ridges`.
  Kolizje ścian / obrzeży kanału dopisywane wprost w tekście pliku (autor edytuje go w edytorze — nie
  przepisywać ResourceSaverem; builder robi to tylko z `BUILD_TILESET=1`).
- `resources/maps/profile/sewer_map_tiles.tres` — profil Named TileSet (`sewer`), budowany przez
  `tests/build_sewer_resources.gd` (tests/ poza gitem). Moduły lica z przesunięciem -1 (`FS`).
- `resources/maps/config/sewer.json` — flagi i parametry układu ścieków. Eksplorator map: pozycja „Ścieki” (F4).
- `scripts/generation/structured/structured_layout_generator.gd` — główny pipeline strukturalnego układu ścieków.
- `scripts/generation/structured/linear_network_generator.gd` — generator szkieletu sieci koryt i tuneli.
- `scripts/generation/structured/structured_zoning.gd` — strefowanie sal, kompleksów i koryt.
- `scripts/generation/structured/bridge_connectivity_resolver.gd` — gwarancja osiągalności i kładek o dł. 6.
- `scripts/generation/topology/canal_pass.gd` — wyznaczanie odcinków koryta, kładek i podziału na suche/ścieki.
- `scripts/generation/tiling/canal_placer.gd` — kafelkowanie wody, brzegów, dna suchego koryta i kładek.

## Kafle (atlas Tiles.png)
- Lico 3H: wiersze 5 (góra = dół bloku) / 6 (krata) / 7 (cokół), końce kol. 0 i 2. Lico 4H: wiersze 8–11
  (top, krata, krata, cokół), końce kol. 0 i 2. Kap (ściana z podłogą na N): 1,3 / 4,3; końce 0,3 / 2,3.
  Boki: 3,1-3,2 (podłoga na E), 5,1-5,2 (na W). Rama pokoju: 3,0 / 5,0 / 3,3 / 5,3. Pustka 1,4.
- Podłoga: teren `floor` (blok 3–5 × 4–9 z brzegami); środek pełną maską mają tylko 4,5 i 6,6.
- Kanał: kwas 9-slice 11–13 × 0–2 (z własną szyną od brzegu), narożniki wewnętrzne 14,0 / 16,0 / 14,2 / 16,2,
  animacja 4 klatek (co 3 wiersze). Lico brzegu 4,13 (końce 3,13 / 5,13, przy ścianie 6,13 / 8,13).
  Obrzeża na podłodze: 4,10 (kanał na N), 4,12 (na S), 5,11 (na E), 3,11 (na W), rogi 3,10 / 5,10 / 3,12 /
  5,12, wklęsłe 13,12 / 14,12 / 13,13 / 14,13 (dodane przez nas do PNG), ciemne końce przy ścianie 6,11 / 8,11,
  6,12 / 8,12, 9,3 / 9,5, 10,3 / 10,5. Kładki (Props.png): pionowa 4–5 × 9–14, pozioma 6–10 × 12–13.

## Architektura i kluczowe reguły (2026-10-05)

### 1. 100% Determinizm generatora
- Wszystkie wywołania `Array.shuffle()` (wbudowane, nieseedowane) zastąpiono deterministycznym Fisher-Yates
  `MapGeneratorBase.shuffle_array(arr, rng)` w `linear_network_generator.gd`, `structured_zoning.gd`,
  `structured_room_packer.gd` i `canal_pass.gd`. Identyczny seed daje 100% identyczny wynik.

### 2. Spójność koryt i brak zakręcania w ścianę
- **Przyczyna skręcania w ścianę:** w `canal_placer.gd` pomocnicza funkcja `_acid` zwracała `not GridUtils.is_walkable`,
  co powodowało traktowanie ściany sąsiadującej z korytem jako kwasu i wywijanie piany/narożników w mur.
  Zmieniono na `return false` — brzeg koryta przy ścianie jest idealnie prosty (W/E).
- **Dowolna szerokość korytarzy wokół koryta (w tym 0 = styk ze ścianą):**
  - Chodniki `lanes` o stałej szerokości obowiązują wyłącznie dla tuneli tranzytowych (`kind == "tunnel"`).
  - W salach i kompleksach dopuszczalne jest `want[pk] = 0` (brak chodnika, woda dochodzi do litej ściany).
  - Całkowicie wycięto funkcję `_ensure_canal_clearance` z `structured_layout_generator.gd`, która wymuszała sztuczny
    pas podłogi wokół wszystkich koryt i niszczyła prepassy ścian.

### 3. Prepassy ścian 1H i 2H (Wall3HPass, Remove1hWallsPass, WallThicknessPass)
- Reguły prepassów działają w `_run_wall_shape_passes` przed kładkami.
- W `wall_3h_pass.gd` funkcja `_can_fill` sprawdza `not canals.cells.has(p)` — zapobiega to wylewaniu się ścian
  w koryto, dzięki czemu ściany 2H powiększają się do 3H wyłącznie w stronę podłogi pokoju (z dala od wody).
- Usunięcie `_ensure_canal_clearance` sprawiło, że po prepassach nie powstają już nowe niepoprawione ściany 1H/2H.

### 4. Podwójny szum (suche koryto vs ścieki)
- Zastosowano dwupoziomowy szum binarny (0 i 1) do partycjonowania sieci kanałów na poziomie skrzyżowań:
  koryta z poziomem 1 są puste (`dry_cells`), a z poziomem 0 zawierają ścieki.
- Suche koryta są całkowicie odseparowane od kwasu (min dystans $\ge 17.0$ kratek w testach).

### 5. Gwarancja przejść i kładki na osobnej warstwie (Bridges)
- **Dedykowana warstwa kładek (`Bridges`):**
  - Kładki (`BRIDGE_V`, `BRIDGE_H`) zostały wydzielone ze wspólnej warstwy `FloorDecor` na osobną warstwę TileMapLayer `Bridges` (`z_index = -1`, `y_sort_enabled = true`).
  - Kolejność nanoszenia warstw: `Floor` -> `FloorDecor` (obrzeża/dekoracje) -> `Bridges` (kładki nad korytem) -> `Walls` -> `Platforms`.
  - Warstwa jest w pełni obsługiwana przez `CaveGenerator` (`prepare_cave_layers`, `execute_cave_tiles`), `ProceduralLevel` (`_prepare_layers`, `_apply_job_async`) oraz podgląd eksploratora (`MapGeneratorPreview` posiada checkbox widoczności oraz inspekcję kafla kładki w HUD).
- `BridgeConnectivityResolverScript.resolve(ctx, canal_layout)` uruchamia się przed dresingiem i nawigacją.
- Gwarantuje dokładnie 1 składową spójną całej mapy. Wszystkie kładki mają stałą długość 6 kratek i opierają się
  stabilnie na podłodze `FLOOR`.

- Katalog `objects_sewer.json` (włączony w `sewer.json`): skrzynie (alias `chest`), stół + krzesła
  (towarzysze), skrzynki / beczki przy ścianach (skupiska), wraki, bloki miedzi, kratki ściekowe 2×2–4×4
  (DECAL na całej podstawie), otwory w posadzce, drobnica, butelki / kubki — wszystko kafle `sewer.tres`; na licu (`mount: facade`):
  lampy, okrągłe kratki, przełączniki, łuki odpływów. Opis mechanizmu: `kontekst/obiekty.md`.
- Nieużyte z atlasu: regał / schody (Props 0–1 × 6–8 — wygląda na wyjście, może grafika portalu),
  skrzynia ścieków (8–9 × 0–3), barierki (6–9 × 4), łańcuch (10, 0–2), filar (Tiles 7, 3–6), rury.

## Testy diagnostyczne i integracyjne
- `tests/diag_sewer_full_test.gd`:
  - Weryfikuje determinizm 100%, zasięg kanałów (>= 50%), separację suche koryto <-> kwas (odległość >= 17 kratek),
    kładki o długości 6 oparte na podłodze, oraz pełną spójność mapy (dokładnie 1 składowa).
  - Wynik: **PASS** na seedach 119, 42, 777, 2026 (rozmiary 160x160 i 250x250).
- `tests/diag_sewer_slice_fixture.gd`:
  - Weryfikacja 13 asercji integracyjnych: filary lica, barierki z przerwami na kładkach, winieta z wolną strefą dojścia,
    osiągalność geometryczna wejście-wyjście, kolizje barierek i poprawność bakingu NavMesh (ścieżka wejście-wyjście).
  - Wynik: **PASS 13 / FAIL 0**.
- Lokalne skrypty pomocnicze: `render_sewer.gd`, `diag_wall_steps.gd`, `diag_spawn_cells.gd`, `diag_enemy_drift.gd`.

