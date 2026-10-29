# Znane problemy i rzeczy odłożone (quiz_rpg — generator jaskiń)

> Tylko otwarte sprawy. Wpisy ZROBIONE/Rozwiązane → [`archiwum/znane_problemy_rozwiazane_2026-10-29.md`](archiwum/znane_problemy_rozwiazane_2026-10-29.md).
> Stan na 2026-10-29. Po naprawie usunąć wpis albo przenieść do archiwum.

---

## Do zrobienia (zgłoszone, następnym razem)

- (2026-10-29) NPC jako CharacterBody2D (dziś StaticBody2D).

### ⚠ WAŻNE: (5) miasto / hub z modularnych zasobów paczki free — następny etap
- **Decyzja 2026-10-15:** miasto robione **ręcznie** przez usera (scena w edytorze), **bez generowania**. Po stronie kodu: NPC, sklep, kowal / ulepszenia, rekrutacja towarzyszy (logika niezależna od mapy).
- Stan 2026-10-29: szkielet logiczny zrobiony (`kontekst/miasto.md`); zostało: konkretne wnętrza, zadania NPC, prawdziwe flagi etapów.
> **Priorytet 2026-10-11:** user ustawił miasto / hub jako następny etap prac.

### (1) tilesety kolejnych map — ścieki zrobione, kolejne po stronie autora
- **Stan 2026-10-17: ODŁOŻONE POZA INŻYNIERKĘ (decyzja usera)** — na teraz zostaje tylko miasto (pkt 5); tilesety Cemetery, Fairy Forest itd. później albo na osobnym branchu.
- Są: jaskinie (`resources/maps/caves.tres`), ścieki (`resources/maps/sewer.tres`). Kolejne wg kolejności stref (`docs/game_design.md`): Cemetery, Fairy Forest, Desert / Desert Temple, Volcano / Forge, Dense Forest / biom zimowy, Library, Garden, Castle.
- Do zrobienia przez autora: TileSet `.tres` + companion-JSON (`resources/maps/config/`) dla każdego biomu.
- Szczegóły ścieków: [kontekst/scieki.md](kontekst/scieki.md).

### Feature: ukryte przejścia między pokojami (tunel pod voidem)
- **Stan: NIE ZROBIONE** (brak kodu; są nisze-przejścia, `NichePlacer`).
- Do ustalenia: sposób pokazania (ściemnienie/teleport vs prawdziwy korytarz), dobór par pokoi, nawigacja wrogów, zapis w seedzie. Pomysł: shader `desert_town.gdshader` (koło wokół gracza, kafle prześwitują). Jeśli shader — pod voidem muszą być kolizje ścian tunelu.

### Nisze-przejścia: wariant kafli RIM i częstość
- **Stan: CZEKA NA USERA** (wariant kafli RIM w `caves.tres`); częstość bez zmian.
- Wariant kafli szczytu ściany z innymi kolizjami jako alternatywa 1 — robi user. Przejść jest mało (0–2 na mapę) — user chce częściej (np. celowe wycięcie ściany do głębokości 3).

### Tryb walki: typy pytań bossów, losowe spotkania — strojenie
- **Stan: W TOKU.** DO SPRAWDZENIA W GRZE: typy pytań bossów (wpisywanie, kafelki, dopasowanie), przewijanie długiej listy. Losowe spotkania (wersja podstawowa zrobiona 2026-10-21): zostało strojenie dystansu w grze, strefy bez spotkań (portale, schody).

### Feedback z testów pre-alpha — resztki DO SPRAWDZENIA W GRZE
4. **[DO SPRAWDZENIA W GRZE]** Mysz w listach Umiejętności / Przedmioty (przerobione 2026-10-11, do potwierdzenia).
5. **[DO SPRAWDZENIA W GRZE]** Brak znacznika celu na starcie wyboru przeciwnika.

### Skalowanie wrogów przy kilkunastu mapach (system tierów)
- **Stan: W TOKU** — XP, statystyki i złoto z poziomu wdrożone. Zostaje: ocena trudności jaskiń po zmianie w grze; krzywe bohatera do lv 100 i tiery sprzętu na 15 map (`ekwipunek_szkic.md`).
- Kierunek: staty z `enemy_level` po jednej krzywej dopasowanej do bohatera, archetyp jako mnożniki. Zadanie projektowe (Opus) razem z kalibracją na FNaFB.

### Zawartość nisz out, sekretne pokoje — resztki
- **Stan: W TOKU** — zrobione: skrzynia tieru 2, sekretny pokój (1–3 pokoje), krypta relikwii, rzadkie pokoje (tier 3). Zostaje: skrzynia przeklęta (mechanika do ustalenia), sprawdzenie w grze.

