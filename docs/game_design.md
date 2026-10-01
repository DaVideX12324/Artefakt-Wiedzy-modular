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
| 4 | **Sewer** | Śluzy/przełączniki, klucz do Cemetery; wyrwa w barierze miasta — jedyne wyjście za mury |
| 5 | **Cemetery** | Nieumarli, klucz od strażnika, pierwsza poszlaka fabularna |
| 6 | **Fairy Forest** | **Hub-skrzyżowanie** — 3 bramy + ukryta 4. ścieżka (lore) |
| 7 | **Desert → Desert Temple** | Otwarta mapa, boss strzegący fragmentu 1 |
| 8 | **Volcano → Forge** | Platformy nad lawą, narzędzie do starych bram, fragment 2 |
| 9 | **Dense Forest → biom zimowy** | Błądzenie w lesie, boss na śniegu, fragment 3 |
| 10 | **Library** | Zagadki + quizy, dowody na Strażnika, scroll do Garden — bez presji |
| 11 | **Garden** | Labirynt żywopłotów, elitarna straż, odblokowany scrollem z Library |
| 12 | **Castle** | **Finał** — spina motywy wszystkich stref, konfrontacja |

> **Fast travel:** aktywny od wejścia do miasta. Po fragmencie 3 **nie jest wyłączany** — albo dalej działa, albo kolejne waypointy **niszczą potwory** (wariant do wyboru, patrz otwarte decyzje). Sieć wyłącza dopiero Strażnik, **po pokonaniu arcymaga w prawdziwym zakończeniu** (patrz „Zakończenia”). Stworzony przez Strażnika — co samo w sobie jest twardą poszlaką. Działa przez barierę dzięki zmodyfikowanej formule / kręgom, które Strażnik przekazał „na sam koniec”.

---

## Fabuła: twist Strażnik vs. Arcymag

### Wersja oficjalna (cel gracza na początku)

Arcymag — mag nadworny/królewski — uruchomił tajne urządzenie magiczne (krąg/maszynę), które wg oficjalnej wersji (czyli wersji Strażnika) **nadpisuje pamięć mieszkańców fałszywą rzeczywistością — żeby nikt nie mógł arcymaga powstrzymać**. Im dłużej działa, tym bardziej destruktywne skutki — gdy osiągnie 100%, procesu nie będzie już dało się odwrócić. Żeby nikt mu nie przeszkodził, **arcymag zamknął miasto za magiczną barierą**. Strażnik stanął przeciw niemu i poległ — ale zanim został pokonany, **zrobił w barierze wyrwę wewnątrz ścieków**, przez którą da się wydostać za miasto (stąd droga Sewer → Cemetery). Cel gracza: wydostać się ściekami, przebić się przez bossów strzegących fragmentów klucza, dostać się do zamku, pokonać arcymaga, zniszczyć urządzenie zanim dobije do pełni.

**Dlaczego bohater pokonuje bossów (oficjalnie):** bossowie to potwory **wzmocnione przez arcymaga**, a każdy z nich to boss etapu — nie da się go ominąć. Bohater nie walczy z nimi po to, żeby cokolwiek „przywracać”. Powody są dwa:
- **Trzej bossowie z odnóg** (Desert Temple, Forge, las/zima) strzegą po jednym fragmencie klucza. Fragmenty otwierają ukryty poziom Library, a stamtąd scroll do Garden i dalej do zamku — **bez nich nie dojdzie do arcymaga**.
- **Pozostali bossowie etapów** nie strzegą klucza. Strażnik wskazuje ich jako najsilniejszych sług arcymaga, których trzeba osłabić przed zamkiem (nagrodą są jego wzmocnienia i fast travel), a mieszkańcy proszą o pomoc, bo bossowie terroryzują okolicę. Bohater po prostu pomaga.

Każdy pokonany boss to oficjalnie jeden sługus maga mniej. Wg Strażnika nie ma innej drogi.

