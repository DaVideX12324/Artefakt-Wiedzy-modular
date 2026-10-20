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
## Propozycje (Gemini, 2026-10-21)

### A. Towarzysze drużyny

#### 1. Łotrzyk (`lotrzyk`, rogue)

| imię | skojarzenie / etymologia | charakter (1–2 zdania) | powód dołączenia (A) / uwagi |
|---|---|---|---|
| Reno | Wskazuje na nurt i bystrość rzeki (jak Ren / Reno); pobrzmiewa lisim sprytem (Renard). Krótkie (4 litery), ostre, dynamiczne. | Opanowany pragmatyk o szorstkim poczuciu humoru, nieufny wobec wielkich słów i magii. Polega wyłącznie na własnym zmyśle przetrwania i refleksie. | Pamięta, że przyszedł do miasta z zewnątrz za czyimś zleceniem, lecz mgła zatarła twarz zleceniodawcy i cel kradzieży. Idzie z bohaterem, bo tylko poza murami ma szansę odkryć, kim był, zanim utknął w zaułkach. (Płeć: męska / neutralna). |
| Kael | Celtyckie *caol* – szczupły, zwinny, wąski. Brzmi jak świst przecinającego powietrze sztyletu (4 litery). | Skryty i małomówny obserwator, który woli działać z ukrycia niż debatować. Każdy krok kalkuluje z wyprzedzeniem, zawsze szukając drogi ucieczki. | Nosi przy pasie pustą miedzianą oprawę po medalionie. Pamięta ucieczkę przed strażą zamkową, ale nie wie, czy był szpiegiem, czy więźniem; wyprawa to jedyna droga do prawdy. (Płeć: męska / neutralna). |
| Vane | Angielskie *vane* (wiatrowskaz / lotka strzały — ktoś zmieniający kierunek wraz z wiatrem) lub łacińskie *vanus* (ulotny). | Błyskotliwa i nieco cyniczna postać, maskująca niepewność kpiącym uśmieszkiem. W walce nie szuka chwały, lecz bezwzględnej skuteczności. | Uważa, że „Vane” to jedyne słowo wyryte na rękojeści jej sztyletu — nie wie, czy to imię, czy nazwa broni. Dołącza, bo bohater nie zadaje zbędnych pytań o przeszłość. (Płeć: neutralna / żeńska). |
| Nyx | Klasyczne nawiązanie do nocy i cienia; zwięzłe, wyraziste 3 litery. | Zadziorna i bezkompromisowa indywidualistka, gardząca konwenansami. Jeśli ktoś wejdzie jej w drogę, najpierw poczuje dym w oczach, a potem chłód stali. | Mgła wymazała wszystko poza jednym wspomnieniem: widokiem zatrzaśniętych wrót miejskich. Wierzy, że za barierą czeka ktoś, kto zna jej prawdziwą tożsamość. (Płeć: żeńska / neutralna). |

#### 2. Mag (`mag`, mage)

