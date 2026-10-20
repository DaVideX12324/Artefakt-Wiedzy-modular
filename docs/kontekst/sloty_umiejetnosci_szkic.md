# Sloty umiejętności wg tierów — szkic do oceny

Stan: **zrobione 2026-10-21 (Opus) według rekomendacji z sekcji 2** — opis wdrożenia w sekcji 6. Liczby to nadal propozycje
do przestrojenia (stałe w `QuizRpgSkillSlots`); punkt odniesienia: `LEVEL_CAP` 20 teraz, docelowo 100 lvl i 15 map.

## 1. Założenia (decyzje usera)

- Na razie **4 tiery** (T1–T4), nie 9. Tiery 5–9 dojdą z rozwojem gry; **tier 9 = umiejętności arcymaga z true endingu** (`game_design.md`).
- Zamiast wielu osobnych skilli różnych tierów: **jeden skill ma poziomy 1…N, poziom = tier**. Ten sam skill można wstawić do slotu T1 (słabsza wersja)
  albo do slotu wyższego tieru (mocniejsza wersja). Mniej różnych skilli, więcej wyborów.
- **Poziom bohatera podnosi maksymalny tier**, do którego wolno podnieść skill. Nie ma osobnego XP skilli. Gracz sam wybiera, na jakim poziomie
  ustawia skill, żeby zapełnić dostępne sloty.
- Sloty rosną z poziomem; **akcesoria zwiększają lub zmniejszają ich liczbę** (zwykle kosztem słabszych statystyk).
- Wyższy tier **kosztuje ograniczenie niższych**: jeden skill T4 wymaga ograniczenia liczby T1.
- Blokady wejścia na zamek sprawdzają **znajomość skilla**, nie slot.
- **Skan jest poza budżetem** (decyzja usera 2026-10-12): nie zajmuje nawet tury, więc slot byłby bezsensem.
- **Combo jest poza budżetem** (decyzja usera): to osobny tryb dostępny po osiągnięciu 100 TP (nie ult). W trybie combo gracz używa skilli tyle razy, ile pozwala SP; skille kosztujące TP są wtedy niedostępne, bo cała pula TP poszła na aktywację. **Combo ≠ ult:** Death Enrage to ult, czyli umiejętność wysokiego tieru (start T4, zajmuje budżet jak każdy skill); flaga `combo` w danych skilli była błędna i została usunięta. Tryb combo nie istnieje jeszcze w kodzie — do zaprojektowania osobno (backlog O3).
- **Odblokowanie combo** (decyzja usera 2026-10-12): po konkretnych warunkach, **nigdy** z poziomu bohatera ani od NPC. Możliwe źródła: rzadki drop, maks. poziom (tier) wskazanych skilli albo pokonanie specjalnego przeciwnika. Dotyczy trybu combo, nie Death Enrage (ult odblokowuje się z poziomu bohatera, `learn_level = 20`).

## 2. Model: wspólny budżet slotów (rekomendacja)

Zamiast osobnej liczby slotów na każdy tier — jeden **budżet w jednostkach**, a skill poziomu N kosztuje stałą liczbę jednostek:

| Tier skilla | Koszt (jednostki) |
|---|---|
| T1 | 1 |
| T2 | 2 |
| T3 | 3 |
| T4 | 5 |

Czyli jeden skill T4 „zjada” pięć jednostek, które mogłyby dać pięć skilli T1 (lub T2 + T3). To wprost realizuje zasadę „T4 ogranicza T1” bez
tablicy zależności. Dodatkowo twardy limit liczby aktywnych skilli naraz (propozycja **6**), żeby menu w walce nie puchło.

Budżet w funkcji poziomu bohatera (propozycja; pierwsze cztery wiersze na `LEVEL_CAP` 20):

| Poziom | Maks. tier skilla | Budżet (jedn.) | Przykładowy układ |
|---|---|---|---|
| 1 | T1 | 3 | 3× T1 |
| 6 | T2 | 5 | 2× T2 + 1× T1, albo 5× T1 |
| 12 | T3 | 8 | T3 + T3 + T2, albo T3 + T2 + 3× T1 |
| 20 | T4 | 11 | T4 + T3 + T2 + T1 |
| 40+ | T5? | dalej z rozwojem | |