**Wspomnienia po bossie (oficjalnie) to skutek uboczny, a nie cel:** bohater nie ma powodu ich pragnąć — Strażnik przedstawia je jako **fałszywe wspomnienia, „echa” urządzenia arcymaga**, które przeciekają do głów, gdy maszyna wchłania uwolnioną z bossa siłę. Ostrzega, żeby im nie ufać, i każe iść dalej do zamku, żeby maszynę zniszczyć. Bohater więc nie „odzyskuje pamięci” z własnej woli, tylko znosi jej skutki uboczne w drodze do celu.

**Zamierzona ironia:** wg wersji oficjalnej gracz idzie zniszczyć maszynę, a robiąc to pokonuje kolejnych bossów — czyli **tylko pomaga arcymagowi**, czyli temu „złemu” (patrz „Prawda”: każdy boss to krok maszyny). Bohater nie wie, że jego postęp napędza urządzenie; Strażnik jest jedynym, który to wie.

### Prawda

1. **Strażnik żyje.** Sam zbudował system fast travel i wzmocnień potworów; wysysał wiedzę mieszkańców miasta — w tym arcymaga.
2. **Arcymag** (jego największa wiedza — czar 9. poziomu do manipulacji wspomnieniami — jest chroniona przez maszynę, patrz „Zakończenia”) w ostatnim momencie, świadomy że traci pamięć, uruchomił urządzenie zaprojektowane specjalnie do **przełamania bariery i czarnej magii Strażnika** (jego czar wysysający wiedzę i dający mu z niej moc to w praktyce czarna magia). Skutkiem jej łamania jest stopniowy powrót pamięci — nie żadne nadpisywanie. Urządzenie potrzebuje czasu — **każdy pokonany boss to trigger postępu** (=jeden krok procesu magicznego). Przed całkowitym wymazaniem arcymag rzucił na siebie zaklęcie ochronne, żeby zachować ten jeden element — świadomość celu urządzenia. To samo zaklęcie osłoniło wiedzę o maszynach i o zwoju do małej maszyny — dlatego Strażnik, choć wysysał wiedzę arcymaga, nie rozpoznał zwoju.
3. **Strażnik namącił wszystkim w głowach:** urządzenie arcymaga to źródło fałszywych wspomnień, a sam mag to winowajca. Gra od początku napędza gracza do jego zniszczenia.
4. **Tuż przed salą arcymaga** widoczna jest maszyna/krąg na poziomie **~95%** — pasek postępu, odliczanie, cokolwiek czytelnego mechanicznie. To jest **właściwy Point of No Return** — w pokoju przedsionkowym. Wejście do komnaty maga = brak odwrotu.
5. **Po pokonaniu arcymaga i zniszczeniu urządzenia** nic już nie kontruje czaru Strażnika: **wszyscy NPC zapominają o wszystkim**. Czy gracz pozna prawdę, zależy od zakończenia (patrz „Zakończenia”).
6. **Prawdziwe zakończenie:** mała maszyna przywraca arcymagowi pamięć — wskazuje Strażnika, ginie, ale ostatkiem many **osłania przed czarem tylko drużynę bohatera** — gracze zachowują pamięć i mogą stawić czoła Strażnikowi. Reszta świata zostaje bez wspomnień. **Złe zakończenie:** arcymag pamięta tylko cel urządzenia (zaklęcie ochronne z pkt 2), nie umie wyjaśnić, dlaczego — umiera, a prawda nie wychodzi na jaw.

#### Bariera wokół miasta i przejście ściekami (prawda)

- **Barierę postawił Strażnik, nie arcymag.** Testował na tym mieście swoje zaklęcie pochłaniania wiedzy i zamknął je z jednego z tych powodów albo z obu naraz (nie wykluczają się — patrz otwarte decyzje):
  - **A)** nie chciał, żeby to wyszło poza miasto — a przynajmniej nie za szybko;
  - **B)** bariera spowalnia maszynę arcymaga, która ma przełamać barierę i jego czarną magię — żeby nie zrobiła tego za szybko.
