# Znane problemy i rzeczy odłożone (quiz_rpg — generator jaskiń)

> Spisane 2026-09-25. Każdy punkt: co jest nie tak, dlaczego zostało jak jest, kiedy do tego wrócić.
> Po naprawie punkt usuwamy albo przenosimy do „Rozwiązane” z numerem commita.
> **Przegląd stanu 2026-10-12:** przy każdym punkcie jest linia „Stan 2026-10-12” (ZROBIONE / W TOKU / NIE ZROBIONE / DO SPRAWDZENIA W GRZE / CZEKA NA USERA), sprawdzona w kodzie i dokumentach.

## Odłożone świadomie

(brak)

## Do zrobienia (zgłoszone, następnym razem)

### (#2) ekran śmierci drużyny i trucizna — ZROBIONE, poprawki po teście usera do sprawdzenia
- **Stan 2026-10-15:** user sprawdził w grze i zgłosił poprawki; zostało tylko sprawdzenie samych poprawek. Znacznik ⚠ zdjęty (decyzja usera).
- **Stan 2026-10-12: ZROBIONE, DO SPRAWDZENIA W GRZE.** Scena `scenes/ui/death_screen.tscn` (WYSIWYG) pokazywana z `QuizCombatController`, gdy po przegranej walce `PlayerStats.is_party_defeated()`; przyciski „Wczytaj zapis” / „Menu główne”. Trucizna w świecie (DoT co `POISON_WORLD_INTERVAL` 3 s, 1 HP, do 1 HP) i w walce (5 % maks. HP na rundę), odtrutka przez `cure_statuses`; źródło trucizny = umiejętność wroga (`QuizRpgEnemySkill`). Commity CienMgly 6482268, 9a6a049; testy lokalne `check_death_screen`, `check_poison`. Pełna ścieżka (przegrana → ekran, zatrucie w walce) nie była przechodzona w grze — po potwierdzeniu przez usera usunąć ten wpis i znacznik ⚠.
- Zgłoszenie usera 2026-10-09: „najbardziej podstawowa funkcja gry” — **priorytet #1, przed wszystkimi innymi
  ważnymi todo**.
- Stan sprzed 2026-10-09 (nieaktualny, zostawione jako opis problemu): przegrana walka (`QuizCombatController._end_combat(false)`, gdy `PlayerStats.is_alive()` == false)
  pokazuje tylko komunikat „Porażka...”, wróg wraca do patrolu, a gracz chodzi dalej z 0 HP — śmierć nie ma skutków.
  Pułapki poza walką (kolce, `PlayerStats.damage_party_percent`) celowo nie zabijają (HP min. 1).
- Decyzje usera (2026-10-09):
  - śmierć = **wszyscy członkowie drużyny mają 0 HP** (nie sam lider);
  - ekran: dwa przyciski **„Menu główne”** i **„Wczytaj zapis”** (wariant prostszy: od razu powrót do menu
    głównego, gracz wczytuje zapis stamtąd);
  - postęp (otwarte skrzynie, pokonani bossowie, seed zapisu) powinien być już zapisywany — **sprawdzić**, że tak
    jest ([game_design.md](game_design.md));
  - pułapki poza walką (kolce) **nie zabijają** — zbijają HP do 1 (`PlayerStats.damage_party_percent`).
- Powiązane — **trucizna w świecie**: postać, która w walce dostała efekt trucizny, traci HP także w eksploracji
  (DoT), dopóki nie użyje się przedmiotu leczącego statusy. Do ustalenia: tempo DoT i czy może zabić (jak pułapki —
  do 1 HP?). Wymaga przeniesienia statusów z walki do stanu drużyny (`PlayerStats.party`).

### (1) tilesety kolejnych map — ścieki zrobione, kolejne mapy po stronie autora
- **Stan 2026-10-17: ODŁOŻONE POZA INŻYNIERKĘ (decyzja usera)** — na teraz zostaje tylko miasto (punkt (5) niżej); tilesety kolejnych map
  (Cemetery, Fairy Forest itd.) później albo na osobnym branchu.
- **Stan 2026-10-12: CZEKA NA USERA** — ścieki ZROBIONE (na `main`), kolejne tilesety po stronie usera. Ścieki: gałąź `sewer-structured` zmergowana 2026-10-09 (CienMgly 9e901a4, host d5a9cfa), platformy PR #1 2026-10-10; mapa `levels/sewer.tscn` podpięta po jaskini (tymczasowo — docelowo jaskinia → miasto → ścieki). W repo są paczki Pixel Crawler: cave, castle, desert, forge, garden, library, sewer (+ sewer_old); brak tilesetów i konfiguracji dla Cemetery, Fairy Forest, Desert / Desert Temple, Forge, Dense Forest / zima, Library, Garden, Castle.
- Zgłoszenie 2026-10-03, priorytet z 2026-10-04: **pierwsze z trzech ważnych todo, przede wszystkim ścieki
  (sewer)**. Kolejność map w grze: jaskinia -> miasto -> ścieki; w ściekach przejście raczej drabiną, pod E
  (`next/previous_portal_use_key` + `_prompt` w scenie dziedziczonej po `procedural_level`).
- **Do zrobienia przez autora:** tilesety (TileSet `.tres` + companion-JSON zachowania
  w `resources/maps/config/`, jak `caves.tres` / `caves.json`) dla kolejnych map z generatora.
- Są: jaskinie (`resources/maps/caves.tres`), ścieki (`resources/maps/sewer.tres`, `config/sewer.json` — na razie
  z profilem kafli jaskiń). Kolejne wg kolejności stref (`docs/game_design.md`): Cemetery, Fairy Forest
  (las — por. wpis „Mapy otwarte z uniwersalnego generatora”), Desert / Desert Temple, Volcano / Forge,
  Dense Forest / biom zimowy, Library, Garden, Castle.
- **Stan 2026-10-04:** ścieki w toku na gałęzi `sewer-tileset` (CienMgly) — tileset, profil, układ, ściany 3H/4H,
  podłoga z terenu, kanały z kładkami; szczegóły i lista flag: [kontekst/scieki.md](kontekst/scieki.md).
- Przypomnienie na start sesji (hook) znika, gdy ten nagłówek zniknie albo straci znacznik „⚠ WAŻNE”.

