# Analiza AI i animacji przeciwników: Amon-Ra `enemy.gd` vs Artefakt `enemy_base.gd`

> Spisane 2026-09-25. Źródła: `Amon-Ra/amon-ra/scripts/characters/enemy.gd` (1077 linii) + podklasy
> i sceny `scenes/characters/enemy_*.tscn`; `modules/quiz_rpg/scripts/enemies/enemy_base.gd` +
> `scenes/enemies/enemy.tscn`. Numery linii `enemy.gd:NNN` = plik Amon-Ra. Nic jeszcze nie zmieniane.

## 1. Błąd: przeciwnik w Artefakcie widzi przez ściany

Pomiar na wygenerowanej mapie (caves, seed 119, 100×100), promienie fizyki w tej samej scenie co kafle.

### Przyczyny (nakładają się)
1. **RayCast2D wroga nie widzi ścian — główna przyczyna.**
   - `RayCast2D` w `scenes/enemies/enemy.tscn` ma domyślną maskę `1` = warstwa „Player”; ściany są na
     warstwie 3 „GroundCollisions” (TileSet `physics_layer_0/collision_layer = 4`).
   - Promień trafia gracza albo nic, a `_has_line_of_sight_to_player` (`enemy_base.gd:225`) oba wyniki
     uznaje za „widzę”.
   - Pomiar: z maską 1 — **200/200** losowych promieni przez mapę bez żadnej przeszkody.
2. **„Blisko = widoczny” bez sprawdzania** — `distance < 50 → return true` (`enemy_base.gd:234`).
   50 px ≈ 3 kratki, więc przez cienką ścianę wróg widzi zawsze; przy `detection_radius = 70` ze sceny to
   ponad połowa zasięgu wzroku.
3. **Kolizje ścian tylko na krawędziach.**
   - Na 8154 komórki ścian kolizję ma 654 (kafle krawędzi, często cienkie wielokąty); lita skała —
     7500 komórek — nie ma żadnej.
   - Nawet z poprawną maską ścian (4): na 500 linii przechodzących przez komórki ścian promień **nie trafił
     w nic w 76 (15%)** — przecieka po skosie przez narożniki i szpary między kształtami kafli.
   - Dla ruchu bez znaczenia (krawędź i tak zatrzyma postać), dla widoczności — przecieki.
4. **Pościg to prosta linia** do ostatniej znanej pozycji; przy ścianie `velocity = 0`
   (`enemy_base.gd:_chase`). Wróg, który „zobaczył” gracza przez skałę, pcha się w nią do końca pamięci
   (3 s) — to wygląda jak widzenie przez ścianę.

### Jak robi to Amon-Ra (działa, bo warstwy są spójne)
- Warstwy: 1 `mapCollision` (ściany we wszystkich tilesetach), 32 `playerDetection` (warstwa gracza).
- RayCast wroga: maska `2147483649` = warstwy 1 + 32 → trafia ścianę albo gracza; ściana zasłania.
- Atak „przez ściany”: osobny promień z maską 1 (same ściany) — pusty wynik = czysto (`enemy.gd:663`).
- VisionRange: maska 32 → reaguje tylko na gracza.
- Luka: brak trafienia promienia → widoczny tylko bliżej niż 100 px (`enemy.gd:480`); promień obcięty do
  300 px, więc przy większym zasięgu wzroku dalszy gracz jest „niewidoczny” mimo czystej drogi.
- Kolizje ścian malowane ręcznie w poziomach — skała jest „pełna”.

### Proponowana naprawa
- **Widoczność po siatce mapy zamiast po fizyce**: linia od kratki wroga do kratki gracza, sprawdzana
  komórka po komórce z narożnikami (supercover — przejście po skosie się nie prześlizgnie); każda komórka
  niechodliwa zasłania. Siatka jest w `last_result.grid`; kilkadziesiąt odczytów, bez przecieków
  i bez zależności od kształtów kafli.
- **Promień fizyki jako zapas** (poziomy bez siatki): maska ściany + gracz = `4 | 1 = 5`.
- **Skrót „bliżej niż 50 px”** tylko przy czystej linii po siatce.
- Opcjonalnie: duże przeszkody (warstwa 6 „ObjectCollisions”) też zasłaniają (kwestia gustu; domyślnie nie).
- Pościg omijający ściany wymaga siatki nawigacji z generatora (patrz niżej, sekcja 4).

