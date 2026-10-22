# Ekwipunek i progresja — szkic modelu (do oceny)

Stan: propozycja z 2026-10-12; **skala drabiny (decyzja druga) wdrożona 2026-10-21 — sekcja 12**; sekcje 1–3 i 8 opisują stan sprzed niej. Odpowiada na brief „Ekwipunek i progresja — kontekst oraz zadanie dla Claude”.
Sekcja 1 to stan faktyczny z kodu (ścieżki względem `modules/quiz_rpg/`). Wszystkie nazwy i liczby w propozycjach są przykładowe.
Liczby scenariuszy pochodzą z `tests/diag_gear_scenarios.gd` (lokalny, nie w repo): te same wzory co w grze, bez losowości i krytyków.

## 1. Stan faktyczny

**Statystyki i wzory**
- Postać: `scripts/heroes/hero_data.gd`: ATK 21 + 1,95 / lvl, DEF 11 + 1,1 / lvl (lv 100: 214 / 120); MAT i MDF analogicznie; HP lv 1 334, lv 20 1402, lv 100 50 000 (krzywa wykładnicza).
- Suma statystyk członka: `autoloads/player_stats.gd` `get_member_total_stat` = baza + wzrost z poziomu + suma `atk/def/mat/mdf_bonus` z pięciu slotów (`EQUIPMENT_SLOTS`: weapon, shield, head, body, accessory).
- Zwykły atak: `ATK×4 − DEF×2`, rozrzut ±10 % (`scripts/skills/skill_math.gd`). Krytyk: 15 % szans, ×1,8 (`scripts/quiz/quiz_combat_controller.gd`, `_apply_player_hit`). Umiejętności: `baza + ATK×a + MAT×m − DEF×d − MDF×md`, razy mnożnik, rozrzut, bonus losowy. Brak limitu obrażeń i przebicia procentowego.
- Wróg z poziomu: `scripts/enemies/enemy_stats.gd`. Wzorzec = bohater z krzywych **plus sprzęt idący po krzywej wykładniczej** (broń ATK 10 → 320, komplet DEF 14 → 194 od lv 1 do 100). DEF wroga = 0,7 × ATK wzorca (ze sprzętem), cios wroga = `HIT_FRAC` maks. HP bohatera.

**Przedmioty**
- Definicja: `scripts/items/item_data.gd` (`QuizRpgItemData`), 34 zasoby `.tres` w `resources/items/`. Pola: slot, `weapon_type`, `atk/def/mat/mdf_bonus`, leczenie, `allowed_classes` (nowe). **Brak** pól na efekty specjalne, rzadkość, cenę, ulepszenie.
- Ekwipunek = **stosy identyfikatorów** `{item_id, count}` (`player_stats.gd`, `inventory`, zapis w `get_save_data`). Nie ma egzemplarzy. `set_member_equipment` zdejmuje 1 z stosu i oddaje poprzedni przedmiot do stosu.
- Obecna krzywa w danych: broń **podwaja się co tier** (10, 20, 40, 80, 160, 320: `training_sword` → `iron_sword` → `steel_blade` → `knight_broadsword` → `runic_claymore` → `shadowbane_sword`); elementy pancerza (głowa, korpus, tarcza) 4, 8, 16, 32, 64 w pięciu tierach; akcesorium `lucky_charm` +2 / +2. Inne bronie (sztylet, łuk, włócznia, buława, topór) mają po jednym tierze 1 (ATK 10); `apprentice_staff`: ATK 4, MAT 10.
- To dokładnie krzywa wzorca z `enemy_stats.gd`: tier broni k pasuje do lv ≈ 1 + 19,8 × (k−1) (tier 2 ≈ lv 21, 3 ≈ 41, 4 ≈ 60, 5 ≈ 80, 6 = lv 100). Komplety pancerza (14 / 26 / 50 / 98 / 194) pasują do lv 1 / 24 / 49 / 74 / 100.

**Źródła przedmiotów**
- Wrogowie nie mają dropów. Skrzynia daje jeden stały przedmiot (`chest_item_id`, `scripts/interactables/chest.gd`; jedyna użyta: `potion` w tutorialu); `tier` skrzyni zmienia tylko trudność quizu.
- Beczki: tabela mikstur i wytrychów + `lucky_charm` 5 % (`autoloads/loot_manager.gd`, `_get_barrel_loot_table`).
- **Brak złota, sklepów, cen, NPC od ulepszeń.** Cały sprzęt powyżej startowego jest dziś osiągalny tylko z menu deweloperskiego.
- `optimize_member_equipment` (`player_stats.gd`): wynik = `atk_bonus + def_bonus`; **pomija MAT / MDF i efekty** (kostur maga liczy się jako 4 zamiast 14). Wpis zakładanego przedmiotu w `get_equippable_entries_for_slot` też niesie tylko ATK / DEF.

**Sprawdzenie założeń z notatki**
- „Zwykły wróg ginie w 3–4 trafieniach, cios ≈ 14 % HP” zachodzi **tylko dla tieru 2**. Tier 1: 1,5 trafienia / 10 %, tier 3: 6 / 16 %, tier 4 (boss): 12 / 15 % (`enemy_stats.gd`, `HITS_TO_KILL`, `HIT_FRAC`). To dla wzorca; faktyczna liczba trafień zależy od sprzętu gracza.
- Roboczy bonus „≈ 1,5 × ATK, 1,6 × DEF” zachodzi **tylko na lv 100** (320 / 214 = 1,50; 194 / 120 = 1,62). Wcześniej udział sprzętu jest mały (tabela niżej).

## 2. Diagnoza

Działa: sumowanie bonusów ze slotów, klasy (od dziś), krzywa wzorcowa, na której stoją statystyki wrogów. Brakuje: **jakiegokolwiek źródła sprzętu w grze** (dropy, sklepy, nagrody), ulepszeń, efektów specjalnych, rzadkości, poprawnego `optimize`. Obecny format (stos `item_id` + `.tres`) wystarcza do zwykłego sprzętu i do ulepszeń „etapami”, bo etap może być osobnym `item_id` (sekcja 5).

Najważniejszy wniosek z liczb: **sprzęt w tej grze jest krytyczny dopiero w drugiej połowie**, a obrażenia rosną nadliniowo wraz z mocą broni, bo DEF wroga jest liczony od ATK wzorca ze sprzętem.

Udział sprzętu wzorcowego w statystyce całkowitej i skutek braku sprzętu (trafienia do zabicia wroga tieru 2 przy sprzęcie wzorcowym = 4,0):

| Poziom | sprzęt w ATK | sprzęt w DEF | bez sprzętu: trafienia (t2) | 1 tier w tyle (×0,5): trafienia (t2) |
|---|---|---|---|---|
| 8 | 27 % | 47 % | 6,8 | 5,0 |
| 20 | 25 % | 42 % | 6,5 | 5,0 |
| 40 | 29 % | 42 % | 7,2 | 5,1 |
| 60 | 37 % | 47 % | 9,2 | 5,6 |
| 80 | 48 % | 54 % | 14,9 | 6,3 |
| 100 | 60 % | 62 % | 51,2 | 7,4 |

Czyli na lv 8–40 brak sprzętu to ok. +60–80 % trafień, a od lv 80 jest to różnica między grywalnym a niegrywalnym. Jeśli „bardzo ważny ekwipunek” ma być odczuwalny także wcześnie, trzeba zmienić `GEAR_*` w `enemy_stats.gd` (np. wyższy start krzywej); to jedna decyzja, nie przepisywanie systemu.

## 3. Standardowy sprzęt: budżet według mapy

Punkt projektowy = **oczekiwany poziom lokacji** (tabela budżetu z `poziomy_i_xp.md`, nie poziom gracza ani procent wyczyszczenia mapy). Zwykły sprzęt mapy m ma moc z krzywej wzorca w poziomie lokacji; rozmiar mapy i liczba wrogów nie wpływają na moc (XP jest normalizowany po spawnach, sprzęt **nie**).

Wzrost krzywej to **×1,256 ATK i ×1,188 DEF na mapę**. Przydatna jednostka: „moc mapy k” = budżet zwykłego sprzętu z mapy k. Rzadkość da się wtedy wyrazić w mapach, a nie w mnożniku: rzadkie ≈ moc mapy m+1..m+2 (+25–55 %), a nie „×1,7”.

