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

## Stan na koniec sesji 2026-10-12 (po drugim compactie) — do podjęcia

**Zrobione w tej sesji** (szczegóły: walka.md, wrogowie.md, obiekty.md, backlog_druzyna_balans.md, poziomy_i_xp.md, skille_i_pierwowzory.md, druzyna_szkic.md, sloty_umiejetnosci_szkic.md):
- Wcześniej: boss w pokoju wyjścia z nawigacją, przejścia za gradientem, odbicie wrogów, ikony, układ list w walce, koniec freeze po ucieczce, łup z beczek jako toast,
  klucze / wytrychy / zamknięte skrzynie, animacja wejścia do walki, Skan, S5, poziomy wrogów i XP na 15 map, log progresji.
- **Tier skrzyń z konfiguracji mapy** (`chest_tier` w JSON: jaskinie 1, ścieki 2) — dotyczy skrzyń z generatora, tutorialowe ręczne.
- **Animacja wyjścia z walki** (ta sama źrenica na zrzucie ekranu walki; nie przy śmierci drużyny).
- `tools/progress_summary.py` — log progresji w tabelę Markdown. `diag_enemy_chase`: próg „wiszą na ścianach” 33 % (wałęsanie losowe).
- **Tłumaczenia JSON:** `QuizRpgI18n` + `resources/i18n/pl.json|en.json`, opcja „Język” w opcjach (zakładka Ogólne, globalne ustawienie hosta). Nazwy i opisy 44 skilli, nazwy i opisy 18 statusów (wszystko podpięte do kodu);
  opisy skilli wrogów z perspektywy gracza, `scan_text` 50 wrogów — zrobione przez Gemini, sprawdzone.
- **S6 zastosowane:** koszty z docx; Mocny Atak 50 SP + 25 TP; Death Enrage = ult wysokiego tieru (450 SP, 100 TP, flaga `combo` usunięta); Toxic Shock na wszystkich wrogów 50 % bez quizu
  (`hit_ignores_quiz`); Hearty Meal leczy MAT × 4 (65 SP); Revive 30 % maks. HP; Backup Bash z losowym bonusem w górę (`bonus_roll_max` / `bonus_roll_curve`);
  Fearless Flight ×0,6 i MDF×1; Shrapnel Toss ×0,5. Wartości tymczasowe (korekta przy 100 lvl).
- **Faza 2, krok 1:** `QuizRpgEnemyStats` — statystyki wrogów z poziomu (proporcje walki dla bohatera wzorcowego z ekwipunkiem idącym po krzywej: broń 10 → 320, pancerz 14 → 194).
  **Naprawiony błąd fazy 1:** poziom / XP z mapy był nadpisywany w `_ready` (wrogowie z `enemy_data`), teraz zapamiętany i nakładany po wczytaniu danych.
- **HP i SP jedną gładką krzywą** (`QuizRpgHeroData.curve_value`; HP: lv 1 334, lv 20 1402, lv 100 50 000; SP dziś liniowo 139 → 446 → 1739).
- Design: skille-klucze tajnego wejścia na zamek (Rushdown / Backup Bash / Rapid Flurry), szkic slotów umiejętności wg tierów, szkic drużyny (klasy, rekrutacja).

**Decyzje usera, których nie ma gdzie indziej:**
- Sloty umiejętności: 4 tiery na razie (tier 9 = arcymag z true endingu); poziom skilla = tier slotu; tier startowy skilla jest dolną granicą; wspólny budżet jednostek (T1 1, T2 2, T3 3, T4 5 — propozycja);
  Skan i tryb combo poza budżetem; combo = osobny tryb po 100 TP (serie skilli za SP, bez skilli TP), odblokowywany warunkami (drop / maks. skille / specjalny przeciwnik), nigdy z poziomu ani od NPC;
  akcesoria zmieniają liczbę slotów; blokady zamku liczą znajomość skilla, nie slot.
- Drużyna: role z klas (`klasy_postaci_i_bronie.md`: Wojownik, Łotrzyk, Mag, Kapłan), dołączanie po zadaniu od postaci, wstępnie 3 towarzyszy (propozycja: Łotrzyk, Mag, Kapłan); każdy ma własną pulę XP i poziom,
  dostaje pełne XP jak we FNaFB, martwy 50 %; cała drużyna w walce, bez limitu (rezerwa później); bez premii nadrabiania; poziom odniesienia = najwyższy w drużynie; poziom wroga z mapy, nie z gracza.
