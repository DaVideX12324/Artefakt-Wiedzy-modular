# Drużyna — towarzysze, klasy, dołączanie (szkic do oceny)

Stan: **2026-10-16 — MVP grywalne na `druzyna-balans`** (sekcja „Zrobione 2026-10-16” na końcu). Szkic niżej to pierwotna propozycja z 2026-10-12.
Wszystkie nazwy i liczby to propozycje.

## 1. Decyzje usera

- **Role wynikają z klas.** Każda postać ma klasę (jak w JRPG); klasa wyznacza krzywe statystyk, pulę umiejętności, typy broni i styl walki.
- **Dołączanie po wykonaniu zadania od danej postaci** (lub czegoś podobnego) — nie automatycznie z fabuły ani z poziomu bohatera.
- **Wstępnie 3 towarzyszy** (razem z bohaterem 4 osoby; do potwierdzenia, czy „3” nie obejmuje bohatera). **Na razie bez limitu wielkości drużyny** — do walki wchodzi cała drużyna, nie ma składu zapasowego.
- **Każdy członek ma własną pulę XP i własny poziom** (osobne krzywe, osobny `LEVEL_CAP`-owy limit).
- **Martwy członek dostaje 50 % XP.**
- **Cel: kto dołączy późno, nie traci czasu na expowiskach** na niskich poziomach — nowy członek szybko dogania drużynę (sekcja 6).

## 2. Co już jest (nie trzeba budować od zera)

- `PlayerStats` liczy po członku: statystyki z ekwipunkiem (`get_member_total_stat`), umiejętności (`get_member_skills`, pula z `QuizRpgHeroData.skills`, `unlock_skill`), statusy,
  HP / SP, leczenie, ekwipunek (`set_member_equipment`), typ broni i wymagania skilli.
- Dane postaci: `QuizRpgHeroData` (`hero_id`, krzywe HP / SP / ATK / DEF / MAT / MDF, domyślny ekwipunek, pula skilli, miniatura). Nowa postać = nowy plik `.tres`.
- Walka i menu pauzy mają wiersze drużyny, `player.gd` ma tryb podążania towarzysza (`is_party_follower`), TP jest wspólną pulą drużyny (100).

## 3. Czego brakuje

1. Dane i grafiki trzech towarzyszy (animacje idle / walka / miniatura; arkusze Pixel Crawler mają bohaterów i klasy) oraz pole klasy w kodzie (`character_class`, `allowed_classes`).
2. **Rekrutacja:** sposób dodania członka do `party` (nowa funkcja `PlayerStats.recruit(hero_id, level)`), zapis / wczytanie składu (bez limitu liczby członków).
3. **Poziom i XP członków:** dziś `PlayerStats.level` jest jeden; propozycja niżej.
4. **Zadania towarzyszy** (sceny, dialog, cel zadania, nagroda), UI dziennika / znacznika.
5. Per członek: sloty tierów i budżet (`sloty_umiejetnosci_szkic.md`), pula skilli klasy, ekwipunek ograniczony typami broni.
6. Skille klasowe, których jeszcze nie ma (sekcja 4) — do napisania (dane, mogą pójść do Gemini).

## 4. Klasy (zdecydowane 2026-10-10, szczegóły: `klasy_postaci_i_bronie.md`)

Cztery klasy-archetypy z dokumentu klas (pole `character_class` w `QuizRpgHeroData`, `allowed_classes` w przedmiotach; w kodzie jeszcze **nie zaimplementowane**):

| Klasa | Rola w walce | Atrybuty | Bronie (`weapon_type` w kodzie) | Skille z obecnej puli (propozycja) |
|---|---|---|---|---|
| **Wojownik** (`warrior`) | tank, ciosy fizyczne, prowokacja | wysokie HP i DEF, solidny ATK | miecze, topory, dwuręczne (sword, axe) | Heavy Strike, Rapid Flurry, Rushdown, Flying Fright, Fearless Flight, Final Strike (miecz), Death Enrage, Guardian Ward, Paralyzing Strike |
| **Łotrzyk** (`rogue`) | DPS fizyczny, multi-hit, statusy, krytyki | wysokie ATK i AGI, niski DEF | sztylety, łuki, rapiery (dagger, bow) | Backup Bash (chance hit — wymagany przez Strażnika), Double Strike, Shrapnel Toss, Smoke Ring, Toxic Dart |
| **Mag** (`mage`) | DPS magiczny, AoE, łamanie odporności | wysoki MAT i SP, niski HP i DEF | kostury, laski, różdżki (staff) | Toxic Shock, Sea Shanty, Lullaby — **za mało, trzeba dopisać skille żywiołów / AoE** |
| **Kapłan** (`priest`) | leczenie, buffy, wskrzeszanie | wysoki MDF, solidny MAT | buławy, młoty, relikwiarze (mace) | First Aid, Hearty Meal, Revive, Motivation Jam, Speed Share |

