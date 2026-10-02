# Edytor pól walki (Battle Layout Preview) — instrukcja

Scena `modules/quiz_rpg/scenes/tools/battle_layout_preview.tscn` — graficzne ustawianie, **gdzie na tle
walki stoją wrogowie**. To, co widać w podglądzie, liczą te same funkcje co walka w grze
(`BattleBackgroundLayout`), przy ekranie 1920×1080 z dolnym paskiem UI 250 px.

## Spis treści
1. [Jak to działa w grze](#1-jak-to-działa-w-grze)
2. [Szybki start](#2-szybki-start)
3. [Nowe tło — tworzenie pliku układu](#3-nowe-tło--tworzenie-pliku-układu)
4. [Edycja pól myszą](#4-edycja-pól-myszą)
5. [Ustawienia pola (inspektor)](#5-ustawienia-pola-inspektor)
6. [Ustawienia podglądu (inspektor sceny)](#6-ustawienia-podglądu-inspektor-sceny)
7. [Jak liczone są miejsca i skala wrogów](#7-jak-liczone-są-miejsca-i-skala-wrogów)
8. [Przykłady](#8-przykłady)
9. [Problemy i pułapki](#9-problemy-i-pułapki)
10. [Pliki](#10-pliki)

---

## 1. Jak to działa w grze

- Każda grafika tła walki może mieć obok siebie plik **układu**: `<nazwa grafiki>_layout.tres`
  (np. `variant_2_training.jpg` → `variant_2_training_layout.tres`).
- Plik układu zawiera listę **pól walki** (podłoga, platforma, półka…). Każde pole to czworobok —
  zwykle trapez, żeby był efekt głębi — z jednym do trzech **rzędów** wrogów.
- Na początku walki gra losuje dla każdego wroga rząd z wolnym miejscem (na wszystkich polach naraz)
  i ustawia go na linii tego rzędu. Dalsze rzędy mogą automatycznie zmniejszać wrogów.
- Brak pliku układu = jedno pole domyślne (trapez na środku, 2 rzędy po 5 miejsc).
- Tła rysowane w kodzie też mają pliki układu:
  `battle_backgrounds/default_layout.tres` i `battle_backgrounds/world_map_layout.tres`.

## 2. Szybki start

1. Otwórz w edytorze `scenes/tools/battle_layout_preview.tscn`.
2. Zaznacz główny węzeł **BattleLayoutPreview**.
3. W inspektorze przeciągnij plik `<grafika>_layout.tres` do pola **layout**.
   Pojawi się tło, ciemny dolny pasek UI, obrysy pól i przykładowi wrogowie.
4. Zaznacz w drzewie sceny węzeł **Field1** i przeciągaj jego narożniki w widoku 2D.
5. Puść mysz — po ok. 0,6 s plik układu zapisuje się sam.
6. Rzędy, pojemność i skale ustawiasz w inspektorze **pliku układu** (patrz [rozdział 5](#5-ustawienia-pola-inspektor)).

> Węzły `Field…` są tylko uchwytami do edycji — przy otwarciu sceny i zmianie pliku układu budują się
> od nowa z pliku. Wszystko, co ważne, ląduje w pliku układu; zapisywanie samej sceny podglądu nie jest
> potrzebne (chyba że chcesz, żeby zapamiętała wybrany `layout` / grafiki).

## 3. Nowe tło — tworzenie pliku układu

1. W panelu FileSystem kliknij prawym na folder z grafiką tła → **Create New → Resource…**
2. Wybierz typ **BattleBackgroundLayout**.
3. Zapisz jako `<dokładna nazwa grafiki bez rozszerzenia>_layout.tres` w **tym samym folderze**
   (inaczej gra go nie znajdzie).
4. W inspektorze nowego pliku przeciągnij grafikę tła do **texture** (to tylko dla podglądu —
   w grze tło wybiera generator).
5. Przeciągnij plik do **layout** w podglądzie. Pusta lista pól pokazuje pole domyślne; żeby mieć
   własne, w inspektorze pliku dodaj element do **fields** (New BattleField) — pojawi się `Field1`.

## 4. Edycja pól myszą

| Czynność | Jak |
|---|---|
| Przesunięcie narożnika | zaznacz `FieldN` w drzewie, przeciągnij punkt w widoku 2D |
| Przesunięcie całego pola | zaznacz `FieldN`, przeciągnij jak zwykły węzeł (narzędzie przesuwania) |
| Nowe pole (np. platforma) | zaznacz istniejące pole i **Ctrl+D** — kopia z tymi samymi ustawieniami |
| Usunięcie pola | zaznacz `FieldN` i **Delete** |

- Kolejność narożników nie ma znaczenia — są zawsze sortowane: **dwa niższe na ekranie = przednia
  krawędź** (rząd przedni), **dwa wyższe = tylna krawędź** (rząd najdalszy).
- Pole musi mieć dokładnie 4 narożniki; dodanie / usunięcie punktu w edytorze wielokąta jest ignorowane.
- Współrzędne zaokrąglane do pełnych pikseli.
- Kolor pola: 1 żółty, 2 niebieski, 3 różowy, 4 zielony (potem od początku).

## 5. Ustawienia pola (inspektor)

W inspektorze pliku układu → **fields** → rozwiń pole:

| Ustawienie | Zakres | Domyślnie | Co robi |
|---|---|---|---|
| **quad** | 4 punkty | — | narożniki pola w px (przy szerokości 1920; ustawiane myszą) |
| **rows** | 1–3 | 1 | liczba rzędów. 1 rząd = na przedniej krawędzi; więcej = równo od przedniej do tylnej |
| **row_capacity** | 1–8 | 3 | ilu wrogów najwyżej w jednym rzędzie |
| **front_scale** | 0,3–2 | 1,0 | mnożnik wielkości wrogów w rzędzie przednim |
| **auto_depth_scale** | wł./wył. | wł. | wł.: dalszy rząd tyle razy mniejszy, ile razy jest węższy od przedniej krawędzi |
| **back_scale** | 0,3–2 | 0,82 | wielkość w rzędzie najdalszym, gdy `auto_depth_scale` wyłączone; rzędy pośrednie — pomiędzy |

Zmiany w inspektorze od razu przesuwają podgląd; myszą zmienione narożniki od razu trafiają do `quad`.

**Wskazówka:** przy mocnym trapezie (tył dużo węższy) `auto_depth_scale` potrafi bardzo zmniejszyć
tylnych wrogów — wtedy wyłącz je i ustaw `back_scale` ręcznie (np. 0,8).

## 6. Ustawienia podglądu (inspektor sceny)

Główny węzeł **BattleLayoutPreview**. Te ustawienia zmieniają **tylko** podgląd, nie grę.

| Ustawienie | Co robi |
|---|---|
| **layout** | edytowany plik układu |
| **preview_per_row** (1–8) | ilu przykładowych wrogów w **każdym** rzędzie pól bez wpisu w `field_counts` (najwyżej `row_capacity`) |
| **field_counts** | ilu wrogów na polu 1, 2, 3… (patrz niżej) |
| **enemy_sprites** | lista grafik wrogów (pliki SpriteFrames z `resources/enemies/`) |

### field_counts
Lista liczb, po jednej na pole, w kolejności pól:

- liczba ≥ 1 — tylu wrogów na tym polu, rozdzielonych po rzędach **od przedniego** po kolei
  (5 wrogów na 2 rzędach → 3 z przodu, 2 z tyłu); najwyżej `rows × row_capacity`;
- `0` — pole puste;
- `-1` albo brak wpisu — `preview_per_row` w każdym rzędzie (jak bez listy).

Przykład: `[4, 0, 1]` → 4 wrogów na podłodze, nic na pierwszej platformie, 1 na drugiej.

### enemy_sprites
- Grafiki rozdawane po kolei: pole 1 od przedniego rzędu od lewej, potem kolejne rzędy, potem pole 2…
  Gdy grafik jest mniej niż wrogów — od początku listy.
- Pokazywana jest pierwsza klatka animacji postoju — ta sama, którą bierze walka w grze
  (`idle_down` → `slime_idle` → `idle` → coś z „idle” → `walk…` → pierwsza animacja).
- Grafika stoi na linii stóp **dolnym nieprzezroczystym pikselem** (jak w grze), więc cień / pusty
  margines pod sprite'em nie zawyża wroga.
- Pusta lista = półprzezroczyste kwadraty w kolorze pola.
- Dalsi wrogowie są rysowani pod bliższymi.

Kropka w kolorze pola = punkt stóp wroga.

## 7. Jak liczone są miejsca i skala wrogów

**Miejsce w rzędzie.** W rzędzie z *n* wrogami stopy *k*-tego (od lewej, od 0) leżą w
`(k + 0,5) / n` długości linii rzędu — środki równych odcinków:

| wrogów w rzędzie | położenie stóp na linii rzędu |
|---|---|
| 1 | 50% |
| 2 | 25%, 75% |
| 3 | 16,7%, 50%, 83,3% |
| 4 | 12,5%, 37,5%, 62,5%, 87,5% |
| 5 | 10%, 30%, 50%, 70%, 90% |

Skrajny wróg nigdy nie stoi na samym boku pola, ale połowa jego grafiki wystaje w bok od kropki —
przy szerokich wrogach zostaw zapas od ścian tła.

**Przydział do rzędów (w grze).** Wszystkie rzędy wszystkich pól tworzą jedną pulę; dla każdego
wroga losowany jest rząd, w którym jest jeszcze miejsce. Wróg z preferencją „front” idzie do rzędu
najbliżej (najniżej na ekranie), „back” — najdalej. *Obecnie żaden wróg nie ma ustawionej preferencji,
więc przydział jest zawsze losowy.* Gdy wrogów jest więcej niż miejsc, nadmiarowi stają na środku przedniego
rzędu pierwszego pola (na sobie) — ustaw łączną pojemność pól co najmniej na największą grupę wrogów.

**Wielkość.** `skala liczby wrogów × skala rzędu`:

| wrogów w walce | 1 | 2 | 3 | 4 | 5+ |
|---|---|---|---|---|---|
| skala bazowa | 8,5 | 7,2 | 6,2 | 5,6 | 5,2 |

Skala rzędu to `front_scale`, a dalej `auto_depth_scale` / `back_scale` (rozdział 5). W podglądzie
„liczba wrogów w walce” = liczba wszystkich narysowanych przykładowych wrogów.

**Inny rozmiar ekranu.** Położenie poziome skaluje się z szerokością ekranu; pionowe liczone jest od
dołu obszaru bitwy (nad paskiem UI) i skaluje się z wysokością. Dlatego ustawiaj pola przy 1920×1080 —
na innych proporcjach wrogowie trzymają się podłogi, a nie góry ekranu.

## 8. Przykłady

**Sprawdzenie najszerszego rozstawienia:** `preview_per_row` = `row_capacity` (np. 5) — skrajni na
10% i 90% linii rzędu, wrogowie w najmniejszej skali.

**Sprawdzenie największego wroga:** `field_counts = [1]`, w `enemy_sprites` najwyższy wróg (np. ork)
— czy głowa nie wchodzi w górny pasek / sufit tła.

**Tło z platformą:**
1. `Field1` — podłoga: trapez na dole, `rows = 2`, `row_capacity = 4`.
2. Zaznacz `Field1`, **Ctrl+D** → `Field2`; przeciągnij jego narożniki na platformę,
   `rows = 1`, `row_capacity = 2`, ew. `front_scale = 0,8`.
3. `field_counts = [3, 2]` — tak może wyglądać walka z 5 wrogami.

## 9. Problemy i pułapki

- **Zmiana nie zapisała się** — plik zapisuje się 0,6 s po ostatnim ruchu i tylko gdy jest zapisanym
  plikiem (ma ścieżkę). Pole wbudowane w scenę się nie zapisze — użyj osobnego `.tres`.
- **Gra nie widzi układu** — sprawdź nazwę: dokładnie `<grafika>_layout.tres` w folderze grafiki
  (np. grafika `Gemini_Generated_Image_….jpg` w `pixel_crawler/cave` nie ma jeszcze układu → pole domyślne).
- **Narożnik „uciekł” / pole zniknęło** — kształt z NaN jest odrzucany (zostaje poprzedni). Jeśli coś
  wygląda źle, Ctrl+Z albo przywrócenie pliku z gita.
- **Po zmianie listy `fields` w inspektorze** węzły `Field…` budują się od nowa — zaznacz pole jeszcze raz.
- **Ostrzeżenia „invalid UID … using text path”** przy otwieraniu sceny pochodzą z plików wrogów
  (`resources/enemies/*.tres`) — grafiki i tak się ładują; nie dotyczą układu.
- **Rozstawienie w grze inne niż w podglądzie** — w grze rzędy są losowane; podgląd pokazuje przykładowy
  podział, ale miejsca w rzędzie i skala są liczone identycznie.

## 10. Pliki

| Plik | Rola |
|---|---|
| `scenes/tools/battle_layout_preview.tscn` | scena podglądu / edytora |
| `scripts/tools/battle_layout_preview.gd` | logika podglądu (synchronizacja `Field…` ↔ plik, rysowanie) |
| `scripts/quiz/battle_background_layout.gd` | `BattleBackgroundLayout` — plik układu, przydział miejsc, położenie, skala |
| `scripts/quiz/battle_field.gd` | `BattleField` — jedno pole: narożniki, rzędy, pojemność, skale |
| `scripts/quiz/battle_background.gd` | tło walki w grze; `get_layout()` wczytuje układ bieżącej grafiki |
| `assets/textures/battle_backgrounds/**/<grafika>_layout.tres` | pliki układu poszczególnych teł |

Wszystkie ścieżki względem `modules/quiz_rpg/`.