- **Fast travel przez barierę:** oficjalnie Strażnik „na sam koniec”, przed swoim „upadkiem”, przekazał zmodyfikowaną formułę / kręgi portali, które działają mimo bariery. Naprawdę działają, bo to jego bariera i jego sieć — sam wie, jak ją przepuścić (kolejna poszlaka dla uważnego gracza).
- **Wyrwę w ściekach Strażnik zostawił celowo** — żeby bohater mógł wyjść z miasta i ostatecznie wyłączyć maszynę arcymaga. Jego „heroiczne” przebicie bariery przed „śmiercią” to część tej samej manipulacji.

#### Bossy i wspomnienia (prawda)

- Strażnik najpierw **testował wysysanie wiedzy i zyskiwanie z niej mocy na potworach**: przekazywał im pochłoniętą wiedzę i moc — i to właśnie przez to **stały się bossami**.
- Pokonanie bossa uwalnia wiedzę, którą w sobie nosił. **Maszyna arcymaga wyłapuje te wspomnienia i oddaje je ludziom** — dlatego bohaterowie (i mieszkańcy) odzyskują część wspomnień, a maszyna robi kolejny krok.
- **Strażnik od dawna chciał odebrać bossom wiedzę i moc** (zebrać owoce swojego testu), **ale maszyna arcymaga go blokowała.**
- **Po zniszczeniu maszyny wiedza i moc wracają do bossów** — a bez maszyny nic już nie przeszkadza Strażnikowi, żeby im je odebrać i przejąć całość. Jednocześnie nie ma kontry na jego czar, więc NPC tracą pamięć (patrz pkt 5–6 wyżej).
- Dlatego Strażnikowi zależy na zniszczeniu maszyny — bohater, niszcząc ją, wykonuje za niego cały plan.

> **Spójność mechaniki z narracją:** liczba potrzebnych „kroków" urządzenia odpowiada dokładnie liczbie bossów w grze (zarówno main-path fragmenty, jak i middle bosse). Gracz sam, przez całą kampanię, nieświadomie napędzał urządzenie arcymaga do działania.

> **Kolejność bossów:** dowolna. Gracz może pokonywać strefy w wybranej kolejności — kolejność nie wpływa na fabułę, tylko na to kiedy gracz zobaczy kolejne kroki postępu.

> **Widoczność postępu — trigger pierwszego wskaźnika:** wskaźnik/indicator pojawia się **po raz pierwszy po pokonaniu jakiegokolwiek pierwszego bossa** (whichever comes first). Kolejne bosse zwiększają go dalej.

> **Komunikat po każdym bossie:** po pokonaniu bossa bohaterowie otrzymują informację, że „odzyskują wspomnienia" / „mgła umysłu nieco opada" — sformułowaną celowo **dwuznacznie**: nie wiadomo, czy chodzi o powrót prawdziwych wspomnień (prawda) czy o narastanie fałszywych, „echa" maszyny (wersja oficjalna Strażnika). Gracz czyta te komunikaty przez pryzmat tego, w co aktualnie wierzy.

> **Wskaźnik postępu a wersja oficjalna:** oficjalnie bohater walczy z bossami dla fragmentów klucza (trzej z odnóg) oraz z prośby Strażnika i mieszkańców (pozostali), a nie dla wskaźnika — wskaźnik maszyny to dla niego tylko ostrzeżenie „ile czasu zostało do zamku”. Dopiero uważny gracz zauważy, że rośnie dokładnie po bossach.

### Sekwencja odkrywania poszlak

```
Cave/Sewer/Cemetery          → drobne niespójności, poszlaki tła
Fragment 1 (Desert Temple)   → pierwsza konkretna poszlaka techniczna
Fragment 2 (Forge)           → mocniejsza poszlaka, coś nie gra ze Strażnikiem
Fragment 3 (las/zima)        → ★ najmocniejszy powrót wspomnień; fast travel działa dalej
                                albo potwory niszczą waypointy (bez wyłączania sieci)
Library                      → dokumenty, dzienniki — dowody na Strażnika (bez walki);
                                zwój arcymaga: teleport do Garden teraz albo później
                                (ukryta moc zwoju → mała maszyna = warunek true endingu)
Garden                       → elitarna straż, zbliżanie się do prawdy
Zamek (przedsionek maga)     → urządzenie na ~95%, PoNR — wejście do komnaty
Boss fight z arcymagiem      → zniszczenie maszyny, koniec pamięci NPC
  bez małej maszyny          → BAD ENDING: koniec, prawda nieodkryta
  z małą maszyną             → arcymag odzyskuje pamięć, wskazuje Strażnika,
                                ginie chroniąc drużynę → bossfight ze Strażnikiem → TRUE ENDING
```