Bohater: dziś jest Wojownikiem (miecz, zbalansowany) — do potwierdzenia. **3 towarzyszy = trzy pozostałe klasy (Łotrzyk, Mag, Kapłan)** to naturalne dopasowanie (dla ustalenia: czy tak).
Włócznia (`spear`) nie ma klasy — do przypisania (propozycja: Wojownik).
Wymóg ze Strażnika (faza 1): sojusznik ofensywny albo z chance hitem — Łotrzyk (Backup Bash).
Każdej klasie trzeba dopisać ok. 4–6 skilli, żeby klasy czuły się różne (szczególnie Mag i Łotrzyk; dane i opisy mogą iść do Gemini jak S6).

**Zgodność z dokumentem klas:** tam jest też rezerwa (`reserve_party`, aktywna czwórka). Decyzja usera 2026-10-12: **na razie cała drużyna w walce, bez limitu**; rezerwa i limit czterech zostają
jako późniejsza opcja.

## 5. Dołączanie przez zadanie (propozycja)

- Postać pojawia się w konkretnym miejscu (Hideout / miasto / mapa po jaskiniach) i **prosi o pomoc**; zadanie ma jeden jasny cel: przynieść przedmiot, pokonać wskazanego miniboss-a (tier 3),
  otworzyć konkretną skrzynię wytrychem albo odblokować przejście skillem.
- Po wykonaniu zadania dołącza na poziomie **bohatera minus 1–2** (nie niżej niż poziom startowy klasy), z podstawowym ekwipunkiem tieru bieżącej mapy.
- Naturalne ułożenie: zadania w trzech odnogach (Desert Temple, Forge, las / zima), skoro te biomy już mają bossów i blokady zamku — **po jednym towarzyszu na odnogę**.
  Do decyzji: czy ich zadania mają być powiązane z blokadami zamku, czy niezależne.

## 6. XP i poziomy członków

Decyzje usera (2026-10-12):
- **Jak we FNaFB: każdy członek dostaje tyle XP, ile dali przeciwnicy** (bez dzielenia przez liczbę członków), ale **każdy ma własną pulę XP** i własny poziom
  (osobny `xp` i `level` w danych członka; `member["level"]` już istnieje).
- **Martwy w chwili końca walki dostaje 50 % XP.**
- **Do walki wchodzi cała drużyna** (bez zapasowych, bez limitu liczby osób na razie).
- **Bez premii nadrabiania.** Nadrabianie załatwia wysoki XP z wrogów wysokiego tieru, a nie osobna mechanika; późny członek nie ma grindować na niskich mapach.
- **Poziom odniesienia = członek o najwyższym poziomie, nie lider** (gdzie potrzebny jeden poziom: start nowego członka — propozycja: najwyższy poziom − 1–2, wpisy logu progresji,
  `PlayerStats.level` jako „poziom drużyny” przestaje być poziomem bohatera). `LEVEL_CAP` jest globalny i obowiązuje każdego członka osobno (XP ponad limit przepada).
- **Poziom wroga jest z mapy, nie z gracza** (`enemy_levels` w konfiguracji mapy; `QuizRpgEnemyStats` liczy statystyki z poziomu wroga, nie z poziomu drużyny). Jak we FNaFB, na obszar wysokiego tieru
  można wejść od początku, jeśli jest dostępny — to ryzyko i szansa na szybki awans, a nie coś, co gra łagodzi skalowaniem do gracza. Dostępność map ogranicza fabuła i blokady (skille, klucze), nie poziom.

## 7. Do uzgodnienia