| Mapa | lv start → koniec | broń ATK (start / koniec) | komplet DEF (start / koniec) | DEF / element (koniec) |
|---|---|---|---|---|
| 1 | 1,0 → 8,5 | 10 / 13 | 14 / 17 | 5 |
| 2 | 8,5 → 15,0 | 13 / 16 | 17 / 20 | 6 |
| 3 | 15,0 → 21,6 | 16 / 21 | 20 / 24 | 7 |
| 4 | 21,6 → 28,1 | 21 / 26 | 24 / 29 | 9 |
| 5 | 28,1 → 34,6 | 26 / 32 | 29 / 34 | 11 |
| 6 | 34,6 → 41,2 | 32 / 41 | 34 / 41 | 13 |
| 7 | 41,2 → 47,7 | 41 / 51 | 41 / 48 | 15 |
| 8 | 47,7 → 54,2 | 51 / 64 | 48 / 57 | 18 |
| 9 | 54,2 → 60,8 | 64 / 81 | 57 / 69 | 22 |
| 10 | 60,8 → 67,3 | 81 / 102 | 69 / 81 | 26 |
| 11 | 67,3 → 73,9 | 102 / 128 | 81 / 97 | 32 |
| 12 | 73,9 → 80,4 | 128 / 161 | 97 / 115 | 38 |
| 13 | 80,4 → 86,9 | 161 / 202 | 115 / 137 | 45 |
| 14 | 86,9 → 93,5 | 202 / 255 | 137 / 163 | 54 |
| 15 | 93,5 → 100,0 | 255 / 320 | 163 / 194 | 64 |

**Podział między sloty** (propozycja, zgodna z danymi): cały zestaw DEF dzieli się po równo na głowę, korpus i tarczę (jak dziś: 64 / 64 / 64 + akcesorium 2); cały ATK idzie w broń (dla Maga i Kapłana ten sam budżet w MAT). Oznacza to, że **ofensywa zależy w 100 % od jednego slotu**, a obrona od trzech. Dlatego wymiana broni jest największą pojedynczą zmianą mocy, a wyjątkowe bronie (sekcja 4) są tak silne.
Akcesorium zostaje poza budżetem statystyk: dobre miejsce na małe bonusy i efekty specjalne (niezależne od mapy).

**Ocena proporcji 1,5 × ATK / 1,6 × DEF:** to wynik końca krzywej, nie wzór. Gdyby stosować ją na każdym poziomie (sprzęt = 1,5 × baza), broń na lv 8 miałaby +52 ATK zamiast +13 (wróg wzorcowy rósłby razem z nią, więc stosunek w walce byłby ten sam), a od pierwszych minut 60 % ATK pochodziłoby ze sprzętu. Zostawiłbym **krzywą wykładniczą z kodu** i traktował 1,5 / 1,6 jako opis lv 100. Jeśli chcesz, żeby sprzęt ważył więcej już na początku, to zmiana `GEAR_ATK_START` / `GEAR_DEF_START` (sekcja 2), a nie stała proporcja.
Mniejsza uwaga: tiery broni podwajają się co ≈ 20 poziomów (≈ 3 mapy), komplety pancerza co ≈ 25. Przy 15 mapach to ok. 5 pełnych tierów + wartości pośrednie; pośrednie wartości z tabeli wyżej (np. 26 ATK na mapie 4) trzeba wpisać do danych, bo dziś istnieją tylko tiery pełne.

## 4. Wyjątkowe bronie i ulepszenia u NPC

Pojęcia rozdzielone w danych i projekcie: **dostępność** (gdzie leży: skrzynia, boss, quest, sekret — tabela źródeł, nie pole przedmiotu), **rzadkość** (tylko etykieta UI / koloru, bez wpływu na statystyki), **moc początkowa** i **potencjał końcowy** (statystyki etapu 0 i ostatniego), **ścieżka ulepszeń** (kolejne etapy i ich koszt), **specjalizacja** (`allowed_classes`, `weapon_type`, efekt).

Wszystkie warianty poniżej są opcjonalne i mogą współistnieć. Przykłady (nazwy i liczby przykładowe), moc w ATK broni:

| Wariant | Przykład | Zdobycie | Moc początkowa → etapy → końcowa |
|---|---|---|---|
| Zwykła, wymieniana | „Stalowy Kord” | skrzynia / sklep mapy 3 | 18 (moc mapy 3) → kolejna broń z mapy 4–5 ją wypiera |
| Wczesna rzadka, rozwijana do endgame | „Żarzące Ostrze” | boss minimapy w mapie 3, raz | 32 (moc mapy 5) → **etap 2 u kowala: 64 (mapa 8)** → **etap 3: 128 (mapa 12)** → **etap 4: 330** (≈ moc mapy 15 + 3 %); każdy etap wymaga warunku fabularnego i/lub unikalnego materiału z konkretnego bossa lub skrzyni, nie powtarzalnego grindu |
| Gotowa broń endgame, wyjątkowa nagroda | „Szept Mgły” | sekretna komnata w mapie 7 (wymaga skilla-klucza) | 320 od razu; brak ulepszeń |
| Sekret ponad budżet | „Pieczęć Arcymaga” | prawdziwe zakończenie | 480 (+50 % ponad koniec krzywej); brak ulepszeń |
| Niski ATK, silny efekt | „Kostur Skupienia” | quest drużyny | ATK 60 % standardu mapy, efekt: np. +X % szansy trafienia z quizu (wymaga pola efektu) |

**Konsekwencje wyjątkowych mocy (liczby z diagnostyki, wróg tieru 2 / tieru 4 = boss, trafienia do zabicia):**

| Broń | lv 8 | lv 20 | lv 40 | lv 60 | lv 80 | lv 100 |
|---|---|---|---|---|---|---|
| standard mapy (wzorzec) | 4,0 / 12,0 | 4,0 / 12,0 | 4,0 / 12,0 | 4,0 / 12,0 | 4,0 / 12,0 | 4,0 / 12,0 |
| rzadka +25 % (≈ +1 mapa) | 3,6 / 10,9 | 3,6 / 10,9 | 3,6 / 10,8 | 3,5 / 10,5 | 3,4 / 10,1 | 3,3 / 9,8 |
| sama broń ×2 | 2,8 / 8,5 | 2,9 / 8,7 | 2,8 / 8,3 | 2,6 / 7,7 | 2,3 / 6,9 | 2,1 / 6,2 |
| **broń 320 ATK zdobyta od razu** | **0,4 / 1,1** | **0,6 / 1,7** | **1,0 / 2,9** | 1,5 / 4,4 | 2,3 / 6,9 | 4,0 / 12,0 |
| sekret 480 ATK na lv 100 | | | | | | 2,7 / 8,2 |

Wnioski (stan faktyczny z wzorów, nie ocena):
- **Gotowa broń endgame zdobyta wcześnie** praktycznie wyłącza walkę ofensywnie od lv 8 do ok. 60: zwykły wróg ginie w jednym uderzeniu, boss w 1–3 trafieniach (wróg nie ma dodatkowej obrony, bo jego DEF = 0,7 × ATK wzorca bez tej broni, wzór `4A − 2D` rośnie liniowo z A). Obrażenia otrzymywane się nie zmieniają. Niska szansa dropu nie ogranicza mocy po zdobyciu. Od lv 80 broń przestaje się wyróżniać, bo standard dogania ją (to ten sam punkt krzywej).
- **Sekret ponad budżet na końcu** jest tani: +50 % nad koniec to ok. −32 % trafień (boss 12 → 8,2), a nie „god mode”. Silne nagrody na końcu krzywej nie psują kampanii, wczesne tak.
- Bronie 2–3× mocniejsze od standardu to wyraźny, ale nieburzący przeskok (zwykły wróg 4 → 2–3 trafień, boss 12 → 6–8) — poziom mocy „rzadkiej nagrody”.

Opcjonalne sposoby ograniczenia wczesnego endgame (nie dodawać automatycznie, wybór decyzją): (a) broń ma wymóg poziomu postaci (`required_level`) albo działa pełną mocą dopiero od określonego etapu; (b) broń startuje słabo i rośnie przez ulepszenia (wariant „Żarzące Ostrze”); (c) jej siła leży w efekcie, a ATK jest niski; (d) wejście do miejsca z bronią wymaga skilla / klucza, który i tak stoi późno w kampanii; (e) kosztowne użycie (SP / TP) tylko dla wybranych broni. Wszystkie rozwiązują ten sam problem inaczej; różnią się tym, czy gracz „czuje się nagrodzony” wcześnie czy późno.

## 5. Minimalny model danych