- Blok bohatera (O2) = 100 % uniku z AGI. Proste zadania (tekst, dane, tłumaczenia) kierować do Antigravity / Gemini (brief w `zadania_dla_antigravity.md`); zrobić Gemini subagentem można tylko przez Gemini CLI (nie zainstalowany).
- Koszty, poziomy nauki i wartości skilli są tymczasowe (Death Enrage 450 SP przy ok. 446 SP na lv 20 jest dziś nieużywalny — celowo).

**Do podjęcia:**
- **Faza 2, krok 2 (Opus / ja):** krzywe bohatera do lv 100 i tiery przedmiotów na 15 map (parametry ekwipunku wzorcowego `GEAR_*` w `enemy_stats.gd` zaakceptowane na razie), poziomy umiejętności (szansa Toxic Shock 50 / 65 / 80 %), sloty tierów, skille z dużą stałą bazą (np. +200 w Relentless Assault) nie skalują się z poziomem.
- **Drużyna (druga połowa gałęzi):** (pole `character_class` i `allowed_classes` zrobione 2026-10-12), rekrutacja, osobne XP członków, zadania towarzyszy, skille klasowe (Mag i Łotrzyk mają za mało), imiona i fabuła — `druzyna_szkic.md`, sekcja „Do uzgodnienia”.
- **O2 (Opus):** unik / pudło / blok z AGI, kolejność tur. **Tryb combo** do zaprojektowania.
- **Testy w grze z kolegami** (log progresji + `progress_summary.py`): poziom przy bossie jaskiń, liczba walk, odstępy między awansami; ewent. `KILL_FRACTION` (0,08) / `xp_size_exponent`. Od zmiany statystyk wrogów z poziomu trzeba też ocenić trudność jaskiń (boss lv 9: HP 1555, ATK 48).
- Dla Gemini (opcjonalnie): teksty logu wrogów `skill.<plik>.log` (kod gotowy, brief `i18n_log_wrogow_dla_gemini.md`), skille klasowe wg briefu.
- Drobne: ikony mikstur (user, z innej paczki), ikona wytrycha zostaje item712, miasto / hub, tajne wejście na zamek (blokada w mapie, segment 2D).
- Do sprawdzenia w grze: boss w pokoju wyjścia chodzi?, przejście przy gradiencie, przewijanie długiej listy w walce, animacja wyjścia z walki, tutorial + jaskinie = lv 8–9?
- **Merge `druzyna-balans` do `main` (CienMgly) dopiero na koniec — na polecenie usera.**

## Sesja 2026-10-12 (część 3): ekwipunek, złoto, klucze — stan i do podjęcia

Szkic i decyzje: `ekwipunek_szkic.md` (sekcje 8–11), obiekty: `obiekty.md`.

**Zrobione (prototyp w jaskiniach):** klasy postaci (`character_class`, `allowed_classes`); złoto (`PlayerStats.gold`, złoto z wrogów od tutorialu, wpis w logu); tabele łupu z JSON mapy (`chest_loot`, `enemy_loot`) w jaskiniach i ściekach;
beczki z wzorem 3/(2n) (1. przedmiot gwarantowany); klucze na tier skrzyni (brązowy / srebrny / szafirowy / złoty = uniwersalny) i wygląd skrzyń wg tieru; język i „Gra bez quizów” w zakładce „Ogólne” opcji.

**Decyzje usera (część 3):** sklepy po odblokowaniu miasta (wyjście z jaskiń), tiery sprzętu w sklepie blokowane flagami fabularnymi (kowal „nie pamięta”); w jaskiniach sprzęt z dropów wrogów i skrzyń / nisz; złoto od tutorialu;
większość złota idzie na mikstury HP / SP (stałe wartości, nie %; walka z 2 wrogami ≈ 70 % HP); rzadki drop = broń z potencjałem, moc początkowa ≤ mapa + 2, rozwój u kowala; beczki: 1. przedmiot pewny, kolejne wg 3/(2n).

**Do podjęcia (ekwipunek i skrzynie):**
- **Skrzynie specjalne w rzadkich pomieszczeniach / niszach** (pomysł usera; **nie dodane**): rzadkie pokoje z wyższym tierem skrzyni (np. 3–4, wygląd złoty / niebieski, ewent. skrzynia z czaszką z arkusza „RPG Chests” kolumna 8 jako przeklęta), z lepszym łupem
  (sprzęt tieru 2, później broń z potencjałem). Wymaga: znacznika „rzadki pokój / nisza” w generatorze obiektów (dziś skrzynie tylko preferują nisze, `objects_caves.json`), osobnego `chest_tier` / tabeli łupu dla takiej skrzyni, ewent. wymogu klucza wyższego tieru.