Wariant B (alternatywa): osobne sloty na tier (np. lv 20: 3× T1, 2× T2, 1× T3, 1× T4), a skill wyższego tieru zajmuje także jeden slot niższy.
Jest czytelniejszy, ale trudniejszy do dostrojenia. Rekomenduję budżet.

**Akcesoria:** `slot_budget` w danych przedmiotu: np. +2 jedn. (−10 % ATK), −1 jedn. (+ staty), albo „+1 do maks. tieru” kosztem budżetu.
**Respec:** przestawianie darmowe poza walką (menu pauzy).

## 3. Poziomy skilli gracza (propozycja)

Kolumna „Poziomy” = [tier startowy – maks. tier skilla]; faktyczny górny limit zależy od poziomu bohatera (sekcja 2). Co rośnie z poziomem: liczby to pomysły, nie wartości docelowe. Skille uczone z poziomu lub u NPC działają tak samo.

| Skill (EN / PL) | Poziomy | Co rośnie z poziomem |
|---|---|---|
| Heavy Strike / Ciężki Cios (`mocny_atak`) | 1–3 | mnożnik 1,5 → 1,8 → 2,2 |
| Heal / Uleczenie (`leczenie`) | 1–3 | leczenie 30 → 40 → 55 % |
| Scan / Skan (`scan`) | bez slotu | — |
| Swift Flurry / Błyskawiczna Seria (`leap_series`) | 1–3 | trafienia 5 → 6 → 7, szansa ogłuszenia rośnie |
| Twin Strike / Podwójny Sztych (`double_throw`) | 1–3 | mnożnik, potem trzecie trafienie |
| Dagger Barrage / Grad Sztyletów (`coin_barrage`) | 1–3 | trafienia 3 → 4 → 5 |
| Smoke Screen / Zasłona Dymna (`smoke_cloud`) | 1–3 | szansa oślepienia 50 → 65 → 80 % |
| Toxic Wave / Toksyczna Fala (`sound_wave`) | 1–3 | szansa trafienia wroga 50 → 65 → 80 % (decyzja usera) |
| Healing Prayer / Modlitwa Uzdrowienia (`hearty_meal`) | 1–3 | leczenie MAT × 4 → 5 → 6 |
| Battle Hymn / Hymn Bojowy (`rousing_tune`) | 2–3 | czas / siła wzmocnienia |
| Armor of Faith / Pancerz Wiary (`nurturing_care`) | 2–3 | czas / siła obrony |
| Seal of Silence / Pieczęć Ciszy (`sea_chant`) | 2–4 | szansa uciszenia rośnie |
| Slumber Missiles / Deszcz Snów (`lullaby`) | 2–4 | trafienia, szansa uśpienia |
| Venom Bolt / Jadowity Pocisk (`piercing_shriek`) | 2–4 | szansa trucizny, mnożnik na zatrutym |
| Paralyzing Strike / Paraliżujące Pchnięcie (`shove`) | 2–4 | szansa paraliżu |
| Meteor Strike / Spadający Meteor (`aerial_strike`) | 2–4 | mnożnik |
| Shadow Strike / Cios z Cienia (`dive_attack`) | 2–4 | mnożnik 1,5 → 2 → 2,5 |
| Resurrection / Wskrzeszenie (`revive_tonic`) | 2–4 | HP po wskrzeszeniu 30 → 50 → 70 % |
| Reckless Strike / Ryzykowny Cios (`reckless_blow`) | 2–4 | szansa trafienia 8 → 12 → 16 % |
| Blade Dance / Taniec Ostrzy (`onslaught`) | 3–4 | trafienia 6 → 8 |
| Wind's Blessing / Błogosławieństwo Wiatru (`share_tempo`) | 3–4 | siła i czas buffa AGI |
| Final Blow / Ostatni Zamach (`final_strike`) | 3–4 | ATK × 8 → × 12 |
| Destruction Frenzy / Szał Zniszczenia (`death_enrage`) | 4 | ult; jedna wersja, slot T4 |

Skille-klucze zamku (Rushdown, Backup Bash, Rapid Flurry) mają niski tier startowy, więc znajomość wystarcza od razu po nauczeniu u NPC.

## 4. Jak to się łączy z resztą

