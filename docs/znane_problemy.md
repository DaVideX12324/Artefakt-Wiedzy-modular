# Znane problemy i rzeczy odłożone (quiz_rpg — generator jaskiń)

> Spisane 2026-09-25. Każdy punkt: co jest nie tak, dlaczego zostało jak jest, kiedy do tego wrócić.
> Po naprawie punkt usuwamy albo przenosimy do „Rozwiązane” z numerem commita.

## Odłożone świadomie

(brak)

## Do zrobienia (zgłoszone, następnym razem)

### Fasada płaskowyżu tuż za ścianą jaskini — zamiast wchłaniać, dociągnąć boki
- Zgłoszenie 2026-09-26, seed 119 250×250, okolice (46–52, 73–75): płaskowyż stoi tuż za ścianą jaskini
  (góra płaskowyżu pod górą ściany jaskini), a jego fasada wychodzi przed ścianę.
- Oczekiwane: fasadę płaskowyżu w takim miejscu wyciąć (jak rim północny pod górą modułu ściany —
  `PlateauRenderer._absorbed`, commit 0c8bc75), a ściany boczne płaskowyżu dociągnąć do ściany jaskini.
  Kierunek: przy kształtowaniu maski (`PlateauPass`, podobnie jak `_turn_up_at_walls`) albo w rendererze.

### Małe filary: skosy i łączniki 3H zamiast 2H
- Seed 118945 160×160, filary (118–121, 89–92) i (124–127, 97–99). Grubość kolumn filaru 2/3/4/3 i 2/3/3/2
  -> mieszanka narożnika 2H, łącznika 2H↔3H, schodka 3H i narożnika out 3H.
- Poprawiacz skosów (`EdgeAnalyzer.slope_2h_depth`, grubość 3..5, commit 107f047) wymaga kontynuacji skosu po
  drugiej stronie — ostatni stopień przed płaskim końcem filaru zostaje narożnikiem 3H. Kolumny grubości 3
  nie dostaną kafla 2H (pokrywa 2 kratki ściany + rim), więc pełne 2H wymaga ścięcia siatki.
- Filar 2 naprawia `ShortBulgeFlattenPass` (włączony domyślnie; na zgłoszeniu był wyłączony w podglądzie).
  Filaru 1 (kształt schodów) nie łapie, bo porównuje wybrzuszenie tylko z sąsiadem w tym samym rzędzie.
- Opcje: (1) rozszerzyć spłaszczanie wybrzuszeń na sąsiadów o rząd wyżej / niżej (ścina górę filaru);
  (2) wymusić 2H na małych, wolnostojących filarach (jak tryb płaskowyżu).

## Do sprawdzenia w grze (testy headless tego nie widzą)
- **Kafle wielokratkowe na warstwie `Props`** (obiekt z `"atlas"` i `size` > 1×1, placement `grid`) —
  ścieżka jest, ale nie była oglądana; kafel TileSetu rysuje się względem swojej kratki, więc duży kafel
  może być przesunięty względem podstawy. Obiekty ze scen (obecny katalog caves) tego nie dotyczy.
- **Kapelusze dużych grzybów nad ścianą** — y-sort po nodze trzonu, więc kapelusz rysuje się nad kaflami
  ściany na północ od niego (tak jak na mockupie). Sprawdzić, czy nie zasłania czegoś ważnego (portale,
  schody płaskowyżu).
- **Pozycja scen INTERACTIVE** — środek kratki kotwicy (dolny wiersz podstawy), jak dotychczasowe
  skrzynie; większe sceny interaktywne mogą wymagać własnego originu.

## Wydajność
- **Wypiekanie siatki nawigacji** ~1 s na 250×250 (w wątku roboczym, etap „Ścieżki przeciwników”);
  mapa nawigacji wczytuje region asynchronicznie (~12 klatek fizyki) — do tego czasu wróg bez ścieżki
  idzie prosto tylko przy czystej linii.
- **Pętla naprawy płaskowyżów** (`PlateauPass._solve`) ~750 ms na 250×250 (BFS po mapie × ~8 iteracji) —
  kandydat na płaskie tablice (jak w `ObjectPlanner`).
