# Opisy umiejętności do przetłumaczenia (zadanie dla Gemini)

Cel: dopisać opisy umiejętności po polsku i angielsku do `modules/quiz_rpg/resources/i18n/pl.json` i `en.json`
(te same klucze w obu plikach). Gra już czyta klucz `skill.<plik>.desc`; gdy go brak, pokazuje `description` z `.tres`.

## Format
- Plik: płaski słownik JSON, UTF-8, wcięcie 2 spacje, nowe wpisy dopisać **pod** istniejącymi `skill.*.name`.
- Klucz: `skill.<nazwa pliku .tres bez rozszerzenia>.desc` (kolumna „klucz” poniżej).
- Wartość: 1–2 zdania, opis działania w grze (co robi, ile trafień, jaki status i szansa, koszt nie — koszt pokazuje UI).
- Nie wymieniaj postaci ani rekwizytów z FNaF; nie zmieniaj istniejących `skill.*.name`.
- Nie dopisuj zdania „Wymaga broni…” — dokleja je kod (jeszcze po polsku, do tłumaczenia osobno).
- Liczby weź z kolumny „obecny opis / działanie” albo z `.tres` (źródło prawdy: plik `.tres`; przy rozbieżności daj znać, nie zgaduj).
- Wrogowie: opis widzi gracz w Skanie, więc pisz z perspektywy „co ten atak robi mojej drużynie”.
- Po zapisie: `python -c "import json;json.load(open('pl.json',encoding='utf-8'))"` (to samo dla en.json) — oba muszą się parsować,
  a zestawy kluczy muszą być identyczne.


## Umiejętności gracza / sojuszników

| klucz | EN | PL | obecny opis (.tres) |
|---|---|---|---|
| `skill.aerial_strike.desc` | Fearless Flight | Podniebny Cios | Szarża z powietrza. Fizyczna i magiczna. |
| `skill.coin_barrage.desc` | Shrapnel Toss | Grad Odłamków | Ciska monetami w losowych wrogów. Trafia kilkukrotnie. |
| `skill.death_enrage.desc` | Death Enrage | Szał Śmierci | Wpada w furię atakując wszystkich wrogów serią zabójczych ciosów. |
| `skill.dive_attack.desc` | Flying Fright | Pikujący Cios | Nurkuje we wroga z potężną siłą. |
| `skill.double_throw.desc` | Double Strike | Podwójny Cios | Rzuca przedmiotem we wroga. Dwa trafienia. |
| `skill.final_strike.desc` | Final Strike | Ostateczne Cięcie | Cały impet w jednym ciosie (ATK × 8). |
| `skill.hearty_meal.desc` | Hearty Meal | Pożywny Posiłek | Leczy sojusznika o MAT × 4 HP. Działa też w menu. |
| `skill.leap_series.desc` | Rapid Flurry | Szybka Seria | Pięć skoków po głowie wroga. Może ogłuszyć. |
| `skill.leczenie.desc` | First Aid | Pierwsza Pomoc | Przywraca 30 % HP (po złej odpowiedzi 1/3 tego). Działa też w menu. |
| `skill.lullaby.desc` | Lullaby | Kołysanka | Dziewięć lekkich trafień w rytm melodii. Duża szansa uśpienia wroga. |
| `skill.mocny_atak.desc` | Heavy Strike | Ciężki Cios | Cięższy cios: 1,5 × zwykłe obrażenia. |
| `skill.nurturing_care.desc` | Guardian Ward | Żelazna Straż | Podaje sojusznikowi orzeźwiający napój. Zwiększa obronę i odnawia SP. |
| `skill.onslaught.desc` | Rushdown | Natarcie | Sześć szybkich ataków. |
| `skill.piercing_shriek.desc` | Toxic Dart | Zatruta Strzałka | Wrzask, który rani zatrutego wroga ponad dwa razy mocniej. Może zatruć. |
| `skill.reckless_blow.desc` | Backup Bash | Hazardowy Cios | Niewiarygodny cios... ale trafia rzadko (8 %). |
| `skill.revive_tonic.desc` | Revive Tonic | Ożywienie | Wskrzesza nieprzytomnego sojusznika z 30 % maks. HP. Działa też w menu. |
| `skill.rousing_tune.desc` | Motivation Jam | Zastrzyk Motywacji | Gra motywujący utwór. Zwiększa atak sojusznika. |
| `skill.scan.desc` | Scan | Skan | Pokazuje HP, statystyki i opis wybranego wroga. Nie zużywa tury. |
| `skill.sea_chant.desc` | Sea Shanty | Morska Szanta | Nuci morską melodię. Osłabia wroga i może go uciszyć. |
| `skill.share_tempo.desc` | Speed Share | Wspólne Tempo | [TODO: wymaga AGI — na razie daje ATK w górę] Dzieli się impetem z całą drużyną, zwiększając jej zwinność. |
| `skill.shove.desc` | Paralyzing Strike | Paraliżujący Cios | Wróg zostaje zepchnięty w dół. Może sparaliżować. |
| `skill.smoke_cloud.desc` | Smoke Ring | Zasłona Dymna | Wypuszcza gęsty dym. Szansa na oślepienie wroga. |
| `skill.sound_wave.desc` | Toxic Shock | Toksyczna Fala | Silne wibracje. Szansa na zatrucie wroga. |

## Umiejętności wrogów i bossów

| klucz | EN | PL | obecny opis (.tres) |
|---|---|---|---|
| `skill.battering_dash.desc` | Battering Dash | Gwałtowna Szarża | — |
| `skill.blinding_smoke.desc` | Smoke Lens | Oślepiający Dym | — |
| `skill.burst_swarm.desc` | Flash Barrage | Seria Rozbłysków | — |
| `skill.crushing_blow.desc` | Crushing Blow | Miażdżący Cios | — |
| `skill.dark_regen.desc` | Dark Mending | Mroczna Regeneracja | — |
| `skill.decay_breath.desc` | Decay Breath | Oddech Zgnilizny | — |
| `skill.dizzying_gaze.desc` | Confusion Lens | Otumaniające Spojrzenie | — |
| `skill.dual_attack.desc` | Dual Attack | Podwójne Uderzenie | — |
| `skill.frenzy_charge.desc` | Frenzy Rush | Szał Uderzeń | — |
| `skill.heavy_strike.desc` | Shock Flurry | Porażająca Salwa | — |
| `skill.knockdown.desc` | Knockdown | Ogłuszające Powalenie | — |
| `skill.phantom_volt.desc` | Phantom Volt | Widmowe Porażenie | — |
| `skill.poison_vine.desc` | Poison Vine | Zatrute Pnącze | — |
| `skill.relentless_assault.desc` | Relentless Assault | Nieustępliwy Szturm | — |
| `skill.sonic_blast.desc` | Sonic Blast | Fala Dźwiękowa | — |
| `skill.spook_howl.desc` | Spook Howl | Złowrogi Skowyt | — |
| `skill.timed_charge.desc` | Blast Wave | Fala Wybuchowa | — |
| `skill.toxic_gaze.desc` | Poison Lens | Zatrute Spojrzenie | — |
| `skill.triple_attack.desc` | Triple Attack | Potrójne Uderzenie | — |
| `skill.venom_screech.desc` | Venom Screech | Jadowity Pisk | — |
| `skill.whirling_slash.desc` | Whirling Slash | Wirujące Cięcie | — |