> **Po ostatnim fragmencie** (fragmenty to klucz do ukrytego poziomu Library): powrót do miasta **bez fast travelu**. Maszyna wciąż działa, więc pokonani bossowie nie wracają.

> **Fast travel a fragment 3:** sieć **nie jest wyłączana** po fragmencie 3 (wcześniej: wyłączenie sieci = pierwsze otwarte podejrzenie wobec Strażnika — zmienione). Albo działa dalej, albo waypointy niszczą potwory. **Wyłączenie sieci** następuje dopiero po pokonaniu arcymaga w true endingu — Strażnik już się nie ukrywa, więc odcina drużynie swoją sieć.

### Zakończenia

**Najwyższa wiedza arcymaga:** główna maszyna chroniła też **największą wiedzę arcymaga — magię 9. poziomu** (ogólnie, nie jeden czar). Wśród niej jest czar **manipulacji wspomnieniami**, tak subtelny, że ofiara nawet nie zdaje sobie sprawy, że coś się zmieniło (w stylu Kotoamatsukami — genjutsu z Mangekyō Sharingana Shisuiego Uchihy z „Naruto”). Ironia: Strażnik oskarżał maszynę o nadpisywanie wspomnień fałszywą rzeczywistością — a to on chce przejąć czar, który to robi.

- **Złe zakończenie (bad ending):** gra kończy się na pokonaniu arcymaga i zniszczeniu maszyny — gracz **nie dowiaduje się**, że to sprawka Strażnika. Bez maszyny Strażnik **przejmuje wiedzę arcymaga** (magię 9. poziomu, w tym czar manipulacji wspomnieniami) i **nadpisuje wspomnienia** wszystkim, także drużynie. Koniec. **Końcowa cutscenka pokazuje zmanipulowane zakończenie** — „szczęśliwy” finał, jaki Strażnik wpisał ludziom (i graczowi) do głów.
- **Prawdziwe zakończenie (true ending):** przed walką z arcymagiem gracz odkrył ukrytą moc zwoju i uruchomił **mniejszą, starszą wersję maszyny**. Dzięki niej po zniszczeniu głównej maszyny **wiedza (magia 9. poziomu) wraca do arcymaga**, a nie do Strażnika, i arcymag **odzyskuje wspomnienia** — wskazuje Strażnika, osłania drużynę przed czarem, **przekazuje drużynie dużo silniejsze umiejętności** (z magii 9. poziomu — na walkę ze Strażnikiem) i ginie. Strażnik nie dostaje czaru, przestaje się ukrywać i **wyłącza fast travel** (to jego sieć); dalej bossfight ze Strażnikiem i true ending.

**Zwój arcymaga (rozwiązanie dziury fabularnej „co zwój arcymaga robi w bibliotece”):**
- Zwój **stworzył arcymag** — jako klucz do sekretnego pomieszczenia z mniejszą / starszą wersją maszyny, która przywróciłaby mu wspomnienia (zabezpieczenie na wypadek ich utraty).
- **Strażnik znalazł zwój i dopisał na nim teleport do ogrodów zamkowych.** Był słabszy / mniej doświadczony / miał mniejszą wiedzę niż arcymag, więc nie zauważył, że zwój ma ukrytą moc — wziął go np. za zwykły list. Pierwotna moc zwoju **nigdy nie przepadła**, była tylko ukryta.
- Dla Strażnika to podwójny zysk: teleport prowadzi bohatera prosto na arcymaga, a podpis arcymaga robi ze zwoju fałszywy dowód jego winy.
- Po otrzymaniu zwoju gracz **wybiera: teleportować się od razu albo nie**. Kto zostaje, może odkryć ukrytą moc i dotrzeć do małej maszyny — stoi w odludnym miejscu w mieście albo w piwnicy biblioteki (do ustalenia). Zwój dalej teleportuje (patrz „Scroll z Library → Garden”).

