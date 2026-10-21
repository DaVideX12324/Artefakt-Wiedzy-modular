# Zadania od najłatwiejszych / najszybszych

> Widok pomocniczy, **nie** źródło prawdy — szczegóły i statusy: [`docs/znane_problemy.md`](../znane_problemy.md). Stan na 2026-10-17.
> Skróty: **U** = robi user (gra/LDtk/grafika), **S** = Sonnet wystarczy, **O** = lepiej Opus (projekt/architektura). ✅ = zrobione.

> Sekcja „Z znanych problemów” na końcu (przeniesione 2026-10-21 z [`znane_problemy.md`](../znane_problemy.md)); zrobione wpisy są tam w „Rozwiązane”.

## 1. Minuty

1. **U** — sprawdzić w grze: poprawki ekranu śmierci i trucizny, skrzynie i klucze na tier, beczki 3/(2n), złoto, koszt walki, zakładkę „Ogólne”, a po ostatnich zmianach: scroll drużyny w pauzie, wczytywanie map z dysku, grę po angielsku w oknie.
2. **U** — skomitować `Floor_Full.xcf` (submoduł, potem wskaźnik w hoście). `miasto.ldtk` niepotrzebne — LDtk pominięty (2026-10-22).
3. ✅ **U** — `world_build` to wersja 32x, nie nada się: przywrócony do `assets/_nieuzywane/pixel_crawler/environments/world_build/` (2026-10-22, assets `1c92671`).
4. **S** — usunąć nieśledzoną kopię `pixel_crawler_free.tres` po sprawdzeniu referencji.

## 2. Godziny

5. ✅ **S** — przegląd gry po angielsku (skan danych i scen UI bez polskich znaków; w oknie nikt nie sprawdzał).
6. ✅ **S** — poprawki i18n: klucze `bb.options.bind_*`, imiona bohaterów wdrożone 2026-10-21 (Kael, Eldon, Selene — EN = PL). Kolizje msgid z nazwami klas usunięte.
7. ✅ **S** — pancerz: zmierzony, decyzja usera **„zostaw na razie”** do czasu decyzji o skali drabiny sprzętu (pkt 20).
8. ✅ **S** — `optimize_member_equipment` z MAT/MDF (mag/kapłan → MAT).
10. ✅ **S** — scroll drużyny > 4 w pauzie. Szyk w Status: zostaje osobno (decyzja usera). Okno pytania: już zgodne z życzeniem (najpierw rozszerza się na maks., potem rośnie w górę; może zasłaniać UI).
11. ✅ **S** — stare FAIL-e testów naprawione (`check_combat_lists`, `check_start_safety`, `check_pause_lists`).
12. **U/S** — ikony i tabela mikstur w tierach.

## 3. Pół dnia

13. ✅ **S** — klucze i wytrychy uniwersalne (zrobione 2026-10-11, `kontekst/obiekty.md` „Klucze i wytrychy”).
14. ✖ ~~konwerter LDtk → `TileMapLayer`~~ — odpada (2026-10-22, decyzja usera): miasto robione bezpośrednio w Godocie, na bazie edytowanego desert town.
15. ✅ **S** — interfejs sklepu (2026-10-21, `kontekst/npc.md`); ceny robocze do czasu pkt 20. Ceny zależą od skali drabiny sprzętu (pkt 20), więc najpierw wspólny szkielet interakcji z NPC (pkt 21–24).
16. **S** — warianty skrzyń z innych paczek i więcej mikstur w jaskiniach.
17. ✅ **S** — zapis map na dysk (`map_disk_cache.gd`, wejście z pliku ≈ 0,25 s zamiast 2–2,5 s). Zapis map z wyprzedzeniem i kasowanie map usuniętego slotu / rerollu zrobione 2026-10-22. Zostało: podbijanie `MAP_CACHE_VERSION` w wydaniu (klatka ~0,5 s przy starcie mapy z wyprzedzeniem naprawiona 2026-10-22: sceny wrogów i tabele łupu wczytywane w tle).
18. ✅ **S/O** — skrzynie specjalne w rzadkich pokojach (2026-10-21, tier 3, pokoje na uboczu). Nisze out w jaskiniach ✅ (2026-10-21: przedmiot, skrzynia tieru 2 albo sekretny pokój — osobna mapa z 1–3 pokoi; jedna nisza na mapę do krypty relikwii z bossem, `kontekst/obiekty.md` „Zawartość nisz out”). Zostało: przedmiot relikwii, rzadkie pokoje.
19. ✅ **S/O** — generator obiektów F5: niszczalne beczki, dźwignie bram, nakładka podglądu (2026-10-21); leniwe sceny niepotrzebne (pomiar).

## 4. Dni