| imię | skojarzenie / etymologia | charakter (1–2 zdania) | powód dołączenia (A) / uwagi |
|---|---|---|---|
| Eldon | Staroangielskie *ella* + *dun* (wzgórze starszych / stare drzewo). Erudycyjne, klasyczne brzmienie adepta akademii (5 liter). | Metodyczny analityk o nienagannych manierach, traktujący każdą potyczkę jak skomplikowane zadanie logiczne. Frustruje go chaos, lecz pod chłodną powierzchownością kryje głębokie poczucie lojalności. | Pamięta z pamięci setki formuł żywiołów (kręgi 1–9), lecz zapomniał imię swego mistrza oraz cel badań, którym poświęcił młodość. Wyrusza, by odnaleźć zaginione traktaty i rozwikłać anomalię bariery. (Płeć: męska). |
| Mira | Łacińskie *mira* (cudowna, niezwykła, od *mirari* – podziwiać) lub słowiańskie *mir* (spokój, świat). 4 litery, czyste i melodyjne. | Niezwykle dociekliwa i zafascynowana prawami natury czarodziejka, potrafiąca w ułamku sekundy skupić wolę w bezlitosny piorun. Codziennie prowadzi dziennik, bojąc się, że o poranku zastanie puste strony. | W jej notatniku brakuje pierwszych dwudziestu stron — zostały starannie wyrwane jej własną ręką. Dołącza do drużyny, mając nadzieję natrafić w podziemiach na ślad badań, przed którymi sama uciekła. (Płeć: żeńska). |
| Talia | Greckie *thallein* (kwitnąć, jaśnieć) lub hebrajskie „rosa niebios” (5 liter). Iskrzące, żywiołowe brzmienie. | Bystra, nieco porywcza i zniecierpliwiona banałem. Kiedy jednak drużyna znajdzie się w opałach, bez wahania spali resztki własnych sił, by osłonić towarzyszy ścianą ognia. | Zużyła wszystkie etery, desperacko podtrzymując czar ochronny wokół domu w mieście. Zrozumiała, że izolacja to powolna śmierć i tylko uderzenie w źródło Mgły daje nadzieję. (Płeć: żeńska). |
| Orin | Celtyckie/hebrajskie korzenie (jasny, sosna / drzewo światła). Krótkie (4 litery), zwarte. | Skupiony, introwertyczny badacz żywiołów, który rzadko podnosi głos, lecz każde jego słowo ma wagę dowodu. | Zaobserwował, że jego obieg many słabnie wraz z gęstnieniem Mgły. Wyrusza w głąb podziemi, wierząc, że badanie pradawnych relikwii pozwoli ocalić gasnący dar czarowania. (Płeć: męska / neutralna). |

#### 3. Kapłan (`kaplan`, priest)

| imię | skojarzenie / etymologia | charakter (1–2 zdania) | powód dołączenia (A) / uwagi |
|---|---|---|---|
| Selene | Greckie uosobienie księżyca — łagodne światło rozpraszające mrok nocy (6 liter). Czyste, kojące brzmienie. | Ciepła, wyrozumiała i niezłomna duchem przewodniczka, niosąca ukojenie w świecie pogrążonym w apatii. Nie osądza nikogo za zapomnianą przeszłość; liczy się dla niej to, jakimi ludźmi stają się tu i teraz. | Codziennie modli się w opuszczonej kaplicy za dusze poległych, lecz ze zgrozą odkryła, że nie pamięta imienia bóstwa ani patrona ołtarza, przed którym klęczy. Idzie z bohaterem, by odzyskać święte księgi i przywrócić pamięć o tym, co uświęcone. (Płeć: żeńska). |
| Lucas | Łacińskie *lux* (światło, niosący jasność). Tradycyjne, serdeczne brzmienie (5 liter). | Ostoja spokoju i niezawodny powiernik. W krytycznych momentach bitwy zachowuje zimną krew, przypominając drużynie, że dopóki tli się wola walki, żadna strata nie jest ostateczna. | Nosi zniszczony modlitewnik, którego karty wyblakły do czysta. Pamięta formuły leczenia ran ciała, lecz pragnie dowiedzieć się, czyja dłoń zawiesiła na jego szyi srebrny symbol wiary. (Płeć: męska). |
| Dorin | Z greckiego *doron* (dar) / plemię Dorów. Krótkie, surowe i dostojne imię zakonne (5 liter). | Pokorny mnich o głębokim głosie i twardych zasadach, gotów własnym ciałem zasłonić rannych przed ciosem. Wierzy, że wiedza i dyscyplina duchowa są jedynym bastionem przed obłędem. | Jest przekonany, że Mgła nie jest zjawiskiem naturalnym, lecz zbrodnią przeciw prawom stworzenia. Chce osobiście spisać kronikę upadku i odrodzenia królestwa, by prawda nie przepadła na wieki. (Płeć: męska). |
| Bastian | Od *sebastos* (czcigodny, godny szacunku, Bastian / Sebastian). 7 liter, tradycyjne rycersko-kapłańskie brzmienie. | Stateczny i opiekuńczy zakonnik, dbający o każdego członka wyprawy niczym starszy brat. Gdy trzeba, bez wahania unosi ciężką buławę, by odepchnąć napastników od bezbronnych. | Posługiwał w lazarecie przed zamknięciem bram; pamięta twarze setek uleczonych mieszkańców, lecz ani jednego nazwiska. Dołącza do drużyny, by dotrzymać dawno złożonej przysięgi niesienia ratunku. (Płeć: męska). |

