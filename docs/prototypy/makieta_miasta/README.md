# Makieta miasta (maska + konwersja Desert Town) — narzędzia pomocnicze

Stan (2026-10-17): **prototyp / narzędzia robocze**, katalog `docs/prototypy/` ma `.gdignore`, więc Godot tego nie wczytuje.
Kontekst decyzji: [`../../zakres_inzynierka.md`](../../zakres_inzynierka.md) (sekcja „Miasto”).

Skrypty Pythona (wymagają `pip install pillow numpy`). Wyniki zapisują do bieżącego folderu.

## Generator makiety miasta

`generator_miasto.py [seed] [liczba_domów]` — maska miasta 288×216 kafli (1 kafel = 16 px, 4608×3456 px), bez tekstur:
nieregularne mury z wieżami i czterema bramami (zamkniętymi barierą), tarasy 0–3 przez miasto (skośne grzbiety, wzgórze biblioteki),
rzeka w najniższym pasie doliny, rynek z niecką, sieć dróg (A* + wygładzenie) ze schodami i mostami, domy tylko wewnątrz murów,
dok ze ścieków, jaskinia (start) przy murze, stacje przy rzece. Wyjścia: `miasto_maska_1px.png`, `miasto_wysokosc_1px.png`,
`miasto_podglad_x5.png` (z legendą), `miasto_szkic_gray_x3.png`, `legenda.json` (z parametrami), `kategorie.csv`, `wysokosc.csv`.

Wariant z gotowych plików obok: **seed 7, 17 wierzchołków murów, 103 domy** (`python3 generator_miasto.py 7 110`).
Parametry wariantu są zapisane w `legenda.json` (`parametry`) i w kodzie (`NV = 17`, promień 0,72–1,0, załamania 0,18 z promieniem 0,60–0,72,
wygładzenie 0,6 / 0,2 / 0,2). Wariant z ostrzejszymi załamaniami: `NV = 13`, promień 0,70–1,0, załamania 0,30 z promieniem 0,58–0,70,
wygładzenie 0,85 / 0,075 / 0,075 (83 domy).

Gotowe renderery w tym katalogu: `miasto_maska_16px.png`, `miasto_wysokosc_16px.png` (1 kafel = 16×16 px), `miasto_podglad_x5.png`.

## Konwersja Desert Town (TMX) na atlasy Pixel Crawler

Źródłowy `Desert_Town.tmx` (cudza paczka Desert Oasis) **nie jest w repo**. Tilesety `.tsx` z TMX nie były dostępne, więc układ
odczytano z identyfikatorów kafli i nazw warstw.

- `desert_town_parse.py` — wczytuje TMX (ścieżka wpisana na stałe, do zmiany), zapisuje `layers.npy` i `objs.json`.
- `ldtk_rules.py` — wylicza reguły autotile LDtk (zweryfikowane na wymalowanym fragmencie `town.ldtk`: 0 różnic w trafionych regułach;
  różni się tylko losowy wybór wariantów kafli).
- `desert_town_na_pixel_crawler_tmx.py` — buduje TMX z **oryginalnymi 13 warstwami** (Sand, Ground, Road, Shadow, Wall, RockSlopes2,
  RockSlopes2_Auto, Rock slopes manual, Fence back, Object Layer 2, Tall Grass, Object Layer 1, Fence Front) i atlasami Pixel Crawler
  (`Floors_Full`, `Wall_Tiles`, `Vegetation`, drzewa jako kolekcja obrazków). Ścieżki do atlasów w TMX są względne od
  `modules/quiz_rpg/scenes/maps/levels/`.

Wnioski z konwersji:
- `RockSlopes2` to markery poziomów (prawdopodobnie do AutoMappingu Tiled), a nie wysokości w sensie wprost.
- Sprite'y drzew Pixel Crawler (96–512 px wysokości) są wielokrotnie większe niż drzewa z Desert Town (ok. 63 px), więc trzeba je skalować.
- `Wall_Tiles` to stemple, a nie autotile — patrz „Klify” w `zakres_inzynierka.md`.