Dopasowany do obecnej architektury (stosy `item_id`, bez egzemplarzy):
- **Etap ulepszenia = osobny `item_id`** (np. `ember_blade_1` … `ember_blade_4`), każdy `.tres` ze statystykami etapu. Dwie kopie na różnych etapach to dwa różne stosy, więc stan nie jest wspólny dla definicji, a **zapis nie wymaga zmian**. Egzemplarze z losowymi afiksami / indywidualnym stanem nie są potrzebne dopóki nie ma takiej potrzeby.
- Nowe pola w `QuizRpgItemData` (wszystkie opcjonalne, domyślnie puste, więc obecne przedmioty nie zmieniają zachowania):
  - `rarity` (enum tylko do UI / koloru nazwy; bez wpływu na staty),
  - `budget_map` (int, 0 = poza krzywą): w jakiej „mocy mapy” jest zaprojektowany; służy testom i dokumentacji, nie skaluje przedmiotu w grze,
  - `required_level` (int, 0 = brak): opcjonalny wymóg, jeśli zdecydujesz o (a) z sekcji 4,
  - `upgrade_to` (item_id następnego etapu) i `upgrade_requirements` (mały zasób lub słownik: przedmioty-materiały, flaga fabularna; **bez złota**, bo go w grze nie ma),
  - na później: efekty specjalne (struktura jak `QuizRpgStatusData` / pasywy) — nie w pierwszym kroku.
- **Receptura ulepszenia** to dane NPC-a (lista `upgrade_to` + wymagania), nie osobny obiekt; wykonanie: zabierz stos etapu N + materiały, dodaj etap N+1, zachowaj założenie jeśli było założone (`set_member_equipment`).
- Źródła (**dostępność**) trzymać w danych map / skrzyń / bossów (np. lista `loot` w JSON mapy), nie w przedmiocie: ten sam przedmiot może leżeć w skrzyni, w sklepie i jako nagroda.
- Poprawić `optimize`: wynik = ważona suma wszystkich czterech statystyk (z uwzględnieniem klasy, np. mag liczy MAT), z możliwością dopisania efektu później.
- Nie skalować znalezionego przedmiotu z poziomem gracza (zgodnie z ustaleniem): moc przedmiotu to stała z `.tres`.

## 6. Testy balansu

Rozszerzyć `diag_gear_scenarios.gd` do testu (`check_gear_budget`) liczonego na prawdziwych wzorach (`QuizRpgSkillMath.basic_attack` ze stałym rozrzutem, `QuizRpgEnemyStats`):
1. **Trafienia i tury:** dla lv 8 / 20 / 40 / 60 / 80 / 100 i tierów wroga 1–4: ile trafień do zabicia i jaką część HP zabiera cios — zestawy: zwykły (z tabeli), przestarzały (1 i 2 mapy w tyle), rzadki (+1 mapa), wyjątkowo mocny (320 ATK od razu, sekret 480).
2. **Długość walki quizowej:** tury = ⌈trafienia / szansa trafienia (z quizu)⌉; szansę odczytać z kontrolera; liczyć też krytyk (15 %, ×1,8) jako średnią (×1,12).
3. **Progi:** zwykły sprzęt wzorcowy: wróg tieru 2 w 3–5 trafieniach i cios 13–15 % HP; przestarzały o 1 mapę: ≤ ×1,5 trafień; o 2 mapy: ≤ ×2; wyjątkowa broń: tylko raport, nie próg (świadoma decyzja projektowa).
4. **Wczesne zdobycie:** raport „broń endgame na lv 8 / 20 / 40” (jak tabela w sekcji 4) przy każdej zmianie krzywej.
5. **Dostępność bez czyszczenia map:** test na danych map: każdy etap zwykłego sprzętu jest osiągalny przez źródło niezależne od „120 % wrogów” (skrzynia / boss / sklep po fabule); ulepszenie nie wymaga powtarzalnego grindu (materiały jednorazowe, flagi fabularne).
6. **Zgodność danych:** przedmioty z `budget_map` mieszczą się w ±15 % budżetu mapy z tabeli (poza wyjątkowymi, oznaczonymi `rarity`).

## 7. Plan wdrożenia (małe etapy)

1. **E0 (drobne, bez decyzji):** naprawa `optimize` (wszystkie cztery statystyki, wpis zakładanego przedmiotu z MAT / MDF). Test.
2. **E1:** wspólna funkcja krzywej sprzętu (jedno źródło prawdy zamiast stałych `GEAR_*` w `enemy_stats.gd` i liczb w danych); tabela budżetu 15 map jako dane; `check_gear_budget` z progami 1–3 i 6. Bez nowych przedmiotów.
3. **E2 (prototyp):** zwykły sprzęt dla map 1–2 (pośrednie wartości z tabeli, np. po 2–3 przedmioty na slot), źródła: skrzynie / boss minimapy z listą łupu w JSON mapy (skrzynia dziś ma jeden stały przedmiot — rozszerzenie na `loot` mapy); sklepy i złoto tylko jeśli pierwsza decyzja z sekcji 10 brzmi „tak” (wtedy E2 obejmuje złoto w `PlayerStats` i zapisie, drop złota i prosty sklep).
4. **E3:** **jedna broń rozwijana do endgame** (np. „Żarzące Ostrze”: 4 etapy jako 4 `.tres` + `upgrade_to`), ulepszanie przez funkcję w `PlayerStats` i tymczasowy punkt wywołania (menu deweloperskie, NPC dopiero gdy powstanie hub / miasto). Test „etap zmienia długość walki”.
5. **E4:** wyjątkowe bronie wg wybranej opcji z sekcji 4 (jedna gotowa endgame jako test wczesnego zdobycia, jedna sekretna ponad budżet), potem efekty specjalne i rozszerzenie na pozostałe mapy (dane do Gemini po ustaleniu wzorców).

**Trade-offy:** stały `item_id` per etap jest najprostszy i nie rusza zapisu, ale każda zmiana etapu to nowy plik (przy dużej liczbie broni szablonowanie danych skryptem); egzemplarze z indywidualnym stanem dałyby swobodę, ale zmieniłyby zapis i UI. Zostaję przy etapach, dopóki nie ma wymagań, których to nie spełnia.

## 8. Wejście usera: poziom daje statystyki, ale mniej niż sprzęt (FNaFB 1 FM, 2026-10-12)

User: we FNaFB 1 FM awans podnosił głównie pulę HP i SP (żeby wytrzymać więcej walk bez zużywania przedmiotów), a siła pochodziła ze sprzętu kupowanego za zebrane pieniądze;
poziom też dawał statystyki, ale **nie aż tak dużą różnicę jak wyposażenie**.

Sprawdzenie na obecnych krzywych (przyrost od lv 1: z poziomu vs z krzywej sprzętu wzorcowego):

| Poziom | ATK z poziomu (+1,95 / lvl) | ATK ze sprzętu (10 → G) | DEF z poziomu (+1,1 / lvl) | DEF ze sprzętu (14 → G) |
|---|---|---|---|---|
| 20 | +37 | +9 | +21 | +9 |
| 40 | +76 | +29 | +43 | +25 |
| 60 | +115 | +69 | +65 | +53 |
| 80 | +154 | +149 | +87 | +100 |
| 100 | +193 | +310 | +109 | +180 |

Czyli **dziś poziom daje więcej statystyk niż sprzęt aż do ok. lv 80**; sprzęt przeważa dopiero na końcu. Porównanie z FNaFB trzeba robić koniec z końcem (FNaFB lv 20 = koniec gry, u nas lv 100): w FNaFB1 na końcu sprzęt kupowalny daje ok. 4 × więcej przyrostu ATK niż poziomy (+150 vs +37), a rzadki drop ok. 8 × (+310), u nas na końcu 1,6 × (+310 vs +193). Skok jednego tieru broni (podwojenie, co ≈ 20 poziomów) to +19 ATK na lv 20, czyli mniej niż 20 poziomów awansu (+39 ATK).
Żeby sprzęt przeważał wcześniej, są dwie niezależne dźwignie: zmniejszyć `atk_per_level` / `def_per_level` (np. 0,5 dla ATK: przyrost z 20 poziomów między tierami to +10 zamiast +39, a krok tieru broni na lv 20 to +19 — sprzęt około dwa razy większy od poziomów; DEF analogicznie przy 0,3) albo podnieść początek krzywej sprzętu (`GEAR_*_START`). Obie zmieniają też wzorzec wrogów, więc stosunek w walce zostaje, a liczby w grze się przesuwają.

**Wariant graniczny** (poziom daje tylko HP / SP, `atk_per_level` / `def_per_level` = 0, stałe 21 / 11) — dla porównania, żeby widać było konsekwencje maksymalnej wagi sprzętu:
Obliczenia na wzorach z kodu (wróg wzorcowy liczony tak samo, więc liczby względne):