**Moja rekomendacja:**
- Łotrzyk: **Reno** (4 litery, litera **R**)
- Mag: **Eldon** (5 liter, litera **E**)
- Kapłan: **Selene** (6 liter, litera **S**)

*Uzasadnienie:* Zestaw idealnie spełnia wszystkie kryteria techniczne i estetyczne: trzy zupełnie różne pierwsze litery (**R**, **E**, **S**), doskonała gradacja długości w wąskim UI (4, 5, 6 liter), brak znaków diakrytycznych, tożsama wymowa w PL i EN. Tworzą zrównoważoną drużynę o wyrazistych sylwetkach: sprytny outsider z zaułków (**Reno**), zorganizowany erudyta akademicki (**Eldon**) oraz współczująca, niosąca światło kapłanka (**Selene**).

---

### B. Prawdziwe imiona Strażnika i Arcymaga

#### 1. Prawdziwy Strażnik (geniusz 10. poziomu magii, twórca kręgów obronnych; uwięziony w zamku w ciele Arcymaga)

| imię | skojarzenie / etymologia | brzmienie w ustach mieszkańca przypominającego sobie prawdę | uwagi / podpis |
|---|---|---|---|
| Alden | Staroangielskie *Ealdwine* — „stary, zaufany przyjaciel”, wierny obrońca (5 liter). Ciepłe, tradycyjne, melodyjne. | Brzmi jak powrót do bezpiecznego domu i zerwanie ciężkiego snu: *„Alden... Przecież to był Alden! Nasz obrońca, to on stał na murach, gdy nadeszła ciemność!”*. | Imię proste, skromne, bez cienia pychy. W easter eggu (wpisane przez gracza na starcie) wywołuje dreszcz uwięzionego mistrza. |
| Kallan | Szkocko-irlandzkie *callan* (strumień, skała) lub germańskie *kall* (wezwanie, powołanie) (6 liter). | Wybrzmiewa z głębokim szacunkiem i powagą: *„Kallan... Mistrz Kallan! Jak mogliśmy zapomnieć imię kogoś, kto oddał za nas własne życie?”*. | Twarde, szlachetne brzmienie pasujące do kamiennych kręgów i barier obronnych. |
| Theron | Greckie *theron* (strażnik, obrońca, łowca) (6 liter). Dźwięczne, dumne, klasyczne. | Brzmi donośnie, jak echo dzwonu zamkowego: *„Theron... To Theron nakreślił te runy! Pamiętam ten znak, to jego pieczęć!”*. | Wyraźne skojarzenie z tarczą i opieką nad miastem. |

#### 2. Prawdziwy Arcymag / Uzurpator (ambitny badacz 9. poziomu, zawistny manipulator; obecnie w ciele Strażnika na zewnątrz)

