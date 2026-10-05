# Plan: uniwersalny generator układów strukturalnych (structured) — konfiguracja ścieków na poziomie makiet

Zatwierdzony 2026-10-05 (po dwóch rundach recenzji i uogólnieniu architektury). Ważne todo (1a) z [znane_problemy.md](znane_problemy.md).
Stan wyjściowy: [kontekst/scieki.md](kontekst/scieki.md), obiekty: [kontekst/obiekty.md](kontekst/obiekty.md).
Makiety: `assets/pixel_crawler/environments/sewer/Social/` — warstwy w Eksploratorze Aseprite.

## Kontekst
Ważne todo (1a). Wynik generatora ścieków (seed 119) to duże jednolite podłogi, void dookoła, jeden prosty
kanał i rozrzucone drobiazgi bez rytmu. Makiety autora (`sewer/Social/MockUp-01`, `MockUp-02`, Extended
`exc.aseprite` klatka 0; 25 × 25 kratek) budują obraz z powtarzalnych przęseł lica, brzegów kanału z barierkami
i małych kompozycji rekwizytów. Cel: okna oceny (def. niżej) z mapy wyglądają jak makieta, przy zachowaniu
płynnej grywalności.

Przyczyny (zbadane): ścieki idą przez `topology/interior_room_layout_generator.gd` (pokoje poly + korytarze
+ przejścia czyszczące pod jaskinie); `CanalPass` dokłada kanały na gotową podłogę; `ObjectPlanner` /
`WallDecorPlanner` stawiają pojedyncze obiekty bez rytmu i kompozycji; brak barierek, rur, filarów, czapek,
mchu, ciemnych plam; brak miary „makieta vs wynik”. Sama zmiana `ObjectPlanner` nie wystarczy.

Ponadto architektura układu nie może być ograniczona tylko do ścieków — elementy takie jak sieć liniowa
(ulice / fosy / kanały), strefowanie, grube ściany 2–3, rytm lica (filary, przęsła A-B-A), winiety z biblioteki
oraz rezerwacje pól są wspólne dla kolejnych map architektonicznych: **Miasta (ważne todo 5)**, Zamku czy Lochów.
Dlatego tworzymy **uniwersalny generator układów strukturalnych (`structured`)**, a ścieki są jego
**pierwszą konfiguracją**.

## Decyzje usera (2026-10-05)
- Niebieskie kafle w korycie Extended to **teren `foliage`** (Tiles 17–19 × 0–2) na dnie. Dopasowanie exc:
  dno 17–19 × 7–9, **doły 17,10 (23 kratki), 18,11** — wszystko już w atlasie.
- **Wymiary planszy ścieków:** kanały oraz woda zajmują znaczną część mapy (~25–35 %) i są *unwalkable*,
  przez co efektywna powierzchnia poruszania się kurczy. Dlatego domyślny zakres rozmiarów ścieków
  zostaje powiększony w konfiguracji: małe mapy od 160×160, standardowe 180×180–220×220, duże do 280×280
  (zamiast standardowych 120–250), aby zapewnić grywalną przestrzeń na sale, korytarze i kompozycje rekwizytów.
- Dzbany / worki: **wyciąć z warstwy MockUp-01** do atlasu (jak koryto), kafle do `sewer.tres` tekstowo.
- Recenzja planu (zewnętrzna, przyjęta): okna oceny, kontrakt rezerwacji pól, kontrola osiągalności,
  miękkie progi, test kafli osobno od pikseli, pionowy wycinek przed F2–F5, portale osobnym commitem.
- **Uogólnienie generatora:** kod układu w `scripts/generation/structured/`, flaga `layout: "structured"`,
  ścieki jako konfiguracja JSON (patrz sekcja Podejście architektoniczne).

## Analiza makiet (gramatyka do odtworzenia)

Makiety mają 400 × 400 px = 25 × 25 kratek (PNG w paczce to skala ×4). Warstwy rozkłada Eksplorator
Aseprite albo `ase_dump.py`.

### Skala i zagęszczenie
- Prawie brak pustki: między pomieszczeniami są **grube ściany 2–3 kratki** (ciemny grzbiet z ramą), a nie
  pola voidu. Podłoga i kanały zajmują ok. 60–70 % okna.
