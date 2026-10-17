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
Trawa = dawne komórki trawy `Ground`; ścieżki = dawne `Path`. Skrypt poza repo (scratchpad sesji); wariant flat = kolumny +12.