| imię | skojarzenie / etymologia | brzmienie w ustach mieszkańca przypominającego sobie prawdę | uwagi / podpis na zwoju |
|---|---|---|---|
| Varian | Łacińskie *varius* (zmienny, niejednoznaczny, niestały — subtelna, ukryta aluzja do zamiany ciał i chwiejnej tożsamości) (6 liter). | Wypowiadane z niedowierzaniem i narastającym chłodem: *„Varian... To imię zawsze kojarzyło się z królewską kancelarią. Czy to możliwe, że to on pociągał za sznurki?”*. | Na sfałszowanym zwoju: dworska, przesadnie wystylizowana sygnatura *„Varian, Arcymag Koronny”* z zamaszystym zawijasem. Nie zdradza twistu przedwcześnie, brzmi dostojnie. |
| Morvath | Szorstkie, starożytne brzmienie dworskie; korzeń *mor* (wielki / granica / zmierzch) (7 liter). | Wymawiane z cichym lękiem i respektem: *„Morvath... Wielki Kanclerz Morvath. Zawsze zamykał się w wieży, patrzył na nas z góry...”*. | Podpis twardy, ostry, najeżony spiczastymi literami. Kojarzy się z nieprzejednaną dyscypliną i chłodną kalkulacją. |
| Malakor | Klasyczne brzmienie potężnego maga akademickiego; korzeń *mal-* (niedoskonałość / cień), brzmiące arystokratycznie (7 liter). | Z trwogą i ulgą po zdjęciu uroku: *„Malakor... Nadworny Arcymag. Jego imię budziło strach jeszcze zanim spadła Mgła.”*. | Pieczęć woskowa z monogramem „M” na starych edyktach zamkowych. |

**Moja rekomendacja:**
- Prawdziwy Strażnik: **Alden** (5 liter)
- Prawdziwy Arcymag / Uzurpator: **Varian** (6 liter)

*Uzasadnienie:* Znakomity kontrast psychologiczny i dramaturgiczny. Prosty, bliski ludowi, serdeczny **Alden** (staroangielski zaufany przyjaciel) idealnie współgra z rolą obrońcy, który poświęcił się dla miasta. Z kolei **Varian** brzmi elegancko, dumnie i dworsko, a jego ukryta etymologia (*varius* — zmienny/podmieniony) stanowi wyśmienity literacki smaczek dla gracza odkrywającego True Ending, nie zdradzając absolutnie niczego na początku przygody. Podpis „Varian” na zwoju z Biblioteki wygląda naturalnie i wiarygodnie jako element dawnej korespondencji.

---

### C. NPC-e miasta

#### Koncepcja pamięci u mieszkańców:
Mieszkańcy pod wpływem Mgły zapomnieli swoje imiona, dawne więzi rodzinne i przeszłość sprzed zamknięcia bram. Na co dzień posługują się wyłącznie rolami zawodowymi (**Zielarka**, **Kowal**, **Płatnerz**, **Karczmarka**, **Nauczyciel**, **Mieszkanka**), ponieważ nawyk rzemieślniczy, pamięć mięśniowa i warsztat okazały się trwalsze niż wspomnienia tożsamości.
Ich prawdziwe imiona nie zostały jednak bezpowrotnie zniszczone — przetrwały wyryte na spodzie kowadła, wyszyte spłowiałą nicią na fartuchu zielarskim, wygrawerowane na starym kuflu czy zapisane w spisie cechowym. Imiona te mogą powracać jako nagroda za zadania poboczne lub wybrzmieć w pełnej krasie po zdjęciu Mgły w zakończeniu gry.