- Pomieszczenia małe i średnie (6–14 kratek), przylegają do siebie, połączone przejściami w ścianach
  i chodnikami przy kanałach. U nas: sale 16–28 kratek + korytarze 8 → wielkie puste pola i voidy.

### Kanały — kręgosłup mapy
- Sieć: pień + odnogi z zakrętami **L, T i +** (MockUp-01: pionowy kanał krzyżuje się z poziomym, dalej
  skręca). Szerokość wody 3–4 kratki. Kanał biegnie też **wzdłuż ściany** (brzeg tylko z jednej strony).
- Brzeg od strony chodnika: obrzeże (1 kratka) + lico brzegu, a na chodniku **barierka** (Props 6–9 × 4)
  ciągnąca się wzdłuż całego brzegu. Barierka ma **przerwę przy kładce** (1 kratka po każdej stronie)
  i **zawinięte końce** przy przerwie oraz przy ścianach.
- Kładki w obu orientacjach: pionowa przez kanał poziomy (2 kratki szerokości) i pozioma przez kanał pionowy
  (2 kratki wysokości, ~5 długości). W MockUp-02 jedna kładka na ~25 kratek kanału.
- **Extended (exc, klatka 0)** — ten sam układ co MockUp-01, ale kanał to **puste koryto**: dno z cegły,
  plamy terenu `foliage` (niebieskawe kafle 17–19 × 0–2 — nie woda), **czarne doły z ceglaną krawędzią** (stąd kafle dołów
  `Tiles.png` 17–20 × 10, 17–18 × 11 — doły to prostokąty 2–4 kratki z krawędzią u góry), **mech na dnie**
  przy brzegach. Barierki i kładki zostają jak przy kwasie.

### Lico ścian — rytm
- Wysokość 3 (grzbiet, krata z mchem, cokół); długie ściany dzielone **filarami** (Tiles 7, 3–6) w stałym
  odstępie: **5 kratek** (MockUp-02 góra: filar, łuk 3 kratki, filar…) albo **4 kratki** (MockUp-02 dół:
  filar, mały łuk 2 kratki, filar…). Filar wystaje kapturem ponad grzbiet ściany.
- Na filarze: **łańcuch z hakiem** albo **lampa**. Między filarami jedna ozdoba na przęsło: duży łuk odpływu,
  mały łuk, okrągła kratka, para lamp, przełączniki — w obrębie jednej ściany **powtarzana albo
  naprzemienna** (A-B-A-B), symetrycznie względem środka ściany.
- **Rury**: 2–4 równoległe miedziane rury schodzące z lica na posadzkę (MockUp-01 prawy górny róg, dół),
  rura w kształcie U wzdłuż ściany bocznej (MockUp-01 lewa ściana).
- Grzbiety ścian: **szare kostki (czapki)** w regularnych odstępach (co 4–5 kratek, w osi filarów).

### Posadzka
- **Kratki ściekowe w osi przęseł** (MockUp-02: trzy kratki 2 × 4 pod trzema łukami), duże kraty 6 × 3,
  4 × 4 w środku sal.
- **Rzędy otworów** 2 × N (pionowe przy ścianie) i N × 2 (poziome, 10 × 2 w MockUp-02).
- **Mech** (teren `foliage`) w kątach, przy ścianach i pod rekwizytami — plamy organiczne, nie kropki.
- **Ciemne plamy** (teren `dark_floor`) — rozmyte smugi na środku sal i przy przejściach.
- Gruz: 3–8 drobin w luźnym skupisku przy rekwizycie, ścianie albo w przejściu — nigdy równomiernie.

### Kompozycje rekwizytów (winiety)
| Winieta | Skład (makieta) | Miejsce |
|---|---|---|
| Wyjście | schody / regał (Props 0–1 × 6–8) między dwoma filarami z lampami | środek ściany N |
| Jadalnia | stół 3 × 2 + 2–4 krzesła po bokach | kąt sali |
| Piramida beczek | 3 + 2 beczki | kąt przy ścianie |
| Stos skrzyń | 2 × 2 skrzynki | przy ścianie, obok filaru |
| Zakątek | wiadro + skrzynka + gruz | kąt N |
| Skrzynia | skrzynia ścieków zamknięta (Props 8–9 × 2–3) / otwarta (8–9 × 0–1) | przy ścianie, często w mchu |
| Przy kanale | dzbany + worki | przy barierce (**brak w atlasie free** — zamiennik: beczki / skrzynki) |