### Modularność assetów — BitBomber
- **Stan: CZĘŚCIOWO** — Cień Mgły gotowy. Zostaje: `modules/BitBomber/resources/icon.png` ma UID jak `resources/icon.png` hosta (ostrzeżenie „UID duplicate"); pełne przeniesienie BitBombera na schemat `_host/`.

### Skalowanie pancerza w późnej fazie gry
- **Stan: DO WERYFIKACJI** — formuła w `enemy_stats.gd` bazuje na ułamku HP, DEF traci znaczenie na wysokich poziomach.
- **Decyzja usera 2026-10-17: zostawić do czasu decyzji o skali drabiny sprzętu.** Opcje: (a) wzór `ATK×4 × 100/(100+DEF·k)`, (b) DEF w krzywych mocniejszy (GEAR_DEF_END ~1100–1900). Pomiar 2026-10-17: przy pancerzu wzorcowym cios zawsze 14 % maks. HP (lv 1–100); bez pancerza spada z 29 % → 15,3 %. Pancerz ±30 % zmienia cios o ±0,4 pp na lv 100.

### Propozycja: korzeń modułu z położenia skryptu
- **Stan: PROPOZYCJA (niezatwierdzona).** Pomocnik wylicza korzeń z `get_script().resource_path` zamiast nazwy folderu. Zakres: `module_runtime.gd`, `bb_runtime.gd`, `quiz_rpg_paths.gd`. Szczegóły w archiwum bieżącej wersji pliku.

---

## Do sprawdzenia w grze (testy headless tego nie widzą)

- Boss w pokoju wyjścia jaskiń (chodzi po nawigacji?), przejście przy gradiencie, animacja wejścia/wyjścia z walki, przewijanie długiej listy, zakładka „Ogólne", wygląd skrzyń wg tieru i klucze na tier, beczki 3/(2n), złoto, trudność jaskiń po nowych statystykach.
- Kafle wielokratkowe na warstwie `Props` — ścieżka jest, nie oglądana; kafel może być przesunięty względem podstawy.
- Kapelusze dużych grzybów nad ścianą — y-sort po nodze, sprawdzić czy nie zasłania portali / schodów.
- Mysz w walce: klik wroga, listy umiejętności/przedmiotów, znacznik celu na starcie, klik po fokusie.
- Skróty dev (F9/F10/F11) w buildzie wydaniowym (`OS.is_debug_build()`).

---

## Wydajność

- **Wypiekanie siatki nawigacji** w kawałkach 64×64 (`NavOutlines.build_chunks`). Czasy: 250×250 ≈ 0,2 s, 500×500 ≈ 0,7 s. Ostrzeżenia „edge error(s)" przy synchronizacji — przy całej mapie też były.
- **`path_search_max_polygons` = 4096** — limit Godota; na 500×500 część losowych par nie ma ścieżki (długie zapytania przekraczają limit, nie siatka).
- **`PlateauPass._solve`** ~750 ms na 250×250 — kandydat na płaskie tablice; ocena 2026-10-21: zysk ≤ 0,5 s przy ryzyku regresji 42/42 — odpuścić.
- **Planer obiektów** ~95–110 ms (500 obiektów) / ~340 ms (pełny katalog jaskiń) na 250×250 — w wątku roboczym.
- **Kształtowanie masek terenu** ~130 ms na 250×250.

---

## Pułapki konfiguracji (działa zgodnie z założeniem, ale łatwo się naciąć)

- Wróg z przypisanym `enemy_data` bierze `detection_radius` z niego, nie z inspektora sceny.
- **Gęstość obiektu jest per obiekt, nie per grupa.** Warianty dawać jako listę scen w jednym obiekcie — nie osobne wpisy.
- **Gęstość = sztuk na 100 kratek-kandydatów;** kandydaci zależą od reguł (`terrain`, `context`).
- **Wtyczka Object Catalog Sync** nie usuwa wpisów po skasowanych scenach (robi to `tools/sync_object_catalogs.gd` z `REMOVE_MISSING = true`).
- **Skrypty używane w edytorze** muszą być `@tool`, jeśli mają `static var`.
- **Maski terenu liczone raz** (`GenerationResult.terrain_masks`) — inny seed kafli = inne maski niż widziały obiekty.
- **`plateau_smooth` = 2** wycina płaskowyże w wąskich korytarzach — zostaje 1.
- **W `.tscn` eksportowane właściwości skryptu muszą stać po linii `script =` węzła** — właściwości wcześniej są cicho ignorowane.
- **`sync_host_copies.gd` nadpisuje kopie w `_host/`** — sprawdzić `git status` przed commitem.
- **Tiery skrzyń, kluczy i łupu:** `chest_tier`, `chest_loot`, `enemy_loot` czytane z companion-JSON mapy; mapa bez `enemy_loot` używa starego losowania klucza tieru 1.

---

## Testy

- Lokalny zestaw ~100 skryptów `check_*` / `diag_*` w `tests/` (gitignorowane); `run_plateau_suite.sh` zielony (parytet ścian 42/42).
- Testy żyją tylko lokalnie — utrata katalogu = utrata zestawu i baseline'u.
- Baseline parytetu zależy od `objects_caves.json` — każda zmiana z kolizją zmienia pole `spawns` w digestach.
- `diag_enemy_chase.gd` część „tutorial_area" jest losowa — pojedynczy FAIL to jeszcze nie regresja.

---

## Potencjalne problemy (do obserwacji)

- **Tekst UI walki 36 px poza siatką Jersey 15** — czcionka ostra przy wielokrotnościach 27 px. User nie widział różnicy; jeśli nierówne litery: zmienić `QuizTheme.COMBAT_FONT_SIZE` na 27 lub 54.

---

## Mapy otwarte z uniwersalnego generatora (las zamiast ścian)

**Stan: NIE ZROBIONE** (lasy przez osobny `overworld_forest_generator.gd`).

Pomysł: ta sama topologia generatora, ale **teren na całej mapie** i **gęsto drzewa** tam, gdzie ściany. Klucz do decyzji projektowych:
- Kolizja z siatki (nie z drzew); drzewa tylko rysują.
- Pas brzegowy (1–3 kratki): drzewa jako obiekty z y-sortem.
- Głąb lasu: kafle wielokratkowe nachodzące na siebie (rozstaw < szerokość korony), y-sort.
- Ciemne podłoże pod lasem (szczeliny wyglądają jak cień).
- Wariacja: `texture_origin` w alternatywach kafli / osobny TileSet 8 px / drzewa `free` na brzegu.
- Autotiling ścian wyłączony — flaga stylu ścian `las` w `GenerationFlags` + JSON biomu.
- Do ustalenia: krawędzie płaskowyżów pod drzewami, wyjścia w lesie, przejście polana → las.