20. ✅ **O** — krzywe XP do lv 100 (były) i skala drabiny sprzętu jak FNaFB1 (2026-10-21, `kontekst/ekwipunek_szkic.md` sekcja 12). Zostało: przedmioty pośrednie per mapa, tiery mikstur, ceny w sklepach.
21. ✅ **O** — wspólny szkielet interakcji z NPC: usługi sklep / odpoczynek / nauka / rozmowa (2026-10-21, `kontekst/npc.md`). Zostały: kowal, zadania NPC.
22. ✅ **O** — sklep z tierami blokowanymi flagami fabularnymi (mechanizm; flagi to placeholdery).
23. ✅ **O** — kowal i bronie z potencjałem (2026-10-21: usługa ulepszania + Ostrze Mgły w 4 etapach jako relikwia jaskiń, `kontekst/npc.md`). Zostało: kolejne bronie z potencjałem (inne klasy), materiały z bossów, prawdziwe flagi etapów.
24. ✅ **O** — rekrutacja towarzyszy, skille klasowe i sloty umiejętności (2026-10-21, `kontekst/druzyna_szkic.md`, `kontekst/sloty_umiejetnosci_szkic.md` sekcja 6). Zostały: imiona towarzyszy, akcesoria z bonusem slotów.
25. **O** — logika miasta: flagi, NPC, wnętrza.
26. ➜ **rozszerzony scope** (decyzja usera 2026-10-22, nie na poziom inżynierki) — finał: walka z ostatnim bossem (fazy, inna Faza 2 na ścieżce Good), cutscenka i zakończenia, zabranie towarzyszy, „Wzmocnienie tarczy”, umiejętność 10. poziomu, limit mikstur SP w finale. Szkic: `fabula_krag_i_zakonczenia_szkic.md` sekcje 5–6.

Odłożone poza inżynierkę (rozszerzony scope): tilesety kolejnych map, dalsze przyspieszanie generatora, finał (pkt 26).

**Następny sensowny krok:** Opus robi szkic ekonomii/drabiny sprzętu (20) i szkielet NPC (21); potem UI scen (15, 22) może zrobić Sonnet albo Antigravity z briefem. Bez blokady: 19 (nakładka podglądu), 16 (warianty skrzyń).

## Z znanych problemów (otwarte, stan 2026-10-21, od najłatwiejszych)

**Minuty / godziny**
- **U** — sprawdzić w grze: ekran śmierci i trucizna, mysz w walce (klik wroga, listy, znacznik celu, klik po fokusie), pytania bossów, skróty dev w eksporcie, gra po angielsku, skrzynie / klucze / beczki / złoto / trudność jaskiń, kafle wielokratkowe na `Props`, grzyby nad ścianą; nowe: sloty (Q/E), trasa map (jaskinia po tutorialu od południa), skille klasowe.
- ✅ **S** — zduplikowany UID ikony BitBombera (BitBomber `icon.png.import` ma własny UID, 2026-10-21).
- **S/O** — `PlateauPass._solve` ~750 ms na 250² (płaskie tablice jak w `ObjectPlanner`). Ocena 2026-10-21: to ~200-liniowa pętla na słownikach w pliku 2000 linii, każda zmiana wymaga parytetu 42/42 — zysk ≤ 0,5 s niewart ryzyka, raczej odpuścić.
- ✅ **S** — resztki i18n (2026-10-21): sprawdzone — sterowanie BitBombera, opcje motywu i nagrody były już przetłumaczone, etapy generowania doszły (`gen.stage.*`). Licznik „407 linii” w `check_i18n.py` zawyża (liczy zapasowe teksty `QuizRpgI18n.t(...)`, komentarze, dev menu, narzędzia); zostają tylko narzędzia i komunikaty debug.

**Pół dnia**
- **S** — propozycja korzenia modułu z położenia skryptu (`module_root()`), po zatwierdzeniu przez usera.
- **S** — ścieki: winiety, gruz w skupiskach, mniej zdejmowania obiektów na 250², uskoki lica przy dostawionych pokojach.
- ✅ **S/O** — umiejętności wrogów skalowane z poziomem (2026-10-21): obrażenia umiejętności liczą się z ATK/MAT wroga, który już skaluje się z poziomem; jedyne stałe liczby to leczenie Mrocznej Regeneracji (zamienione na 25 % maks. HP) oraz niewielkie `base_damage` 40 / 80 w Serii Wybuchów i Oddechu Zgnilizny (zostawione — pomijalne na wyższych poziomach).
- **S/O** — częstsze nisze-przejścia (dziś 0–2 na mapę; np. celowe wycięcie ściany do głębokości 3).
- **O** — pancerz na późnych poziomach: wzór procentowy `ATK×4 × 100/(100+DEF·k)` albo mocniejszy DEF w krzywych (po zmierzeniu drabiny).
- **O** — NPC: kwestie przy pierwszej rozmowie po nowym tierze (`required_flag`), prawdziwe flagi etapów kowala i sklepów, skrzynia przeklęta, akcesoria z bonusem slotów.

**Dni**
- ✅ **O** — minimapa z fog of war (2026-10-21: róg + pełna mapa pod M, linia wzroku, maska w zapisie, mapy ręczne z warstw; `znane_problemy.md` „Minimapa”).
- ✅ **O** — losowe spotkania jak w JRPG (2026-10-21, wersja podstawowa: tryb `cleared` w jaskiniach, `random_encounters` w JSON mapy; zostało strojenie w grze i ścieki).
- **O** — ukryte przejścia między pokojami (tunel pod voidem, shader z Amon-Ra, własne kolizje ścian tunelu) — projekt najpierw.

**User / poza inżynierką**
- Miasto (ręcznie), wariant kafli RIM nisz-przejść, tilesety kolejnych map, mapy otwarte (las) po tilesetach.