---

## Podejście architektoniczne: Uniwersalny generator `structured`

Układ powstaje w ogólnym katalogu **`scripts/generation/structured/`**. Zwraca standardowy `GenerationResult`
(grid, rooms, linear_features / canals, objects, terrain_masks, portale, strefy, spawny).
Wybór układu następuje flagą `"layout": "structured"` w companion-JSON (gałąź w `cave_generator.gd:generate()`
obok `InteriorRoomLayoutGenerator.generate_layout`).
Ścieki to **pierwsza konfiguracja** tego układu (`resources/maps/config/sewer.json`). Ta sama architektura
posłuży do wygenerowania miasta (`city.json`), zamku czy lochów.

### Podział na warstwy: ogólna vs specyficzna

1. **Warstwa ogólna (`scripts/generation/structured/` — bez „Sewer” w nazwach):**
   - **`StructuredReservations`** — mapa zajętości, atomowy `claim`, blokady ruchu vs rezerwacje przechodnie;
   - **`LinearFeatureLayout`** — abstrakcja sieci cech liniowych (osie, odcinki, pasy ruchu, kładki/przejścia, krawędzie barier);
   - **`LinearNetworkGenerator`** — algorytm wzrostu sieci liniowej (pień, odnogi, zakręty L/T/+, minimalny odstęp);
   - **`StructuredZoning`** — strefowanie pasów ruchu wzdłuż sieci, grube ściany 2–3, korytarze serwisowe za ścianą;
   - **`StructuredRoomPacker`** — kompleksy wielokątne sal wzdłuż linii, odległe pokoje, korytarze A*, pętle, doklejane pokoiki;
   - **`FacadeRhythm`** — algorytm podziału lica ścian (filary co N kratek, symetria/naprzemienność przęseł, czapki);
   - **`VignettePlanner`** — silnik winiet rozkładający kompozycje z biblioteki szablonów JSON według kotwic;
   - **`ScatterPlanner`** — klastrowy rozrzut drobnicy (DECAL);
   - **Kontrole geometrii A i B** — weryfikacja spójności, osiągalności i czyszczenie odcięć;
   - **Metryki i okna oceny** — warstwowy framework ewaluacji wizualnej względem wzorców makiet;
   - **`tools/mockup_extract.py`** — sparametryzowany ekstraktor makiet Aseprite (przyjmuje ścieżki i atlasy z CLI).

2. **Warstwa specyficzna dla ścieków (`resources/maps/config/sewer.json` + `tiling/`):**
   - Typ elementu liniowego: `"canal"` (szerokość 4, pasy 3);
   - Koryto suche (`canal_dry_chance`), czarne doły z krawędzią (`pits`), mech (`foliage`) na dnie;
   - Barierki ochronne (Props 6–9 × 4) na zakwalifikowanych brzegach (`rail_edges`);
   - Kafelkowanie: `CanalPlacer` (kwas, obrzeża, kładki) oraz `FacadePlacer` na kaflach `sewer.tres`.

### Abstrakcja elementu liniowego: `LinearFeatureLayout` vs `CanalLayout`
Decyzja projektowa: Wprowadzamy ogólną klasę **`LinearFeatureLayout`** (`structured/core/linear_feature_layout.gd`),
zawierającą osie, segmenty, pasy ruchu (`lanes`), kładki/mostki (`crossings`), krawędzie barier (`rail_edges`)
oraz typ (`canal`, `street`, `trench`, `river`).
Klasa **`CanalLayout`** (`core/canal_layout.gd`) zostaje zachowana jako adapter/podklasa dziedzicząca po
`LinearFeatureLayout` (lub mapująca pola `water`, `dry`, `bridges`, `blocked`).
**Uzasadnienie:** Pozwala to miastu czy zamkowi korzystać z ulic, alejek i fos bez wprowadzania pojęć
związanych ze ściekami/wodą, a jednocześnie zapewnia 100 % wstecznej kompatybilności dla istniejących
konsumentów (`CanalPlacer`, `NavOutlines`, `SpawnPlanner`, testy diagnostyczne) bez konieczności ich modyfikacji.

