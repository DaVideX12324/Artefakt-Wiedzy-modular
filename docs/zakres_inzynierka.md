# Zakres pracy inżynierskiej — wycinek gry, miasto, BitBomber (szkic do oceny)

Stan (2026-10-17): **SZKIC (niezatwierdzone)** — ustalenia z rozmowy, nic nie jest zamrożone. Obrona: **styczeń/luty 2027**.
Oznaczenia: **[U]** — decyzja autora, **[P]** — propozycja do potwierdzenia.

## 1. Zasada

Tytuł pracy to projekt i implementacja edukacyjnej gry z mechaniką quizów w Godocie. Praca ocenia się po tym, czy opisany system
działa, jak jest zaprojektowany (platforma modułowa, edytor pytań, generator map, walka), jak został przetestowany i czy ktoś go
przetestował (ewaluacja z użytkownikami). Nie ocenia się ilości treści gry. Dlatego **zakres to zamknięty wycinek**, a pełna wizja
(fabuła, zakończenia, ~15 map) zostaje jako „dalszy rozwój” w rozdziale pracy [P]. Warto potwierdzić zakres z promotorem.

## 2. Zakres (musi / powinno / może)

| Poziom | Pozycja |
|---|---|
| **Musi** | Zamknięta pętla Cienia Mgły: **miasto-hub** z podstawowymi NPC (sklep, nauczyciel umiejętności w Hideout, zapis/odpoczynek, jeden mieszkaniec z dialogiem) |
| **Musi** | Pełna ścieżka: tutorial → jaskinia → miasto → ścieki, z jednym bossem i **krótkim zakończeniem** (bez rozgałęzień) |
| **Musi** | Edytor pytań i quizy działające w całej ścieżce (5 typów pytań, własne zestawy) |
| **Musi** | **BitBomber** jako drugi moduł dowodzący modularności: kontrakt host↔moduł w obie strony (konfiguracja sesji do modułu, wynik z modułu), stabilne embedded i standalone, podstawowe mapy i tekstury |
| **Musi** | Testy i pomiary (parytet generatora, profil generowania), dokumentacja architektury, ewaluacja z użytkownikami, tekst pracy |
| Powinno | BitBomber: więcej kształtów map (jak w Bomb It 7), motywy wizualne, ekran wyników |
| Powinno | 2–3 wnętrza w mieście (sklep, Hideout, ewentualnie kowal) |
| Może | Kowal i ulepszenia broni (rekrutacja towarzyszy: zrobiona, MVP) |
| Dalszy rozwój | Trzy zakończenia, NG+, fabuła z zamianą ciał, magia 10. poziomu (szkic: [`kontekst/fabula_krag_i_zakonczenia_szkic.md`](kontekst/fabula_krag_i_zakonczenia_szkic.md)), ~15 map, kolejne moduły |
| Poza zakresem | Przepisywanie generatora na C# (patrz „Wydajność”); tilesety kolejnych map (Cemetery, Fairy Forest itd.) — osobny branch **[U]** |

## 3. Orientacyjny harmonogram [P]

- **Do końca listopada:** miasto + NPC + sklep + nauczyciele umiejętności; BitBomber w zakresie 2–3 tygodni (mapy, tekstury, kontrakt).
  Potem **zamrożenie funkcji**.
- **Grudzień:** stabilizacja, testy, ewaluacja z użytkownikami (np. uczniowie, ankieta).
- **Styczeń:** pisanie i szlif pracy, bez nowych funkcji.

Ryzyka terminów: każdy budynek jako osobna scena wnętrza (robić tylko tyle wnętrz, ile wymagają role NPC), system dialogów, UI sklepu
i UI nauki umiejętności (osobne kawałki kodu — wycenić przed pracą nad grafiką).

## 4. Miasto

- Układ: maska makiety miasta (mury, tarasy, rzeka, rynek, drogi, domy jako obrysy) — generator i wyniki w
  [`prototypy/makieta_miasta/`](prototypy/makieta_miasta/README.md). Alternatywa: konwersja Desert Town na Pixel Crawler
  (ten sam katalog; zrobiona tylko częściowo).
- **Klify w Pixel Crawler** — `Wall_Tiles` to stemple, a nie autotile. Pierwszy blok (kolumny 0–5): wierzch skały w wierszach 0–4
  (krawędzie w kolumnach 0 i 5, górny brzeg w wierszu 0), dolna krawędź wierzchu w wierszu 5, ściana w wierszach 6–7, dół ściany
  z trawą w wierszach 8–9. Trzy kolory (brązowy, szary, ciemny) i wariant ze śniegiem.