- **Planer obiektów** ~95–110 ms na 250×250 przy ~500 obiektach, ale z pełnym katalogiem caves
  (~3,4 tys. obiektów z towarzyszami) ~340 ms — w wątku roboczym, ale wydłuża ładowanie. Najdroższe:
  cechy mapy (`ObjectFeatures`, ~40 ms), BFS rezerwacji przejść, pętle kandydatów dla gęstych DECAL-i.
- **Kształtowanie masek terenu** (`TerrainMaskPlanner.shape_mask`) ~130 ms na 250×250 (dwie maski).
- **Etap `entities`** jest ciężki przez odtwarzanie sceny `slime_tutorial` przy każdej instancji
  (ostrzeżenie „re-save this scene”) — po ponownym zapisie sceny w edytorze powinno spaść.
- `closed_chest_tutorial.tscn` ma nieaktualny UID tekstury (ostrzeżenie „invalid UID … using text path”)
  — do ponownego zapisu w edytorze.

## Pułapki konfiguracji (działa zgodnie z założeniem, ale łatwo się naciąć)
- **Gęstość obiektu jest per obiekt, nie per grupa.** Warianty jednego rodzaju dawać jako listę scen
  w jednym obiekcie (`"scene": [a, b, c]`), a nie jako osobne obiekty — inaczej gęstość się mnoży.
  Narzędzie/wtyczka katalogu dodaje każdą nową scenę jako osobny obiekt → po dodaniu wariantów scalić
  je ręcznie w listę.
- **Gęstość = sztuk na 100 kratek-kandydatów**, a kandydaci zależą od reguł (`terrain`, `context`).
  Obiekty tylko na trawie skalują się z pokryciem trawą (`terrain_grass_*` w caves.json).
- **Wtyczka Object Catalog Sync** nie usuwa wpisów po skasowanych scenach (robi to narzędzie
  `tools/sync_object_catalogs.gd` z `REMOVE_MISSING = true`) i zostawia grupy bez obiektów w pliku.
- **Skrypty używane w edytorze** (narzędzia, wtyczka) muszą być `@tool`, jeśli mają `static var` —
  edytor nie inicjalizuje statycznych zmiennych skryptów bez `@tool` (stąd leniwe mutexy w
  `ObjectBake` / `ObjectCatalog`).
- **Maski terenu liczone raz** w etapie obiektów (`GenerationResult.terrain_masks`) i używane przez planer
  kafli tylko przy tym samym seedzie — `procedural_level` planuje kafle z `result.seed_used`. Inny seed
  kafli = inne maski niż te, które widziały obiekty.
- **`plateau_smooth` = 2** wycina płaskowyże w wąskich korytarzach — zostaje 1.

## Testy
- Testy (`modules/quiz_rpg/tests/`, w tym `run_plateau_suite.sh`, `diag_objects.gd` i
  `parity_baseline.txt`) są w `.gitignore` — żyją tylko lokalnie. Utrata katalogu = utrata zestawu
  i baseline'u parytetu.
- Baseline parytetu zależy od katalogu obiektów: przeszkody zsuwają spawny wrogów/skrzyń, więc każda
  zmiana `objects_caves.json` z kolizją zmienia pole `spawns` w digestach (ściany/podłoga bez zmian).

## Rozwiązane (dla kontekstu)
- Nawigacja wrogów bez ścian i przeszkód — siatka nawigacji z generatora (`NavOutlines`, commit b4bb991,
  dokładne kształty przeszkód 0785ade); wrogowie gonią i wałęsają się po niej (0785ade).
- Wróg widział przez ściany — promień jak w Amon-Ra (ściany + przeszkody) + linia po siatce mapy
  (e4192f9). Szczegóły: `docs/analiza_ai_przeciwnikow.md`.
- Pojedyncze kratki / plamy 1×2 / zakręty 1-szerokie błota i trawy (zestaw 13 kafli bez pokrycia) —
  kształtowanie masek pod wierzchołki kafli (commit c4c253f), test `diag_terrain_masks.gd`.
- Twarde cięcia krawędzi błota/trawy = Godot bug #70218 (`set_cells_terrain_connect`) — obejście własnym
  `TerrainAutotileSolver` (commit 2524d2b); zostają pojedyncze niedopasowania narożników (subtelne).
- Losowy seed (≤ 0) dawał kaflom i terenowi inny seed niż topologii — teraz wspólny `result.seed_used`.
- Narzędzie katalogu w edytorze: niezainicjalizowane statyczne mutexy (commit 4cc579f).
