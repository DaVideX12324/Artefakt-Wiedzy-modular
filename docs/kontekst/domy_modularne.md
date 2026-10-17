# Domy modułowe (Pixel Crawler Free Pack) — stan 2026-10-17

Narzędzie: `modules/quiz_rpg/tools/house_builder.py` (Python: Pillow, numpy, scipy). Składa z `Walls`, `Roofs`, `Props` PNG korpusu i dachu oraz scenę
`scenes/objects/buildings/<preset>.tscn` (korzeń `StaticBody2D`: kolizja podstawy, `DoorArea` + `DoorSpot` przy drzwiach; `Body` i `Roof` to dwa `Sprite2D`
w jednym punkcie, więc dach można ukryć osobno). Teksturę trzyma `assets/textures/buildings/`. Presety: `chata_mala`, `chata_duza`, `chata_zielona`.

- **Dach modułowy:** płaty dwuspadowego dachu poszerzane powielaniem środkowego wycinka 16 px z przesunięciem o nachylenie (jak u autora).
- **Ściana:** wiersze bali między słupkami, przycięta do obrysu dachu; okap (`eave`) ma sięgać górnej krawędzi drzwi (user: dachy wyżej / ściany wyższe).
- **Cień pod dachem:** dwa pasma (ciemne 8 px + jaśniejsze 6 px) pod dolną krawędzią płatów (user: efekt głębi).
- **Wzór:** zrzuty z oficjalnego Discorda autora paczki (domy z logów, tynk z cokołem, zielony dach z wieżą) — nie ma ich w żadnej paczce, którą mamy; składamy z elementów Free Packa.
- **Do zrobienia:** wersja tynkowana z cokołem, dach „bokiem” (prostokątny płat z okapem), dach płaski A, lukarna, komin, dobudówka, więcej wariantów okien/drzwi, wnętrza (osobno, później), logika wejścia i ukrywanie dachu w grze.

## Osada: przepisanie obiektów z Desert Town (2026-10-17, wersja robocza)

`town.tscn` (poza terenem i klifami z wcześniejszego przepisania) ma teraz węzły `Buildings` (7 chat z `house_builder`), `Trees` (166; palmy Desert Town ->
drzewa PC: Red = pomarańczowe liściaste, Dark/Emerald = iglaste, Light = sosny, Yellow = żółte), `Rocks` (37), `Bushes` (33; kaktusy -> krzaki) i `Spawns`
(`Spawn`, `Cave-Town` na południu, `Sewer-Town` na północy). Pozycje = globalne pozycje z `desert_town.tscn` (ten sam układ komórek). Domy -> preset wg
szerokości podstawy (86–150 px -> mała/zielona, ~166 px -> duża); stawiane środkiem dolnej krawędzi polygonu kolizji oryginału.
Nie przepisane: wieża, studnia, stragany, skrzynie, beczki, wazony, lampy, banery, ruiny, szkielety, płoty, NPC z oryginału, wyjście `enter_desert_oasis`,
logika wejść do budynków i przejść między poziomami (spawny to same znaczniki). Skrypt przepisania leży poza repo (scratchpad sesji).

**Podłoga osady (2026-10-17):** warstwy `Ground` (ziemia, pełne kafle `Floors_Full` (4,14)/(5,14) zamiast piasku), `Grass` (nakładka trawy) i `Path` (kamień)
z przejściami blob-47 wg tabeli `szablon_terenu_47_ze_zrzutu_16px.txt` (lewa połowa arkusza; bloki: trawa wiersze 0–4, kamień 5–9, ziemia 10–14, źródło 22).
ODWRÓCONE na prośbę usera: ziemia (podłoże) widoczna tylko tam, gdzie w Desert Town była trawa (1208 komórek) + ~220 komórek małych plam; reszta (dawny piasek) = trawa. Ścieżki = dawne `Path`. Skrypt poza repo (scratchpad sesji); wariant flat = kolumny +12.

## Warianty domów i domy z kafli (2026-10-17)