### Bossfight ze Strażnikiem (pomysł, inspiracja: FNaFB)

- **Faza 1 — bohater sam.** Na start walki Strażnik **zabiera wspomnienia wszystkim towarzyszom** bohatera — znikają z walki. Bohater zostaje solo i **wygrać się tego nie da**.
- Strażnik w fazie 1 **nie używa potężnych skilli** — tylko zwykły atak i statusy (patrz todo „Statusy pozytywne i negatywne”).
- Kluczem jest **przetrwanie**: gracz cały czas używa **obrony (guard)**, żeby nabić TP, i co jakiś czas **przedmiotów leczących**. Sojusznicy wracają **wyłącznie przez wzmocnienie tarczy za TP** (niżej) — liczba tur sama w sobie nie ma znaczenia. Kto ma dużo przedmiotów leczących, też przetrwa, ale nieefektywnie.
- **Atak bohatera zadaje obrażenia**, ale **bez wszystkich sojuszników pokonanie Strażnika jest niemożliwe**.
- **Gra nic nie podpowiada** — gracz sam musi wpaść, że chodzi o przetrwanie.
- **Brak gwarantowanego leczenia:** kto nie przygotował się na finał (przedmioty), ma problem — skill issue. Po game over: **spróbuj ponownie** albo **wczytaj ostatni zapis** — ten jest zawsze **tuż przed wejściem na arenę z arcymagiem**. Po wczytaniu można się wycofać, **dofarmić kasę i lepiej zaopatrzyć** (przedmioty leczące) przed ponownym podejściem.
- **Umiejętności 9. poziomu działają** w fazie 1, ale bohater solo **nie ma** ofensywnej („gigantyczne obrażenia”) ani **uberheala**.
- **Czemu towarzysze tracą wspomnienia mimo osłony arcymaga:** czarna magia rzucona **z bliska jest dużo skuteczniejsza** — osłona wytrzymała czar na całe miasto, ale nie skupiony atak Strażnika w walce.
- **Czemu bohater ich nie traci:** ma przy sobie **zwój arcymaga z biblioteki** (z ukrytą mocą — ten sam, który prowadził do małej maszyny; w true endingu bohater zawsze go ma).
- **Wzmocnienie tarczy (umiejętność fazy 1):** obrona (guard) **nabija TP** (TP liczone jak bez obrony — patrz „Tech Pointy w walce”); na czas fazy 1 bohater może wydać **100 TP** (cała pula), żeby **wzmocnić tarczę chroniącą sojuszników przed czarem** — to **przywraca kolejnego sojusznika** z listy drużyny. Jedyny sposób na powrót drużyny.
- Z pełną drużyną gracz **pokonuje Strażnika po raz pierwszy**, po czym zaczyna się **faza 2**.

