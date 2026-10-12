# Brief dla Gemini: teksty logu walki wrogów (EN + PL)

**Zadanie (proste, tekst):** dla 21 umiejętności wrogów dopisać w `resources/i18n/en.json` i `pl.json` klucz `skill.<plik>.log`.
Kod już go czyta (`QuizRpgEnemySkill.localized_log_text()`); bez klucza gra używa polskiego `log_text` z zasobu, więc można dopisywać stopniowo.

## Zasady
- Klucz: `skill.<nazwa pliku .tres bez rozszerzenia>.log`, wartość = jedno zdanie, które gracz widzi w logu walki, gdy wróg używa umiejętności.
- Zachować dokładnie znaczniki `{enemy}` (nazwa wroga) i opcjonalnie `{skill}` (nazwa umiejętności) — nie tłumaczyć, nie zmieniać nawiasów.
- **PL**: istniejący tekst z kolumny „Obecnie (PL)” jest wzorem stylu — można go zostawić bez zmian (skopiować do `pl.json`), poprawić tylko literówki.
- **EN**: naturalne, krótkie zdanie w czasie teraźniejszym, ten sam sens i liczby (np. „osiem razy” → „eight times”), bez motywów FNaF.
- Edytować oba pliki JSON zachowując istniejące klucze, kodowanie UTF-8, ten sam styl wcięć (2 spacje). Przed edycją odczytać plik z dysku (inni też go edytują).
- Po skończeniu wpisać na dole tego pliku „GOTOWE” z datą; weryfikację (kompletność kluczy w obu językach) robię ja.

## Lista

| Plik (klucz `skill.<plik>.log`) | Obecnie (PL) |
|---|---|
| `battering_dash` | {enemy} z impetem taranuje cel! |
| `blinding_smoke` | {enemy} spowija pole bitwy gęstym dymem! |
| `burst_swarm` | {enemy} detonuje serię ładunków z ogłuszającym hukiem! |
| `crushing_blow` | {enemy} wyprowadza potężny, ryzykowny cios! |
| `dark_regen` | {enemy} pochłania mroczną energię i odzyskuje siły! |
| `decay_breath` | {enemy} zieje odrażającym, trującym oparem! |
| `dizzying_gaze` | {enemy} posyła hipnotyczny błysk mącący zmysły! |
| `dual_attack` | {enemy} atakuje dwukrotnie! |
| `frenzy_charge` | {enemy} bezlitośnie szarżuje osiem razy! |
| `heavy_strike` | {enemy} atakuje plątaniną metalowych członków! |
| `knockdown` | {enemy} spycha przeciwnika w dół! |
| `phantom_volt` | {enemy} wyładowuje upiorne wyładowanie elektryczne! |
| `poison_vine` | {enemy} oplata cię trującym pnączem! |
| `relentless_assault` | {enemy} wykonuje serię 6 gwałtownych natarć! |
| `sonic_blast` | {enemy} generuje potężną falę dźwiękową! |
| `spook_howl` | {enemy} wydaje mrożący krew w żyłach skowyt! |
| `timed_charge` | {enemy} ciska tykający ładunek we wrogów! |
| `toxic_gaze` | {enemy} błyska toksycznym światłem! |
| `triple_attack` | {enemy} wyprowadza serię trzech ciosów! |
| `venom_screech` | {enemy} wydaje z siebie pisk rozdzierający uszy! |
| `whirling_slash` | {enemy} tnie wirującym ostrzem! |

Liczba pozycji: 21.