1. Czy „3” oznacza 3 towarzyszy (razem 4) czy 3 osoby łącznie.
2. Klasy mają nazwy (Wojownik, Łotrzyk, Mag, Kapłan — `klasy_postaci_i_bronie.md`); do ustalenia imiona i charakter postaci oraz ich powód dołączenia (pasuje do motywu wspomnień).
3. Czy zadania towarzyszy są powiązane z odnogami i blokadami zamku (sekcja 5).
4. Poziom startowy dołączającego (propozycja: najwyższy poziom w drużynie − 1–2); krzywe XP per klasa (parametry `xp_*` w danych postaci) czy wspólna krzywa.
5. Czy bohater też ma klasę (Wojownik) i czy da się zmieniać klasę (propozycja: nie).
6. Skille klasowe: Mag i Łotrzyk mają za mało skilli (sekcja 4); dane i opisy do Gemini wg briefu jak S6 — najpierw ustalić, jakie skille (lista pomysłów).
7. Grafiki: jakich postaci użyć z paczki, czy potrzebne są nowe animacje.

## Zrobione 2026-10-16 (Opus, gałąź `druzyna-balans`)

- **Postacie:** `resources/heroes/hero_lotrzyk.tres` (rogue, ATK), `hero_mag.tres` (mage, MAT i SP), `hero_kaplan.tres` (priest, MDF i MAT);
  grafika Pixel Crawler: Łotrzyk i Mag = NPC free packa (Rogue, Wizzard; `resources/heroes/frames/`, klatki dopełnione do 64×64),
  Kapłan = `royal_priest` (royal_crew). Imiona zastępcze. Skille z obecnej puli (zastępczo — klasowe do zaprojektowania, pkt 6).
  Broń klasy: sztylet / kostur / buława. `QuizRpgHeroData.sprite_offset` (stopy klatek 64×64).
- **PlayerStats:** `recruit(hero_id, at_level)` (domyślnie najwyższy poziom − 1), `HERO_PATHS`, `hero_by_id`, `has_member`,
  `recruitable_heroes`, `highest_level`; `add_xp` — każdy członek pełna kwota do własnej puli, bez przytomności 50 % (także lider),
  awanse wg krzywej postaci (sygnał `member_level_up`); `companion_quests` w zapisie; wczytanie odtwarza pola wizualne (JSON).
- **Mapa:** `scripts/player/party_followers.gd` — towarzysze za bohaterem na każdej mapie (level_manager), poza grupą `player`
  i bez warstwy kolizji (wrogowie / portale widzą tylko lidera), doganiają skokiem, odbicie sprite'a w lewo.
- **Walka:** wiersz każdego członka, wróg atakuje losowego przytomnego (obrona tylko dla broniącego), porażka po upadku całej
  drużyny, komunikaty awansów towarzyszy. **Schemat tury bez zmian: w turze działa jedna wybrana postać** (Walcz → wybór postaci).
- **Rekrutacja:** `scenes/npc/companion_npc.tscn` (@tool — widoczny w edytorze): rozmowa (`scenes/ui/dialog_box.tscn`) → zadanie
  (NONE / ANSWER_CORRECT / BRING_ITEM) → dołącza i znika. W `town.tscn`: Łotrzyk (5 poprawnych odpowiedzi), Mag (2 etery),
  Kapłan (10 poprawnych odpowiedzi). Menu deweloperskie: karta „Drużyna” (dołącz od ręki).
- Testy lokalne: `check_party_recruit`, `check_party_followers`, `check_party_combat`, `check_companion_npc`, `shot_party_combat`, `shot_party_pause`.

**Pytania do usera:** (1) czy w każdej turze ma działać każdy członek (4 pytania na turę) czy zostaje jedna wybrana postać;
(2) imiona i charakter towarzyszy; (3) skille klasowe (Mag / Łotrzyk / Kapłan mają dziś pożyczone z puli bohatera);
(4) bohater ma stare klatki Soldier (100×100, legacy Amon-Ra) — towarzysze i wrogowie są z Pixel Crawlera; podmienić bohatera?

**Odpowiedzi (2026-10-16):** (1) „zależne od AGI” — zrobione: każdy przytomny działa raz na rundę w kolejności wg AGI
(opis w `walka.md`); (4) „tak” — bohater to Knight z `royal_crew` (`resources/heroes/frames/bohater_frames.tres`,
też w `player.tscn`). Otwarte: (2) imiona / charakter, (3) skille klasowe.

