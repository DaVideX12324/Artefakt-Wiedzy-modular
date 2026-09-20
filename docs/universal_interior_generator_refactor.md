# Universal Interior Generator — plan refaktoru (dokument wykonawczy)

> **Status:** zatwierdzony plan analityczny. Dokument jest jedynym źródłem prawdy dla refaktoru
> generatora proceduralnego w module `quiz_rpg`.
>
> **Adresat:** AI implementujące zmiany (Gemini / Antigravity) oraz autor projektu.
>
> **Zakres tego dokumentu:** analiza stanu obecnego, weryfikacja i korekta dwóch dokumentów
> źródłowych, docelowa architektura, etapowy plan wdrożenia, strategia weryfikacji.
>
> **Dokumenty źródłowe (poprawiane przez ten plik):**
> - `README_universal_interior_generator.md` (dalej: **RD-1**)
> - `README_edge_detection_2h_3h.md` (dalej: **RD-2**)
>
> W razie sprzeczności między RD-1/RD-2 a tym dokumentem — **obowiązuje ten dokument**.
> Rozdział 4 wylicza wszystkie rozbieżności wraz z uzasadnieniem.

---

## Spis treści

1. [Werdykt: ocena RD-1 i RD-2](#1-werdykt-ocena-rd-1-i-rd-2)
2. [Stan faktyczny kodu (ground truth)](#2-stan-faktyczny-kodu-ground-truth)
3. [Analiza problemów w obecnym kodzie](#3-analiza-problemów-w-obecnym-kodzie)
4. [Błędy i nieścisłości w RD-1 / RD-2 — korekty](#4-błędy-i-nieścisłości-w-rd-1--rd-2--korekty)
5. [Luki w RD-1 / RD-2 — czego brakuje](#5-luki-w-rd-1--rd-2--czego-brakuje)
6. [Decyzje autora (wiążące)](#6-decyzje-autora-wiążące)
7. [Architektura docelowa](#7-architektura-docelowa)
8. [Kontrakty i sygnatury API](#8-kontrakty-i-sygnatury-api)
9. [Model edge detection](#9-model-edge-detection)
10. [Model placementu i priorytetów](#10-model-placementu-i-priorytetów)
11. [Profile terenu (JSON)](#11-profile-terenu-json)
12. [Etapowy plan wdrożenia](#12-etapowy-plan-wdrożenia)
13. [Strategia weryfikacji i testów](#13-strategia-weryfikacji-i-testów)
14. [Lista błędów i rzeczy do weryfikacji wizualnej](#14-lista-błędów-i-rzeczy-do-weryfikacji-wizualnej)
15. [Zasady pracy dla implementującego AI](#15-zasady-pracy-dla-implementującego-ai)
16. [Załączniki](#16-załączniki)

---

## 1. Werdykt: ocena RD-1 i RD-2

### 1.1. Ocena ogólna

**Kierunek jest słuszny i należy go zrealizować.** Oba dokumenty poprawnie diagnozują
rzeczywisty problem architektoniczny: `apply_cave_tiles()` to jedna funkcja o długości
**795 linii** (linie 903–1697 w `cave_generator.gd`), która jednocześnie:

- modyfikuje topologię siatki (pre-passy),
- liczy sąsiedztwo (`n_floor`, `w_floor`, `nw_floor`, … — powtórzone w 4 miejscach),
- klasyfikuje geometrię (zagnieżdżone `if/elif` o głębokości do 5 poziomów),
- rozstrzyga konflikty przez stringi w `placed_tiles: Dictionary` (`"ROCK"`, `"FACADE"`,
  `"CORNER"`, `"SIDE_FIXED"`, `"SIDE"`, `"RIM"`),
- wykonuje 91 bezpośrednich wywołań `set_cell()` / `erase_cell()`.

Ten kształt kodu jest udowodnioną przyczyną konkretnych, mierzalnych defektów —
rozdział 3 i 14 wyliczają je z numerami linii.

### 1.2. Co w RD-1/RD-2 jest bezwzględnie trafne

| Postulat | Ocena | Dowód w kodzie |
|---|---|---|
| Wspólny `EdgeAnalyzer` zamiast lokalnego liczenia sąsiedztwa | **Trafne** | `n_floor`/`w_floor`/`e_floor` liczone niezależnie w liniach 1160–1185, 1563–1566, 1588–1595 |
| Rozdzielenie `EdgeKind` (geometria) od kafla (atlas) | **Trafne** | Dziś typ geometrii nie istnieje jako dana — jest zaszyty w strukturze `if`-ów |
| Priorytety liczbowe zamiast stringów | **Trafne, ale wymaga korekty** | Obecny system ma **cykl priorytetów** (§3.3) — nie da się go odwzorować 1:1 |
| Detekcja **segmentów** fasad/rimów (START/MIDDLE/END) | **Trafne i pilne** | Atlas ma zakończenia rimu roots `(1,8)/(1,9)` i `(4,8)/(4,9)`, które kod **deklaruje i nigdy nie używa** (§3.5) |
| Pre-passy jako niezależne, testowalne jednostki | **Trafne** | 5 pre-passów jest dziś rozrzuconych między `generate()` i `apply_cave_tiles()` |
| `TerrainProfile` + JSON | **Trafne**, zgodne z konwencją repo | Projekt już używa JSON: `module_manifest.json`, `resources/quizzes/*.json`, `resources/audio/music_tracks.json` |
| `CaveGenerator` jako wrapper kompatybilnościowy | **Trafne, ale sygnatura w RD-1 jest błędna** | §4.1 |
| Ortogonalny model `kind + orientation + height + segment + theme` (RD-2) | **Trafne — to jest właściwy model** | RD-1 proponuje sprzeczny, płaski enum — §4.2 |

### 1.3. Co w RD-1/RD-2 jest błędne lub nieaktualne

Skrót (pełna lista: rozdział 4):

1. **Tabela priorytetów jest odwrotna do rzeczywistości** — RD-1/RD-2 dają `RIM_BASE (70) > FACADE (50)`,
   kod robi dokładnie odwrotnie.
2. **Sygnatura wrappera `CaveGenerator.generate()` łamie istniejące wywołanie** w `procedural_level.gd:100`.
3. **Filary (`PILLAR`) nie istnieją w kodzie** — zostały usunięte w commicie `0956687`.
   RD-1 każe je „zweryfikować" w Etapie 1, co jest niewykonalne.
4. **Flaga `enable_rim_capping` jest martwa** (0 użyć) — RD-1 traktuje ją jako działającą funkcję.
5. **Płaski `EdgeKind` z RD-1 jest sprzeczny z ortogonalnym `EdgeKind` z RD-2.**
6. **8-kierunkowa orientacja jest nadmiarowa** dla fasad południowych i zachęca do błędów.
7. **`_resolve_facade_height()` z RD-2 nie opisuje faktycznej semantyki 2H/3H** w tym tilesecie (§2.6).
8. **Klucz `String` w `TilePlacementPlan.queue()`** to problem wydajnościowy przy mapach 500×500.

### 1.4. Czego w RD-1/RD-2 brakuje krytycznie

1. **Autotiling terenów** (`set_cells_terrain_connect`) — nie da się go wyrazić jako placement per-komórka.
2. **Model „wymazania" kafla** (portal `erase_cell`).
3. **Kontrakt warstw fizyki / kolizji** tilesetu (`physics_layer_0` vs `physics_layer_1`).
4. **Brak frameworka testowego w projekcie** — RD-2 wymaga testów, których nie ma na czym uruchomić.
5. **Kontrakt determinizmu** — flagi są dziś przekazywane osobno do `generate()` i `apply_cave_tiles()`.
6. **Motyw `roots` nie ma modułów 2H** — profil musi umieć zrobić fallback do motywu podstawowego.
7. **Kolejność pre-passów względem portali** — przeniesienie ich „w górę" zmieni wynik.
8. **System obiektowy.** RD-1 kończy pipeline na „Interior decoration and spawn planning",
   ale traktuje dekoracje jak kafle. Zgodnie z doktryną autora (§6.8) wszystko poza
   ścianami i podłogami jest **obiektem** i należy do osobnego generatora.

---

## 2. Stan faktyczny kodu (ground truth)

Ten rozdział jest opisem tego, co **jest**, a nie tego, co ma być. Implementujące AI musi
traktować go jako referencję przy każdej migracji fragmentu logiki.

### 2.1. Inwentarz plików

```
modules/quiz_rpg/scripts/generation/
├── cave_generator.gd              1748 linii   ← główny obiekt refaktoru
├── map_generator_base.gd           396 linii   ← CellType, GenerationResult, utils, spawn, nav
├── dungeon_generator.gd            157 linii   ← zamek (paleta + carve_rect + carve_corridor)
└── overworld_forest_generator.gd   167 linii   ← las (FastNoiseLite + polany + A*)

modules/quiz_rpg/scripts/maps/
└── procedural_level.gd             ~180 linii  ← orkiestrator scen, JEDYNY produkcyjny konsument

modules/quiz_rpg/scripts/tools/
└── map_generator_preview.gd        ~470 linii  ← narzędzie podglądu (seed / rozmiar / maska)

modules/quiz_rpg/resources/tilemaps/
└── caves.tres                     1036 linii   ← TileSet, 280 zdefiniowanych kafli
```

### 2.2. Graf wywołań (kompletny)

```
procedural_level.gd::generate_level()
├── CaveGeneratorScript.get_default_palette()                       [:95]
├── CaveGeneratorScript.generate(w, h, seed, 6, 24, rooms_count)    [:100]   ← 6 argumentów pozycyjnych
├── _get_or_create_layer("Floor",      z=-2, ts)
├── _get_or_create_layer("FloorDecor", z=-1, ts)
├── _get_or_create_layer("Walls",      z= 0, ts)
├── MapGeneratorBaseScript.create_rng(actual_seed)                            ← DRUGI, niezależny RNG
├── CaveGeneratorScript.apply_cave_tiles(floor, walls, res, rng, decor) [:129] ← BEZ argumentu `flags`
├── MapGeneratorBaseScript.spawn_entities(self, res, …)
├── MapGeneratorBaseScript.setup_navigation_region(self, res)
└── _connect_exit_trigger()

map_generator_preview.gd
├── ProceduralLevelScript.new()  + set("level_type"/"map_seed"/"map_width"/"map_height"/"cave_max_rooms")
└── CaveGeneratorScript.get_grid_mask_image(res)                     [:164]
```

**Konsekwencje, które refaktor musi uszanować:**

- Istnieje **dokładnie jeden** produkcyjny konsument (`procedural_level.gd`) i **jedno** narzędzie
  (`map_generator_preview.gd`). Powierzchnia zmian jest mała — to dobra wiadomość.
- `generate()` jest wywoływane **6 argumentami pozycyjnymi**; `max_rooms` jest liczone dynamicznie
  ze pola mapy (`procedural_level.gd:96-99`). Profil **musi** dopuszczać nadpisanie tego parametru
  w runtime.
- `apply_cave_tiles()` jest wywoływane **bez `flags`** → powstaje drugi, domyślny obiekt
  `GenerationFlags`. Jeżeli ktoś kiedyś przekaże flagi do `generate()`, a nie do
  `apply_cave_tiles()`, wynik będzie niespójny (§3.4).
- `rng` przekazywany do `apply_cave_tiles()` to **osobny** `RandomNumberGenerator`, zainicjowany
  tym samym seedem co `generate()`, ale konsumowany niezależnie.

### 2.3. Pełna kolejność operacji — `generate()` (linie 198–366)

| # | Operacja | Linia | Flaga | Zmienia grid? | Zużywa RNG? |
|---|---|---|---|---|---|
| 1 | Wypełnienie całej siatki `CellType.WALL` | 209–212 | — | tak | nie |
| 2 | Losowanie i rzeźbienie komór (`_carve_cave_chamber`) | 214–250 | — | tak | **tak** |
| 3 | MST — korytarze łączące wszystkie komory | 253–280 | — | tak | **tak** |
| 4 | Dodatkowe korytarze pętlowe (max 3) | 282–296 | — | tak | **tak** |
| 5 | `_smooth_cave_junctions()` | 299 | `enable_junction_smoothing` | tak | nie |
| 6 | `_remove_1height_walls()` | 302 | — | tak (**dodaje** ściany) | nie |
| 7 | `_enforce_wall_thickness()` | 303 | — | tak (tylko wycina) | nie |
| 8 | `_flatten_short_3h_bulges()` | 304 | — | tak (tylko wycina) | nie |
| 9 | `_ensure_rooms_connected()` | 307 | — | tak | **tak** (jeśli naprawia) |
| 10 | Wybór komory wejściowej i wyjściowej (max dystans) | 311–324 | — | nie | nie |
| 11 | `_carve_portal_alcove()` × 2 + oznaczenie `ENTRANCE`/`EXIT` | 327–341 | — | tak | **tak** |
| 12 | Boss w komorze wyjściowej | 344–347 | — | nie | nie |
| 13 | Wrogowie / skrzynie w komorach pośrednich | 350–364 | — | nie | **tak** |

### 2.4. Pełna kolejność operacji — `apply_cave_tiles()` (linie 903–1697)

| # | Operacja | Linia | Flaga | Warstwa |
|---|---|---|---|---|
| 0 | `_cleanup_grid_before_tiling()` + `_flatten_short_3h_bulges()` | 934–937 | `enable_grid_cleanup` | **mutuje `result.grid`** |
| 1 | Wypełnienie voidu `WALL_INSIDE (2,2)` w zakresie `-4 … +4` poza mapą | 939–944 | — | Walls |
| 2a | Bazowa podłoga `(10,13)` na dylatacji 5×5 wokół floor | 946–960 | — | Floor |
| 2b | Plamy `Mud` — `set_cells_terrain_connect(cells, 0, 1, true)` | 962–995 | `enable_terrain_smoothing` | Floor |
| 2c | Plamy `Grass` — `set_cells_terrain_connect(cells, 0, 2, true)` | 997–1024 | `enable_terrain_smoothing` | FloorDecor |
| 3 | Konfiguracja szumów motywu (`roots_theme_noise`, `ab_noise`) + `get_use_roots` | 1026–1058 | — | — |
| F1 | **FAZA 1** — wypełnienie litej skały (3 warianty) | 1060–1074 | — | Walls |
| F2 | **FAZA 2** — fasady, łączniki 2H↔3H, schodki, nisze, zakończenia | 1076–1518 | `enable_decorative_niches`, `niche_spawn_chance`, `secret_niche_spawn_chance` | Walls |
| F2.5 | **FAZA 2.5** — ściany pionowe obok kończącego się schodka | 1520–1557 | — | Walls |
| F3 | **FAZA 3** — ściany boczne W/E (warianty A/B z `rng.randi()`) | 1559–1582 | — | Walls |
| F4 | **FAZA 4** — rimy, półki, misy, narożniki diagonalne | 1584–1692 | — | Walls |
| P | Wymazanie kafli na polach portali (`erase_cell`) | 1694–1696 | — | Walls |

### 2.5. Semantyka siatki logicznej

```
CellType.VOID     = 0   ← poza mapą; _is_walkable() == false → traktowane jak ściana
CellType.FLOOR    = 1   ← przechodnie
CellType.WALL     = 2   ← lita skała
CellType.DOOR     = 6   ← NIE używane w jaskiniach (tylko dungeon_generator)
CellType.ENTRANCE = 7   ← przechodnie, strefa portalu wejściowego
CellType.EXIT     = 8   ← przechodnie, strefa portalu wyjściowego
```

`_is_walkable()` (linia 1699) zwraca `true` dla `FLOOR | DOOR | ENTRANCE | EXIT`.
Brzegi mapy są więc automatycznie traktowane jako ściana (`VOID`).

**Strefy portali:** `_carve_portal_alcove()` rzeźbi alkowę `5×5` (promień 2), ale do
`alcove_cells` (czyli do `entrance_zone`/`exit_zone`) trafiają **tylko wiersze `dy >= -1`**,
czyli **20 z 25 komórek**. Najwyższy wiersz alkowy (`dy == -2`) jest wycięty jako `FLOOR`,
ale **nie** jest oznaczony jako `ENTRANCE`/`EXIT` — celowo, żeby końcowe `erase_cell()`
nie usunęło z niego bazy fasady. Stała `ALCOVE_NORTH_EXTRA` ma wartość `0`, więc kod
obsługujący „dodatkowy wiersz na fasadę" jest **martwy** — efekt realizuje warunek
`if dy >= -ALCOVE_RADIUS + 1` (linia 869).

### 2.6. Semantyka wysokości fasad — KRYTYCZNE

To jest najważniejszy szczegół domenowy, którego **RD-2 nie opisuje poprawnie**.

Definicja: `solid_depth` = liczba kolejnych komórek `WALL` idąc na północ od komórki podłogi
będącej „stopą" fasady (`walkable(pos) and not walkable(pos + (0,-1))`).

```
solid_depth == 1   → NIE WYSTĘPUJE. Gwarantowane przez _remove_1height_walls().
                     Gdyby wystąpiło: FAZA 2 pomija (wymaga not walkable(pos+(0,-2))),
                     a FAZA 4 pomija (warunek `if _is_walkable(grid, pos + (0,1)): continue`).
                     Efekt: tylko surowy ROCK_FILL, brak modułu ściany.

solid_depth == 2   → FASADA 2H. Kod stawia 2 kafle:
                       base @ y      (na komórce PODŁOGI, efekt 2.5D)
                       top  @ y - 1  (na komórce ściany)
                     Komórka y - 2 (najwyższy wiersz ściany) dostaje RIM w FAZIE 4.
                     Razem widoczne 3 wiersze.

solid_depth >= 3   → FASADA 3H. Kod stawia 4 kafle:
                       base  @ y      (na komórce PODŁOGI)
                       mid   @ y - 1
                       top   @ y - 2
                       crown @ y - 3  ← moduł zawiera własną krawędź górną
                     Jeśli solid_depth > 3, wiersze y-4 … pozostają ROCK_FILL,
                     a najwyższy wiersz ściany dostaje osobny RIM w FAZIE 4.
                     Efekt zamierzony: fasada 3H zawsze wygląda na 3 kafle wysoką
                     z górną warżką, a za nią / nad nią kontynuuje się lita skała.
```

**Wniosek dla implementacji:** `facade_height` **nie jest** prostym `min(solid_depth, 3)`.
Jest to `2` dla `solid_depth == 2` i `3` dla `solid_depth >= 3`, przy czym moduł 3H
**konsumuje wiersz rimu**, a moduł 2H **nie**. Ta asymetria musi być jawna w kontrakcie
`TileRule` (pole `consumes_rim_row: bool`), bo inaczej rim pass nadpisze koronę 3H
lub pozostawi dziurę nad 2H.

### 2.7. Wybór motywu (`rock` / `roots`)

```gdscript
# cave_generator.gd:1026-1058
roots_theme_noise.seed      = rng.seed + 333
roots_theme_noise.frequency = 0.08          # plamy szerokości kilku kratek
ab_noise.seed               = rng.seed + 777
ab_noise.frequency          = 0.45          # warianty A/B zmieniają się co 1-2 kratki

get_use_roots(pos):
    if theme_override == 0: return false            # wymuszony rock
    if theme_override == 1: return true             # wymuszony roots
    # Strefy portali: JEDNOLITY motyw dla całej alkowy (Chebyshev <= 4 od centrum)
    if entrance != ZERO and |pos.x - ent.x| <= 4 and |pos.y - ent.y| <= 4:
        return noise(ent.x, ent.y) > 0.14
    if exit != ZERO and |pos.x - exi.x| <= 4 and |pos.y - exi.y| <= 4:
        return noise(exi.x, exi.y) > 0.14
    return noise(pos.x, pos.y) > 0.14               # próg 0.14 ≈ 30% powierzchni
```

**Do zachowania 1:1.** Próg `0.14`, częstotliwości `0.08` / `0.45`, offsety seeda `+333` / `+777`
oraz regułę jednolitego motywu w promieniu Chebysheva 4 wokół portali.

**Pułapka:** motyw jest odpytywany w różnych punktach odniesienia zależnie od fazy:
- FAZA 2: `get_use_roots(pos)` — pozycja stopy fasady.
- FAZA 3: `get_use_roots(pos + (1,0))` dla ściany zachodniej, `get_use_roots(pos + (-1,0))`
  dla wschodniej — czyli **motyw sąsiedniej komórki podłogi**, nie własnej (linie 1571, 1579).
- FAZA 4: `get_use_roots(pos + (0,-1) if n_floor else pos)` (linia 1600) — czyli motyw
  komórki podłogi nad rimem.

To nie jest błąd — to celowe „przyklejanie" motywu ściany do motywu pomieszczenia,
które ta ściana obsługuje. **Nowy `ThemeResolver` musi zachować te trzy różne punkty odniesienia.**

### 2.8. Warianty A/B i losowość

| Miejsce | Mechanizm | Zależny od kolejności skanowania? |
|---|---|---|
| ROCK_FILL (3 warianty) | `hash(Vector2i(x, y + rng.seed)) % 100` | **nie** (funkcja pozycji) |
| Fasady, rimy, korony A/B | `ab_noise.get_noise_2d(x, y) > 0.0` | **nie** |
| Ściany boczne FAZA 3 A/B | `rng.randi() % 2` | **TAK** ← problem |
| Nisza standardowa | `rng.randf() < flags.niche_spawn_chance` | **TAK** ← problem |
| Nisza sekretna (OUT) | `rng.randf() < flags.secret_niche_spawn_chance` | **TAK** ← problem |
| Dystans między niszami OUT | `OUT_NICHE_MIN_DISTANCE = 10`, lista `out_niche_positions` | **TAK** (kolejność) |

Trzy ostatnie pozycje uniemożliwiają bezpieczny refaktor na model planu placementu
przy zachowaniu parytetu seedów. Decyzja autora: patrz §6.3.

### 2.9. Mapa atlasu — pełna tabela

Atlas: `assets/pixel_crawler/_versions_archive/cave_v1/Pixel Crawler - Cave/Assets/Tiles.png`,
`272 × 368 px`, kafel `16 × 16` → **17 kolumn (0–16) × 23 wiersze (0–22)**.
`caves.tres` definiuje **280** kafli. Weryfikacja przeprowadzona: **wszystkie** współrzędne
atlasu używane w `cave_generator.gd` istnieją w `caves.tres`.

#### Motyw `rock` (podstawowy)

| Element | Współrzędne | Nazwana stała | Używane? |
|---|---|---|---|
| Rim 1H A/B | `(2,0)` `(3,0)` | `WALL_TOP` | tak (jako literał) |
| Rim cap wschodni | `(5,1)` | `WALL_TOP_CORNER_RIGHT` | tak (jako literał) |
| Rim cap zachodni | `(0,1)` | `WALL_TOP_CORNER_LEFT` | tak (jako literał) |
| Misa / półka pod cap E | `(4,1)` | `CORNER_INNER_BOTTOM_LEFT` / `WALL_TOP_SLOPE_RIGHT` | tak (jako literał) |
| Misa / półka pod cap W | `(1,1)` | `CORNER_INNER_BOTTOM_RIGHT` / `WALL_TOP_SLOPE_LEFT` | tak (jako literał) |
| Ściana boczna zachodnia A/B | `(5,2)` `(5,3)` | `WALL_SIDE_WEST` | tak |
| Ściana boczna wschodnia A/B | `(0,2)` `(0,3)` | `WALL_SIDE_EAST` | tak |
| Lita skała (główna) | `(2,2)` | `WALL_INSIDE` | tak |
| Lita skała warianty | `(2,3)` `(3,2)` | — | tak (literały) |
| Fasada 3H — korona A/B | `(2,4)` `(3,4)` | **brak stałej** | tak (literały) |
| Fasada 3H — top A/B | `(2,5)` `(3,5)` | `WALL_BOTTOM_TOP` | tak |
| Fasada 3H — mid A/B | `(2,6)` `(3,6)` | `WALL_BOTTOM_MID` | tak |
| Fasada 3H — base A/B | `(2,7)` `(3,7)` | `WALL_BOTTOM_BASE` | tak |
| Narożnik wewn. SW | `(4,4)` | `CRNR_SW_IN` | tak |
| Narożnik wewn. SE | `(1,4)` | `CRNR_SE_IN` | tak |
| Schodek NW_IN (top/mid/base) | `(1,5)` `(1,6)` `(1,7)` | `MOD_CRNR_NW_IN_*` | tak |
| Schodek NE_IN (top/mid/base) | `(4,5)` `(4,6)` `(4,7)` | `MOD_CRNR_NE_IN_*` | tak |
| Zakończenie NW_OUT (top/mid/base) | `(0,4)` `(0,5)` `(0,6)` | `MOD_CRNR_NW_OUT_*` | tak |
| Zakończenie NE_OUT (top/mid/base) | `(5,4)` `(5,5)` `(5,6)` | `MOD_CRNR_NE_OUT_*` | tak |
| Fasada 2H — top/base A/B | `(2,20)/(3,20)` `(2,21)/(3,21)` | `WALL_2H_TOP` / `WALL_2H_BASE` | tak |
| Fasada 2H — zakończenie W | `(0,19)` `(0,20)` | `WALL_2H_WEST_*` | tak |
| Fasada 2H — zakończenie E | `(5,19)` `(5,20)` | `WALL_2H_EAST_*` | tak |
| **Schodek 2H lewy** | `(1,19)` `(1,20)` `(1,21)` | `WALL_2H_SLOPE_LEFT_*` | **NIE — martwy** |
| **Schodek 2H prawy** | `(4,19)` `(4,20)` `(4,21)` | `WALL_2H_SLOPE_RIGHT_*` | **NIE — martwy** |
| Łącznik 2H→3H | `(7,19)` `(7,20)` `(7,21)` | `CONNECTOR_2H_TO_3H_*` | tak |
| Łącznik 3H→2H | `(10,19)` `(10,20)` `(10,21)` | `CONNECTOR_3H_TO_2H_*` | tak |
| Podłoga bazowa | `(10,13)` | **brak stałej** | tak (literał) |

#### Motyw `roots` (drugorzędny)

| Element | Współrzędne | Nazwana stała | Używane? |
|---|---|---|---|
| Rim roots — tips A/B | `(2,8)` `(3,8)` | `ROOT_TOP_TIPS` | tak |
| Rim roots — base A/B | `(2,9)` `(3,9)` | `ROOT_TOP_BASE` | tak |
| **Rim roots — zakończenie lewe** | `(1,8)` `(1,9)` | `ROOT_TOP_TIPS_LEFT` / `ROOT_TOP_BASE_LEFT` | **NIE — martwe** |
| **Rim roots — zakończenie prawe** | `(4,8)` `(4,9)` | `ROOT_TOP_TIPS_RIGHT` / `ROOT_TOP_BASE_RIGHT` | **NIE — martwe** |
| Rim roots skos prawy | `(5,9)` `(5,10)` | `ROOT_TOP_SLOPE_*_RIGHT` | tak |
| Rim roots skos lewy | `(0,9)` `(0,10)` | `ROOT_TOP_SLOPE_*_LEFT` | tak |
| Misa roots pod cap E | `(4,10)` | `ROOT_CORNER_INNER_BOTTOM_LEFT` | tak |
| Misa roots pod cap W | `(1,10)` | `ROOT_CORNER_INNER_BOTTOM_RIGHT` | tak |
| Ściana boczna roots W A/B | `(5,11)` `(5,12)` | `ROOT_WALL_SIDE_WEST` | tak |
| Ściana boczna roots E A/B | `(0,11)` `(0,12)` | `ROOT_WALL_SIDE_EAST` | tak |
| Narożnik wewn. roots SW | `(4,13)` | `ROOT_CRNR_SW_IN` | tak |
| Narożnik wewn. roots SE | `(1,13)` | `ROOT_CRNR_SE_IN` | tak |
| Fasada roots 3H — korona A/B | `(2,13)` `(3,13)` | **brak stałej** | tak (literały) |
| Fasada roots 3H — top/mid/base | `(2,14)/(3,14)` `(2,15)/(3,15)` `(2,16)/(3,16)` | `ROOT_BOTTOM_*` | tak |
| Schodek roots NW_IN | `(1,14)` `(1,15)` `(1,16)` | `ROOT_MOD_CRNR_NW_IN_*` | tak |
| Schodek roots NE_IN | `(4,14)` `(4,15)` `(4,16)` | `ROOT_MOD_CRNR_NE_IN_*` | tak |
| Zakończenie roots NW_OUT | `(0,13)` `(0,14)` `(0,15)` | `ROOT_MOD_CRNR_NW_OUT_*` | tak |
| Zakończenie roots NE_OUT | `(5,13)` `(5,14)` `(5,15)` | `ROOT_MOD_CRNR_NE_OUT_*` | tak |
| **Fasada roots 2H** | — | — | **NIE ISTNIEJE W ATLASIE** |

**Dwa wnioski o wysokiej wartości:**

1. **Motyw `roots` nie ma wariantu 2H.** Dlatego gałąź `is_2h` (linie 1109–1140) **całkowicie
   ignoruje** `use_roots`. Profil musi obsługiwać deklaratywny fallback:
   `theme.roots.fallback_for = ["facade_2h", "connector_2h_3h", "connector_3h_2h"]`.
2. **Atlas zawiera 4 moduły, których kod nigdy nie używa**: schodki 2H (kolumny 1 i 4,
   wiersze 19–21) oraz zakończenia rimu roots (kolumny 1 i 4, wiersze 8–9). To dokładnie
   te przypadki, o których mówi RD-2 („prawa końcówka bez kafla", „schodek 2H → 3H").
   **Uniwersalny system jest warunkiem koniecznym do ich wykorzystania** — to najmocniejszy
   merytoryczny argument za refaktorem.

### 2.10. Kontrakt warstw fizyki (nieopisany w RD-1/RD-2)

```
caves.tres:
  physics_layer_0/collision_layer = 4    → warstwa projektu 3 "GroundCollisions"
  physics_layer_0/collision_mask  = 3
  physics_layer_1/collision_layer = 32   → warstwa projektu 6 "PlatformCollisions"
  physics_layer_1/collision_mask  = 3

player.tscn:  collision_mask = 6   = warstwy 2 (Enemies) + 3 (GroundCollisions)
enemy.tscn:   collision_mask = 39  = warstwy 1 + 2 + 3 + 6 (Enemies + Ground + Platform)
```

**Obserwacja:** przeciwnicy kolidują z `PlatformCollisions` (`physics_layer_1`, obecnym m.in.
na kaflach szczytów ścian `7:0`, `8:0`, `9:0`, `10:0`, `6:1`, `7:1`, `10:1`, `11:1`),
a **gracz nie**. Kolizje są przypisane per-kafel w `caves.tres`, więc dopóki refaktor
zachowa te same współrzędne atlasu, zachowanie fizyki pozostanie identyczne.

**Wymóg dla profilu:** dla nowego tilesetu (castle / library) profil musi deklarować,
które kategorie kafli wymagają której warstwy fizyki, a walidator profilu musi to
sprawdzić przeciwko `TileSet`. Inaczej gracz zacznie przechodzić przez ściany w nowym terenie.

**Uwaga o nawigacji:** `setup_navigation_region()` (`map_generator_base.gd:366-396`) buduje
`NavigationPolygon` **wyłącznie z prostokątnego obrysu mapy** — bez dziur na ściany.
`enemy_base.gd:67` pobiera `NavigationAgent2D`, ale **nigdzie go nie używa** (jedyne wystąpienie
zmiennej `_nav_agent` w pliku). Czyli navmesh jest obecnie dekoracją i nie wpływa na grę.
Nie jest to blokada refaktoru, ale jeśli kiedyś pathfinding zostanie włączony,
`GenerationResult.grid` trzeba będzie przekuć na dziury w navmeshu (§14, P3-2).

### 2.11. Flagi generacji — stan faktyczny

```gdscript
# cave_generator.gd:13-24 — klasa WEWNĘTRZNA: CaveGenerator.GenerationFlags
class GenerationFlags:
    var enable_meandering: bool = true              # 1 użycie  (_carve_organic_corridor)
    var enable_variable_width: bool = true          # 1 użycie
    var enable_funnels: bool = true                 # 1 użycie
    var enable_junction_smoothing: bool = true      # 1 użycie  (generate)
    var enable_grid_cleanup: bool = true            # 1 użycie  (apply_cave_tiles, KROK 0)
    var enable_terrain_smoothing: bool = true       # 2 użycia  (mud + grass)
    var enable_decorative_niches: bool = true       # 1 użycie  (FAZA 2)
    var enable_rim_capping: bool = true             # 0 UŻYĆ — MARTWA FLAGA
    var niche_spawn_chance: float = 0.15            # 1 użycie
    var secret_niche_spawn_chance: float = 0.3      # 1 użycie
```

`GenerationFlags` jest klasą **wewnętrzną** `CaveGenerator`. Wyciągnięcie jej do
`core/generation_flags.gd` z `class_name GenerationFlags` zmienia ścieżkę typu
(`CaveGenerator.GenerationFlags` → `GenerationFlags`). Nikt tej klasy dziś nie tworzy
spoza `cave_generator.gd`, więc zmiana jest bezpieczna — ale musi być zrobiona w jednym commicie.

### 2.12. Martwy kod

| Element | Linia | Status |
|---|---|---|
| `_get_vertical_wall_thickness()` | 661–674 | **Nigdy nie wywoływana.** Usunąć. |
| `print_grid_mask_ascii()` | 1730–1748 | Nigdy nie wywoływana w projekcie. Zachować jako narzędzie debug — będzie przydatna w testach gridowych (§13). |
| `flags.enable_rim_capping` | 22 | Martwa flaga. Usunąć lub podłączyć (§6.2). |
| `ALCOVE_NORTH_EXTRA` | 789 | Wartość `0` czyni zależny kod martwym. Uprościć. |
| `WALL_2H_SLOPE_LEFT_*`, `WALL_2H_SLOPE_RIGHT_*` | 166–172 | Zadeklarowane, nieużywane. **Zachować — to brakująca funkcja** (§14, P2-1). |
| `ROOT_TOP_TIPS_LEFT/RIGHT`, `ROOT_TOP_BASE_LEFT/RIGHT` | 83–89 | Zadeklarowane, nieużywane. **Zachować — to brakująca funkcja** (§14, P2-2). |
| Aliasy kompatybilności (`WALL_BOTTOM_TOP_LEFT`, `WALL_LEFT`, `CORNER_INNER_TOP_LEFT`, …) | 69–76, 121–140 | Zadeklarowane, nieużywane. Usunąć przy migracji do profilu. |
| `_build_free_standing_pillars()`, `_assemble_pillar()` | — | **Usunięte** w commicie `0956687`. Ostatnia wersja: `git show 0792c03:modules/quiz_rpg/scripts/generation/cave_generator.gd` (linie 1653–1700). |

---

## 3. Analiza problemów w obecnym kodzie

### 3.1. Regresja składniowa na `main` (już naprawiona lokalnie)

Na commicie `0956687` plik `cave_generator.gd` **nie kompiluje się**. Weryfikacja
(Godot 4.6, `--headless --check-only`):

```
SCRIPT ERROR: Parse Error: Identifier "right_is_2h_step" not declared in the current scope.
   at: GDScript::reload (res://modules/quiz_rpg/scripts/generation/cave_generator.gd:1170)
SCRIPT ERROR: Parse Error: Identifier "left_is_2h_step" not declared in the current scope.
   at: GDScript::reload (res://modules/quiz_rpg/scripts/generation/cave_generator.gd:1170)
ERROR: Failed to load script … with error "Parse error".
```

Przyczyna: commit `0956687` usunął deklaracje `left_is_2h_step` / `right_is_2h_step`
(dawniej `check_2h_col.call(x ± 1, y - 1)`), ale zostawił trzecią gałąź `elif`, która
ich używa. Pozostałe trzy skrypty generacji (`map_generator_base`,
`dungeon_generator`, `overworld_forest_generator`) kompilują się poprawnie.

**Status:** autor naprawił to lokalnie (dopisanie dwóch zmiennych), ale zmiana **nie jest
zacommitowana na `main`**.

**Zadanie Z-0 (obowiązkowe, przed czymkolwiek innym):**
1. Zacommitować lokalną naprawę na `main`.
2. Dodać do repo skrypt kontroli składni (§13.1) i uruchamiać go przed każdym commitem.
   Refaktor tej skali bez automatycznej kontroli parsowania jest nieodpowiedzialny —
   ten konkretny błąd przeżył cały commit i push.

**Uwaga merytoryczna po naprawie.** Po przywróceniu zmiennych logika łączników 2H/3H
staje się **asymetryczna**:

```gdscript
# gałąź 1 — TYLKO przypadek "na tej samej wysokości"
if left_is_2h_same and right_has_room_for_3h:            # → CONNECTOR_2H_TO_3H

# gałąź 2 — TYLKO przypadek "na tej samej wysokości"
elif right_is_2h_same and left_has_room_for_3h:          # → CONNECTOR_3H_TO_2H

# gałąź 3 — obsługuje TAKŻE przypadek schodkowy (dy_off = -1)
elif (right_is_2h_same or right_is_2h_step) and not (left_is_2h_same or left_is_2h_step):
                                                         # → CONNECTOR_3H_TO_2H (± offset)
```

Kierunek **3H → 2H** ma obsługę schodkową (gałąź 3), kierunek **2H → 3H** jej **nie ma**
(dawna gałąź z `dy_off` dla `left_is_2h_step` została skasowana). Skutek: przejście
2H→3H schodkiem nie dostanie łącznika i zostanie obsłużone dalszymi gałęziami
(OUT corner / schodek 3H), co daje wizualnie inny styk niż w kierunku przeciwnym.

Do zaadresowania w Etapie 5 — nowy `EdgeAnalyzer` musi traktować oba kierunki symetrycznie.

### 3.2. Sześć niezależnych implementacji analizy sąsiedztwa

| Lokalizacja | Co liczy | Linie |
|---|---|---|
| `_smooth_cave_junctions` | `floor_cardinal`, `floor_corners` | 571–583 |
| `_enforce_wall_thickness` | `floor_count` | 641–649 |
| `_cleanup_grid_before_tiling` | `w_n`, `w_s`, `w_w`, `w_e`, `wall_cardinal` | 787–800 |
| `_flatten_short_3h_bulges` | `is_col_2h`, `is_col_3h_plus` (lambdy) | 841–852 |
| `apply_cave_tiles` FAZA 2 | `has_same_y`, `check_2h_col`, `w_open`, `e_open`, `left_y`, `right_y` | 1094–1185 |
| `apply_cave_tiles` FAZA 3 / FAZA 4 | `n_floor`, `nw_floor`, `ne_floor`, `w_floor`, `e_floor`, `se_floor`, `sw_floor` | 1563–1566, 1588–1595 |

Każda z nich używa innej konwencji (jedna liczy podłogi, inna ściany; jedna toleruje
`abs(dy) <= 1`, inna `<= 4`, inna wymaga dokładnej równości). To źródło niespójności,
które RD-2 poprawnie diagnozuje.

### 3.3. Cykl priorytetów — dowód, że priorytety liniowe nie odtworzą obecnego zachowania 1:1

Obecny system używa `placed_tiles: Dictionary[Vector2i -> String]` i **nie ma jednej reguły**.
Każda gałąź ma własny warunek nadpisania. Wyekstrahowane warunki:

| Piszący | Warunek zapisu | Linia |
|---|---|---|
| `ROCK` | brak warunku (FAZA 1, pierwszy) | 1072 |
| `FACADE` | **brak warunku** — nadpisuje wszystko | wiele |
| `CORNER` (w gałęzi 2H OUT) | **brak warunku** | 1224–1227, 1263–1266 |
| `CORNER` (zakończenie proste, FAZA 2.5, schodek `dy>1`) | `not has or == "ROCK"` | 1486, 1510, 1539, 1568 |
| `SIDE_FIXED` | `not has or == "ROCK"` | 1229, 1243, 1268, 1284 |
| `SIDE` (FAZA 3) | `not has or == "ROCK"` | 1570, 1578 |
| `RIM` (główny, `pos`) | pomija tylko `"FACADE"` i `"SIDE_FIXED"` | 1601 |
| `RIM_TIP` roots (`pos-(0,1)`) | pomija tylko `"FACADE"` | 1620 |
| `RIM_BOWL` roots (`pos+(0,1)`) | pomija `"FACADE"`, `"SIDE_FIXED"`, `"CORNER"` | 1621 |
| `RIM_BOWL` rock (`pos+(0,1)`) | `not has or == "ROCK"` | 1613, 1620 |
| `RIM` diagonalny (`nw_floor`/`ne_floor`) | `not has or == "ROCK"` | 1686, 1691 |
| `PORTAL` | `erase_cell()` na końcu, bezwarunkowo | 1694–1696 |

Z tego wynika **cykl**:

```
RIM        >  CORNER        (FAZA 4 nie pomija "CORNER")
CORNER     >  SIDE_FIXED    (gałąź 2H OUT pisze CORNER bezwarunkowo)
SIDE_FIXED >  RIM           (FAZA 4 pomija "SIDE_FIXED")
```

**Wniosek:** jednoliczbowe priorytety **nie mogą** odtworzyć obecnego zachowania dokładnie.
Cykl trzeba zerwać świadomą decyzją. Rekomendacja (§10.2): ujednolicić `CORNER` do wariantu
z warunkiem (nie nadpisuje `SIDE_FIXED` ani `FACADE`), co daje spójny porządek liniowy.
Jedyna zmiana zachowania: w gałęzi 2H OUT narożnik `p_in` przestanie nadpisywać wcześniej
położony `SIDE_FIXED`/`FACADE`. Wymaga weryfikacji wizualnej (§14, P1-3).

Drugi konflikt: **miska pod zakończeniem rimu ma dwa różne warunki nadpisania** zależnie
od motywu (rock: nadpisuje tylko `ROCK`; roots: nadpisuje też `SIDE` i `RIM`).
**Rozwiązany projektowo** dwiema kategoriami placementu — `RIM_BOWL` (15) dla rock
i `RIM_BOWL_DECORATED` (42) dla roots — co zachowuje oba obecne zachowania dokładnie.
Pełne wyjaśnienie, co to jest i skąd nazwa: §6.7.

Trzeci konflikt: obecny system rozdziela **priorytet zapisu** od **priorytetu blokowania**.
`SIDE_FIXED` zapisuje się tylko na `ROCK` (niski priorytet zapisu), ale blokuje `RIM`
(wysoki priorytet blokowania). W modelu jednoliczbowym te dwie role się zlewają.
W praktyce różnica nie wystąpi, bo `SIDE_FIXED` powstaje w FAZIE 2, a `RIM` w FAZIE 4 —
w momencie zapisu `SIDE_FIXED` żaden `RIM` jeszcze nie istnieje. **Ale trzeba to udokumentować**
w komentarzu przy tabeli priorytetów, żeby nikt nie "poprawił" tego w przyszłości.

### 3.4. Rozspójnienie flag między `generate()` i `apply_cave_tiles()`

```gdscript
# procedural_level.gd
gen_result = CaveGeneratorScript.generate(w, h, seed, 6, 24, rooms_count)   # flags = null → default #1
CaveGeneratorScript.apply_cave_tiles(floor, walls, gen_result, rng, decor)  # flags = null → default #2
```

Dziś działa, bo oba są domyślne. Ale:

- `flags.enable_grid_cleanup` jest sprawdzane **wyłącznie** w `apply_cave_tiles()`, mimo że
  dotyczy **topologii**. Wyłączenie jej w `generate()` nie ma żadnego efektu.
- `flags.enable_junction_smoothing` jest sprawdzane **wyłącznie** w `generate()`.
- `enable_terrain_smoothing` dotyczy tylko kafelkowania.

To jest bezpośredni dowód na słuszność postulatu RD-1: pre-pass nie ma prawa być w fazie
tilingu. Nowa architektura musi przenosić flagi **wewnątrz `GenerationContext`**, żeby
rozspójnienie było niemożliwe konstrukcyjnie (§8.2).

### 3.5. `apply_cave_tiles()` mutuje `result.grid`

Linie 934–937 wołają `_cleanup_grid_before_tiling()` i `_flatten_short_3h_bulges()`
**na `result.grid`**. Konsekwencje:

1. **Funkcja nie jest idempotentna.** Dwukrotne `apply_cave_tiles()` na tym samym
   `GenerationResult` da inny wynik niż jednokrotne.
2. **`GenerationResult` zwrócony z `generate()` nie opisuje mapy, która trafi na ekran.**
   Podgląd maski (`get_grid_mask_image`) pokazuje stan **po** czyszczeniu tylko dlatego,
   że w `map_generator_preview.gd` maska jest tworzona po `apply_cave_tiles()`.
3. **Ukryte sprzężenie: poprawność kafelkowania zależy od tego, że czyszczenie zostało wykonane.**

Dowód punktu 3. W gałęzi "ściana prosta" (linia 1489) korona jest stawiana bezwarunkowo
na `pos + (0,-3)`:

```gdscript
var crown_t := Vector2i(3, 4) if is_b else Vector2i(2, 4)
walls_layer.set_cell(pos + Vector2i(0, -3), 0, crown_t)     # BRAK sprawdzenia, czy y-3 to ściana
```

Gałąź jest osiągalna, gdy `is_2h == false`, co zachodzi m.in. dla izolowanej,
jednokolumnowej fasady o `solid_depth == 2`. Wtedy `y - 3` jest **podłogą**, a korona
zostaje namalowana w powietrzu nad komorą wyżej. Dziś tego nie widać, bo
`_cleanup_grid_before_tiling()` REGUŁA 1 (`wall_cardinal <= 1`) wycina taki kikut.
Ale przy `flags.enable_grid_cleanup = false` defekt się ujawni.

**Wymóg:** w nowej architekturze pre-passy należą do `generate()` (topologia),
`apply_*` nie ma prawa modyfikować siatki, a placery muszą sprawdzać przesłanki geometryczne
**jawnie**, a nie polegać na tym, że wcześniejszy pass usunął problem.

### 3.6. Kolejność pre-passów — pułapka przy przenoszeniu

`_cleanup_grid_before_tiling()` i drugie `_flatten_short_3h_bulges()` działają **po**
wyrzeźbieniu alkow portalowych (bo są w `apply_cave_tiles()`, a portale w `generate()`).
Naiwne przeniesienie ich do `generate()` "na górę" (np. obok pozostałych pre-passów,
przed `_ensure_rooms_connected()`) **zmieni wynik**, bo alkowy portalowe nie byłyby
znormalizowane.

Jedyna kolejność zachowująca obecne zachowanie 1:1 — patrz §12, Etap 3, tabela P1–P12.

**Dobra wiadomość:** przeniesienie jest **neutralne względem RNG**. `_cleanup_grid_before_tiling()`
i `_flatten_short_3h_bulges()` nie zużywają `RandomNumberGenerator`, a planowanie spawnów
liczy pozycje z `Rect2i` komór (nie z siatki). Etap 3 może więc być **bit-exact**.

### 3.7. Korytarze naprawcze nie są normalizowane

`_ensure_rooms_connected()` (linia 307) rzeźbi nowe korytarze organiczne **po**
`_remove_1height_walls()`, `_enforce_wall_thickness()` i `_flatten_short_3h_bulges()`.
Nowe korytarze mogą więc ponownie wprowadzić ściany 1H, cienkie mostki i ząbki.
Częściowo ratuje to `_cleanup_grid_before_tiling()` z fazy tilingu, ale ono nie zawiera
kontroli grubości poziomej (`_enforce_wall_thickness`).

**Rekomendacja:** w nowym pipeline uruchamiać pre-passy w **pętli zbieżnej** po naprawie
spójności, z twardym limitem iteracji (`cleanup.max_passes`, domyślnie 4) i weryfikacją,
że pętla nie rozłącza komór.

### 3.8. Wydajność

Podgląd dopuszcza mapy do `600 × 600`. Przy `500 × 500`:

| Operacja | Koszt | Linia |
|---|---|---|
| Wypełnienie voidu `-4 … h+4` | `~508 × 508 = 258 064` wywołań `set_cell` | 939–944 |
| Dylatacja 5×5 `near_floor` | do `250 000 × 25 = 6 250 000` wstawień do `Dictionary` | 947–952 |
| FAZA 1 ROCK_FILL | `set_cell` na każdej ścianie (nadpisuje wypełnienie voidu) | 1060–1074 |
| FAZA 2 / 3 / 4 | 3 pełne skany `W × H` | — |

Void jest wypełniany dwukrotnie (raz `WALL_INSIDE`, raz ROCK_FILL). `near_floor`
to najdroższa operacja w całym pipeline.

**Rekomendacje (nieblokujące, Etap 9):**
- Zamienić `near_floor` na jeden skan z testem "czy w promieniu 2 jest podłoga"
  albo na dylatację separowalną (dwa przebiegi 1D).
- Usunąć wypełnianie voidu wewnątrz `0…W × 0…H` (i tak nadpisywane przez FAZĘ 1);
  zostawić tylko ramkę poza mapą.
- **Nie** używać kluczy `String` w `TilePlacementPlan` (§10.4).

### 3.9. Determinizm — `hash()` na `Vector2i`

```gdscript
var r := (int(hash(Vector2i(x, y + rng.seed))) & 0x7fffffff) % 100      # linia 1065
```

Uwagi:
1. `hash()` na `Vector2i` jest funkcją silnika — **stabilną w danej wersji Godota**,
   ale nie gwarantowaną między wersjami. Zapisany seed mógłby dać inny wygląd po
   aktualizacji silnika.
2. Tylko `y` jest przesunięte seedem, `x` nie. Efekt: wzór skały jest tą samą teksturą
   przesuniętą pionowo dla różnych seedów, a nie niezależnym wzorem.

**Rekomendacja:** zastąpić własnym, jawnym hashem całkowitym (np. splitmix64 / PCG
na `int64`), umieszczonym w `core/grid_hash.gd`. To jest zmiana wizualna — wchodzi
razem z decyzją §6.3 w jednym commicie.

---

## 4. Błędy i nieścisłości w RD-1 / RD-2 — korekty

### 4.1. RD-1: sygnatura wrappera `CaveGenerator.generate()` łamie build

RD-1 proponuje:

```gdscript
static func generate(width := 160, height := 160, seed_val := -1, flags: GenerationFlags = null) -> GenerationResult
```

Rzeczywiste wywołanie (`procedural_level.gd:100`):

```gdscript
gen_result = CaveGeneratorScript.generate(map_width, map_height, actual_seed, 6, 24, rooms_count)
```

Przy sygnaturze z RD-1 argument `6` trafiłby na `flags` (błąd typu), a `24` i `rooms_count`
byłyby nadmiarowe (błąd wywołania).

**KOREKTA (obowiązująca):** wrapper musi zachować pełną, obecną sygnaturę:

```gdscript
static func generate(
    width: int = 160,
    height: int = 160,
    seed_val: int = -1,
    min_room_size: int = 6,
    max_room_size: int = 24,
    max_rooms: int = 15,
    corridor_width: int = 3,
    flags: GenerationFlags = null
) -> GenerationResult:
    var overrides := {
        "min_room_size": min_room_size,
        "max_room_size": max_room_size,
        "max_rooms": max_rooms,
        "corridor_width": corridor_width,
    }
    return TerrainGenerator.generate(width, height, seed_val, &"caves_default", flags, overrides)
```

**Wniosek ogólny:** `TerrainProfile` **musi** dopuszczać nadpisania runtime parametrów
topologii. `max_rooms` jest liczone dynamicznie z pola mapy (`procedural_level.gd:96-99`,
zakres `[4, 120]`) i nie może być zaszyte w JSON-ie.

### 4.2. RD-1 vs RD-2: dwa sprzeczne `EdgeKind`

RD-1 proponuje płaski enum z 24 wartościami (`FACADE_2H`, `FACADE_3H`, `SIDE_WALL_WEST`,
`SIDE_WALL_EAST`, `TOP_RIM_LEFT_END`, `OUT_CORNER_SW`, `PILLAR_LEFT`, …).
RD-2 proponuje ortogonalny rozkład na `kind + orientation + height + segment_kind + theme + variant`.

Te modele się wykluczają. RD-1 jest dokładnie tym, przed czym RD-2 ostrzega
("nie tworzyć osobnego typu dla każdej kombinacji wysokości, kierunku i stylu").

**KOREKTA:** obowiązuje model **RD-2** (ortogonalny). Enum `EdgeKind` z RD-1 należy
zignorować w całości. Docelowa definicja: §9.2.

### 4.3. RD-1/RD-2: tabela priorytetów jest odwrotna do rzeczywistości

RD-1 i RD-2 podają identyczną tabelę, w której `RIM_BASE` = 70, `RIM_TIP` = 71,
a `FACADE` = 50 i `CORNER/STEP` = 60. Oznacza to, że **rim nadpisuje fasadę**.
Kod robi odwrotnie (FAZA 4, linia 1601: `if placed_tiles[pos] == "FACADE" … continue`).

Przyjęcie tabeli z RD-1/RD-2 zmieniłoby wygląd: rimy zaczęłyby zamazywać korony
i szczyty fasad 3H/2H, a kryterium "Cave Generator działa wizualnie co najmniej tak samo
dobrze jak przed refaktorem" stałoby się niespełnialne.

**KOREKTA (decyzja autora §6.1):** priorytety są **przełącznikiem w profilu**.
Domyślny preset = `legacy_facade_wins` (odtworzenie obecnego zachowania).
Drugi preset = `readme_rim_wins` (kolejność z RD-1/RD-2). Wybór po porównaniu zrzutów.
Pełne tabele: §10.2.

### 4.4. RD-1: filary nie istnieją

RD-1 Etap 1 nakazuje "Zweryfikować rim capping, filary, schodki 2H/3H, nisze i portale".

Stan faktyczny:

- **Filary: nie istnieją.** `_build_free_standing_pillars()` i `_assemble_pillar()`
  usunięto w commicie `0956687`. W całym `modules/quiz_rpg/scripts/` nie ma słowa
  `pillar` poza jednym komentarzem (linia 424).
- **Rim capping: flaga martwa.** `flags.enable_rim_capping` — 0 użyć.
- **Schodki 2H: nie istnieją.** Moduły atlasu `(1,19..21)` i `(4,19..21)` zadeklarowane,
  nieużywane.
- Nisze i portale: **istnieją i działają**.

**KOREKTA:** Etap 1 weryfikuje tylko: fasady 2H, fasady 3H, schodki 3H (`MOD_CRNR_*_IN`),
zakończenia OUT (`MOD_CRNR_*_OUT`), łączniki 2H↔3H, nisze (standardowa + sekretna),
rimy (rock 1-kaflowy i roots BASE+TIPS), narożniki diagonalne, portale.
Filary są zadaniem **nowym** (§6.2), wchodzą jako Etap 10, **po** osiągnięciu parytetu wizualnego.
Odzyskanie starej implementacji jako punktu wyjścia:

```
git show 0792c03:modules/quiz_rpg/scripts/generation/cave_generator.gd | sed -n '1653,1700p'
```

### 4.5. RD-2: 8-kierunkowa orientacja jest nadmiarowa i myląca

RD-2 podaje przykład `kind = OUT_CORNER`, `orientation = SOUTH_EAST`, `height = 2`
i sam dodaje: "Dokładne przypisanie `SOUTH_EAST` / `SOUTH_WEST` należy potwierdzić wizualnie".

W tym tilesecie fasady są **wyłącznie południowe** (patrzą w dół, na komorę). Narożnik OUT
ma tylko dwa sensowne warianty: koniec zachodni i koniec wschodni. Nazwa `SOUTH_EAST`
nie wnosi informacji, a wymusza arbitralną decyzję, którą RD-2 sam zostawia otwartą.

**KOREKTA — kanoniczna, wiążąca konwencja orientacji.**
`orientation` nazywa **stronę otwartą** (tę, po której jest podłoga):

| Sytuacja w kodzie | `kind` | `orientation` | Moduł rock |
|---|---|---|---|
| `w_open` (podłoga na zachód przy y-1, y-2) | `OUT_CORNER` | `WEST` | `MOD_CRNR_NW_OUT` kol. 0 |
| `e_open` (podłoga na wschód przy y-1, y-2) | `OUT_CORNER` | `EAST` | `MOD_CRNR_NE_OUT` kol. 5 |
| `left_y != -1 and y > left_y` (opada z lewej w prawo) | `STEP` | `WEST` | `MOD_CRNR_NW_IN` kol. 1 |
| `right_y != -1 and y > right_y` (opada z prawej w lewo) | `STEP` | `EAST` | `MOD_CRNR_NE_IN` kol. 4 |
| Ściana boczna, podłoga na wschód (`e_floor and not w_floor`) | `SIDE_WALL` | `EAST` | `WALL_SIDE_WEST` kol. 5 |
| Ściana boczna, podłoga na zachód (`w_floor and not e_floor`) | `SIDE_WALL` | `WEST` | `WALL_SIDE_EAST` kol. 0 |
| Fasada prosta | `FACADE` | `SOUTH` | `WALL_BOTTOM_*` / `WALL_2H_*` |
| Rim prosty | `TOP_RIM` | `NORTH` | `WALL_TOP` |
| Rim cap (`e_floor and not w_floor`) | `TOP_RIM` | `NORTH` + `segment = START` | `(5,1)` |
| Rim cap (`w_floor and not e_floor`) | `TOP_RIM` | `NORTH` + `segment = END` | `(0,1)` |
| `nw_floor and not ne_floor and not w_floor` | `INNER_CORNER` | `NORTH_WEST` | `(1,1)` |
| `ne_floor and not nw_floor and not e_floor` | `INNER_CORNER` | `NORTH_EAST` | `(4,1)` |

> **PUŁAPKA NAZEWNICZA — przeczytać dwa razy.**
> Stałe `WALL_SIDE_WEST` / `WALL_SIDE_EAST` w obecnym kodzie nazywają **ścianę pomieszczenia**,
> nie stronę otwartą. `WALL_SIDE_WEST` = zachodnia ściana komory = kafel po lewej stronie
> pokoju = podłoga jest **na wschód** od niego.
> Nowy kod **nie może** dziedziczyć tej konwencji. W profilu klucz to
> `side_wall.east` (orientacja = strona otwarta) → moduł `(5,2)/(5,3)`.
> Migracja musi to jawnie odwrócić i opatrzyć komentarzem — inaczej ściany boczne
> zamienią się stronami i cała mapa będzie wyglądać "wywrócona na lewą stronę".

Docelowy enum `EdgeOrientation` jest pełny (9 wartości — `INNER_CORNER` potrzebuje diagonali),
ale z **jawnym ograniczeniem dozwolonych orientacji per `EdgeKind`**, wymuszanym przez
walidator (§9.4). Kombinacja `OUT_CORNER + SOUTH_EAST` musi zostać odrzucona jako niepoprawna.

### 4.6. RD-2: `_resolve_facade_height()` nie opisuje faktycznej semantyki

RD-2 podaje:

```gdscript
if solid_depth >= 3 and profile.feature_enabled(&"facades_3h"): return 3
if solid_depth >= 2 and profile.feature_enabled(&"facades_2h"): return 2
return 1
```

Problemy:

1. Zwraca `1` dla `solid_depth == 1`, ale w tym tilesecie **nie ma modułu fasady 1H** —
   `solid_depth == 1` jest niedopuszczalny i musi być wyeliminowany w pre-passie,
   a nie "obsłużony" jako wysokość 1.
2. Nie wyraża, że **3H konsumuje wiersz rimu, a 2H nie** (§2.6).
3. Nie wyraża, że przy `solid_depth > 3` moduł nadal ma wysokość 3, a nad nim
   zostaje `ROCK_FILL` + osobny rim.
4. Nie wyraża, że **motyw `roots` nie ma modułu 2H** i wymaga fallbacku (§5.7).

**KOREKTA:**

```gdscript
# edge/facade_height_resolver.gd
class_name FacadeHeightResolver
extends RefCounted

enum { INVALID = 0, H2 = 2, H3 = 3 }

static func resolve(solid_depth: int, ctx: GenerationContext) -> int:
    if solid_depth >= 3 and ctx.feature(&"allow_3h_facades"):
        return H3
    if solid_depth == 2 and ctx.feature(&"allow_2h_facades"):
        return H2
    if solid_depth >= 3:
        return H3      # 3H wyłączone w profilu, ale 2H nie pasuje do gł. 3+ → i tak 3H
    if solid_depth == 2:
        return H2      # 2H wyłączone w profilu, ale nie ma czym zastąpić → i tak 2H
    push_error("FacadeHeightResolver: solid_depth=%d — niezmiennik WallThicknessPass naruszony przy %s"
        % [solid_depth, str(ctx.debug_pos)])
    return INVALID
```

`TileRule` dla `FACADE` musi nieść dodatkowe pola:

```
rows_above: int            # 1 dla 2H, 3 dla 3H
consumes_rim_row: bool     # false dla 2H, true dla 3H
draws_on_floor_row: bool   # true — base leży na komórce PODŁOGI (efekt 2.5D)
```

### 4.7. RD-2: przykłady "kolanko OUT" mają sprzeczną konwencję

RD-2 podaje dwa przykłady i **obu** przypisuje `orientation = SOUTH_EAST`:

```text
przykład 1:        przykład 2:
0 1 1              0 0 1
0 0 1              0 0 1
0 0 1              1 1 1
```

W przykładzie 1 podłoga jest po stronie wschodniej i północnej, w przykładzie 2 —
wschodniej i południowej. To są dwie różne sytuacje geometryczne, więc nie mogą mieć
tej samej etykiety. Przykłady są więc wewnętrznie sprzeczne i nie nadają się na fixture'y.

**KOREKTA:** wszystkie fixture'y gridowe zapisujemy w notacji ASCII identycznej
z `print_grid_mask_ascii()` (`#` = WALL, `.` = FLOOR, `S` = ENTRANCE, `E` = EXIT).
Przykłady z RD-2 należy odrzucić i zastąpić fixture'ami z §16.2, wygenerowanymi
narzędziem `dump_edge_fixtures.gd` (§13.4) z **rzeczywistego** kodu, a nie pisanymi ręcznie.

### 4.8. RD-1: `TilePlacementPlan.queue()` — klucz `String` i reguła remisu

RD-1 podaje:

```gdscript
var key := "%s:%d:%d" % [placement.layer, placement.pos.x, placement.pos.y]
…
if placement.priority >= existing.priority:
    placements[key] = placement
```

Dwa problemy:

1. **Wydajność.** Przy `500 × 500` to setki tysięcy formatowań stringów i alokacji
   (§3.8) — dokładnie w najgorętszej pętli całego systemu.
2. **`>=` jest semantycznie niedeterministyczne.** Przy równym priorytecie wygrywa
   **ostatni wstawiony**, czyli wynik zależy od kolejności placerów — dokładnie tego,
   co refaktor ma wyeliminować.

**KOREKTA:** §10.4 — klucz zagnieżdżony per warstwa, reguła remisu jawna i deterministyczna
(`>` zamiast `>=`, plus `tie_breaker`).

### 4.9. RD-1: `caves_debug.json` z "fixed seed"

Seed **nie jest** własnością profilu terenu — jest parametrem uruchomienia
(`TerrainGenerator.generate(…, seed_value, …)`). Umieszczenie go w profilu łamie rozdział
"profil = możliwości terenu" / "flagi = konkretne uruchomienie", który RD-1 sam wprowadza.

**KOREKTA:** `caves_debug.json` zawiera wyłącznie `features` / `cleanup` / `probabilities`
nastawione na diagnostykę. Seed przekazuje narzędzie podglądu.

### 4.10. Pozostałe, drobniejsze korekty

| RD | Twierdzenie | Korekta |
|---|---|---|
| RD-1 | `EdgeContext` bez `orientation` i `segment_kind` | Użyć wersji z RD-2 (pełnej) |
| RD-1 | `"room_padding": 5` | Kod używa **asymetrycznego** marginesu: `Rect2i(rx-5, ry-6, rw+10, rh+12)` — 5 poziomo, 6 pionowo. Profil musi mieć `room_padding_x: 5` i `room_padding_y: 6` |
| RD-1 | `"extra_loop_count": 3` | Kod używa `mini(3, rooms.size() / 3)` — wartość z profilu jest **górnym ograniczeniem**, nie stałą. Dodatkowo `loop_attempts < 25` i warunek dystansu `d < max(w,h) * 0.45` |
| RD-1 | `"corridor_width": 3` | Zgodne z domyślną wartością `generate()`. `procedural_level.gd` nie przekazuje tego argumentu → używana jest wartość domyślna `3` |
| RD-1 | `"min_room_size": 6, "max_room_size": 24, "max_rooms": 15` | Zgodne z domyślnymi, ale `procedural_level.gd` przekazuje `6, 24, rooms_count`. Profil podaje wartość domyślną, override wygrywa |
| RD-1 | `"secondary_theme_threshold": 0.14` | Zgodne z kodem (linia 1055) |
| RD-1 | `"theme_frequency": 0.08`, `"variant_frequency": 0.45` | Zgodne z kodem (linie 1029, 1033) |
| RD-1 | `"theme_seed_offset": 333`, `"variant_seed_offset": 777` | Zgodne z kodem (linie 1028, 1032) |
| RD-1 | `"connectivity": "mst_with_loops"` | Zgodne — MST (linie 253–280) + pętle (282–296) |
| RD-1 | struktura katalogów z `terrain_generator.gd` obok `cave_generator.gd` | Zaakceptowana bez zmian |
| RD-1 | `"tileset_path"` w profilu | Zgodne, ale uwaga: `procedural_level.gd:113` czyta `palette.get("tileset_path", …)` z `get_default_palette()`. Wrapper `CaveGenerator.get_default_palette()` musi zostać, dopóki `procedural_level.gd` nie przejdzie na profil |
| RD-2 | "Nie należy blokować dekoracji tylko dlatego, że komórka zawiera `ROCK_FILL`" | Zgodne z kodem — `RIM_TIP` roots już dziś nadpisuje `ROCK` (linia 1620). Postulat opisuje stan istniejący, nie zmianę |
| RD-2 | `EdgeContext.neighborhood_mask` (8 bitów) | Zaakceptowane. Bitowa kolejność z RD-2 (N=1, NE=2, E=4, SE=8, S=16, SW=32, W=64, NW=128) jest wiążąca |

---

## 5. Luki w RD-1 / RD-2 — czego brakuje

### 5.1. Autotiling terenów — nie da się wyrazić jako placement per-komórka

Oba dokumenty modelują wyłącznie `set_cell(pos, source, atlas_coords)`. Ale podłoga
używa **autotilingu terenowego Godota**:

```gdscript
floor_layer.set_cells_terrain_connect(mud_cells, 0, 1, true)             # linia 995
floor_decor_layer.set_cells_terrain_connect(grass_cells, 0, 2, true)     # linia 1024
```

`set_cells_terrain_connect()` jest operacją **na zbiorze komórek**: silnik sam dobiera
kafle przejściowe i **modyfikuje także komórki sąsiadujące** ze zbiorem, żeby zszyć
granice terenu. Nie istnieje odwzorowanie tej operacji na niezależne placementy per-komórka.

**Wymóg architektoniczny — osobny plan:**

```gdscript
class_name TerrainPaintPlan
extends RefCounted

class TerrainBatch:
    extends RefCounted
    var layer: StringName          # &"Floor" | &"FloorDecor"
    var cells: Array[Vector2i] = []
    var terrain_set: int = 0
    var terrain: int = 0
    var ignore_empty_terrains: bool = true
    var order: int = 0             # kolejność wykonania batchy na tej samej warstwie

var batches: Array[TerrainBatch] = []
```

Kolejność wykonania (obowiązkowa, odtwarza obecne zachowanie):

1. `TilePlacementExecutor` → warstwa `Floor`: baza `(10,13)` per-komórka.
2. `TerrainPaintExecutor` → warstwa `Floor`: batch `Mud` (`terrain_set 0`, `terrain 1`).
3. `TerrainPaintExecutor` → warstwa `FloorDecor`: batch `Grass` (`terrain_set 0`, `terrain 2`).
4. `TilePlacementExecutor` → warstwa `Walls`: wszystkie placementy ścian.
5. `PortalClearExecutor` → warstwa `Walls`: wymazania.

`Floor`/`FloorDecor` i `Walls` to rozłączne warstwy, więc konflikt priorytetów między
nimi nie występuje. Priorytety `FLOOR_BASE` / `FLOOR_DECOR` z RD-1 są technicznie zbędne,
ale zostają w tabeli dla czytelności.

**Do zachowania 1:1** (parametry masek terenu, linie 962–1024):

```
mud_noise.seed      = rng.seed + 202       mud próg:   noise > -0.02
mud_noise.frequency = 0.035
grass_noise.seed      = rng.seed           grass próg: noise >  0.10
grass_noise.frequency = 0.13
```

Obie maski są przepuszczane przez `_clean_terrain_mask()` (dopełnianie klastrów 2×2
+ łatanie styków diagonalnych) przy `enable_terrain_smoothing = true`, albo przez
uproszczoną wersję inline przy `false`. Strefy portali są **wykluczone** z obu masek.

> **Uwaga:** komentarz w nagłówku pliku (linia 27) mówi "Podłoga porośnięta mchem/trawą …
> terrain 1", a kod używa `terrain 2` dla trawy. Poprawna jest wartość z kodu:
> `terrain 0 = Ground`, `terrain 1 = Mud`, `terrain 2 = Grass` (potwierdzone
> w `caves.tres`, sekcja `[resource]`). Komentarz do poprawienia.

### 5.2. Model "wymazania" kafla (portal)

Linie 1694–1696:

```gdscript
for p in portal_zone:
    walls_layer.erase_cell(p)
```

Ani RD-1, ani RD-2 nie mają dla tego reprezentacji. RD-1 pisze tylko "Portal ma zawsze
wygrywać z każdym innym placementem", ale portal **nie stawia kafla** — on **usuwa** kafle.

**Wymóg:** `TilePlacement` z `atlas_coords == Vector2i(-1, -1)` oznacza **wymazanie**.
Executor wywołuje wtedy `erase_cell()` zamiast `set_cell()`. Kategoria `&"PORTAL_CLEAR"`,
priorytet `1000`.

Dodatkowo `GenerationContext.portal_zone: Dictionary[Vector2i -> bool]` musi być dostępny
dla klasyfikatora **przed** placementem — dziś nisze są blokowane w strefie portalu
(linia 1381), a wymazanie następuje dopiero na końcu. W nowej architekturze `portal_zone`
jest wypełniany raz, w fazie topologii, i jest tylko do czytania w fazie tilingu.

### 5.3. Brak frameworka testowego

RD-2 wymaga: "Dla każdej nowej reguły edge detectionu dodać test gridowy i screenshot /
preview seedowy". W repo:

- brak katalogu `tests/`,
- brak GUT / GdUnit4 w `addons/`,
- brak jakiegokolwiek runnera.

**Wymóg:** Etap 1 musi dostarczyć minimalną infrastrukturę weryfikacji, **bez** dodawania
zewnętrznego addonu (żeby nie rozdmuchiwać zakresu i nie wprowadzać zależności do repo
z submodułami). Projekt: §13.

### 5.4. Kontrakt determinizmu jako testowalny artefakt

RD-1 podaje kryterium "ten sam seed + profil + flagi daje ten sam wynik", ale nie mówi,
**jak to sprawdzić**. Bez maszynowego artefaktu kryterium jest nieweryfikowalne i
w praktyce nikt go nie sprawdzi.

**Wymóg:** `TilePlacementPlan.compute_digest() -> String` (SHA-256 kanonicznej serializacji)
oraz snapshoty trzymane w repo. Szczegóły: §13.3.

### 5.5. Planowanie spawnów jako jawny moduł

RD-1 wymienia "Interior decoration and spawn planning" w pipeline, ale nie definiuje
kontraktu. Dziś logika spawnów siedzi w `generate()` (linie 344–364) i zapisuje wprost
do `GenerationResult.enemy_spawns` / `chest_spawns`.

Znane słabości do zaadresowania:

- pozycje liczone jako `room.get_center() + Vector2i(rng.randi_range(-2,2), rng.randi_range(-2,2))`
  **bez sprawdzenia przechodniości** → wróg może wylądować w ścianie (§14, P2-4);
- boss na `exit_room.get_center() + Vector2i(0, -2)` — również bez sprawdzenia;
- przypisanie roli komory przez `i % 2` — sztywne, nieprofilowane;
- `result.player_spawn` = centrum alkowy wejściowej, co jest poprawne, ale nie
  jest weryfikowane po pre-passach.

**Wymóg:** `spawn/spawn_planner.gd` przyjmujący **finalną** siatkę (po wszystkich
pre-passach) z obowiązkiem walidacji `GridUtils.is_walkable()` i fallbackiem
do najbliższej przechodniej komórki (BFS o promieniu max 4).

### 5.6. Kontrakt warstw fizyki i `y_sort_origin`

§2.10. Profil musi deklarować wymagania fizyki per kategoria kafla, a walidator
sprawdzać je przeciwko `TileSet`. Dla `caves.tres` to no-op (kolizje są już w zasobie),
ale dla castle/library brak tej walidacji oznacza mapy, przez które można przejść.

```json
"physics_requirements": {
  "SOLID_FILL":  { "layers": [0] },
  "FACADE":      { "layers": [0] },
  "SIDE_WALL":   { "layers": [0] },
  "RIM_BASE":    { "layers": [0] },
  "RIM_TIP":     { "layers": [1], "note": "dekoracja — tylko PlatformCollisions" },
  "PORTAL_CLEAR":{ "layers": [] }
}
```

Walidator weryfikuje, że każdy kafel przypisany do danej kategorii ma w `TileSet`
niepustą geometrię kolizji na wskazanych warstwach fizyki (i tylko na nich).

### 5.7. Fallback motywu

§2.9. Profil musi umieć powiedzieć: "motyw `roots` nie ma reguły dla `FACADE + 2H`
→ użyj reguły motywu `rock`". Bez tego refaktor albo rzuci błąd, albo postawi pusty kafel.

```json
"themes": {
  "primary": "rock",
  "secondary": "roots",
  "fallback": { "roots": "rock" }
}
```

`TileRuleResolver.resolve()` przy braku reguły dla `theme` idzie łańcuchem `fallback`
i **loguje ostrzeżenie raz na kombinację** (nie raz na komórkę — inaczej konsola utonie).

### 5.8. Kolejność pre-passów względem portali

§3.6. RD-1 Etap 3 mówi "Zachować kolejność passów aktualnego Cave Generatora", ale nie
zauważa, że **dwa passy są dziś w innej funkcji, po wyrzeźbieniu portali**. Bez tabeli
P1–P12 (§12, Etap 3) implementujące AI prawie na pewno przeniesie je w złe miejsce.

### 5.9. Zakres: zamek tak, las nie

Decyzja autora (§6.4, uściślona w §6.8): uniwersalny rdzeń obejmuje **lokacje zamknięte**
(ściany + podłogi). Las do niego **nie należy** — trafia do osobnego generatora
obiektowego.

RD-1 tego nie omawia, ale i nie powinien: jego własna lista celów (castle, library,
dungeon, crypt, temple, laboratory, sewer, mine, technical tunnels, ice cave,
ruined interiors) to wyłącznie wnętrza. Brak analizy
`overworld_forest_generator.gd` nie jest luką RD-1 — jest poprawnym zakresem.

**Luka, która pozostaje realna:** RD-1 nie przewiduje **systemu obiektowego**.
Pipeline z RD-1 kończy się na „Interior decoration and spawn planning", ale traktuje
dekoracje jak kafle. Pod doktryną §6.8 są to dwie rozdzielne warstwy:
kafle (ten generator) i obiekty (osobny generator). Kontrakt wejścia systemu
obiektowego: §6.8 punkt 7.

Dodatkowo `dungeon_generator.gd` ma dwie rzeczy, których jaskinia nie ma:

- `_detect_and_place_doors()` — detekcja drzwi na obrysach pokoi (dziś `CellType.DOOR`);
- `GenerationResult.doors` + `door_scene` w `spawn_entities()`.

Pod doktryną §6.8 drzwi są **obiektem**, więc `DoorGenerator` należy do systemu
obiektowego, a nie do `PortalGenerator`. `PortalGenerator` odpowiada wyłącznie za
geometrię alkow wejścia/wyjścia (kafle i siatka).

### 5.10. `GenerationResult` — brak pól opisujących nowy pipeline

Obecny `GenerationResult` (`map_generator_base.gd:20-33`) nie ma miejsca na dane,
których nowy pipeline potrzebuje:

```gdscript
# DO DODANIA (kompatybilnie — same nowe pola, nic nie usuwamy):
var profile_id: StringName = &""                  # który profil wygenerował ten wynik
var flags_used: RefCounted = null                 # GenerationFlags faktycznie użyte
var overrides_used: Dictionary = {}               # nadpisania runtime
var portal_zone: Dictionary = {}                  # Vector2i -> bool (union entrance+exit)
var corridors: Array[Dictionary] = []             # { from, to, width } — do debugowania
var preprocess_stats: Dictionary = {}             # ile komórek zmienił każdy pass
```

`profile_id` + `flags_used` + `overrides_used` + `seed_used` to **pełny klucz reprodukcji**.
Bez nich snapshot regresyjny nie ma czego opisywać.

---

## 6. Decyzje autora (wiążące)

Te cztery decyzje zostały podjęte przez autora projektu po przedstawieniu analizy.
Implementujące AI **nie ma prawa ich zmieniać** bez wyraźnej zgody autora.

### 6.1. Priorytety placementu = przełącznik w profilu

**Decyzja:** nie wybieramy z góry między zachowaniem obecnym a kolejnością z RD-1/RD-2.
Implementujemy **dwa presety** i wybieramy po porównaniu zrzutów.

```json
"placement": {
  "priority_preset": "legacy_facade_wins"
}
```

- `legacy_facade_wins` — **domyślny**. Odtwarza obecne zachowanie (fasada wygrywa z rimem).
  Używany podczas całego refaktoru jako baza porównawcza.
- `readme_rim_wins` — kolejność z RD-1/RD-2 (rim wygrywa z fasadą).

Obie tabele: §10.2. Preset jest **jedynym** miejscem, gdzie priorytety są zdefiniowane —
żaden placer nie ma prawa mieć liczby priorytetu na sztywno w kodzie.

**Zadanie dodatkowe (Etap 8):** wygenerować zrzuty tej samej mapy (seed `119`, `100×100`)
w obu presetach, obok siebie, i przedstawić autorowi do decyzji.

### 6.2. Filary wracają — ale jako nowy etap, po osiągnięciu parytetu

**Decyzja:** filary mają wrócić w nowej architekturze jako `PillarDetector` + `PillarPlacer`
za flagą `allow_pillars`, **ale dopiero w Etapie 10**, po tym jak Cave Generator osiągnie
parytet wizualny z obecnym stanem.

Uzasadnienie kolejności: dopóki nie ma parytetu, nie da się rozstrzygnąć, czy różnica
na zrzucie wynika z refaktoru czy z nowo dodanych filarów.

Punkt wyjścia — stara implementacja:

```
git show 0792c03:modules/quiz_rpg/scripts/generation/cave_generator.gd | sed -n '1653,1700p'
```

W konsekwencji:

- `EdgeKind.PILLAR` **zostaje** w enumie od Etapu 4 (jako wartość zarezerwowana, nieprodukowana).
- `allow_pillars` **zostaje** w profilu, z wartością `false` do Etapu 10.
- `flags.enable_rim_capping` → **usunąć** (martwa flaga, nie ma żadnej implementacji
  do przywrócenia; nie ma jej nawet w historii gita jako działającej funkcji).

### 6.3. Losowość przechodzi na hash pozycji — zmiana wizualna zamierzona

**Decyzja:** wszystkie decyzje losowe w fazie kafelkowania stają się funkcją
`(seed, x, y)` — niezależną od kolejności skanowania.

Dotyczy (§2.8):

| Co | Było | Będzie |
|---|---|---|
| Warianty A/B ścian bocznych (FAZA 3) | `rng.randi() % 2` | `GridHash.variant_ab(seed, pos)` |
| Nisza standardowa | `rng.randf() < 0.15` | `GridHash.chance(seed, pos, NICHE_SALT) < 0.15` |
| Nisza sekretna (OUT) | `rng.randf() < 0.30` | `GridHash.chance(seed, pos, SECRET_SALT) < 0.30` |
| ROCK_FILL warianty | `hash(Vector2i(x, y + rng.seed))` | `GridHash.pick(seed, pos, ROCK_SALT, weights)` |

**Konsekwencje, które trzeba zaakceptować i zapisać:**

1. Te same seedy dadzą **inny wygląd** niż przed refaktorem. Struktura mapy (topologia,
   komory, korytarze, portale) pozostaje **identyczna** — zmienia się tylko dobór
   wariantów A/B i rozmieszczenie nisz.
2. Kryterium akceptacji zmienia się z "identyczny obraz" na **"brak regresji strukturalnej
   + jakość wizualna nie gorsza"**. Ocena jakości należy do autora.
3. **Baseline snapshotów maszynowych nagrywamy PO tej zmianie**, nie przed.
   Kolejność: Etap 1 nagrywa zrzuty referencyjne "oka" (stary RNG) → Etap 6 wprowadza
   hash w jednym, dedykowanym commicie ze zrzutami przed/po → Etap 6 zamraża nowy
   baseline maszynowy.
4. Dystans między niszami OUT (`OUT_NICHE_MIN_DISTANCE = 10`) był realizowany
   przez listę `out_niche_positions` wypełnianą w kolejności skanowania.
   Przy hashu kolejność nie istnieje, więc trzeba to przerobić na **deterministyczny,
   dwuprzebiegowy wybór**: (1) zebrać wszystkich kandydatów, (2) posortować kanonicznie
   po `(y, x)`, (3) przejść listę zachłannie odrzucając kandydatów bliżej niż 10.
   To jest zachowanie **równoważne** i w pełni deterministyczne.

### 6.4. Zakres: pełna uniwersalizacja, ale etapami

**Decyzja autora (cytat):** *"autor chce, aby wszystko bazowało na uniwersalnym generatorze
bazującym na CaveGenerator, więc to chyba bez znaczenia. Refactor ma polegać właśnie na tym,
aby generator był uniwersalny/modułowy."*

**Wykładnia dla planu:** celem końcowym jest jeden rdzeń dla wszystkich typów lokacji.
Ale realizujemy to **etapami**, bo jednoczesne przepisanie trzech generatorów uniemożliwi
ustalenie, co spowodowało regresję.

| Faza | Zakres | Etapy |
|---|---|---|
| **A** | Cave Generator → uniwersalny rdzeń. Parytet wizualny. | 0–9 |
| **B** | Filary (przywrócenie w nowej architekturze). | 10 |
| **C** | Zamek → `castle_default` na wspólnym rdzeniu (`RectangularRoomCarver` + `OrthogonalCorridorCarver` + `DoorGenerator`). Biblioteka → `library_default`. | 11 |
| **D** | `ObjectGenerator` — osobny system stawiania obiektów (§6.8). | 12 |

Faza A jest **warunkiem wejścia** do B/C/D. Nie wolno zaczynać fazy C przed zamknięciem A.

Ważne: fazy C i D **nie mogą** usunąć `apply_grid_to_layers()` z `map_generator_base.gd`,
dopóki nie mają pełnego zamiennika — to jedyna ścieżka renderowania dla zamku i lasu dziś.

> **Korekta zakresu (§6.8).** „Wszystko" z decyzji autora oznacza **wszystkie lokacje
> zamknięte** (ściany + podłogi). Las **nie jest** profilem tego generatora — trafia
> do osobnego systemu obiektowego. Zgadza się to z własną listą celów RD-1
> (castle, library, dungeon, crypt, temple, laboratory, sewer, mine, technical tunnels,
> ice cave, ruined interiors) — sama nazwa „Universal **Interior** Generator" mówi,
> że las nigdy nie był w zakresie.

### 6.5. Moduły 2H są poprawne — nie zmieniać

**Decyzja autora (cytat):** *„jak działa to nie ruszaj, 2h są dobrze zrobione."*

Dotyczy punktu P1-1 (§14): narożnik OUT 2H rysuje `base` na `y-1` (wiersz ściany),
`top` na `y-2`, a koronę na `y-3` — inaczej niż fasada prosta 2H, która rysuje
`base` na wierszu podłogi. **To jest zamierzone** i wynika z układu atlasu
(moduły zakończeń 2H zajmują wiersze 19–20, a prosta 2H wiersze 20–21).

**Wiążące konsekwencje dla implementacji:**

1. Punkt P1-1 **przestaje być pytaniem** — jest niezmiennikiem do zachowania 1:1.
2. Reguła profilu dla `out_corner / {west,east} / 2h` **musi** mieć
   `"draws_on_floor_row": false` i `"row_offset": -1`. Zmiana tych wartości
   na „spójne z prostą 2H" jest **błędem**, nie poprawką.
3. Krok 5.10 (Etap 5) jest migracją bit-exact — **nie** jedną ze świadomych zmian wyglądu.
4. Fixture'y `F-11` i `F-12` (§16.2) zapisują obecne, poprawne zachowanie jako
   oczekiwanie. Jeśli po refaktorze przestaną przechodzić — to regresja.
5. Nie „ujednolicać" konwencji `draws_on_floor_row` między wariantami wysokości.
   Model `TileRule` ma te pola właśnie dlatego, że warianty różnią się celowo.

Ogólna zasada wynikająca z tej decyzji, obowiązująca w całym refaktorze:
**różnica między modułami nie jest dowodem defektu.** Jeśli coś wygląda
niekonsekwentnie w kodzie, ale wygląda dobrze na ekranie — zachować i udokumentować,
nie „naprawiać".

### 6.6. `PlatformCollisions` — docelowo Area2D, asymetria jest zamierzona

**Decyzja autora (cytat):** *„Platform collisions będą zaimplementowane tak, że przed
platformami aż do końca kolizji platformy będą area2d dzięki czemu będą funkcjonalne."*

Dotyczy punktu P2-5 (§14): gracz ma `collision_mask = 6` (bez warstwy 6),
przeciwnicy `collision_mask = 39` (z warstwą 6).

**Wykładnia:** `physics_layer_1` tilesetu (`collision_layer = 32`, warstwa projektu 6
`PlatformCollisions`) nie jest docelowo zwykłą kolizją. Ma obsługiwać platformy /
nawisy przez `Area2D` rozciągnięty od przodu platformy do końca jej geometrii kolizji.
Obecna asymetria masek jest stanem przejściowym w kierunku tego rozwiązania,
a nie przeoczeniem.

**Wiążące konsekwencje:**

1. P2-5 **zamknięty** — nie zgłaszać ponownie, nie „naprawiać" masek kolizji.
2. Refaktor generatora **nie dotyka** masek ani warstw fizyki. Kolizje pochodzą
   z `caves.tres` per kafel i pozostają nietknięte, dopóki zachowujemy współrzędne atlasu.
3. Kontrakt `physics_requirements` w profilu (§5.6, §11.3) zostaje — ale jego rolą
   jest **walidacja nowych tilesetów** (castle / library), a nie zmienianie czegokolwiek
   w `caves.tres`.
4. Gdy platformy `Area2D` będą wdrażane, generator może potrzebować nowego wyjścia:
   listy prostokątów platform w `GenerationResult` (np. `platform_zones: Array[Rect2i]`),
   żeby scena mogła z nich utworzyć `Area2D`. **Zanotowane jako przyszłe wymaganie** —
   poza zakresem Etapów 0–12, ale `GenerationResult` jest rozszerzalny (§5.10)
   i dodanie pola nie złamie niczego.

### 6.7. „Rim bowl" — nazwa robocza, konflikt rozwiązany bez decyzji autora

Autor zapytał: *„jakie rim bowl?"* — nazwa `RIM_BOWL` **nie występuje w kodzie**,
została wprowadzona w tym dokumencie jako etykieta kategorii placementu.
Pochodzi od komentarza autora w `cave_generator.gd:1584`:
`# FAZA 4: Dolny rim, półki i misy (Rims & Bowls)`.

**Co to konkretnie jest.** Przy zakończeniu rimu (kafel `(5,1)` lub `(0,1)`) kod stawia
dodatkowy kafel **jedną komórkę NIŻEJ** — „miskę" domykającą półkę:

| Motyw | Zakończenie wschodnie (`e_floor and not w_floor`) | Zakończenie zachodnie (`w_floor and not e_floor`) | Linie |
|---|---|---|---|
| rock | rim `(5,1)` @ `pos`, miska `(4,1)` @ `pos+(0,1)` | rim `(0,1)` @ `pos`, miska `(1,1)` @ `pos+(0,1)` | 1611–1621 |
| roots | rim `(5,10)` + tips `(5,9)`, miska `(4,10)` @ `pos+(0,1)` | rim `(0,10)` + tips `(0,9)`, miska `(1,10)` @ `pos+(0,1)` | 1637–1661 |

Warunek postawienia miski: `not se_floor` (odpowiednio `not sw_floor`) oraz
komórka poniżej musi być ścianą.

**Gdzie był konflikt.** Warunek nadpisania różni się między motywami:

```gdscript
# rock (linie 1613, 1620) — nadpisuje TYLKO pustkę albo ROCK
if not _is_walkable(grid, p_b) and (not placed_tiles.has(p_b) or placed_tiles[p_b] == "ROCK"):

# roots (linia 1621) — nadpisuje też SIDE i RIM
var can_place_base := not _is_walkable(grid, p_b) \
    and not (placed_tiles.has(p_b) and (placed_tiles[p_b] == "FACADE"
             or placed_tiles[p_b] == "SIDE_FIXED" or placed_tiles[p_b] == "CORNER"))
```

Praktyczna różnica jest jedna: **gdy pod zakończeniem rimu stoi ściana boczna
(`SIDE`, z FAZY 3), wariant roots zamaluje ją miską, a wariant rock ją zostawi.**

**Rozwiązanie — bez zmiany wyglądu i bez decyzji autora.** Kategoria placementu jest
daną per motyw w profilu (pole `bowl_category`, §11.4), więc wystarczą **dwie kategorie**:

```
RIM_BOWL            = 15    ← motyw rock:  nadpisuje tylko SOLID_FILL
RIM_BOWL_DECORATED  = 42    ← motyw roots: nadpisuje też SIDE_WALL i RIM_BASE
```

Oba obecne zachowania zostają zachowane **dokładnie**, kosztem jednego dodatkowego
wpisu w tabeli priorytetów. Zgodnie z §6.5: skoro działa, nie ruszamy.

**Konsekwencje:** punkt P1-4 zamknięty jako „rozwiązany projektowo", krok 5.5
w Etapie 5 jest migracją bit-exact, a lista świadomych zmian wyglądu w Etapie 5
skraca się z trzech pozycji do dwóch (P1-3 i P1-5), przy czym obie są najpierw
**pomiarem**, a nie zmianą — patrz §14.

### 6.8. Doktryna: siatka to ściany i podłogi. Wszystko inne jest obiektem

**Decyzja autora (cytat):** *„jakie lasy jak ich jeszcze nie było w kodzie poza tym
pierwszym generatorem który był useless. Las nie będzie przez tileset, Będzie obiektowo
stawiany — Inaczej: Wszystko co nie jest ścianami i podłogami Traktuję jako obiekt,
Do tego będzie osobny generator."*

To jest **najważniejsza decyzja architektoniczna w całym dokumencie** — wyznacza granicę
zakresu uniwersalnego generatora i unieważnia część mojego wcześniejszego planu.

#### Granica

```
   TileMap (ten generator)              Obiekty (osobny generator)
   ──────────────────────────           ──────────────────────────────
   WALL   → warstwa Walls               drzewa, krzewy, woda
   FLOOR  → warstwa Floor               skrzynie, wrogowie, gracz
   terrain Mud   → Floor                drzwi, dźwignie, pochodnie
   terrain Grass → FloorDecor           kolumny, regały, meble
   moduły ścian (fasady, rimy,          grzyby, kałuże, kamienie,
     narożniki, schodki, korzenie)        kości, beczki
```

Kryterium rozstrzygające: **czy to jest kafel na siatce logicznej, czy węzeł w scenie.**
Jeśli węzeł — nie należy do tego generatora.

#### Wiążące konsekwencje

1. **`GridUtils.is_walkable()` pozostaje binarne.** Siatka zna `WALL` i komórki
   przechodnie (`FLOOR`, plus `ENTRANCE` / `EXIT` / `DOOR` jako podtypy podłogi).
   **Anuluje to** wcześniejsze zalecenie z Etapu 2 (zadanie 2.3) o dodawaniu obsługi
   `CellType.TREE`, `WATER` i `PATH` „na potrzeby lasu". Nie dodawać.

2. **Etap 12 zmienia treść.** Nie ma `noise_field_layout_generator.gd` ani
   `natural_path_carver.gd`. Etap 12 to `ObjectGenerator` — osobny system.

3. **`overworld_forest_generator.gd` nie jest wchłaniany.** Autor określa go jako
   „useless"; zostaje nietknięty do czasu, gdy `ObjectGenerator` go zastąpi.
   Wtedy decyzję o usunięciu podejmuje autor.

4. **RD-1 `decoration/` produkuje OBIEKTY, nie kafle.** To istotna korekta RD-1:
   dokument wymienia dla jaskini „Decorators: moss, roots, stones, puddles, mushrooms",
   mieszając dwie różne rzeczy. Poprawny podział:

   | Element z listy RD-1 | Czym jest u nas | Gdzie należy |
   |---|---|---|
   | moss / trawa | terrain `Grass` na `FloorDecor` | **kafel** — ten generator |
   | roots | moduły ścian (`ROOT_*`, w tym TIPS) | **kafel** — ten generator |
   | stones, puddles, mushrooms | propsy | **obiekt** — `ObjectGenerator` |

   Dlatego flagi `allow_floor_decorations` i `allow_top_decorations` **zostają**
   w profilu terenu — dotyczą kafli, nie obiektów.

5. **`spawn/spawn_planner.gd` to zalążek systemu obiektowego.** Obecne
   `enemy_spawns`, `chest_spawns`, `doors`, `decoration_spawns` w `GenerationResult`
   są już listami obiektów — tylko nazwanymi ad hoc.
   **Nie przemianowywać go w Etapach 3–9** (tam obowiązuje bit-exact);
   w Etapie 12 staje się jedną ze strategii wewnątrz `ObjectGenerator`.

6. **Drzwi są obiektem.** `_detect_and_place_doors()` z `dungeon_generator.gd`
   ma produkować wpisy do listy obiektów, a nie `CellType.DOOR`. `CellType.DOOR`
   zostaje wyłącznie jako znacznik przechodniości, jeśli w ogóle będzie potrzebny —
   samo skrzydło drzwi jest sceną (`door_scene`, już dziś instancjonowaną
   w `spawn_entities()`).

7. **Kontrakt wejścia `ObjectGenerator`.** Osobny generator konsumuje **gotowy**
   `GenerationResult`: finalną siatkę, `rooms`, `portal_zone`, `entrance_zone`,
   `exit_zone`, `corridors`. Nie modyfikuje siatki i nie zna atlasu kafli.
   To ta sama reguła izolacji co dla `topology/` ↔ `tiling/` (§7.3).

8. **Las pod tą doktryną to otwarta podłoga plus obiekty.** Jeśli drzewa są węzłami
   z własnymi kolizjami, to siatka lasu nie ma ścian — jest polem przechodnim,
   a układ terenu wynika z gęstości obiektów. Dlatego las **nie jest** profilem
   generatora wnętrz i słusznie ma osobny system.

#### Czego ta decyzja NIE zmienia

Etapy 0–11 pozostają bez zmian. Doktryna dotyczy granicy zakresu i Etapu 12;
nie wpływa na migrację jaskini, bo jaskinia operuje wyłącznie na ścianach i podłogach.
Jedyna korekta wsteczna to punkt 1 (zadanie 2.3 w Etapie 2).

---

## 7. Architektura docelowa

### 7.1. Diagram przepływu

```
                TerrainProfile (JSON)  +  GenerationFlags  +  seed  +  overrides
                                        │
                                        ▼
                            ┌───────────────────────┐
                            │  GenerationContext    │  ← jeden obiekt niesie WSZYSTKO
                            │  profile, flags, rng, │     (uniemożliwia rozspójnienie)
                            │  grid, noises, hash,  │
                            │  portal_zone, stats   │
                            └───────────┬───────────┘
                                        │
   FAZA 1 ── TOPOLOGIA ─────────────────▼──────────────────────────────────────────
   │  RoomPlacer → RoomCarver(strategia) → CorridorCarver(strategia)
   │  → ConnectivityRepair → PortalGenerator
   │  Zna: CellType, Rect2i, RNG.        Nie zna: TileMapLayer, atlasu, motywów.
   └──────────────────────────────────────────────────────────────────────────────
                                        │  grid: Dictionary[Vector2i -> CellType]
   FAZA 2 ── PRE-PROCESSING ────────────▼──────────────────────────────────────────
   │  GridPreprocessor: [GridPass] w ustalonej kolejności (§12 Etap 3, P4–P11)
   │  Zna: grid.                         Nie zna: TileMapLayer, atlasu, motywów.
   └──────────────────────────────────────────────────────────────────────────────
                                        │  grid FINALNY (niezmienny od tego punktu)
   FAZA 3 ── PLANOWANIE SPAWNÓW ────────▼──────────────────────────────────────────
   │  SpawnPlanner → GenerationResult.{player_spawn, enemy_spawns, chest_spawns, doors}
   └──────────────────────────────────────────────────────────────────────────────
                                        │  GenerationResult  ← KONIEC generate()
   ════════════════════════ granica: generate() / apply_tiles() ═══════════════════
                                        │
   FAZA 4 ── ANALIZA KRAWĘDZI ──────────▼──────────────────────────────────────────
   │  EdgeAnalyzer      → Dictionary[Vector2i -> EdgeContext]
   │  FacadeSegmentDetector → Array[FacadeSegment]  (START/MIDDLE/END/SINGLE)
   │  PillarDetector    → Array[PillarCandidate]    (Etap 10)
   │  ThemeResolver     → theme_id per EdgeContext  (3 punkty odniesienia! §2.7)
   │  Zna: grid, profil.                Nie zna: TileMapLayer, atlas coords.
   └──────────────────────────────────────────────────────────────────────────────
                                        │  Array[EdgeContext]
   FAZA 5 ── PLANOWANIE KAFLI ──────────▼──────────────────────────────────────────
   │  TileRuleResolver: (kind, orientation, height, segment, theme) → TileRule
   │  Placery: SolidFill, Floor, SideWall, Facade, Corner, Step, Rim, Niche,
   │           Connector, Pillar, PortalClear
   │  → TilePlacementPlan     (per-komórka, z priorytetami)
   │  → TerrainPaintPlan      (batche autotilingu — §5.1)
   │  Nie wywołuje set_cell().
   └──────────────────────────────────────────────────────────────────────────────
                                        │
   FAZA 6 ── WYKONANIE ─────────────────▼──────────────────────────────────────────
   │  TilePlacementExecutor (Floor) → TerrainPaintExecutor → TilePlacementExecutor
   │  (Walls) → PortalClearExecutor
   │  Jedyne miejsce w całym systemie, które woła set_cell/erase_cell/
   │  set_cells_terrain_connect.
   └──────────────────────────────────────────────────────────────────────────────
                                        │
   ════════════ granica: kafle / obiekty — doktryna §6.8 ═════════════════════════
                                        │  GenerationResult (siatka niezmienna)
   FAZA 7 ── OBIEKTY (OSOBNY SYSTEM) ───▼──────────────────────────────────────────
   │  ObjectGenerator → strategie → ObjectPlacementPlan → ObjectExecutor
   │  Wszystko, co nie jest ścianą ani podłogą: wrogowie, skrzynie, drzwi,
   │  propsy, pochodnie, regały, drzewa.
   │  Zna: siatkę, rooms, portal_zone.   Nie zna: atlasu kafli, TileMapLayer.
   │  Etap 12.
   └──────────────────────────────────────────────────────────────────────────────
```

### 7.2. Struktura katalogów (zatwierdzona, z korektami)

Baza: propozycja RD-1. Zmiany zaznaczone jako **[+]** (dodane) / **[~]** (zmienione).

```
modules/quiz_rpg/scripts/generation/
├── map_generator_base.gd               ← ZOSTAJE (CellType, GenerationResult, spawn, nav)
├── terrain_generator.gd                ← NOWY orkiestrator
├── cave_generator.gd                   ← staje się wrapperem (§4.1)
├── dungeon_generator.gd                ← bez zmian do Etapu 11
├── overworld_forest_generator.gd       ← bez zmian do Etapu 12
│
├── core/
│   ├── cell_type.gd                    [~] re-eksport enumu z map_generator_base
│   ├── generation_context.gd
│   ├── generation_flags.gd
│   ├── generation_result_ext.gd        [+] nowe pola GenerationResult (§5.10)
│   ├── grid_utils.gd
│   ├── grid_hash.gd                    [+] deterministyczny hash (§6.3)
│   ├── seeded_noise.gd
│   ├── tile_placement.gd
│   ├── tile_placement_plan.gd
│   ├── terrain_paint_plan.gd           [+] autotiling (§5.1)
│   └── placement_priority.gd           [+] presety priorytetów (§10.2)
│
├── topology/
│   ├── topology_generator.gd
│   ├── interior_room_layout_generator.gd
│   ├── room_placer.gd
│   ├── room_carver.gd
│   ├── room_carver_factory.gd
│   ├── organic_cave_room_carver.gd
│   ├── rectangular_room_carver.gd
│   ├── circular_room_carver.gd
│   ├── corridor_carver.gd
│   ├── corridor_carver_factory.gd      [+] symetria do room_carver_factory
│   ├── organic_corridor_carver.gd
│   ├── orthogonal_corridor_carver.gd
│   ├── portal_generator.gd
│   └── connectivity_repair.gd
│
├── preprocess/
│   ├── grid_preprocessor.gd
│   ├── grid_pass.gd
│   ├── junction_smoothing_pass.gd      [+] = _smooth_cave_junctions
│   ├── remove_1h_walls_pass.gd         [+] = _remove_1height_walls
│   ├── wall_thickness_pass.gd          [~] = _enforce_wall_thickness
│   ├── spike_cleanup_pass.gd           [~] = _cleanup_grid_before_tiling, REGUŁA 1 + 3A
│   ├── thin_bridge_cleanup_pass.gd     [~] = _cleanup_grid_before_tiling, REGUŁA 2
│   ├── staircase_normalizer_pass.gd    [~] = _cleanup_grid_before_tiling, REGUŁA 3B
│   └── short_bulge_flatten_pass.gd     [~] = _flatten_short_3h_bulges
│
├── edge/
│   ├── edge_context.gd
│   ├── edge_kind.gd                    ← EdgeKind + EdgeOrientation + SegmentKind
│   ├── edge_analyzer.gd
│   ├── facade_height_resolver.gd       [+] §4.6
│   ├── facade_segment.gd
│   ├── facade_segment_detector.gd
│   ├── theme_resolver.gd               [+] §2.7 — trzy punkty odniesienia
│   └── pillar_detector.gd              ← Etap 10
│
├── tiling/
│   ├── tile_rule_resolver.gd           [+] (kind,orient,height,segment,theme) → TileRule
│   ├── tile_placement_planner.gd
│   ├── floor_placer.gd
│   ├── terrain_mask_planner.gd         [+] maski Mud/Grass → TerrainPaintPlan
│   ├── solid_fill_placer.gd
│   ├── facade_placer.gd
│   ├── connector_placer.gd             [+] łączniki 2H↔3H
│   ├── step_placer.gd                  [+] schodki (RD-1 wrzucał je do corner_placer)
│   ├── rim_placer.gd
│   ├── side_wall_placer.gd
│   ├── corner_placer.gd
│   ├── pillar_placer.gd                ← Etap 10
│   ├── niche_placer.gd
│   ├── portal_clear_placer.gd          [+] §5.2
│   ├── tile_placement_executor.gd
│   └── terrain_paint_executor.gd       [+] §5.1
│
├── spawn/
│   └── spawn_planner.gd                [+] §5.5; w Etapie 12 wchłonięty przez objects/
│
├── objects/                            [+] OSOBNY SYSTEM — Etap 12, §6.8
│   ├── object_placement.gd
│   ├── object_placement_plan.gd
│   ├── object_rule.gd
│   ├── object_generator.gd
│   ├── object_executor.gd              ← jedyne instantiate() / add_child()
│   └── strategies/
│       ├── enemy_spawn_strategy.gd
│       ├── chest_spawn_strategy.gd
│       ├── door_strategy.gd            [+] drzwi = obiekt (§6.8 pkt 6)
│       ├── prop_scatter_strategy.gd    ← kamienie, kałuże, grzyby
│       ├── wall_hugger_strategy.gd     ← pochodnie, regały, kolumny
│       └── tree_scatter_strategy.gd    ← las (§6.8 pkt 8)
│
└── profiles/
    ├── terrain_profile.gd
    ├── tile_rule.gd
    ├── terrain_profile_loader.gd
    └── terrain_profile_validator.gd

modules/quiz_rpg/resources/generation/profiles/
├── caves_default.json
├── caves_rock_only.json
├── caves_roots_heavy.json
├── caves_debug.json
├── castle_default.json                 ← szkielet, Etap 11
└── library_default.json                ← szkielet, Etap 11

modules/quiz_rpg/tests/                  [+] §13
├── run_tests.gd                         ← runner headless (extends SceneTree)
├── check_parse.gd                       ← kontrola składni wszystkich .gd
├── fixtures/
│   └── edge/*.txt                       ← fixture'y ASCII
└── snapshots/
    └── *.sha256 / *.txt                 ← snapshoty regresyjne
```

### 7.3. Reguły izolacji (twarde, weryfikowalne mechanicznie)

Te reguły są sprawdzalne skryptem (§13.5) i **muszą** być sprawdzane w każdym etapie:

| Katalog | Nie wolno wystąpić | Uzasadnienie |
|---|---|---|
| `topology/` | `TileMapLayer`, `set_cell`, `Vector2i(` jako atlas coord, `theme`, `roots` | Topologia nie zna wyglądu |
| `preprocess/` | `TileMapLayer`, `set_cell`, `atlas`, `theme` | Pre-pass operuje tylko na siatce |
| `edge/` | `TileMapLayer`, `set_cell`, `erase_cell` | Analiza nie rysuje |
| `tiling/*_placer.gd` | `set_cell`, `erase_cell`, `set_cells_terrain_connect` | Placery kolejkują, nie wykonują |
| `tiling/*_executor.gd` | logika klasyfikacji geometrii | Executor tylko wykonuje plan |
| `core/`, `profiles/` | `TileMapLayer` | Warstwa danych |
| `objects/` (Etap 12) | `TileMapLayer`, `set_cell`, `atlas_coords`, zapis do `grid` | System obiektowy nie zna kafli ani nie zmienia siatki (§6.8) |
| `objects/*` poza `object_executor.gd` | `instantiate`, `add_child`, `queue_free` | Strategie planują, executor wykonuje |
| wszystko poza `profiles/` i `core/placement_priority.gd` | literały priorytetów | Priorytety tylko w presetach |
| wszystko poza `profiles/` | literały współrzędnych atlasu | Atlas tylko w profilu (od Etapu 7) |

**Wyjątek przejściowy:** do Etapu 7 współrzędne atlasu wolno trzymać w stałych GDScript
(przeniesionych 1:1 z `cave_generator.gd`), żeby nie mieszać dwóch źródeł zmian w jednym
etapie. Od Etapu 7 wyjątek przestaje obowiązywać.

---

## 8. Kontrakty i sygnatury API

Wszystkie sygnatury poniżej są **wiążące**. Zmiana którejkolwiek wymaga aktualizacji
tego dokumentu.

### 8.1. `TerrainGenerator` — orkiestrator

```gdscript
class_name TerrainGenerator
extends RefCounted

## Pełny pipeline: topologia → pre-processing → spawny.
## Zwraca GenerationResult z FINALNĄ siatką. Nie dotyka TileMapLayer.
static func generate(
    width: int,
    height: int,
    seed_val: int,
    profile_id: StringName,
    flags: GenerationFlags = null,
    overrides: Dictionary = {}
) -> GenerationResult

## Kafelkowanie. NIE modyfikuje result.grid.
## layers: { &"Floor": TileMapLayer, &"FloorDecor": TileMapLayer, &"Walls": TileMapLayer }
static func apply_tiles(
    layers: Dictionary,
    result: GenerationResult
) -> void

## Wariant zwracający plan bez wykonania — do testów i snapshotów.
static func build_plans(
    result: GenerationResult
) -> Dictionary        # { "tiles": TilePlacementPlan, "terrain": TerrainPaintPlan }
```

> **Uwaga:** `apply_tiles()` **nie przyjmuje** `rng` ani `flags`. Wszystko, czego potrzebuje,
> jest w `GenerationResult` (`seed_used`, `profile_id`, `flags_used`, `overrides_used`).
> To konstrukcyjnie likwiduje problem z §3.4 — rozspójnienie flag staje się niemożliwe.
> Konsekwencja dla `procedural_level.gd`: argument `rng` przy wywołaniu znika.

### 8.2. `GenerationContext` — jeden nosiciel stanu

```gdscript
class_name GenerationContext
extends RefCounted

# --- Wejście (niezmienne po konstrukcji) ---
var profile: TerrainProfile
var flags: GenerationFlags
var overrides: Dictionary
var seed_value: int
var width: int
var height: int

# --- Stan roboczy ---
var rng: RandomNumberGenerator                  # tylko FAZA 1 (topologia) i spawny
var grid: Dictionary = {}                       # Vector2i -> CellType
var portal_zone: Dictionary = {}                # Vector2i -> bool
var rooms: Array[Rect2i] = []
var entrance_pos: Vector2i = Vector2i.ZERO
var exit_pos: Vector2i = Vector2i.ZERO

# --- Szumy (deterministyczne, tworzone raz) ---
var theme_noise: FastNoiseLite                  # seed + profile.noise.theme_seed_offset
var variant_noise: FastNoiseLite                # seed + profile.noise.variant_seed_offset
var mud_noise: FastNoiseLite                    # seed + 202
var grass_noise: FastNoiseLite                  # seed

# --- Diagnostyka ---
var preprocess_stats: Dictionary = {}
var debug_pos: Vector2i = Vector2i.ZERO         # ustawiane przez analizator dla push_error

# --- API ---

## Efektywna wartość cechy: profil AND flagi runtime.
func feature(key: StringName) -> bool:
    var allowed: bool = profile.features.get(key, false)
    var enabled: bool = flags.get_feature(key)     # domyślnie true, jeśli flaga nie istnieje
    return allowed and enabled

## Parametr topologii z uwzględnieniem override runtime.
func param(key: StringName, default_value: Variant) -> Variant:
    if overrides.has(key):
        return overrides[key]
    return profile.topology.get(key, default_value)

## Prawdopodobieństwo z profilu (nadpisywalne flagą).
func probability(key: StringName, default_value: float) -> float
```

**Reguła:** żaden moduł poza `TerrainGenerator` nie tworzy `GenerationContext`.
Każdy pass / analyzer / placer dostaje go jako argument.

### 8.3. `GenerationFlags` — standalone

```gdscript
class_name GenerationFlags
extends RefCounted

# --- Topologia ---
var enable_meandering: bool = true
var enable_variable_width: bool = true
var enable_funnels: bool = true
var enable_junction_smoothing: bool = true

# --- Pre-processing ---
var enable_grid_cleanup: bool = true

# --- Tiling ---
var enable_terrain_smoothing: bool = true
var enable_decorative_niches: bool = true
var enable_pillars: bool = true                 # Etap 10; profil trzyma false do wtedy
var enable_2h_facades: bool = true
var enable_3h_facades: bool = true
var enable_floor_decorations: bool = true

# --- Prawdopodobieństwa (nadpisują profil, gdy >= 0.0) ---
var niche_spawn_chance: float = -1.0            # -1.0 = weź z profilu
var secret_niche_spawn_chance: float = -1.0

# --- Debug ---
var force_theme: int = -1                       # -1 = szum, 0 = primary, 1 = secondary
var debug_log_edge_kinds: bool = false

## Mapowanie klucza cechy profilu na flagę runtime.
## Klucz nieznany → true (flaga nie ogranicza).
func get_feature(key: StringName) -> bool:
    match key:
        &"allow_pillars":             return enable_pillars
        &"allow_niches":              return enable_decorative_niches
        &"allow_secret_niches":       return enable_decorative_niches
        &"allow_2h_facades":          return enable_2h_facades
        &"allow_3h_facades":          return enable_3h_facades
        &"allow_floor_decorations":   return enable_floor_decorations
        _:                            return true
```

> **Migracja:** `flags.enable_rim_capping` — **usunąć** (§6.2).
> `CaveGenerator.GenerationFlags` (klasa wewnętrzna) → alias na nowy typ,
> żeby ewentualny zewnętrzny kod nie pękł:
> `const GenerationFlags = preload("res://.../core/generation_flags.gd")`.

### 8.4. Warstwa topologii

```gdscript
class_name TopologyGenerator
extends RefCounted

## Wypełnia ctx.grid, ctx.rooms, ctx.portal_zone, ctx.entrance_pos, ctx.exit_pos.
func generate(ctx: GenerationContext) -> void:
    push_error("TopologyGenerator.generate() must be overridden")
```

```gdscript
class_name RoomCarver
extends RefCounted

func carve(ctx: GenerationContext, room: Rect2i) -> void:
    push_error("RoomCarver.carve() must be overridden")
```

```gdscript
class_name CorridorCarver
extends RefCounted

func carve(ctx: GenerationContext, from: Vector2i, to: Vector2i, width: int) -> void:
    push_error("CorridorCarver.carve() must be overridden")
```

> **Uwaga do migracji `OrganicCaveRoomCarver`:** obecne `_carve_cave_chamber()`
> przyjmuje `(grid, rect, rng, map_w, map_h)`. Nowy `carve(ctx, room)` bierze
> `rng`/`width`/`height` z `ctx`. **Kolejność zużycia RNG musi zostać identyczna:**
> `randi_range(3,5)` (liczba lobes), potem w pętli `randf_range(0,TAU)`,
> `randf_range(0.2,0.6)` ×2, `randi_range(2, …)`. Zmiana kolejności = inna mapa.

```gdscript
class_name RoomCarverFactory
extends RefCounted

static func create(carver_id: StringName) -> RoomCarver:
    match carver_id:
        &"organic_cave": return OrganicCaveRoomCarver.new()
        &"rectangular":  return RectangularRoomCarver.new()
        &"circular":     return CircularRoomCarver.new()
        _:
            push_error("Unknown room carver: %s" % carver_id)
            return RectangularRoomCarver.new()
```

Analogicznie `CorridorCarverFactory`: `&"organic_meandering"`, `&"orthogonal"`, `&"natural_path"`.

### 8.5. Warstwa pre-processingu

```gdscript
class_name GridPass
extends RefCounted

## Stabilny identyfikator do statystyk i logów.
func get_id() -> StringName:
    push_error("GridPass.get_id() must be overridden")
    return &""

func is_enabled(ctx: GenerationContext) -> bool:
    return true

## Zwraca liczbę zmienionych komórek (0 = brak zmian → pętla zbieżna może się zatrzymać).
func apply(ctx: GenerationContext) -> int:
    push_error("GridPass.apply() must be overridden")
    return 0
```

```gdscript
class_name GridPreprocessor
extends RefCounted

## Uruchamia passy w PODANEJ kolejności. Nie sortuje, nie przestawia.
## Zapisuje do ctx.preprocess_stats: { pass_id: liczba_zmian }.
static func run(ctx: GenerationContext, passes: Array[GridPass]) -> void
```

> **Krytyczne:** `GridPreprocessor` **nie ma** własnej, wbudowanej listy passów.
> Kolejność definiuje `TerrainGenerator` zgodnie z tabelą P1–P12 (§12 Etap 3),
> bo dla jaskini passy są uruchamiane w **dwóch różnych momentach** (przed i po portalach).
> Propozycja RD-1 z listą zaszytą w `GridPreprocessor.apply()` **jest nieprawidłowa**
> i doprowadziłaby do zmiany wyniku.

### 8.6. Warstwa analizy krawędzi

```gdscript
class_name EdgeAnalyzer
extends RefCounted

## Buduje EdgeContext dla każdej komórki wymagającej kafla ściany.
## Zwraca Dictionary[Vector2i -> EdgeContext]. Iteracja kanoniczna: y rosnąco, potem x rosnąco.
static func analyze(ctx: GenerationContext) -> Dictionary

## Pojedyncza komórka — do testów fixture'owych.
static func analyze_cell(ctx: GenerationContext, pos: Vector2i) -> EdgeContext

## Głębokość litej ściany w danym kierunku od komórki podłogi.
static func measure_solid_depth(
    ctx: GenerationContext,
    floor_pos: Vector2i,
    direction: Vector2i,
    max_depth: int = 6
) -> int
```

```gdscript
class_name FacadeSegmentDetector
extends RefCounted

## Wykrywa ciągłe poziome odcinki fasad i rimów na tej samej wysokości.
## Wynik nadaje EdgeContext.segment_kind (SINGLE / START / MIDDLE / END).
static func detect(ctx: GenerationContext, edges: Dictionary) -> Array[FacadeSegment]
```

```gdscript
class_name ThemeResolver
extends RefCounted

enum RefPoint { SELF, NORTH_FLOOR, EAST_FLOOR, WEST_FLOOR }

## Zwraca theme_id dla komórki. ref_point odtwarza trzy różne punkty odniesienia
## z obecnego kodu (§2.7) — MUSI być przekazywany jawnie przez każdy placer.
static func resolve(
    ctx: GenerationContext,
    pos: Vector2i,
    ref_point: int
) -> StringName
```

Mapowanie `ref_point` na obecny kod:

| Placer | `ref_point` | Odpowiednik dziś |
|---|---|---|
| `FacadePlacer`, `StepPlacer`, `NichePlacer`, `ConnectorPlacer`, `CornerPlacer` | `SELF` | `get_use_roots(pos)` |
| `SideWallPlacer`, orientacja `EAST` | `EAST_FLOOR` | `get_use_roots(pos + (1,0))` |
| `SideWallPlacer`, orientacja `WEST` | `WEST_FLOOR` | `get_use_roots(pos + (-1,0))` |
| `RimPlacer` | `NORTH_FLOOR` | `get_use_roots(pos + (0,-1))` gdy `n_floor`, inaczej `pos` |

### 8.7. Warstwa planowania kafli

```gdscript
class_name TileRuleResolver
extends RefCounted

## Zwraca null, gdy reguła nie istnieje nawet po fallbacku motywu.
static func resolve(
    ctx: GenerationContext,
    kind: int,
    orientation: int,
    height: int,
    segment_kind: int,
    theme_id: StringName
) -> TileRule
```

```gdscript
class_name TileRule
extends RefCounted

# Warianty A/B — wybór przez GridHash.variant_ab(), nie przez RNG.
var base_variants: Array[Vector2i] = []
var middle_variants: Array[Vector2i] = []
var top_variants: Array[Vector2i] = []
var crown_variants: Array[Vector2i] = []
var decoration_variants: Array[Vector2i] = []

# Zakończenia segmentu (nadpisują *_variants, gdy niepuste).
var start_base: Vector2i = Vector2i(-1, -1)
var start_decoration: Vector2i = Vector2i(-1, -1)
var end_base: Vector2i = Vector2i(-1, -1)
var end_decoration: Vector2i = Vector2i(-1, -1)

# Geometria modułu.
var rows_above: int = 0                 # ile kafli nad wierszem bazowym
var draws_on_floor_row: bool = false    # czy base leży na komórce PODŁOGI
var consumes_rim_row: bool = false      # czy moduł zawiera własny rim (3H: true)
var decoration_offset: Vector2i = Vector2i(0, -1)   # gdzie idzie dekoracja (roots tips)

# Rozstrzyganie konfliktów.
var category: StringName = &""          # klucz do presetu priorytetów
var layer: StringName = &"Walls"

## Weryfikacja spójności — wołane przez TerrainProfileValidator.
func validate(tileset: TileSet, source_id: int) -> Array[String]
```

```gdscript
class_name TilePlacementPlanner
extends RefCounted

## Uruchamia placery w kolejności z profilu i zwraca oba plany.
static func build(
    ctx: GenerationContext,
    edges: Dictionary,
    segments: Array[FacadeSegment]
) -> Dictionary        # { "tiles": TilePlacementPlan, "terrain": TerrainPaintPlan }
```

### 8.8. `GridHash` — determinizm bez RNG

```gdscript
class_name GridHash
extends RefCounted

## Sole — stałe, NIGDY nie zmieniać po zamrożeniu baseline'u snapshotów.
const SALT_VARIANT_AB   := 0x9E3779B97F4A7C15
const SALT_ROCK_FILL    := 0xC2B2AE3D27D4EB4F
const SALT_NICHE        := 0x165667B19E3779F9
const SALT_SECRET_NICHE := 0x27D4EB2F165667C5

## splitmix64 — deterministyczny między wersjami Godota (czysta arytmetyka int64).
static func mix(seed_value: int, pos: Vector2i, salt: int) -> int

## 0.0 <= wynik < 1.0
static func unit(seed_value: int, pos: Vector2i, salt: int) -> float

## 0 lub 1 — zamiennik ab_noise > 0.0 oraz rng.randi() % 2
static func variant_ab(seed_value: int, pos: Vector2i) -> int

## Ważony wybór indeksu — zamiennik ROCK_FILL (wagi 45 / 47 / 8)
static func pick_weighted(seed_value: int, pos: Vector2i, salt: int, weights: PackedInt32Array) -> int
```

> **Rozstrzygnięte — JEDNA sól.** `variant_ab()` zastępuje **dwie różne** rzeczy:
> `ab_noise.get_noise_2d(x,y) > 0.0` (fasady, rimy, korony) oraz `rng.randi() % 2`
> (ściany boczne). Autor potwierdził wariant z **jedną solą** `SALT_VARIANT_AB`,
> czyli ściany boczne będą miały **ten sam** wzór A/B co fasady i rimy.
>
> Konsekwencja wizualna do sprawdzenia na zrzutach Etapu 6: wzór A/B ścian bocznych
> przestanie być niezależny od wzoru fasad — w miejscach styku ściany bocznej z fasadą
> oba wybiorą ten sam wariant. Efekt powinien być subtelny (wzór zmienia się co 1–2 kratki),
> ale należy go odnotować w punkcie 6.8 listy zadań Etapu 6.
>
> **Nie dodawać** `SALT_VARIANT_AB_SIDE`. Gdyby jednak autor wolał zachować dzisiejszą
> niezależność wzorów, jest to zmiana jednej linii: druga sól dla `SideWallPlacer`.

---

## 9. Model edge detection

### 9.1. `EdgeContext` — pełna definicja

```gdscript
class_name EdgeContext
extends RefCounted

var pos: Vector2i

# --- Sąsiedztwo 3x3 (true = przechodnie) ---
var n_floor: bool
var ne_floor: bool
var e_floor: bool
var se_floor: bool
var s_floor: bool
var sw_floor: bool
var w_floor: bool
var nw_floor: bool

# --- Podsumowanie ---
var floor_cardinal_count: int
var wall_cardinal_count: int
var neighborhood_mask: int          # N=1 NE=2 E=4 SE=8 S=16 SW=32 W=64 NW=128

# --- Klasyfikacja geometryczna ---
var edge_kind: int = EdgeKind.NONE
var orientation: int = EdgeOrientation.NONE
var facade_height: int = 0          # 0 = nie dotyczy, 2 = 2H, 3 = 3H
var solid_depth: int = 0            # zmierzona głębokość ściany (może być > 3)

# --- Segment poziomy ---
var segment_kind: int = SegmentKind.NONE
var segment_index: int = -1         # indeks w Array[FacadeSegment]

# --- Styl ---
var theme_id: StringName = &""
var variant_ab: int = 0             # 0 = A, 1 = B

# --- Kontekst specjalny ---
var in_portal_zone: bool = false
var niche_partner: Vector2i = Vector2i(-1, -1)   # druga kolumna pary niszy
```

### 9.2. Enumy (wiążące)

```gdscript
# edge/edge_kind.gd

enum EdgeKind {
    NONE = 0,
    FLOOR,              # komórka przechodnia (warstwa Floor)
    SOLID_FILL,         # lita skała, brak kontaktu z podłogą wymagającego modułu
    SIDE_WALL,          # ściana pionowa (podłoga po jednej stronie w poziomie)
    FACADE,             # fasada południowa (podłoga pod, ściana nad)
    CONNECTOR,          # łącznik zmiany wysokości fasady (2H <-> 3H)
    STEP,               # schodek fasady (sąsiad na innej wysokości)
    TOP_RIM,            # szczyt ściany widziany z góry
    OUT_CORNER,         # wypukłe zakończenie fasady (koniec masywu)
    INNER_CORNER,       # wklęsły narożnik / domknięcie schodka
    PILLAR,             # ZAREZERWOWANE — Etap 10
    NICHE,              # wnęka dekoracyjna (para kolumn)
    PORTAL_CLEAR        # komórka portalu — kafel usuwany
}

enum EdgeOrientation {
    NONE = 0,
    NORTH, SOUTH, WEST, EAST,
    NORTH_WEST, NORTH_EAST, SOUTH_WEST, SOUTH_EAST
}

enum SegmentKind {
    NONE = 0,
    SINGLE,
    START,
    MIDDLE,
    END
}
```

### 9.3. Kolejność klasyfikacji (wiążąca)

Od najbardziej szczegółowego do najbardziej ogólnego. Pierwsze dopasowanie wygrywa.

```
 1. PORTAL_CLEAR       ← ctx.portal_zone.has(pos)
 2. PILLAR             ← PillarDetector (Etap 10; do wtedy pomijane)
 3. NICHE              ← NicheDetector (para kolumn, wymaga rezerwacji obu)
 4. CONNECTOR          ← zmiana wysokości fasady między sąsiadami w poziomie
 5. STEP               ← sąsiad fasady na innej wysokości (left_y/right_y)
 6. OUT_CORNER         ← koniec masywu ściany (w_open / e_open)
 7. FACADE             ← podłoga pod, >= 2 ściany nad
 8. INNER_CORNER       ← diagonalne domknięcia (nw_floor/ne_floor)
 9. TOP_RIM            ← ściana z podłogą nad sobą
10. SIDE_WALL          ← ściana z podłogą po jednej stronie w poziomie
11. SOLID_FILL         ← ściana bez żadnego z powyższych
12. FLOOR              ← komórka przechodnia
```

> **Różnica względem RD-2.** RD-2 podaje kolejność:
> `PORTAL → PILLAR → CORNER → STEP → FACADE → TOP RIM → SIDE WALL → FLOOR/SOLID`,
> czyli bez `NICHE` i bez `CONNECTOR`, oraz z `OUT_CORNER` **przed** `STEP`.
>
> Korekta jest wymuszona przez obecny kod:
> - `NICHE` musi być **przed** `CONNECTOR`/`STEP`/`FACADE`, bo w obecnym kodzie nisze są
>   sprawdzane w gałęzi `else` po wykluczeniu schodków, ale **rezerwują dwie kolumny**
>   (`pos` i `pos_next`) — muszą więc mieć pierwszeństwo, inaczej `pos_next` zostanie
>   zajęte przez inny placer.
> - `CONNECTOR` musi być **przed** `OUT_CORNER`, bo w obecnym kodzie łączniki 2H↔3H są
>   sprawdzane **przed** `w_open`/`e_open` (linie 1142–1180).
> - `STEP` i `OUT_CORNER` są w obecnym kodzie **rozłączne**: `w_open` zawiera warunek
>   `left_y == -1`, a `e_open` zawiera `right_y == -1`, czyli narożnik OUT może powstać
>   tylko tam, gdzie po tej stronie nie ma sąsiedniej fasady — a `STEP` wymaga
>   dokładnie odwrotnego (`left_y != -1` / `right_y != -1`). W kodzie `w_open`/`e_open`
>   jest sprawdzane pierwsze, ale ponieważ zbiory są rozłączne, **kolejność 5/6
>   nie wpływa na wynik**. Ustalamy `STEP` (5) przed `OUT_CORNER` (6) i wymuszamy
>   rozłączność testem (fixture `F-10`, §16.2), który sprawdza, że żadna komórka
>   nie kwalifikuje się do obu klasyfikacji jednocześnie.

### 9.4. Dozwolone kombinacje (walidator)

Walidator (`TerrainProfileValidator`) odrzuca profil, który definiuje regułę dla
kombinacji nieujętej w tabeli. Analizator loguje `push_error`, jeśli wyprodukuje
kombinację nieujętą w tabeli.

| `EdgeKind` | Dozwolone `orientation` | Dozwolone `facade_height` | Dozwolone `segment_kind` |
|---|---|---|---|
| `FLOOR` | `NONE` | `0` | `NONE` |
| `SOLID_FILL` | `NONE` | `0` | `NONE` |
| `SIDE_WALL` | `WEST`, `EAST` | `0` | `NONE` |
| `FACADE` | `SOUTH` | `2`, `3` | `SINGLE`, `START`, `MIDDLE`, `END` |
| `CONNECTOR` | `WEST`, `EAST` | `2`, `3` | `NONE` |
| `STEP` | `WEST`, `EAST` | `2`, `3` | `NONE` |
| `TOP_RIM` | `NORTH` | `0` | `SINGLE`, `START`, `MIDDLE`, `END` |
| `OUT_CORNER` | `WEST`, `EAST` | `2`, `3` | `SINGLE`, `START`, `END` |
| `INNER_CORNER` | `NORTH_WEST`, `NORTH_EAST`, `SOUTH_WEST`, `SOUTH_EAST` | `0` | `NONE` |
| `PILLAR` | `WEST`, `EAST`, `NONE` | `2`, `3` | `START`, `MIDDLE`, `END`, `SINGLE` |
| `NICHE` | `WEST`, `EAST` | `3` | `START`, `END` |
| `PORTAL_CLEAR` | `NONE` | `0` | `NONE` |

Objaśnienia:

- `CONNECTOR` + `orientation = EAST` znaczy "wyższa strona jest na wschód"
  → `CONNECTOR_2H_TO_3H` (kolumna 7). `WEST` → `CONNECTOR_3H_TO_2H` (kolumna 10).
- `NICHE` + `START` = lewa kolumna pary, `END` = prawa kolumna pary.
- `NICHE` ma tylko `facade_height = 3`, bo w obecnym kodzie nisze powstają wyłącznie
  w gałęzi po wykluczeniu `is_2h` i stawiają 4 kafle (korona + 3 moduły).
- `OUT_CORNER` nie ma `MIDDLE` — narożnik jest z definicji zakończeniem.

### 9.5. Pomiar `solid_depth` — implementacja referencyjna

```gdscript
static func measure_solid_depth(
    ctx: GenerationContext,
    floor_pos: Vector2i,
    direction: Vector2i,
    max_depth: int = 6
) -> int:
    var depth := 0
    for offset in range(1, max_depth + 1):
        var check_pos := floor_pos + direction * offset
        if GridUtils.is_walkable(ctx.grid, check_pos):
            break
        depth += 1
    return depth
```

`max_depth = 6` (nie `4` jak w RD-2), bo klasyfikacja 3H wymaga rozróżnienia
`depth == 3` od `depth > 3` (§2.6), a `_flatten_short_3h_bulges()` operuje
na oknie do `y - 3` włącznie i musi wiedzieć, że wyżej też jest ściana.

### 9.6. Warunki klasyfikacji — odwzorowanie 1:1 z obecnego kodu

Ta tabela jest **kontraktem migracji**. Implementujące AI musi przenieść dokładnie te
warunki, bez "upraszczania".

| Klasyfikacja | Warunek (obecny kod) | Linia |
|---|---|---|
| Stopa fasady (kandydat) | `walkable(pos) and not walkable(pos+(0,-1)) and not walkable(pos+(0,-2))` | 1080–1083 |
| `is_horizontal_facade` | `has_same_y(x-1,y) or has_same_y(x+1,y)`, gdzie `has_same_y` toleruje `abs(fy-cy) <= 1` | 1094–1099 |
| `check_2h_col(cx, fy)` | `walkable(cx,fy) and not walkable(cx,fy-1) and not walkable(cx,fy-2) and walkable(cx,fy-3)` | 1101–1105 |
| `near_2h_context` | `(left_2h and right_2h) or (left_2h and check_2h_col(x+2,y)) or (right_2h and check_2h_col(x-2,y))` | 1109–1111 |
| `is_2h` (FACADE, h=2) | `is_horizontal_facade and (walkable(pos+(0,-3)) or near_2h_context)` | 1114 |
| `is_west_end` (2H) | `walkable(pos+(-1,-1)) or walkable(pos+(-1,-2))` | 1117 |
| `is_east_end` (2H) | `walkable(pos+(1,-1)) or walkable(pos+(1,-2))` | 1118 |
| `right_has_room_for_3h` | `not check_2h_col(x+1,y) and not check_2h_col(x+2,y) and not check_2h_col(x+3,y)` | 1147 |
| `left_has_room_for_3h` | `not check_2h_col(x-1,y) and not check_2h_col(x-2,y) and not check_2h_col(x-3,y)` | 1148 |
| `left_y` | pierwsze `ly` w `facade_cols[x-1]` z `abs(ly-y) <= 4` | 1183–1188 |
| `right_y` | pierwsze `ry` w `facade_cols[x+1]` z `abs(ry-y) <= 4` | 1190–1195 |
| `w_open` (OUT_CORNER, WEST) | `walkable(pos+(-1,-1)) and walkable(pos+(-1,-2)) and not walkable(pos+(0,-2)) and left_y == -1` | 1198–1201 |
| `e_open` (OUT_CORNER, EAST) | `walkable(pos+(1,-1)) and walkable(pos+(1,-2)) and not walkable(pos+(0,-2)) and right_y == -1` | 1203–1206 |
| `is_2h_corner` | `walkable(pos+(0,-3))` | 1209, 1252 |
| `STEP` WEST | `left_y != -1 and y > left_y`, `dy = y - left_y` | 1295 |
| `STEP` EAST | `right_y != -1 and y > right_y`, `dy = y - right_y` | 1334 |
| `step_use_roots` | `use_roots and (dy == 1)` — moduł dekorowany tylko przy `dy == 1` | 1300, 1336 |
| `can_niche` | `enable_decorative_niches and not is_in_portal and facade_cols.has(x+1) and facade_cols[x+1].has(y) and not (placed[pos_next] == "FACADE") and left_has_same_y and right_has_same_y and not left_down_wall and not right_down_wall and front_is_walkable and left_wall_clear and right_wall_clear` | 1377–1398 |
| `RIM` (kandydat) | `not walkable(pos) and walkable(pos+(0,-1)) and not walkable(pos+(0,1))` | 1599–1607 |
| `SIDE_WALL` EAST | `not walkable(pos) and walkable(pos+(1,0)) and not walkable(pos+(-1,0))` | 1568 |
| `SIDE_WALL` WEST | `not walkable(pos) and walkable(pos+(-1,0)) and not walkable(pos+(1,0))` | 1576 |
| `INNER_CORNER` NW | `not walkable(pos) and nw_floor and not ne_floor and not w_floor` | 1684 |
| `INNER_CORNER` NE | `not walkable(pos) and ne_floor and not nw_floor and not e_floor` | 1689 |

**Uwagi migracyjne:**

1. `facade_cols: Dictionary[int -> Array[int]]` (kolumna → lista `y` stóp fasad) jest
   strukturą pomocniczą budowaną w liniach 1078–1088. W nowej architekturze to
   `FacadeSegmentDetector` — ale **musi** zachować tę samą tolerancję: `<= 1` dla
   `has_same_y`, `<= 4` dla `left_y`/`right_y`, `<= 2` dla FAZY 2.5. Trzy różne
   tolerancje w trzech różnych miejscach — nie ujednolicać bez zrzutu porównawczego.
2. `sorted_xs` (linia 1090) sortuje kolumny rosnąco — to jedyna gwarancja, że
   `placed_tiles[pos] == "FACADE"` (linia 1080) działa jako "już obsłużone przez
   parę niszy z lewej". W modelu planu tę rolę przejmuje **rezerwacja pary niszy**
   (`EdgeContext.niche_partner`), więc sortowanie przestaje być semantycznie potrzebne,
   ale kanoniczna iteracja `(y, x)` zostaje dla determinizmu.
3. Kolumna `facade_cols[x]` może mieć **wiele** `y` (wiele fasad w jednej kolumnie,
   np. dwie komory jedna nad drugą). Każde `y` klasyfikowane osobno.

---

## 10. Model placementu i priorytetów

### 10.1. `TilePlacement`

```gdscript
class_name TilePlacement
extends RefCounted

var pos: Vector2i
var layer: StringName = &"Walls"
var source_id: int = 0
var atlas_coords: Vector2i = Vector2i(-1, -1)   # (-1,-1) = WYMAZANIE (erase_cell)
var alternative_tile: int = 0
var category: StringName = &""                  # klucz do presetu priorytetów
var priority: int = 0                           # wypełniane z presetu, nie z palca
var origin: Vector2i = Vector2i.ZERO            # komórka, która wygenerowała placement (debug)
var tie_breaker: int = 0                        # rozstrzyganie remisów (§10.4)

func is_erase() -> bool:
    return atlas_coords == Vector2i(-1, -1)
```

### 10.2. Presety priorytetów

Priorytety **nie mogą** być literałami w placerach. Jedyne źródło:
`core/placement_priority.gd` + nadpisania w profilu.

#### Preset `legacy_facade_wins` (DOMYŚLNY — odtwarza obecne zachowanie)

Odwzorowany z rzeczywistych warunków w kodzie (§3.3).

| Priorytet | Kategoria | Odpowiednik dziś | Warstwa |
|---|---|---|---|
| `10` | `SOLID_FILL` | `placed_tiles[p] = "ROCK"` | Walls |
| `15` | `RIM_BOWL` | miska pod zakończeniem rimu, motyw **rock** (§6.7) | Walls |
| `20` | `FLOOR_BASE` | `(10,13)` | Floor |
| `30` | `FLOOR_DECOR` | maska Grass | FloorDecor |
| `40` | `SIDE_WALL` | `"SIDE"` (FAZA 3) | Walls |
| `42` | `RIM_BOWL_DECORATED` | miska pod zakończeniem rimu, motyw **roots** (§6.7) | Walls |
| `45` | `CORNER` | `"CORNER"` | Walls |
| `50` | `RIM_BASE` | `"RIM"` | Walls |
| `51` | `RIM_TIP` | roots TIPS nad rimem | Walls |
| `60` | `SIDE_WALL_FIXED` | `"SIDE_FIXED"` | Walls |
| `65` | `STEP` | schodki `MOD_CRNR_*_IN` | Walls |
| `70` | `FACADE` | `"FACADE"` | Walls |
| `70` | `CONNECTOR` | łączniki 2H↔3H | Walls |
| `70` | `OUT_CORNER` | `MOD_CRNR_*_OUT` | Walls |
| `75` | `NICHE` | nisze (para) | Walls |
| `80` | `PILLAR` | Etap 10 | Walls |
| `1000` | `PORTAL_CLEAR` | `erase_cell()` | Walls |

**Zmiany zachowania wprowadzone przez ten preset (najpierw POMIAR, potem ewentualna decyzja):**

1. `CORNER` (`45`) nigdy nie nadpisze `SIDE_WALL_FIXED` (`60`) ani `FACADE` (`70`).
   Dziś w gałęzi 2H OUT nadpisywał bezwarunkowo. → pomiar: §14, P1-3.
2. `STEP` (`65`) < `FACADE` (`70`): dziś oba piszą jako `"FACADE"` bezwarunkowo,
   więc wygrywał późniejszy w kolejności skanowania. Rozdzielenie na dwie kategorie
   czyni rozstrzygnięcie jawnym. → pomiar: §14, P1-5.

Oba punkty są **najpierw zadaniem pomiarowym**: policzyć, ile razy kolizja faktycznie
zachodzi na 6 kombinacjach snapshotowych. Jeśli licznik wynosi `0` — zmiana jest
teoretyczna, digest się nie zmieni i nie ma o czym decydować.

`RIM_BOWL` **nie jest** już na tej liście — konflikt rock/roots rozwiązano dwiema
kategoriami (`RIM_BOWL` = 15, `RIM_BOWL_DECORATED` = 42), co zachowuje oba obecne
zachowania dokładnie. Szczegóły i uzasadnienie: §6.7.

#### Preset `readme_rim_wins` (alternatywa z RD-1/RD-2)

| Priorytet | Kategoria |
|---|---|
| `10` | `SOLID_FILL` |
| `20` | `FLOOR_BASE` |
| `30` | `FLOOR_DECOR` |
| `40` | `SIDE_WALL`, `SIDE_WALL_FIXED` |
| `50` | `FACADE`, `CONNECTOR` |
| `60` | `CORNER`, `OUT_CORNER`, `STEP` |
| `70` | `RIM_BASE`, `RIM_BOWL`, `RIM_BOWL_DECORATED` |
| `71` | `RIM_TIP` |
| `80` | `PILLAR` |
| `90` | `NICHE` |
| `1000` | `PORTAL_CLEAR` |

#### Implementacja

```gdscript
class_name PlacementPriority
extends RefCounted

const LEGACY_FACADE_WINS := {
    &"SOLID_FILL": 10, &"RIM_BOWL": 15, &"FLOOR_BASE": 20, &"FLOOR_DECOR": 30,
    &"SIDE_WALL": 40, &"RIM_BOWL_DECORATED": 42, &"CORNER": 45,
    &"RIM_BASE": 50, &"RIM_TIP": 51,
    &"SIDE_WALL_FIXED": 60, &"STEP": 65, &"FACADE": 70, &"CONNECTOR": 70,
    &"OUT_CORNER": 70, &"NICHE": 75, &"PILLAR": 80, &"PORTAL_CLEAR": 1000,
}

const README_RIM_WINS := {
    &"SOLID_FILL": 10, &"FLOOR_BASE": 20, &"FLOOR_DECOR": 30,
    &"SIDE_WALL": 40, &"SIDE_WALL_FIXED": 40, &"FACADE": 50, &"CONNECTOR": 50,
    &"CORNER": 60, &"OUT_CORNER": 60, &"STEP": 60,
    &"RIM_BASE": 70, &"RIM_BOWL": 70, &"RIM_BOWL_DECORATED": 70, &"RIM_TIP": 71,
    &"PILLAR": 80, &"NICHE": 90, &"PORTAL_CLEAR": 1000,
}

static func get_table(preset_id: StringName, overrides: Dictionary = {}) -> Dictionary:
    var base: Dictionary
    match preset_id:
        &"legacy_facade_wins": base = LEGACY_FACADE_WINS.duplicate()
        &"readme_rim_wins":    base = README_RIM_WINS.duplicate()
        _:
            push_error("Unknown priority preset: %s" % preset_id)
            base = LEGACY_FACADE_WINS.duplicate()
    for key in overrides:
        base[StringName(key)] = int(overrides[key])
    return base

## Placer NIGDY nie ustawia priority ręcznie — zawsze przez to.
static func assign(placement: TilePlacement, table: Dictionary) -> void:
    if not table.has(placement.category):
        push_error("PlacementPriority: brak priorytetu dla kategorii '%s'" % placement.category)
        placement.priority = 0
        return
    placement.priority = int(table[placement.category])
```

### 10.3. Uwaga o rozdziale "priorytet zapisu" / "priorytet blokowania"

Obecny system rozdziela te dwie role (§3.3, trzeci konflikt). Model jednoliczbowy je zlewa.

**To jest świadome uproszczenie.** W praktyce nie powoduje różnicy, bo:

- `SIDE_WALL_FIXED` powstaje w FAZIE 2, a `RIM_BASE` w FAZIE 4 — w momencie zapisu
  `SIDE_WALL_FIXED` żaden rim nie istnieje, więc niski priorytet zapisu nie ma na co wpłynąć;
- w modelu planu kolejność placerów przestaje mieć znaczenie, bo rozstrzyga priorytet.

**Nie wolno "poprawiać" tego** przez dodanie osobnego `block_priority` — to zwiększy
złożoność bez zysku. Jeśli weryfikacja wizualna (§14, P1-3…P1-5) wykaże regresję,
właściwą reakcją jest **przesunięcie liczby w presecie**, nie dodanie drugiego mechanizmu.

### 10.4. `TilePlacementPlan` — implementacja referencyjna

```gdscript
class_name TilePlacementPlan
extends RefCounted

## layer -> Dictionary[Vector2i -> TilePlacement]
## Klucz Vector2i, NIE String — §4.8.
var by_layer: Dictionary = {}

func queue(placement: TilePlacement) -> void:
    var cells: Dictionary = by_layer.get(placement.layer)
    if cells == null:
        cells = {}
        by_layer[placement.layer] = cells

    var existing: TilePlacement = cells.get(placement.pos)
    if existing == null:
        cells[placement.pos] = placement
        return

    # Ostro >: przy równym priorytecie NIE nadpisujemy — wynik niezależny od kolejności.
    if placement.priority > existing.priority:
        cells[placement.pos] = placement
        return

    # Remis: rozstrzygamy deterministycznie, nie "ostatni wygrywa".
    if placement.priority == existing.priority:
        if placement.tie_breaker > existing.tie_breaker:
            cells[placement.pos] = placement
        elif placement.tie_breaker == existing.tie_breaker:
            # Ostatnia deska ratunku: kanoniczne porównanie współrzędnych atlasu.
            # Gwarantuje determinizm i JEDNOCZEŚNIE sygnalizuje błąd projektowy.
            if _atlas_less(existing.atlas_coords, placement.atlas_coords):
                cells[placement.pos] = placement
            push_warning("TilePlacementPlan: nierozstrzygalny remis %s @ %s (%s vs %s)"
                % [placement.layer, placement.pos, existing.category, placement.category])

static func _atlas_less(a: Vector2i, b: Vector2i) -> bool:
    return a.y < b.y or (a.y == b.y and a.x < b.x)

## Kanoniczna serializacja do snapshotu regresyjnego (§13.3).
func serialize_canonical() -> String

func compute_digest() -> String:
    return serialize_canonical().sha256_text()

func get_placements(layer: StringName) -> Dictionary:
    return by_layer.get(layer, {})
```

**Reguła `tie_breaker`:** ustawiany tylko tam, gdzie dwa placery z tą samą kategorią
mogą trafić w tę samą komórkę. Dziś dotyczy to jednego przypadku: pary niszy
(`START` i `END` nigdy nie kolidują) oraz `FACADE`/`CONNECTOR`/`OUT_CORNER`
(priorytet `70` w presecie legacy). Dla nich `tie_breaker` = odległość Manhattan
od `origin` (bliżej źródła = wyższy), co daje intuicyjne "moduł wygrywa na własnej kolumnie".

Każde `push_warning` o nierozstrzygalnym remisie jest **błędem do naprawienia** —
snapshoty regresyjne muszą przechodzić z zerem takich ostrzeżeń.

### 10.5. `TilePlacementExecutor`

```gdscript
class_name TilePlacementExecutor
extends RefCounted

## Wykonuje plan dla JEDNEJ warstwy. Iteracja kanoniczna (y, potem x) —
## dla set_cell kolejność nie ma znaczenia, ale ma dla powtarzalności logów.
static func execute(layer_node: TileMapLayer, plan: TilePlacementPlan, layer: StringName) -> void:
    var cells: Dictionary = plan.get_placements(layer)
    var keys: Array = cells.keys()
    keys.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
        return a.y < b.y or (a.y == b.y and a.x < b.x))

    for pos in keys:
        var p: TilePlacement = cells[pos]
        if p.is_erase():
            layer_node.erase_cell(p.pos)
        else:
            layer_node.set_cell(p.pos, p.source_id, p.atlas_coords, p.alternative_tile)
```

> To jest **jedyna** funkcja w całym systemie wywołująca `set_cell` / `erase_cell`.
> Druga (i ostatnia) to `TerrainPaintExecutor` z `set_cells_terrain_connect`.
> Reguła jest sprawdzalna skryptem — §13.5.

### 10.6. Kolejność wykonania (wiążąca)

```gdscript
# terrain_generator.gd :: apply_tiles()
TilePlacementExecutor.execute(layers[&"Floor"],      plans.tiles,   &"Floor")
TerrainPaintExecutor.execute(layers,                 plans.terrain)          # Mud, potem Grass
TilePlacementExecutor.execute(layers[&"Walls"],      plans.tiles,   &"Walls")
# PORTAL_CLEAR jest już w plans.tiles z priorytetem 1000 — osobny executor NIE jest potrzebny.
```

**Uwaga:** `PORTAL_CLEAR` nie wymaga osobnego przebiegu, bo priorytet `1000` gwarantuje,
że wygra w planie. To jest **ulepszenie** względem obecnego kodu, gdzie wymazanie było
osobną pętlą na końcu — dzięki temu `erase_cell` nie może już przypadkiem usunąć
kafla, który miał tam zostać (np. bazy fasady w najwyższym wierszu alkowy, §2.5).

**Konsekwencja do sprawdzenia:** obecne `erase_cell` działa na `entrance_zone + exit_zone`
(20 komórek na alkowę). W nowym modelu `PORTAL_CLEAR` musi być kolejkowany
**dokładnie na tych samych komórkach** — czyli z `result.entrance_zone` i `result.exit_zone`,
a **nie** z `ctx.portal_zone`, jeśli te zbiory miałyby się różnić. Zweryfikować,
że `portal_zone == entrance_zone ∪ exit_zone` (dziś tak jest — linie 966–970).

---

## 11. Profile terenu (JSON)

### 11.1. Podział odpowiedzialności

| Do JSON-a | Do GDScript |
|---|---|
| parametry topologii (rozmiary, liczby, marginesy) | algorytmy carvingu |
| identyfikatory strategii (`room_carver`, `corridor_carver`) | flood fill, naprawa spójności |
| ścieżka tilesetu, `source_id` | analiza krawędzi, detekcja segmentów |
| parametry szumów (seed offset, frequency, próg) | pre-passy siatki |
| flagi cech (`features`) | rozstrzyganie konfliktów placementu |
| prawdopodobieństwa | parsowanie i walidacja JSON-a |
| preset priorytetów + nadpisania | konwersja `[x, y]` → `Vector2i` |
| współrzędne atlasu (`edge_rules`) | fallback motywu |
| wymagania fizyki per kategoria | — |
| fallback motywów | — |

**Zakaz:** żadnej logiki warunkowej w JSON-ie. Nie ma `"if"`, nie ma wyrażeń,
nie ma referencji typu `"$ref"`. Jeśli reguła wymaga warunku — to jest kod.

### 11.2. Współrzędne atlasu

Zawsze tablica dwóch liczb całkowitych:

```json
"base": [2, 7]
```

**Nigdy** `"Vector2i(2, 7)"` jako string. Loader konwertuje przez
`Vector2i(int(arr[0]), int(arr[1]))` i waliduje zakres przeciwko
`TileSetAtlasSource.get_atlas_grid_size()`.

Warianty A/B jako tablica tablic:

```json
"base": [[2, 7], [3, 7]]
```

Indeks `0` = wariant A, indeks `1` = wariant B. Wybór:
`GridHash.variant_ab(seed, pos)`.

### 11.3. Schemat `caves_default.json` — pełny

```json
{
  "id": "caves_default",
  "display_name": "Natural Cave",
  "schema_version": 1,

  "tileset_path": "res://modules/quiz_rpg/resources/maps/caves.tres",
  "source_id": 0,

  "layers": {
    "floor": "Floor",
    "floor_decor": "FloorDecor",
    "walls": "Walls"
  },

  "topology": {
    "generator": "interior_rooms",
    "room_carver": "organic_cave",
    "corridor_carver": "organic_meandering",
    "connectivity": "mst_with_loops",

    "min_room_size": 6,
    "max_room_size": 24,
    "max_rooms": 15,
    "room_border": 6,
    "room_padding_x": 5,
    "room_padding_y": 6,
    "room_attempts_multiplier": 25,
    "room_attempts_min": 300,

    "corridor_width": 3,
    "corridor_control_point_divisor": 6.0,
    "corridor_control_points_min": 3,
    "corridor_control_points_max": 14,
    "corridor_amplitude_factor": 0.22,
    "corridor_amplitude_min": 3.0,
    "corridor_amplitude_max": 10.0,
    "corridor_path_frequency": 0.04,
    "corridor_width_frequency": 0.08,
    "corridor_funnel_strength": 2.2,

    "extra_loop_count_max": 3,
    "extra_loop_room_divisor": 3,
    "extra_loop_attempts": 25,
    "extra_loop_distance_factor": 0.45,

    "portal_alcove_radius": 2,
    "portal_map_border": 2,
    "portal_tunnel_length_min": 5,
    "portal_tunnel_length_max": 7,
    "portal_min_tunnel_length": 5
  },

  "noise": {
    "theme_seed_offset": 333,
    "theme_frequency": 0.08,
    "secondary_theme_threshold": 0.14,
    "theme_portal_uniform_radius": 4,

    "variant_seed_offset": 777,
    "variant_frequency": 0.45,

    "mud_seed_offset": 202,
    "mud_frequency": 0.035,
    "mud_threshold": -0.02,

    "grass_seed_offset": 0,
    "grass_frequency": 0.13,
    "grass_threshold": 0.10
  },

  "themes": {
    "primary": "rock",
    "secondary": "roots",
    "fallback": { "roots": "rock" }
  },

  "terrains": {
    "floor_base": [10, 13],
    "mud":   { "layer": "floor",       "terrain_set": 0, "terrain": 1, "order": 0 },
    "grass": { "layer": "floor_decor", "terrain_set": 0, "terrain": 2, "order": 1 },
    "floor_dilation_radius": 2
  },

  "features": {
    "allow_pillars": false,
    "allow_niches": true,
    "allow_secret_niches": true,
    "allow_2h_facades": true,
    "allow_3h_facades": true,
    "allow_connectors": true,
    "allow_steps": true,
    "allow_rim_capping": true,
    "allow_top_decorations": true,
    "allow_floor_decorations": true,
    "allow_2h_steps": false,
    "allow_rim_segment_caps": false
  },

  "cleanup": {
    "junction_smoothing": true,
    "remove_1h_walls": true,
    "enforce_wall_thickness": true,
    "flatten_short_3h_bulges": true,
    "remove_single_tile_spikes": true,
    "remove_thin_wall_bridges": true,
    "normalize_staircases": true,
    "max_passes": 4,
    "bulge_min_width": 4
  },

  "probabilities": {
    "niche_spawn_chance": 0.15,
    "secret_niche_spawn_chance": 0.30,
    "out_niche_min_distance": 10,
    "rock_fill_weights": [45, 47, 8]
  },

  "placement": {
    "priority_preset": "legacy_facade_wins",
    "priority_overrides": {}
  },

  "physics_requirements": {
    "SOLID_FILL":    { "layers": [0] },
    "FACADE":        { "layers": [0] },
    "CONNECTOR":     { "layers": [0] },
    "STEP":          { "layers": [0] },
    "OUT_CORNER":    { "layers": [0] },
    "SIDE_WALL":     { "layers": [0] },
    "RIM_BASE":      { "layers": [0] },
    "RIM_TIP":       { "layers": [1] },
    "PORTAL_CLEAR":  { "layers": [] }
  },

  "spawn": {
    "boss_offset": [0, -2],
    "enemy_count_min": 2,
    "enemy_count_max": 4,
    "enemy_offset_range": 2,
    "enemy_tier_min": 1,
    "enemy_tier_max": 2,
    "boss_tier": 3,
    "room_role_modulo": 2,
    "validate_walkable": true,
    "walkable_search_radius": 4
  },

  "edge_rules": { }
}
```

> Klucz `edge_rules` jest pusty w tym szkielecie — pełna zawartość w §11.4,
> bo jest długa i wchodzi do repo dopiero w Etapie 7.

### 11.4. `edge_rules` — struktura i pełna zawartość dla `caves_default`

Struktura klucza: `edge_rules[kind][orientation][height][segment][theme]`.

Poziomy `orientation` / `height` / `segment` mogą być pominięte dla kategorii,
które ich nie używają (§9.4). Klucz `"any"` oznacza "dowolna wartość na tym poziomie".

```json
"edge_rules": {
  "solid_fill": {
    "any": { "any": { "any": {
      "rock": {
        "base": [[2, 2], [2, 3], [3, 2]],
        "variant_mode": "weighted",
        "weights": [45, 47, 8],
        "category": "SOLID_FILL"
      }
    } } }
  },

  "side_wall": {
    "east": { "any": { "any": {
      "rock":  { "base": [[5, 2], [5, 3]], "category": "SIDE_WALL" },
      "roots": { "base": [[5, 11], [5, 12]], "category": "SIDE_WALL" }
    } } },
    "west": { "any": { "any": {
      "rock":  { "base": [[0, 2], [0, 3]], "category": "SIDE_WALL" },
      "roots": { "base": [[0, 11], [0, 12]], "category": "SIDE_WALL" }
    } } }
  },

  "facade": {
    "south": {
      "3h": {
        "middle": {
          "rock": {
            "base":   [[2, 7], [3, 7]],
            "middle": [[2, 6], [3, 6]],
            "top":    [[2, 5], [3, 5]],
            "crown":  [[2, 4], [3, 4]],
            "rows_above": 3,
            "draws_on_floor_row": true,
            "consumes_rim_row": true,
            "category": "FACADE"
          },
          "roots": {
            "base":   [[2, 16], [3, 16]],
            "middle": [[2, 15], [3, 15]],
            "top":    [[2, 14], [3, 14]],
            "crown":  [[2, 13], [3, 13]],
            "rows_above": 3,
            "draws_on_floor_row": true,
            "consumes_rim_row": true,
            "category": "FACADE"
          }
        }
      },
      "2h": {
        "middle": {
          "rock": {
            "base": [[2, 21], [3, 21]],
            "top":  [[2, 20], [3, 20]],
            "rows_above": 1,
            "draws_on_floor_row": true,
            "consumes_rim_row": false,
            "category": "FACADE"
          }
        },
        "start": {
          "rock": {
            "base": [[0, 20]],
            "top":  [[0, 19]],
            "rows_above": 1,
            "draws_on_floor_row": true,
            "consumes_rim_row": false,
            "category": "FACADE",
            "note": "zakończenie zachodnie 2H, base na wierszu podłogi — zachowanie potwierdzone przez autora (§6.5)"
          }
        },
        "end": {
          "rock": {
            "base": [[5, 20]],
            "top":  [[5, 19]],
            "rows_above": 1,
            "draws_on_floor_row": true,
            "consumes_rim_row": false,
            "category": "FACADE"
          }
        }
      }
    }
  },

  "connector": {
    "east": { "any": { "any": {
      "rock": {
        "base":   [[7, 21]],
        "middle": [[7, 20]],
        "top":    [[7, 19]],
        "rows_above": 2,
        "draws_on_floor_row": true,
        "category": "CONNECTOR",
        "note": "2H po lewej -> 3H po prawej"
      }
    } } },
    "west": { "any": { "any": {
      "rock": {
        "base":   [[10, 21]],
        "middle": [[10, 20]],
        "top":    [[10, 19]],
        "rows_above": 2,
        "draws_on_floor_row": true,
        "category": "CONNECTOR",
        "note": "3H po lewej -> 2H po prawej"
      }
    } } }
  },

  "step": {
    "west": { "3h": { "any": {
      "rock": {
        "base": [[1, 7]], "middle": [[1, 6]], "top": [[1, 5]], "crown": [[1, 4]],
        "rows_above": 3, "draws_on_floor_row": true, "consumes_rim_row": true,
        "category": "STEP"
      },
      "roots": {
        "base": [[1, 16]], "middle": [[1, 15]], "top": [[1, 14]], "crown": [[1, 13]],
        "rows_above": 3, "draws_on_floor_row": true, "consumes_rim_row": true,
        "category": "STEP",
        "requires": { "step_dy": 1 }
      }
    } } },
    "east": { "3h": { "any": {
      "rock": {
        "base": [[4, 7]], "middle": [[4, 6]], "top": [[4, 5]], "crown": [[4, 4]],
        "rows_above": 3, "draws_on_floor_row": true, "consumes_rim_row": true,
        "category": "STEP"
      },
      "roots": {
        "base": [[4, 16]], "middle": [[4, 15]], "top": [[4, 14]], "crown": [[4, 13]],
        "rows_above": 3, "draws_on_floor_row": true, "consumes_rim_row": true,
        "category": "STEP",
        "requires": { "step_dy": 1 }
      }
    } } }
  },

  "out_corner": {
    "west": {
      "3h": { "any": {
        "rock":  { "base": [[0, 6]], "middle": [[0, 5]], "top": [[0, 4]],
                   "rows_above": 2, "draws_on_floor_row": true, "category": "OUT_CORNER" },
        "roots": { "base": [[0, 15]], "middle": [[0, 14]], "top": [[0, 13]],
                   "rows_above": 2, "draws_on_floor_row": true, "category": "OUT_CORNER" }
      } },
      "2h": { "any": {
        "rock":  { "base": [[0, 20]], "top": [[0, 19]], "crown": [[0, 1]],
                   "rows_above": 2, "draws_on_floor_row": false, "row_offset": -1,
                   "category": "OUT_CORNER",
                   "note": "ZAMIERZONE (§6.5): base na y-1, NIE na wierszu podłogi. Nie zmieniać." }
      } }
    },
    "east": {
      "3h": { "any": {
        "rock":  { "base": [[5, 6]], "middle": [[5, 5]], "top": [[5, 4]],
                   "rows_above": 2, "draws_on_floor_row": true, "category": "OUT_CORNER" },
        "roots": { "base": [[5, 15]], "middle": [[5, 14]], "top": [[5, 13]],
                   "rows_above": 2, "draws_on_floor_row": true, "category": "OUT_CORNER" }
      } },
      "2h": { "any": {
        "rock":  { "base": [[5, 20]], "top": [[5, 19]], "crown": [[5, 1]],
                   "rows_above": 2, "draws_on_floor_row": false, "row_offset": -1,
                   "category": "OUT_CORNER", "note": "ZAMIERZONE (§6.5) — jak wariant west" }
      } }
    }
  },

  "inner_corner": {
    "south_east": { "any": { "any": {
      "rock":  { "base": [[1, 4]] },
      "roots": { "base": [[1, 13]] }
    } } },
    "south_west": { "any": { "any": {
      "rock":  { "base": [[4, 4]] },
      "roots": { "base": [[4, 13]] }
    } } },
    "north_west": { "any": { "any": {
      "rock":  { "base": [[1, 1]],  "category": "CORNER" },
      "roots": { "base": [[1, 10]], "category": "CORNER" }
    } } },
    "north_east": { "any": { "any": {
      "rock":  { "base": [[4, 1]],  "category": "CORNER" },
      "roots": { "base": [[4, 10]], "category": "CORNER" }
    } } }
  },

  "top_rim": {
    "north": { "any": {
      "middle": {
        "rock":  { "base": [[2, 0], [3, 0]], "category": "RIM_BASE" },
        "roots": { "base": [[2, 9], [3, 9]],
                   "decoration": [[2, 8], [3, 8]],
                   "decoration_offset": [0, -1],
                   "decoration_category": "RIM_TIP",
                   "category": "RIM_BASE" }
      },
      "start": {
        "rock":  { "base": [[5, 1]],
                   "bowl": [[4, 1]], "bowl_offset": [0, 1], "bowl_category": "RIM_BOWL",
                   "category": "RIM_BASE" },
        "roots": { "base": [[5, 10]],
                   "decoration": [[5, 9]], "decoration_offset": [0, -1],
                   "decoration_category": "RIM_TIP",
                   "bowl": [[4, 10]], "bowl_offset": [0, 1], "bowl_category": "RIM_BOWL_DECORATED",
                   "category": "RIM_BASE" }
      },
      "end": {
        "rock":  { "base": [[0, 1]],
                   "bowl": [[1, 1]], "bowl_offset": [0, 1], "bowl_category": "RIM_BOWL",
                   "category": "RIM_BASE" },
        "roots": { "base": [[0, 10]],
                   "decoration": [[0, 9]], "decoration_offset": [0, -1],
                   "decoration_category": "RIM_TIP",
                   "bowl": [[1, 10]], "bowl_offset": [0, 1], "bowl_category": "RIM_BOWL_DECORATED",
                   "category": "RIM_BASE" }
      }
    } }
  },

  "niche": {
    "west": { "3h": { "start": {
      "rock":  { "base": [[4, 7]], "middle": [[4, 6]], "top": [[4, 5]], "crown": [[4, 4]],
                 "rows_above": 3, "draws_on_floor_row": true, "category": "NICHE" },
      "roots": { "base": [[4, 16]], "middle": [[4, 15]], "top": [[4, 14]], "crown": [[4, 13]],
                 "rows_above": 3, "draws_on_floor_row": true, "category": "NICHE" }
    } } },
    "east": { "3h": { "end": {
      "rock":  { "base": [[1, 7]], "middle": [[1, 6]], "top": [[1, 5]], "crown": [[1, 4]],
                 "rows_above": 3, "draws_on_floor_row": true, "category": "NICHE" },
      "roots": { "base": [[1, 16]], "middle": [[1, 15]], "top": [[1, 14]], "crown": [[1, 13]],
                 "rows_above": 3, "draws_on_floor_row": true, "category": "NICHE" }
    } } }
  },

  "niche_secret": {
    "west": { "3h": { "start": {
      "rock":  { "base": [[5, 6]], "middle": [[5, 5]], "top": [[5, 4]], "crown": [[4, 4]],
                 "rows_above": 3, "draws_on_floor_row": true, "category": "NICHE" },
      "roots": { "base": [[5, 15]], "middle": [[5, 14]], "top": [[5, 13]], "crown": [[4, 13]],
                 "rows_above": 3, "draws_on_floor_row": true, "category": "NICHE" }
    } } },
    "east": { "3h": { "end": {
      "rock":  { "base": [[0, 6]], "middle": [[0, 5]], "top": [[0, 4]], "crown": [[1, 4]],
                 "rows_above": 3, "draws_on_floor_row": true, "category": "NICHE" },
      "roots": { "base": [[0, 15]], "middle": [[0, 14]], "top": [[0, 13]], "crown": [[1, 13]],
                 "rows_above": 3, "draws_on_floor_row": true, "category": "NICHE" }
    } } }
  }
}
```

**Moduły dostępne w atlasie, jeszcze nieprzypisane** (dodać w Etapie 10+ razem z flagą):

```json
"facade": { "south": { "2h": {
  "step_west": { "rock": { "base": [[1, 21]], "middle": [[1, 20]], "top": [[1, 19]] } },
  "step_east": { "rock": { "base": [[4, 21]], "middle": [[4, 20]], "top": [[4, 19]] } }
} } },
"top_rim": { "north": { "any": {
  "start_cap_roots": { "roots": { "base": [[1, 9]], "decoration": [[1, 8]] } },
  "end_cap_roots":   { "roots": { "base": [[4, 9]], "decoration": [[4, 8]] } }
} } }
```

Kontrolowane flagami `allow_2h_steps` i `allow_rim_segment_caps` (domyślnie `false`).

### 11.5. Pozostałe profile

```
caves_rock_only.json
  themes.secondary = null            → wszystko rock
  features.allow_top_decorations = false
  Cel: porównanie geometrii bez drugiej warstwy dekoracyjnej.

caves_roots_heavy.json
  noise.secondary_theme_threshold = -0.10    → ~70% roots
  Cel: testowanie BASE + TIPS i zakończeń rimów.

caves_debug.json
  features: allow_niches=false, allow_secret_niches=false,
            allow_floor_decorations=false, allow_top_decorations=false
  cleanup.max_passes = 1
  Cel: czysta geometria do diagnozowania EdgeKind i priorytetów.
  UWAGA: BEZ pola "seed" — §4.9.
  Decyzja autora: trzymany w repo na stałe (nie w .gitignore).

castle_default.json      ← szkielet parametrów, Etap 11
library_default.json     ← szkielet parametrów, Etap 11
```

### 11.6. Walidator profilu — lista kontrolna

`TerrainProfileValidator.validate(profile, tileset) -> Array[String]`
(pusta tablica = OK; każdy element = komunikat błędu).

Obowiązkowe sprawdzenia:

1. `schema_version` obsługiwana przez loader.
2. `id` niepusty i zgodny z nazwą pliku.
3. `tileset_path` istnieje (`ResourceLoader.exists`) i ładuje się jako `TileSet`.
4. `source_id` istnieje w `TileSet`.
5. Każda współrzędna atlasu we `edge_rules` mieści się w
   `TileSetAtlasSource.get_atlas_grid_size()` **i** kafel jest utworzony
   (`has_tile(coords)`). To wyłapałoby literówkę typu `[2, 40]`.
6. Każda kombinacja `kind/orientation/height/segment` jest dozwolona (§9.4).
7. Każda kategoria użyta w `edge_rules` ma priorytet w wybranym presecie.
8. `themes.primary` ma reguły dla wszystkich kategorii wymaganych przez `features`.
9. `themes.fallback` nie tworzy cyklu.
10. `physics_requirements`: każdy kafel przypisany do kategorii ma niepustą geometrię
    kolizji na wskazanych warstwach i **pustą** na pozostałych.
11. `terrains.mud.terrain_set` / `.terrain` istnieją w `TileSet`.
12. `probabilities.rock_fill_weights` ma tyle elementów, ile wariantów `solid_fill.base`.
13. Wszystkie wartości `*_chance` w `[0.0, 1.0]`.
14. `topology.min_room_size <= topology.max_room_size`.
15. `topology.room_border >= topology.portal_alcove_radius + topology.portal_map_border`.

Walidator uruchamiany:
- przy każdym ładowaniu profilu w trybie debug (`OS.is_debug_build()`),
- zawsze w `tests/run_tests.gd`,
- **nigdy** w buildzie release (koszt).

---

## 12. Etapowy plan wdrożenia

### 12.0. Zasady ogólne dla wszystkich etapów

1. **Jeden etap = jeden lub kilka commitów, nigdy pół etapu.** Po każdym commicie
   projekt musi się uruchamiać i generować mapę.
2. **Po każdym etapie uruchomić `tests/check_parse.gd`** (§13.1). Etap bez tego
   nie jest zakończony.
3. **Żaden etap nie usuwa starego kodu, dopóki nowy nie przejdzie weryfikacji.**
   Wzorzec: dodaj nowe → przełącz wywołanie → zweryfikuj → usuń stare (osobny commit).
4. **Etapy 2–5 muszą być bit-exact.** Różnica w `compute_digest()` = błąd migracji,
   nie „ulepszenie".
5. **Etap 6 jest jedynym etapem zmieniającym wygląd** (hash pozycji, §6.3).
6. Nie wolno łączyć etapów. Nie wolno robić Etapu 7 „po drodze" przy Etapie 4.

### 12.1. Etap 0 — stabilizacja i infrastruktura weryfikacji

**Cel:** projekt kompiluje się, istnieje sposób maszynowego sprawdzenia regresji.

**Zadania:**

| # | Zadanie |
|---|---|
| 0.1 | Zacommitować lokalną naprawę `left_is_2h_step` / `right_is_2h_step` (§3.1) |
| 0.2 | Utworzyć `modules/quiz_rpg/tests/check_parse.gd` (§13.1) |
| 0.3 | Uruchomić i potwierdzić, że wszystkie `.gd` w `modules/quiz_rpg/` parsują się |
| 0.4 | Usunąć martwą `_get_vertical_wall_thickness()` (linie 661–674) |
| 0.5 | Usunąć `flags.enable_rim_capping` (§6.2) |
| 0.6 | Poprawić komentarz o terenie trawy: `terrain 1` → `terrain 2` (linia 27) |
| 0.7 | Uprościć martwy `ALCOVE_NORTH_EXTRA` (§2.5) — zachowując wynik: wiersz `dy == -2` nadal wycięty, ale nieoznaczony |
| 0.8 | Dodać `docs/universal_interior_generator_refactor.md` (ten plik) do repo |

**Definition of Done:**
- `check_parse.gd` zwraca exit code 0.
- Mapa generuje się w `map_generator_preview.tscn` dla seedów `119`, `1`, `42`, `999`.
- `git status` czysty.

**Weryfikacja:** ręczna, wzrokowa. Zapisać **4 zrzuty referencyjne** (seed `119`, `1`,
`42`, `999`, rozmiar `100×100`, typ Jaskinie) do `docs/reference_screenshots/etap0/`.
To są zrzuty „przed refaktorem" — punkt odniesienia dla oceny jakości w Etapie 6 i 8.

> **UWAGA:** zrzuty z Etapu 0 są referencją **dla oka**, nie dla maszyny.
> Maszynowy baseline (`compute_digest`) powstaje dopiero w Etapie 5 (stary RNG)
> i jest ponownie zamrażany w Etapie 6 (nowy hash).

### 12.2. Etap 1 — inwentaryzacja i snapshot bazowy (bez zmian logiki)

**Cel:** móc maszynowo wykryć, że cokolwiek się zmieniło.

**Zadania:**

| # | Zadanie |
|---|---|
| 1.1 | `tests/run_tests.gd` — runner headless (`extends SceneTree`, §13.2) |
| 1.2 | `tests/dump_plan.gd` — zrzut **obecnego** wyniku kafelkowania do pliku tekstowego (§13.3) |
| 1.3 | Nagrać snapshoty dla 6 kombinacji (§13.3, tabela) do `tests/snapshots/etap1/` |
| 1.4 | `tests/dump_grid.gd` — zrzut siatki w notacji ASCII + PNG maski |
| 1.5 | Nagrać snapshoty siatek do `tests/snapshots/etap1/` |

**Sposób zrzutu w Etapie 1** (obecny kod nie ma planu placementu):
`dump_plan.gd` uruchamia `CaveGenerator.generate()` + `apply_cave_tiles()` na
`TileMapLayer` utworzonych w pamięci (bez scen), a następnie iteruje
`walls_layer.get_used_cells()` w kolejności kanonicznej i serializuje
`pos | source_id | atlas_coords | alternative_tile`. Identycznie dla `Floor`
i `FloorDecor`. Ten format jest **tym samym**, który później produkuje
`TilePlacementPlan.serialize_canonical()` — dzięki temu snapshoty z Etapu 1
będą bezpośrednio porównywalne z wynikami Etapów 2–5.

**Definition of Done:**
- Dwa uruchomienia `run_tests.gd` z rzędu dają identyczne digesty (test determinizmu).
- Snapshoty w repo.

### 12.3. Etap 2 — wydzielenie `core/` (bez zmiany zachowania)

**Cel:** typy danych żyją osobno, `cave_generator.gd` ich używa.

**Zadania:**

| # | Zadanie |
|---|---|
| 2.1 | `core/generation_flags.gd` — przeniesienie klasy wewnętrznej (§8.3) |
| 2.2 | W `cave_generator.gd`: `const GenerationFlags = preload(...)` (alias wsteczny) |
| 2.3 | `core/grid_utils.gd` — `is_walkable()`, `in_bounds()`, `carve_circle()`, `get_reachable_cells()`, `neighbors_4/8`. **`is_walkable()` pozostaje binarne** — nie dodawać `TREE`/`WATER`/`PATH` (§6.8 pkt 1) |
| 2.4 | `core/cell_type.gd` — re-eksport enumu (żeby `topology/` nie musiało dziedziczyć po `MapGeneratorBase`) |
| 2.5 | `core/seeded_noise.gd` — fabryka szumów z profilu |
| 2.6 | `core/tile_placement.gd`, `core/tile_placement_plan.gd` (§10.1, §10.4) |
| 2.7 | `core/terrain_paint_plan.gd` (§5.1) |
| 2.8 | `core/placement_priority.gd` (§10.2) |
| 2.9 | `core/generation_context.gd` (§8.2) |
| 2.10 | Rozszerzyć `GenerationResult` o nowe pola (§5.10) — **tylko dodać, nic nie usuwać** |
| 2.11 | Podmienić w `cave_generator.gd` wywołania `_is_walkable` → `GridUtils.is_walkable` itd. |

**Definition of Done:**
- `check_parse.gd` OK.
- Digesty **identyczne** ze snapshotami Etapu 1 (bit-exact).
- `cave_generator.gd` skrócony o kod przeniesiony do `core/`.

### 12.4. Etap 3 — topologia i pre-processing

**Cel:** `generate()` = topologia + pre-passy + spawny. `apply_*` już nie mutuje siatki.

**Kolejność passów — TABELA OBOWIĄZKOWA.** To jedyna kolejność zachowująca obecny wynik.

| # | Moduł docelowy | Odpowiednik dziś | Flaga | RNG? |
|---|---|---|---|---|
| P1 | wypełnienie `WALL` (w `InteriorRoomLayoutGenerator`) | `generate()` :209 | — | nie |
| P2 | `RoomPlacer` + `OrganicCaveRoomCarver` | `generate()` :214–250 | — | **tak** |
| P3 | `OrganicCorridorCarver` (MST + pętle) | `generate()` :253–296 | `enable_meandering`, `enable_variable_width`, `enable_funnels` | **tak** |
| P4 | `JunctionSmoothingPass` | `_smooth_cave_junctions` | `enable_junction_smoothing` | nie |
| P5 | `Remove1hWallsPass` | `_remove_1height_walls` | — | nie |
| P6 | `WallThicknessPass` | `_enforce_wall_thickness` | — | nie |
| P7 | `ShortBulgeFlattenPass` | `_flatten_short_3h_bulges` | — | nie |
| P8 | `ConnectivityRepair` | `_ensure_rooms_connected` | — | **tak** |
| P9 | `PortalGenerator` | `_carve_portal_alcove` ×2 + `ENTRANCE`/`EXIT` | — | **tak** |
| P10 | `SpikeCleanupPass` + `ThinBridgeCleanupPass` + `StaircaseNormalizerPass` | `_cleanup_grid_before_tiling` (REGUŁY 1, 2, 3A, 3B) | `enable_grid_cleanup` | nie |
| P11 | `ShortBulgeFlattenPass` (drugi raz) | `_flatten_short_3h_bulges` w `apply_cave_tiles` | `enable_grid_cleanup` | nie |
| P12 | `SpawnPlanner` | `generate()` :344–364 | — | **tak** |

> **KRYTYCZNE — trzy pułapki:**
>
> 1. **P10/P11 są dziś w `apply_cave_tiles()`, PO portalach (P9).** Nie wolno ich przenieść
>    przed P9 (§3.6).
> 2. **P12 jest dziś PRZED P10/P11** (spawny w `generate()`, czyszczenie w `apply`).
>    Przeniesienie P12 na koniec jest bezpieczne, bo spawny liczą pozycje z `Rect2i`
>    komór, nie z siatki, a P10/P11 nie zużywają RNG. Kolejność zużycia RNG:
>    P2 → P3 → P8 → P9 → P12 pozostaje identyczna.
> 3. **`_cleanup_grid_before_tiling()` rozbija się na 3 passy, ale musi zostać
>    JEDNĄ pętlą zbieżną** (`while changed and pass_count < 4`), w której wszystkie
>    trzy reguły są sprawdzane w jednym przebiegu po siatce. Rozdzielenie na trzy
>    niezależne pętle **zmieni wynik**, bo dziś reguły widzą siatkę przed zbiorczym
>    zastosowaniem `to_carve` z tej samej iteracji.
>    → `GridPreprocessor` musi obsługiwać **grupy passów** wykonywane wspólnie
>    w jednej pętli zbieżnej:
>    ```gdscript
>    GridPreprocessor.run_convergent(ctx, [
>        SpikeCleanupPass.new(),
>        ThinBridgeCleanupPass.new(),
>        StaircaseNormalizerPass.new(),
>    ], max_passes = 4)
>    ```

**Mapowanie reguł `_cleanup_grid_before_tiling()` na passy:**

| Reguła (linie) | Warunek | Pass |
|---|---|---|
| REGUŁA 1 (:801–804) | `wall_cardinal <= 1` | `SpikeCleanupPass` |
| REGUŁA 2 (:806–809) | `w_n and w_s and not w_w and not w_e` | `ThinBridgeCleanupPass` |
| REGUŁA 3A (:811–816) | `not w_s and not w_w and not w_e` | `SpikeCleanupPass` |
| REGUŁA 3B (:818–828) | `not w_w and not w_e and w_s and not floor_sw and not floor_se` | `StaircaseNormalizerPass` |

**Zadania dodatkowe:**

| # | Zadanie |
|---|---|
| 3.13 | `topology/topology_generator.gd`, `room_carver.gd`, `corridor_carver.gd` + fabryki (§8.4) |
| 3.14 | `topology/interior_room_layout_generator.gd` — orkiestracja P1–P3, P8, P9 |
| 3.15 | `topology/portal_generator.gd` — `_carve_portal_alcove` 1:1 |
| 3.16 | `topology/connectivity_repair.gd` |
| 3.17 | `preprocess/grid_pass.gd` + `grid_preprocessor.gd` z `run()` i `run_convergent()` (§8.5) |
| 3.18 | 8 passów jako osobne pliki |
| 3.19 | `spawn/spawn_planner.gd` — na razie **bez** walidacji przechodniości (żeby zachować bit-exact); walidacja wchodzi w Etapie 9 |
| 3.20 | `apply_cave_tiles()`: **usunąć KROK 0** (linie 934–937) |

**Definition of Done:**
- `check_parse.gd` OK.
- Digesty **identyczne** ze snapshotami Etapu 1.
- `apply_cave_tiles()` nie zawiera ani jednego zapisu do `result.grid`.
- `ctx.preprocess_stats` pokazuje sensowne liczby dla każdego passu.

### 12.5. Etap 4 — `EdgeAnalyzer`

**Cel:** jedno źródło informacji o geometrii. Placery przestają liczyć sąsiedztwo.

**Zadania:**

| # | Zadanie |
|---|---|
| 4.1 | `edge/edge_kind.gd` — enumy (§9.2) |
| 4.2 | `edge/edge_context.gd` (§9.1) |
| 4.3 | `edge/facade_height_resolver.gd` (§4.6) |
| 4.4 | `edge/edge_analyzer.gd` — klasyfikacja w kolejności z §9.3, warunki 1:1 z §9.6 |
| 4.5 | `edge/facade_segment.gd` + `facade_segment_detector.gd` |
| 4.6 | `edge/theme_resolver.gd` — trzy punkty odniesienia (§8.6) |
| 4.7 | `tests/dump_edge_fixtures.gd` + 16 fixture'ów (§16.2) |
| 4.8 | W `apply_cave_tiles()`: **tylko dodać** wywołanie analizatora i `assert`, że jego klasyfikacja zgadza się z decyzjami istniejących `if`-ów. Nie przepisywać jeszcze placementu. |

**Zadanie 4.8 jest kluczowe i nieoczywiste.** Zamiast od razu przepisywać placery,
uruchamiamy `EdgeAnalyzer` **równolegle** ze starą logiką i porównujemy wyniki.
W trybie debug, dla każdej komórki fasady:

```gdscript
if OS.is_debug_build() and ctx.flags.debug_log_edge_kinds:
    var expected := _legacy_classify(pos)        # tymczasowa funkcja odwzorowująca stare if-y
    var actual: EdgeContext = edges[pos]
    if expected != actual.edge_kind:
        push_error("EdgeAnalyzer mismatch @ %s: legacy=%s analyzer=%s"
            % [pos, expected, actual.edge_kind])
```

To pozwala wykryć błąd klasyfikacji **przed** tym, jak zmieni on wygląd.
`_legacy_classify()` i cała ta ścieżka są usuwane w Etapie 5.

**Definition of Done:**
- 16 fixture'ów przechodzi.
- Zero `push_error` o niezgodności dla seedów `119`, `1`, `42`, `999` przy `100×100`
  **i** dla `250×250` seed `7` (większa mapa = więcej przypadków brzegowych).
- Digesty **identyczne** ze snapshotami Etapu 1.

### 12.6. Etap 5 — placery i plan placementu

**Cel:** `apply_cave_tiles()` przestaje wywoływać `set_cell`. Powstaje plan.

**Kolejność migracji placerów** (od najprostszego, każdy = osobny commit):

| # | Placer | Zastępuje | Ryzyko |
|---|---|---|---|
| 5.1 | `SolidFillPlacer` | FAZA 1 (:1060–1074) | niskie |
| 5.2 | `FloorPlacer` + `TerrainMaskPlanner` | KROK 2a–2c (:946–1024) | niskie |
| 5.3 | `PortalClearPlacer` | wymazanie portali (:1694–1696) | niskie |
| 5.4 | `SideWallPlacer` | FAZA 3 (:1559–1582) | niskie |
| 5.5 | `RimPlacer` | FAZA 4 (:1584–1692) | **wysokie** — 2 motywy × 5 gałęzi + misy + narożniki diagonalne |
| 5.6 | `CornerPlacer` | wstrzykiwane korony + FAZA 2.5 (:1520–1557) | średnie |
| 5.7 | `FacadePlacer` | gałęzie `is_2h` i „ściana prosta" | **wysokie** |
| 5.8 | `ConnectorPlacer` | łączniki 2H↔3H (:1142–1180) | **wysokie** — asymetria z §3.1 |
| 5.9 | `StepPlacer` | schodki (:1295–1372) | wysokie |
| 5.10 | `OutCornerPlacer` | `w_open` / `e_open` (:1208–1292) | **wysokie** — offset 2H jest zamierzony (§6.5), zachować 1:1 |
| 5.11 | `NichePlacer` | nisze standardowa + sekretna (:1374–1478) | wysokie |
| 5.12 | `TilePlacementExecutor` + `TerrainPaintExecutor` | — | niskie |
| 5.13 | `TilePlacementPlanner` — orkiestracja placerów | — | niskie |
| 5.14 | Usunąć `_legacy_classify()` i stary kod FAZ 1–4 | — | — |

**Reguła dla każdego kroku 5.x:** po migracji placera digest musi pozostać identyczny.
Jeśli się zmienił — **cofnąć i znaleźć różnicę**, nie „zaakceptować bo ładniej wygląda".

**Dwa miejsca, gdzie digest MOŻE się zmienić** (§10.2, lista zmian presetu):
- krok 5.6: `CORNER` nie nadpisuje `SIDE_WALL_FIXED` → §14 P1-3;
- krok 5.9: `STEP` vs `FACADE` rozstrzygane priorytetem → §14 P1-5.

**Oba są najpierw zadaniem pomiarowym, nie zmianą.** Przed migracją dodać tymczasowy
licznik kolizji i uruchomić na 6 kombinacjach snapshotowych. Jeśli licznik = `0`,
zmiana jest teoretyczna i krok pozostaje bit-exact. Jeśli > `0` — osobny commit,
zrzut przed/po, decyzja autora, potem zamrożenie `tests/snapshots/etap5/`.

Kroki 5.5 i 5.10 są bit-exact:
- 5.5 — miska rimu ma dwie kategorie, oba zachowania zachowane (§6.7);
- 5.10 — offset modułu OUT 2H jest zamierzony i zachowany 1:1 (§6.5).

**Definition of Done:**
- `apply_cave_tiles()` (a właściwie już `TerrainGenerator.apply_tiles()`) nie zawiera
  ani jednego `set_cell` / `erase_cell`.
- `grep -rn "set_cell\|erase_cell\|set_cells_terrain_connect" scripts/generation/` zwraca
  wyniki **tylko** w `tiling/tile_placement_executor.gd` i `tiling/terrain_paint_executor.gd`.
- Zero `push_warning` o nierozstrzygalnym remisie.
- Trzy świadome zmiany zaakceptowane przez autora, snapshoty zamrożone.

### 12.7. Etap 6 — hash pozycji zamiast RNG w kafelkowaniu

**Cel:** determinizm niezależny od kolejności. **JEDYNY etap zmieniający wygląd celowo.**

**Zadania:**

| # | Zadanie |
|---|---|
| 6.1 | `core/grid_hash.gd` (§8.8) |
| 6.2 | `SideWallPlacer`: `rng.randi() % 2` → `GridHash.variant_ab()` |
| 6.3 | `SolidFillPlacer`: `hash(Vector2i(x, y+seed))` → `GridHash.pick_weighted()` |
| 6.4 | `NichePlacer`: `rng.randf()` → `GridHash.unit(seed, pos, SALT_NICHE)` |
| 6.5 | `NichePlacer`: dystans OUT — dwuprzebiegowy, deterministyczny wybór (§6.3 pkt 4) |
| 6.6 | Wszystkie `ab_noise.get_noise_2d(x,y) > 0.0` → `GridHash.variant_ab()` |
| 6.7 | `apply_tiles()` przestaje przyjmować `rng` — aktualizacja `procedural_level.gd` |
| 6.8 | Zrzuty przed/po dla seedów `119`, `1`, `42`, `999` |
| 6.9 | Nowy baseline snapshotów → `tests/snapshots/etap6/` |

**Definition of Done:**
- `apply_tiles()` nie ma w sygnaturze `RandomNumberGenerator`.
- `grep -rn "randi\|randf" scripts/generation/tiling/ scripts/generation/edge/` → pusto.
- Autor zaakceptował zrzuty (jakość nie gorsza niż Etap 0).
- Nowy baseline zamrożony, dwa uruchomienia dają ten sam digest.
- **Zmiana kolejności placerów w `TilePlacementPlanner` nie zmienia digestu** —
  to jest dowód, że cel etapu osiągnięty. Dodać ten test do `run_tests.gd`.

### 12.8. Etap 7 — profile JSON

**Cel:** dane opuszczają kod.

**Zadania:**

| # | Zadanie |
|---|---|
| 7.1 | `profiles/terrain_profile.gd`, `tile_rule.gd`, `terrain_profile_loader.gd` |
| 7.2 | `profiles/terrain_profile_validator.gd` — 15 sprawdzeń (§11.6) |
| 7.3 | `caves_default.json` — najpierw **tylko** `topology`, `noise`, `features`, `cleanup`, `probabilities`, `placement`, `spawn` |
| 7.4 | Zweryfikować digest — musi być identyczny z Etapem 6 |
| 7.5 | `tiling/tile_rule_resolver.gd` + `edge_rules` w JSON (§11.4) |
| 7.6 | Przenieść wszystkie stałe atlasu z `cave_generator.gd` do `edge_rules` |
| 7.7 | Zweryfikować digest ponownie |
| 7.8 | `caves_rock_only.json`, `caves_roots_heavy.json`, `caves_debug.json` |
| 7.9 | Usunąć ~120 stałych atlasu z `cave_generator.gd` (poza `get_default_palette()`) |

**Kolejność 7.3 → 7.4 → 7.5 → 7.7 jest obowiązkowa.** Przenoszenie parametrów
i współrzędnych atlasu w jednym kroku uniemożliwi zlokalizowanie błędu.

**Definition of Done:**
- Digest identyczny z Etapem 6.
- Przełączenie między 4 profilami **bez zmiany ani jednej linii kodu**.
- Walidator wyłapuje celowo wprowadzony błąd (np. `[2, 40]` — poza atlasem).
- `grep -n "Vector2i([0-9]" scripts/generation/cave_generator.gd` → tylko `get_default_palette()`.

### 12.9. Etap 8 — `TerrainGenerator` i wrapper

**Cel:** publiczne API nowego rdzenia; `cave_generator.gd` to wrapper.

**Zadania:**

| # | Zadanie |
|---|---|
| 8.1 | `terrain_generator.gd` z API z §8.1 |
| 8.2 | `cave_generator.gd` → wrapper z **pełną** sygnaturą (§4.1) |
| 8.3 | `procedural_level.gd`: `apply_cave_tiles(floor, walls, res, rng, decor)` → `TerrainGenerator.apply_tiles(layers, res)` |
| 8.4 | `map_generator_preview.gd`: dodać `OptionButton` wyboru profilu |
| 8.5 | `map_generator_preview.gd`: dodać `CheckBox` przełączania presetu priorytetów |
| 8.6 | Wygenerować zrzuty obu presetów obok siebie → decyzja autora (§6.1) |
| 8.7 | Zapisać decyzję w `caves_default.json` i w tym dokumencie (§6.1) |

**Definition of Done:**
- `cave_generator.gd` ma < 120 linii (wrapper + `get_default_palette()`).
- Podgląd umożliwia przełączanie profili i presetów bez restartu.
- Decyzja o presecie priorytetów podjęta i zapisana.

### 12.10. Etap 9 — jakość, wydajność, higiena

**Cel:** naprawa rzeczy, których nie wolno było ruszać w Etapach 2–7.

| # | Zadanie | Referencja |
|---|---|---|
| 9.1 | `SpawnPlanner`: walidacja przechodniości + BFS fallback | §14 P2-4 |
| 9.2 | Optymalizacja `near_floor` (dylatacja separowalna) | §3.8 |
| 9.3 | Usunięcie podwójnego wypełniania voidu | §3.8 |
| 9.4 | Pętla zbieżna pre-passów po naprawie spójności | §3.7 |
| 9.5 | Symetria łączników 2H→3H (brakująca gałąź schodkowa) | §3.1 |
| 9.6 | Ujednolicenie trzech tolerancji `has_same_y` (`1` / `4` / `2`) — **tylko jeśli zrzut nie pokaże regresji** | §9.6 uwaga 1 |
| 9.7 | Usunięcie martwych aliasów stałych | §2.12 |
| 9.8 | Reguły izolacji jako skrypt `tests/check_isolation.gd` | §7.3, §13.5 |

Każde zadanie = osobny commit z porównaniem zrzutów.

### 12.11. Etap 10 — filary i brakujące moduły atlasu

| # | Zadanie | Referencja |
|---|---|---|
| 10.1 | `edge/pillar_detector.gd` + `tiling/pillar_placer.gd` | §6.2 |
| 10.2 | `allow_pillars: true` w `caves_default.json` | |
| 10.3 | Schodki 2H — `allow_2h_steps` + reguły `(1,19..21)` / `(4,19..21)` | §14 P2-1 |
| 10.4 | Zakończenia rimu roots — `allow_rim_segment_caps` + reguły `(1,8)/(1,9)` / `(4,8)/(4,9)` | §14 P2-2 |

Każda funkcja za flagą, domyślnie `false`, włączana po weryfikacji wizualnej.

### 12.12. Etap 11 — zamek i biblioteka

| # | Zadanie |
|---|---|
| 11.1 | `RectangularRoomCarver`, `OrthogonalCorridorCarver` |
| 11.2 | `topology/door_generator.gd` — z `_detect_and_place_doors()` (§5.9) |
| 11.3 | `castle_default.json` — parametry + tileset zamkowy + `edge_rules` |
| 11.4 | `library_default.json` — jak castle, szersze korytarze, inny dekorator |
| 11.5 | **NIE** tworzyć `decoration/` — dekoratory z RD-1 produkują obiekty, więc należą do `objects/strategies/` w Etapie 12 (§6.8 pkt 4). W Etapie 11 zamek i biblioteka dostają tylko profile terenu i `edge_rules` |
| 11.6 | `procedural_level.gd`: `LevelType.DUNGEON_CASTLE` → `TerrainGenerator` z `castle_default` |
| 11.7 | **Nie usuwać** `dungeon_generator.gd` ani `apply_grid_to_layers()` do potwierdzenia |

### 12.13. Etap 12 — `ObjectGenerator` (osobny system)

**Zmienione względem wersji 1.1 dokumentu.** Wcześniejszy plan („las jako typ topologii
`noise_field`") został **unieważniony** decyzją autora §6.8. Las nie jest profilem
generatora wnętrz; obiekty dostają własny system.

**Cel:** wszystko, co nie jest ścianą ani podłogą, jest stawiane jako węzeł scenu przez
osobny generator konsumujący gotowy `GenerationResult`.

| # | Zadanie |
|---|---|
| 12.1 | `objects/object_placement.gd` — opis jednego obiektu: `scene_path`, `cell`, `offset_px`, `rotation`, `z_hint`, `category`, `tags` |
| 12.2 | `objects/object_placement_plan.gd` — plan obiektów + deterministyczna serializacja i digest (analogicznie do `TilePlacementPlan`) |
| 12.3 | `objects/object_generator.gd` — orkiestrator; wejście: gotowy `GenerationResult` (§6.8 pkt 7) |
| 12.4 | `objects/object_rule.gd` + reguły w JSON: gęstość, dozwolone komórki, minimalne odstępy, zakazane strefy (portale) |
| 12.5 | Strategie: `EnemySpawnStrategy`, `ChestSpawnStrategy`, `DoorStrategy`, `PropScatterStrategy`, `WallHuggerStrategy` (pochodnie, regały) |
| 12.6 | Wchłonięcie `spawn/spawn_planner.gd` jako strategii (§6.8 pkt 5) — **pierwsze przemianowanie dozwolone dopiero tutaj** |
| 12.7 | `objects/object_executor.gd` — jedyne miejsce wołające `instantiate()` / `add_child()`; przeniesienie logiki z `MapGeneratorBase.spawn_entities()` |
| 12.8 | Migracja `GenerationResult.{enemy_spawns, chest_spawns, doors, decoration_spawns}` na `ObjectPlacementPlan` — **stare pola zostawić jako widok kompatybilnościowy** |
| 12.9 | `forest_*` jako profil systemu obiektowego (drzewa, krzewy, woda), nie jako profil terenu |
| 12.10 | Dopiero po potwierdzeniu: usunąć `overworld_forest_generator.gd` i `apply_grid_to_layers()` — **decyzja autora, nie AI** |

**Reguły izolacji dla `objects/`** (dopisać do `check_isolation.gd`):

| Katalog | Nie wolno wystąpić | Uzasadnienie |
|---|---|---|
| `objects/*` poza `object_executor.gd` | `instantiate`, `add_child`, `queue_free` | Strategie planują, executor wykonuje |
| `objects/` | `TileMapLayer`, `set_cell`, `atlas_coords` | System obiektowy nie zna kafli |
| `objects/` | zapis do `ctx.grid` / `result.grid` | Siatka jest gotowa i niezmienna |

**Definition of Done:**
- `GenerationResult.grid` nie zawiera żadnego typu poza `WALL` i komórkami przechodnimi.
- Dwa uruchomienia dają ten sam `ObjectPlacementPlan.compute_digest()`.
- Zmiana kolejności strategii nie zmienia digestu (ta sama reguła co §12.7 dla kafli).
- Żaden obiekt nie trafia w komórkę nieprzechodnią ani w strefę portalu.
- `procedural_level.gd` woła `ObjectGenerator` zamiast `spawn_entities()`.

> **Uwaga o `CellType`.** `TREE`, `WATER`, `PATH` i `DECORATION` z `map_generator_base.gd`
> **nie wchodzą** do modelu siatki nowego rdzenia. Zostają w enumie, bo używa ich
> `overworld_forest_generator.gd` i `apply_grid_to_layers()`, ale
> `GridUtils.is_walkable()` ich nie interpretuje (§6.8 pkt 1). Gdy Etap 12.10 usunie
> stare generatory, można je usunąć z enumu — to ostatni krok, nie pierwszy.

> **Otwarte przy Etapie 12 (nie blokuje Etapów 0–11):** czy `CellType.ENTRANCE` / `EXIT`
> mają zostać w siatce jako podtypy podłogi, czy przenieść się w całości do
> `entrance_zone` / `exit_zone` (które już istnieją)? Dziś są w obu miejscach naraz.
> Pod doktryną §6.8 sam portal jest obiektem, a alkowa jest podłogą — więc znaczniki
> w siatce są redundantne. Zmiana dotknęłaby `get_grid_mask_image()` i `_is_walkable()`,
> więc wymaga osobnego commita i zgody autora.

---

## 13. Strategia weryfikacji i testów

Projekt nie ma frameworka testowego (§5.3). **Nie dodajemy GUT ani GdUnit4** — repo
używa submodułów i dodatkowa zależność w `addons/` komplikuje pracę bez proporcjonalnego
zysku. Zamiast tego budujemy trzy małe narzędzia headless.

Wszystkie wzorce w tym rozdziale zostały **sprawdzone** na Godot 4.6 w izolowanym
projekcie — nie są zgadywane.

### 13.1. `tests/check_parse.gd` — kontrola składni

**To narzędzie jest obowiązkowe po każdym etapie.** Błąd z §3.1 przeżył cały commit
i push właśnie dlatego, że go nie było.

> **PUŁAPKA — nie używać `ResourceLoader.load()`.** Sprawdzono: dla pliku z błędem
> parsowania `ResourceLoader.load(path, "GDScript", CACHE_MODE_IGNORE)` zwraca
> **niepustą** referencję i nie sygnalizuje błędu. Jedyna niezawodna metoda to
> `GDScript.reload(true)` + kontrola `can_instantiate()`.

```gdscript
# res://modules/quiz_rpg/tests/check_parse.gd
# Uruchomienie:
#   godot --headless --path . --script res://modules/quiz_rpg/tests/check_parse.gd
extends SceneTree

const ROOTS: Array[String] = [
    "res://modules/quiz_rpg/scripts",
    "res://modules/quiz_rpg/tools",
    "res://modules/quiz_rpg/tests",
]

func _initialize() -> void:
    var files: Array[String] = []
    for root in ROOTS:
        _collect(root, files)
    files.sort()

    var failed: Array[String] = []
    for path in files:
        if not _parses(path):
            failed.append(path)

    print("check_parse: sprawdzono %d plików, błędów: %d" % [files.size(), failed.size()])
    for f in failed:
        print("  BŁĄD PARSOWANIA: ", f)
    quit(1 if not failed.is_empty() else 0)


func _collect(dir_path: String, out: Array[String]) -> void:
    var dir := DirAccess.open(dir_path)
    if dir == null:
        return
    dir.list_dir_begin()
    var name := dir.get_next()
    while name != "":
        if dir.current_is_dir():
            if not name.begins_with("."):
                _collect(dir_path.path_join(name), out)
        elif name.ends_with(".gd"):
            out.append(dir_path.path_join(name))
        name = dir.get_next()
    dir.list_dir_end()


func _parses(path: String) -> bool:
    var src := FileAccess.get_file_as_string(path)
    if src.is_empty() and FileAccess.get_open_error() != OK:
        push_error("check_parse: nie mogę odczytać %s" % path)
        return false
    var sc := GDScript.new()
    sc.source_code = src
    var err := sc.reload(true)
    return err == OK and sc.can_instantiate()
```

**Weryfikacja poprawności samego narzędzia** (sprawdzone):

| Plik | `reload()` | `can_instantiate()` |
|---|---|---|
| `map_generator_base.gd` (poprawny) | `0` (OK) | `true` |
| `cave_generator.gd` @ `0956687` (zepsuty) | `43` (`ERR_PARSE_ERROR`) | `false` |

### 13.2. `tests/run_tests.gd` — runner

```gdscript
# Uruchomienie:
#   godot --headless --path . --script res://modules/quiz_rpg/tests/run_tests.gd
extends SceneTree

var _passed := 0
var _failed := 0
var _messages: Array[String] = []

func _initialize() -> void:
    _run_profile_validation()
    _run_edge_fixtures()
    _run_determinism()
    _run_snapshots()
    _run_placer_order_independence()

    print("\n=== WYNIK: %d OK, %d BŁĄD ===" % [_passed, _failed])
    for m in _messages:
        print("  ", m)
    quit(1 if _failed > 0 else 0)


func _assert(condition: bool, label: String) -> void:
    if condition:
        _passed += 1
    else:
        _failed += 1
        _messages.append("BŁĄD: " + label)
```

**Co uruchamia każda sekcja:**

| Sekcja | Od etapu | Co sprawdza |
|---|---|---|
| `_run_profile_validation()` | 7 | 15 sprawdzeń walidatora na wszystkich profilach (§11.6) |
| `_run_edge_fixtures()` | 4 | 16 fixture'ów ASCII (§16.2) |
| `_run_determinism()` | 1 | dwa uruchomienia tej samej konfiguracji → ten sam digest |
| `_run_snapshots()` | 1 | digest == zapisany snapshot dla 6 kombinacji |
| `_run_placer_order_independence()` | 6 | odwrócenie kolejności placerów nie zmienia digestu |

Ostatnia sekcja jest **najważniejszym testem całego refaktoru** — to ona dowodzi,
że system priorytetów faktycznie zastąpił zależność od kolejności faz.

### 13.3. Snapshoty regresyjne

**Kanoniczna serializacja planu** (ten sam format w Etapie 1 i w `TilePlacementPlan`):

```gdscript
func serialize_canonical() -> String:
    var out := PackedStringArray()
    var layer_names: Array = by_layer.keys()
    layer_names.sort()                                 # kolejność warstw: alfabetycznie

    for layer in layer_names:
        var cells: Dictionary = by_layer[layer]
        var positions: Array = cells.keys()
        positions.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
            return a.y < b.y or (a.y == b.y and a.x < b.x))

        for pos in positions:
            var p: TilePlacement = cells[pos]
            out.append("%s|%d,%d|%d|%d,%d|%d|%s|%d" % [
                layer, p.pos.x, p.pos.y,
                p.source_id, p.atlas_coords.x, p.atlas_coords.y,
                p.alternative_tile, p.category, p.priority
            ])
    return "\n".join(out)
```

`compute_digest()` = `serialize_canonical().sha256_text()`.
(Sprawdzone: `String.sha256_text()` działa headless.)

**Kombinacje do snapshotowania** (stałe przez cały refaktor):

| Nazwa snapshotu | Profil | Seed | Rozmiar | `max_rooms` | Cel |
|---|---|---|---|---|---|
| `caves_default_s119_100x100` | `caves_default` | 119 | 100×100 | 6 | domyślny podgląd |
| `caves_default_s1_60x60` | `caves_default` | 1 | 60×60 | 4 | mała mapa, przypadki brzegowe |
| `caves_default_s7_250x250` | `caves_default` | 7 | 250×250 | 37 | duża mapa, dużo geometrii |
| `caves_default_s42_160x100` | `caves_default` | 42 | 160×100 | 9 | asymetria proporcji |
| `caves_rock_only_s119_100x100` | `caves_rock_only` | 119 | 100×100 | 6 | geometria bez roots |
| `caves_roots_heavy_s119_100x100` | `caves_roots_heavy` | 119 | 100×100 | 6 | BASE + TIPS, zakończenia |

Zapis: `tests/snapshots/<etap>/<nazwa>.sha256` (jedna linia) oraz
`tests/snapshots/<etap>/<nazwa>.txt` (pełna serializacja — do `git diff` przy regresji).

> **Dlaczego oba pliki?** `.sha256` daje szybki test PASS/FAIL. `.txt` pozwala
> zobaczyć **co konkretnie** się zmieniło (`git diff` pokaże, że np. 14 komórek
> kategorii `RIM_BOWL` zmieniło kafel). Bez `.txt` regresja jest niediagnozowalna.
>
> Rozmiar: `.txt` dla `250×250` to ~60 tys. linii (~4 MB). Dopuszczalne, ale
> **tylko ten jeden** duży snapshot trzyma `.txt`; reszta `.txt` dla map ≤ `160×100`.
> Dla `250×250` wystarczy `.sha256`.

**Snapshot siatki** (osobny, tańszy — wykrywa regresje topologii niezależnie od kafli):

```
tests/snapshots/<etap>/<nazwa>.grid.txt    # notacja ASCII, format print_grid_mask_ascii()
tests/snapshots/<etap>/<nazwa>.grid.png    # get_grid_mask_image()
```

Snapshot siatki **nie może** się zmienić w Etapach 2–12 (topologia jest niezmienna
od Etapu 3). Jeśli się zmieni, błąd jest w topologii lub pre-passach — to natychmiast
zawęża obszar poszukiwań.

### 13.4. Fixture'y gridowe dla `EdgeAnalyzer`

**Format** (identyczny z `print_grid_mask_ascii()`):

```
# tests/fixtures/edge/F-01_rim_1h_straight.txt
# Nazwa: prosty rim 1H
# Oczekiwanie dla komórki (3,2):
#   kind=TOP_RIM orientation=NORTH height=0 segment=MIDDLE
@expect 3,2 TOP_RIM NORTH 0 MIDDLE
@grid
#######
#.....#
#######
#######
#.....#
#######
```

Parser: linie `@expect x,y KIND ORIENTATION HEIGHT SEGMENT`, potem `@grid`
i siatka ASCII. `#` = `WALL`, `.` = `FLOOR`, `S` = `ENTRANCE`, `E` = `EXIT`,
spacja = `VOID`.

**Generator fixture'ów** (`tests/dump_edge_fixtures.gd`): wycina okno `11×11`
z rzeczywistej wygenerowanej mapy wokół wskazanej pozycji i zapisuje jako fixture
z aktualną klasyfikacją. Dzięki temu fixture'y opisują **rzeczywiste** przypadki,
a nie ręcznie wymyślone (§4.7).

Procedura dodawania nowego przypadku:
1. Znaleźć go na mapie w podglądzie (włączyć `debug_log_edge_kinds`).
2. `dump_edge_fixtures.gd --seed 119 --at 47,63 --name F-17_nowy_przypadek`.
3. Sprawdzić ręcznie, czy zapisane oczekiwanie jest **poprawne** (to jedyny krok ręczny).
4. Dodać plik do repo.

Lista obowiązkowych fixture'ów: §16.2.

### 13.5. `tests/check_isolation.gd` — egzekwowanie reguł architektury

Reguły z §7.3 są sprawdzalne mechanicznie. Bez tego skryptu zostaną złamane
w ciągu kilku commitów.

```gdscript
extends SceneTree

const RULES: Array[Dictionary] = [
    { "dir": "res://modules/quiz_rpg/scripts/generation/topology",
      "forbidden": ["TileMapLayer", "set_cell", "erase_cell", "set_cells_terrain_connect",
                    "theme_id", "atlas_coords"] },
    { "dir": "res://modules/quiz_rpg/scripts/generation/preprocess",
      "forbidden": ["TileMapLayer", "set_cell", "erase_cell", "atlas_coords", "theme_id"] },
    { "dir": "res://modules/quiz_rpg/scripts/generation/edge",
      "forbidden": ["TileMapLayer", "set_cell", "erase_cell"] },
    { "dir": "res://modules/quiz_rpg/scripts/generation/core",
      "forbidden": ["TileMapLayer"] },
    { "dir": "res://modules/quiz_rpg/scripts/generation/profiles",
      "forbidden": ["TileMapLayer"] },
]

# Dodatkowo: pliki *_placer.gd nie mogą zawierać set_cell/erase_cell,
# a set_cell/erase_cell/set_cells_terrain_connect wolno wystąpić WYŁĄCZNIE
# w tile_placement_executor.gd i terrain_paint_executor.gd.
```

Dwa dodatkowe sprawdzenia:

1. **Literały priorytetów:** żaden plik poza `core/placement_priority.gd` nie może
   zawierać `priority = <liczba>`.
2. **Literały atlasu (od Etapu 7):** żaden plik poza `profiles/` nie może zawierać
   `Vector2i(<cyfra>, <cyfra>)` w kontekście stałej kafla. Heurystyka: odrzucamy
   dopasowania, gdzie któraś współrzędna jest ujemna lub gdzie linia zawiera
   `+ Vector2i` (offsety sąsiedztwa są dozwolone).

Wyjątek przejściowy dla Etapów 2–6 zapisany w samym skrypcie jako lista
`ALLOWED_UNTIL_STAGE_7`.

### 13.6. Weryfikacja wizualna — procedura

Dla każdego etapu oznaczonego jako „zmienia wygląd":

1. Wygenerować zrzuty dla seedów `119`, `1`, `42`, `999` przy `100×100`, typ Jaskinie.
2. Zapisać do `docs/reference_screenshots/etap<N>/`.
3. Dla każdego seeda zrobić zrzut **z włączonym podglądem maski** (`M` w podglądzie)
   — to pokazuje, czy zmiana jest w geometrii czy tylko w kaflach.
4. Porównać z `etap0/` i z poprzednim etapem.
5. Przedstawić autorowi. **Decyzja o akceptacji należy do autora, nie do AI.**

Rozszerzenia podglądu potrzebne do tej procedury (Etap 8, zadania 8.4–8.5):

| Kontrolka | Funkcja |
|---|---|
| `OptionButton` „Profil" | wybór `caves_default` / `rock_only` / `roots_heavy` / `debug` |
| `CheckBox` „Preset priorytetów" | `legacy_facade_wins` / `readme_rim_wins` |
| `CheckBox` „Log EdgeKind" | `flags.debug_log_edge_kinds` |
| `Button` „Zapisz zrzut" | `get_viewport().get_texture().get_image().save_png()` |
| `Button` „Zapisz snapshot" | zapis `.sha256` + `.txt` do wskazanego katalogu |
| Etykieta „Digest" | pierwsze 12 znaków `compute_digest()` — natychmiastowa informacja, czy coś się zmieniło |

Etykieta z digestem jest tanim i bardzo skutecznym narzędziem: autor widzi na bieżąco,
czy zmiana w kodzie wpłynęła na wynik, bez uruchamiania testów.

---

## 14. Lista błędów i rzeczy do weryfikacji wizualnej

Priorytety: **P0** = blokuje, **P1** = wymaga decyzji przed Etapem 6,
**P2** = brakująca funkcja / ulepszenie, **P3** = nice-to-have.

Kolumna „Status" określa, czy problem jest **potwierdzony** (zweryfikowany maszynowo
lub jednoznacznie wynikający z kodu), czy **do weryfikacji** (wymaga obejrzenia zrzutu).

---

### P0 — blokujące

#### P0-1 — Błąd parsowania na `main` · POTWIERDZONY (naprawiony lokalnie, niezacommitowany)

- **Plik:** `cave_generator.gd:1170`
- **Objaw:** `Parse Error: Identifier "right_is_2h_step" not declared in the current scope.`
  Cały `LevelType.CAVE_DUNGEON` nie działa.
- **Weryfikacja:** Godot 4.6 `--headless --check-only` (§3.1).
- **Naprawa:** przywrócić dwie deklaracje przed pierwszym `if`:
  ```gdscript
  var left_is_2h_step: bool = check_2h_col.call(x - 1, y - 1)
  var right_is_2h_step: bool = check_2h_col.call(x + 1, y - 1)
  ```
- **Działanie:** zacommitować + dodać `check_parse.gd` (Etap 0).

---

### P1 — wymagają decyzji autora (weryfikacja wizualna)

#### P1-1 — Narożnik OUT 2H rysowany o wiersz wyżej niż fasada prosta 2H · ZAMKNIĘTY: ZAMIERZONE

- **Pliki/linie:** `cave_generator.gd:1208–1231` (`w_open`), `1252–1271` (`e_open`)
  vs `1136–1140` (prosta 2H)
- **Rozstrzygnięcie autora:** *„jak działa to nie ruszaj, 2h są dobrze zrobione."* (§6.5)
- **Opis stanu, który należy ZACHOWAĆ 1:1:**

  | Wariant | `base` | `top` | `crown` | Rim |
  |---|---|---|---|---|
  | Prosta 2H (`is_2h`) | `y` (wiersz **podłogi**) | `y-1` | — | `y-2` z FAZY 4 |
  | OUT 2H (`w_open`/`e_open`) | `y-1` (wiersz **ściany**) | `y-2` | `y-3` | — |

  Różnica wynika z układu atlasu: moduły zakończeń 2H zajmują wiersze 19–20,
  a prosta 2H wiersze 20–21. Grafika zakończenia zawiera górną warżkę w wierszu 19,
  więc przesunięcie na mapie jest kompensacją, nie błędem.
- **Wiążące wymagania:**
  - reguła profilu `out_corner / {west,east} / 2h` ma `"draws_on_floor_row": false`
    i `"row_offset": -1`;
  - krok 5.10 (Etap 5) jest migracją **bit-exact**;
  - fixture'y `F-11` i `F-12` (§16.2) zapisują to zachowanie jako oczekiwanie —
    ich niepowodzenie po refaktorze to regresja, nie „wykrycie błędu";
  - **nie ujednolicać** konwencji `draws_on_floor_row` między wariantami wysokości.
- **Wniosek ogólny:** różnica między modułami nie jest dowodem defektu.
  Niekonsekwencja w kodzie przy poprawnym obrazie = zachować i udokumentować.

#### P1-2 — Korona fasady 3H rysowana bez sprawdzenia, czy `y-3` jest ścianą · POTWIERDZONY (dziś maskowany)

- **Plik/linia:** `cave_generator.gd:1489–1491`
- **Opis:** `walls_layer.set_cell(pos + Vector2i(0, -3), 0, crown_t)` — brak warunku.
  Osiągalne przy `flags.enable_grid_cleanup = false` (§3.5).
- **Naprawa:** `FacadePlacer` musi sprawdzić `not GridUtils.is_walkable(ctx.grid, pos + Vector2i(0,-3))`
  przed zakolejkowaniem korony, a przy niespełnieniu — `push_error` z pozycją
  (bo to znaczy, że `WallThicknessPass` nie zrobił swojej roboty).
- **Wpływ na wygląd:** przy domyślnych flagach **zerowy** (pre-pass usuwa przypadek).
  Digest nie powinien się zmienić.

#### P1-3 — `CORNER` przestanie nadpisywać `SIDE_WALL_FIXED` · DO WERYFIKACJI

- **Pliki/linie:** `cave_generator.gd:1224–1227`, `1263–1266` (zapis bezwarunkowy)
  vs `1486`, `1510`, `1539` (zapis warunkowy)
- **Opis:** ta sama kategoria `"CORNER"` ma dwa różne zachowania (§3.3, cykl priorytetów).
  Ujednolicenie do wariantu warunkowego (`CORNER` = 45 < `SIDE_WALL_FIXED` = 60)
  zmieni wynik w komórkach, gdzie oba trafiają w to samo miejsce.
- **Jak zweryfikować:** przed migracją dodać licznik: ile razy bezwarunkowy zapis
  `CORNER` nadpisuje istniejący `SIDE_FIXED`/`FACADE`. Jeśli 0 dla wszystkich
  6 kombinacji snapshotowych → zmiana jest bezpieczna i digest się nie zmieni.
- **Działanie:** Etap 5, krok 5.6.

#### P1-4 — Miska pod zakończeniem rimu: różny warunek nadpisania rock vs roots · ZAMKNIĘTY: ROZWIĄZANY PROJEKTOWO

- **Pliki/linie:** rock `1613`, `1620` (`not has or == "ROCK"`)
  vs roots `1621` (`not (FACADE or SIDE_FIXED or CORNER)`)
- **Uwaga nazewnicza:** `RIM_BOWL` to etykieta kategorii wprowadzona w tym dokumencie,
  **nie występuje w kodzie**. Pochodzi od komentarza autora w linii 1584:
  `# FAZA 4: Dolny rim, półki i misy (Rims & Bowls)`. Pełne wyjaśnienie: §6.7.
- **Co to jest:** przy zakończeniu rimu kod stawia dodatkowy kafel **jedną komórkę niżej**
  (rock: `(4,1)` / `(1,1)`; roots: `(4,10)` / `(1,10)`), domykający półkę.
- **Praktyczna różnica:** gdy pod zakończeniem rimu stoi ściana boczna (`SIDE` z FAZY 3),
  wariant roots zamaluje ją miską, a wariant rock ją zostawi.
- **Rozwiązanie (bez zmiany wyglądu, bez decyzji autora):** dwie kategorie placementu,
  przypisywane per motyw przez pole `bowl_category` w profilu:
  ```
  RIM_BOWL           = 15    ← rock:  nadpisuje tylko SOLID_FILL
  RIM_BOWL_DECORATED = 42    ← roots: nadpisuje też SIDE_WALL i RIM_BASE
  ```
  Oba obecne zachowania zachowane dokładnie; koszt to jeden wpis w tabeli priorytetów.
- **Konsekwencja:** krok 5.5 w Etapie 5 jest migracją **bit-exact**.

#### P1-5 — `STEP` vs `FACADE` — dziś rozstrzyga kolejność skanowania · POTWIERDZONY

- **Opis:** oba zapisują `placed_tiles[...] = "FACADE"` bezwarunkowo, więc przy
  kolizji wygrywa ten, który wykonał się później (sortowanie `sorted_xs` rosnąco,
  potem kolejność w `facade_cols[x]`). Rozdzielenie na `STEP` (65) i `FACADE` (70)
  czyni rozstrzygnięcie jawnym, ale może zmienić wynik.
- **Jak zweryfikować:** przed migracją policzyć kolizje `STEP` ↔ `FACADE`.
- **Działanie:** Etap 5, krok 5.9.

#### P1-6 — Asymetria łączników 2H↔3H · POTWIERDZONY

- **Plik/linia:** `cave_generator.gd:1142–1180` (§3.1)
- **Opis:** kierunek 3H→2H obsługuje przypadek schodkowy (`dy_off = -1`),
  kierunek 2H→3H nie. Dawna gałąź `left_is_2h_step` z `dy_off` została usunięta
  w commicie `0956687`.
- **Skutek:** przejście 2H→3H schodkiem wygląda inaczej niż 3H→2H schodkiem.
- **Naprawa:** `ConnectorPlacer` obsługuje `orientation = EAST` i `WEST` symetrycznie,
  z tym samym mechanizmem `row_offset` dla przypadku schodkowego.
- **Działanie:** Etap 9, zadanie 9.5 (nie w Etapie 5 — tam trzymamy bit-exact).

---

### P2 — brakujące funkcje

#### P2-1 — Schodki 2H nieużywane · POTWIERDZONY

- **Atlas:** `(1,19)` `(1,20)` `(1,21)` i `(4,19)` `(4,20)` `(4,21)`
- **Stałe:** `WALL_2H_SLOPE_LEFT_*`, `WALL_2H_SLOPE_RIGHT_*` — zadeklarowane, 0 użyć
- **Skutek:** schodek na fasadzie 2H jest dziś obsługiwany modułami 3H
  (`MOD_CRNR_*_IN`, wysokość 3) albo łącznikiem, co przy ścianie o głębokości 2
  daje niedopasowany moduł.
- **Działanie:** Etap 10, zadanie 10.3, za flagą `allow_2h_steps`.
  Wymaga rozszerzenia `StepPlacer` o `facade_height = 2`.

#### P2-2 — Zakończenia rimu roots nieużywane · POTWIERDZONY

- **Atlas:** `(1,8)` `(1,9)` (lewe) i `(4,8)` `(4,9)` (prawe)
- **Stałe:** `ROOT_TOP_TIPS_LEFT/RIGHT`, `ROOT_TOP_BASE_LEFT/RIGHT` — 0 użyć
- **Skutek:** to jest **dokładnie** problem, który RD-2 opisuje jako
  „prawa końcówka bez kafla". Rimy roots kończą się dziś kaflem środkowym
  (`ROOT_TOP_*[A/B]`) albo skosem (`(5,9)/(5,10)`, `(0,9)/(0,10)`),
  ale nie mają dedykowanych zakończeń segmentu.
- **Działanie:** Etap 10, zadanie 10.4, za flagą `allow_rim_segment_caps`.
  Wymaga działającego `FacadeSegmentDetector` (Etap 4) — dlatego nie da się
  tego zrobić przed refaktorem.

#### P2-3 — Filary usunięte · POTWIERDZONY

- **Historia:** `_build_free_standing_pillars()` + `_assemble_pillar()`
  w `0792c03`, usunięte w `0956687`
- **Działanie:** Etap 10, zadanie 10.1 (decyzja autora §6.2)

#### P2-4 — Spawny bez walidacji przechodniości · POTWIERDZONY

- **Plik/linie:** `cave_generator.gd:344–347` (boss), `350–364` (wrogowie/skrzynie)
- **Opis:** `room.get_center() + Vector2i(rng.randi_range(-2,2), rng.randi_range(-2,2))`
  oraz `exit_room.get_center() + Vector2i(0,-2)` — bez sprawdzenia `is_walkable()`.
  Komory są organiczne (elipsa + lobes), więc komórka `center + (-2,-2)` może być ścianą.
- **Skutek:** wróg lub skrzynia wewnątrz litej skały — niedostępna, potencjalnie
  blokująca ukończenie poziomu, jeśli to skrzynia z wymaganym przedmiotem.
- **Naprawa:** `SpawnPlanner` z BFS fallbackiem (promień max 4) do najbliższej
  przechodniej komórki. Deterministyczny: BFS w kolejności `UP, RIGHT, DOWN, LEFT`.
- **Działanie:** Etap 9, zadanie 9.1. **Nie w Etapie 3** — zmieniłoby digest.

#### P2-5 — Gracz i przeciwnicy mają różne maski kolizji · ZAMKNIĘTY: ZAMIERZONE

- **Pliki:** `player.tscn:127,149` (`collision_mask = 6`),
  `enemy.tscn:13` (`collision_mask = 39`)
- **Rozstrzygnięcie autora:** *„Platform collisions będą zaimplementowane tak, że przed
  platformami aż do końca kolizji platformy będą area2d dzięki czemu będą funkcjonalne."*
  (§6.6)
- **Wykładnia:** `physics_layer_1` tilesetu (warstwa projektu 6 `PlatformCollisions`)
  nie jest docelowo zwykłą kolizją — ma obsługiwać platformy i nawisy przez `Area2D`
  rozciągnięty od przodu platformy do końca jej geometrii kolizji. Obecna asymetria
  masek to stan przejściowy w kierunku tego rozwiązania.
- **Działanie:** żadne. Refaktor generatora nie dotyka masek ani warstw fizyki.
  Kolizje pochodzą z `caves.tres` per kafel i pozostaną nietknięte, dopóki zachowujemy
  współrzędne atlasu.
- **Przyszłe wymaganie (poza Etapami 0–12):** gdy platformy `Area2D` będą wdrażane,
  generator może potrzebować wyjścia w postaci listy prostokątów platform
  (`GenerationResult.platform_zones: Array[Rect2i]`), żeby scena mogła z nich
  utworzyć `Area2D`. `GenerationResult` jest rozszerzalny (§5.10), więc dodanie
  pola nie złamie niczego.

---

### P3 — nice-to-have

#### P3-1 — `hash()` na `Vector2i` niestabilny między wersjami silnika · POTWIERDZONY

- Plik/linia: `cave_generator.gd:1065`. Szczegóły: §3.9.
- Działanie: Etap 6, zadanie 6.3 (`GridHash.pick_weighted`).

#### P3-2 — Navmesh nie ma dziur na ściany · POTWIERDZONY (dziś bez skutku)

- **Plik:** `map_generator_base.gd:366–396`
- **Opis:** `NavigationPolygon` ma tylko prostokątny obrys mapy — cała mapa jest
  „nawigowalna", ściany włącznie. `NavigationRegion2D` jest dodawany jako dziecko
  poziomu i nie ma własnych dzieci z geometrią kolizji, więc `bake_navigation_polygon()`
  nie ma z czego wyciąć dziur.
- **Dlaczego dziś to nie szkodzi:** `enemy_base.gd:67` pobiera `NavigationAgent2D`,
  ale **nigdzie go nie używa** (jedyne wystąpienie `_nav_agent` w pliku).
  Przeciwnicy nie korzystają z pathfindingu.
- **Działanie:** poza zakresem refaktoru generatora. Jeśli pathfinding kiedyś wejdzie,
  `GenerationResult.grid` trzeba przekuć na `add_outline()` per spójny obszar podłogi
  (lub na `NavigationMeshSourceGeometryData2D` z prostokątów ścian).
  Zanotowane, żeby nie zginęło.

#### P3-3 — Podwójne wypełnianie voidu + kosztowna dylatacja `near_floor` · POTWIERDZONY

- Szczegóły i rekomendacje: §3.8. Działanie: Etap 9, zadania 9.2–9.3.

#### P3-4 — Trzy różne tolerancje sąsiedztwa fasad · POTWIERDZONY

- `has_same_y`: `abs(fy - cy) <= 1` (:1097)
- `left_y` / `right_y`: `abs(ly - y) <= 4` (:1186, :1193)
- FAZA 2.5: `abs(fy - sy) <= 2` (:1530)
- **Opis:** trzy różne progi „ta sama wysokość" w jednej funkcji. Prawdopodobnie
  narosłe historycznie, nie zaprojektowane.
- **Działanie:** Etap 9, zadanie 9.6 — **tylko** jeśli ujednolicenie nie pokaże
  regresji na zrzutach. Jeśli pokaże, zostawić trzy progi i udokumentować je
  jako parametry profilu (`segment_tolerance_same`, `segment_tolerance_step`,
  `segment_tolerance_sidewall`).

#### P3-5 — Martwe aliasy stałych · POTWIERDZONY

- `WALL_LEFT`, `WALL_RIGHT`, `WALL_BOTTOM_*_LEFT/RIGHT`, `CORNER_INNER_TOP_*`,
  `ROOT_WALL_LEFT/RIGHT`, `ROOT_BOTTOM_*_LEFT/RIGHT`, `ROOT_CORNER_INNER_TOP_*`
  — zadeklarowane jako „kompatybilność wsteczna", zero użyć.
- **Działanie:** Etap 7, zadanie 7.9 (razem z przeniesieniem atlasu do JSON).

#### P3-6 — Wzór skały przesunięty pionowo, nie niezależny per seed · POTWIERDZONY

- Szczegóły: §3.9 punkt 2. Naprawia się samo przy Etapie 6.

---

### 14.1. Tabela zbiorcza

| ID | Priorytet | Status | Etap naprawy |
|---|---|---|---|
| P0-1 | P0 | potwierdzony, naprawiony lokalnie | 0 |
| P1-1 | — | **ZAMKNIĘTY: zamierzone** (§6.5) | zachować 1:1 w kroku 5.10 |
| P1-2 | P1 | potwierdzony (maskowany przez pre-pass) | 5 (krok 5.7) |
| P1-3 | P1 | **pomiar**, decyzja tylko jeśli licznik > 0 | 5 (krok 5.6) |
| P1-4 | — | **ZAMKNIĘTY: rozwiązany projektowo** (§6.7) | zachować 1:1 w kroku 5.5 |
| P1-5 | P1 | **pomiar**, decyzja tylko jeśli licznik > 0 | 5 (krok 5.9) |
| P1-6 | P1 | potwierdzony | 9 (9.5) |
| P2-1 | P2 | potwierdzony | 10 (10.3) |
| P2-2 | P2 | potwierdzony | 10 (10.4) |
| P2-3 | P2 | potwierdzony | 10 (10.1) |
| P2-4 | P2 | potwierdzony | 9 (9.1) |
| P2-5 | — | **ZAMKNIĘTY: zamierzone** (§6.6) | brak działania |
| P3-1 | P3 | potwierdzony | 6 (6.3) |
| P3-2 | P3 | potwierdzony (bez skutku) | poza zakresem |
| P3-3 | P3 | potwierdzony | 9 (9.2–9.3) |
| P3-4 | P3 | potwierdzony | 9 (9.6, warunkowo) |
| P3-5 | P3 | potwierdzony | 7 (7.9) |
| P3-6 | P3 | potwierdzony | 6 (6.3) |

---

## 15. Zasady pracy dla implementującego AI

### 15.1. Kolejność czytania przed rozpoczęciem pracy

1. Ten dokument, rozdziały 2, 6, 9, 10, 12 — **obowiązkowo w całości**.
2. `modules/quiz_rpg/scripts/generation/cave_generator.gd` — **cały plik**,
   nie fragmenty. Refaktor bez znajomości całości skończy się utratą przypadków brzegowych.
3. `modules/quiz_rpg/scripts/maps/procedural_level.gd` — jedyny produkcyjny konsument.
4. `modules/quiz_rpg/resources/maps/caves.tres`, sekcja `[resource]` na końcu
   (definicje `terrain_set` i `physics_layer`).

### 15.2. Bezwzględne zakazy

| Zakaz | Dlaczego |
|---|---|
| Nie zmieniać kolejności passów z tabeli P1–P12 | §3.6 — zmieni wynik |
| Nie rozdzielać `_cleanup_grid_before_tiling()` na trzy niezależne pętle | §12.4, pułapka 3 |
| Nie „upraszczać" warunków z §9.6 | Każdy z nich odpowiada za konkretny przypadek brzegowy |
| Nie ujednolicać trzech tolerancji `has_same_y` przed Etapem 9 | §14 P3-4 |
| Nie zmieniać kolejności zużycia RNG w `OrganicCaveRoomCarver` | §8.4 uwaga |
| Nie wpisywać literałów priorytetu w placerach | §10.2 |
| Nie wołać `set_cell` / `erase_cell` poza executorami | §7.3 |
| Nie usuwać `apply_grid_to_layers()` przed Etapem 12 | §6.4 |
| Nie zmieniać sygnatury `CaveGenerator.generate()` | §4.1 |
| Nie dodawać GUT / GdUnit4 | §13 wstęp |
| Nie akceptować zmiany digestu w Etapach 2–5 „bo ładniej wygląda" | §12.0 pkt 4 |
| Nie łączyć etapów | §12.0 pkt 6 |
| Nie zmieniać soli w `GridHash` po Etapie 6 | §8.8 — unieważni baseline |
| Nie „naprawiać" offsetu modułu narożnika OUT 2H | §6.5 — zamierzone, `draws_on_floor_row: false` |
| Nie ujednolicać `RIM_BOWL` i `RIM_BOWL_DECORATED` do jednej kategorii | §6.7 — rozdzielenie zachowuje oba zachowania |
| Nie zmieniać masek kolizji gracza ani przeciwników | §6.6 — zamierzone, docelowo `Area2D` |
| Nie traktować niekonsekwencji w kodzie jako dowodu defektu | §6.5 — jeśli obraz jest poprawny, zachować i udokumentować |
| Nie dodawać `TREE` / `WATER` / `PATH` do `GridUtils.is_walkable()` | §6.8 pkt 1 — siatka jest binarna |
| Nie wciągać lasu do profili generatora wnętrz | §6.8 — las to system obiektowy |
| Nie wprowadzać propsów (kamienie, kałuże, grzyby) jako kafli | §6.8 pkt 4 — to obiekty |
| Nie przemianowywać `spawn/spawn_planner.gd` przed Etapem 12 | §6.8 pkt 5 — Etapy 3–9 są bit-exact |
| Nie dodawać drugiej soli `SALT_VARIANT_AB_SIDE` | §8.8 — autor wybrał jedną sól |

### 15.3. Kiedy zatrzymać się i zapytać autora

- Digest zmienił się w Etapie 2, 3, 4 lub 5, a nie jest to jedna z trzech
  świadomych zmian z §12.6.
- `check_isolation.gd` zgłasza naruszenie, którego nie da się usunąć bez zmiany
  architektury z §7.
- Zrzut po etapie wygląda gorzej niż `etap0/` — **nie „naprawiać na oślep"**,
  pokazać autorowi obie wersje.
- Pomiar dla P1-3 lub P1-5 dał licznik > `0` (czyli zmiana priorytetów faktycznie
  wpłynie na wygląd).
- Walidator profilu zgłasza błąd w `caves.tres`, którego nie da się naprawić
  po stronie profilu (np. brakujący kafel w atlasie).
- Zrzuty Etapu 6 pokazują, że jedna sól `SALT_VARIANT_AB` daje zły efekt na stykach
  ścian bocznych z fasadami (§8.8 — wtedy wraca pytanie o drugą sól).
- Pojawia się element, którego nie da się jednoznacznie przypisać do „kafel" albo
  „obiekt" (§6.8). Nie zgadywać — granica zakresu jest decyzją autora.

**Nie pytać ponownie** o punkty zamknięte w §6.5, §6.6, §6.7 i §6.8 — są rozstrzygnięte.
Lista wszystkich rozstrzygniętych pytań: §16.6.

### 15.4. Format commitów

Jeden commit = jedno zadanie z tabel w §12. Wiadomość:

```
gen: <etap>.<zadanie> <krótki opis>

<co zrobione>
<czy digest się zmienił: TAK/NIE + dlaczego>
<snapshoty: zaktualizowane / bez zmian>
```

Przykład:

```
gen: 3.18 wydzielenie ośmiu GridPass do preprocess/

Przeniesiono _smooth_cave_junctions, _remove_1height_walls,
_enforce_wall_thickness, _flatten_short_3h_bulges oraz cztery reguły
_cleanup_grid_before_tiling do osobnych plików GridPass.
Kolejność wg tabeli P1-P12. Trzy reguły cleanup działają w jednej
pętli zbieżnej przez GridPreprocessor.run_convergent().

Digest: NIE ZMIENIONY (bit-exact, 6/6 snapshotów OK).
Snapshoty: bez zmian.
```

Wiadomość mówiąca „digest: TAK" bez uzasadnienia i bez zgody autora jest
powodem do odrzucenia commita.

### 15.5. Lista kontrolna przed zamknięciem etapu

```
[ ] check_parse.gd  → exit 0
[ ] run_tests.gd    → exit 0
[ ] check_isolation.gd → exit 0   (od Etapu 3)
[ ] Digest: identyczny / zmieniony świadomie i zaakceptowany
[ ] Mapa generuje się w map_generator_preview.tscn dla seedów 119, 1, 42, 999
[ ] Mapa generuje się dla 250x250 seed 7 (test wydajności i przypadków brzegowych)
[ ] Zrzuty zapisane do docs/reference_screenshots/etap<N>/  (jeśli etap zmienia wygląd)
[ ] git status czysty
[ ] Definition of Done z §12 spełniony w całości
```

### 15.6. Jak NIE refaktorować (antywzorce zaobserwowane w tym kodzie)

1. **Nie usuwać deklaracji zmiennej, zostawiając jej użycie.** Dokładnie to zdarzyło
   się w `0956687` (§3.1). `check_parse.gd` po każdej zmianie.
2. **Nie zostawiać martwych flag.** `enable_rim_capping` sugeruje istnienie funkcji,
   której nie ma — to wprowadza w błąd i RD-1 się na to nabrał (§4.4).
3. **Nie deklarować stałych „na przyszłość".** `WALL_2H_SLOPE_*` czekają nieużywane;
   trudno teraz stwierdzić, czy to brakująca funkcja czy porzucony pomysł.
   Jeśli stała nie jest używana — albo jest zadanie w backlogu (jak P2-1),
   albo trzeba ją usunąć.
4. **Nie używać literałów tam, gdzie istnieje nazwana stała.** `Vector2i(2,0)` jest
   używane w FAZIE 4, mimo że istnieje `WALL_TOP[0]`. Zmiana atlasu wymagałaby
   znalezienia wszystkich literałów.
5. **Nie mieszać faz.** `apply_cave_tiles()` modyfikuje siatkę w KROKU 0 — to źródło
   trzech osobnych problemów (§3.5).

---

## 16. Załączniki

### 16.1. Szybka mapa: „co gdzie było" → „co gdzie będzie"

| Obecny element (`cave_generator.gd`) | Linie | Cel |
|---|---|---|
| `class GenerationFlags` | 13–24 | `core/generation_flags.gd` |
| Stałe atlasu (rock) | 30–183 | `resources/generation/profiles/caves_default.json` → `edge_rules` |
| Stałe atlasu (roots) | 79–148 | jak wyżej |
| `get_default_palette()` | 187–195 | pozostaje w wrapperze (używa jej `procedural_level.gd:95`) |
| `generate()` | 198–366 | `terrain_generator.gd` + `topology/interior_room_layout_generator.gd` |
| `_get_reachable_cells()` | 368–392 | `core/grid_utils.gd` |
| `_ensure_rooms_connected()` | 394–424 | `topology/connectivity_repair.gd` |
| `_remove_1height_walls()` | 426–456 | `preprocess/remove_1h_walls_pass.gd` |
| `_carve_cave_chamber()` | 458–481 | `topology/organic_cave_room_carver.gd` |
| `_carve_organic_corridor()` | 483–565 | `topology/organic_corridor_carver.gd` |
| `_smooth_cave_junctions()` | 567–612 | `preprocess/junction_smoothing_pass.gd` |
| `_enforce_wall_thickness()` | 614–659 | `preprocess/wall_thickness_pass.gd` |
| `_get_vertical_wall_thickness()` | 661–674 | **USUNĄĆ** (martwa) |
| `_carve_portal_alcove()` | 676–772 | `topology/portal_generator.gd` |
| `_cleanup_grid_before_tiling()` R1+R3A | 774–834 | `preprocess/spike_cleanup_pass.gd` |
| `_cleanup_grid_before_tiling()` R2 | 806–809 | `preprocess/thin_bridge_cleanup_pass.gd` |
| `_cleanup_grid_before_tiling()` R3B | 818–828 | `preprocess/staircase_normalizer_pass.gd` |
| `_flatten_short_3h_bulges()` | 836–878 | `preprocess/short_bulge_flatten_pass.gd` |
| `_clean_terrain_mask()` | 880–901 | `tiling/terrain_mask_planner.gd` |
| `apply_cave_tiles()` KROK 0 | 934–937 | **USUNĄĆ** (przenosi się do `generate()`, P10–P11) |
| `apply_cave_tiles()` KROK 1 (void) | 939–944 | `tiling/solid_fill_placer.gd` |
| `apply_cave_tiles()` KROK 2a | 946–960 | `tiling/floor_placer.gd` |
| `apply_cave_tiles()` KROK 2b–2c | 962–1024 | `tiling/terrain_mask_planner.gd` |
| `apply_cave_tiles()` KROK 3 (`get_use_roots`) | 1026–1058 | `edge/theme_resolver.gd` |
| FAZA 1 | 1060–1074 | `tiling/solid_fill_placer.gd` |
| FAZA 2 — `facade_cols` | 1078–1091 | `edge/facade_segment_detector.gd` |
| FAZA 2 — `is_2h`, prosta 2H | 1094–1140 | `tiling/facade_placer.gd` |
| FAZA 2 — łączniki | 1142–1180 | `tiling/connector_placer.gd` |
| FAZA 2 — `w_open` / `e_open` | 1198–1292 | `tiling/out_corner_placer.gd` |
| FAZA 2 — schodki | 1295–1372 | `tiling/step_placer.gd` |
| FAZA 2 — nisze | 1374–1478 | `tiling/niche_placer.gd` |
| FAZA 2 — ściana prosta 3H + zakończenia | 1480–1518 | `tiling/facade_placer.gd` + `corner_placer.gd` |
| FAZA 2.5 | 1520–1557 | `tiling/corner_placer.gd` |
| FAZA 3 | 1559–1582 | `tiling/side_wall_placer.gd` |
| FAZA 4 | 1584–1692 | `tiling/rim_placer.gd` |
| Wymazanie portali | 1694–1696 | `tiling/portal_clear_placer.gd` |
| `_is_walkable()` | 1699–1701 | `core/grid_utils.gd` (rozszerzone o `PATH`, `TREE` — §12.13) |
| `get_grid_mask_image()` | 1704–1728 | zostaje (używane przez podgląd) |
| `print_grid_mask_ascii()` | 1730–1748 | `tests/` — przydatne w fixture'ach |
| Spawny (boss, wrogowie, skrzynie) | 344–364 | `spawn/spawn_planner.gd` |

### 16.2. Obowiązkowe fixture'y `EdgeAnalyzer`

Lista bazuje na RD-2 („Testy obowiązkowe"), skorygowana o rzeczywiste możliwości
tilesetu i uzupełniona o przypadki wykryte w analizie.

| ID | Nazwa | Sprawdza |
|---|---|---|
| F-01 | `rim_1h_straight` | `TOP_RIM / NORTH / 0 / MIDDLE` |
| F-02 | `rim_roots_base_tips` | `TOP_RIM` + dekoracja na `pos + (0,-1)` |
| F-03 | `rim_segment_start_middle_end` | `SINGLE`, `START`, `MIDDLE`, `END` na jednym odcinku |
| F-04 | `rim_cap_east` | `TOP_RIM / NORTH / START` → `(5,1)` + misa `(4,1)` |
| F-05 | `rim_cap_west` | `TOP_RIM / NORTH / END` → `(0,1)` + misa `(1,1)` |
| F-06 | `facade_3h_straight` | `FACADE / SOUTH / 3 / MIDDLE`, `consumes_rim_row = true` |
| F-07 | `facade_2h_straight` | `FACADE / SOUTH / 2 / MIDDLE`, `consumes_rim_row = false` |
| F-08 | `facade_depth_5` | `solid_depth = 5` → `height = 3`, rim osobno nad koroną |
| F-09 | `out_corner_west_3h` | `OUT_CORNER / WEST / 3` |
| F-10 | `out_corner_east_3h` | `OUT_CORNER / EAST / 3` + **rozłączność ze `STEP`** (§9.3) |
| F-11 | `out_corner_west_2h` | `OUT_CORNER / WEST / 2` — zamraża zamierzony offset `row_offset = -1` (§6.5) |
| F-12 | `out_corner_east_2h` | `OUT_CORNER / EAST / 2` — jak F-11 |
| F-13 | `step_west_dy1` | `STEP / WEST / 3`, `step_dy = 1` → moduł roots dozwolony |
| F-14 | `step_west_dy3` | `STEP / WEST / 3`, `step_dy = 3` → moduł roots **zabroniony** (§9.6) |
| F-15 | `step_east_dy1` | `STEP / EAST / 3` |
| F-16 | `connector_2h_to_3h` | `CONNECTOR / EAST / 3` |
| F-17 | `connector_3h_to_2h` | `CONNECTOR / WEST / 2` |
| F-18 | `inner_corner_nw` | `INNER_CORNER / NORTH_WEST` → `(1,1)` |
| F-19 | `inner_corner_ne` | `INNER_CORNER / NORTH_EAST` → `(4,1)` |
| F-20 | `side_wall_east` | `SIDE_WALL / EAST` → `(5,2)/(5,3)` — **test pułapki nazewniczej §4.5** |
| F-21 | `side_wall_west` | `SIDE_WALL / WEST` → `(0,2)/(0,3)` |
| F-22 | `niche_pair` | `NICHE / WEST / START` + `NICHE / EAST / END`, rezerwacja pary |
| F-23 | `spike_removed_by_prepass` | pojedynczy ząbek — po pre-passie **nie istnieje** |
| F-24 | `staircase_kept_by_prepass` | poprawny schodek 2×2 — pre-pass go **zostawia** |
| F-25 | `portal_not_covered` | komórka portalu → `PORTAL_CLEAR`, priorytet `1000`, nic jej nie przykrywa |
| F-26 | `facade_1h_invalid` | `solid_depth == 1` → `push_error` + `FacadeHeight.INVALID` |

F-23, F-24 i F-26 są testami **pre-passów**, nie analizatora — trzymamy je w tym samym
zestawie, bo weryfikują niezmienniki, na które analizator się opiera.

### 16.3. Polecenia pomocnicze

```bash
# Kontrola składni (Etap 0+)
godot --headless --path . --script res://modules/quiz_rpg/tests/check_parse.gd

# Pełny zestaw testów (Etap 1+)
godot --headless --path . --script res://modules/quiz_rpg/tests/run_tests.gd

# Reguły izolacji (Etap 3+)
godot --headless --path . --script res://modules/quiz_rpg/tests/check_isolation.gd

# Sprawdzenie pojedynczego pliku bez runnera
godot --headless --path . --check-only --script res://modules/quiz_rpg/scripts/generation/cave_generator.gd

# Czy ktoś woła set_cell poza executorami?
grep -rn "set_cell\|erase_cell\|set_cells_terrain_connect" modules/quiz_rpg/scripts/generation/ \
  | grep -v "_executor.gd"

# Czy ktoś wpisał priorytet z palca?
grep -rn "priority = [0-9]" modules/quiz_rpg/scripts/generation/ \
  | grep -v "placement_priority.gd"

# Czy zostały literały atlasu poza profilami? (Etap 7+)
grep -rn "Vector2i([0-9]" modules/quiz_rpg/scripts/generation/ \
  | grep -v "profiles/" | grep -v "+ Vector2i"

# Stara implementacja filarów (Etap 10)
git show 0792c03:modules/quiz_rpg/scripts/generation/cave_generator.gd | sed -n '1653,1700p'

# Co dokładnie zepsuł commit 0956687
git diff 0792c03 0956687 -- modules/quiz_rpg/scripts/generation/cave_generator.gd
```

### 16.4. Stałe do przeniesienia 1:1 (kontrolna lista wartości)

Wartości, których **nie wolno zmienić** przy migracji do profilu. Każda z nich
wpływa na wygląd lub topologię.

```
# Topologia
border                          = 6
max_attempts                    = max(300, max_rooms * 25)
room padding                    = Rect2i(rx-5, ry-6, rw+10, rh+12)
extra_loops                     = min(3, rooms.size() / 3)
loop_attempts                   = 25
loop_distance_threshold         = max(width, height) * 0.45
corridor lobes                  = randi_range(3, 5)
lobe dist                       = randf_range(0.2, 0.6) * radius
lobe radius                     = randi_range(2, int(min(rx_rad, ry_rad) * 0.6))
corridor path_noise.frequency   = 0.04
corridor width_noise.frequency  = 0.08
corridor control points         = clamp(int(dist / 6.0), 3, 14)
corridor max_amplitude          = clamp(dist * 0.22, 3.0, 10.0)
corridor total_steps            = int(dist * 2.5)
corridor min_w / max_w          = max(2, width-1) / width+2
corridor funnel                 = pow(1.0 - sin(t*PI), 2.0) * 2.2

# Portale
ALCOVE_RADIUS                   = 2
ALCOVE_NORTH_EXTRA              = 0
MAP_BORDER                      = 2
MIN_TUNNEL_LENGTH               = 5
tunnel_length                   = min(randi_range(5, 7), max_length)
alcove_cells filter             = dy >= -ALCOVE_RADIUS + 1

# Pre-passy
_enforce_wall_thickness passes  = 4
_cleanup_grid_before_tiling     = 4
bulge_width threshold           = < 4

# Szumy
roots_theme_noise.seed          = rng.seed + 333
roots_theme_noise.frequency     = 0.08
roots threshold                 = > 0.14
theme portal uniform radius     = 4 (Chebyshev)
ab_noise.seed                   = rng.seed + 777
ab_noise.frequency              = 0.45
mud_noise.seed                  = rng.seed + 202
mud_noise.frequency             = 0.035
mud threshold                   = > -0.02
grass_noise.seed                = rng.seed
grass_noise.frequency           = 0.13
grass threshold                 = > 0.10
floor dilation                  = 5x5 (dy, dx in -2..2)

# Kafelkowanie
rock fill weights               = 45 / 47 / 8  → (2,2) / (2,3) / (3,2)
void fill range                 = -4 .. size+4
floor base tile                 = (10, 13)
terrain_set                     = 0
terrain Mud                     = 1
terrain Grass                   = 2

# Nisze
niche_spawn_chance              = 0.15
secret_niche_spawn_chance       = 0.30
OUT_NICHE_MIN_DISTANCE          = 10

# Tolerancje sąsiedztwa (trzy różne! §14 P3-4)
has_same_y                      = abs(fy - cy) <= 1
left_y / right_y                = abs(ly - y)  <= 4
FAZA 2.5                        = abs(fy - sy) <= 2

# Spawny
boss offset                     = center + (0, -2)
boss tier                       = 3
enemies per room                = randi_range(2, 4)
enemy offset                    = randi_range(-2, 2) w obu osiach
enemy tier                      = randi_range(1, 2)
room role                       = i % 2 == 1 ? wrogowie : skrzynia
```

### 16.5. Historia dokumentu

| Data | Zmiana |
|---|---|
| 2026-09-15 | Wersja 1. Analiza kodu na commicie `0956687` (+ lokalna naprawa P0-1). Weryfikacja: Godot 4.6 headless. Decyzje autora §6.1–6.4 zapisane. |
| 2026-09-15 | Wersja 1.1. Rozstrzygnięcia autora §6.5 (moduły 2H zamierzone), §6.6 (`PlatformCollisions` przez `Area2D`), §6.7 (miska rimu — dwie kategorie). P1-1, P1-4, P2-5 zamknięte. Lista świadomych zmian wyglądu w Etapie 5 skrócona z 3 do 2 pozycji, obie przekwalifikowane na zadania pomiarowe. |
| 2026-09-15 | Wersja 1.2. **Doktryna obiektowa §6.8**: siatka to wyłącznie ściany i podłogi, wszystko inne jest obiektem z osobnym generatorem. Etap 12 przepisany z „las jako topologia `noise_field`" na `ObjectGenerator`. Anulowano zalecenie dodawania `TREE`/`WATER`/`PATH` do `GridUtils.is_walkable()` (zadanie 2.3). Skorygowano RD-1 w sprawie `decoration/` (obiekty, nie kafle). Ustalono jedną sól `SALT_VARIANT_AB`. `caves_debug.json` na stałe w repo. Brak pytań blokujących. |

### 16.6. Pytania rozstrzygnięte

| Pytanie | Odpowiedź autora | Zapisane w |
|---|---|---|
| P2-5 — różnica masek kolizji gracza (`6`) i przeciwnika (`39`) | Zamierzone. `PlatformCollisions` będą docelowo obsługiwane przez `Area2D` rozciągnięty od przodu platformy do końca jej kolizji. | §6.6 |
| P1-1 — offset modułu narożnika OUT 2H | Zamierzone: *„jak działa to nie ruszaj, 2h są dobrze zrobione."* | §6.5 |
| P1-4 — priorytet miski rimu (rock vs roots) | Nazwa `RIM_BOWL` nie istniała w kodzie — nieporozumienie terminologiczne. Konflikt rozwiązany dwiema kategoriami, bez zmiany wyglądu. | §6.7 |
| Zakres refaktoru (jaskinia vs wszystko) | Wszystko ma bazować na jednym uniwersalnym rdzeniu; realizacja etapami A–D. | §6.4 |
| Priorytety placementu | Dwa presety, decyzja po porównaniu zrzutów. | §6.1 |
| Filary | Przywrócić w nowej architekturze, po parytecie wizualnym. | §6.2 |
| Losowość w kafelkowaniu | Hash pozycji; zmiana wyglądu zaakceptowana. | §6.3 |
| Sól wariantów A/B ścian bocznych | Jedna sól — ściany boczne dzielą wzór A/B z fasadami i rimami. | §8.8 |
| `CellType.TREE` / `WATER` w lesie | Las nie będzie przez tileset. Wszystko poza ścianami i podłogami to obiekt, z osobnym generatorem. Stary generator lasu określony jako bezużyteczny. | §6.8 |
| `caves_debug.json` w repo | Na stałe. | §11.5 |

### 16.7. Otwarte pytania do autora

**Brak pytań blokujących Etapy 0–11.** Wszystkie wcześniejsze zostały rozstrzygnięte
(§16.6). Implementacja może startować od Etapu 0.

Dwie rzeczy do rozstrzygnięcia dopiero przy odpowiednim etapie:

1. **Etap 6, interpretacja odpowiedzi o soli.** Odpowiedź „tak" na pytanie
   alternatywne odczytałem jako **jedna sól** `SALT_VARIANT_AB` (czyli ściany boczne
   dzielą wzór A/B z fasadami i rimami — wariant domyślny w planie).
   Jeśli chodziło o przeciwnie (zachować dzisiejszą niezależność wzorów), to zmiana
   jednej linii w `SideWallPlacer`. Do potwierdzenia na zrzutach Etapu 6.
2. **Etap 12** — czy `CellType.ENTRANCE` / `EXIT` mają zostać w siatce jako podtypy
   podłogi, czy przenieść się w całości do `entrance_zone` / `exit_zone`
   (które już istnieją)? Dziś są w obu miejscach naraz, co jest redundancją.
   Nie blokuje niczego przed Etapem 12.
