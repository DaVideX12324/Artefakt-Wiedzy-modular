# Quiz RPG — Dokument Projektowy


## Przegląd

Top-down dungeon crawler oparty o pakiet assetów **Pixel Crawler (Anokolisa)**, łączący eksplorację, walkę i system quizów edukacyjnych. Silnik: Godot 4.x (GDScript).

**Dostępne assety z pakietu:** Desert, Forge, Sewer, Cemetery, Fairy Forest, Castle, Hideout, Library, Garden, Cave + bazowy tileset bohaterzy/wrogowie/broń.
**Brakujące:** Desert Temple, Volcano, Dense Forest, biom zimowy/górski — planowane jako zmodyfikowane warianty istniejących lub assety z sieci (styl 16×16, zgodność wizualna z Pixel Crawler).

---

## Struktura świata — kolejność stref

| # | Strefa | Rola |
|---|--------|------|
| 1 | **Tutorial Dungeon** | Nauka mechanik, liniowy |
| 2 | **Cave** | Pierwsza eksploracja, pułapki, rój nietoperzy |
| 3 | **Miasto** | Hub: sklep, zapis, NPC z questami, odblokowanie skilli |
| 4 | **Sewer** | Śluzy/przełączniki, klucz do Cemetery |
| 5 | **Cemetery** | Nieumarli, klucz od strażnika, pierwsza poszlaka fabularna |
| 6 | **Fairy Forest** | **Hub-skrzyżowanie** — 3 bramy + ukryta 4. ścieżka (lore) |
| 7 | **Desert → Desert Temple** | Otwarta mapa, boss strzegący fragmentu 1 |
| 8 | **Volcano → Forge** | Platformy nad lawą, narzędzie do starych bram, fragment 2 |
| 9 | **Dense Forest → biom zimowy** | Błądzenie w lesie, boss na śniegu, fragment 3 |
| 10 | **Library** | Zagadki + quizy, dowody na Strażnika, scroll do Garden — bez presji |
| 11 | **Garden** | Labirynt żywopłotów, elitarna straż, odblokowany scrollem z Library |
| 12 | **Castle** | **Finał** — spina motywy wszystkich stref, konfrontacja |

> **Fast travel:** aktywny od wejścia do miasta do momentu zdobycia fragmentu 3 (patrz: fabuła). Stworzony przez Strażnika — co samo w sobie jest twardą poszlaką.

---

## Fabuła: twist Strażnik vs. Arcymag

### Wersja oficjalna (cel gracza na początku)

Strażnik osłonił miasto barierą blokującą duże efekty magiczne (w tym fast travel) i poległ w walce z arcymagiem. Arcymag — mag nadworny/królewski — uruchomił tajne urządzenie magiczne (krąg/maszynę), które wg oficjalnej wersji **nadpisuje pamięć mieszkańców fałszywymi wspomnieniami**. Im dłużej działa, tym bardziej destruktywne skutki — gdy osiągnie 100%, procesu nie będzie już dało się odwrócić. Cel gracza: dostać się do zamku, pokonać arcymaga, zniszczyć urządzenie zanim dobije do pełni.

### Prawda

1. **Strażnik żyje.** Sam zbudował system fast travel i wzmocnień potworów; wysysał wiedzę mieszkańców miasta — w tym arcymaga.
2. **Arcymag** w ostatnim momencie, świadomy że traci pamięć, uruchomił urządzenie zaprojektowane specjalnie do **złamania czaru Strażnika i stopniowego przywracania pamięci**. Urządzenie potrzebuje czasu — **każdy pokonany boss to trigger postępu** (=jeden krok procesu magicznego). Przed całkowitym wymazaniem arcymag rzucił na siebie zaklęcie ochronne, żeby zachować ten jeden element — świadomość celu urządzenia.
3. **Strażnik namącił wszystkim w głowach:** urządzenie arcymaga to źródło fałszywych wspomnień, a sam mag to winowajca. Gra od początku napędza gracza do jego zniszczenia.
4. **Tuż przed salą arcymaga** widoczna jest maszyna/krąg na poziomie **~95%** — pasek postępu, odliczanie, cokolwiek czytelnego mechanicznie. To jest **właściwy Point of No Return** — w pokoju przedsionkowym. Wejście do komnaty maga = brak odwrotu.
5. **Po pokonaniu arcymaga i zniszczeniu urządzenia** gracz odkrywa prawdę. Ale jest już za późno — bez urządzenia czar Strażnika nie może zostać złamany, wszyscy ponownie tracą wiedzę.
6. **Arcymag ginie**, ale ostatkiem many **pośmiertnie chroni drużynę** — gracze zachowują pamięć i mogą stawić czoła Strażnikowi.

