# Ścieki (sewer) — stan na 2026-10-04

Gałąź **`sewer-tileset`** w submodule CienMgly (`modules/quiz_rpg`), wypchnięta, **jeszcze nie na `main`**
(czeka na review / akceptację autora). `main` CienMgly ma z tej serii tylko: opcje walki (pytanie w logu /
w menu walki, odpowiedzi lista / siatka, okno quizu na szerokość treści) i poprawkę spawnów (osobne kratki).
W hoście niezacommitowane: `assets/pixel_crawler/environments/sewer/Assets/Tiles.png` (4 narożniki kanału,
kopia w `_host/` już na gałęzi). Lokalnie u autora niezacommitowany rozmiar panelu w
`scenes/tools/map_generator_preview.tscn` — nie ruszać. Scenę testową `procedural_level.tscn` autor
malował ręcznie — przed merge cofnąć jego zmiany w niej (jeśli jeszcze są).

## Pliki
- `resources/maps/sewer.tres` — TileSet (UID `c73m68vj3lqr3`), źródło 0 = `sewer/Assets/Tiles.png`, źródło 1 =
  `Props.png` (kładki). Tereny autora: `floor` (0), `void`, `dark_floor`, `foliage` (mech), `ridges`.
  Kolizje ścian / obrzeży kanału dopisywane wprost w tekście pliku (autor edytuje go w edytorze — nie
  przepisywać ResourceSaverem; builder robi to tylko z `BUILD_TILESET=1`).
- `resources/maps/profile/sewer_map_tiles.tres` — profil Named TileSet (`sewer`), budowany przez
  `tests/build_sewer_resources.gd` (tests/ poza gitem). Moduły lica z przesunięciem -1 (`FS`).
- `resources/maps/config/sewer.json` — flagi (niżej). Eksplorator map: pozycja „Ścieki” (F4).
- Atlas z rolami (obrazek): scratchpad sesji `atlas_sewer_z_modulami.png`, skrypt `atlas_sewer.py` (do odtworzenia).

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
- Moduł 6,3–6,5 = zacienione lico w szczelinie filar–ściana (nieużyty). `Social/exc.aseprite` to reklama
  płatnego „Extended” — nie brać z niej kafli. `.aseprite` rozkładamy własnym parserem Pythona.

## Flagi generatora dodane w tej serii (domyślnie wyłączone — parytet jaskini 42/42)
- Układ: `room_shape: poly` (L / T / plus), `room_density`, `room_layout: random|grid` (+ `grid_cell_size`,
  `grid_room_chance`, `grid_loop_chance`), `corridor_shape: straight` (L) + `corridor_diagonal_45`,
  `corridor_diagonal_30_60`, `corridor_corner_room_chance`.
- Ściany: `enforce_3h_walls` (Wall3HPass), `align_wall_tops` (WallTopAlignPass), `enable_4h_facades` +
  `facade_4h_chance` (całe odcinki lica), `facade_base_on_wall` (lico na kratkach ściany).
- Podłoga: `floor_terrain`, `floor_area: near|walkable|all`, `floor_edges_by_walkable`, `terrain_mud_index`,
  `terrain_grass_index`.
- Kanały: `canal_count`, `canal_min_length`, `canal_bridge_spacing`.
- Ścieki używają: poly, gęstość 0.6, pokoje 16–28, korytarz 8, L bez skosów, pokoje na zakrętach 0.3, bez
  wygładzania styków, wejście center, 4H 35%, lico na ścianie, podłoga all + brzegi z maski, kanały 3.

## Kanały (w toku)
- `topology/canal_pass.gd` → `core/canal_layout.gd` (water, bridges, bridge_cells, blocked); grid zostaje
  FLOOR. Oś kanału wybierana spośród najdłuższych odcinków (TOP_CHOICES), kładki co `canal_bridge_spacing`,
  dokładanie kładek / usuwanie kanału do spójności z wejściem.
- Konsumenci `canals.blocked`: nawigacja (NavOutlines), spawny, obiekty (kładki = FORBID), arrival_cell;
  podłoga / teren pomijają water.
- `tiling/canal_placer.gd`: kwas + lico na Floor, obrzeża + kładki na FloorDecor (kolizja tylko obrzeży i boków
  kładek — kwas bez kolizji, decyzja autora). FloorDecor wykonywany po terenie (cave_generator + procedural_level).
- Zrobione i zweryfikowane renderem (seedy 119 / 7 / 42, 200×200); wrogowie nie wpadają do kanału (diag).
  Zacommitowane na `sewer-tileset` (ec6745f generator, f2096be ścieki), parytet jaskini 42/42.
  Zostało: test w grze (kolizje obrzeży, chodzenie po kładce, wrogowie przy kanale).
- Do decyzji / dalej: skrzyżowania kanałów (+, T) mało przetestowane, kładki bywają parami (dokładane dla
  spójności), mech (teren foliage), filary w licu, barierki (Props 5–9 × 4).

## Obiekty
- Katalog `objects_sewer.json` (włączony w `sewer.json`): skrzynie (alias `chest`), stół + krzesła
  (towarzysze), skrzynki / beczki przy ścianach (skupiska), wraki, bloki miedzi, kratki ściekowe 2×2–4×4
  (DECAL na całej podstawie), otwory w posadzce, drobnica, butelki / kubki; na licu (`mount: facade`):
  lampy, okrągłe kratki, przełączniki, łuki odpływów. Opis mechanizmu: `kontekst/obiekty.md`.
- Nieużyte z atlasu: regał / schody (Props 0–1 × 6–8 — wygląda na wyjście, może grafika portalu),
  skrzynia ścieków (8–9 × 0–3), barierki (6–9 × 4), łańcuch (10, 0–2), filar (Tiles 7, 3–6), rury.

## Testy lokalne (tests/, poza gitem)
`render_sewer.gd` (RS_SEEDS / RS_SIZES / RS_FLAGS / RS_LAYOUT / RS_TAG), `diag_wall_steps.gd` (uskoki),
`diag_spawn_cells.gd`, `diag_enemy_drift.gd` (wrogowie poza podłogą w eksploratorze), `shot_preview_sewer.gd`,
`shot_question_position.gd`, `build_sewer_resources.gd`. Wzorzec parytetu zaktualizowany po poprawce spawnów.
