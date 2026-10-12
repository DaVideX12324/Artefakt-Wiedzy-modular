# Sloty umiejętności wg tierów — szkic do oceny

Stan: **pomysł usera z 2026-10-12, nic nie jest zaimplementowane.** W grze dziś nie ma limitu aktywnych skilli (cała odblokowana pula jest
dostępna w walce). Wszystkie liczby poniżej to propozycje do przerobienia; punkt odniesienia: `LEVEL_CAP` 20 teraz, docelowo 100 lvl i 15 map.

## 1. Założenia (decyzje usera)

- Na razie **4 tiery** (T1–T4), nie 9. Tiery 5–9 dojdą z rozwojem gry; **tier 9 = umiejętności arcymaga z true endingu** (`game_design.md`).
- Zamiast wielu osobnych skilli różnych tierów: **jeden skill ma poziomy 1…N, poziom = tier**. Ten sam skill można wstawić do slotu T1 (słabsza wersja)
  albo do slotu wyższego tieru (mocniejsza wersja). Mniej różnych skilli, więcej wyborów.
- **Poziom bohatera podnosi maksymalny tier**, do którego wolno podnieść skill. Nie ma osobnego XP skilli. Gracz sam wybiera, na jakim poziomie
  ustawia skill, żeby zapełnić dostępne sloty.
- Sloty rosną z poziomem; **akcesoria zwiększają lub zmniejszają ich liczbę** (zwykle kosztem słabszych statystyk).
- Wyższy tier **kosztuje ograniczenie niższych**: jeden skill T4 wymaga ograniczenia liczby T1.
- Blokady wejścia na zamek sprawdzają **znajomość skilla**, nie slot.
- Skan nie zajmuje slotu (narzędzie, bez tury i bez kosztu) — do potwierdzenia.

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

Zakres poziomów i co rośnie z poziomem; liczby to pomysły, nie wartości docelowe. Skille uczone z poziomu lub u NPC działają tak samo.

| Skill (EN / PL) | Poziomy | Co rośnie z poziomem |
|---|---|---|
| Heavy Strike / Ciężki Cios (`mocny_atak`) | 1–3 | mnożnik 1,5 → 1,8 → 2,2 |
| First Aid / Pierwsza Pomoc (`leczenie`) | 1–3 | leczenie 30 → 40 → 55 % |
| Scan / Skan (`scan`) | bez slotu | — |
| Rapid Flurry / Szybka Seria (`leap_series`) | 1–3 | trafienia 5 → 6 → 7, szansa ogłuszenia rośnie |
| Double Strike / Podwójny Cios (`double_throw`) | 1–3 | mnożnik, potem trzecie trafienie |
| Shrapnel Toss / Grad Odłamków (`coin_barrage`) | 1–3 | trafienia 3 → 4 → 5 |
| Smoke Ring / Zasłona Dymna (`smoke_cloud`) | 1–3 | szansa oślepienia 50 → 65 → 80 % |
| Toxic Shock / Toksyczna Fala (`sound_wave`) | 1–3 | szansa trafienia wroga 50 → 65 → 80 % (decyzja usera) |
| Hearty Meal / Pożywny Posiłek (`hearty_meal`) | 1–3 | leczenie MAT × 4 → 5 → 6 |
| Motivation Jam / Zastrzyk Motywacji (`rousing_tune`) | 2–3 | czas / siła wzmocnienia |
| Guardian Ward / Żelazna Straż (`nurturing_care`) | 2–3 | czas / siła obrony |
| Sea Shanty / Morska Szanta (`sea_chant`) | 2–4 | szansa uciszenia rośnie |
| Lullaby / Kołysanka (`lullaby`) | 2–4 | trafienia, szansa uśpienia |
| Toxic Dart / Zatruta Strzałka (`piercing_shriek`) | 2–4 | szansa trucizny, mnożnik na zatrutym |
| Paralyzing Strike / Paraliżujący Cios (`shove`) | 2–4 | szansa paraliżu |
| Fearless Flight / Podniebny Cios (`aerial_strike`) | 2–4 | mnożnik |
| Flying Fright / Pikujący Cios (`dive_attack`) | 2–4 | mnożnik 1,5 → 2 → 2,5 |
| Revive / Ożywienie (`revive_tonic`) | 2–4 | HP po wskrzeszeniu 30 → 50 → 70 % |
| Backup Bash / Hazardowy Cios (`reckless_blow`) | 2–4 | szansa trafienia 8 → 12 → 16 % |
| Rushdown / Natarcie (`onslaught`) | 3–4 | trafienia 6 → 8 |
| Speed Share / Wspólne Tempo (`share_tempo`) | 3–4 | siła i czas buffa AGI |
| Final Strike / Ostateczne Cięcie (`final_strike`) | 3–4 | ATK × 8 → × 12 |
| Death Enrage / Szał Śmierci (`death_enrage`) | 4 | ult; jedna wersja, slot combo |

Skille-klucze zamku (Rushdown, Backup Bash, Rapid Flurry) mają niski tier startowy, więc znajomość wystarcza od razu po nauczeniu u NPC.

## 4. Jak to się łączy z resztą

- **Poziomy skilli z fazy 2** (`otwarte.md`, szansa Toxic Shock 50 / 65 / 80 %) to ten sam mechanizm — jeden system, nie dwa.
- **True ending:** tier 9 arcymaga to dodatkowe sloty / wysokie tiery dostępne po finale; akcesoria z „+1 do maks. tieru” pasują do ukrytych przedmiotów.
- **Drużyna:** każdy członek ma własny budżet i własną listę poziomów (sojusznicy mogą mieć inną krzywą).
- **Wrogowie** nie używają slotów (mają `szansę użycia` i `cooldown`).

## 5. Do uzgodnienia

1. Wartości jednostek (1 / 2 / 3 / 5) i budżetu na poziom; limit aktywnych skilli (6?).
2. Czy skill T4 może być ustawiony tylko na poziomie 4, czy też niższym (propozycja: wybór dowolny w zakresie poziomów z tabeli).
3. Czy Skan i skill combo (Death Enrage, 5. slot) leżą poza budżetem (propozycja: tak).
4. Format akcesoriów (jednostki budżetu, ±1 tier) i które z obecnych `lucky_charm` / nowych dostają bonus.
5. UI: ekran w menu pauzy (lista skilli, suwak poziomu, pasek budżetu), widok w walce bez zmian.
6. Zapis: lista (skill, poziom) na członka.
