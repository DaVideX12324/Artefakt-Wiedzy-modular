# Klasy postaci, system broni strefowych i rozszerzona drużyna

> Dokument koncepcyjno-architektoniczny (2026-10-10, decyzja autora).
> **Przeznaczenie:** Podstawa wdrożenia architektonicznego dla sesji z **Claude Opus** (mechanika klas, system rezerwy, restrykcje ekwipunku) oraz masowego tworzenia zasobów `.tres` przez **Gemini** (16 broni per strefa, ikony, skille).

---

## 1. Przegląd założeń

1. **4 Klasy Postaci (archetypy)**:
   - Każda postać grywalna i każdy towarzysz posiada przypisaną klasę: **Wojownik (Warrior)**, **Łotrzyk (Rogue)**, **Mag (Mage)**, **Kapłan (Priest)**.
   - Klasa determinuje bazowy profil statystyk (ATK/DEF/MAT/MDF), styl drzewka umiejętności oraz typy broni, które postać może założyć.
2. **Restrykcje broni per klasa**:
   - Bronie posiadają ograniczenie klasowe (`required_class` / `allowed_classes`).
   - Wojownik nie może nosić sztyletu ani kostura maga; mag nie założy dwuręcznego miecza itp.
3. **16 Broni na każdą strefę (4 typy × 4 warianty)**:
   - Każda z 10 stref gry posiada 4 linie broni (odpowiadające 4 klasom).
   - Każda linia ma 4 warianty jakościowe/rzadkości w obrębie danego biomu:
     - **Wariant 1 (Zwykły)** — standardowy drop / zakup
     - **Wariant 2 (Ulepszony)** — skrzynie i silniejsi wrogowie
     - **Wariant 3 (Rzadki)** — ukryte nisze, trudne quizy
     - **Wariant 4 (Unikatowy / Legendarny)** — bardzo rzadki, drop z bossa lub sekretów; część z nich to **najpotężniejsze przedmioty w całej grze** (endgame / top-tier)
   - Łącznie w grze: 10 stref × 16 broni = **160 unikalnych broni**.
4. **Rozszerzona drużyna (Więcej niż 4 towarzyszy)**:
   - W grze istnieje więcej niż 4 potencjalnych towarzyszy do zwerbowania w trakcie podróży.
   - W walce i eksploracji aktywna jest drużyna do **4 postaci** (`party`).
   - Nadmiarowi towarzysze trafiają do puli rezerwowej (`reserve_party`), dostępnej do rotacji w mieście, obozie lub w dedykowanym menu.

---

## 2. Klasy Postaci (Archetypy)

Zgodność z pakietem **Pixel Crawler** (wrogowie i bohaterowie dzielą się na te same archetypy: `Soldier/Knight`, `Rogue/Archer`, `Mage/Scholar`, `Priest`):

| Klasa | Rola w walce | Główne atrybuty | Dedykowane typy broni | Przykładowe postaci / towarzysze |
|---|---|---|---|---|
| **Wojownik** (`warrior`) | Tank, ciosy fizyczne, prowokacja, wysoka przeżywalność | Wysokie HP, wysoki DEF, solidny ATK | Miecze, topory, tasaki, miecze dwuręczne | Rycerz zamkowy, Wojownik ze straży, Freddy / Bonnie (tanker) |
| **Łotrzyk** (`rogue`) | DPS fizyczny, ciosy wielokrotne (multi-hit), statusy, wysokie AGI, krytyki | Wysoki ATK, wysokie AGI, zbalansowane HP, niski DEF | Sztylety, kindżały, łuki, rapiery | Zwiadowca ze ścieków, Łowca z jaskiń, Foxy |
| **Mag** (`mage`) | DPS magiczny, ataki żywiołów, AoE, łamanie odporności | Wysoki MAT, wysokie SP, niski HP, niski DEF | Kostury, laski żywiołów, kryształowe różdżki | Uczony z biblioteki, Wiedźma bagienna, BB |
| **Kapłan** (`priest`) | Healer, wsparcie, buffy (ATK/DEF Up), wskrzeszanie | Wysoki MDF, solidny MAT, średnie HP/DEF | Buławy, młoty kapłańskie, relikwiarze, święte laski | Kapłanka światła, Medyk miejski, Chica |

---

## 3. Matryca 16 Broni na Strefę (10 stref × 4 klasy × 4 tiery)

Zestawienie biome-packów z Pixel Crawlera z 4 archetypami broni:

| # | Strefa w grze | Pack Pixel Crawlera | 1. Wojownik (Miecz/Topór) | 2. Łotrzyk (Sztylet/Łuk) | 3. Mag (Kostur/Różdżka) | 4. Kapłan (Buława/Młot) |
|---|---|---|---|---|---|---|
| 1 | **Cave / Samouczek** | `cave_spore` (`Spore_Roots`) | Korzenny Tasak (1–4) | Zarodnikowy Sztylet (1–4) | Pnączowy Kostur (1–4) | Grzybowa Pałka (1–4) |
| 2 | **Sewer (Ścieki)** | `sewer_poison` (`Poison Weapons`) | Rynsztokowy Topór (1–4) | Jadowity Kindżał (1–4) | Toksyczna Różdżka (1–4) | Kwasowy Młot (1–4) |
| 3 | **Cemetery (Cmentarz)** | `cemetery_cursed` (`Cursed Weapons`) | Przeklęty Tasak (1–4) | Kościany Sztylet (1–4) | Kostur Nekromancji (1–4) | Młot Grabieży (1–4) |
| 4 | **Fairy Forest** | `fairy_elf` (`Elf_Weapon`) | Elfie Ostrze (1–4) | Leśny Sztylet/Łuk (1–4) | Kostur Driady (1–4) | Berło Światłości (1–4) |
| 5 | **Desert (Pustynia)** | `desert_gold` (`Desert-Gold`) | Złoty Sejmitar (1–4) | Pustynny Kindżał (1–4) | Berło Ozyrysa (1–4) | Słoneczny Buzdygan (1–4) |
| 6 | **Forge (Kuźnia/Wulkan)** | `forge_fire` (`Fire Weapons`) | Magmowy Tasak (1–4) | Płonący Sztylet (1–4) | Piromantyczna Laska (1–4) | Młot Kowalski (1–4) |
| 7 | **Hideout / Gęsty Las** | `hideout_rustic` (`Rustic`) | Myśliwski Kord (1–4) | Skrytobójczy Sztylet (1–4) | Runiczny Kij (1–4) | Ciężka Maczuga (1–4) |
| 8 | **Library (Biblioteka)** | `library` (`Weapons.png`) | Runiczny Pałasz (1–4) | Szpada Arkanów (1–4) | Kostur Wiedzy (1–4) | Mistyczna Kula (1–4) |
| 9 | **Garden (Ogród)** | `garden` (`Weapons.png`) | Florystyczny Tasak (1–4) | Cierniowy Rapier (1–4) | Różana Różdżka (1–4) | Berło Flory (1–4) |
| 10 | **Castle (Zamek / Miasto)** | `castle_marble` & `reinforced_iron` | Marmurowy Miecz (1–4) | Szlachecki Sztylet (1–4) | Berło Arcymaga (1–4) | Królewska Buława (1–4) |

### 4 Warianty w obrębie każdego typu broni:
1. **Wariant T1 (Zwykły)** — bazowe obrażenia strefowe.
2. **Wariant T2 (Wzmocniony)** — ~1.3× obrażeń T1, lekki bonus do statystyki pobocznej (np. DEF, MAT, LUK).
3. **Wariant T3 (Elitarny)** — ~1.7× obrażeń T1, szansa na nałożenie statusu powiązanego ze strefą (np. poison w ściekach, burn w kuźni, blind na pustyni).
4. **Wariant T4 (Legendarny / Topowy)** — unikalny model, potężny mnożnik (~2.2×–3.5×), unikalny pasywny bonus. W późniejszych biomach (Kuźnia, Biblioteka, Ogrody, Zamek) są to **absolutne endgame'owe best-in-sloty**.

---

## 4. Architektura Towarzyszy i Drużyny (dla Claude Opus)

### 4.1. Stan Drużyny w `PlayerStats`
Obecny model przechowuje prostą tablicę `party: Array[Dictionary]`. 
Wymagane rozszerzenie:
- `active_party: Array[Dictionary]` — aktywna drużyna (max 4 osoby biorące udział w walce i chodzące po mapie).
- `reserve_party: Array[Dictionary]` — lista zwerbowanych towarzyszy oczekujących w rezerwie.
- Wsteczna kompatybilność zapisu gry: jeśli w starym save brak `reserve_party`, inicjalizowana jako pusta tablica `[]`.