- **Poziomy skilli z fazy 2** (`otwarte.md`, szansa Toxic Shock 50 / 65 / 80 %) to ten sam mechanizm — jeden system, nie dwa.
- **True ending:** tier 9 arcymaga to dodatkowe sloty / wysokie tiery dostępne po finale; akcesoria z „+1 do maks. tieru” pasują do ukrytych przedmiotów.
- **Drużyna:** każdy członek ma własny budżet i własną listę poziomów (sojusznicy mogą mieć inną krzywą).
- **Wrogowie** nie używają slotów (mają `szansę użycia` i `cooldown`).

## 5. Do uzgodnienia

1. Wartości jednostek (1 / 2 / 3 / 5) i budżetu na poziom; limit aktywnych skilli (6?).
2. ~~Czy skill T4 może być ustawiony niżej?~~ **Rozstrzygnięte (user 2026-10-12):** skill ma tier startowy i nie zajmie niższego slotu (T4 na start = tylko slot T4). Jeśli startuje np. na T3, a poziom bohatera podniósł jego maks. tier do T4, można go wstawić na T4 albo na dowolnym niższym poziomie, nie niższym niż T3. Czyli zakres = [tier startowy, maks. tier z poziomu bohatera].
3. ~~Czy Skan i combo (tryb) leżą poza budżetem?~~ **Rozstrzygnięte:** tak, oba. Zostaje zaprojektować sam tryb combo (aktywacja 100 TP, serie skilli za SP, blokada skilli TP).
4. Format akcesoriów (jednostki budżetu, ±1 tier) i które z obecnych `lucky_charm` / nowych dostają bonus.
5. UI: ekran w menu pauzy (lista skilli, suwak poziomu, pasek budżetu), widok w walce bez zmian.
6. Zapis: lista (skill, poziom) na członka.

## 6. Wdrożenie (2026-10-21)

- **Wartości:** koszt T1–T4 = 1 / 2 / 3 / 5, budżet liniowo 3 → 11 (lv 1 → 20; lv 6 = 5, lv 12 = 8), maks. tier od lv 1 / 6 / 12 / 20,
  najwyżej 6 aktywnych, skan poza budżetem — `scripts/skills/skill_slots.gd` (`QuizRpgSkillSlots`).
- **Dane skilla** (`QuizRpgSkillData`, grupa „Tiery (sloty)”): `tier_min`, `tier_max`, `tier_overrides` = `{tier: {pole: wartość}}`
  kumulatywnie od `tier_min + 1`; `at_tier(t)` daje kopię z nałożonymi zmianami (nazwa i opis z tłumaczeń źródła), `tier_summary(t)` —
  krótki opis w menu. Zakresy i zmiany wg tabeli z sekcji 3 (bez czasu trwania buffów — tego pola nie ma: Hymn Bojowy i Pancerz Wiary
  na T3 działają na całą drużynę, Błogosławieństwo Wiatru T4 tańsze w SP); skille klasowe towarzyszy też mają tiery (`druzyna_szkic.md`).
- **Członek:** `member["loadout"]` = `{skill_id: tier}`. `PlayerStats.set_member_skill_tier` (0 = zdejmij), `get_member_slot_info`,
  `get_member_battle_skills` — **walka i menu pauzy używają tylko skilli ze slotów** (+ skan). Nowo nauczony skill (poziom, NPC) wchodzi
  sam na tier startowy, jeśli się mieści; inaczej czeka na liście. Stary zapis bez slotów: znane skille po kolei, ile się zmieści.
- **Akcesoria:** pola `slot_budget` i `max_tier_bonus` w `QuizRpgItemData` (suma ze sprzętu); po zmianie sprzętu nadmiar schodzi ze slotów
  od końca puli. **Żaden przedmiot jeszcze ich nie ma** — pkt 4 nadal do decyzji.
- **UI:** panel Umiejętności w menu pauzy (`scenes/ui/skills_panel.tscn`): pasek slotów (budżet, aktywne, maks. tier), 16 wierszy,
  tier przy nazwie albo „poza slotem”, **Q / E = tier w dół / w górę** (poniżej startowego = zdjęcie ze slotu), w opisie zakres tierów
  i to, co daje bieżący tier. Walka bez zmian w wyglądzie.
- Testy lokalne: `check_skill_slots`, `shot_skill_slots` (okno).
- Otwarte: akcesoria z bonusem (pkt 4), tiery 5+ (poziomy powyżej 20), podpowiedź po awansie, że odblokował się nowy tier.
