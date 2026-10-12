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
6. **Balans i skalowanie walki (HP, ATK, DEF, TTK)** — specyfikacja i diagnoza w [balans_i_skalowanie.md](balans_i_skalowanie.md). Do wdrożenia w sesji z **Claude Opus**: rekalibracja mnożników w `QuizRpgSkillMath` (DEF ×1.8 zamiast ×2.0), korekta burst damage wczesnych skilli (Podwójny Rzut), rebalans statystyk przeciwników pod tiery stref i symulator TTK (`simulate_combat_balance.gd`).

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

## Stan na koniec sesji 2026-10-11 (przed compactem) — do podjęcia
- Niezacommitowane (nie z tej pracy, zostawione): `rat_base.tres` / `rat_base.tscn`, tła walki
  `battle_backgrounds/pixel_crawler/cave/Variant (6–8).jpg`.
- Ikony przedmiotów: duplikaty (`iron_buckler` = `steel_kite_shield`), mało różnych mikstur, akcesorium = pierścień;
  ikony w liście ekwipunku ekranu Status i w liście przedmiotów w walce.
- Backlog druzyna-balans S5–S7 (strojenie tierów 2–4, skille sojuszników / statusy FNaFB3, 3 niepodpięte skille wrogów);
  O1–O7 (skalowanie tierów, AGI, combo, poziomy skilli, towarzysze / sklep, klucze, tłumaczenia); potem miasto / hub.
- UI walki: user rozważa przewijaną listę zamiast siatki umiejętności.
- Testy lokalne: `diag_enemy_chase` (tutorial_area) niestabilny (200–750 / 3000 przy progu 600); wzorzec parytetu
  odświeżany przy zamierzonych zmianach generatora (`tests/parity_baseline.txt`).
- Szczegóły zmian sesji: walka.md, wrogowie.md, sciany_i_kafle.md, menu_i_opcje.md, ekran_ladowania.md (sekcje 2026-10-11),
  `docs/krytyczne_zawieszenia_klatek.md` (lag przy myszy — rozwiązany restartem edytora).
- **Poziomy wrogów i XP na 15 map (2026-10-12):** faza 1 zrobiona, faza 2 (statystyki z poziomu, krzywe do lv 100) do zrobienia — [poziomy_i_xp.md](poziomy_i_xp.md).

## Stan na koniec sesji 2026-10-12 (przed compactem) — do podjęcia
Zrobione w tej sesji (szczegóły: walka.md, wrogowie.md, obiekty.md, sciany_i_kafle.md, backlog_druzyna_balans.md, poziomy_i_xp.md, skille_i_pierwowzory.md):
boss w pokoju wyjścia z nawigacją; Area2D przejść za gradientem; odbicie wrogów od siebie (wałęsanie); ikony przedmiotów + ikony w listach; układ list
w walce (siatka 2 kol. / przewijana, opcja Motyw) i siatka celów bez HP; koniec freeze po ucieczce; łup z beczek jako toast bez pauzy, bogate beczki w
tutorialu; klucze uniwersalne + wytrychy (zamknięte skrzynie, quiz wg tieru); animacja wejścia do walki; okno komunikatów po walce na szerokość UI;
Skan (CC) bez zużycia tury; skille wrogów (Miażdżący Cios jak FNaFB 25000 / 16 %); strojenie tierów 2–4 (S5); poziomy wrogów + XP na 15 map
(MAX_LEVEL 100, LEVEL_CAP 20, HP lv20 1402 → lv100 50000, boss tier 4 + miniboksy tier 3 w jaskiniach, skala XP po rozmiarze mapy,
pokrętło xp_size_exponent = 1,0); log progresji do testów (`user://progress_log.txt`).
Do podjęcia:
- **Testy w grze z kolegami** (log progresji): poziom przy bossie jaskiń, liczba walk, odstępy między awansami; potem ewent. `KILL_FRACTION` (0,08)
  / `xp_size_exponent` (1,0 vs 0,75). 120 % to scenariusz kalkulacji, nie wymaganie.
- **Faza 2 poziomów (Opus):** statystyki wrogów z poziomu (generator .tres z krzywej), krzywe bohatera do lv 100 (ekwipunek ma być bardzo ważny),
  poziomy umiejętności rozciągnięte na 100, tiery przedmiotów na 15 map — poziomy_i_xp.md.
- **O2 (Opus):** unik / pudło / blok z AGI, kolejność tur — backlog_druzyna_balans.md.
- `scan_text` wrogów do uzupełnienia (Gemini; FNaFB CC ma 38 + 200 opisów).
- **Tajne wejście na zamek:** skille-klucze wybrane (docs/game_design.md): pustynia Rushdown, Forge Backup Bash, las / zima Rapid Flurry. Do zrobienia: blokada w mapie sprawdzająca `unlock_skill` (nie wymaga aktywnego slotu), segment 2D.
- **Poziomy umiejętności (faza 2, plan usera):** szansa Toxic Shock (`sound_wave`, trafia wszystkich wrogów niezależnie od quizu, `hit_ignores_quiz`) zależy tylko od poziomu skilla: lv 1 = 50 %, lv 2 = 65 %, lv max = 80 % (dziś stałe 50 %, `success_rate`). Hearty Meal leczy MAT × 4 (`heal_mat_coeff`), Revive 30 % maks. HP; Backup Bash ma `bonus_roll_max` / `bonus_roll_curve`.
- **Koszty, poziomy nauki i wartości umiejętności są tymczasowe** (decyzja usera 2026-10-12): przy docelowych 100 lvl będzie korekta (faza 2 poziomów). Dziś np. Death Enrage 450 SP przy ok. 446 SP bohatera na lv 20 jest nieużywalny — celowo nie poprawiane.
- S6: nazwy umiejętności z docx Gemini są w `resources/i18n/pl.json` / `en.json` (klucz `skill.<plik .tres>.name`, `QuizRpgI18n`, opcja „Język” w Motywie, domyślnie pl). Zostaje ocena wartości (koszty, mnożniki) i opisów (`description` jeszcze nietłumaczone), dalej: statusy, przedmioty, UI. Pozostałe: tier skrzyni z poziomu mapy (dziś ręcznie, domyślnie 1), animacja wyjścia z walki, ikony mikstur z innej paczki
  (user), ikona wytrycha (kandydaci: podglady_ui/wytrych_kandydaci.png, dziś item712), miasto / hub, `diag_enemy_chase` niestabilny.
- Do sprawdzenia w grze: boss w pokoju wyjścia chodzi?, przejście przy gradiencie, przewijanie długiej listy w walce, tutorial + jaskinie = lv 8–9?
- **Merge `druzyna-balans` do `main` (CienMgly) dopiero na koniec — na polecenie usera.**
