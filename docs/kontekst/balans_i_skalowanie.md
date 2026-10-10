# Balans i Skalowanie Walki: HP, ATK, Pancerz i Formuły Obrażeń

> **Dokument projektowy i analityczny dla Claude Opus**  
> Data sporządzenia: 2026-10-10  
> Powiązane dokumenty: [`walka.md`](walka.md), [`klasy_postaci_i_bronie.md`](klasy_postaci_i_bronie.md), [`otwarte.md`](otwarte.md)

---

> **Uwaga (2026-10-11):** przykłady liczbowe w sekcjach 2.A0–2.C pochodzą z analizy sprzed przebalansowania wrogów i
> były liczone z błędnymi wartościami startowego ekwipunku (miecz treningowy ma +10 ATK, tarcza / czapka / tunika po +4 DEF —
> poprawione w tekście, wyniki pochodne są przybliżone). Statystyki wrogów zmieniono po tej analizie (tiery HP 120 / 350 / 900 / 2200,
> ATK 26 / 52 / 85 / 150, DEF 30 / 60 / 95 / 140), a mnożniki umiejętności bohatera obniżono — patrz commit „Balans".

## 1. Problem i Diagnoza (Zgłoszenie z testów)

### Zgłoszone objawy:
1. **Wrogowie padają za szybko**: umiejętności bohatera (np. *Rzut Cylindrem* / `tophat_toss`) zadają ogromny burst damage, eliminując przeciwników jednym ciosem.
2. **Wrogowie zadają za mało obrażeń**: ataki wrogów ledwo uszkadzają drużynę (kilkanaście do kilkudziesięciu HP przy puli gracza 334+ HP). Drużyna jest niemal nietykalna, zwłaszcza przy używaniu obrony / quizu.
3. **Dysproporcja skalowania**: formuła RPG Makera / FNaFB (`ATK × 4 − DEF × 2`) jest silnie nieliniowa – niewielki wzrost pancerza drastycznie neutralizuje ataki wrogów, a wzrost ataku broni potęguje obrażenia gracza czterokrotnie.

---

## 2. Źródła problemu w obecnym kodzie i zasobach

### A0. Zwykły atak gracza (Basic Attack) zadający ponad 100 DMG
Nawet bez użycia jakiejkolwiek umiejętności, **zwykły atak gracza regularnie zadaje 90–100+ DMG** (a przy krytyku 160–180+ DMG). Dlaczego tak się dzieje?
1. **Wzór w `QuizRpgSkillMath.basic_attack`**:
   $$\text{Obrażenia} = \text{ATK} \times 4.0 - \text{DEF} \times 2.0$$
2. **Potężny mnożnik $\times 4.0$ przy ATK**:
   - Bohater na poziomie 1 ma `base_atk = 20`.
   - Miecz treningowy (`training_sword`) daje `+10 ATK`.
   - Łączny atak bohatera wynosi **30 ATK**.
   - Sam człon $\text{ATK} \times 4.0$ generuje **100 bazowych punktów obrażeń** jeszcze przed uwzględnieniem pancerza!
3. **Za niski DEF wrogów w scenach**:
   - W istniejących scenach przeciwników (np. `scenes/enemies/bandit_1.tscn`, `bandit_2.tscn`) wróg ma ustawione zaledwie `defense = 5`!
   - W rezultacie pancerz wroga odejmuje zaledwie $5 \times 2 = 10\text{ DMG}$.
   - Zwykły atak gracza zadaje więc:
     $$25 \times 4.0 - 5 \times 2.0 = 100 - 10 = 90\text{ DMG (z rozrzutem } \pm 10\% \text{: 81–99 HP)}$$
   - Jeśli wróg ma `defense = 0`, atak wynosi równe **100 DMG**.
   - W przypadku krytyka (15% szansy, mnożnik $\times 1.8$ w `_apply_player_hit`):
     $$90 \times 1.8 = 162\text{ DMG!}$$
4. **Wzrost po zdobyciu lepszej broni**:
   - Wystarczy, że gracz założy miecz żelazny (`iron_sword` +20 ATK, łącznie 45 ATK):
     $$45 \times 4.0 - 5 \times 2.0 = 180 - 10 = 170\text{ DMG zwykłym atakiem!}$$
   - Przy HP wrogów rzędu 60–160 (np. `knowledge_guardian` 60 HP, `bandit_2` 160 HP), gracz zabija wrogów **jednym zwykłym atakiem**, bez używania jakichkolwiek umiejętności!

### A. Rzut Cylindrem i skille przeniesione z CC (Complete Collection)
W `resources/skills/tophat_toss.tres`:
- `hits`: 2
- `base_damage`: 100
- `atk_coeff`: 3.4
- `def_coeff`: 2.0
- `damage_multiplier`: 1.35
- **Rzeczywiste obrażenia jednego ciosu**: `1.35 × (100 + ATK × 3.4 − DEF × 2.0)`
- Dla bohatera na lv 1 z mieczem treningowym (ATK = 30) przeciw wrogowi o DEF = 12:
  $$\text{Dmg na trafienie} = 1.35 \times (100 + 85 - 24) = 1.35 \times 161 \approx 217$$
  $$\text{Łączny atak (2 trafienia)} = 434\text{ HP!}$$
