# Znane problemy i rzeczy odłożone (quiz_rpg — generator jaskiń)

> Spisane 2026-09-25. Każdy punkt: co jest nie tak, dlaczego zostało jak jest, kiedy do tego wrócić.
> Po naprawie punkt usuwamy albo przenosimy do „Rozwiązane” z numerem commita.

## Odłożone świadomie

### Nawigacja nie widzi ścian ani przeszkód
- `MapGeneratorBase.setup_navigation_region` robi `NavigationRegion2D` jako sam prostokąt mapy — region
  nie ma dzieci do parsowania, więc ani ściany, ani przeszkody z generatora obiektów (kształty w ciałach
  `PhysicsServer2D` po fragmentach 32×32 kratek) nie są przeszkodami nawigacji.
- Odłożone (decyzja 2026-09-25): wrogowie po kolizji z obiektem zmieniają kierunek, więc w praktyce nie
  przeszkadza.
- Wrócić, gdy pojawią się objawy: wrogowie klinują się o duże grzyby / koralowce, idą w ściany, gonią
  gracza „przez” przeszkody. Kierunek: obrysy przeszkód (kształty z `ObjectBake`, `ObjectPlan.solid_cells`)
  i ścian jako przeszkody w `NavigationMeshSourceGeometryData2D` przed bake'iem.

### Przeciwnik widzi przez ściany
- `RayCast2D` wroga ma domyślną maskę 1 (warstwa Player), więc nie trafia ścian (warstwa 3); do tego
  skrót „bliżej niż 50 px = widoczny”, a ściany mają kolizję tylko na krawędziach (15% promieni przez skałę
  przecieka nawet z poprawną maską). Szczegóły, pomiary i proponowana naprawa (widoczność po siatce mapy):
  `docs/analiza_ai_przeciwnikow.md`, sekcja 1. Pościg omijający ściany wymaga siatki nawigacji (punkt wyżej).

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
- Pojedyncze kratki / plamy 1×2 / zakręty 1-szerokie błota i trawy (zestaw 13 kafli bez pokrycia) —
  kształtowanie masek pod wierzchołki kafli (commit c4c253f), test `diag_terrain_masks.gd`.
- Twarde cięcia krawędzi błota/trawy = Godot bug #70218 (`set_cells_terrain_connect`) — obejście własnym
  `TerrainAutotileSolver` (commit 2524d2b); zostają pojedyncze niedopasowania narożników (subtelne).
- Losowy seed (≤ 0) dawał kaflom i terenowi inny seed niż topologii — teraz wspólny `result.seed_used`.
- Narzędzie katalogu w edytorze: niezainicjalizowane statyczne mutexy (commit 4cc579f).