### (1a) przebudowa generowania ścieków — ZROBIONE (main 2026-10-09 / 10), szczegóły do dopracowania
- **Stan 2026-10-12: ZROBIONE.** Układ `structured` (R1–R7, port prototypu v11) na `main`; platformy (PR #1); `sewer-gen-v2` porzucona. Zostaje na później (wg `kontekst/scieki.md` i pamięci): schody N/E/W i rury (po stronie usera), winiety z biblioteki i gruz skupiskami, mniej zdejmowania obiektów na 250², miasto między jaskinią a ściekami. Znacznik ⚠ zdjęty — przypomnienie na start sesji dla tego punktu wygasa.
- **Plan:** [plan_generator_sciekow.md](plan_generator_sciekow.md) (układ ogólny `structured`, ścieki = pierwsza
  konfiguracja; reguły R1–R7 z prototypu `docs/prototypy/structured_layout/`; ocena gałęzi `sewer-gen-v2` *(usunięte 2026-10-16 — w historii gita, commit sprzed usunięcia: `git log -- docs/prototypy`)*
  2026-10-07: korytarze serwisowe niezgodne, regresja ścian jaskini — nie mergować).
- Zgłoszenie 2026-10-05. Autor chce przerobić generowanie ścieków w osobnej sesji z **dużo wyższym effort**
  (max lub podobnym), z **MCP Godota** (autor go dodaje — podgląd sceny / gry zamiast samych renderów headless).
- Obecny wynik (eksplorator, seed 119, 160×160) jest pusty w porównaniu z makietami autora paczki
  (`sewer/Social/MockUp-01`, `MockUp-02`; warstwy podejrzysz w Eksploratorze Aseprite). Różnice zauważone
  przy porównaniu:
  - lico: makiety dzielą długie ściany **filarami** (Tiles 7, 3–6) z łańcuchem / lampą na filarze, łuki
    odpływów między filarami, pionowe rury z lica na posadzkę (Tiles 6–8 × 8–9), rura przy ścianie bocznej;
  - kanały: **barierki** wzdłuż brzegu (Props 6–9 × 4, przerwa i zagięte końce przy kładce), zakręty L i T,
    kanał wzdłuż ściany (brzeg tylko z jednej strony), szersza sieć; puste koryto już jest (`canal_dry_chance`);
  - posadzka: ciemniejsze plamy (teren `dark_floor`), **mech** (teren `foliage`) w kątach i przy ścianach,
    rzędy otworów 2 × N, gruz w małych skupiskach;
  - rekwizyty w kompozycjach: stół + krzesła + regał / schody (Props 0–1 × 6–8) przy ścianie, stosy skrzynek
    2 × 2, grupy beczek, skrzynia ścieków (Props 8–9 × 2–3) i otwarta (8–9 × 0–1); dzbany / worki z makiety
    nie występują w atlasach paczki;
  - skala: makieta 25 × 25 kratek mieści kilka pokoi i kanały, u nas sale 16–28 kratek są puste.
- Stan wyjściowy i flagi: [kontekst/scieki.md](kontekst/scieki.md), obiekty: [kontekst/obiekty.md](kontekst/obiekty.md).
- **Aktualizacja 2026-10-06:** wdrożono technicznie korytarze serwisowe z bramami (`proto_layout10.py`), separację ścianą, A* Manhattan i blokadę kładek na zakrętach (commit `cbe4b35`). Dopracowanie układu przestrzennego i mentalnego korytarzy wzdłuż koryt odłożone do kolejnej sesji z Claude Opus.
- **Aktualizacja 2026-10-08:** `sewer-gen-v2` porzucona; nowa gałąź **`sewer-structured`** (CienMgly, z `sewer-tileset`
  + main + F0b/F1a/F1b z v2) — port prototypu v11 i strojenie układu z autorem (stan w pamięci / commitach gałęzi).
- **Potencjalny problem (DO SPRAWDZENIA W GRZE, stan 2026-10-12 bez zmian):** przejścia
  czyszczące (Remove1h, WallThickness, Wall3H, WallTopAlign, Spike / ThinBridge / Staircase, ShortLedge, DiagonalTouch,
  SlopeThickness) zmieniają w ściekach **1,3–1,6 % kratek** (cel planu R7: < 1 %; przed pokojami dostawionymi
  do chodników 0,6–0,9 %). Prawdopodobna przyczyna: uskoki 1–2 kratek i krótkie ścianki przy rogach pokoi
  dostawionych do chodnika / sali, prostowane potem przez Wall3H / WallTopAlign. Skutki do obejrzenia: dziwne
  wcięcia lica przy pokojach, ścięte rogi. Spójność jest chroniona (`GenerationContext.protected_floor` + bezpiecznik
  `_restore_cuts`), więc nie odcina mapy. Naprawa docelowa: pokoje dostawiane równo z krawędzią chodnika albo
  z odstępem zgodnym z wysokością lica, żeby przejścia nie miały czego prostować. Statystyka:
  `preprocess_stats["structured"]["prepass_changed"]`, test `tests/diag_structured_layout.gd`.
  **Aktualizacja 2026-10-08 (noc):** po usunięciu wypustek ściany o 1 kratkę (chodniki losowane na łańcuchu
  odcinków, bez zmiany szerokości 2 ↔ 3 i krótkich końcówek, chodnik liczony z miejsca do ramki, górna ramka
  +1, korytarz serwisowy bez pasa wzdłuż sali — CienMgly `0ea2cd2`, `f133c17`) przejścia czyszczące zmieniają
  **0–1,1 %** kratek (15 seedów 160²), wypustek 0–1 na mapę. Zostaje do obejrzenia w podglądzie: pojedyncze
  uskoki lica o 1 przy pokojach dostawionych (detektor: `tests/diag_sewer_thin_walls.gd`).



### ⚠ WAŻNE: (5) miasto / hub z modularnych zasobów paczki free — następny etap
- **Decyzja 2026-10-15:** miasto robione **ręcznie** przez usera (scena w edytorze), **bez generowania** — punkt „mapa składana z modułów paczki przez generator” odpada. Po stronie kodu: NPC, sklep, kowal / ulepszenia, rekrutacja towarzyszy (logika niezależna od mapy).
- Stan 2026-10-12: NIE ZROBIONE (brak mapy miasta w `scenes/maps/levels/`: są `cave.tscn`, `sewer.tscn`). Od miasta zależą: sklepy (po wyjściu z jaskiń), kowal i ulepszenia broni z tierami blokowanymi fabułą, wydawanie złota (`kontekst/ekwipunek_szkic.md`), rekrutacja towarzyszy. Do czasu miasta sklep w menu deweloperskim.
> **Priorytet 2026-10-11:** user ustawił miasto / hub jako następny etap prac (po drużynie i balansie).

- Zgłoszenie 2026-10-05 (ostatnie z ważnych todo). Mapa miasta (kolejność map: jaskinia → miasto → ścieki,
  [game_design.md](game_design.md)) zbudowana ze skomplikowanych, modularnych zasobów
  `assets/pixel_crawler/packs/free_pack_2.11/Pixel Crawler - Free Pack/Environment/`:
  - budynki składane z modułów: `Structures/Buildings/` — `Walls`, `Roofs`, `Props`, `Shadows`,
    wnętrza (`Interior/Interior_Walls_01`, `Interior_Props_01`);
  - stacje rzemieślnicze (`Structures/Stations/`: kowadło, piec, ognisko, kuchnia, tartak, alchemia, warsztat —
    część animowana `-Sheet.png`);
  - tilesety `Tilesets/` (`Floors_Tiles`, `Wall_Tiles`, `Wall_Variations`, `Water_tiles`, `Dungeon_Tiles`),
    rekwizyty `Props/Static` (meble, farma, drzewa w rozmiarach, roślinność), animowane `Props/Animated`.
- Przed startem rozłożyć `.aseprite` budynków na warstwy (parser jak przy ściekach) — zasady składania modułów
  (ściana + dach + cień, warianty) wyczytać z warstw, nie zgadywać z PNG. Obiekty przez generator obiektów
  ([kontekst/obiekty.md](kontekst/obiekty.md)), podgląd przez MCP `godot-runtime`.

### Feature: ukryte przejścia między pokojami (tunel pod voidem)
- **Stan 2026-10-12: NIE ZROBIONE** (brak kodu; są tylko nisze-przejścia, `NichePlacer`).
- Zgłoszenie 2026-10-03. Ukryte przejście może łączyć dwa pokoje — gracz wchodzi w nie (np. nisza-przejście,
  sekretna nisza) i wychodzi w innym pokoju, jakby szedł tunelem pod voidem / litą skałą.
- Do ustalenia: jak to pokazać (przejście przez ekran ładowania / ściemnienie i teleport, czy prawdziwy
  korytarz na warstwie pod spodem), dobór par pokoi (odległość, osiągalność — skrót nie może omijać
  zamkniętych drzwi / quizów), wejścia z obu stron, nawigacja wrogów (bez przejść), zapis w seedzie.
  Powiązane: nisze-przejścia (`NichePlacer`, `ctx.passage_cells`), zawartość nisz out i sekretne pokoje.
- Pomysł usera (2026-10-03) na pokazanie tunelu: shader z Amon-Ra robiący kafle częściowo przezroczystymi —
  `assets/shaders/desert_town/desert_town.gdshader` (już skopiowany do hosta; w Amon-Ra materiał
  `desert_town.tres`): koło wokół `player_position` o promieniu `circle_radius`, alfa od `min_alpha` (przy
  graczu) do `max_alpha`, `smoothness`. Gracz idzie po prawdziwym korytarzu pod voidem / skałą, a kafle nad
  nim (warstwa z materiałem, `player_position` ustawiany co klatkę) prześwitują wokół niego.
- Wtedy **pod terenem voidu muszą się też generować ściany tunelu** (kolizje wzdłuż korytarza) — inaczej
  pod voidem dałoby się chodzić po całej mapie. Czyli: korytarz tunelu wycięty w osobnej masce (nie w siatce
  pokoi), własne kolizje ścian tunelu, warstwa voidu / skały nad tunelem z shaderem, wejścia przez
  nisze-przejścia na obu końcach.

### Nisze-przejścia: wariant kafli RIM i częstość
- **Stan 2026-10-12: CZEKA NA USERA** (wariant kafli RIM w `caves.tres`); częstość przejść bez zmian.
- Generator i kafle OUT gotowe (patrz „Rozwiązane”, 2026-10-03). Zostało: **wariant kafli szczytu ściany (RIM)
  z innymi kolizjami jako alternatywa 1** w `caves.tres` — robi user; executor użyje go sam nad płytszą kolumną.
- Przejść jest mało (seed 103107 160×160 ma 2, pięć innych map 0) — user chce, żeby pojawiały się częściej.
  Sposób do ustalenia (np. celowe wycięcie ściany do głębokości 3 za kandydatem niszy).

### Tryb walki: interfejs, pozycje wrogów, marginesy per tło, losowe spotkania
- **Stan 2026-10-12: W TOKU** — interfejs ZROBIONY (styl RPG Makera, WYSIWYG; listy umiejętności i przedmiotów przerobione 2026-10-11: siatka 2 kolumn albo przewijana lista z ikonami, opcja w Motywie; wybór celu w siatce; animacje wejścia i wyjścia z walki). DO SPRAWDZENIA W GRZE: typy pytań bossów (wpisywanie, kafelki, dopasowanie), przewijanie długiej listy. Losowe spotkania: NIE ZROBIONE.
- Zgłoszenie 2026-09-29. Scena `scenes/quiz/quiz_combat_ui.tscn`, logika `scripts/quiz/quiz_combat_controller.gd`,
  tła `scripts/quiz/battle_background.gd` + `background_generators/*`.
- **Interfejs walki** — zrobiony w stylu RPG Makera (2026-09-30), WYSIWYG; zostały okna Umiejętności /
  Przedmioty w starym wyglądzie i niesprawdzone w grze typy pytań bossów (wpisywanie, kafelki, dopasowanie).
  Tło okien = asset UI od usera -> resources/ui/quiz_theme.tres (QuizWindow).
- **Losowe spotkania jak w JRPG — ZROBIONE 2026-10-21 (wersja podstawowa):** `QuizRpgRandomEncounters` (`scripts/maps/random_encounters.gd`), konfiguracja w companion-JSON mapy, klucz `random_encounters` (`mode` off / always / cleared, `min_distance` / `max_distance` w px, `max_chance`, `tiers` z wagami). Szansa rośnie z krokami: 0 do `min_distance`, potem liniowo do `max_chance` na krok (kratka = krok), pewność przy `max_distance`; średnio ≈ 820 px. Jaskinie: `cleared` (dopiero po wyczyszczeniu zwykłych wrogów, 480–1100 px, `max_chance` 0,12, tiery 1:2 wg wag 3:2). Wróg spotkania jest niewidzialny, spoza grupy `enemies`, znika po walce. Nie liczy dystansu w azylu, w walce/dialogu, podczas nietykalności po walce i po teleporcie. Zostało: strojenie dystansu w grze, strefy bez spotkań (portale, schody), ścieki. Test lokalny `check_random_encounters`.
- (stary opis) **Losowe spotkania jak w JRPG**: wrogowie niewidoczni na mapie, walka zaczyna się nagle podczas chodzenia.
  Tryb obok obecnego (wrogowie widoczni) — np. włącza się po pokonaniu wszystkich wrogów na mapie; zasada
  do ustalenia (per mapa / per biom, szansa na krok, strefy bez spotkań: portale, schody, sekretne pokoje).

### Feedback z zamkniętych testów pre-alpha (tester zewnętrzny)
- **Stan 2026-10-12: W TOKU** — skróty klawiszowe F i blokada w wydaniu zrobione, ignorowanie kliku po odzyskaniu fokusu w walce zrobione, układ pytań zrobiony; DO SPRAWDZENIA W GRZE: klikanie wrogów myszą, obsługa myszy w menu walki, znacznik celu na starcie.
- Zgłoszenie 2026-10-04 (kolega, klon repo). Żadnego z punktów nie było wcześniej na liście; pkt 4 częściowo
  pokrywa się z „Tryb walki” (okna Umiejętności / Przedmioty jeszcze w starym wyglądzie).
1. **[ZROBIONE 2026-10-12, DO SPRAWDZENIA W EKSPORCIE WYDANIOWYM: skróty (F1 / ~, F9 / F10 / F11), menu deweloperskie i przycisk DEV działają tylko przy `OS.is_debug_build()` (`cheat_service.gd`, kontrolery walki i zagadek); litery K / O / P przestały być skrótami (decyzja usera: tylko klawisze F) — opis problemu poniżej jest historyczny]** **Narzędzia deweloperskie za łatwo dostępne.** `autoloads/services/cheat_service.gd` łapie pojedyncze litery
   zawsze, gdy nie trwa wpisywanie tekstu: K = natychmiastowe zwycięstwo (też w `quiz_combat_controller.gd`
   i `quiz_puzzle_controller.gd`), O = wrogowie wł./wył., P = quizy wł./wył.; menu deweloperskie pod F1 / `~`.
   Nie ma warunku `OS.is_debug_build()` — działa też w eksporcie. Do ustalenia: tylko klawisze F albo skrót
   z modyfikatorem, przełącznik „tryb deweloperski” w opcjach, wyłączenie w buildzie wydaniowym.
2. ~~**Układ ekranu pytania w walce:** pytanie na samej górze, odpowiedzi na dole — wzrok skacze po ekranie.~~
   Zrobione (2026-10-04, CienMgly 13fa303, f79c808 + host 793109f): układ u góry to decyzja autora (styl RPG
   Makera), więc doszła opcja Opcje -> Motyw -> „Pytanie w walce”: „W oknie logu (u góry)” (domyślnie) /
   „W menu walki (nad odpowiedziami)” — pytanie i pasek czasu w panelu quizu pod tytułem, jak przed oknem logu
   (`_apply_question_position`). Menu opcji hosta obsługuje teraz opcje modułu typu `choice`.
3. **[POPRAWIONE CZĘŚCIOWO (aa47eaf, a7c4730: wybór myszą, wiersze celów), DO SPRAWDZENIA W GRZE — `kontekst/walka.md` oznacza klikanie wrogów jako niesprawdzone]** **Kliknięcie wroga na polu walki nie atakuje**, choć cel się zmienia (podświetlenie działa). Obsługa kliknięcia:
   `_handle_hovered_enemy_click` (tylko w fazie `TARGET_SELECT`: ustawia cel i woła `_confirm_target_selection`).
   Do sprawdzenia: czy klik w ogóle tam dociera (może go przechwytywać GUI albo inna faza).
4. **[DO SPRAWDZENIA W GRZE: listy Umiejętności / Przedmioty przerobione 2026-10-11 (wiersze z ikonami), obsługa myszy do potwierdzenia]** **Mysz nie działa w części menu walki** — „Przedmioty” i „Umiejętności” obsługują tylko klawiaturę, pewnie też
   inne listy (`_list_menu_mode`). Te dwa okna i tak czekają na przeróbkę w stylu RPG Makera (wpis „Tryb walki”) —
   załatwić przy niej; wymaganie dla nowych okien: obsługa i myszą, i klawiaturą.
5. **[DO SPRAWDZENIA W GRZE]** **Brak znacznika celu na starcie wyboru przeciwnika** — pojawia się dopiero po pierwszej zmianie celu.
   Do sprawdzenia: odświeżenie znacznika (`_refresh_target_selection`) przy otwarciu panelu celu.
6. **[ZROBIONE 2026-10-12 w walce, DO SPRAWDZENIA W GRZE: `QuizCombatController` ignoruje mysz, gdy okno nie ma fokusu (`FOCUS_OUT`), oraz klik przez 300 ms po `FOCUS_IN`; test `check_focus_click`; nie testowane na prawdziwej utracie fokusu]** **Kliknięcie w okno, żeby wróciło skupienie (np. z Discorda), wykonało atak.** Klik przywracający fokus idzie
   do gry jak zwykłe wejście (przycisk akcji albo wróg pod kursorem). Pomysł: ignorować kliknięcia przez chwilę
   po `NOTIFICATION_APPLICATION_FOCUS_IN` (albo gdy okno nie miało fokusu w chwili kliknięcia).

### Skalowanie wrogów przy kilkunastu mapach (system tierów)
- **Stan 2026-10-12: W TOKU** — w większości zrobione. Poziom wroga z mapy (`enemy_levels` w JSON), XP z poziomu (`QuizRpgEnemyXp`), statystyki wroga z poziomu wg bohatera wzorcowego z ekwipunkiem po krzywej (`QuizRpgEnemyStats`, `tier` jako klasa trudności), złoto z poziomu (`QuizRpgEnemyGold`); szczegóły `kontekst/poziomy_i_xp.md`. Zostaje: umiejętności wrogów ze stałą bazą nie skalują się z poziomem; ocena trudności jaskiń po zmianie (boss lv 9: HP 1555, ATK 48) w grze; krzywe bohatera do lv 100 i tiery sprzętu na 15 map (`ekwipunek_szkic.md`). Generator `.tres` nie jest potrzebny (wartości liczone w kodzie).
- **TODO (zgłoszenie 2026-10-11):** dziś są 4 tiery wrogów (HP 100 / 350 / 900 / 2200, ATK 26 / 52 / 85 / 150, DEF 30 / 60 / 95 / 140;
  umiejętności = tier − 1, boss 3; XP 200 × 2^(tier−1)) — wystarcza na 2–3 mapy, nie na kilkanaście. XP rosnące 2^tier wybuchnie,
  a stałe skoki ×2–3 nie pasują do krzywej gracza (HP 334 → 1402, poziomy 1–20, później do 100).
- **Kierunek do rozważenia:** staty z **poziomu wroga** (`enemy_level`) po jednej krzywej dopasowanej do krzywej bohatera, a archetyp
  (wojownik / łotrzyk / mag / boss) jako mnożniki HP / ATK / DEF zamiast ręcznych liczb w ~75 plikach; `encounter_tier` zostaje jako klasa
  trudności (liczba umiejętności, XP, wielkość grup); mapa = zakres poziomów wrogów; XP jako ułamek XP potrzebnego graczowi na kolejny poziom.
  Generator `.tres` z krzywej zamiast edycji ręcznej. To zadanie projektowe (Opus), razem z kalibracją na FNaFB.

### Zawartość nisz out, sekretne pokoje, klucze i wytrychy do skrzyń
- **Stan 2026-10-21: W TOKU** — zrobione: tier skrzyni z JSON mapy (`chest_tier`), klucze na tier (brązowy / srebrny / szafirowy / złoty = uniwersalny, klucz tieru ≥ tier skrzyni), wygląd skrzyni wg tieru (`tier_frames`), tabele łupu skrzyń i wrogów z JSON (`chest_loot`, `enemy_loot`), klucze w łupie map; **zawartość nisz out w jaskiniach (2026-10-21)**: wagi usera przedmiot 50 / skrzynia 35 / sekretny pokój 15, skrzynia nisz tieru 2 z lepszym łupem, przedmiot na ziemi; **sekretny pokój (2026-10-21)**: osobna mapa z 1–3 pokoi (decyzja usera), bez wyjścia, ze skarbem i powrotem do niszy; **pokój relikwii**: zawsze dokładnie jedna nisza na mapę, krypta 2–3 pokoje, relikwia w ostatnim, boss przed nim (`kontekst/obiekty.md` „Zawartość nisz out”). **Skrzynie specjalne w rzadkich pokojach (2026-10-21)**: 1–2 na mapę, tier 3, pokoje na uboczu głównej drogi; relikwia = Ostrze Mgły (broń z potencjałem, kowal). Zostaje: skrzynia przeklęta (do ustalenia), sprawdzenie w grze.
- Zgłoszenie 2026-09-29. Dziś nisze z modułów out (`tiling/niche_placer.gd`, szansa
  `secret_niche_spawn_chance`, kandydaci `EdgeContext.is_secret_niche_candidate`) są tylko kaflami ścian.
- **Każda nisza out ma zawartość, losowaną**: przedmiot na ziemi, skrzynia albo **przejście do
  sekretnego pokoju**. Sekretny pokój: osobna mała mapa / podpokój z nagrodą — mocny przedmiot, miniboss
  z dobrym lootem albo inna niespodzianka (lista do rozbudowy). Wagi losowania do ustalenia.
- **Klucze i wytrychy do skrzyń** — oba wypadają z potworów, **klucze dużo rzadziej**.
  - Klucz: otwiera skrzynię od razu.
  - Wytrych: otwarcie uruchamia **sekcję quizu**; **tier skrzyni** wyznacza trudność i liczbę pytań
    (porażka — do ustalenia: wytrych przepada / skrzynia się blokuje / można spróbować znowu).
- ~~**TODO (priorytet, zgłoszenie 2026-10-10): przedmioty „klucz uniwersalny” i „wytrych uniwersalny”**~~ — zrobione 2026-10-11 (obiekty.md „Klucze i wytrychy”); zostaje tier skrzyni z poziomu mapy. — na pewno do
  zrobienia. Jako przedmioty z ekwipunku (`ItemData`) działają na **dowolnej** zamkniętej skrzyni (bez dopasowania
  `lock_id`), w odróżnieniu od kluczy fabularnych. Klucz otwiera od razu, wytrych odpala quiz skrzyni (tier skrzyni =
  trudność). Wypadają z wrogów (`loot_manager.gd`), klucze dużo rzadziej; dodać do paska/menu użycia przy skrzyni.
- Punkty zaczepienia: `scripts/interactables/chest.gd` (`lock_id`, `is_locked`, `chest_item_id`),
  skrzynie z generatora obiektów (INTERACTIVE `chest`, `unique_id` "<id>_<x>_<y>"), loot z wrogów
  (`autoloads/loot_manager.gd`, `enemy_data.encounter_tier`), quiz (`scripts/quiz/` — kontrolery
  walki / zagadki, `quiz_door.gd` jako wzór bramki quizowej).
- Do ustalenia przy realizacji: skąd tier skrzyni (głębokość / poziom mapy / nisza vs pokój), zapis stanu (otwarte skrzynie / odwiedzone
  sekretne pokoje per save, jak pokonani bossowie).
- **TODO (pomysł usera 2026-10-12, nie dodane): skrzynie specjalne w rzadkich pomieszczeniach / niszach.** Rzadki pokój lub nisza z wyższym tierem skrzyni (3–4, wygląd niebieski / złoty; skrzynia z czaszką
  z arkusza „RPG Chests” kolumna 8 jako przeklęta), z lepszym łupem (sprzęt tieru 2, później broń z potencjałem — `docs/kontekst/ekwipunek_szkic.md`). Potrzebne: znacznik „rzadki pokój / nisza”
  w generatorze obiektów (dziś `objects_caves.json` tylko preferuje nisze dla zwykłych skrzyń), osobny tier i tabela łupu dla takiej skrzyni, ewent. wymóg klucza wyższego tieru.

### Minimapa z fog of war
- **Stan 2026-10-21: ZROBIONE (wersja podstawowa).** `QuizRpgMinimapData` (`scripts/maps/minimap_data.gd`: rodzaje kratek z wyniku generacji albo z warstw TileMapLayer — Walls / Cliffs = ściana; odkrywanie w promieniu z linią wzroku Bresenhama, ściany zasłaniają, uskoki płaskowyżów nie; maska DEFLATE + base64) i scena `scenes/ui/minimap.tscn` w HUD (róg: wycinek wokół gracza, zoom 4 px / kratkę; akcja `minimap` = M: cała mapa, Esc zamyka). Promień 12 kratek. Maska per mapa w stanie poziomu (`LevelStateManager`, klucz `fog`) — w zapisie gry, znika z rerollem. Kolory: podłoga, góra płaskowyżu, obrys ścian, uskok, wejście (niebieskie), wyjście (złote). Widoczna tylko w eksploracji. Zostało: znaczniki skrzyń / NPC / odwiedzonych nisz, ikonki zamiast kropki gracza, opcja wyłączenia w ustawieniach, budowa danych w wątku (`from_level` ≈ 25 ms na 160², ~2,5× więcej na 250²). Testy lokalne `check_minimap`, `shot_minimap`.
- Stan 2026-10-12 (stary opis): NIE ZROBIONE (brak kodu minimapy).
- Zgłoszenie 2026-09-30. W projekcie nie ma jeszcze minimapy.
- Minimapa w rogu ekranu (opcjonalnie pełna mapa pod klawiszem), odkrywana w miarę chodzenia: kratki
  w promieniu widzenia gracza przechodzą z „nieznane” na „odkryte” (fog of war); odkryte zostają.
- Źródło danych: wynik generacji (`GenerationResult.grid`, płaskowyże — bariery / schody, portale),
  np. jako `Image` W×H rysowany raz, plus maska odkrycia (`PackedByteArray`) aktualizowana przy ruchu.
  Znaczniki: gracz, wejście / wyjście, opcjonalnie skrzynie i odwiedzone nisze.
- Do ustalenia: promień odkrywania (z linią wzroku po ścianach czy bez), zapis maski odkrycia per mapa
  w save (jak seedy map), mapy ręczne (tutorial_area) — z TileMapLayer zamiast z wyniku generacji.

### Mapy otwarte z uniwersalnego generatora (las zamiast ścian)
- **Stan 2026-10-12: NIE ZROBIONE** (lasy nadal przez osobny `overworld_forest_generator.gd`; analiza poniżej aktualna).
- Zgłoszenie 2026-10-01. Pomysł: mapy otwarte (las, Fairy Forest, Dense Forest…) z tego samego generatora co
  jaskinie — topologia (pokoje, korytarze, płaskowyże) bez zmian, ale **teren (podłoga, wzniesienia) na całej
  mapie**, a tam, gdzie jaskinia ma ściany, **gęsto drzewa**, przez które nie da się przejść.
- Dziś mapy otwarte robi osobny `overworld_forest_generator.gd` (szum + polany + ścieżki, ~170 linii) — nowa
  ścieżka by go zastąpiła i dała lasom płaskowyże, teren, obiekty, nawigację i postęp ładowania jak w jaskiniach.
- Proponowany podział:
  - **Kolizja z siatki, nie z drzew:** kratki ścian zostają blokujące (niewidoczna warstwa kolizji / Walls bez
    grafiki); drzewa tylko rysują. Gęsto stawiane drzewa z małymi kształtami pni i tak zostawiałyby szczeliny,
    a nawigacja (`NavOutlines`) już liczy z siatki.
  - **Pas brzegowy** (1–3 kratki od podłogi): drzewa jako obiekty (`ObjectPlanner`, katalog np.
    `objects_forest.json`, kontekst przy ścianie), z y-sortem — postać może wejść „za” pień.
  - **Głąb lasu:** nie kafle koron, które muszą do siebie pasować (korony są szersze niż kratka → luki albo
    niedopasowane krawędzie), tylko **całe drzewa nachodzące na siebie** — jak w makiecie
    `assets/pixel_crawler/environments/world_build/MockUps/Trees.png`: duże kafle wielokratkowe (sprite drzewa
    z `Tree.png` Fairy Forest) w rozstawie mniejszym niż szerokość korony (np. co 2–3 kratki), z y-sortem
    (przednie przykrywają tylne) i przesunięciem przez kafle alternatywne z innym `texture_origin`.
    Na TileMapLayer, nie jako obiekty — przy 500×500 to setki tysięcy kratek.
  - **Ciemne podłoże pod lasem** (kafel cienia zamiast trawy) — ewentualna szczelina między koronami wygląda
    wtedy jak cień, nie jak dziura. W `Tree.png` są też same korony w 6 odcieniach aż do prawie czarnego —
    ciemniejsze głębiej w lesie.
  - **Wariacja mimo siatki** (autor chce drzew nie w równym gridzie), do połączenia:
    - kafle alternatywne w TileSecie — każdy może mieć własny `texture_origin` (przesunięcie o kilka px),
      odbicie, `modulate` (odcień) i `y_sort_origin`; generator losuje alternatywę → drzewa „poza siatką”;
    - osobny TileSet warstwy drzew z drobniejszą kratką (np. 8 px zamiast 16) — więcej możliwych pozycji;
    - w pasie brzegowym (blisko gracza) drzewa jako obiekty w trybie `free` — pełna dowolność pozycji;
      wypieczona scena (`ObjectBake`) pozwala złożyć drzewo z wielu sprite'ów jak „moduł”.
    - Sprawdzone (Godot 4.7.2): `texture_origin` przesuwa **tylko grafikę** — kolizja alternatywy zostaje
      na kratce (każda alternatywa ma własne kształty, więc trzeba by je przesuwać ręcznie). Przy kolizji
      z siatki to bez znaczenia; tylko na brzegu przesunięcie w stronę polany ograniczyć, żeby rysunek pnia
      nie wchodził na kratki podłogi.
  - Do sprawdzenia: kafle wielokratkowe na warstwie z y-sortem (por. „Do sprawdzenia w grze” → kafle
    wielokratkowe na `Props`) i koszt rysowania przy 500×500.
  - Autotiling ścian (`EdgeAnalyzer`, fasady 2H/3H) wyłączony dla tego stylu — flaga stylu ścian
    (kafle skalne / las) w `GenerationFlags` + JSON biomu (por. wpis „Nowe flagi generatora”).
- Do ustalenia: krawędzie płaskowyżów pod drzewami (klify widoczne tylko na polanach?), wyjścia mapy w lesie
  (przecinka w pasie drzew), wygląd przejścia polana → las (krzaki, pojedyncze drzewa przed ścianą).

### Modularność assetów i autoloadów (moduł samodzielny bez dublowania w eksporcie)
- **Stan 2026-10-12: W TOKU** — ZROBIONE dla Cienia Mgły (quiz_rpg), CZĘŚCIOWO dla BitBombera. Cień Mgły to osobne repo (submoduł `modules/quiz_rpg`), ścieżki przez `QuizRpgPaths`, kopie hosta w `_host/` z `.gdignore`, synchronizacja `tools/sync_host_copies.gd`, `tools/make_standalone.sh` (opis w `docs/module_contract.md`, wpis w „Rozwiązane” 2026-10-03). Zostaje: `modules/BitBomber/resources/icon.png` ma ten sam UID co `resources/icon.png` hosta (ostrzeżenie „UID duplicate” przy imporcie, plik leży obok `quizzes/`, więc nie da się ukryć folderu); pełne przeniesienie BitBombera na ten schemat (kopia fontów z `.gdignore` jest, reszta nie).
- Zasady, które się sprawdziły (Godot 4.7.2): UID w `ext_resource` ma pierwszeństwo przed ścieżką (scena z błędną ścieżką, ale poprawnym UID wczytuje właściwy plik); względne `path="../…"` działają przy wczytaniu, ale zapis sceny / zasobu zmienia je na `res://…`; pliki `.import` są w repo (UID-y assetów wspólne dla klonów); po zmianie zasobów hosta trzeba ponownie zsynchronizować `_host/` (uwaga: synchronizacja nadpisuje też pliki hosta, które w `_host/` są nowsze — sprawdzać diff, np. `Tiles.png`).

### Skalowanie pancerza w późnej fazie gry (wpływ DEF na przeżywalność)
- **Stan 2026-10-12: DO WERYFIKACJI** — formuła obrażeń w `enemy_stats.gd` liczy cios wroga z ułamka HP (`HIT_FRAC`), co osłabia wpływ pancerza na późniejszych poziomach.
- Zgłoszenie 2026-10-12 (`otwarte.md`, `balans_i_skalowanie.md`). Przy skalowaniu do lv 100 pancerz (DEF) ma malejący wpływ na przeżywalność, ponieważ cios wroga bazuje na ułamku HP bohatera.
- Do zrobienia: przejrzeć i zrewidować definicję obrażeń oraz pancerza w `enemy_stats.gd` niezależnie od reszty drabiny sprzętu.
- **Pomiar 2026-10-17** (wróg tieru 2, ciosy zwykłe, % maks. HP na cios): lv 1 — z pancerzem wzorcowym 14,0 %, bez pancerza 29,0 %; lv 20 — 14,0 % / 21,9 %; lv 50 — 14,0 % / 17,8 %; lv 100 — 14,0 % / 15,3 %. Pancerz ±30 % wzorca zmienia cios o ±0,4 pp na lv 100 (±4,5 pp na lv 1). Przyczyna: ATK wroga ≈ (HIT_FRAC·HP + 2·DEF)/4, a HP rośnie ~150× do lv 100, DEF ~13×.
- **Decyzja usera 2026-10-17: zostawić do czasu decyzji o skali drabiny sprzętu.** Opcje: (a) wzór procentowy ATK×4 × 100/(100+DEF·k) (zalecane), (b) DEF w krzywych ~6× mocniejszy (GEAR_DEF_END ~1100–1900).

### Propozycja: korzeń modułu z położenia skryptu (zamiast nazwy folderu)
- **Stan 2026-10-13: PROPOZYCJA (niezatwierdzona).** Wynikła z pytania o `ModuleConfig.path()` — starą klasę z pierwszego
  szablonu modułu (maj 2026, `modules/_template/scripts/module_config.gd`, zastąpioną przez `ModuleRuntime`).
- **Dziś:** pomocniki ścieżek modułów (`ModuleRuntime` w szablonie, `BBRuntime` w BitBomberze, `QuizRpgPaths` w Cieniu Mgły)
  mają na sztywno korzeń hosta (`res://modules/<id>` albo `res://modules/BitBomber`) i sprawdzają, czy istnieje
  `…/module_manifest.json`. Wymaga to, żeby nazwa folderu zgadzała się z wpisaną w pomocniku (szablon: `MODULE_ID`
  = nazwa folderu; BitBomber: `BitBomber` wielką literą przy `id` `bitbomber`) — przy zmianie nazwy folderu trzeba
  poprawić ręcznie.
- **Dlaczego nie wraca `ModuleConfig`:** host woła `embedded_start(api, …)` dopiero po `add_child` modułu
  (`scripts/core/module_host.gd`), więc korzeń od hosta przychodzi za późno dla `_ready()` modułu (BitBomber otwiera scenę
  gry właśnie tam), dla statycznych zmiennych (Cień Mgły: `START_SCENE`) i dla autoloadów modułu (startują z silnikiem).
  Do tego uruchomiony samodzielnie moduł nie ma skryptu hosta, więc pomocnik i tak musiałby być w każdym module.
- **Propozycja:** w pomocniku modułu wyliczyć korzeń z położenia samego skryptu, bez nazwy folderu i bez pliku manifestu:

```gdscript
static func module_root() -> String:
	var p: String = (new() as RefCounted).get_script().resource_path   # np. res://modules/BitBomber/scripts/bb_runtime.gd
	return p.get_base_dir().get_base_dir()                             # res://modules/BitBomber

static func path(local: String) -> String:
	var root := module_root()
	return root + local.trim_prefix("/") if root == "res://" else root + "/" + local.trim_prefix("/")
```

  Sprawdzone w Godocie 4.7.2: w hoście daje `res://modules/Abc`, samodzielnie `res://`; **w trybie samodzielnym trzeba
  osobno obsłużyć korzeń `res://`** (bez tego wychodzi `res:///scenes/…`), stąd warunek w `path`. Założenie: pomocnik leży
  w `scripts/` modułu (jeden poziom pod korzeniem); przy innym położeniu zmienia się liczba `get_base_dir()`.
- **Opcjonalnie:** gdy host przekaże korzeń (`api.module_root`), pomocnik może go przyjąć, ale tylko jako zgodność — nie
  jako jedyne źródło.
- **Zakres zmiany:** `modules/_template/scripts/module_runtime.gd`, `modules/BitBomber/scripts/bb_runtime.gd` (repo BitBomber)
  i `modules/quiz_rpg/scripts/quiz_rpg_paths.gd` (repo CienMgly, tam jest też `localize` / `canonical` / `host` — to osobna
  logika kopii `_host/`). Po zmianie poprawić opis w README hosta („Konwencja ścieżek”) i w `docs/module_contract.md`.

## Do sprawdzenia w grze (testy headless tego nie widzą)
- **Nowe od 2026-10-11 / 12 (stan: DO SPRAWDZENIA W GRZE):** boss w pokoju wyjścia jaskiń (chodzi po nawigacji?), przejście przy gradiencie, animacja wejścia i wyjścia z walki, przewijanie długiej listy w walce, zakładka „Ogólne” w opcjach (osadzona w menu Cienia Mgły), wygląd skrzyń wg tieru i klucze na tier, beczki z modelem 3 / (2n) (średnio ≈ 2,3 losowania), złoto i wiersz „Złoto” w menu pauzy, koszt walki (≈ 70 % HP na parę wrogów) i liczba mikstur w jaskiniach, trudność jaskiń po nowych statystykach wrogów, tutorial + jaskinie = lv 8–9?
- **Kafle wielokratkowe na warstwie `Props`** (obiekt z `"atlas"` i `size` > 1×1, placement `grid`) —
  ścieżka jest, ale nie była oglądana; kafel TileSetu rysuje się względem swojej kratki, więc duży kafel
  może być przesunięty względem podstawy. Obiekty ze scen (obecny katalog caves) tego nie dotyczy.
- **Kapelusze dużych grzybów nad ścianą** — y-sort po nodze trzonu, więc kapelusz rysuje się nad kaflami
  ściany na północ od niego (tak jak na mockupie). Sprawdzić, czy nie zasłania czegoś ważnego (portale,
  schody płaskowyżu).
- **Pozycja scen INTERACTIVE** — środek kratki kotwicy (dolny wiersz podstawy), jak dotychczasowe
  skrzynie; większe sceny interaktywne mogą wymagać własnego originu.

## Wydajność
- **Wypiekanie siatki nawigacji** — w kawałkach 64×64 kratek (`NavOutlines.build_chunks`, jeden
  `NavigationRegion2D` na kawałek pod węzłem `NavigationRegion2D`), w wątku roboczym, etap „Ścieżki
  przeciwników”. Cała mapa naraz rosła dużo szybciej niż pole przez obrysy przeszkód (seed 184356:
  250×250 7 s, 500×500 ~5,5 min w wolnym kontenerze, u autora ~63 s); w kawałkach 0,2 s / 0,7 s.
  Brzegi kawałków bez zwężania o promień agenta (`baking_rect` + `border_size`), regiony łączy serwer
  nawigacji. Ścieżki vs cała mapa: 250×250 400/400 par osiągalnych w obu, średnio 0,995 długości, żadna
  przez ścianę; 500×500 382 w obu, 0 tylko w całej, 5 tylko w kawałkach. Ostrzeżenia „edge error(s)” przy
  synchronizacji były już przy całej mapie (cienkie przejścia). Mapa nawigacji wczytuje regiony
  asynchronicznie (kilka klatek fizyki) — do tego czasu wróg bez ścieżki idzie prosto tylko przy czystej linii.
- **Na 500×500 ~1/3 losowych par kratek nie miało ścieżki** (seed 184356) — wyjaśnione 2026-09-30
  (`tests/diag_nav_reach.gd`, lokalnie): to **limit zapytania Godota `path_search_max_polygons` = 4096**
  (map_get_path / query_path — po nim ścieżka do punktu najbliższego celu), nie siatka. Obiekty mnożą
  wielokąty (dziury), więc długie zapytania przez 500×500 go przekraczają. Bez limitu: 1 / 300 (rzadkie
  prawdziwe zwężenie przez przeszkodę), po zmianie w planerze (osiągalność jak dla wroga, niżej) 0 / 300.
  Wrogowie też pytają z limitem 4096 (`enemy_base.gd`, pościg / wałęsanie), ale ich ścieżki są krótkie.
  Podniesienie limitu u nich — tylko gdy pojawią się długie trasy (bez limitu nieosiągalny cel przeszukuje
  całą mapę przy każdym przeliczeniu ścieżki).
- **Planer obiektów sprawdza osiągalność jak wróg** (`ObjectPlanner._clearance` / `_bfs_agent`): po środkach
  kratek, z odstępem promienia agenta (7 px) od dokładnych obrysów przeszkód (`NavOutlines.placement_outlines`,
  te same co siatka); odcięty teren -> zdejmowane przeszkody w promieniu 2 kratek. 250×250: -18 z 2623 obiektów,
  etap osiągalności 26 -> 40 ms.
- **Pętla naprawy płaskowyżów** (`PlateauPass._solve`) ~750 ms na 250×250 (BFS po mapie × ~8 iteracji) —
  kandydat na płaskie tablice (jak w `ObjectPlanner`).
- **Planer obiektów** ~95–110 ms na 250×250 przy ~500 obiektach, ale z pełnym katalogiem caves
  (~3,4 tys. obiektów z towarzyszami) ~340 ms — w wątku roboczym, ale wydłuża ładowanie. Najdroższe:
  cechy mapy (`ObjectFeatures`, ~40 ms), BFS rezerwacji przejść, pętle kandydatów dla gęstych DECAL-i.
- **Kształtowanie masek terenu** (`TerrainMaskPlanner.shape_mask`) ~130 ms na 250×250 (dwie maski).

## Pułapki konfiguracji (działa zgodnie z założeniem, ale łatwo się naciąć)
- Wróg z przypisanym `enemy_data` bierze `detection_radius` (i inne statystyki) z niego, nie z inspektora
  sceny — np. Enemy5 w `tutorial_area.tscn` ma pusty `enemy_data`, więc zasięg = domyślne 150.
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
- **W `.tscn` eksportowane właściwości skryptu muszą stać po linii `script =` węzła.** Właściwości zapisane wcześniej (np. `tier_frames` skrzyni wpisane po `sprite_frames`) są cicho ignorowane przy wczytaniu; w scenie dziedziczonej skrypt jest już z bazy, więc kolejność nie szkodzi.
- **`sync_host_copies.gd` nadpisuje kopie w `_host/` z hosta** — jeśli plik w `_host/` jest nowszy (np. `Tiles.png`), pojawi się niezamierzona zmiana; sprawdzić `git status` przed commitem i cofnąć niepowiązane pliki.
- **Tiery skrzyń, kluczy i łupu:** `chest_tier`, `chest_loot`, `enemy_loot` czytane z companion-JSON mapy (jaskinie 1, ścieki 2); mapa bez `enemy_loot` używa starego losowania klucza tieru 1 w `QuizCombatController._roll_item_drops`.

## Testy
- **Stan 2026-10-12:** lokalny zestaw to ok. 100 skryptów `check_*` / `diag_*` w `tests/` (gitignorowane); pełny `run_plateau_suite.sh` zielony (parytet ścian 42/42). `check_progress_log` pisze już do osobnego pliku (`QuizRpgProgressLog.log_path`), nie do prawdziwego logu; `diag_enemy_chase` ma próg 33 %. Nowe testy: `check_gold`, `check_enemy_gold`, `check_loot_tables`, `check_barrel_model`, `check_character_class`, `check_i18n`, `check_i18n_misc`, `check_chest_lock` (klucze na tier, wygląd skrzyń).
- Testy (`modules/quiz_rpg/tests/`, w tym `run_plateau_suite.sh`, `diag_objects.gd` i
  `parity_baseline.txt`) są w `.gitignore` — żyją tylko lokalnie. Utrata katalogu = utrata zestawu
  i baseline'u parytetu.
- Baseline parytetu zależy od katalogu obiektów: przeszkody zsuwają spawny wrogów/skrzyń, więc każda
  zmiana `objects_caves.json` z kolizją zmienia pole `spawns` w digestach (ściany/podłoga bez zmian).
- `diag_enemy_chase.gd`, część „poziom ręczny (tutorial_area)” jest losowa (wałęsanie bez seeda):
  „klatki przy ścianie” wahają się od ~30 do ~1300 / 3000 i sprawdzenia czasem nie przechodzą — także
  przed zmianami. Pojedynczy FAIL tam to jeszcze nie regresja; powtórzyć kilka razy.

## Potencjalne problemy (do obserwacji)
- **Tekst UI walki 36 px poza siatką Jersey 15** (2026-10-03, decyzja usera): czcionka pikselowa jest ostra
  w wielokrotnościach 27 px (27 / 54 / 81); przy 36 px (4/3) piksel litery wypada na 1,33 px ekranu, więc
  kreski mogą mieć raz 1, raz 2 px. User w testach nie widział różnicy. Jeśli wyjdą nierówne litery: zmienić
  `QuizTheme.COMBAT_FONT_SIZE` na 27 albo 54 (ekran walki ma własną kopię motywu — `combat_theme()`).

## Rozwiązane (dla kontekstu)
- **Przeniesione z „Do zrobienia” 2026-10-21 (szczegóły w kontekst/ i commitach):**
  - Przyspieszenie generowania (#1): zrobione, dalszy zysk wymagałby C# / GDExtension — `plan_przyspieszenie_generowania.md`, `plan_zapis_map.md`.
  - Generator obiektów F5 (dźwignie, beczki, nakładka podglądu): `kontekst/obiekty.md`, `plan_generator_obiektow.md`.
  - Tła walki 16:9: kod gotowy (2026-10-06); grafiki generuje user, wpis wygaszony (decyzja usera).
  - Teammate'owie (4): rekrutacja, skille klasowe, sloty umiejętności, imiona Kael / Eldon / Selene — `kontekst/druzyna_szkic.md`, `sloty_umiejetnosci_szkic.md`.
  - NPC (6): sklep, nauczyciel, odpoczynek, kowal, rozmowa — `kontekst/npc.md`.
  - Beczki scale / k (7): CienMgly ae73bfe6.
  - Tłumaczenia JSON: `I18nService` + słowniki, `kontekst/i18n_calosc_raport.md` (resztki w `zadania_wg_trudnosci.md`).
  - Optymalizacja ekwipunku członków (MAT / MDF / AGI wg klasy): `_equipment_score` w `player_stats.gd`.
  - Spójna ścieżka między mapami: CienMgly 833d7c0c, `scripts/maps/map_links.gd` (wejście = przeciwna krawędź do wyjścia poprzedniej, bez zawracania; parytet 42/42).
- **Ekwipunek, złoto i klucze — prototyp w jaskiniach** (2026-10-12, CienMgly): klasy postaci (`character_class`, `allowed_classes`), złoto (`PlayerStats.gold`, `QuizRpgEnemyGold`), tabele łupu z JSON mapy (`chest_loot`, `enemy_loot`), beczki z wzorem 3 / (2n), klucze na tier skrzyni i wygląd skrzyń wg tieru. Szkic i decyzje: `kontekst/ekwipunek_szkic.md`.
- **Tłumaczenia JSON (system), statystyki wrogów z poziomu, krzywa HP / SP, log progresji, animacja wyjścia z walki, opcje Ogólne z językiem** (2026-10-11 / 12, CienMgly): szczegóły w `kontekst/otwarte.md`, `poziomy_i_xp.md`, `walka.md`.
- **Kładki na osobnej warstwie i ciągłość opuszczonej krawędzi (ścieki)** (2026-10-05, CienMgly): kładki
  (`BRIDGE_V`, `BRIDGE_H`) wydzielone na dedykowaną warstwę TileMapLayer `Bridges` (`z_index = -1`, y-sort);
  kładka pozioma `BRIDGE_H` rozszerzona w atlasie `Props.png` do 6×2 (kolumny 5–10, `origin = Vector2i(5, 12)`,
  `size = Vector2i(6, 2)`); w `canal_placer.gd` funkcja `_is_face` uniezależniona od przechodniości północnego
  sąsiada (`not water.has(n)`), co gwarantuje 100% ciągłości lica uskoku `CANAL_FACE` (4, 13) wzdłuż całego biegu
  koryta (w tym na seedzie 324091 przy kafelku (74, 241)) bez wcięć kwasu w mur.
- **Mapy jako sceny dziedziczone + seed per zapis + powrót do poprzedniego poziomu** (2026-10-03, CienMgly):
  `procedural_level.tscn` to baza, mapy w `scenes/maps/levels/` (na razie `cave.tscn`; w przyszłości po jaskini
  miasto, potem ścieki). Jeden seed na zapis (`LevelStateManager.world_seed`), seed mapy = hash(seed zapisu,
  nazwa sceny); reroll = nowy seed zapisu i czyste mapy. Wejście mapy (`enter_previous_level`) prowadzi na
  poprzedni poziom do markera `FromNext` przy jego wyjściu (`scripts/maps/level_portal.gd`).
- **Punkty pojawienia się odsunięte od przejść** (2026-10-04, CienMgly 99b3cd4): gracz nie pojawia się w Area2D
  przejścia, tylko przy markerze >= 3 kratki od niego — na mapach generowanych `Spawn` / `FromNext` z
  `MapGeneratorBase.arrival_cell` (podłoga, ta sama wysokość, bez barier i obiektów), w samouczku
  `Spawns/Tutorial-Caves` (marker usera; `cave.tscn` `previous_spawn_name`). Przejście działa od razu po wejściu;
  obszar, w którym gracz stoi po wczytaniu, dopiero po wyjściu. Testy: `diag_level_back`, `diag_arrival_cells`.
- **Przejścia pod E** (2026-10-04): tryb per przejście — w scenie ręcznej metadane Area2D `portal_use_key` (bool)
  i `portal_prompt` (tekst, domyślnie „Przejdź”), na mapach dziedziczonych eksporty `procedural_level`
  `next/previous_portal_use_key` i `next/previous_portal_prompt` (np. drabina w ściekach). Podpowiedź „[E] …”
  nad środkiem kształtu obszaru (`portal_key_listener.gd`). Test: `diag_portal_key`.
- **Zmiana klawiszy (rebind) per moduł** (2026-10-03): zakładka „Sterowanie” w opcjach — 2 pola na akcję,
  przejmowanie klawisza w konflikcie, „Przywróć domyślne”; `InputBinds` + `SettingsService.set_module(…, "binds")`,
  nazwy akcji z `action_labels` w manifestach. Opis: `docs/kontekst/menu_i_opcje.md`.
- **Wymuszone 2H tam, gdzie powinno być 3H** (2026-10-03, seed 103107 160×160, (82–83, 113–114) i (89–90,
  113–114)): to była reguła skosu 2H (`WALL_2H_SLOPE`) — dostawał go każdy schodek o 1 przy grubości 3–5,
  także pojedyncze schodki na poziomej fasadzie. Teraz (`EdgeAnalyzer.slope_2h_run`, CienMgly b9b0cae) skos
  dostaje cały ukośny ciąg kolumn schodzących po 1 rząd, jeśli któraś ma 3 kratki nad stopą INNER_CORNER w
  kierunku skosu (NORTH_WEST schodzący w lewo, NORTH_EAST w prawo). Do tego `SlopeThicknessPass` (P11a):
  ukośna ściana o grubości 3 -> 4 (ciąg >= 3 stóp, bez „zębów”), bo klin seeda 119 160×160 (71–72) nie
  pasował do okna 100/000/001. Potem (CienMgly, „reguła narożnika zastępuje regułę grubości”) usunięty
  warunek grubości 3–5 i „schodka o 1” — skos wyłącznie z narożnika (seed 118945 160×160, (16,53) grubości 6).
  Flagi do porównań: `slope_2h_corner_rule`, `enable_slope_thickness` (caves.json; obie false = stan sprzed zmian).
  Kafli skosu na 10 mapach testowych 56 -> 17; decyzje usera.
- **Cień Mgły (quiz_rpg) samodzielny i jako submoduł** (2026-10-03): ścieżki niezależne od korzenia
  (`scripts/quiz_rpg_paths.gd`, UID w każdym `ext_resource`), kopie hosta w `_host/` z `.gdignore`
  (`tools/sync_host_copies.gd`, opis w `docs/module_contract.md`), `tools/make_standalone.sh`; potem
  `git subtree split` (353 commity) -> repo https://github.com/DaVideX12324/CienMgly, podpięte jako submoduł
  `modules/quiz_rpg` (d32a856). W submodule własne `.gitignore` (`/.godot/`, `/tests/`, `/project.godot`) i
  `.gitattributes` (LF) — reguły hosta go nie obejmują. Diagnostyki `tests/` dalej tylko lokalnie.
  Praca: commit + push w submodule, potem wskaźnik w hoście; po zmianach zasobów hosta — ponowny sync.
- Flagi generatora `room_shape` i `entrance_mode` (2026-10-04): kształt pokoi `organic` (domyślnie, jak dotąd) /
  `rect` / `round` / `mixed` (losowo per pokój) — `RoomCarverFactory` + `RectRoomCarver`, `RoundRoomCarver`,
  `MixedRoomCarver`; wejście `edge` (domyślnie, wnęka przy krawędzi) / `center` — `PortalGenerator.carve_portal_in_room`:
  strefa 5×5 w pokoju najbliżej środka mapy (pokoje o boku ≥ 10, gdy są), bez wnęki; wyjście przy krawędzi w
  pokoju najdalszym od wejścia. Obie flagi w JSON-ie biomu (`flags`), domyślne = wynik bez zmian (MD5 topologii
  3 seedów identyczne). Ścieki (`sewer.json`) używają `entrance_mode: center`
  (decyzja autora, 2026-10-03).
- Etap `entities` i ostrzeżenie „re-save this scene” przy `slime_tutorial` (sprawdzone 2026-10-04): scena
  zapisana ponownie w edytorze (028bafc, c205e80); Godot 4.7.2 tworzy ją bez ostrzeżeń, ~0,2 ms na instancję.
- Kolizje wrogów w `tutorial_area.tscn` (sprawdzone 2026-10-04): nadpisania `collision_mask = 5` usunięte
  w c205e80 — instancje biorą 39 z `enemy.tscn`.
- Nisze przy ścianie o głębokości 3 (2026-10-03, 8649546, 4788812, 56b329f): rząd -3 to tam szczyt ściany,
  a korona niszy wycinała w nim ciemny ząbek (seed 103107 160×160, (85, 113)). Teraz to nisza OUT bez korony,
  nigdy sekretna, będąca przejściem (szansa `passage_niche_spawn_chance`); kafle przejścia dostają alternatywę 1.
- Ostrzeżenia „invalid UID” (2026-10-03, e37c940): 293 odwołania w 37 plikach (wrogowie, kafelki pustyni,
  obiekty, gracz) poprawione na UID-y z `.import`.
- Sterowanie per moduł (2026-10-02, ba3d490): Opcje -> „Sterowanie” — sekcje z pola `controls` w
  `module_manifest.json`; z menu głównego wszystkie moduły, z modułu tylko jego (BitBomber: 7c87f4f).
- Opcje w menu Quiz RPG (2026-10-02, 888d682): przycisk „Opcje” otwiera okno opcji hosta (jak z menu Esc).
- Edytor pytań (2026-10-02, 278f906, 3866fb5, 3d2108c): menu główne hosta -> „Pytania” (zestawy:
  nowy / import JSON z raportem pominiętych / eksport / nazwa / usuń lub przywróć oryginał; pytania 5 typów:
  dodaj / edytuj / duplikuj / usuń / włącz-wyłącz), Opcje -> „Pytania” (zestawy używane w grze). Dane:
  `scripts/core/question_bank.gd` (user://quizzes, user://quiz_selection.json — wybór globalny). Gra losuje
  z przypisanego zestawu, gdy aktywny, inaczej ze wszystkich aktywnych (domyślnie inf_podst = jak dawniej).
- UI walki WYSIWYG (2026-09-30, 157473c, d914538, 7e61f2f): wygląd w quiz_combat_ui.tscn + motyw
  resources/ui/quiz_theme.tres; pola walki per tło w `<grafika>_layout.tres` (BattleBackgroundLayout:
  lista pól BattleField — trapezy z rzędami, pojemnością i skalą głębi, 622a098) — edycja graficzna w
  scenes/tools/battle_layout_preview.tscn (narożniki „eksplodujące” do NaN — 9b00207; lista grafik
  i liczba wrogów na pole w podglądzie — 169e294; szczegóły: docs/kontekst/walka.md). Dawne „wrogowie za nisko” (kontroler nadpisywał scenę
  wartościami z kodu tła) i „marginesy pola walki per tło jako .tres” — rozwiązane tym samym.
- Freeze po pokonaniu potwora (2026-09-30, aa8d686): na mapie gracz stał, aż wróg zniknie (stan EXPLORING
  dopiero po animacji). Teraz rusza od razu i ma 5 s nietykalności na kolejne walki (miga). Czekanie na
  ekranie walki (komunikaty zwycięstwa, pomijalne Enterem) zostaje — decyzja usera. XP było dodawane dwa
  razy (ekran walki + mapa) — zostało tylko na ekranie walki (1673bde).
- Spłaszczanie wybrzuszeń (`ShortBulgeFlattenPass`, flaga `enable_bulge_flatten`) usunięte 2026-09-29
  (decyzja usera po porównaniu par z przebiegiem / bez): kształty ścian zostają naturalne, a kafle
  poprawiają wymuszone 2H małych filarów i `ShortLedgeRaisePass`.
- Wąskie wypustki 2H przy licu 3H+ (seed 118945 160×160 bez spłaszczania, nad (76, 97)) — kawałek lica
  o grubości 2 i szerokości 1–2 obok kolumny 3H+ na tej samej stopie. `ShortLedgeRaisePass` (flaga
  `enable_ledge_fix`) podnosi go do 3H (kratka nad nim -> ściana, gdy zostają nad nią 2 kratki podłogi),
  inaczej usuwa; małe wolnostojące wyspy (<= 25 kratek) pomija.
- Małe przekrzywione filary (seed 118945 160×160, (118–121, 89–92); bez `ShortBulgeFlattenPass` więcej
  takich, np. (127, 107) 2/4/5/3/2) — mieszanka 2H / łącznik / 3H. Mała wolnostojąca wyspa ściany
  (pole <= 25, <= 6 kolumn, kolumny <= 5 — flagi `small_pillar_2h_*`) z górami i dołami kolumn w różnych
  rzędach dostaje zawsze lico 2H, bez łączników (`EdgeAnalyzer.small_wall_islands` / `_skewed`,
  `GenerationContext.force_2h_cells`). Filary o równej górze (np. 2/3/3/3/2), szersze pasy skały i wysokie
  bryły zostają przy 3H. Siatka bez zmian (tylko kafle).
- Fasada płaskowyżu tuż za ścianą jaskini (seed 119 250×250, (48–51, 74–75)) — lico płaskowyżu, którego
  górna kratka wypada na górze modułu ściany głównej (rim / najwyższa część lica, nie narożnik out), jest
  wchłaniane (`PlateauRenderer._on_wall_top`); sąsiednia kolumna dostaje zakończenie lica.
- Zasięg wykrywania wroga niewidoczny / zły przy „Visible Collision Shapes” — kształt `DetectionArea`
  był współdzielony przez wszystkie instancje `enemy.tscn` (promień ustawiał ostatni wróg). Teraz
  `resource_local_to_scene` + setter `detection_radius` (zmiana w trakcie gry od razu zmienia okrąg).
  Test `diag_detection_radius.gd`. Podglądu w edytorze nie ma (osobny węzeł `@tool`, jeśli potrzebny).
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
- Freeze świata po ucieczce / porażce (2026-10-11): `EnemyBase.on_combat_finished` zmieniał stan na EXPLORING dopiero po 2 s postoju wroga. Teraz od razu (jak po wygranej), gracz dostaje nietykalność, wróg stoi 2 s. Test `check_flee_unfreeze`.
