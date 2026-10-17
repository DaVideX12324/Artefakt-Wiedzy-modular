# Domy modułowe (Pixel Crawler Free Pack) — stan 2026-10-17

Narzędzie: `modules/quiz_rpg/tools/house_builder.py` (Python: Pillow, numpy, scipy). Składa z `Walls`, `Roofs`, `Props` PNG korpusu i dachu oraz scenę
`scenes/objects/buildings/<preset>.tscn` (korzeń `StaticBody2D`: kolizja podstawy, `DoorArea` + `DoorSpot` przy drzwiach; `Body` i `Roof` to dwa `Sprite2D`
w jednym punkcie, więc dach można ukryć osobno). Teksturę trzyma `assets/textures/buildings/`. Presety: `chata_mala`, `chata_duza`, `chata_zielona`.

- **Dach modułowy:** płaty dwuspadowego dachu poszerzane powielaniem środkowego wycinka 16 px z przesunięciem o nachylenie (jak u autora).
- **Ściana:** wiersze bali między słupkami, przycięta do obrysu dachu; okap (`eave`) ma sięgać górnej krawędzi drzwi (user: dachy wyżej / ściany wyższe).
- **Cień pod dachem:** dwa pasma (ciemne 8 px + jaśniejsze 6 px) pod dolną krawędzią płatów (user: efekt głębi).
- **Wzór:** zrzuty z oficjalnego Discorda autora paczki (domy z logów, tynk z cokołem, zielony dach z wieżą) — nie ma ich w żadnej paczce, którą mamy; składamy z elementów Free Packa.
- **Do zrobienia:** wersja tynkowana z cokołem, dach „bokiem” (prostokątny płat z okapem), dach płaski A, lukarna, komin, dobudówka, więcej wariantów okien/drzwi, wnętrza (osobno, później), logika wejścia i ukrywanie dachu w grze.
