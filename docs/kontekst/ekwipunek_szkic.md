# Ekwipunek i progresja — szkic modelu (do oceny)

Stan: **propozycja z 2026-10-12, nic z sekcji 2–6 nie jest zaimplementowane ani zatwierdzone.** Odpowiada na brief „Ekwipunek i progresja — kontekst oraz zadanie dla Claude”.
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
- **Sklep w lokacji sprzedaje jeden tier standardowego sprzętu tej lokacji** (jak FNaFB: 4 sklepy = 4 tiery kupowalne), pułap sklepu = standardowy sprzęt końca kampanii (np. 600 ATK po wydłużeniu drabiny, sekcja wyżej). Cena ≈ 2 zabicia zwykłych wrogów tej lokacji: złoto z wroga ≈ 0,25 × ATK_standard(poziom wroga) × waga tieru (0,6 / 1,0 / 1,6, boss ×6), normalizacja po liczbie spawnów jak XP.
- **Rzadki drop ponad pułap sklepu** (Kingly): osobna tabela łupu wrogów z małą szansą (np. 1/80 jak FNaFB, bez wymogu poziomu), moc ≈ 2 × pułap. W tabeli sekcji 4 to scenariusz „sama broń ×2”: wróg tieru 2 ginie w 2,1–2,9 trafień zamiast 4, boss w 6,2–8,7 zamiast 12.
- **Najrzadszy** (Godly): drop z bossów (np. 1/40–1/60) lub sekret, ≈ 3 × pułap, z bonusami do HP / SP (wielostatystyczna broń).
- **Wzmocnienia stałe za złoto** (HP / SP / ATK / DEF Boost) jako dodatkowy wydatek, który nie wymaga nowego systemu (jednorazowy przedmiot z efektem `+stat`).
- **Warianty z karą** (jak sekretna broń z HP −5000): opcjonalne, osobne pytanie; nie dodawać automatycznie.
- Pokrętło tempa: stosunek cena / złoto z potwora (tu 2 zabicia); wyższa wartość spowalnia zakupy bez ruszania krzywych.

## 10. Decyzje do podjęcia

**Pierwsza (blokuje resztę):** czy bierzemy model FNaFB „waluta z potworów + sklepy po jednym tierze standardowego sprzętu w lokacji + rzadkie dropy ponad pułap sklepu”? (Dziś w grze nie ma złota, sklepów ani źródła sprzętu, więc cały system sprzętu nie ma jak działać.)
- **Tak:** dodaje złoto w `PlayerStats` i zapisie, drop złota i tabelę łupu wrogów (w tym rzadkie bronie), NPC / interfejs sklepu (miasta jeszcze nie ma, więc najpierw sklep w menu deweloperskim).
- **Nie:** tylko skrzynie / bossowie / questy; tempo sprzętu zależy od losu i eksploracji.

**Druga:** skala drabiny przy 100 poziomach: **A.** wydłużyć drabinę (pułap sklepu ≈ 600 ATK, rzadki ≈ 1200, najrzadszy ≈ 1850 ATK z bonusami HP / SP; przyrost z poziomu bez zmian, „szalone liczby” z ustaleń usera), **B.** zmniejszyć przyrost z poziomu (`atk_per_level` / `def_per_level`, sekcja 8), **C.** zostawić jak teraz (nasz pułap 320 = FNaFB-owy rzadki drop, poziom dominuje do lv 80).
Uwaga: **zmiana A / B przesuwa wzorzec wrogów** w `enemy_stats.gd` (`GEAR_*` albo `*_per_level`); stosunek w walce zostaje, liczby w grze rosną.

**Uwaga o roli FNaFB:** to przykład progresji i wyjątkowych nagród, nie specyfikacja (user: nasza gra jest znacznie bardziej rozbudowana). Z FNaFB wynika tylko, że drop może przekraczać zwykłą progresję i że może być przypisany do konkretnej postaci i tieru wroga. **Nie** ustalamy jednej broni ostatecznej na postać, tabeli dropów „tier = postać” ani liczby takich broni; kampanię balansujemy pod zwykły, dostępny sprzęt (broń ostateczna nie jest wymagana do finału), a ostateczne i sekretne bronie są świadomymi wyjątkami (także sekretne ponad budżet). Cechy przedmiotu (dostępność, moc początkowa, potencjał, ścieżka ulepszeń, specjalizacja) są niezależne, więc „ostateczna z dropu” i „rozwijana u NPC” to dwie osobne drogi, nie jeden obowiązkowy etap.

**Trzecia:** wczesny rzadki drop o mocy endgame — FNaFB dopuszcza go bez ograniczeń (Kingly 1/80 już z Alpha Party Hat). U nas oznacza to jedno- do trzytrafieniowe walki z bossami od lv 8 do ok. 60 (tabela sekcji 4).
- **A.** Tak jak w FNaFB, jako szczęśliwy los (bez zmian w kodzie).
- **B.** Tak, ale moc rośnie etapami (wariant „Żarzące Ostrze”).
- **C.** Wymóg poziomu postaci (`required_level`) dla broni powyżej budżetu mapy.

W każdym wariancie osobna poprawka: pancerz prawie nie wpływa na przeżywalność późno (sekcja 8), więc definicję ciosu wroga w `enemy_stats.gd` trzeba przejrzeć niezależnie od wyborów.