- **Chaty z PNG (`house_builder.py`):** 9 presetów (`chata_mala/duza/zielona`, `chata_zielona_mala/duza`, `chata_brazowa_prawa`, `chata_wysoka`, `chata_wysoka_zielona`, `dom_dlugi`; parametr `door: "right"`, `eave` 56/64/72) + 5 złożonych (`COMPOSITES`: `dom_l_prawy`, `dom_l_lewy`, `dom_szeregowy`, `dom_t`, `dom_schodkowy` — bryły obok siebie, cofnięte o `up` px, jeden `Body` + `Roof`, kolizja per bryła). Ponowne uruchomienie nadpisuje sceny.
- **Dom z kafli zbudowany ręcznie przez usera (lepszy od PNG):** `scenes/objects/buildings/dom_l_lewy.tscn` — sześć `TileMapLayer` (źródło 5 = Walls, 6 = Roofs, 7 = Props z `pixel_crawler_free.tres`), dach ze skosem co 2 kolumny kafli, komin, lukarna, schodek, dobudówka. Dodałem korzeń `StaticBody2D` (warstwa 32), warstwy przesunięte o (336, 96) tak, że origin = środek drzwi na dolnej krawędzi ściany, kolizje (główna 128×16, dobudówka 64×16 w (-96, -40)), `DoorArea`, `DoorSpot`.
- **`tools/house_tile_variants.py`:** z `dom_l_lewy` robi `dom_l_lewy_zielony`, `dom_l_lewy_bez_komina`, `dom_l_prawy`, `dom_l_prawy_zielony`, `dom_l_prawy_bez_komina` (odbicie x -> -43 - x + FLIP_H; zielony dach = kafle Roofs +8 kolumn atlasu; bez komina = usunięta warstwa `TileMapLayer5` z dzieckiem). Odbite dachy mają odwrócone światło. Nadpisuje te sceny.
- **Poszerzanie / inne kształty z kafli:** niezrobione — okna i drzwi leżą w kolumnach ściany, dach schodkuje co 2 kolumny, więc wymaga ręcznego rozcięcia; do zrobienia z userem.
- Moich 9 chat z PNG osada (`town.tscn`) nadal używa; podmiana na domy z kafli czeka na decyzję usera.
- `tests/render_scene.gd` (lokalny, gitignored): render dowolnej sceny do PNG (`SCENE_PATH`, `SCENE_OUT`, `SCENE_SCALE`, origin w (450, 560)).
- 7 zrzutów wzorów od usera odzyskane z transkryptu sesji do `scratchpad/ref_dom_1..7.png` (jedno zestawienie: `wzory_domow.png`).

## Generator domów z kafli `tools/house_tiles.py` (2026-10-17)

Nowe domy zbudowane od zera z kafli (a nie przekopiowane z `dom_l_lewy`): `dom_k_chata_8`, `dom_k_chata_12`, `dom_k_dluga_16`, `dom_k_deski_12`, `dom_k_pionowe_8`, `dom_k_tynk_12`, `dom_k_wysoki_8`.
Parametry (`HOUSES`): `n` (pary płata, szerokość ściany W = 4 + 4n kolumn), `d` (głębokość dachu), `e` (wysokość ściany pod okapem, 6 = bazowa), `kit` (0 kłody, 1 deski poziome, 2 deski pionowe, 3 tynk), `teal`, `chimney`.
Odkryte reguły (też w docstringu): dach A = próbka 8x6 kafli Roofs, szerokość przez powielanie par kolumn (każda para o wiersz niżej), głębokość przez powielanie wiersza 3; ściany = pasy 1x3 kafle (`size_in_atlas` + `texture_origin`, kotwica w dolnym wierszu pasa): dolny (x,8), wyższe (x,12), kit = +6 kolumn; cień pod ścianą (x,49); drzwi = rama Props (2..3,1..4) + skrzydło (8..9,1..3), okna łukowe (6..7,4..5), okna szczytowe (8..9,6..7), komin Props (0..1,4..7) + dwa kafle dachu nad nim.
Origin sceny = środek drzwi na dolnej krawędzi ściany. Dachy/ściany po stronie ridge są symetryczne. Brak: dach „bokiem” (Roofs 2..5 x 10..12), lukarna (Roofs 3..4 x 13..14), dobudówki, drzwi poza środkiem. Ponowne uruchomienie nadpisuje te sceny.