### Otwarte decyzje fabularne
- [ ] Prawdziwy powód bariery: A) ukrycie testu zaklęcia przed światem (żeby się nie wydało / nie za szybko), B) spowolnienie maszyny arcymaga, czy oba naraz? Oba warianty pasują do fabuły i się nie wykluczają.
- [x] Mechanika przepływu wiedzy — rozwiązane: maszyna wyłapuje wiedzę uwolnioną z bossów i oddaje ją ludziom; po jej zniszczeniu nie ma kontry na czar, arcymag osłania tylko drużynę, wszyscy NPC zapominają.
- [x] Bariera a fast travel — rozwiązane: Strażnik „na sam koniec” dał zmodyfikowaną formułę / kręgi fast travelu działające przez barierę (patrz „Bariera wokół miasta”).
- [ ] Bossy po zniszczeniu maszyny: po ostatnim fragmencie (klucz do ukrytego poziomu Library) jest powrót do miasta bez fast travelu — maszyna jeszcze działa, więc bossowie wtedy **nie wracają**. Po arcymagu i zniszczeniu maszyny: osobny bossfight ze Strażnikiem gdzie indziej — czy i jak wracają wtedy bossowie (odrodzeni, jako część walki ze Strażnikiem?) i gdzie jest ta walka — do ogarnięcia później.
- [x] Czy Strażnikowi zależy na pokonywaniu bossów — tak: to on dał narrację, że wspomnienia są fałszywe, a celem jest zniszczenie maszyny; bohater idący przez bossy do zamku realizuje jego plan (to, że każdy boss przyspiesza maszynę, jest ceną, którą Strażnik akceptuje).
- [x] Strażnik jest bossem finałowym — osobny bossfight po arcymagu i zniszczeniu maszyny, w innym miejscu (lokalizacja do ustalenia).
- [x] Ile bossy = ile kroków urządzenia? — wszyscy bossowie etapów są obowiązkowi (nie da się ich ominąć), więc każdy z nich to jeden krok maszyny (main path i middle bossy).
- [x] Dwa zakończenia (bad / true) i zwój arcymaga z ukrytą mocą — patrz „Zakończenia”.
- [ ] Gdzie dokładnie stoi mała maszyna: odludne miejsce w mieście czy piwnica biblioteki? I jak gracz odkrywa ukrytą moc zwoju (poszlaka, zagadka / quiz w bibliotece, NPC)?
- [ ] Jak mała maszyna działa na arcymaga **po** walce, skoro stoi daleko od zamku (uruchomiona wcześniej przez gracza i np. ładuje przedmiot / zaklęcie, którego drużyna używa po walce?).
- [x] Strażnik „słabszy / mniej wiedzy” a to, że wysysał wiedzę arcymaga (pkt 1 „Prawdy”): zaklęcie ochronne arcymaga (pkt 2) osłoniło właśnie wiedzę o maszynach i zwoju, więc Strażnik jej nie przejął i nie rozpoznał zwoju.
- [x] Złe zakończenie: po prostu koniec — Strażnik przejmuje wiedzę arcymaga i nadpisuje wspomnienia (także drużynie); cutscenka pokazuje zmanipulowane zakończenie.
- [x] Co z magią 9. poziomu w true endingu — arcymag przed śmiercią daje drużynie dużo silniejsze umiejętności.
- [x] Jakie umiejętności z magii 9. poziomu — arcymag używa ich w swojej walce, w true endingu gracz wybiera jedną lub więcej (patrz „System skilli” → „Umiejętności 9. poziomu”).
- [ ] Szczegóły true endingu po walce ze Strażnikiem.
- [x] Bossfight ze Strażnikiem, faza 1: towarzysze tracą wspomnienia, bo czarna magia z bliska jest skuteczniejsza niż czar na całe miasto; wracają przez wzmocnienie tarczy za TP.
- [x] Faza 1: bohater nie traci wspomnień, bo ma przy sobie zwój arcymaga z biblioteki.
- [x] Faza 1: wzmocnienie tarczy kosztuje 100 TP.
- [x] Faza 1 — reguły: sojusznicy wracają tylko za TP (tury bez znaczenia), gra nic nie podpowiada, bez gwarantowanego leczenia (game over → ponów / zapis przed areną arcymaga), umiejętności 9. poziomu działają bez ofensywnej i uberheala.
- [x] Faza 1: atak bohatera zadaje obrażenia, ale bez wszystkich sojuszników nie da się wygrać.
- [ ] Faza 1 — mechanika „niemożliwe bez drużyny” (np. HP Strażnika nie spada poniżej progu, dopóki ktoś z drużyny nie wrócił?).
- [ ] Faza 2 — przebieg i mechanika.
- [ ] Fast travel po fragmencie 3: **A)** działa dalej czy **B)** potwory niszczą waypointy? Uwaga: „powrót do miasta bez fast travelu” po ostatnim fragmencie (wyżej) pasuje do B; przy A trzeba go zmienić.
- [ ] Skąd teraz pierwsze otwarte podejrzenie wobec Strażnika (dotąd: wyłączenie jego sieci po fragmencie 3)?

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
> *(Dopisek o waypointach zależny od wariantu fast travelu — sieć już nie gaśnie po fragmencie 3. Wariant „potwory niszczą waypointy”: „A gdzieś w oddali coś uderzyło w kamień waypointu. Potem drugi raz.”; wariant „działa dalej”: bez dopisku.)*

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

