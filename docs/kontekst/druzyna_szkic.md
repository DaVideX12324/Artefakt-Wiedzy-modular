# Drużyna — towarzysze, klasy, dołączanie (szkic do oceny)

Stan: **pomysł z 2026-10-12, nic nie jest zaimplementowane** (jest jeden bohater `hero_bohater.tres`; infrastruktura per członek już działa, patrz niżej).
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

1. Dane i grafiki trzech klas (animacje idle / walka / miniatura; arkusze Pixel Crawler mają bohaterów i klasy).
2. **Rekrutacja:** sposób dodania członka do `party` (nowa funkcja `PlayerStats.recruit(hero_id, level)`), zapis / wczytanie składu (bez limitu liczby członków).
3. **Poziom i XP członków:** dziś `PlayerStats.level` jest jeden; propozycja niżej.
4. **Zadania towarzyszy** (sceny, dialog, cel zadania, nagroda), UI dziennika / znacznika.
5. Per członek: sloty tierów i budżet (`sloty_umiejetnosci_szkic.md`), pula skilli klasy, ekwipunek ograniczony typami broni.
6. Skille klasowe, których jeszcze nie ma (sekcja 4) — do napisania (dane, mogą pójść do Gemini).

## 4. Klasy (propozycja; typy broni z `weapon_type`: sword, dagger, axe, spear, mace, staff, bow)

| Klasa | Rola | Bronie | Statystyki (kierunek) | Skille z obecnej puli | Do dopisania |
|---|---|---|---|---|---|
| **Wojownik** (bohater) | uniwersalny, obrażenia fizyczne | miecz, topór | zrównoważone | Heavy Strike, Rapid Flurry, Rushdown, Flying Fright, Fearless Flight, Final Strike (miecz), Death Enrage | — (już ma pulę) |
| **Obrońca** | tank, kontrola | maczuga, włócznia + tarcza | wysokie DEF / HP, niskie ATK | Guardian Ward, Paralyzing Strike | prowokacja (status `provoke` już jest), osłona sojusznika, kontratak, ochronny okrzyk |
| **Kapłan / medyk** | leczenie i wzmocnienia | laska, buława | wysokie MAT / MDF, niskie ATK | First Aid, Hearty Meal, Revive, Motivation Jam, Speed Share, Sea Shanty, Lullaby | leczenie całej drużyny, odtrucie, oczyszczenie statusów, tarcza |
| **Łowca** | obrażenia pojedyncze / losowe, statusy | łuk, sztylet | wysokie ATK i AGI (po O2), niskie DEF | Backup Bash (chance hit — wymagany przez Strażnika), Toxic Dart, Shrapnel Toss, Smoke Ring, Double Strike, Toxic Shock | strzał krytyczny, seria strzałów, pułapka |

Wymóg z `game_design.md` (walka ze Strażnikiem, faza 1): potrzebny sojusznik stricte ofensywny albo z chance hitem — spełnia go Łowca (Backup Bash) lub Wojownik.
Klasy ułożone tak, że skille z tabeli S6 mają dom; ok. 4–6 nowych skilli na klasę trzeba dopisać, żeby klasy czuły się różne.

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
2. Nazwy klas i postaci, ich charakter / fabuła (dołączają z własnego powodu; pasuje do motywu wspomnień).
3. Czy zadania towarzyszy są powiązane z odnogami i blokadami zamku (sekcja 5).
4. Poziom startowy dołączającego (propozycja: najwyższy poziom w drużynie − 1–2); krzywe XP per klasa (parametry `xp_*` w danych postaci) czy wspólna krzywa.
5. Czy bohater też ma klasę (Wojownik) i czy da się zmieniać klasę (propozycja: nie).
6. Kto pisze skille klasowe (dane skilli i opisy mogą iść do Gemini wg briefu jak S6).
7. Grafiki: jakich postaci użyć z paczki, czy potrzebne są nowe animacje.