- **[U] Wysokość ponad minimum przez powtórzenie środka ściany.** Ściany wyższe niż minimalna (rzędu 1–5 poziomów wysokości) buduje się,
  powtarzając środkowy fragment ściany (wiersze 6–7) odpowiednią liczbę razy. To pozwala odwzorować wysokości jak w Desert Oasis (1–5)
  bez dorysowywania nowych kafli.
- **[P] Renderer klifów stemplami (9-slice):** płaskowyż to wierzch (środek z kolumn 1–4, krawędzie z kolumn 0 i 5), nad nim dolna
  krawędź wierzchu, pod nią powtarzany środek ściany i dół z trawą. Ograniczenia: płaskowyż min. ok. 6×8 kafli, proste obrysy,
  brak odpowiednika narożników wewnętrznych. Do zbudowania na wejściu z maski wysokości (generator makiety ma już poziomy 0–3).
- Wariant minimalny, jeśli czasu zabraknie [P]: mapa płaska, wysokość tylko w 1–2 miejscach (taras biblioteki), malowana ręcznie.

## 5. BitBomber

Stan (`modules/BitBomber`): arena to prosta siatka 17×17 o kafelku 64 px (`scripts/arena.gd`) z filarami i skrzyniami, rysowana
`ColorRect`-ami (bez tekstur). Są gracze, boty, bomby, power-upy, quiz między rundami, menu, opcje, pauza. Brakuje map i tekstur
**[U]**; generator jest bardzo prosty, a Bomb It 7 miał wiele kształtów aren **[U]**.

- **[P] Format definicji map:** ASCII lub JSON (`#` ściana, `.` pusto, `+` skrzynia, `S` spawn), wczytywany przez `arena.gd` zamiast
  zaszytej siatki. Ten sam format pozwala testować mapy bez uruchamiania gry (np. spójność: każdy spawn osiągalny, dość miejsca na start).
- **[P] Szablony kształtów** (klasyczna siatka, pierścień, krzyż, romb, dziury/wyspy, asymetryczne strefy) i warianty z symetrią
  (lustro, obrót) oraz losowym rozmieszczeniem skrzyń z gwarancją bezpiecznego startu.
- **[P] Motywy tekstur** (tileset na motyw: podłoga, ściana stała, skrzynia), np. z paczki Pixel Crawler, przełączane per mapa.
- **[P] Kontrakt z hostem:** konfiguracja sesji w, wynik (zwycięzca, punkty) z powrotem — jedyny element zostawiony w Roadmapie README BitBombera.
- Zakres czasowy: 2–3 tygodnie. Nowe tryby gry i rozbudowa poza tym zakresem.

## 6. Wydajność generatora (C#)

500×500 spadło z ok. 68 s do ok. 32 s po optymalizacjach; **[U] generator przyspieszony, ile się da bez C# (2026-10-17), temat zamknięty**. Przepisywanie skryptów na C# **[P] nie na tym etapie**: projekt jest dziś
zwykłym Godotem (GDScript, bez `.csproj`), a C# wymaga edytora .NET, SDK, innych szablonów eksportu i budowania modułów; eksport na web
w Godot 4 nie był wspierany dla C# (sprawdzić dla 4.7). Wąskim gardłem są `Dictionary[Vector2i]` i wywołania na kratkę, więc najpierw
płaska siatka `PackedByteArray` (krok 3 w [`plan_przyspieszenie_generowania.md`](plan_przyspieszenie_generowania.md)); porty tylko tych etapów,
które po tym nadal przekraczają 2–3 s na realnych rozmiarach (150–250). Parytet generatora (digesty IDENTICAL) jest siatką bezpieczeństwa.

## 7. Otwarte pytania

- Co dokładnie wymaga promotor (wymagania formalne, wielkość systemu, ewaluacja)?
- ~~Czy BitBomber ma wejść do ewaluacji?~~ **[U] 2026-10-23: cały Artefakt wchodzi do ewaluacji**, w tym tworzenie i edycja pytań; dwa etapy testów: (1) platforma + edytor pytań + BitBomber, wcześnie, (2) Cień Mgły po zamrożeniu funkcji (materiały: [`ewaluacja/`](ewaluacja/etap1_scenariusz.md)).
- Który wariant klifów (renderer stemplami czy mapa płaska z kilkoma tarasami)?