Trafienia do zabicia wroga tieru 2 zależnie od mocy sprzętu gracza (1,0 = wzorzec / 0,5 / 0,25 / bez sprzętu), `DEF_RATIO` 0,7 (obecne) i 0,4 (łagodniejsze):

| Poziom | DEF_RATIO 0,7 | DEF_RATIO 0,4 |
|---|---|---|
| 8 | 4,0 / 5,6 / 7,1 / 9,6 | 4,0 / 5,2 / 6,2 / 7,6 |
| 20 | 4,0 / 6,3 / 9,0 / 15,4 | 4,0 / 5,7 / 7,3 / 10,0 |
| 40 | 4,0 / 8,0 / 16,1 / **626** | 4,0 / 6,7 / 10,3 / 21,5 |
| 60 | 4,0 / 10,2 / 45 / **1039** | 4,0 / 7,9 / 15,4 / **313** |
| 80 | 4,0 / 12,5 / **1871** / 1871 | 4,0 / 8,9 / 23,3 / **2303** |
| 100 | 4,0 / 14,4 / **3546** / 3546 | 4,0 / 9,7 / 33,3 / **4365** |

(Wartości powyżej ~100 trafień znaczą „1 obrażenie na trafienie”, czyli walka niewykonalna.)

Wnioski:
- Wariant jest spójny z ustaleniem „ekwipunek bardzo ważny”: sprzęt ma 100 % wagi na każdym poziomie, a awans służy przetrwaniu (HP / SP). Wymaga jednak **pewnego źródła sprzętu** (sklepy za zdobywane pieniądze, jak FNaFB): gracz o jeden tier w tyle walczy 3,6 × dłużej, o dwa tiery od lv 40 praktycznie nie zadaje obrażeń. Skrzynie i dropy losowe nie wystarczą jako jedyne źródło. Złota i sklepów dziś w grze nie ma.
- Klif jest tak stromy, bo DEF wroga liczy się od ATK wzorca (`DEF_RATIO` 0,7): wzór `4A − 2D` daje 0 przy A < 0,35 × ATK wzorca. Przy `DEF_RATIO` 0,4 klif jest łagodniejszy, ale nie znika.
- **Pancerz już dziś prawie nie wpływa na przeżywalność późno:** cios wroga tieru 2 to 14,0 % HP ze sprzętem wzorcowym, a bez żadnego pancerza 19,3 % na lv 8, 16,0 % na lv 40 i tylko **14,8 % na lv 100**. Powód: cios wroga jest wyprowadzany z ułamka jego HP (`HIT_FRAC` × HP bohatera), a HP rośnie wykładniczo do 50 000, podczas gdy DEF rośnie do ok. 300. Budżet DEF z tabeli w sekcji 3 będzie więc prawie kosmetyczny, jeśli nic nie zmienimy. Jeśli pancerz ma realnie bronić (szczególnie w wariancie „jak FNaFB”), trzeba zmienić definicję ciosu wroga w `enemy_stats.gd` (np. ATK wroga z własnej krzywej, nie z ułamka HP bohatera, albo DEF jako procentowa redukcja).

## 9. Dane FNaFB 1: sklepy, dropy, waluta i tempo (wczytane z `Weapons` / `Armors` / `Enemies` / `Items` / mapy `.rvdata2`, 2026-10-12)

Uwaga o skali: FNaFB1 kończy się na **lv 20**, nasza gra na **lv 100**; porównania robię koniec z końcem. Poprawione po uwagach usera: **Kingly Microphone nie jest do kupienia — to rzadki drop z potworów.**

**Sprzęt kupowalny** (kod sklepu 302 w mapach): tylko 4 sklepy w lokacjach, po jednym tierze każdy:

| Lokacja (mapa) | Broń (ATK) / cena | Pancerz (DEF) / cena |
|---|---|---|
| start (Classic) | 10 / — | 4 / — |
| Backroom (mapa 3) | Bronze 20 / 10 | 8 / 10 |
| Restrooms (mapa 5) | Silver 40 / 20 | 16 / 20 |
| Supply Closet (mapa 6) | Gold 80 / 40 | 32 / 40 |
| East Hall Corner (mapa 10) | Platinum 160 / 80 | 64 / 80 |

**Pułap sklepu to broń 160 ATK i pancerz 64 DEF na element.** Nic ponad to nie jest w sprzedaży.

**Rzadkie dropy** (`Enemies.rvdata2`, tabele łupu):
- **Broń ostateczna jednego członka drużyny na tier wroga** (zgodnie z opisem usera: po jednej broni ostatecznej dla każdego członka, każdy tier przeciwników ma szansę na drop konkretnej broni): Alpha Party Hat → Kingly Hook (1/80), Beta → Everything Cupcakes (1/80), Gamma → Kingly Guitar (1/120), Omega → Kingly Microphone (1/80); wszystkie 320 ATK. Cztery rodzaje broni = cztery postacie, cztery tiery wroga = cztery bronie. W drugim zestawie tych samych wrogów (id 32–35, prawdopodobnie osobna strefa) szansa jest **1/4**.
- **Godly** (500 ATK, **+500 HP, +500 SP, +50 DEF / MAT / MDF, +100 AGI / LUK**; też po jednej na postać): każdy z czterech „Ace” (bossowie) dropi jedną (Microphone 1/40, Guitar 1/60, Cupcakes 1/40, Hook 1/40); w drugim zestawie Party Hatów 1/8–1/16.
- Kingly może wypaść już z Alpha Party Hat, czyli z najsłabszego wroga na początku (1/80), **bez wymogu poziomu**. Gotowa broń endgame zdobyta wcześnie jest więc w FNaFB dopuszczona jako szczęśliwy los.
- Sekretna broń z kosztem (ATK 500, LUK 500, **HP −5000, DEF −500, MDF −500**) oraz seria „A–F” (50 / 100 / 200 / 300 / 400 / 500 do wszystkich statystyk): to dowód, że FNaFB ma i warianty z karą, i drabinę ulepszeń.

**Waluta i tempo** (złoto z Party Hatów 5 / 10 / 20 / 40, XP 200 / 400 / 800 / 1600):
- Cena kolejnego tieru kupowalnego = **2 zabicia potworów z aktualnej lokacji** (Bronze 10 = 2 Alpha, Silver 20 = 2 Beta, Gold 40 = 2 Gamma, Platinum 80 = 2 Omega). Poziom: lv 5 → 2,4 Beta, lv 10 → 4,4 Gamma, lv 15 → 4,9 Omega, lv 19 → 7,8 Omega. Barierą nie jest kwota (złoto z potworów podwaja się razem z cenami), tylko **dostęp do sklepu lokacji**.
- Złoto ma też wydatki poza sprzętem: mikstury (pizze 2–50, napoje 3–80), prezent / ciasto 20–50 oraz **stałe wzmocnienia** po 100 złota: HP Boost +50 maks. HP, MP Boost +50 SP, Attack Boost +5 ATK, Defense Boost +5 DEF (+5 ATK to ok. 2,5 poziomu przyrostu Freddy’ego).

**Siła sprzętu względem poziomu, koniec z końcem** (Freddy lv 20: ATK 58, DEF 32; przyrost z poziomów +37 ATK):

| Zestaw | ATK całkowity | udział sprzętu | sprzęt / przyrost z poziomów |
|---|---|---|---|
| FNaFB1: pułap sklepu (160) | 218 | 73 % | 4,3 × |
| FNaFB1: Kingly (320, drop) | 378 | 85 % | 8,6 × |
| FNaFB1: Godly (500, drop) | 558 | 90 % | 13,5 × |
| Nasz wzorzec na lv 100 (320 / baza 214) | 534 | 60 % | 1,6 × |

Wniosek: nasz „standardowy pułap” 320 ATK to w FNaFB wartość **rzadkiego dropu**, nie sklepu. Tier 6 w naszych danych (`shadowbane_sword` 320) odpowiada więc Kingly, a nie Platinum. Żeby uzyskać proporcje FNaFB przy 100 poziomach i bazie ATK 214, pułap sklepu to ok. 2,8 × baza ≈ **600 ATK**, rzadki drop ≈ 2 × pułap ≈ **1200**, najrzadszy ≈ 3,1 × pułap ≈ **1850** (z bonusami do HP / SP). Albo odwrotnie: zmniejszamy przyrost z poziomu (sekcja 8). To dwie dźwignie jednego problemu, nie dwa problemy.