### Konfiguracja w JSON zamiast stałych w kodzie
Wszystkie parametry determinujące charakter planszy przenosimy do sekcji w companion-JSON (`sewer.json`):
- `"structured_layout"`:
  - `linear_feature_type`: `"canal"` (w mieście: `"street"`);
  - `linear_width`: 4, `linear_clear_margin`: 16, `lane_width`: 3;
  - `wall_thickness_h`: 5, `wall_thickness_v`: 2;
  - `complex_count_ratio`: 5500, `complex_min_gap`: 20;
  - `room_distance_min_h`: 9, `room_distance_min_v`: 12;
  - `rooms_ratio`: 2000, `room_size_w`: [10, 17], `room_size_h`: [9, 14];
  - `loop_chance`: 0.35, `corridor_room_chance`: 0.5;
- `"facade_rhythm"`:
  - `pillar_spacing_options`: [4, 5];
  - `patterns`: ["A-A-A", "A-B-A", "A-B-B-A"];
  - `pillar_cap`: true;
- `"vignettes_catalog"`: `"res://modules/quiz_rpg/resources/maps/vignettes/sewer_vignettes.json"`.

Dzięki temu konfiguracja kolejnej mapy strukturalnej (np. Miasta) wymaga jedynie nowego pliku JSON oraz
katalogu obiektów/winiet, bez dopisywania nowego kodu układu.

---

## Kontrakt rezerwacji pól (`structured/structured_reservations.gd`)

Jedna mapa zajętości dzielona przez wszystkie passy. Każda kratka ma dwie niezależne cechy:
- `reserved_for_placement` — nie wolno tu postawić obiektu danej klasy (portal_zone, lanes,
  bridge_clearance: **przechodnie**, tylko zakaz stawiania);
- `blocks_movement` — kratka blokuje ruch (barierka, rekwizyt PROP z kolizją, woda bez kładki).

Do `ObjectPlan.occupancy` (spawny, nawigacja) trafia **tylko `blocks_movement`**, nie każdy claim.
Tabela legalnych nakładek (klasa nowego obiektu × właściciel kratki): DECAL (gruz, kratki, otwory) może leżeć
na posadzce pod lanes / clearance (nie blokuje ruchu), nie na portalu ani wodzie; PROP nigdy na pasie ruchu,
prześwicie, portalu; ozdoby lica (mount facade) nie zajmują posadzki poza kratką pod rurą. Reszta = konflikt.
`claim(cells, owner, klass, flags) -> bool` jest **atomowe**: sprawdza cały obrys (wszystkie kratki obiektu
wielokaflowego + margines) i zapisuje wszystko albo nic. **Bez wypierania:** passy rezerwują od najwyższego
priorytetu w dół, wcześniejszy claim jest ostateczny (nie trzeba nigdy cofać obiektu z `ObjectPlan`).

Priorytet przy konflikcie:
1. woda / dno kanału / ulica, kładki **z prześwitem** (kratki przed i za kładką),
2. pasy ruchu (chodnik ≥ 2 kratki wolne wzdłuż krawędzi, przejścia między pomieszczeniami),
3. portale i ich strefy dojścia (`portal_zone`, `arrival_cell`),
4. brzegi pod barierkę (kwalifikujące się odcinki — `LinearFeatureLayout.rail_edges`),
5. kotwice fasady (filary, przęsła, rury: kratki lica + kratka posadzki pod rurą),
6. kratki ściekowe / rzędy otworów (w osi przęseł),
7. winiety (cały obrys + strona dostępu),
8. gruz (tylko DECAL — może leżeć na polach 6, nie na 1–3).

Kolejność generowania jest z tym zgodna: sieć liniowa i pasy ruchu powstają pierwsze; **portale wybierane są
potem wyłącznie spośród kandydatów niekolidujących z wodą, kładką, prześwitem i pasami ruchu**; po wyborze
portali rezerwacje 1–3 są finalne i dopiero wtedy passy 4–8 rozstawiają obiekty.
`LinearFeatureLayout` dostaje pola: `rail_edges`, `bridge_clearance`, `lanes`. **`ObjectPlan.occupancy` dostaje
wyłącznie blokady ruchu; rezerwacje przechodnie pozostają w `StructuredReservations` i służą plannerom oraz
walidacji.**

