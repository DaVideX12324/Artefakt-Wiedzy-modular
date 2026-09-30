# Ekran ładowania

Scena `scenes/ui/loading_screen.tscn`, skrypt `scripts/ui/loading_screen.gd` (dawniej
`generation_loading_overlay`, budowany w kodzie). Używa go `procedural_level.generate_level_async`.

## API

- Źródło postępu: `track(obj z fraction()/label())` (GenProgress), `track_resource_load(path)`
  (wczytywanie w tle — pod mapy ręczne), `set_progress(frac, label)`. `close()` = 100% + zanik.
- Pola: `title`, `location` (duża nazwa, font **Jacquard 24** — `assets/fonts/`, OFL, polskie znaki;
  import bez antyaliasingu tylko lokalnie, bo `.import` w gitignore), `background`, `paused`.
- Węzły po unikalnych nazwach (`%Root %Art %Band %Title %Location %Stage %Percent %Bar`, opcjonalnie
  `%FillClip %Shine`) — można
  przestawiać w drzewie (user dodał `MarginContainer`).
- **Pauza**: `paused` (inspektor / Remote) albo klawisz Pause/Break — pasek stoi, `close()` czeka.
- **Podgląd F6**: scena uruchomiona sama pokazuje grafikę z `preview_key`, `preview_location`, pasek.

## Postęp i animacja

- **begin / sub / end**: `GenProgress.begin(&"etap")` na początku, `GenProgress.end(&"etap")` na końcu
  każdego etapu (`end()` bez nazwy = bieżący; nazwa inna niż bieżąca = no-op). `sub()` dochodzi najwyżej
  do 95% etapu — cały etap zalicza dopiero `end()` (wcześniej `sub(1.0)` w „Potworach i skrzyniach”
  pokazywało ~100%, choć potem jeszcze sekundami szło wstawianie obiektów). Przed `finish()` pasek
  najwyżej 99%, procent zaokrąglany w dół — 100% tylko przy `close()`. Nowy etap: `begin` + `end`.
- **Etapy** (`GenProgress.STAGES`, wagi ≈ ms/10 przy 250×250, kalibracja 2026-09-30): płaskowyże
  rozbite na kształt + schody, obiekty na teren + obiekty, encje na potwory + obiekty w scenie (`props`).
- **Kotwice** `sub()` w długich etapach: wygładzanie, płaskowyże (kroki kształtu, iteracje naprawy),
  obiekty (po defach), krawędzie (co 16 wierszy + przebiegi), skała (co 16 wierszy), podłoga, ściany
  (po placerach), kafle płaskowyżów (poziomy wg wielkości, okna wg pola), malowanie, obiekty w scenie.
  `sub_in(etap, x)` działa tylko w danym etapie — `EdgeAnalyzer` i placery są wołane też w oknach
  płaskowyżów (etap `plateau_tiles`) i nie mogą przesuwać paska w cudzym etapie.
- **Przesuw w czasie**: `fraction()` przesuwa pasek w obrębie etapu wg oczekiwanego czasu (waga ×
  tempo; tempo startuje z `ms_per_weight` skalowanego polem mapy i dopasowuje się do zmierzonych
  etapów) — liniowo do 80% etapu, potem coraz wolniej do 97%, nigdy za koniec etapu.
- **Malowanie terenu** porcjami (`TerrainPaintExecutor.execute_chunked`) — wcześniej jedna klatka ~0,6 s
  przy 500×500.
- **Animacja**: błysk `%Shine` w `%FillClip` pod `%Bar` (szerokość/prędkość/przerwa: `SHINE_*`),
  kropki 1..3 po nazwie etapu (`DOTS_STEP`) — działa także, gdy postęp chwilowo stoi.
  Pozycja błysku to **stan** (`_shine_x` +`SHINE_SPEED*delta`, po końcu wypełnienia przerwa `SHINE_GAP`),
  nie `fmod(czas, okres)`: okres zależał od szerokości wypełnienia, która rośnie z paskiem, więc wzór
  przeskakiwał, także w lewo.
- Pomiar (seed 184356, próbka co klatkę): 250×250 najdłuższy przestój < 0,5 pkt ~0,65 s, największy
  skok 3,8%; 500×500 ~1,7–1,9 s i 1,7% (wcześniej 12 s na 73% w „Płaskowyżach” i 3,3 s na 99%).

## Tło

- Losowa grafika z folderu `modules/quiz_rpg/assets/textures/loading_screens/<klucz>/` (png/jpg/webp,
  `ResourceLoader.list_directory` — działa w eksporcie). Brak = ciemne tło.
- Klucz: mapa generowana — `ProceduralLevel.loading_screen_key` albo z typu poziomu
  (CAVE_DUNGEON→`cave`, DUNGEON_CASTLE→`castle`, FOREST_OVERWORLD→`forest`); mapa ręczna — nazwa
  pliku sceny (np. `tutorial_area`).
- `%Band`: pas pod paskiem w kolorze dolnych 2% grafiki (`edge_color`); wysokość i przejście z edytora.
- Nazwa lokacji: `ProceduralLevel.location_name`, puste → „Jaskinia” / „Zamek” / „Las”.
- Prompty do grafik: `loading_screens/loading_screen_prompts.md` — 12 stref × 3–4 warianty,
  perspektywa 1. osoby z poziomu ziemi (Gemini robił widok z góry), referencje = mockupy autorów paczek.

## Niezrobione

- Ekran nie jest podpięty pod mapy ręczne (`level_manager.load_level_direct` robi `load()` synchronicznie).
- Grafiki z Gemini dla jaskini są w `loading_screens/cave/` (c205e80); pozostałe foldery puste.