- Sklep i interfejs zakupu (po mieście; do czasu miasta w menu deweloperskim), tiery sklepu z flagami fabularnymi (`LevelStateManager.register_device_progress`), ceny w „zabiciach” (pełne leczenie ≈ 1,2–1,3 × złoto z wroga).
- Mikstury w kolejnych tierach ze stałymi wartościami (tabela w `ekwipunek_szkic.md`, sekcja 9) i ich ikony (user); więcej mikstur w jaskiniach (beczki, skrzynie, wrogowie) po teście w grze.
- Bronie z potencjałem: etapy jako osobne `item_id`, `upgrade_to`, flagi i koszt ulepszeń u kowala, pole `budget_map` + test limitu mapa + 2; sekretne bronie ponad budżet (osobna decyzja); skala drabiny sprzętu przy 100 poziomach (pułap sklepu ≈ 600 ATK / zmniejszenie wzrostu z poziomu / bez zmian) — pytanie otwarte w szkicu.
- Poprawka: pancerz prawie nie wpływa na przeżywalność późno (cios wroga liczony z ułamka HP) — przejrzeć definicję w `enemy_stats.gd` niezależnie od reszty.
- Optymalizacja ekwipunku (`optimize_member_equipment`) liczy tylko ATK + DEF (pomija MAT / MDF i efekty).
- Ewent.: osobne warianty skrzyń z innych paczek (zielona, czerwona, ozdobna z „RPG Chests”; `All Chest Sheet.png` 16×16; pustynia `Props.png`).
- Sprawdzić w grze: czterokrotnie większy łup z beczek (średnio ≈ 2,3 losowania zamiast 0,45), wygląd skrzyń wg tieru i koszt walki (≈ 70 % HP) w jaskiniach.

**Dopisek na koniec sesji 2026-10-12 (po części 3):**
- **Zrobione dodatkowo:** narzędzia deweloperskie tylko w buildzie debugowym i **tylko klawisze F** (F9 / F10 / F11, F1 / `~`; litery K / O / P usunięte — decyzja usera); walka ignoruje mysz bez fokusu okna i klik odzyskujący fokus (300 ms po `FOCUS_IN`);
  przegląd i aktualizacja stanów w `docs/znane_problemy.md` (linie `Stan 2026-10-12` przy punktach).
- **Czeka na Gemini:** brief `porzadkowanie_docs_dla_gemini.md` (zadanie E w `zadania_dla_antigravity.md`): uporządkowanie `docs/` — `znane_problemy.md` = jedyne źródło todo i problemów (hook czyta nagłówki `### ⚠ WAŻNE:`), `otwarte.md` = tylko handoff,
  indeksy `docs/README.md` i `kontekst/README.md`, `docs/archiwum/`, statusy planów, raport. Po oddaniu: sprawdzić hook (`sh .claude/hooks/przypomnienia.sh`), linki, `git diff --stat`, potem commit. Zadanie D: teksty logu wrogów (`i18n_log_wrogow_dla_gemini.md`).
- **Najbliższe kroki (Claude):** po resecie limitu — krzywe XP i bohatera do lv 100 oraz skala drabiny sprzętu (pytanie otwarte w `ekwipunek_szkic.md`, sekcja 11: pułap sklepu ≈ 600 ATK / mniejszy wzrost z poziomu / bez zmian), potem sklep i tiery z flagami fabularnymi, mikstury w tierach (stałe wartości), bronie z potencjałem i kowal, rekrutacja towarzyszy.
- **Do sprawdzenia przez usera w grze:** wygląd skrzyń i klucze na tier, beczki 3 / (2n), złoto, koszt walki w jaskiniach (≈ 70 % HP na parę wrogów), zakładka „Ogólne” w opcjach, klik po odzyskaniu fokusu, build wydaniowy bez narzędzi deweloperskich.
- **Repo:** host `main` i submoduł `modules/quiz_rpg` (CienMgly, gałąź `druzyna-balans`) czyste i wypchnięte; merge `druzyna-balans` do `main` dopiero na polecenie usera.