**Mechanika losowa per save:** losowana jest jedna z trzech odnóg (Desert Temple / Forge / las+zima), a w niej **losowo jeden z jej ostatnich poziomów** — tam znajduje się ukryte, zniszczone lub zablokowane wejście na sekcję side-scroller, która prowadzi **między tą odnogą a murami zamku**.

**Dostępność:** wejście jest widoczne i dostępne **od razu** po wejściu na daną mapę — ale przejście za bramę jest niemożliwe bez odpowiedniego skilla. Można eksplorować obszar przed bramą, nie można przejść dalej.

### Segment 2D side-scroller (odnoga → brama w murach zamku)
Po przejściu przez wejście gra przełącza się na **krótki segment 2D side-scrollerowy** — przejście od odnogi pod mury zamku, do bramy (brama jest częścią murów), żeby gracz poczuł skalę zamku i zobaczył, jak wygląda ta konkretna brama (każdy biom ma inny styl).

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
- Tech Pointy zdobywane osobną ścieżką (quizy, sekrety, opcjonalne areny). *(Do uzgodnienia z „Tech Pointy w walce” niżej — czy to osobna waluta do odblokowań, czy ta sama pula TP.)*

### Tech Pointy w walce (zasady w całej grze)

- **Otrzymywanie obrażeń** daje najwięcej TP — **proporcjonalnie do utraconego % HP** (np. utrata 50% HP → 40 TP).
- **Atakowanie** też daje TP, ale **dużo mniej**.
- **Obrona (guard)** zmniejsza otrzymane obrażenia, ale **TP rośnie tak, jakby obrony nie było** (liczone z obrażeń przed redukcją) — dlatego obrona jest dobrym sposobem na nabijanie TP.
- Dokładne proporcje — do ustalenia balansem.
- Stan kodu (2026-10-01): TP rośnie tylko z otrzymanych obrażeń i o tyle punktów, ile wynoszą obrażenia, a przy obronie z obrażeń już zmniejszonych (`_gain_party_tp` w `quiz_combat_controller.gd`); atak TP nie daje. Do przerobienia pod zasady wyżej.

> Konkretna lista skilli per postać i balans Tech Pointów — do opracowania osobno.

### Umiejętności 9. poziomu (od arcymaga, true ending)

- **Bossfight z arcymagiem:** arcymag używa **wyłącznie swoich unikalnych umiejętności — czarów 9. poziomu**. Gracz poznaje je w walce, zanim może je dostać.
- **True ending:** po pokonaniu arcymaga gracz **wybiera jedną lub więcej** z tych umiejętności. **Więcej** do wyboru, jeśli przyszedł na bossfight z **ukrytymi przedmiotami / umiejętnościami** (znalezionymi wcześniej w grze).
- Kosztują **Tech Pointy** i są **bardzo potężne**.
- Klasy umiejętności (wstępnie 4):
  1. **Uberheal** — leczy całą drużynę do pełna i usuwa negatywne statusy.
  2. **Manipulacja wspomnieniami** (Kotoamatsukami) — **blokuje przeciwnikowi ostatnio użytą umiejętność** na kilka tur.
  3. **Ofensywna** — stricte obrażenia, gigantyczne.
  4. **Klątwa** — nakłada na przeciwnika negatywne statusy.
- Wymaga systemu statusów (patrz „Otwarte zadania” → „Statusy pozytywne i negatywne”).

---

## Scroll z Library → Garden