**Propozycja dla nas** (wszystko przykładowe, do zatwierdzenia), wprost wzorowana na tej strukturze:
- **Sklep w lokacji sprzedaje jeden tier standardowego sprzętu tej lokacji** (jak FNaFB: 4 sklepy = 4 tiery kupowalne), pułap sklepu = standardowy sprzęt końca kampanii (np. 600 ATK po wydłużeniu drabiny, sekcja wyżej). Cena ≈ 2 zabicia zwykłych wrogów tej lokacji: złoto z wroga = `GOLD_PER_ATK` (w kodzie 2,0; stała dowolna, ceny liczy się w „zabiciach”) × ATK_standard(poziom wroga) × waga tieru (0,6 / 1,0 / 1,6, boss ×6), normalizacja po liczbie spawnów jak XP (`QuizRpgEnemyGold`).
- **Rzadki drop ponad pułap sklepu** (Kingly): osobna tabela łupu wrogów z małą szansą (np. 1/80 jak FNaFB, bez wymogu poziomu), moc ≈ 2 × pułap. W tabeli sekcji 4 to scenariusz „sama broń ×2”: wróg tieru 2 ginie w 2,1–2,9 trafień zamiast 4, boss w 6,2–8,7 zamiast 12.
- **Najrzadszy** (Godly): drop z bossów (np. 1/40–1/60) lub sekret, ≈ 3 × pułap, z bonusami do HP / SP (wielostatystyczna broń).
- **Wzmocnienia stałe za złoto** (HP / SP / ATK / DEF Boost) jako dodatkowy wydatek, który nie wymaga nowego systemu (jednorazowy przedmiot z efektem `+stat`).
- **Warianty z karą** (jak sekretna broń z HP −5000): opcjonalne, osobne pytanie; nie dodawać automatycznie.
- Pokrętło tempa: stosunek cena / złoto z potwora (tu 2 zabicia); wyższa wartość spowalnia zakupy bez ruszania krzywych.

## 10. Jaskinie (mapa 1) bez sklepu — źródła sprzętu (decyzja usera 2026-10-12)

Sklepów nie będzie, dopóki nie odblokuje się miasta (wyjście z jaskiń), a wyjście jest daleko. Dlatego **sprzęt w jaskiniach pochodzi z dropów wrogów oraz ze skrzyń i nisz** (ukrytych). Sklep i złoto z sekcji 9 zaczynają działać po wyjściu z jaskiń.

**Stan faktyczny w kodzie:** wszystkie skrzynie wygenerowane na mapach dają dziś jeden stały przedmiot — `potion` (domyślna wartość `chest_item_id` w `scripts/interactables/chest.gd`, scena `scenes/objects/closed_chest_tutorial.tscn`); generator obiektów stawia skrzynie z preferencją nisz, ślepych zaułków i narożników (`resources/maps/config/objects_caves.json`, `per_room` 0,5), a `chest_tier` w `caves.json` zmienia tylko trudność quizu. **Wrogowie nie mają dropów.** Do zbudowania: tabela łupu skrzyń z konfiguracji mapy (pole np. `chest_loot`) i tabela łupu wrogów per tier (`enemy_loot`, nałożona jak `enemy_levels`) z nagrodą po wygranej w `quiz_combat_controller.gd` (miejsce, gdzie dziś przyznawany jest XP).

**Co daje sprzęt na poziomach jaskiń (lv 5–9, wróg tieru 1 / 2 / 3 / boss tieru 4 = trafienia do zabicia / cios w % HP; wzory z gry, bez krytyków):**

| Zestaw (lv 8) | t1 | t2 | t3 | t4 (boss) |
|---|---|---|---|---|
| start (miecz 10, komplet pancerza 14) | 1,6 / 11 % | 4,4 / 15 % | 6,6 / 17 % | 13,2 / 16 % |
| + żelazny miecz (20, tier 2) | 1,2 / 11 % | 3,2 / 15 % | 4,9 / 17 % | 9,7 / 16 % |
| + komplet pancerza tieru 2 (26) | 1,6 / 7 % | 4,4 / 11 % | 6,6 / 13 % | 13,2 / 12 % |
| miecz 20 + komplet 26 | 1,2 / 7 % | 3,2 / 11 % | 4,9 / 13 % | 9,7 / 12 % |
| topór 40 (tier 3), reszta start | 0,8 / 11 % | 2,1 / 15 % | 3,2 / 17 % | 6,4 / 16 % |
| miecz 40 + komplet 50 (tier 3) | 0,8 / 0 % | 2,1 / 4 % | 3,2 / 6 % | 6,4 / 5 % |
| miecz 80 + komplet 98 (tier 4) | 0,5 / 0 % | 1,3 / 0 % | 1,9 / 0 % | 3,8 / 0 % |

Wnioski:
- **Sprzęt startowy w jaskiniach jest już na poziomie wzorca** (wróg tieru 2 w 4,4 trafieniach, cios 15 % HP), więc kampanię jaskiń da się przejść bez żadnych znalezisk; znaleziska są nagrodą, nie koniecznością.
- **Pancerz działa tu bardzo silnie** (inaczej niż późno, sekcja 8): komplet tieru 3 prawie unieważnia ciosy zwykłych wrogów (0–6 % HP). Dlatego pancerz tieru 3 i wyżej w jaskiniach powinien być **ukrytą nagrodą** (nisza), a nie dropem.
- **Broń tieru 2** daje ok. −27 % trafień (4,4 → 3,2), tier 3 ok. −52 % (→ 2,1): dobra skala dla „znaleziska” i „ukrytej nagrody”.
- Jedna zmiana tieru wystarczy do wyraźnego efektu, dlatego w jaskiniach nie potrzeba wielu poziomów sprzętu.

**Propozycja źródeł w jaskiniach (przykładowa, do oceny):**
- **Drop wrogów:** tier 1: mikstury i drobiazgi; tier 2: element sprzętu tieru 2 z małą szansą (np. 1/15 na wroga); tier 3 (miniboss): element tieru 2 lub rzadziej 3 (np. 1/4); boss końcowy: pewna nagroda (np. broń tieru 3).
- **Skrzynie:** tabela po rzadkości: najczęściej mikstury, rzadziej sprzęt tieru 2, a **skrzynie w niszach** (ślepe zaułki / nisze, które generator już preferuje) dają sprzęt tieru 2–3.
- Niższe tiery gwarantują, że gracz bez szczęścia nie jest zablokowany; wyższe są opcjonalne.
- **Złoto wypada od początku, już od tutorialu** (decyzja usera 2026-10-12): zbierane w jaskiniach na wizytę w mieście. Nie ma w nim żadnego zakupu przed miastem, więc w jaskiniach liczy się tylko to, żeby gracz miał zapas.

**Tiery sprzętu w sklepach blokuje postęp i fabuła (decyzja usera 2026-10-12; 2026-10-21 rozszerzona na wszystkich rzemieślników:
pamiętają swoje imiona, ale słabo rzemiosło, i przypominają je sobie z postępem — `npc.md`):** kowal „nie pamięta, jak się robi lepsze rzeczy”, więc dostępny tier zależy od odblokowanych etapów fabuły, a nie od poziomu gracza, od samego dotarcia do lokacji ani od ilości złota. Konsekwencje:
- Barierą zakupu jest odblokowanie tieru, nie cena: złoto może się gromadzić (od tutorialu), a odblokowanie kolejnego tieru nie robi z niego natychmiast „pustego” zakupu, bo cena to ułamek zapasu. Cena służy więc głównie jako wydatek i wyważenie (sekcja 9 pokrętło), a nie jako bramka tempa; poważny wydatek złota dają też stałe wzmocnienia, mikstury i opłaty za ulepszenia u NPC.
- Mechanizm już istnieje: `LevelStateManager.register_device_progress(story_id)` / `has_device_progress(story_id)` (`autoloads/level_state_manager.gd`, monotoniczne flagi fabularne zapisywane z grą). Odblokowanie tieru kowala = flaga fabularna (np. po wykonaniu zadania kowala, po pokonaniu bossa); lista „tier → wymagana flaga” w danych sklepu. Nowy system nie jest potrzebny.
- Rozmiar mapy ani poziom wroga nie zmienia dostępności sprzętu (spójne z wcześniejszym ustaleniem, że moc sprzętu nie zależy od powierzchni mapy ani poziomu gracza).

**Główny wydatek złota to przedmioty leczące i dające SP (decyzja usera 2026-10-12):** gracz realnie wydaje większość złota na mikstury HP i SP, sprzęt jest mniejszą częścią budżetu. Dane FNaFB1 (`Items.rvdata2`) pokazują, jak to wygląda:

| Przedmiot | Efekt | Cena | Uwaga |
|---|---|---|---|
| Pizza mała / średnia / duża | +100 / +300 / +600 HP | 2 / 5 / 15 | dla Freddy’ego lv 20 (HP 1402): 7 % / 21 % / 43 % |
| Pizza XL | 100 % HP | 50 | ≈ 1,25 zabicia Omega (40 złota) |
| Napój mały / średni / duży | +40 / +150 / +300 SP | 3 / 7 / 17 | pula SP lv 20 = 446 |
| Napój XL | 100 % SP | 80 | ≈ 2 zabicia Omega |

