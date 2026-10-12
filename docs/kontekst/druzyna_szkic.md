# Drużyna — towarzysze, klasy, dołączanie (szkic do oceny)

Stan: **pomysł z 2026-10-12, nic nie jest zaimplementowane** (jest jeden bohater `hero_bohater.tres`; infrastruktura per członek już działa, patrz niżej).
Wszystkie nazwy i liczby to propozycje.

## 1. Decyzje usera

- **Role wynikają z klas.** Każda postać ma klasę (jak w JRPG); klasa wyznacza krzywe statystyk, pulę umiejętności, typy broni i styl walki.
- **Dołączanie po wykonaniu zadania od danej postaci** (lub czegoś podobnego) — nie automatycznie z fabuły ani z poziomu bohatera.
- **Wstępnie 3 towarzyszy** (razem z bohaterem drużyna 4-osobowa; do potwierdzenia, czy „3” nie obejmuje bohatera).

## 2. Co już jest (nie trzeba budować od zera)

- `PlayerStats` liczy po członku: statystyki z ekwipunkiem (`get_member_total_stat`), umiejętności (`get_member_skills`, pula z `QuizRpgHeroData.skills`, `unlock_skill`), statusy,
  HP / SP, leczenie, ekwipunek (`set_member_equipment`), typ broni i wymagania skilli.
- Dane postaci: `QuizRpgHeroData` (`hero_id`, krzywe HP / SP / ATK / DEF / MAT / MDF, domyślny ekwipunek, pula skilli, miniatura). Nowa postać = nowy plik `.tres`.
- Walka i menu pauzy mają wiersze drużyny, `player.gd` ma tryb podążania towarzysza (`is_party_follower`), TP jest wspólną pulą drużyny (100).

## 3. Czego brakuje

1. Dane i grafiki trzech klas (animacje idle / walka / miniatura; arkusze Pixel Crawler mają bohaterów i klasy).
2. **Rekrutacja:** sposób dodania członka do `party` (nowa funkcja `PlayerStats.recruit(hero_id, level)`), zapis / wczytanie składu, limit 4.
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

## 6. XP i poziomy członków (propozycja)

- **Decyzja usera (2026-10-12): jak we FNaFB — każdy członek dostaje tyle XP, ile dali przeciwnicy** (bez dzielenia przez liczbę członków); dokładne liczby to kwestia balansu. Poziomy są więc zbliżone; nowy członek startuje z poziomu bohatera − 1–2.
- Do przetestowania przy balansie: czy martwy w chwili końca walki członek też dostaje XP, czy członek spoza walki / zapasowy dostaje całość czy ułamek, oraz czy dogonienie bohatera przez nowego członka nie jest za szybkie (dwa poziomy różnicy to ok. 1–2 walki).
- Każdy ma własny poziom w danych członka (`member["level"]` już istnieje); `PlayerStats.level` przestaje być pojedynczą prawdą — pozostaje poziomem lidera / `LEVEL_CAP`.
- Poziomy wrogów i XP mapy liczą się dla lidera; budżet XP (15 map → lv 100) nie zmienia się, bo członkowie dzielą te same XP.

## 7. Do uzgodnienia

1. Czy „3” oznacza 3 towarzyszy (razem 4) czy 3 osoby łącznie.
2. Nazwy klas i postaci, ich charakter / fabuła (dołączają z własnego powodu; pasuje do motywu wspomnień).
3. Czy zadania towarzyszy są powiązane z odnogami i blokadami zamku (sekcja 5).
4. Poziom startowy dołączającego (propozycja: bohater − 1–2); XP martwych i zapasowych członków (sekcja 6).
5. Czy bohater też ma klasę (Wojownik) i czy da się zmieniać klasę (propozycja: nie).
6. Kto pisze skille klasowe (dane skilli i opisy mogą iść do Gemini wg briefu jak S6).
7. Grafiki: jakich postaci użyć z paczki, czy potrzebne są nowe animacje.