- **Jednostronny** (tylko Library → Garden), ale **wielokrotnego użytku**.
- Teleportuje bezpośrednio do ogrodów zamkowych (wejście do strefy Garden).
- Fizyczne przejście przez mury zamkowe **otwiera się od wewnątrz** — dopiero gdy gracz jest już w zamku (wszedł scrollem albo tajnym wejściem). Potem służy jako skrót z zewnątrz.
- Scroll wygląda jak dowód winy arcymaga (jest sygnowany jego imieniem) — dopóki prawda nie wyjdzie na jaw.
- **Pochodzenie:** zwój zrobił arcymag jako klucz do sekretnego pomieszczenia z małą maszyną; teleport do ogrodów dopisał Strażnik, nie zauważywszy ukrytej mocy (patrz „Zakończenia”). Po otrzymaniu zwoju gracz wybiera, czy teleportować się od razu.

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
- [x] Strażnik jest bossem finałowym — osobny bossfight po arcymagu, miejsce do ustalenia (patrz „Otwarte decyzje fabularne”).
- [x] Ile kroków urządzenia = ile bossów? — liczą się wszyscy bossowie etapów (są obowiązkowi, nie ma opcjonalnych).
- [ ] Konkretne poszlaki i ich rozmieszczenie (dzienniki, ślady walki) między Fairy Forest a Library.

**Mechaniczne:**
- [ ] Lista skilli per postać + balans Tech Pointów (proporcje TP z obrażeń i ataku — patrz „Tech Pointy w walce”).
- [ ] Skille wymagane do otwarcia każdego tajnego wejścia (biom-specific, do ustalenia przy projektowaniu postaci).
- [ ] Szczegóły segmentu 2D side-scroller przy tajnym wejściu (długość, co widać, czy jest interakcja).
- [ ] Projekt NPC-ów w Hideout i ich upgrade po otwarciu tajnego wejścia.
- [ ] Mechanika bocznej ścieżki/łódki powrotu do Hideout gdy brak skilla.
- [ ] Wizualizacja postępu urządzenia arcymaga (UI, animacja) — jak śledzone przez całą grę?
- [ ] **Więcej bohaterów w drużynie** — dodatkowe postacie (skład, kiedy dołączają, role w walce, własne skille), spójne z fabułą (arcymag osłania całą drużynę) i z UI walki.
- [ ] **Statusy pozytywne i negatywne** — dziś walka ich nie ma (jest tylko obrona na turę: akcja `DEFEND`, `defending` w `quiz_combat_controller.gd`). Do zaprojektowania: lista statusów (np. trucizna, ogłuszenie, osłabienie / wzmocnienie ataku i obrony, regeneracja, przyspieszenie / spowolnienie — por. prędkość niżej), czas trwania w turach, kumulowanie, odporności wrogów i bossów, ikonki w UI walki, skąd się biorą (skille, przedmioty, wrogowie) i co je zdejmuje (uberheal, przedmioty, koniec walki). Potrzebne m.in. dla umiejętności 9. poziomu.
- [ ] **Umiejętności 9. poziomu** (patrz „System skilli”): ile do wyboru bazowo, ile więcej za ukryte przedmioty / umiejętności i jakie to przedmioty, koszty TP (pula drużyny `PARTY_TP_MAX` = 100), czas blokady z manipulacji wspomnieniami, balans walki z arcymagiem (używa tylko tych czarów) i ze Strażnikiem.
- [ ] **Prędkość postaci w walce** — stat prędkości (bohaterowie i wrogowie) wyznacza kolejność ruchów w turze; **na prędkość wpływa też kolejność w drużynie** (np. pozycja w szyku daje bonus / karę — zasada do ustalenia). Dziś walka to naprzemiennie tura gracza i tura wrogów (`quiz_combat_controller.gd`: `_start_player_turn` / `_enemy_turn`), bez kolejki inicjatywy. Do ustalenia: czy pasek kolejki (jak w FNaFB / JRPG z timeline), wpływ ekwipunku / skilli / statusów na prędkość, remisy.

**Referencje (do dostarczenia przez autora):**
- [ ] Przykłady z innych JRPG / gier RPG Maker / serii FNaFB (tą autor zna najlepiej) — jako kontekst, jak ma wyglądać gra: UI (walka, menu, dialogi), balans (staty, obrażenia, tempo levelowania), struktura map i drużyny. Zrzuty / linki / nazwy scen + co konkretnie z nich brać.

**Assety:**
- [ ] Desert Temple (reskin Desert), Volcano (przedsionek Forge), Dense Forest, biom zimowy — zmodyfikowane warianty lub 16×16 z sieci.
