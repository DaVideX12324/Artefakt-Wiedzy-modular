# Ekran ładowania

Scena `scenes/ui/loading_screen.tscn`, skrypt `scripts/ui/loading_screen.gd` (dawniej
`generation_loading_overlay`, budowany w kodzie). Używa go `procedural_level.generate_level_async`.

## API

- Źródło postępu: `track(obj z fraction()/label())` (GenProgress), `track_resource_load(path)`
  (wczytywanie w tle — pod mapy ręczne), `set_progress(frac, label)`. `close()` = 100% + zanik.
- Pola: `title`, `location` (duża nazwa, font **Jacquard 24** — `assets/fonts/`, OFL, polskie znaki;
  import bez antyaliasingu tylko lokalnie, bo `.import` w gitignore), `background`, `paused`.
- Węzły po unikalnych nazwach (`%Root %Art %Band %Title %Location %Stage %Percent %Bar`) — można
  przestawiać w drzewie (user dodał `MarginContainer`).
- **Pauza**: `paused` (inspektor / Remote) albo klawisz Pause/Break — pasek stoi, `close()` czeka.
- **Podgląd F6**: scena uruchomiona sama pokazuje grafikę z `preview_key`, `preview_location`, pasek.

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