- W efekcie Rzut Cylindrem na lv 1 zadaje ponad 400 DMG, co deklasuje każdego zwykłego przeciwnika.

### B. Atak wrogów a pancerz drużyny
W `resources/enemies/enemy_data.gd` / `scenes/enemies/plant_1.tscn`:
- Wróg ma `attack = 24`.
- Bohater na lv 1 ma bazowe `base_def = 15`.
- Ze startowym ekwipunkiem (`wooden_shield`, `adventurer_tunic`, `cloth_cap` po +4) DEF bohatera wynosi **27**.
- Atak zwykły wroga zadaje:
  $$\text{Dmg} = 24 \times 4 - 20 \times 2 = 96 - 40 = 56\text{ HP}$$
- Bohater na lv 1 ma **334 HP**. Wróg potrzebuje aż **6 nieblokowanych ciosów**, aby powalić pojedynczego bohatera.
- Przy udanym bloku gracz otrzymuje **0 HP**, a przy nieudanym bloku **28 HP** (potrzeba 12 tur!).

### C. Tiery ekwipunku potęgują rozjazd
Dodane tiery broni i zbroi (`resources/items/`):
- Bronie: +10 (trening) $\rightarrow$ +20 (żelazo) $\rightarrow$ +40 (stal) $\rightarrow$ +80 (rycerski) $\rightarrow$ +160 (runiczny) $\rightarrow$ +320 (shadowbane).
- Zbroje/Tarcze: +4 $\rightarrow$ +8 $\rightarrow$ +16 $\rightarrow$ +32 $\rightarrow$ +64 per slot (razem: +8 $\rightarrow$ +24 $\rightarrow$ +48 $\rightarrow$ +96 $\rightarrow$ +192 DEF).
- Każdy +1 punkt DEF redukuje otrzymywane obrażenia o 2 punkty. Pancerz stalowy (+48 DEF) redukuje obrażenia wroga o **96 HP**, co natychmiast zeruje ataki wszystkich wrogów o ATK $\le 48$.

---

## 3. Punkt Odniesienia: FNaFB1 FM (Final Mix)

Dane wyciągnięte z dekompilacji FNaFB1 FM (`fnafb_skille/1_fnafb1_FM_sojusznicy.txt` i `2_fnafb1_FM_wrogowie.txt`):

### Tabela Wrogów FNaFB1 FM:
| Wróg | Tier | HP | ATK | DEF | MAT / MDF | Formuła Ataku |
|---|---|---|---|---|---|---|
| **Alpha Party Hat** | Tier 1 (start) | 100 | 20 | 20 | 20 | `ATK × 4 − DEF × 1.8` |
| **Beta Party Hat** | Tier 2 | 400 | 40 | 40 | 40 | `ATK × 4 − DEF × 1.8` |
| **Gamma Party Hat** | Tier 3 | 1200 | 80 | 80 | 80 | `ATK × 4 − DEF × 1.8` |
| **Omega Party Hat** | Tier 4 | 2400 | 160 | 160 | 160 | `ATK × 4 − DEF × 1.8` |
| **Show Stage Camera** | Boss / Elita | 4000 | 70 | 40 | 40 | `ATK × 4 − DEF × 1.8` |
| **Backroom Camera** | Boss / Elita | 5000 | 80 | 50 | 50 | 2–3 ataki w turze |

### Kluczowe różnice FNaFB1 FM vs nasz obecny stan:
1. **Mnożnik DEF celu wynosi 1.8, a nie 2.0**:
   - `ATK × 4 − DEF × 1.8` sprawia, że obrona nie ucina obrażeń tak gwałtownie jak przy mnożniku 2.0.
2. **Tophat Toss w FM nie miał mnożnika 1.35**:
   - Wzór w FM: `100 + ATK × 3.2 − DEF × 1.6` (bez zewnętrznego `1.35×`).
3. **Stosunek HP do ATK**:
   - Alpha Party Hat ma 100 HP, ale bije gracza za `20 × 4 − 15 × 1.8 = 80 − 27 = 53 HP`. W 2 tury zbija ponad 30% HP gracza!
   - Wrogowie w FNaFB są niebezpieczni („szklane armaty” – szybko giną, ale szybko zabijają).

---

## 4. Metryki Docelowe (Target TTK — Time to Kill)

Wzorzec rozgrywki quizowo-taktycznej:
1. **Zwykły wróg pojedynczy**:
   - Zwykły atak gracza: **2 do 3 trafień** na zabicie wroga.
   - Skill ofensywny (np. Rzut Cylindrem, Mocny Atak): **1 do 2 trafień** (nagroda za SP/TP i dobrą odpowiedź w quizie).
2. **Grupa wrogów (2–3 przeciwników)**:
   - Łączne obrażenia grupy wrogów w 1 rundzie bez bloku: **~25–35% maks. HP postaci**.
   - Po 3–4 turach bez leczenia postać powinna być bliska śmierci.