---

## Pipeline (`structured/structured_layout_generator.gd`)

1. **`LinearNetworkGenerator`** — graf elementów liniowych najpierw: pień + odnogi, zakręty L / T / +,
   odcinki przy ścianie, woda 3–4 (lub ulica w mieście).
2. **`StructuredZoning`** — chodniki 2–4 wzdłuż brzegów (pasy ruchu), strefy, grube ściany 2–3.
3. **`StructuredRoomPacker`** —
   - Kompleksy sal wzdłuż linii: ciąg 2–4 odcinków jednej linii objęty spójnym wielokątem z błądzeniem
     losowym szerokości brzegu (0 lub 2–10 kratek), kładka w strefie o obu brzegach ≥ 2, zwężenia (brzeg 0)
     omijane korytarzem za ścianą (`service`) z bramą/dźwignią;
   - Pomieszczenia wolnostojące 6–14 kratek rzadko i daleko (odstęp ≥ 9/12 kratek od sieci i innych sal);
   - Korytarze A* łączące pokoje z siecią liniową ze ścianami od obcej podłogi;
   - Pętle wychodzące z kompleksu i wracające do jego odległej części;
   - Doklejane małe pokoiki do długich korytarzy;
   - Następnie reużycie: `_run_wall_shape_passes`, `ConnectivityRepair.repair`, `PortalGenerator`,
     wspólny wybór wejścia / wyjścia (kandydaci filtrowani przez rezerwacje 1–2; finalizacja rezerwacji portali).
   **Kontrola geometrii A:** po naprawie — wejście → wyjście osiągalne, krawędzie sieci przeliczone,
   `rail_edges` liczone dopiero teraz.
4. **`FacadeRhythm`** — filary (np. Tiles 7, 3–6) co 4 / 5 wyśrodkowane, typ przęsła na ścianę (A-A-A / A-B-A),
   łańcuch / lampa na filarze, czapki grzbietów w osi filarów, rury lico → posadzka, rura U przy ścianie bocznej.
5. **`LinearFeatureDressing` (dla ścieków: `CanalDressing`)** — barierki (Props 6–9 × 4) na `rail_edges`,
   przerwa przy kładce, zawinięte końce, kolizja; kładki w obu osiach; koryto suche wg Extended
   (`foliage` na dnie przy brzegach, czarne doły z krawędzią 2–4).
6. **`FloorDetail`** — `dark_floor` / `foliage` z pól odległości + szum (`TerrainMaskPlanner` / `TerrainAutotileSolver`),
   kratki w osi przęseł, duże kraty w środku sal, rzędy otworów.
7. **`VignettePlanner`** — biblioteka winiet z JSON (wyjście: schody Props 0–1 × 6–8 między filarami z lampami;
   jadalnia; piramida beczek; stos skrzyń; zakątek; skrzynia ścieków; dzbany + worki przy barierce);
   skrzynie quizów = winieta „Skrzynia”.
8. **`ScatterPlanner`** — gruz skupiskami (tylko DECAL).
9. **Kontrola geometrii B** (po barierkach i obiektach): osiągalność wejście → wyjście, wszystkie skrzynie
   quizowe, strefy wymagane dla gracza; przeszkodę odcinającą cel zdejmujemy (mechanizm `removed_for_reach`
   z `ObjectPlanner`), nie przesuwamy celu. Potem `SpawnPlanner`.

**Definicja ruchu = jak w grze:** gracz to kapsuła r = 3 px (`player.tscn`), wrogowie chodzą po navmeshu
z `NavOutlines.AGENT_RADIUS` = 7 px. Szybki BFS: 4 kierunki + skos **tylko gdy obie kratki ortogonalne
są wolne** (bez ścinania rogów), kratka przechodnia = nie `blocks_movement`; kładka przechodnia tylko
wzdłuż swojej osi (boki kładki = brzeg / barierka); przejście szerokości 1 kratki liczone jako
przechodnie dla gracza, ale **nie** dla wrogów (agent 7 px wymaga ≥ 1 kratki wolnej z marginesem —
sprawdzane na navmeshu). Test navmesh na scenie (MCP) po synchronizacji nawigacji
(`NavigationServer2D.map_changed` z **sprawdzeniem RID właściwej mapy** + kilka klatek fizyki,
**z timeoutem** — test kończy się błędem zamiast wisieć), nie zaraz po zbudowaniu mapy.

