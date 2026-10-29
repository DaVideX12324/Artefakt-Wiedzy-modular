# Plan: zapis gotowych map na dysk (wczytanie zapisu / powrót bez generowania)

> Status 2026-10-17: **ZROBIONE (jaskinie i ścieki, `scripts/maps/map_disk_cache.gd`)** — opis „Jak działa” na końcu pliku. Wcześniej (2026-10-16): plan. Uzupełnia mapy z wyprzedzeniem
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

## Jak działa (2026-10-17)

- `MapDiskCache` (`scripts/maps/map_disk_cache.gd`): `user://maps/<seed zapisu>/<mapa>.map` = nagłówek (magic, rozmiar,
  MD5 treści) + zstd(`var_to_bytes`) słownika {v, sig, tiles, r}. Uszkodzony plik wykrywa MD5 (sama kompresja przepuszczała
  zmienione bajty), niezgodny podpis = brak trafienia.
- **Co zapisuje:** `tile_map_data` ośmiu warstw malowanych przez generator (Floor, FloorDecor, Curbs, Bridges, Walls, Rails,
  Platforms, PortalShade) **zaraz po malowaniu** — encje, obiekty (Decals / Props / sceny), nawigacja i wyjścia liczą się po
  wczytaniu jak zawsze — oraz lekki `GenerationResult`: siatka (bajty), pokoje, spawny, drzwi, wejście / wyjście, schody
  i drabiny portali, nawigacja (wielokąty po kawałkach), `nav_excluded`, kanały (`cells`, `blocked`, kładki, barierki,
  korytarze-schody), płaskowyże (`mask`, `blocked`, `min_level`), plan obiektów (miejsca z id definicji, `occupancy`;
  definicje syntetyczne bram zapisane polami).
- **Podpis:** wersja `MAP_CACHE_VERSION` + klucz (poziom, seed, rozmiar) + data i rozmiar companion-JSON, katalogu obiektów
  i tilesetu; w buildzie debug także najnowsza data skryptów `scripts/generation`. Po zmianie generatora w wydaniu podbić
  `MAP_CACHE_VERSION`.
- **Przepływ:** `ProceduralLevel.generate_level_async`: plik (zgodny podpis) > MapPrefetch > generowanie. Tylko w grze
  (`_prefetch_allowed()`, jaskinie i ścieki). Migawka kodowana na głównym wątku podczas ekranu ładowania (wynik nie jest
  jeszcze zmieniany), kompresja i zapis w wątku roboczym (`*.tmp` + rename).
- **Sprzątanie:** raz na sesję zostaje 6 ostatnio zmienianych folderów seedów (nowa gra / reroll tworzą nowy seed; stare
  foldery wypadają same). Wyłączenie: `ProjectSettings` `quiz_rpg/map_disk_cache = false` albo cecha `no_map_cache`.
- **Pomiar (ścieki / jaskinia 160², headless):** wejście świeże ~2,0–2,5 s, z pliku ~0,24 s; plik ~110 KB.
- **Test:** `tests/check_map_disk_cache.gd` (env `MC_SCENE`, `MC_SEED`): warstwy kafli identyczne, rodzaje wrogów, skrzynie,
  obiekty, nawigacja, wejście / wyjście, drzewo węzłów; uszkodzony plik; inny podpis. Pozycje wrogów są losowe także przy
  świeżym generowaniu, więc nie są porównywane.
- **Zapis map z wyprzedzeniem (2026-10-22):** po policzeniu danych w tle `MapPrefetch` trzyma poziom poza drzewem, a ten (`ProceduralLevel.save_prefetched_async`) maluje kafle z planu w trakcie gry po 2 ms na klatkę (`FrameSlicer` ze stałym budżetem), robi migawkę i zapisuje plik — po restarcie gry sąsiednie mapy wczytują się z pliku. Malowanie bez losowania, więc plik = świeże wejście (test). Gdy wejście weźmie dane wcześniej, tło nie zapisuje (wynik zmienia już gra; wejście zapisuje samo). Koszt w grze: jedna klatka ~+14 ms (podpis; skan skryptów generatora tylko w buildzie debug, raz na sesję), reszta ≤ ~8 ms. Plik po zapisie w tle: wejście ~0,24 s zamiast ~2 s.
- **Unieważnianie (2026-10-22):** usunięcie slotu (`SaveManager.delete_save_slot`) i reroll świata kasują `user://maps/<seed>/`, o ile seeda nie ma żaden inny slot (`SaveManager.used_world_seeds`) ani bieżąca gra (`MapDiskCache.clear_seed_if_unused`). Dalej działa sprzątanie do 6 folderów.
- **Test:** `tests/check_map_prefetch_save.gd` (plik z tła bez wejścia, identyczny z świeżym; wejście w trakcie tła; seed bez slotu). Pomiar klatek: `tests/diag_prefetch_frames.gd` (DPF_SAVE=0/1).
- **Zostało:** podbijanie `MAP_CACHE_VERSION` przy wydaniu ze zmianą generatora. Klatka ~0,5 s przy starcie mapy z wyprzedzeniem naprawiona 2026-10-22: to było wczytywanie scen wrogów w `_prepare_job` (~425 ms) — `MapPrefetch._prepare` czeka teraz, aż `warm_enemy_scenes` wczyta je w tle (`ProceduralLevel.enemy_scenes_ready`), a pliki .tres z companion-JSON (tabele łupu) wczytuje w wątkach przed `_prepare_job`. Najdłuższa klatka 480 → ~36 ms.