## 2. Sprite'y i animacje w Amon-Ra

### Wybór trybu (`enemy.gd:340`)
- 4-way, gdy istnieją wszystkie `walk_up/down/left/right`; inaczej 2-way.
- W Amon-Ra 4-way mają wszystkie zwykłe wrogi (bandyci, orki, rośliny, slime'y, wampiry, mumie, warthog),
  2-way tylko slime'y tutorialowe (nazwy animacji nadpisane w `_ready`: `anim_walk = "slime_walk"` —
  to zwykłe zmienne, nie eksporty).

### 4-way (`enemy.gd:741–812`)
- **Kierunek z prędkości z histerezą**: oś dominuje, gdy jej składowa (wektor znormalizowany) przewyższa
  drugą o 0,5 — na skosach zostaje poprzedni kierunek, sprite nie migocze. Poniżej 5 px/s — ostatni
  kierunek (idle patrzy tam, gdzie wróg szedł).
- **Nazwa animacji** `przedrostek_kierunek`, priorytet: hurt (jeśli gra) > attack (jeśli gra) > death >
  walk > idle. Liczone co klatkę, także przy `anim_locked`; przy odrzucie kierunek może się zmienić
  i hurt startuje od nowa w nowym kierunku.
- **Kształty kierunkowe (opcjonalne)**: ciało `CollisionUp/Down/Left/Right`, atak
  `DamageHitbox/ShapeUp/...` przełączane wg kierunku.
- **Aktywne klatki ataku per kierunek** (`attack_frames_up/...` → słownik); hitbox tylko w nich,
  kolejne klatki po trafieniu go nie włączają (jedno trafienie na zamach). Ręczna tablica hitboxów
  (klatka → kształt) ma pierwszeństwo.

### 2-way (`enemy.gd:814–869`)
- Walk/idle respektuje `anim_locked`; odbicie w poziomie zawsze, gdy `|kierunek.x| > flip_threshold`
  (domyślnie 0 — każdy minimalny ruch w bok przerzuca sprite).
- Lustro kształtów: ciało i wszystkie kształty hitboxa — odbijane tylko `position.x` (oryginalne `|x|`
  w metadanych). Działa dla kształtów narysowanych „w prawo”; wielokątów ani kształtów niesymetrycznych nie
  odbija.

### Śmierć / obrażenia
- `death_<kierunek>` → zapas `death` → `await animation_finished` → `queue_free`. Mumia (bez animacji
  śmierci) nadpisuje to zanikaniem (tween).

### Ryzyka
- Zapętlona animacja hurt / attack / death → `await animation_finished` nigdy nie wraca: `anim_locked`
  na zawsze, przy śmierci wróg nie znika.
- `hurt_<kierunek>` grane bez sprawdzenia, czy istnieje (`enemy.gd:949`).
- Kształty kierunkowe przełączane `call_deferred` w każdej klatce, także bez zmiany kierunku
  (`enemy.gd:710`, `:757`) — zbędny koszt i chwila, gdy wszystkie są wyłączone.

## 3. AI w Amon-Ra

### Percepcja (`enemy.gd:463–505`)
- VisionRange (wejście gracza) → co klatkę RayCast do kształtu kolizji gracza (maks. 300 px).
- Trafia gracza → zaalarmowany, `last_seen_player_pos`, pamięć `memory_duration` (3 s). Utrata wzroku →
  przez czas pamięci goni ostatnią znaną pozycję.

### Pościg i pathfinding (`enemy.gd:517–538`)
- `NavigationAgent2D.target_position = last_seen_player_pos` **co klatkę** — przy ruchomym graczu trasa
  liczona praktycznie co klatkę.