Ozdoby = kafle `sewer.tres` w `ObjectPlan`, kolizje `physics_layer_1`, kształty nawigacji z `"shape"`
w `objects_sewer.json`.

---

## Okna oceny i metryki

- **Okno kwalifikujące się:** 25 × 25 w granicach mapy z ≥ 60 % powierzchni grywalnej (podłoga + kanał).
  Kategorie: wejście, kanał / element liniowy, sala (bez kanału). Okna wybierane **deterministycznie i warstwowo**
  (siatka z krokiem 12 + losowanie z seeda raportu, stała liczba na kategorię). Raport: mediana i najgorsze
  10 % **osobno na kategorię** (metryki wizualne porównywane z makietą tej samej kategorii — sala nie musi
  mieć barierek), plus **współrzędne najgorszych okien** (seed, rozmiar, x, y) — showcase otwiera je wprost.
- **Twarde testy (błędy):** przerwana barierka na kwalifikującym się odcinku (100 % kwalifikujących się —
  bez kładek, zakończeń i celowych otwarć), barierka „w powietrzu”, zablokowany portal / strefa dojścia,
  nieosiągalne wyjście lub skrzynia quizowa, pokój ze spawnem bez połączenia navmesh, nakładające się obrysy.
- **Miękkie (zakresy / percentyle względem makiet opisanych w F0):** udział voidu, gęstość rekwizytów,
  mech / ciemne plamy, filary na 10 kratek lica, przęsła z ozdobą, liczba ról kafli, największy pusty
  prostokąt (miara pustki — percentyl, nie próg; sale do 14 mogą mieć spokojny środek).

---

## Fazy (commit + push po każdym kroku; gałąź `sewer-gen-v2` z `sewer-tileset`)

- **F0a dokumenty** — zatwierdzenie i commit zaktualizowanego `docs/plan_generator_sciekow.md`
  o uniwersalną architekturę `structured` oraz decyzje i recenzje.
- **F0b uniwersalny ekstraktor makiet** — `tools/mockup_extract.py` przyjmujący z CLI parametry `--atlas`,
  `--mockups`, `--output` (parser `.aseprite`, bezstratnie) → `resources/maps/mockups/sewer_m1|m2|ext.json`
  (warstwa, kratka, źródło / kafel / odbicie, obiekty spoza siatki z przesunięciem px). Pokrycie dziś 67–100 %:
  nieznane kratki opisywane ręcznie. Opis makiet: strefy, przęsła, winiety, odcinki barierek → wzorce metryk miękkich.
- **F0c testy odtworzenia** — (1) **zgodność kafli**: makieta złożona z naszego TileSetu — identyfikatory
  kafli, warstwy, kolejność rysowania / y-sort, pozycje; (2) **zgodność pikseli** jako drugi test, z listą
  wyjątków (cienie ręczne, rekwizyty spoza atlasu).
- **F0d narzędzia** — wycięcie dzbanów / worków do atlasu + kafle w `sewer.tres`; `tests/sewer_showcase.gd`
  (okna oceny + zrzut MCP obok makiety); `tests/diag_structured_metrics.gd` (twarde + miękkie); pomiar czasu.
- **F1a portale** — wydzielenie wyboru wejścia / wyjścia z `interior_room_layout_generator.gd` P9 do wspólnej
  funkcji — **osobny mały commit + parytet jaskini 42/42** (jedyna zmiana na ścieżce jaskini).
- **F1b uniwersalny silnik układu `structured`** — implementacja warstwy ogólnej: `LinearNetworkGenerator`,
  `StructuredZoning`, `StructuredRoomPacker`, `StructuredReservations`, `LinearFeatureLayout` (kroki 1–3 + kontrola A),
  flaga `layout: "structured"` w `cave_generator.gd` i konfiguracja w `sewer.json`.
