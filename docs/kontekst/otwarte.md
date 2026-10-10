# Otwarte sprawy

Trzy ważne todo (2026-10-04 / 2026-10-06; opis i przypomnienie hookiem — `docs/znane_problemy.md`):
0. **#1 NAJWAŻNIEJSZE (2026-10-09): ekran śmierci drużyny** — dziś przegrana kończy się komunikatem
   „Porażka...”, a gracz chodzi dalej z 0 HP. Opis: `docs/znane_problemy.md` „(#1)”.
1. **Ścieki (sewer)**:
   - ~~**Kładki na osobnej warstwie**, **ciągłość opuszczonej krawędzi**, **Faza F2 (barierki, pits, 100% determinizm)**~~ — zrobione 2026-10-05.
   - ~~**Korytarze serwisowe, separacja ścianą, A* Manhattan, blokada kładek na zakrętach**~~ — zrobione technicznie 2026-10-06 (commit `cbe4b35`).
   - **Odłożone do sesji z Claude Opus:** Dopracowanie układu przestrzennego korytarzy wzdłuż koryt ścieków (oddzielenie ścianą, omijanie zakrętów).
   - **Paczka Sewer v2** (2026-10-08, `sewer-structured`): ściany z cieniem, kanał, barierki, obiekty i filary
     przeniesione; następne: lico drewniane między filarami, ściana szer. 1, krawężniki, platformy — lista w
     [scieki.md](scieki.md) („Paczka Sewer v2”). Gra dalej na v1.
2. **Generator obiektów** — dokończyć fazę F5 (niszczalne obiekty, dźwignie, podgląd).
3. ~~**Tła walki 16:9** — wyświetlanie na pełny ekran (1920×1080) w `folder_battle_background.gd`, przezroczysty pas dolny w `quiz_combat_ui.tscn` i podgląd 16:9~~ — zrobione 2026-10-06 (commit `deb8866`).
4. **Grywalne postacie — teammate'owie, klasy i 16 broni per strefa** — specyfikacja w [klasy_postaci_i_bronie.md](klasy_postaci_i_bronie.md). Do wdrożenia w kodzie przez **Claude Opus**: pole `character_class` w `HeroData`, `allowed_classes` w `ItemData`, podział `PlayerStats` na aktywną drużynę (max 4) i rezerwę (`reserve_party`), orszak followerów w `player.gd`, ekran zarządzania składem. Gemini przygotowuje zasoby `.tres` broni i wycięte ikony.
5. **Miasto z modularnych zasobów paczki free**.
6. **Balans i skalowanie walki (HP, ATK, DEF, TTK)** — specyfikacja i diagnoza w [balans_i_skalowanie.md](balans_i_skalowanie.md). Do wdrożenia w sesji z **Claude Opus**: rekalibracja mnożników w `QuizRpgSkillMath` (DEF ×1.8 zamiast ×2.0), korekta burst damage wczesnych skilli (Rzut Cylindrem), rebalans statystyk przeciwników pod tiery stref i symulator TTK (`simulate_combat_balance.gd`).

- Do sprawdzenia przez usera w grze (2026-10-04): przejścia z odsuniętymi spawnami (samouczek <-> jaskinia),
  bieg / chód (opcje w Sterowaniu), okno zmaksymalizowane / bez ramki / ręczny rozmiar, menu deweloperskie
  w różnych skalach UI.
- Niescommitowane zmiany usera (nie ruszać): `window/size/mode=2` w `project.godot` hosta,
  `scenes/player/player.tscn` w CienMgly.
- **Feature — ukryte przejścia między pokojami** (tunel pod voidem) — `docs/znane_problemy.md`.

- **Tła walki 16:9** — kod gotowy ([walka.md](walka.md)). User generuje kolejne grafiki wg promptów
  (`battle_backgrounds/*_prompts.md`, `correction_prompts.md`) i dopasowuje pola w edytorze `battle_layout_preview.tscn`.
- **Tekst walki 36 px** — obserwować, czy litery nie wychodzą nierówne (`docs/znane_problemy.md`).
- Do sprawdzenia przez usera w grze: motywy / style pasków w menu Esc, tryb „UI walki na szerokość
  treści”, muzyka menu po wyjściu z gry.

- **Edytor pytań — zrobiony** (menu główne -> Pytania, Opcje -> Pytania; `docs/kontekst/pytania.md`). Do
  sprawdzenia przez usera w grze: okna plików (import / eksport), przeciąganie pliku na okno.
- **Nisze-przejścia** (ściana o głębokości 3 nad niszą): generator gotowy, kafle OUT z szerszym otworem
  (alternatywa 1) są — **user robi wariant kafli RIM z innymi kolizjami jako alternatywę 1** (te same id
  kafli co zwykły szczyt); bez niego szczyt nad przejściem blokuje. Opis w [sciany_i_kafle.md](sciany_i_kafle.md).
  Przejść jest mało (geometria: na 6 mapach 2 miejsca) — user chce częściej; do ustalenia, jak (np. ścianka
  o głębokości 3 za niszą wycinana celowo).
- **Tryb walki**: ~~okna Umiejętności / Przedmioty w stylu RPG Makera~~ — zrealizowane w modelu danych i UI (patrz [walka.md](walka.md)), gotowe zasoby skilli gracza i wrogów, statusy i przedmioty. Pozostało dopracowanie logiki losowych spotkań w terenie wg `docs/znane_problemy.md`.
- **Każda nisza out z losową zawartością, sekretne pokoje, klucze i wytrychy (quiz wg tieru skrzyni)** — pomysł
  usera, opis w `docs/znane_problemy.md` („Do zrobienia”).
- **Obiekty**: obejrzeć w eksploratorze map, czy duże grzyby nie są za rzadkie przy ścianach
  (ew. gęstość w `objects_caves.json`).
- **Wypustki**: gdy nie da się podnieść, są usuwane — na razie nie wystąpiło; jeśli user woli usuwanie
  zamiast podnoszenia, zmiana w `ShortLedgeRaisePass`.
- **Drzwi z zagadką** (`scripts/quiz/quiz_door.gd`, tylko na starej `world_map.tscn`): zostają (decyzja usera
  2026-10-04) — do ewentualnego recyklingu, np. jako sekcja quizu przy otwieraniu skrzyni wytrychem.
- `docs/znane_problemy.md` — reszta zgłoszeń i historia rozwiązanych.
