# Imiona postaci (zadanie dla Gemini)

Cel: **zaproponować imiona** postaci w grze „Cień Mgły” — przede wszystkim trzech towarzyszy drużyny, a do tego prawdziwych imion
Strażnika i Arcymaga oraz NPC-ów miasta. Najpierw same propozycje w tym pliku (sekcja „Propozycje”); user wybiera.
**Niczego nie zmieniaj w kodzie, scenach ani JSON-ach, dopóki user nie wybierze** — wdrożenie opisuje sekcja 6.

## 1. Świat w skrócie (to, co gracz wie na starcie)

- Średniowieczne królestwo fantasy, **miasto królewskie** z zamkiem (nazwa miasta jeszcze nieustalona). Gra po polsku, z wersją angielską.
- Nad miastem wisi **Mgła**: ludzie zapominają **imiona**, twarze, drogi, własne zajęcia — i jest coraz gorzej. Miasto zamyka magiczna bariera.
- Oficjalnie: zły **Arcymag** w zamku stoi za Mgłą i barierą, a opiekun miasta, **Strażnik**, stanął przeciw niemu i poległ.
- **Bohater** budzi się w podziemiach bez pamięci. **Imię bohatera wpisuje gracz** — bohatera nie nazywaj.
- Ton: melancholijny (Mgła, utrata pamięci). Walka wzorowana na FNaFB, easter eggi na Undertale — **żadnych postaci ani nazw z tych gier**.
- Więcej: [`docs/game_design.md`](../game_design.md) sekcja „Zarys fabuły — co gracz wie na początku”.

## 2. Prawda fabularna (tylko dla Ciebie — nie może przeciec do imion)

Aktualna wersja: [`fabula_krag_i_zakonczenia_szkic.md`](fabula_krag_i_zakonczenia_szkic.md) (zastępuje sekcję twistu w `game_design.md`). W skrócie:
Arcymag z zazdrości wymusił **zamianę ciał** ze Strażnikiem. „Strażnik”, który prowadzi bohatera, to uzurpator (umysł Arcymaga w ciele
Strażnika); „Arcymag” uwięziony w zamku to prawdziwy Strażnik. **Mgła to czar uzurpatora**, który wymazał imiona, twarze i głosy obu magów,
żeby nikt nie zauważył zamiany. W True Endingu Mgła opada i wspomnienia wracają.

Wniosek dla imion: **imię nie może zdradzać twistu** (np. znaczenie „złodziej”, „zdrajca”, „podmieniony”, „cień” przy Strażniku).
Ukryte, łagodne nawiązanie (etymologia, którą odkryje dopiero ktoś, kto zna zakończenie) — mile widziane, ale opisz je.

## 3. Kogo nazwać

### A. Towarzysze drużyny (najważniejsze)

Dziś mają imiona zastępcze = nazwy klas. Dołączają w mieście po krótkim zadaniu (sceny `modules/quiz_rpg/scenes/maps/levels/town.tscn`,
pola `intro_lines`). Grafika (Pixel Crawler) — sprawdź klatki, zanim zaproponujesz imię:

| hero_id | klasa | grafika | rola w walce | obecna kwestia przy werbunku |
|---|---|---|---|---|
| `lotrzyk` | Łotrzyk (`rogue`) | NPC „Rogue” z Pixel Crawlera, `resources/heroes/frames/lotrzyk_frames.tres` | szybkie ciosy sztyletem, trucizna, dym, Cios w Plecy | „Psst. Nie patrz tak — nie jestem stąd, tak jak ty.” — zadanie: poprawne odpowiedzi w quizie |
| `mag` | Mag (`mage`) | NPC „Wizzard”, `resources/heroes/frames/mag_frames.tres` | czary żywiołów z MAT: Iskra, Lodowy Odłamek, Kula Ognia, Łańcuch Błyskawic | „Moje zapasy się skończyły, a bez nich nie rzucę ani jednego zaklęcia.” — zadanie: przynieść etery |
| `kaplan` | Kapłan (`priest`) | `royal_priest` z royal crew, `resources/enemies/pixel_crawler/royal_priest.tres` | leczenie, wskrzeszanie, Święte Światło, Krąg Odnowy | „Mgła zabiera wspomnienia, ale wiedza zostaje.” — zadanie: poprawne odpowiedzi w quizie |