Szacunek: **walka z dwoma wrogami zabiera dziś ok. 70 % HP** (pomiar usera w Cieniu Mgły; podobnie było we FNaFB). To zgadza się z wzorami: cios jednego wroga to ok. 14 % HP, ale walka trwa kilka tur, a obrona (×0,25 / ×0,5) tylko częściowo to łagodzi (14 % to cios **jednego** wroga, nie koszt całej walki). Przy cenie XL pizzy 50 złota (100 % HP) uzupełnienie 70 % HP po walce kosztuje ok. 35 złota, a walka z dwoma wrogami Omega daje 80 złota; SP (założenie: ok. 25 % puli za walkę, napój XL 80 złota) ok. 20 złota. Razem **leczenie i SP pochłaniają ok. 2/3 dochodu**, co zgadza się z opisem usera. Sprzęt jest więc wydatkiem sporadycznym (jednorazowy zakup tieru), a tempo oszczędzania zależy od tego, jak oszczędnie gracz gra (blok, dobre odpowiedzi, mniej strat HP).

Co z tego wynika dla naszej gry:
- **Mikstury mają konkretne wartości (decyzja usera), nie procenty.** `potion` leczy dziś stałe 100 HP (`resources/items/potion.tres`), co na lv 20 to 7 %, a na lv 60 ≈ 1 %, więc potrzebne są **kolejne tiery tych samych przedmiotów ze stałymi, rosnącymi wartościami** (mały / średni / duży, jak pizze FNaFB 100 / 300 / 600 HP i napoje 40 / 150 / 300 SP), odblokowywane postępem jak sprzęt. Wartości liczę z krzywej HP / SP mapy, na której przedmiot pojawia się po raz pierwszy, i wpisuję do danych jako liczby (niezależne od późniejszego poziomu gracza). Przykład (małe / średnie / duże ≈ 15 / 35 / 60 % HP lokacji i 10 / 30 / 60 % SP):

| Mapa | lv koniec | HP | leczenie małe / średnie / duże | SP | SP małe / średnie / duże |
|---|---|---|---|---|---|
| 1 | 8,5 | 660 | 99 / 230 / 400 | 260 | 26 / 78 / 160 |
| 3 | 21,6 | 1 500 | 230 / 540 / 920 | 470 | 47 / 140 / 280 |
| 5 | 34,6 | 3 000 | 450 / 1100 / 1800 | 680 | 68 / 200 / 410 |
| 8 | 54,2 | 7 400 | 1100 / 2600 / 4400 | 1000 | 100 / 300 / 600 |
| 10 | 67,3 | 13 000 | 1900 / 4500 / 7700 | 1200 | 120 / 360 / 730 |
| 12 | 80,4 | 22 000 | 3300 / 7800 / 13 000 | 1400 | 140 / 430 / 850 |
| 15 | 100,0 | 50 000 | 7500 / 17 000 / 30 000 | 1700 | 170 / 520 / 1000 |

Uwaga: pula SP rośnie ×12 (139 → 1700), HP ×150 (334 → 50 000), więc wartości SP rosną znacznie wolniej od leczenia, a koszty umiejętności są stałe.
- **Cena zależy od ilości leczenia:** przy FNaFB ok. 0,017–0,036 złota za 1 HP; uzupełnienie 70 % HP po walce ≈ 0,4–0,45 × dochód z tej walki (≈ 2 wrogów), czyli pełne leczenie ≈ 1,2–1,3 × złoto z jednego zwykłego wroga lokacji (jak XL pizza FNaFB = 1,25 × Omega). Pokrętła: cena pełnego leczenia i napoju w „zabiciach”.
- **Cena sprzętu (2 zabicia) i cena mikstur dają razem budżet:** jeśli leczenie zjada ok. 2/3, to złoto wystarcza na sprzęt dopiero po oszczędzeniu; to wzmacnia wagę decyzji (kupić miksturę czy odłożyć na tier) i jest zgodne z „ekwipunek ważny, ale nie przez grind”.
- **Przed miastem (jaskinie):** nie ma sklepu, więc mikstury pochodzą z beczek i skrzyń (tabela beczek już istnieje: `potion` 55, `ether` 25, `focus_tonic`, `antidote`, `lockpick`, `lucky_charm`, `loot_manager.gd`); przy kosztach walki ok. 70 % HP na parę wrogów jaskinie wymagają **dużo więcej mikstur z beczek i skrzyń niż dziś** albo przerw na odpoczynek (do rozważenia osobno). Złoto zbierane od tutorialu idzie na pierwszą wizytę w mieście, głównie na zapas mikstur.

**Bronie z wielkim potencjałem (decyzja usera 2026-10-12):** rzadki drop daje broń, której **moc początkowa jest ograniczona do maksymalnie 2 poziomów lokacji powyżej standardu** (moc mapy m + 2), a pełny potencjał (endgame) osiąga się **ulepszeniami u kowala**, odblokowywanymi postępem i fabułą (te same flagi co tiery sklepu). To zastępuje wariant „gotowa broń endgame od razu” (Kingly 320 z mapy 1): nie da się przeskoczyć kampanii szczęśliwym dropem.

Liczby (nasza krzywa: ×1,256 ATK i ×1,188 DEF na mapę, czyli **+2 mapy ≈ ×1,58 ATK, ×1,41 DEF**; „moc mapy k” = standard końca mapy k z sekcji 3). Trafienia do zabicia zwykłego wroga tieru 2 / bossa tieru 4 na końcu mapy m:

| Broń o mocy mapy… | gracz na końcu mapy 1 (lv 8) | mapy 3 (lv 22) | mapy 5 (lv 35) | mapy 8 (lv 54) | mapy 12 (lv 80) |
|---|---|---|---|---|---|
| = standard (m) | 4,0 / 12,0 | 4,0 / 12,0 | 4,0 / 12,0 | 4,0 / 12,0 | 4,0 / 12,0 |
| m + 2 (drop z potencjałem) | 3,2 / 9,7 | 3,3 / 9,8 | 3,2 / 9,6 | 3,1 / 9,2 | 2,8 / 8,4 |
| m + 4 (po 1–2 ulepszeniach) | 2,5 / 7,4 | 2,5 / 7,6 | 2,5 / 7,4 | 2,2 / 6,7 | 2,3 / 7,0 (cap 15) |

Czyli drop z potencjałem daje ok. −20–30 % trafień na start (zwykły wróg ok. 3 trafienia zamiast 4), a każde ulepszenie u kowala przesuwa moc o kolejne mapy aż do endgame. Rzadki drop jest odczuwalny, ale **nie psuje walk** (w przeciwieństwie do broni 320 ATK na lv 8, sekcja 4).

Spójność z danymi: na mapie 1 (jaskinie) moc mapy 3 ≈ 21 ATK = istniejący `iron_sword` (tier 2); na mapie 3 moc mapy 5 = 32 ATK. Przykład z sekcji 4 („Żarzące Ostrze”: znalezione na mapie 3 z mocą 32) spełnia tę regułę.

Zasady dla danych (propozycja):
- Etapy broni to osobne `item_id` (jak w sekcji 5): `X_1` (moc początkowa: standard lokacji drop + 2 mapy) … `X_n` (potencjał końcowy).
- Ulepszenie `X_k → X_k+1` u kowala wymaga (a) flagi fabularnej odblokowującej etap (`has_device_progress`), (b) złota (kolejny wydatek zmniejszający nadwyżkę, ale nie grind: cena rzędu kilku zabić zwykłych wrogów tej mapy), (c) opcjonalnie unikalnego materiału z konkretnego bossa lub skrzyni (jednorazowo, nie farmiony).
- **Moc początkowa każdego dropu** ma w danych pole `budget_map` = mapa drop + 2 (test sprawdza, że nie wychodzi poza ten limit).
- Liczba takich broni, rodzaje (po jednej na postać czy mniej) i ich potencjał końcowy zostają otwarte; sekretne bronie mogą świadomie przekraczać potencjał końcowy (osobna decyzja).

## 10a. Stan prototypu w jaskiniach (wdrożone 2026-10-12)