3. **Obrona i Quiz**:
   - Dobra odpowiedź przy obronie: **0 obrażeń** (nagroda za wiedzę).
   - Zła odpowiedź przy obronie: **50% obrażeń**.
   - Zwykły atak po złej odpowiedzi: **20% szansy trafienia** (lub zredukowany mnożnik).

---

## 5. Propozycja Skalowania dla 10 Stref i Poziomów Gracza

Dopasowanie statystyk wrogów do poziomów postaci i tierów sprzętu:

| Strefa / Biom | Sugerowany Tier | Poziom Gracza | Sugerowane HP Wroga | ATK Wroga | DEF Wroga | Dostępny Sprzęt |
|---|---|---|---|---|---|---|
| **Jaskinie (Caves / Tutorial)** | Tier 1 | Lv 1–3 | 120 – 180 | 26 – 32 | 14 – 18 | Tier 0 (treningowy) |
| **Ścieki (Sewer)** | Tier 1+ / 2 | Lv 4–6 | 250 – 350 | 38 – 46 | 22 – 28 | Tier 1 (żelazny) |
| **Katakumby (Catacombs)** | Tier 2 | Lv 7–9 | 450 – 600 | 52 – 62 | 32 – 40 | Tier 1+ / 2 (stalowy) |
| **Kuźnia (Forge)** | Tier 2+ / 3 | Lv 10–12 | 700 – 900 | 70 – 82 | 44 – 52 | Tier 2 (stalowy) |
| **Pustynia (Desert)** | Tier 3 | Lv 13–15 | 1100 – 1400 | 92 – 108 | 56 – 66 | Tier 3 (rycerski) |
| **Ogród (Garden)** | Tier 3+ | Lv 16–17 | 1500 – 1800 | 115 – 130 | 70 – 80 | Tier 3 (rycerski) |
| **Biblioteka (Library)** | Tier 4 | Lv 18–19 | 2000 – 2400 | 140 – 160 | 85 – 95 | Tier 4 (runiczny) |
| **Zamek / Finał** | Tier 4+ / 5 | Lv 20 | 2600 – 3200 | 170 – 200 | 100 – 120 | Tier 4 / 5 (legendarny) |

---

## 6. Zadania Implementacyjne

1. **Kalibracja zasobów i scen wrogów** (UKOŃCZONE ✅ 2026-10-10):
   - Zaktualizowano wszystkie sceny w `scenes/enemies/*.tscn` oraz dane `resources/enemies/pixel_crawler/data/*.tres`.
   - Zastąpiono dawny szablon (`DEF = 5`, `ATK = 18`) nowymi, skalowanymi progami FNaFB:
     - Tier 1: HP 120, ATK 26, DEF 30
     - Tier 2: HP 350, ATK 52, DEF 60
     - Tier 3: HP 900, ATK 85, DEF 95
     - Tier 4: HP 2200, ATK 150, DEF 140
   - Efekt: zwykły atak gracza na starcie zadaje teraz **~35–45 DMG** (zamiast 100+), co wymaga 3 trafień na wroga o 120 HP, a wróg zadaje graczowi **~64 DMG** (zamiast 30).
2. **Korekta formuły bazowej w `skill_math.gd`** (Dla Claude Opus):
   - Ewentualna zmiana mnożnika obrony na `1.8` jak w FNaFB FM (`ATK × 4 − DEF × 1.8`).
3. **Korekta mnożników umiejętności startowych** (Dla Claude Opus):
   - W `tophat_toss.tres`: opcjonalne zdjęcie zewnętrznego mnożnika 1.35 z wersji CC lub obniżenie bazowego dmg.
4. **Skrypt symulacji balansu (`tests/simulate_combat_balance.gd`)** (Dla Claude Opus):
   - Bezuruchomieniowy test headless symulujący 100 walk dla poziomów 1, 5, 10, 20.

   - W `tophat_toss.tres`:
     - Opcja A (wzór FM): usunięcie `damage_multiplier = 1.35` (ustawienie `1.0`), baza `100`, `atk_coeff = 3.2`, `def_coeff = 1.6`. Wtedy 2 trafienia dają łącznie `~220 HP` zamiast `434 HP`.
     - Opcja B: zachowanie mnożnika, ale obniżenie `base_damage` z 100 do 30–40.
3. **Skrypt symulacji balansu (`tests/simulate_combat_balance.gd`)**:
   - Bezuruchomieniowy test headless symulujący 100 walk dla poziomów 1, 5, 10, 20.
   - Raportowanie metryk: średnia liczba tur do zabicia wroga (TTK gracza), średnia liczba tur do śmierci gracza (TTK wroga), % wygranych przy 100% poprawnym quizie vs 50% poprawnym.
4. **Kalibracja zasobów wrogów (`resources/enemies/`)**:
   - Aktualizacja wartości `max_hp`, `attack`, `defense`, `magic_attack`, `magic_defense` w plikach `.tres` i scenach `.tscn` wrogów dla poszczególnych stref wg tabeli w sekcji 5.