- **F1c pionowy wycinek = test integracyjny architektury** — wycinek (fixture, stały seed / zadany graf)
  z **dwiema kładkami w obu osiach** (kanał poziomy + pionowy z zakrętem), barierkami z końcami i przerwami,
  jednym przęsłem z filarami i jedną winietą z dojściem — minimalne wersje passów 4–9 na kontrakcie rezerwacji.
  Od `GenerationResult` po ruch w grze (MCP: `run_project` → `simulate_input` wzdłuż barierek, przez obie kładki,
  przy końcu barierki, do winiety; zgodność grafiki, fizyki i navmesh po synchronizacji; wrogowie przy kanale).
  Dopiero po akceptacji wycinka skalowanie.
- **F2 skalowanie sieci liniowej i dressing kanałów** (pełny krok 1 + 5 na całej mapie, koryto suche, doły).
- **F3 lico** (ogólny `FacadeRhythm`: filary, przęsła, czapki, rury).
- **F4 posadzka** (ogólny `FloorDetail`: maski terenu, kratki, rzędy otworów).
- **F5 winiety i gruz** (`VignettePlanner` z biblioteki JSON + `ScatterPlanner` + kontrola B).
- **F6 rozgrywka i wydajność** — spawny, navmesh z barierkami; czas mierzony **osobno**: generowanie danych
  oraz pełny czas do gotowej sceny (kafle, fizyka, nawigacja) dla 160² i 250²; budżet: obecny + 20 % dla obu.
- **F7 strojenie i walidacja uniwersalności** — galeria 12 seedów (artefakt „makieta | wynik” + tabela metryk),
  weryfikacja kryterium akceptacji uniwersalności (poniżej), merge na `main` po akceptacji.

### Kryterium akceptacji uniwersalności (cel po F7)
Po zakończeniu F7 konfiguracja drugiej mapy opartej o układ strukturalny (np. szkic miasta z ulicami,
placami i budynkami) wymaga **wyłącznie utworzenia pliku JSON konfiguracji** (`city.json`) oraz **katalogu
obiektów i winiet** (`objects_city.json`, `city_vignettes.json`), **bez konieczności modyfikowania kodu
generatora układu w `scripts/generation/structured/`**.

---

## Pliki