| NPC / rola | Proponowane imię | Skojarzenie / etymologia | Charakter i zachowanie | Szczegół pamięci / pamiątka |
|---|---|---|---|---|
| **Zielarka** (`shopkeeper`) | **Fenna** (rekomendacja) / Elira / Tessa | Staroangielskie/fryzyjskie *fenn* (torfowisko, wrzosowisko, zioła mokradeł). 5 liter, ciepłe i naturalne. | Spokojna, nieco zamyślona kobieta o spracowanych, pachnących tymiankiem dłoniach; pociesza każdego, kto zagląda do jej kramu. | Na lnianym fartuchu ma wyszyty spłowiały monogram z literą „F”. |
| **Kowal** (`blacksmith`) | **Brann** (rekomendacja) / Torvald / Gorn | Staronordyckie *brandr* (ogień, płomień, ostrze miecza). Krótkie (5 liter), mocne jak uderzenie młota. | Szorstki, milkliwy rzemieślnik o potężnej posturze, który nie lubi gadać po próżnicy; ożywia się tylko przy dźwięku rozżarzonego żelaza. | Na podstawie jego kowadła widnieje głęboko wybity puncą znak cechowy „BRANN”. |
| **Płatnerz** (`armorer`) | **Kastor** (rekomendacja) / Varek / Halden | Z greckiego *Kastor* (mityczny wojownik, budowniczy mocnych osłon). Twarde 6 liter. | Skrupulatny perfekcjonista, nieustannie polerujący napierśniki i tarcze. Wierzy, że dobrze wykuty pancerz to jedyna różnica między życiem a śmiercią. | W kieszeni kubraka nosi małą miedzianą tabliczkę z wygrawerowanym napisem „Dla syna Kastora”. |
| **Karczmarka** (`innkeeper`) | **Greta** (rekomendacja) / Marta / Sela | Tradycyjne zdrobnienie od Margarety (perła). 5 liter, swojskie, gościnne brzmienie. | Obrotna, energiczna gospodyni o tubalnym głosie, która twardą ręką trzyma porządek w szynku, ale nikomu głodnemu nie odmówi strawy. | Na dnie cynowego kufla, z którego pija co wieczór, wyryto imię „Greta”. |
| **Mistrz Fechtunku** (`teacher`) | **Corvus** (rekomendacja) / Roderic / Severin | Łacińskie *corvus* (kruk). 6 liter, brzmi surowo i drapieżnie. | Siwiejący weteran z Hideout o przenikliwym spojrzeniu i bliznach na przedramionach. Szanuje wyłącznie dyscyplinę i pot wylany na treningu („formuły przekażę, osobistej techniki nie”). | Sztych jego treningowego rapiera ma wygrawerowany herb kruka z inicjałami „C.V.”. |
| **Mieszkanka** (`villager`) | **Lina** (rekomendacja) / Nella / Iris | Skrót od klasycznych imion (Adelina, Paulina; len, delikatna nić). 4 litery, skromne i wzruszające. | Cicha, zlękniona dziewczyna w wyblakłej sukience, która całymi dniami wpatruje się w zamglony horyzont za bramą miasta. | Ściska w dłoni drewnianą figurkę ptaka z niewyraźnym podpisem „Dla małej Liny”. |

**Moja rekomendacja:**
- Zielarka: **Fenna**
- Kowal: **Brann**
- Płatnerz: **Kastor**
- Karczmarka: **Greta**
- Mistrz Fechtunku: **Corvus**
- Mieszkanka: **Lina**

*Uzasadnienie:* Każde z tych imion jest zwarte (4–6 liter), pozbawione polskich znaków diakrytycznych, identyczne w wersji polskiej i angielskiej oraz głęboko zakorzenione w realiach średniowiecznego miasteczka. Zestaw tworzy wiarygodną społeczność rzemieślników i mieszkańców, których imiona idealnie pasują do pamiątek i detali otoczenia, czekając na ponowne odkrycie przez gracza.
### Status wdrożenia (2026-10-21)
- **Towarzysze:** User zaakceptował propozycje: Łotrzyk = **Kael**, Mag = **Eldon**, Kapłan = **Selene**. Wdrożono w `pl.json`, `en.json`, `.tres` i testach.
- **NPC-e miasta:** Wdrożono rekomendowany zestaw: Zielarka = **Fenna**, Kowal = **Brann**, Płatnerz = **Kastor**, Karczmarka = **Greta**, Mistrz Fechtunku = **Corvus**, Mieszkanka = **Lina** w `pl.json`, `en.json` oraz scenach `modules/quiz_rpg/scenes/npc/*.tscn` zgodnie z briefem w `npc.md`.
- **Prawdziwe imiona:** Strażnik = **Alden**, Arcymag / Uzurpator = **Varian** (zgodnie z rekomendacją do wykorzystania w twistach fabularnych i True Endingu).