> **Spójność mechaniki z narracją:** liczba potrzebnych „kroków" urządzenia odpowiada dokładnie liczbie bossów w grze (zarówno main-path fragmenty, jak i middle bosse). Gracz sam, przez całą kampanię, nieświadomie napędzał urządzenie arcymaga do działania.

> **Kolejność bossów:** dowolna. Gracz może pokonywać strefy w wybranej kolejności — kolejność nie wpływa na fabułę, tylko na to kiedy gracz zobaczy kolejne kroki postępu.

> **Widoczność postępu — trigger pierwszego wskaźnika:** wskaźnik/indicator pojawia się **po raz pierwszy po pokonaniu jakiegokolwiek pierwszego bossa** (whichever comes first). Kolejne bosse zwiększają go dalej.

> **Komunikat po każdym bossie:** po pokonaniu bossa bohaterowie otrzymują informację, że „odzyskują wspomnienia" / „mgła umysłu nieco opada" — sformułowaną celowo **dwuznacznie**: nie wiadomo, czy chodzi o powrót prawdziwych wspomnień (działanie urządzenia arcymaga) czy o narastanie fałszywych (wersja Strażnika). Gracz czyta te komunikaty przez pryzmat tego, w co aktualnie wierzy.

### Sekwencja odkrywania poszlak

```
Cave/Sewer/Cemetery          → drobne niespójności, poszlaki tła
Fragment 1 (Desert Temple)   → pierwsza konkretna poszlaka techniczna
Fragment 2 (Forge)           → mocniejsza poszlaka, coś nie gra ze Strażnikiem
Fragment 3 (las/zima)        → ★ bohater zaczyna podejrzewać — Strażnik stworzył
                                fast travel, a właśnie ON je wyłącza i wzmacnia potwory
Library                      → dokumenty, dzienniki — dowody na Strażnika (bez walki)
Garden                       → elitarna straż, zbliżanie się do prawdy
Zamek (przedsionek maga)     → urządzenie na ~95%, PoNR — wejście do komnaty
Boss fight z arcymagiem      → po walce: pełne odkrycie, zniszczenie, koniec pamięci
Arcymag ginie pośmiertnie    → chroni drużynę, otwiera ścieżkę na Strażnika
```

> **Kluczowy moment po fragmencie 3:** wyłączenie fast travelu i wzmocnienie potworów jest natychmiastowe. Bohater stwierdza, że to niemożliwe, żeby ktokolwiek inny uruchomił sieć waypointów Strażnika — pierwsze otwarte podejrzenie.

### Otwarte decyzje fabularne
- [ ] Czy Strażnik jest bezpośrednim bossem finałowym, czy ucieka/znika po odkryciu prawdy?
- [ ] Ile bossy = ile kroków urządzenia? (Czy wszystkie bosse w grze, czy tylko main path?)

---

## Komunikaty po pokonaniu bossa — „odzyskiwanie wspomnień"

Każdy komunikat jest celowo **dwuznaczny** — pasuje zarówno do interpretacji „urządzenie przywraca prawdziwe wspomnienia" jak i „urządzenie wszczepia fałszywe". Gracz odczyta je przez pryzmat tego, w co aktualnie wierzy.

Placeholder imienia gracza: `{IMIĘ}` (wypełniane imieniem z ekranu tworzenia postaci).

---

### Pula — middle bosse (subtelne, impresyjne)

> *Przez chwilę {IMIĘ} miał wrażenie, że zna to miejsce. Może to echo — może coś więcej.*

> *Coś drgnęło. Obraz, który nie wiadomo skąd. Znika, zanim zdążysz go schwycić.*

> *{IMIĘ} przez sekundę wiedział, gdzie jest. Potem już nie.*

> *Cicho. Jakby ktoś zatrzymał oddech świata i zaraz wypuścił.*

> *Wspomnienie bez twarzy. Głos bez słów. I poczucie, że powinno to znaczyć więcej, niż znaczy.*

> *Mgła. Gdzieś w niej — zarys czegoś znajomego.*

> *{IMIĘ} zatrzymał się. Coś w powietrzu po walce — jak zapach miejsca, które się kiedyś znało.*

> *Na chwilę drużyna widziała to samo. Nie rozmawiała o tym.*

---

### Pula — bossy fragmentów (mocniejsze, bardziej dosadne — ale wciąż unclear)

**Fragment 1 (pierwszy pokonany boss fragmentu — jakikolwiek):**
> *Nagle — wyraźnie — {IMIĘ} przypomniał sobie twarz. Prawdziwą. Nie wiedział skąd ją zna, ale wiedział, że ją zna. I wiedział, że ktoś bardzo chciał, żeby o niej zapomniał.*