### Warstwa ogólna (uniwersalna dla ścieków, miasta, zamku)
- Nowe moduły:
  - `scripts/generation/structured/structured_layout_generator.gd` (koordynator pipeline'u);
  - `scripts/generation/structured/structured_reservations.gd` (`StructuredReservations`);
  - `scripts/generation/structured/core/linear_feature_layout.gd` (`LinearFeatureLayout`);
  - `scripts/generation/structured/linear_network_generator.gd` (`LinearNetworkGenerator`);
  - `scripts/generation/structured/structured_zoning.gd` (`StructuredZoning`);
  - `scripts/generation/structured/structured_room_packer.gd` (`StructuredRoomPacker`);
  - `scripts/generation/structured/facade_rhythm.gd` (`FacadeRhythm`);
  - `scripts/generation/structured/vignette_planner.gd` (`VignettePlanner`);
  - `scripts/generation/structured/scatter_planner.gd` (`ScatterPlanner`).
- Narzędzia i testy:
  - `tools/mockup_extract.py` (ogólny parser makiet z CLI);
  - `tests/diag_structured_metrics.gd` (ogólny ewaluator metryk okien oceny).

### Warstwa specyficzna dla ścieków
- Nowe pliki danych:
  - `resources/maps/vignettes/sewer_vignettes.json` (szablony kompozycji dla ścieków);
  - `resources/maps/mockups/sewer_m1.json`, `sewer_m2.json`, `sewer_ext.json`.
- Istniejące / modyfikowane moduły:
  - `cave_generator.gd` (rozpoznawanie flagi `"layout": "structured"`);
  - `interior_room_layout_generator.gd` (tylko F1a — wydzielenie wyboru portali);
  - `core/canal_layout.gd` (alias/adapter do `LinearFeatureLayout`);
  - `core/generation_flags.gd` + `tiles/generator_behaviour_config.gd` (sekcje `"structured_layout"`, `"facade_rhythm"`);
  - `resources/maps/config/sewer.json` (konfiguracja układu, rytmu, winiet, powiększone rozmiary mapy);
  - `objects_sewer.json`, `sewer.tres` (tekstowo — dzbany/worki);
  - `Tiles.png` / `Props.png` (host + `_host/`);
  - Testy lokalne: `tests/sewer_showcase.gd`.
- Dokumentacja:
  - `docs/plan_generator_sciekow.md`, `docs/kontekst/scieki.md`.

---

## Weryfikacja
- Po każdej fazie: zrzut MCP `godot-runtime` okien oceny obok makiety (seedy 119 / 7 / 42; 160², 250²),
  raport `diag_structured_metrics.gd` (twarde = zielone; miękkie = mediana i najgorsze 10 % w zakresie makiet).
- F0c zielony (kafle), piksele w granicach wyjątków.
- F1c: ruch postaci i wrogów na działającej scenie (MCP `simulate_input`, `run_script` z pozycją gracza).
- Regresja: `run_plateau_suite.sh` (parytet jaskini 42/42), `diag_objects`, `diag_tile_object_physics`,
  `diag_sewer_objects_runtime`, `diag_spawn_cells`, `diag_enemy_drift`.
- Czas: dane i pełna scena ≤ obecny + 20 %.
- Kryterium uniwersalności: szkic konfiguracji miasta bez zmian w `scripts/generation/structured/`.

---

## Status realizacji (stan na 2026-10-05)

- [x] **F0a Dokumenty** — plan zatwierdzony i zaktualizowany o uniwersalną architekturę `structured`.
- [x] **F1a Portale** — wydzielony wybór wejścia / wyjścia ze wspólnym algorytmem, zachowany parytet jaskini.
- [x] **F1b Uniwersalny silnik układu `structured`** — wdrożone moduły w `scripts/generation/structured/`:
  - `LinearNetworkGenerator`, `StructuredZoning`, `StructuredRoomPacker`, `StructuredReservations`, `LinearFeatureLayout`, `CanalLayout`.
  - Integracja w `cave_generator.gd` pod flagą `"layout": "structured"` i konfiguracja w `sewer.json`.
  - 100% determinizmu PRNG we wszystkich passach (Fisher-Yates `shuffle_array`).
  - Separacja suchego koryta od kwasu na poziomie skrzyżowań (min dystans $\ge 17.0$ kratek).
  - Usunięcie rozcinającego ściany `_ensure_canal_clearance` i zachowanie prepassów ścian 3H przy korytach.
  - `BridgeConnectivityResolver` gwarantujący 1 składową spójną całej mapy.
- [x] **F1c Pionowy wycinek (test integracyjny architektury)** — `diag_sewer_slice_fixture.gd` (PASS 13 / FAIL 0):
  - Kładki w obu osiach, barierki z przerwami i zawiniętymi końcami, przęsło lica, winieta z dojściem, baking NavMesh i synchronizacja.
- [x] **Kładki i krawędzie (poprawki F1)**:
  - Kładki na dedykowanej, osobnej warstwie `Bridges` (`z_index = -1`, y-sort) w generatorze i `ProceduralLevel`.
  - 100% ciągłości opuszczonej krawędzi `CANAL_FACE` (4, 13) w `canal_placer.gd` (usunięcie zbędnego warunku przechodniości pola na północ).
  - Rozszerzenie kładki poziomej `BRIDGE_H` w atlasie `Props.png` do pełnego rozmiaru 6×2 (kolumny 5–10, `origin = Vector2i(5, 12)`).
- [ ] **F2 Skalowanie sieci liniowej i dressing kanałów** *(NASTĘPNY ETAP)*:
  - Czarne doły z krawędzią (`pits`) w suchym korycie.
  - Pełny dressing barierek ochronnych na całej mapie (`CanalDressing`).
- [ ] **F3 Lico** (ogólny `FacadeRhythm`: filary, przęsła, czapki, rury).
- [ ] **F4 Posadzka** (ogólny `FloorDetail`: maski terenu, kratki, rzędy otworów).
- [ ] **F5 Winiety i gruz** (`VignettePlanner` + `ScatterPlanner` + kontrola B).
- [ ] **F6 Rozgrywka i wydajność** (spawny, weryfikacja navmesh, budżet czasu).
- [ ] **F7 Strojenie i walidacja uniwersalności** (galeria 12 seedów, konfiguracja miasta).