Zrobione (kod w `modules/quiz_rpg`, testy lokalne `check_gold`, `check_enemy_gold`, `check_loot_tables`, `check_barrel_model`):
- **Złoto:** `PlayerStats.gold` (`add_gold`, `spend_gold`, sygnał `gold_changed`, zapis, reset), wiersz „Złoto” w menu pauzy. **Złoto z wrogów** (`scripts/enemies/enemy_gold.gd`): `2 × ATK standardowej broni z poziomu wroga × waga tieru`, boss ×6, skala rozmiaru mapy jak XP; wróg bez poziomu (tutorial) liczy się jak poziom 1, więc złoto wypada od tutorialu. Po wygranej komunikat „Zdobyto N złota!” i wpis `zł +N` w logu progresji.
- **Łup z mapy (JSON):** `chest_loot` (skrzynie, wybór wagowy jednego wpisu, `count`) i `enemy_loot` (tier wroga → wpisy z `chance`, losowane osobno), nakładane po wygenerowaniu mapy (`procedural_level.gd`, `_apply_loot_tables`); `scripts/items/loot_table.gd`. W `caves.json`: skrzynie dają mikstury / ether / tonik / antidotum / wytrych i z wagą łącznie 16 pojedynczy element sprzętu tieru 2; wrogowie tieru 1–2 mikstury (12–18 %), tieru 2 dodatkowo każdy z czterech elementów sprzętu tieru 2 po 1,2 %, miniboss (tier 3) po 6 % na element, boss (tier 4) pewny żelazny miecz + 3 mikstury + 2 etery. Zgodnie z regułą „maks. mapa + 2” w jaskiniach jest tylko sprzęt tieru 2.
- **Beczki:** n-te losowanie z szansą `min(1, scale / n)` (wzór usera 3 / (2n), czyli scale 1,5): 1. gwarantowane, 2. 75 %, 3. 50 %…; P(1) 25 %, P(2) 37,5 %, P(3) 23 %, P(4) 10 %, średnio ≈ 2,3 losowania (dawniej 0,45). W `tutorial_area` scale 2,5 (średnio ≈ 3,8). Metadane `barrel_loot` {scale, max_items}, eksport `loot_scale`.

Niezrobione: sklep, tiery sklepu z flagami fabularnymi, mikstury w kolejnych tierach (stałe wartości, tabela sekcji 9), drop rzadkich broni z potencjałem i ulepszenia u kowala, klucze w łupie (patrz pytanie niżej), balans liczby mikstur w jaskiniach (do sprawdzenia w grze).

## 11. Decyzje do podjęcia

**Pierwsza — rozstrzygnięta przez usera:** złoto z potworów od tutorialu, sklepy po odblokowaniu miasta, tiery sklepu blokowane fabułą (kowal), w jaskiniach sprzęt z dropów i skrzyń / nisz, rzadkie dropy to bronie z potencjałem (moc początkowa ≤ mapa + 2, rozwój u kowala).

**Czwarta (jaskinie) — rozstrzygnięta:** złoto wypada od początku, już od tutorialu.

**Druga — rozstrzygnięta przez usera 2026-10-21 („jak we FNaFB, pamiętając, że tam skalowanie kończy się na lv 20”; skala liczb:
„duże — HP do 50 000 zostaje”; pancerz: „atak wroga z własnej krzywej”).** Wdrożenie: sekcja 12. Pierwotne warianty:
skala drabiny przy 100 poziomach: **A.** wydłużyć drabinę (pułap sklepu ≈ 600 ATK, rzadki ≈ 1200, najrzadszy ≈ 1850 ATK z bonusami HP / SP; przyrost z poziomu bez zmian, „szalone liczby” z ustaleń usera), **B.** zmniejszyć przyrost z poziomu (`atk_per_level` / `def_per_level`, sekcja 8), **C.** zostawić jak teraz (nasz pułap 320 = FNaFB-owy rzadki drop, poziom dominuje do lv 80).
Uwaga: **zmiana A / B przesuwa wzorzec wrogów** w `enemy_stats.gd` (`GEAR_*` albo `*_per_level`); stosunek w walce zostaje, liczby w grze rosną.

**Uwaga o roli FNaFB:** to przykład progresji i wyjątkowych nagród, nie specyfikacja (user: nasza gra jest znacznie bardziej rozbudowana). Z FNaFB wynika tylko, że drop może przekraczać zwykłą progresję i że może być przypisany do konkretnej postaci i tieru wroga. **Nie** ustalamy jednej broni ostatecznej na postać, tabeli dropów „tier = postać” ani liczby takich broni; kampanię balansujemy pod zwykły, dostępny sprzęt (broń ostateczna nie jest wymagana do finału), a ostateczne i sekretne bronie są świadomymi wyjątkami (także sekretne ponad budżet). Cechy przedmiotu (dostępność, moc początkowa, potencjał, ścieżka ulepszeń, specjalizacja) są niezależne, więc „ostateczna z dropu” i „rozwijana u NPC” to dwie osobne drogi, nie jeden obowiązkowy etap.

**Trzecia — rozstrzygnięta przez usera:** wczesny rzadki drop **nie** daje od razu mocy endgame; moc początkowa ≤ moc mapy + 2, pełny potencjał przez ulepszenia u kowala (wariant „moc rośnie etapami”, sekcja 10).

W każdym wariancie osobna poprawka: pancerz prawie nie wpływa na przeżywalność późno (sekcja 8), więc definicję ciosu wroga w `enemy_stats.gd` trzeba przejrzeć niezależnie od wyborów. **Rozwiązane 2026-10-21 (sekcja 12).**

## 12. Skala jak FNaFB1 do lv 100 (wdrożone 2026-10-21)

Jedno źródło liczb: `scripts/heroes/stat_scale.gd` (`QuizRpgStatScale`). Nasze lv 1–100 to rozciągnięte lv 1–20 FNaFB1
(`fnafb_level` = 1 + (L − 1) × 19 / 99), a wszystko poza HP i SP rośnie dodatkowo z krzywą HP: `factor(L)` = HP bohatera
wzorcowego / HP Freddy'ego w tym samym punkcie FNaFB (lv 1: 1, lv 100: 35,7). Krzywe HP, SP i XP bez zmian.
- **Bohater:** ATK / DEF / MAT / MDF = (baza + przyrost × (poziom FNaFB − 1)) × factor; `*_per_level` w danych postaci to
  przyrost na poziom FNaFB (bohater 1,95 ATK = Freddy 21 -> 58). AGI bez skali (kolejność tur). `PlayerStats.get_member_total_stat`.
- **Sprzęt ze sklepu (standard):** broń 10 -> 160 i komplet pancerza (głowa + korpus + tarcza razem, ¼ / ½ / ¼) 4 -> 64 jak
  sklepy FNaFB1, wykładniczo po poziomie FNaFB, × factor. Rzadki drop ≈ 2 × sklep (Kingly), najrzadszy ≈ 3 × (Godly) — do
  zaprojektowania przy relikwiach / broniach z potencjałem.
- **Wróg:** ATK z własnej krzywej (Party Hat Alpha 20 -> Omega 160, × factor) × `ENEMY_ATK_MULT` tieru (0,79 / 0,96 / 1,04 / 1,0 —
  na lv 1 cios jak dotąd: 10 / 14 / 16 / 15 % HP); HP i DEF jak dotąd z bohatera wzorcowego (`HITS_TO_KILL`, `DEF_RATIO`).
  Pancerz waży jak w FNaFB: komplet ze sklepu tnie cios o 14 % (lv 1) -> 22 % (lv 100); cios rośnie z 14 % do ≈ 30 % HP
  na lv 100 (Omega na Freddym lv 20: 32 %). `enemy_stats.gd`.
- **Złoto z wroga:** 2 × broń ze sklepu z jego poziomu × waga tieru (`enemy_gold.gd`) — rośnie razem z cenami.

Końce map (bohater wzorcowy ze sprzętem ze sklepu; `tests/diag_stat_scale.gd`):