- Kierunek do następnego punktu trasy **losowo obracany o ±25° co klatkę** + przesunięcie ±10° zmieniane
  co 1–2 s → „żywy”, ale drgający tor (histereza 4-way maskuje to tylko na sprite'cie).
- Bez avoidance agenta i bez separacji — prędkość ustawiana wprost, `move_and_slide` ślizga po ścianach;
  grupa zbija się w jeden punkt.
- **Błąd**: po dojściu do celu `velocity` nie jest zerowane i `move_and_slide` nie jest wołane
  (`enemy.gd:533`) — wróg stoi w ostatnio widzianym miejscu, grając animację chodu, do końca pamięci.
- Dane nawigacji: ręczne `NavigationRegion2D` w poziomach (np. CaveEntrance z przeszkodami wycinającymi
  siatkę — `carve_navigation_mesh`).

### Wałęsanie (`enemy.gd:871–883`)
- Losowy cel w `wander_radius` co 2–4 s, linia prosta, połowa prędkości, **bez nawigacji i bez reakcji na
  ścianę** (przyciśnięty do ściany czeka na koniec czasu).
- `wander_timer` wspólny dla wałęsania i przesunięcia w pościgu (`enemy.gd:872`, `:887`) — mieszają sobie
  czasy.

### Atak
- ANIMATION_BASED: widzi + czysta linia + zasięg (auto z kształtu hitboxa: rozmiar + przesunięcie, × 1,5)
  → animacja ataku, `velocity = 0`, cooldown. CONTINUOUS: hitbox zawsze aktywny, obrażenia przy wejściu
  i co tick timera.
- Hak `_try_custom_attack` dla podklas (np. szarża warthoga: przygotowanie, pęd, ogłuszenie o ścianę).

### Drobiazgi
- Odrzut i ogłuszenie nadpisują ruch.
- `_raycast_update_timer` eksportowany, ale bez efektu (promień i tak co klatkę, `enemy.gd:514`).
- Gracz szukany po `/root/Game/Player`, grupa jako zapas.

## 4. Porównanie z Artefaktem

| | Amon-Ra `enemy.gd` | Artefakt `enemy_base.gd` |
|---|---|---|
| Kierunek 4-way | histereza 0,5, pamięta ostatni | bez histerezy — migocze na skosach |
| Animacje | walk/idle/hurt/attack/death × 4 kierunki | tylko walk/idle (walka to quiz) |
| 2-way | odbicie z progiem + lustro kształtów | `flip_h = velocity.x < 0` |
| Widoczność | RayCast ściany + gracz (spójne warstwy) | RayCast tylko warstwa gracza → **widzi przez ściany** (sekcja 1) |
| Pościg | NavigationAgent2D + losowe drgania | linia prosta, przy ścianie stop (nawigacja celowo wyłączona) |
| Wałęsanie | linia prosta, bez reakcji na ścianę | linia prosta, odbicie od ściany, pauzy |
| Pamięć | 3 s, ostatnia pozycja | to samo |
| Dane nawigacji | ręczne regiony w poziomach | sam prostokąt mapy (region bez dzieci) |

## 5. Co przenieść do Artefaktu

**Wziąć**
- Wybór kierunku 4-way z histerezą i priorytetem przedrostków, z zapasem do idle / 2-way przy braku
  animacji.
- Odbicie 2-way z progiem.
- Opcjonalny hak `_try_custom_attack` dla specjalnych wrogów.

**Poprawić przy przenoszeniu**
- Zerować `velocity` po dojściu do celu.
- Płynne sterowanie zamiast losowego obrotu co klatkę.
- Trasa co ~0,25 s albo gdy cel przesunie się o ponad pół kratki, nie co klatkę.
- Avoidance (RVO), żeby wrogowie się nie zbijali.
- Kształty kierunkowe przełączać tylko przy zmianie kierunku.
- Maski promieni dopasować do naszych warstw (Player 1, Enemies 2, GroundCollisions 3, ObjectCollisions 6).
- Każdy `await animation_finished` z limitem czasu.

**Pominąć**
- Hitboxy ataku, klatki aktywne, CONTINUOUS, progresję, loot — u nas walkę uruchamia kontakt, dalej quiz.

**Warunek konieczny dla pathfindingu**: prawdziwa siatka nawigacji z generatora — obrys chodliwej
podłogi minus bariery płaskowyżów i przeszkody obiektów (`docs/znane_problemy.md`, „Nawigacja nie widzi
ścian ani przeszkód”). Bez niej NavigationAgent2D nic nie da — `enemy_base` wyłączył go właśnie dlatego,
że przy pustym regionie prowadził w złą stronę.