**Fragment 2:**
> *Tym razem to nie był obraz. To był głos. Powiedział coś ważnego — {IMIĘ} poczuł to w klatce piersiowej. Za chwilę już nie pamiętał słów. Ale poczucie zostało: ktoś go ostrzegał.*

**Fragment 3:**
> *{IMIĘ} pamiętał. Przez pełne pięć sekund — pamiętał wszystko. Skąd pochodzi. Kogo zostawił. Dlaczego tu jest naprawdę. Potem mgła wróciła. Ale tym razem wiedział, że to mgła — i że ktoś ją specjalnie zastawił.*
>
> *(A gdzieś w oddali — sieć waypointów, która miała ich prowadzić, zatrzęsła się. I zgasła.)*

---

### System easter eggów (à la Undertale)

Jeśli gracz wpisał jedno ze specjalnych imion, komunikaty po bossach lub NPC-e mogą reagować inaczej. Przykłady:

| Imię | Reakcja |
|------|---------|
| Imię developerów / testerów | Ukryty komentarz NPC w Hideout |
| Klasyczne imię bohatera RPG (np. „Link", „Frisk", „Cloud") | Modyfikacja jednego z komunikatów wspomnieniowych, meta-nawiązanie |
| Imię Strażnika (placeholder: TBD) | Specjalna linia dialogowa przy pierwszym spotkaniu z poszlaką dotyczącą Strażnika |
| Imię Arcymaga (placeholder: TBD) | Jeden z NPC-ów w Hideout reaguje dziwnie — „Skąd znasz to imię?" |
| Celowo puste / spacja | Komunikaty wspomnieniowe pomijają imię, NPC mówi „jak masz na imię?" |

> Lista konkretnych easter egg imion — do ustalenia osobno (i niekoniecznie w dokumentacji publicznej 😉).



## Tajne wejście na zamek (opcjonalne)

**Mechanika losowa per save:** po jednej z trzech map (Desert Temple / Forge / las+zima) znajduje się ukryte, zniszczone lub zablokowane wejście na zamek. Losowane jest *które* z trzech wejść jest aktywne w danym save.

**Dostępność:** wejście jest widoczne i dostępne **od razu** po wejściu na daną mapę — ale przejście za bramę jest niemożliwe bez odpowiedniego skilla. Można eksplorować obszar przed bramą, nie można przejść dalej.

### Segment 2D side-scroller (przy bramie)
Przy odkryciu wejścia gra przełącza się na **krótki segment 2D side-scrollerowy** — żeby gracz poczuł skalę zamku i zobaczył, jak wygląda ta konkretna brama (każdy biom ma inny styl).

### Rodzaje blokad i wymagane skille (biom-specific)

| Biom | Typ blokady | Wymagany skill |
|------|-------------|----------------|
| Desert Temple | Zasyp piasku / stare wrota | Skill zależny od postaci, tematycznie pustynny/siłowy |
| Forge | Zawalony szyb / metalowa blokada | Skill tematycznie ognisty/mechaniczny |
| Las/zima | Zamarznięte drzwi / zwalony drzewostan | Skill tematycznie lodowy/leśny |

Konkretne skille przypisane do każdego wejścia — do ustalenia przy projektowaniu postaci.

**Nagroda:** NPC-e w Hideout awansują na wyższą wersję (lepszy asortyment, nowe dialogi, dodatkowe questy).

**Jeśli gracz nie ma skilla w momencie odkrycia:** może wrócić do Hideout przez **boczną, jednostronną ścieżkę lub łódkę** (nie blokuje postępu głównego — wymaga tylko objazdu, żeby odblokować skill u NPC).

---

## System skilli

Każda postać ma **4 aktywne skille** + **1 skill combo (5.)** korzystający z puli Tech Pointów.

- **Skille 1–4** odblokowywane u NPC w Hideout (stopniowo przez grę).
- **Skill 5 (combo)** — synteza wybranych skilli, działa za Tech Pointy; gracz wybiera kombinację przy odblokowaniu.
- Tech Pointy zdobywane osobną ścieżką (quizy, sekrety, opcjonalne areny).

> Konkretna lista skilli per postać i balans Tech Pointów — do opracowania osobno.

---

## Scroll z Library → Garden

- **Jednostronny** (tylko Library → Garden), ale **wielokrotnego użytku**.
- Teleportuje bezpośrednio do ogrodów zamkowych (wejście do strefy Garden).
- Fizyczna brama z Fairy Forest do Garden jest otwarta po zebraniu 3 fragmentów — scroll daje skrót z poziomu Library bez przechodzenia całej trasy powrotnej.
- Scroll wygląda jak dowód winy arcymaga (jest sygnowany jego imieniem) — dopóki prawda nie wyjdzie na jaw.

---

## Point of No Return

Jest ich faktycznie **dwa**, o różnym charakterze:

### 1. Wejście do Castle — ostrzeżenie logistyczne
Przed bramą zamku gra wyświetla **wyraźne ostrzeżenie:**
- Po przekroczeniu progu nie będzie możliwości swobodnego powrotu do Hideout ani kupowania u NPC.
- Lista rzeczy do rozważenia: ekwipunek, skille, opcjonalne wątki, tajne wejście.

### 2. Przedsionek komnaty arcymaga — prawdziwy PoNR fabularny
W pokoju tuż przed salą arcymaga widoczne jest urządzenie/krąg na **~95% postępu** — animacja, pasek, odliczanie. Gracz wie (albo myśli, że wie), że zostało mu już bardzo mało czasu. Wejście do komnaty = cutscene aktywuje się automatycznie, brak odwrotu.

---

## System quizów

### Dwa tryby użytkownika
1. **Nauka własna** — gracz tworzy zestaw, sam gra, widzi statystyki błędów.
2. **Nauczanie** — nauczyciel tworzy zestaw, uczeń gra, wynik wraca do twórcy (start: eksport/import JSON, bez wymogu online).

### Umiejscowienie w świecie (fabularnie: „testy strażników wiedzy dawnej cywilizacji")
| Miejsce | Mechanika |
|---------|-----------|
| Bramy między strefami | Dobra odpowiedź otwiera przejście; zła → wyższy poziom trudności (nie twarda blokada) |
| Library | Tryb nauki bez presji błędu, z wyjaśnieniami |
| Skrzynie / sekrety | Quiz jako alternatywa dla walki o nagrodę |
| Areny minibossów | Dobra odpowiedź przed walką = buff dla drużyny |

Presety pasują do wczesnych stref (Cave, Sewer). W późniejszych (Forge, Garden, Castle) gracz może wybrać trudniejszy preset lub własny zestaw za dodatkową nagrodę.

---

## Format JSON pytań

Zgodny z istniejącym formatem w `resources/quizzes/`:

```json
{
  "name": "Nazwa zestawu",
  "description": "Opis (opcjonalny).",
  "questions": [
    {
      "id": "mc_001",
      "type": "multiple_choice",
      "difficulty": 1,
      "category": "kategoria",
      "question": "Treść pytania?",
      "answers": ["Odpowiedź A", "Odpowiedź B", "Odpowiedź C", "Odpowiedź D"],
      "correct_index": 2
    },
    {
      "id": "tf_001",
      "type": "true_false",
      "difficulty": 1,
      "category": "kategoria",
      "question": "Stwierdzenie do oceny.",
      "correct": true,
      "explanation": "Opcjonalne wyjaśnienie odpowiedzi."
    },
    {
      "id": "ft_001",
      "type": "fill_text",
      "difficulty": 2,
      "category": "kategoria",
      "question": "Uzupełnij zdanie: ___ jest stolicą Polski.",
      "correct_answer": "Warszawa"
    }
  ]
}
```

Typy: `multiple_choice`, `true_false`, `fill_text`, `fill_tiles`, `matching`.

---

## Otwarte zadania

**Fabularne:**
- [ ] Czy Strażnik jest bossem finałowym, czy ucieka/znika po ujawnieniu prawdy?
- [ ] Ile kroków urządzenia = ile bossów? Czy liczą się tylko main-path bosse, czy też opcjonalne?
- [ ] Konkretne poszlaki i ich rozmieszczenie (dzienniki, ślady walki) między Fairy Forest a Library.

**Mechaniczne:**
- [ ] Lista skilli per postać + balans Tech Pointów.
- [ ] Skille wymagane do otwarcia każdego tajnego wejścia (biom-specific, do ustalenia przy projektowaniu postaci).
- [ ] Szczegóły segmentu 2D side-scroller przy tajnym wejściu (długość, co widać, czy jest interakcja).
- [ ] Projekt NPC-ów w Hideout i ich upgrade po otwarciu tajnego wejścia.
- [ ] Mechanika bocznej ścieżki/łódki powrotu do Hideout gdy brak skilla.
- [ ] Wizualizacja postępu urządzenia arcymaga (UI, animacja) — jak śledzone przez całą grę?

**Assety:**
- [ ] Desert Temple (reskin Desert), Volcano (przedsionek Forge), Dense Forest, biom zimowy — zmodyfikowane warianty lub 16×16 z sieci.