| Mapa | lv | factor | HP | ATK bez sprzętu | broń sklep | komplet pancerza | ATK wroga (Omega) | sprzęt w ATK | pancerz tnie | cios t1 / t2 / t3 / boss |
|---|---|---|---|---|---|---|---|---|---|---|
| start | 1 | 1,0 | 334 | 21 | 10 | 4 | 20 | 32 % | 14 % | 10 / 14 / 16 / 15 % |
| 1 | 9 | 1,6 | 687 | 39 | 20 | 8 | 39 | 34 % | 14 % | 9 / 13 / 15 / 14 % |
| 2 | 15 | 2,1 | 1 037 | 56 | 32 | 13 | 57 | 36 % | 15 % | 9 / 13 / 15 / 14 % |
| 3 | 22 | 2,8 | 1 570 | 81 | 50 | 20 | 87 | 38 % | 15 % | 9 / 13 / 15 / 14 % |
| 4 | 28 | 3,5 | 2 163 | 108 | 74 | 29 | 122 | 41 % | 16 % | 10 / 14 / 15 / 14 % |
| 5 | 35 | 4,4 | 3 063 | 147 | 113 | 45 | 179 | 43 % | 16 % | 10 / 14 / 16 / 15 % |
| 6 | 41 | 5,3 | 4 066 | 191 | 163 | 65 | 246 | 46 % | 17 % | 11 / 15 / 17 / 16 % |
| 7 | 48 | 6,7 | 5 590 | 256 | 248 | 99 | 357 | 49 % | 17 % | 12 / 16 / 18 / 17 % |
| 8 | 54 | 8,0 | 7 286 | 328 | 355 | 142 | 490 | 52 % | 18 % | 12 / 17 / 19 / 18 % |
| 9 | 61 | 10,1 | 9 863 | 437 | 539 | 216 | 709 | 55 % | 18 % | 14 / 18 / 21 / 20 % |
| 10 | 67 | 12,2 | 12 733 | 556 | 773 | 309 | 974 | 58 % | 19 % | 15 / 20 / 22 / 21 % |
| 11 | 74 | 15,2 | 17 091 | 736 | 1 177 | 471 | 1 412 | 62 % | 19 % | 16 / 22 / 24 / 23 % |
| 12 | 80 | 18,5 | 21 946 | 935 | 1 691 | 676 | 1 945 | 64 % | 20 % | 17 / 23 / 26 / 25 % |
| 13 | 87 | 23,2 | 29 318 | 1 236 | 2 583 | 1 033 | 2 829 | 68 % | 21 % | 19 / 25 / 28 / 27 % |
| 14 | 93 | 28,3 | 37 529 | 1 568 | 3 721 | 1 488 | 3 908 | 70 % | 21 % | 20 / 27 / 31 / 29 % |
| 15 | 100 | 35,7 | 50 000 | 2 070 | 5 706 | 2 282 | 5 706 | 73 % | 22 % | 22 / 30 / 34 / 32 % |

**Tiery istniejących przedmiotów = budżet sklepu co 3 mapy** (cena broni 2,5 × ATK; pancerz: 2,5 × broń tieru × 0,4 / 0,6 / 0,4):

| Tier | budżet | broń | głowa / korpus / tarcza | przedmioty |
|---|---|---|---|---|
| 1 | start (lv 1) | 10 | 1 / 2 / 1 | training_sword (i inne bronie 10), cloth_cap, adventurer_tunic, wooden_shield |
| 2 | mapa 3 (lv 22) | 50 | 5 / 10 / 5 | iron_sword, leather_hood, reinforced_tunic, iron_buckler |
| 3 | mapa 6 (lv 41) | 160 | 16 / 33 / 16 | steel_blade, iron_helmet, iron_chainmail, steel_kite_shield |
| 4 | mapa 9 (lv 61) | 540 | 54 / 108 / 54 | knight_broadsword, knight_visored_helm, knight_plate_armor, knight_shield |
| 5 | mapa 12 (lv 80) | 1 690 | 169 / 338 / 169 | runic_claymore, crown_of_clarity, warden_cuirass, aegis_shield |
| 6 | mapa 15 (lv 100) | 5 700 | — | shadowbane_sword (pułap sklepu) |

- Łup jaskiń (mapa 1) tylko do tieru 2 = moc mapy 3 (reguła „mapa + 2”); nisze i sekretne pokoje poprawione w
  `caves.json` (wcześniej tier 3).
- **Pierwsza broń z potencjałem (2026-10-21): Ostrze Mgły** (`mist_blade_1`…`_4`, miecz) — relikwia krypty w jaskiniach.
  Etapy = budżet sklepu map 3 / 6 / 10 / 15 + 3 %: ATK 50 / 163 / 773 / 5900; ulepszenie u kowala (`QuizRpgNpcUpgrade`,
  `npc.md`) za 5 zabić zwykłego wroga z poziomu odblokowania (500 / 2480 / 16 900 D) po flagach zastępczych `boss:sewer` /
  `boss:forge` / `boss:library`. Bez ceny (nie do kupienia ani sprzedania). Test `check_upgrade`.
- **Odblokowanie w sklepach (decyzja usera 2026-10-22): główne tiery na bossa, przedmioty pośrednie na zadanie.**
  Wdrożone dla miasta (kowal Brann, płatnerz Kastor; test `check_shop_tiers`):

  | Stopień | budżet | broń (miecz / sztylet / kostur MAT / buława) | głowa / korpus / tarcza | odblokowanie |
  |---|---|---|---|---|
  | tier 1 | start | 10 (training_sword…) | 1 / 2 / 1 | od razu |
  | tier 2 | mapa 3 | 50 (iron_sword) | 5 / 10 / 5 | `boss:cave_relic` (boss jaskini) |
  | pośredni A | mapa 4 | 74: tempered_sword, tempered_dagger, oak_staff (ATK 30), iron_mace | 7 / 15 / 7: studded_hood, studded_jerkin, banded_buckler | „Lepsza ruda” (Brann: 5 × ruda żelaza) i „Surowe skóry” (Kastor: 5 × surowa skóra) — oferowane po bossie jaskini |
  | pośredni B | mapa 5 | 113: guardsman_sword, stiletto, runed_staff (ATK 45), flanged_mace | 11 / 23 / 11: iron_coif, scale_armor, iron_round_shield | „Węgiel i stal” (Brann: 300 D na surowce u handlarza) i „Żelazne łuski” (Kastor: 8 × ruda) — po zadaniach A |
  | tier 3 | mapa 6 | 160 (steel_blade) | 16 / 33 / 16 | `boss:sewer` |

  Fabuła zadań (user 2026-10-22): rzemieślnik potrzebuje lepszych materiałów / surowców (nie „przypomina sobie fach” — to
  zostaje przy głównych tierach po bossie). Materiały: `iron_ore` (wrogowie jaskiń 20–35 %, boss 2–3 szt.; ścieki 12–20 %),
  `raw_hide` (wrogowie ścieków 30–45 %, boss 2–3), cena 20 / 16 D (sprzedaż 10 / 8 D ≈ pół złota z wroga mapy 1), ikony 16 px w `resources/items/icons/` (zastępcze, moje).
  Ceny: broń 2,5 × ATK, hełm / tarcza 10 × DEF, korpus 7,5 × DEF. Ikony pożyczone z najbliższych przedmiotów (do
  zrobienia własne). Dalsze mapy: ten sam wzór (pośrednie map 3t+1 / 3t+2 na zadania, tier co 3 mapy na bossa).
- Brakuje pancerza na lv 100 i pośrednich dla kolejnych map — dane do dorobienia (np. Gemini) z tabeli wyżej.
- Kowal w mieście: tier 3 po `boss:sewer` (flagi zastępcze) — przestroić z tierami map, gdy powstaną sklepy.
- **Tiery mikstur i eterów (wdrożone 2026-10-21):** tier t = mapy 3t−2…3t (jak sprzęt), rozmiary mała / duża / wielka
  ≈ 15 / 35 / 60 % HP lub SP końca mapy 3t−2 (lv 9 / 28 / 48 / 67 / 87); `potion` (100 HP) i `ether` (40 SP) = tier 1
  mały, bez zmian. Id `potion_<t><s|m|l>`, `ether_<t><s|m|l>`, nazwy „Duża mikstura II”, „Wielki eter III”… Ceny jak FNaFB:
  mikstura = ułamek HP × 1,25 × złoto z wroga tieru 2, eter = ułamek SP × 2 × złoto (pełne leczenie ≈ 1,25 zabicia, pełne
  SP ≈ 2 zabicia). Zielarka: tier 1 od razu, 2–5 po `boss:sewer` / `forge` / `library` / `garden` (flagi zastępcze).
  Jaskinie: duża mikstura w skrzyniach i niszach, wielka w skarbie sekretnych pokoi. Ikony wspólne (potion / ether) — do
  zrobienia osobne. Test `check_potion_tiers`.

  | Tier (mapy) | mikstura mała / duża / wielka (HP) | eter mały / duży / wielki (SP) |
  |---|---|---|
  | 1 (1–3) | 100 / 240 / 410 | 40 / 95 / 160 |
  | 2 (4–6) | 320 / 760 / 1300 | 85 / 200 / 340 |
  | 3 (7–9) | 840 / 1950 / 3350 | 135 / 310 / 540 |
  | 4 (10–12) | 1900 / 4450 / 7600 | 180 / 420 / 720 |
  | 5 (13–15) | 4400 / 10 300 / 17 600 | 230 / 540 / 920 |
