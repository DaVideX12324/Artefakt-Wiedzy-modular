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
| **Musi** | Pełna ścieżka: tutorial → jaskinia → miasto → ścieki, **kończąca się na bossie ścieków** (**[U] 2026-10-23**: to koniec Cienia Mgły w zakresie inżynierki; krótkie zakończenie bez rozgałęzień po pokonaniu bossa; **[U] 2026-10-24**: ekran końca po wyjściu ze ścieków na cmentarzysko — boss otwiera wyjście) |
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

> **Stan 2026-10-24: nieaktualne — plan z 2026-10-16, zrealizowany i rozszerzony.** BitBomber `0.9.0-beta` ma 28 map
> (układy z Bomb It 7, format JSON), generowaną grafikę i dźwięk, tryby Ostatni żywy i Zabójstwa, quizy w grze i kontrakt
> sesji z hostem w obie strony — opis w `modules/BitBomber/README.md` i `CHANGELOG.md`. Niżej treść historyczna.

Stan 2026-10-16 (`modules/BitBomber`): arena to prosta siatka 17×17 o kafelku 64 px (`scripts/arena.gd`) z filarami i skrzyniami, rysowana
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
płaska siatka `PackedByteArray` (krok 3 w [`archiwum/plan_przyspieszenie_generowania.md`](archiwum/plan_przyspieszenie_generowania.md)); porty tylko tych etapów,
które po tym nadal przekraczają 2–3 s na realnych rozmiarach (150–250). Parytet generatora (digesty IDENTICAL) jest siatką bezpieczeństwa.

## 7. Stan kodu Cienia Mgły względem zakresu (sprawdzone 2026-10-24, CienMgly `955bb5c8`, wersja `0.8.0-alpha`)

> Poprzednia wersja tej sekcji (2026-10-23) opisywała starszy commit `39da694a` — miasto i boss ścieków doszły po nim
> (handoff `archiwum/sesja_2026-10-22.md`).

Przegląd kodu pod kątem ścieżki „tutorial → jaskinia → miasto → ścieki, koniec na bossie ścieków” (od 2026-10-24: na wyjściu ze ścieków po bossie):

| Element | Stan w kodzie |
|---|---|
| Łańcuch map | `tutorial_area` → `cave` → `town` → `sewer` (`next_level_path` w scenach `levels/`); powrót do poprzednich map działa |
| Miasto | `town.tscn` z NPC (sklepy, kowal, nauczyciel, karczma, zadania) i przejściami; **mapa w budowie** u usera (warstwa Walls, obiekty, domki) — po przeniesieniu warstw test przejścia i szczelności granic |
| Boss jaskini | `caves.json` `"boss"` (`cave_relic`) w pokoju wyjścia; po wizycie w mieście boss powrotny Matka Nietoperzy (`boss:cave_return`) |
| Boss ścieków | Szczurzy Król (`rat_king.tscn`, najwyższy tier puli `beasts`) w pokoju wyjścia; `sewer.json` `"boss": {"locks_exit": true}` — wyjście (drabina) zamknięte i bez snopu światła do pokonania bossa (2026-10-24); flaga `boss:sewer` z nazwy sceny |
| Koniec po wyjściu ze ścieków | `end_screen.tscn` po wejściu w wyjście ścieków (na cmentarzysko) — `sewer.json` `"exit_ends_game": true` zamiast przejścia na następną mapę (decyzja usera 2026-10-24; znacznik „Ukończono” w slocie zapisu). `sewer.tscn` nie ma `next_level_path` (zaślepka `world_map.tscn` odpięta); mapa cmentarzyska to zakres 2.0 |

Do zrobienia, żeby zakres był domknięty **[P]**:
1. Dokończenie mapy miasta (user) i test przejścia jaskinia → miasto → ścieki na `town.tscn`.
2. Przejście ścieżki od nowej gry do ekranu końca w grze (bez komend deweloperskich) — warunek Bety (`0.9.0-beta`).
3. Zastępcze flagi `forge` / `library` / `garden` w sklepach: zostają pod pełną grę; ulepszenie broni etap 1 → 2 jest
   tymczasowo pod `boss:cave_return` (docelowo `boss:sewer`, który w tym zakresie kończy grę).

## 8. Otwarte pytania

- Co dokładnie wymaga promotor (wymagania formalne, wielkość systemu, ewaluacja)?
- ~~Czy BitBomber ma wejść do ewaluacji?~~ **[U] 2026-10-23: cały Artefakt wchodzi do ewaluacji**, w tym tworzenie i edycja pytań; dwa etapy testów: (1) platforma + edytor pytań + BitBomber, wcześnie, (2) Cień Mgły po zamrożeniu funkcji (materiały: [`ewaluacja/`](ewaluacja/etap1_scenariusz.md)).
- Który wariant klifów (renderer stemplami czy mapa płaska z kilkoma tarasami)?
