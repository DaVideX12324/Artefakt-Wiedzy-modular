# Plan: zapis gotowych map na dysk (wczytanie zapisu / powrót bez generowania)

> Status 2026-10-16: **plan, nie zaczęte.** Decyzja usera: „na razie MD / plan”. Uzupełnia mapy z wyprzedzeniem
> (`scripts/maps/map_prefetch.gd`, zrobione) — te liczą w tle mapy, na których gracz jeszcze nie był; zapis na dysk
> obsłuży wczytanie zapisu i powroty po restarcie gry.

## Pomiar (2026-10-16, `tests/diag_map_save_size.gd`, seed 119)

Zapis = `tile_map_data` wszystkich TileMapLayer + siatka (bajty) + obiekty (id, kratka, wariant) + spawny + nawigacja.

| Mapa | surowo | zstd |
|---|---:|---:|
| jaskinia 160² | 575 KB | ~100 KB |
| ścieki 160² (rozmiar w grze) | 681 KB | ~97 KB |
| ścieki 250² | 1,6 MB | ~230 KB |
| ścieki 500² | 6,5 MB | ~840 KB |

~90 % to kafle. Kompresja / dekompresja 1–12 ms. Szacowane wejście z dysku ~0,3 s (zostają encje, obiekty,
nawigacja — jak przy mapie z wyprzedzeniem) zamiast ~2,4 s (headless) / ~6 s (laptop usera).

## Co zapisać

Plik `user://maps/<world_seed>/<nazwa_sceny>.map` (FileAccess, `var_to_bytes` + zstd), zawartość:
- `version` — znacznik wersji (niżej), `key` = MapPrefetch.key_of (poziom, seed, rozmiar);
- `tiles`: {nazwa warstwy: tile_map_data} — po `_apply_job_async` (paint + teren + obiekty-kafle Props / Decals / …);
- lekki wynik (`GenerationResult`), tylko pola używane po generowaniu. **Audyt konsumentów do zrobienia najpierw**
  (grep `last_result`, `job.result`, `result.` w `procedural_level.gd`, `map_generator_base.gd`
  (`spawn_entities`, `setup_navigation_region`), `ObjectRealizer`, `height_veil.gd`, `gate_nav.gd`, `grid_sight.gd`,
  `enemy_base.gd`, portale / drabiny). Pewne: `grid` (raster bajtów), `width/height/seed_used`, `entrance_pos`,
  `exit_pos`, `enemy_spawns`, `chest_spawns`, `portal_ladders`, `portal_stairs`, `portal_zone`, `nav_excluded`,
  `nav_chunk_keys`, `nav_polygons` (wierzchołki + wielokąty), `objects` (placements: id definicji z katalogu,
  kratka, wariant — definicje z `ObjectCatalog` przy odczycie). Do sprawdzenia: `plateau` (zasłona wysokości?),
  `canals`, `terrain_masks`, `rooms`.
- Bez `plans` (kafle już w `tiles`) i bez obiektów pomocniczych generatora.

## Przepływ

1. **Zapis:** po `generation_finished` (ścieżka gry, `_prefetch_allowed()`), w wątku roboczym: serializacja +
   kompresja, zapis do `*.tmp`, potem `DirAccess.rename` (przerwany zapis nie psuje pliku).
2. **Odczyt:** `generate_level_async` — kolejność: plik na dysku (zgodny klucz i wersja) > MapPrefetch > generowanie.
   Z pliku: warstwy przez `tile_map_data`, wynik do `last_result`, dalej `_finish_level` jak dziś (encje, obiekty,
   nawigacja, stan poziomu z LevelStateManagera — skrzynie / beczki / bramy jak teraz).
3. Plik uszkodzony / niezgodny → generowanie od nowa (i nadpisanie pliku).
4. Mapy z wyprzedzeniem też mogą zapisywać plik po policzeniu (wtedy po restarcie gry sąsiednie mapy są gotowe).

## Ryzyka i zabezpieczenia

1. **Zmiana tilesetu / atlasu po aktualizacji gry** — w pliku są numery kafli; stary plik pokazałby złe kafle.
   Znacznik `version` = stała `MAP_CACHE_VERSION` (podbijana ręcznie przy zmianach generatora / kafli) + hash
   companion-JSON poziomu + `resource_path` i data modyfikacji tilesetu. Niezgodność → generowanie od nowa.
2. **Praca nad generatorem** (user / ja) — zapis ukrywałby zmiany. W buildzie debug do znacznika dochodzi
   najnowsza data modyfikacji skryptów `scripts/generation/**` (skan raz na sesję) albo zapis wyłączony
   (przełącznik w dev menu / JSON `debug`).
3. **Pominięte pole wyniku** — cichy błąd (np. zasłona płaskowyżów, przebudowa nawigacji po otwarciu bramy, widoczność
   wrogów). Zabezpieczenie: audyt (wyżej) + test porównujący mapę z pliku i świeżą: te same warstwy, encje
   (pozycje, typy), obiekty (węzły Props), nawigacja (liczba wielokątów), zasłona wysokości.
4. **Nowy seed zapisu** (`reroll_world_seed`) i **usunięcie slotu** — kasować `user://maps/<stary_seed>/`
   (o ile żaden inny slot nie ma tego seeda). Plus `MapPrefetch.clear()` (już jest).
5. **Stan poziomu** (otwarte skrzynie, zniszczone beczki, bramy, bossowie) zostaje w LevelStateManagerze jak dziś —
   plik mapy jest tylko układem. Plus: układ nie zmienia się już po aktualizacji generatora (dziś zmiana generatora
   przestawia mapy w istniejących zapisach, a stan jest po pozycjach), dopóki nie zmieni się `version`.
6. **Miejsce:** ~100 KB na mapę 160²; sprzątanie folderów seedów bez slotu przy starcie gry.

## Kroki (szacunek: 1 sesja)

1. Audyt konsumentów wyniku → lista pól (dopisać tutaj).
2. `scripts/maps/map_disk_cache.gd`: `save(level, job_key, version)` w wątku, `load(job_key, version) -> {tiles, result}`,
   `clear_seed(seed)`; serializacja wyniku (raster siatki, obiekty po id, NavigationPolygon z wierzchołków i wielokątów).
3. `procedural_level.gd`: odczyt przed MapPrefetch, zapis po `generation_finished`; ścieżka z pliku omija job.run i paint.
4. Reroll / usunięcie slotu → `clear_seed`.
5. Test `tests/check_map_disk_cache.gd`: zapis → nowy poziom z pliku → porównanie jak w punkcie 3 ryzyk; uszkodzony
   plik → generowanie; zmiana `version` → generowanie. Test nie dotyka ustawień usera; pliki w osobnym folderze testu.
6. Docs + pamięć.