### 4.2. Klasa w `QuizRpgHeroData`
W pliku [`modules/quiz_rpg/scripts/heroes/hero_data.gd`](file:///F:/Programy/GitHub/Artefakt%20Wiedzy%20modular/modules/quiz_rpg/scripts/heroes/hero_data.gd):
```gdscript
@export_enum("warrior", "rogue", "mage", "priest") var character_class: String = "warrior"
```
Do słownika `member` w `build_member_data()` dopisujemy:
```gdscript
"character_class": character_class
```

### 4.3. Ograniczenia ekwipunku w `QuizRpgItemData`
W pliku [`modules/quiz_rpg/scripts/items/item_data.gd`](file:///F:/Programy/GitHub/Artefakt%20Wiedzy%20modular/modules/quiz_rpg/scripts/items/item_data.gd):
```gdscript
## Dozwolone klasy ("" lub pusta lista = każda postać może założyć)
@export var allowed_classes: PackedStringArray = []
```
W `PlayerStats.set_member_equipment(member_idx, slot, item_id)`:
- Sprawdzenie, czy `allowed_classes` przedmiotu zawiera `member["character_class"]`.
- Jeśli nie — zablokowanie założenia przedmiotu i zwrócenie `false` / stosowny komunikat w UI.

### 4.4. UI Zarządzania Drużyną
- W menu pauzy (Esc) oraz u NPC w Mieście: ekran **„Drużyna / Skład”**.
- Możliwość zamiany miejscami członków aktywnej czwórki z rezerwą.
- Wyposażanie i podgląd statystyk postaci z rezerwy.

### 4.5. Orszak na mapie eksploracji (`player.gd`)
- Dynamiczne generowanie sprite'ów followerów podążających za liderem (łańcuch pozycji `history` lidera).
- Sprite i animacje pobierane z `actor_scene` lub `sprite_frames` danego `HeroData`.

---

## 5. Podział Pracy: Claude Opus vs. Gemini

| Obszar | Przypisany Agent | Zakres prac |
|---|---|---|
| **Kod rdzenny (`PlayerStats`, `HeroData`, `inventory_service.gd`)** | **Claude Opus** | Dodanie pól klas, weryfikacji ekwipunku, podziału na `active_party` / `reserve_party`, metody wymiany członków, migracja save'a |
| **Followerzy na mapie (`player.gd`)** | **Claude Opus** | Pętla podążania członków aktywnej drużyny za liderem |
| **UI Drużyny (Menu Esc / Miasto)** | **Claude Opus** | Interfejs wymiany i podglądu rezerwy |
| **Wycięcie ikon broni (Python)** | **Gemini** | Pocięcie arkuszy Pixel Crawlera na pojedyncze PNG do `assets/textures/icons/weapons/` |
| **Generowanie plików `.tres` (160 broni)** | **Gemini** | Tworzenie zasobów `.tres` dla 10 stref (po 16 broni: nazwy, opisy, staty, `allowed_classes`, ikony) |
| **Zasoby towarzyszy i skilli towarzyszy** | **Gemini** | Tworzenie `.tres` dla kolejnych towarzyszy (`resources/heroes/`) i ich skilli (`resources/skills/`) |

---

## 6. Struktura Assetów Broni w Pixel Crawlerze: Zestawy Wielowariantowe vs. Zestawy Pojedyncze

W assetach Pixel Crawlera (Anokolisa) widoczny jest wyraźny podział na dwie grupy paczek pod względem bogactwa oręża:

### Typ A: Bogate Zestawy Wielowariantowe (wiele różnych wariantów dla wielu klas)
* **Przykłady:**
  * **Caves (`cave_spore` / `Spore_Roots.png`):** Aż ~39 odrębnych sprajtów broni! Wiele różnych wariantów sztyletów, lanc korzennych, pałek, łuków i pnączy.
  * **Library (`library/Weapons.png`):** Aż ~68 sprajtów! Mnóstwo różnych typów i wariantów oręża (różne miecze, rapierki, sztylety, kostury, księgi/relikwie, tarcze).
  * **Garden (`garden/Weapons.png`):** Duży arkusz (208×320) z bogatą reprezentacją wielu wariantów broni różnej maści.
  * **Base / Reinforced Iron / Marble:** Pełne arkusze z wieloma wariantami każdego typu broni (krótkie, długie, dwuręczne, zróżnicowane głowice).
* **Wpływ na grę:** W tych strefach każdy z 4 wariantów jakościowych (T1–T4) dla każdej z 4 klas może mieć swój **własny, w pełni unikalny sprajt** wycięty bezpośrednio z arkusza.

### Typ B: Zestawy Skupione / Pojedyncze (po 1 wariancie z danego typu)
* **Przykłady:**
  * **Sewer (`sewer/Poison Weapons.png`):** ~19 sprajtów łącznie — pojedynczy zatruty sztylet, pojedyncza lanca, pojedynczy tasak, pojedyncza tarcza.
  * **Desert (`desert/Desert-Gold.png`):** ~20 sprajtów — po 1 wariancie złotego sztyletu, szabli/sejmitara, włóczni i łuku.
  * **Forge (`weapons/fire_weapons/Fire Weapons.png`):** ~15 sprajtów — po 1 sztuce z danego typu (np. jeden ognisty młot, jeden sztylet, jeden miecz).
  * **Fairy Forest (`fairy_forest/Elf_Weapon.png`):** Jeden smukły łuk, jedno elfie ostrze, jeden sztylet.
* **Wpływ na grę:** W tych strefach dany typ broni ma w arkuszu tylko **jedną bazową grafikę**. 
  * Warianty T1–T4 w obrębie danego typu (np. Jadowity Sztylet T1 → T2 → T3 → T4) dzielą tę samą biomową ikonę (lub lekki wariant kolorystyczny / elementy z arkusza), rosnąc w statystykach, opisach i rzadkości.
  * Alternatywnie: wariant T4 (najrzadsza legenda strefy) może być unikalną bronią specjalną z tego zestawu (np. specyficzna kosa, egzotyczny sierp czy wielki magmowy młot).