Dla każdego towarzysza 3–5 propozycji. Do każdej: imię, krótkie uzasadnienie (brzmienie, skojarzenie, etymologia), **1–2 zdania charakteru**
i **powód dołączenia związany z motywem pamięci** (np. pamięta tylko przydomek, szuka kogoś, czyjego imienia nie pamięta).
Płci postaci nie przesądzaj: jeśli imię ją sugeruje, zaznacz to; mile widziane imiona neutralne.

### B. Prawdziwe imiona Strażnika i Arcymaga

W grze to tytuły („Strażnik”, „Arcymag”), bo Mgła wymazała ich imiona. Imiona przydadzą się do: podpisu na zwoju (uzurpator podrobił podpis
Arcymaga), easter eggów (gracz wpisze imię Strażnika albo Arcymaga jako swoje — `game_design.md` „System easter eggów”) i finału True.
Po 3 propozycje dla każdego, z opisem, jak imię brzmi w ustach mieszkańca, który je sobie nagle przypomina.

### C. NPC-e miasta (opcjonalnie, jeśli zostanie czasu)

Dziś role zamiast imion: Zielarka (sklep), Kowal, Płatnerz, Karczmarka, Mistrz Fechtunku (nauczyciel w Hideout), Mieszkanka. Teksty NPC to
osobny brief ([`npc.md`](npc.md) „Brief dla Gemini”) — tu tylko imiona, w tym samym stylu co towarzysze. Do rozważenia i opisania:
czy mieszkańcy pod Mgłą w ogóle pamiętają swoje imiona (może przedstawiają się zawodem, a imię wraca później).

## 4. Zasady dla imion

- **To samo imię po polsku i angielsku** (jeden zapis), łatwe do wymówienia w obu językach. Bez polskich znaków diakrytycznych (ą, ę, ł…),
  bo imię idzie też do wersji EN.
- **Krótkie: najwyżej 10 znaków** (wiersze drużyny w walce i w menu pauzy są wąskie; obok imienia stoi „LV 20”).
- Pasujące do średniowiecznego fantasy, ale bez kopiowania znanych postaci z gier, książek i filmów; nie imiona prawdziwych, znanych osób.
- Różne pierwsze litery i różna długość u trzech towarzyszy (gracz ma je odróżniać na pierwszy rzut oka).
- Imię nie jest nazwą klasy ani umiejętności z gry (lista: `modules/quiz_rpg/resources/i18n/pl.json`, klucze `skill.*.name`, `class.*`).
- Bez twistu (sekcja 2).

## 5. Format odpowiedzi

Dopisz na końcu tego pliku sekcję `## Propozycje (Gemini, <data>)` z podsekcjami A / B / C, w każdej tabela:

| imię | skojarzenie / etymologia | charakter (1–2 zdania) | powód dołączenia (A) / uwagi |
|---|---|---|---|

Na końcu każdej podsekcji jedna linia: **„Moja rekomendacja: …”** z uzasadnieniem. Nie zmieniaj innych plików.

## 6. Wdrożenie (dopiero po wyborze usera)

- Imię towarzysza: klucz `hero.<hero_id>.name` w `modules/quiz_rpg/resources/i18n/pl.json` **i** `en.json` (UTF-8, końce linii LF,
  wcięcie 2 spacje, klucze alfabetycznie — przy dopisywaniu nie zmieniaj kolejności innych kluczy), pole `display_name` w
  `modules/quiz_rpg/resources/heroes/hero_<hero_id>.tres` oraz nazwa w `modules/quiz_rpg/tests/build_companions.gd`.
- Kwestie werbunku (`intro_lines` w `town.tscn`) mogą wspomnieć imię — tylko jeśli user o to poprosi.
- Kontrola: oba JSON-y się parsują (`python -c "import json;json.load(open('pl.json',encoding='utf-8'))"`, to samo dla `en.json`),
  zestawy kluczy w obu plikach są identyczne.
- Po wdrożeniu zamknąć w [`druzyna_szkic.md`](druzyna_szkic.md) otwarty punkt „(2) imiona / charakter” i wpis o tymczasowych imionach EN
  w [`zadania_wg_trudnosci.md`](zadania_wg_trudnosci.md) pkt 6.
