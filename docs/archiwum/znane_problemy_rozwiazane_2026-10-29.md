# Znane problemy — wpisy ZROBIONE / Rozwiązane (przeniesione 2026-10-29)

> Źródło: `docs/znane_problemy.md`. Przeniesione, żeby skrócić plik roboczy do otwartych spraw.

---

## Sekcja „Rozwiązane" (stan 2026-10-12 i wcześniej)

- **Przeniesione z „Do zrobienia" 2026-10-21 (szczegóły w kontekst/ i commitach):**
  - Przyspieszenie generowania (#1): zrobione, dalszy zysk wymagałby C# / GDExtension — `archiwum/plan_przyspieszenie_generowania.md`, `archiwum/plan_zapis_map.md`.
  - Generator obiektów F5 (dźwignie, beczki, nakładka podglądu): `kontekst/obiekty.md`, `plan_generator_obiektow.md`.
  - Tła walki 16:9: kod gotowy (2026-10-06); grafiki generuje user, wpis wygaszony (decyzja usera).
  - Teammate'owie (4): rekrutacja, skille klasowe, sloty umiejętności, imiona Kael / Eldon / Selene — `kontekst/druzyna_szkic.md`, `sloty_umiejetnosci_szkic.md`.
  - NPC (6): sklep, nauczyciel, odpoczynek, kowal, rozmowa — `kontekst/npc.md`.
  - Beczki scale / k (7): CienMgly ae73bfe6.
  - Tłumaczenia JSON: `I18nService` + słowniki, `archiwum/i18n_calosc_raport.md`.
  - Optymalizacja ekwipunku członków (MAT / MDF / AGI wg klasy): `_equipment_score` w `player_stats.gd`.
  - Spójna ścieżka między mapami: CienMgly 833d7c0c, `scripts/maps/map_links.gd`.
- **Ekwipunek, złoto i klucze — prototyp w jaskiniach** (2026-10-12, CienMgly): klasy postaci, złoto, tabele łupu z JSON, beczki 3/(2n), klucze na tier, wygląd skrzyń. Szczegóły: `kontekst/ekwipunek_szkic.md`.
- **Tłumaczenia JSON, statystyki wrogów z poziomu, krzywa HP/SP, log progresji, animacja wyjścia z walki, opcje Ogólne** (2026-10-11/12): `kontekst/otwarte.md`, `poziomy_i_xp.md`, `walka.md`.
- **Kładki na osobnej warstwie i ciągłość lica uskoku (ścieki)** (2026-10-05, CienMgly): `BRIDGE_V`/`BRIDGE_H` na warstwie `Bridges`; `_is_face` uniezależnione od sąsiada N — 100% ciągłości `CANAL_FACE`.
- **Mapy jako sceny dziedziczone + seed per zapis + powrót do poprzedniego poziomu** (2026-10-03, CienMgly): `procedural_level.tscn`, `LevelStateManager.world_seed`, `level_portal.gd`.
- **Punkty pojawienia się odsunięte od przejść** (2026-10-04, CienMgly 99b3cd4): `MapGeneratorBase.arrival_cell`, `diag_arrival_cells`.
- **Przejścia pod E** (2026-10-04): `portal_use_key` / `portal_prompt` per przejście w metadanych Area2D.
- **Zmiana klawiszy (rebind) per moduł** (2026-10-03): zakładka „Sterowanie", `InputBinds`, `SettingsService`.
- **Wymuszone 2H zamiast 3H** (2026-10-03): `EdgeAnalyzer.slope_2h_run` (CienMgly b9b0cae) + `SlopeThicknessPass` (P11a).
- **Cień Mgły samodzielny i jako submoduł** (2026-10-03): `QuizRpgPaths`, `_host/`, `tools/make_standalone.sh`, git subtree → repo CienMgly.
- Flagi `room_shape` i `entrance_mode` (2026-10-04): `RoomCarverFactory` z wariantami rect/round/mixed, `entrance_mode: center` dla ścieków.
- Etap `entities` / ostrzeżenie „re-save" przy `slime_tutorial` (2026-10-04): zapisane ponownie (028bafc, c205e80).
- Kolizje wrogów w `tutorial_area.tscn` (2026-10-04): nadpisania `collision_mask` usunięte (c205e80).
- Nisze przy ścianie głębokości 3 (2026-10-03): nisza OUT bez korony, szansa `passage_niche_spawn_chance`.
- Ostrzeżenia „invalid UID" (2026-10-03, e37c940): 293 odwołania poprawione.
- Sterowanie per moduł (2026-10-02, ba3d490): sekcje z `module_manifest.json`.
- Opcje w menu Quiz RPG (2026-10-02, 888d682).
- Edytor pytań (2026-10-02): zestawy, 5 typów pytań, `question_bank.gd`.
- UI walki WYSIWYG (2026-09-30): `quiz_combat_ui.tscn`, motyw `quiz_theme.tres`, `BattleBackgroundLayout`.
- Freeze po pokonaniu potwora (2026-09-30, aa8d686): 5 s nietykalności, XP raz.
- Spłaszczanie wybrzuszeń (`ShortBulgeFlattenPass`) usunięte (decyzja usera, 2026-09-29).
- Wąskie wypustki 2H przy licu 3H+ — `ShortLedgeRaisePass`.
- Małe przekrzywione filary — `EdgeAnalyzer.small_wall_islands` / `_skewed`, `force_2h_cells`.
- Fasada płaskowyżu tuż za ścianą — `PlateauRenderer._on_wall_top`.
- Zasięg wykrywania wroga współdzielony przez instancje — `resource_local_to_scene` + setter `detection_radius`.
- Nawigacja wrogów — `NavOutlines` (b4bb991, 0785ade).
- Wróg widział przez ściany — linia po siatce (e4192f9), `analiza_ai_przeciwnikow.md`.
- Pojedyncze kratki błota i trawy — `TerrainMaskPlanner`, test `diag_terrain_masks.gd`.
- Twarde cięcia krawędzi błota/trawy — `TerrainAutotileSolver` (2524d2b).
- Losowy seed dawał inny seed kafli — wspólny `result.seed_used`.
- Narzędzie katalogu: niezainicjalizowane mutexy (4cc579f).
- Freeze świata po ucieczce/porażce (2026-10-11): `EnemyBase.on_combat_finished` od razu zmienia stan.

---

## Wpisy ZROBIONE wyciągnięte z sekcji „Do zrobienia"

### (#2) ekran śmierci drużyny i trucizna — ZROBIONE
Stan 2026-10-15: user sprawdził w grze i zgłosił poprawki; zostało tylko sprawdzenie samych poprawek.
Stan 2026-10-12: `scenes/ui/death_screen.tscn`, przyciski „Wczytaj zapis" / „Menu główne"; trucizna DoT co 3 s, 1 HP, do 1 HP; odtrutka przez `cure_statuses`. Commity CienMgły 6482268, 9a6a049. Pełna ścieżka (przegrana → ekran) nie była przechodzona w grze — do potwierdzenia przez usera.

### (1a) przebudowa generowania ścieków — ZROBIONE (main 2026-10-09/10)
Układ `structured` (R1–R7, port prototypu v11) na main; platformy (PR #1); `sewer-gen-v2` porzucona.
Zostaje na później: schody N/E/W, rury, winiety i gruz skupiskami, mniej zdejmowania na 250².

### Tryb walki — interfejs ZROBIONY
Styl RPG Makera, WYSIWYG; siatka 2 kolumn z ikonami; wybór celu; animacje wejścia/wyjścia. Listy Umiejętności / Przedmioty przerobione 2026-10-11. DO SPRAWDZENIA W GRZE: typy pytań bossów, przewijanie listy.

### Feedback — większość punktów ZROBIONA
1. Skróty F i blokada w wydaniu (`OS.is_debug_build()`) — ZROBIONE 2026-10-12.
2. Układ ekranu pytania — ZROBIONE (opcja motywu).
3. Klik wroga — NAPRAWIONE 2026-10-21 (`_enemy_slot_at`).
6. Klik po odzyskaniu fokusu — ZROBIONE 2026-10-12 (`FOCUS_OUT` + 300 ms blokada).

### Losowe spotkania jak w JRPG — ZROBIONE 2026-10-21
`QuizRpgRandomEncounters`, klucz `random_encounters` w JSON mapy; jaskinie: tryb `cleared`; ścieki: `always`. Zostało: strojenie dystansu w grze, strefy bez spotkań.

### Minimapa z fog of war — ZROBIONE 2026-10-21
`QuizRpgMinimapData`, maska DEFLATE+base64, promień 12 kratek, linia wzroku Bresenhama, Bresenham. Kolory z kafli, znaczniki, opcja w Sterowanie, dane z warstw 3,5× szybciej. Budowa danych pod ekranem ładowania. Zostało: ikonka gracza.

### Zduplikowany UID ikony BitBombera — ZROBIONE 2026-10-21
`BitBomber/icon.png.import` ma własny UID.

### Umiejętności wrogów skalowane z poziomu — ZROBIONE 2026-10-21
Obrażenia z ATK/MAT (skaluje się z poziomem); Mroczna Regeneracja 25 % maks. HP.

### Resztki i18n — ZROBIONE 2026-10-21
Etapy generowania doszły (`gen.stage.*`); zostają tylko narzędzia i komunikaty debug.

### Zapis map na dysk — ZROBIONE 2026-10-22
`map_disk_cache.gd`; ≈ 0,25 s zamiast 2–2,5 s; zapis z wyprzedzeniem; kasowanie przy rerollu.
