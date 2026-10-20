# Zadania od najłatwiejszych / najszybszych

> Widok pomocniczy, **nie** źródło prawdy — szczegóły i statusy: [`docs/znane_problemy.md`](../znane_problemy.md). Stan na 2026-10-17.
> Skróty: **U** = robi user (gra/LDtk/grafika), **S** = Sonnet wystarczy, **O** = lepiej Opus (projekt/architektura). ✅ = zrobione.

## 1. Minuty

1. **U** — sprawdzić w grze: poprawki ekranu śmierci i trucizny, skrzynie i klucze na tier, beczki 3/(2n), złoto, koszt walki, zakładkę „Ogólne”, a po ostatnich zmianach: scroll drużyny w pauzie, wczytywanie map z dysku, grę po angielsku w oknie.
2. **U** — skomitować `Floor_Full.xcf` i `miasto.ldtk` (submoduł, potem wskaźnik w hoście).
3. **U** — zdecydować, co z 78 cudzymi usunięciami w `assets/.../world_build/`.
4. **S** — usunąć nieśledzoną kopię `pixel_crawler_free.tres` po sprawdzeniu referencji.

## 2. Godziny

5. ✅ **S** — przegląd gry po angielsku (skan danych i scen UI bez polskich znaków; w oknie nikt nie sprawdzał).
6. ✅ **S** — poprawki i18n: klucze `bb.options.bind_*`, imiona bohaterów w EN = nazwy klas (tymczasowo). Zostało: **prawdziwe imiona** (czekają na nazwy usera) i jedna nieszkodliwa kolizja „Kapłan”/Priest.
7. ✅ **S** — pancerz: zmierzony, decyzja usera **„zostaw na razie”** do czasu decyzji o skali drabiny sprzętu (pkt 20).
8. ✅ **S** — `optimize_member_equipment` z MAT/MDF (mag/kapłan → MAT).
10. ✅ **S** — scroll drużyny > 4 w pauzie. Szyk w Status: zostaje osobno (decyzja usera). Okno pytania: już zgodne z życzeniem (najpierw rozszerza się na maks., potem rośnie w górę; może zasłaniać UI).
11. ✅ **S** — stare FAIL-e testów naprawione (`check_combat_lists`, `check_start_safety`, `check_pause_lists`).
12. **U/S** — ikony i tabela mikstur w tierach.

## 3. Pół dnia

13. ✅ **S** — klucze i wytrychy uniwersalne (zrobione 2026-10-11, `kontekst/obiekty.md` „Klucze i wytrychy”).
14. **S** — konwerter LDtk → `TileMapLayer` i zasilenie `town.tscn` (krok do miasta).
15. ✅ **S** — interfejs sklepu (2026-10-21, `kontekst/npc.md`); ceny robocze do czasu pkt 20. Ceny zależą od skali drabiny sprzętu (pkt 20), więc najpierw wspólny szkielet interakcji z NPC (pkt 21–24).
16. **S** — warianty skrzyń z innych paczek i więcej mikstur w jaskiniach.
17. ✅ **S** — zapis map na dysk (`map_disk_cache.gd`, wejście z pliku ≈ 0,25 s zamiast 2–2,5 s). Zostało: zapis po policzeniu mapy z wyprzedzeniem (prefetch), podbijanie `MAP_CACHE_VERSION` w wydaniu, osobne unieważnianie przy usunięciu slotu.
18. **S/O** — skrzynie specjalne w rzadkich pokojach. Nisze out w jaskiniach ✅ (2026-10-21: przedmiot, skrzynia tieru 2 albo sekretny pokój — osobna mapa z 1–3 pokoi, `kontekst/obiekty.md` „Zawartość nisz out”). Zostało: rzadkie pokoje.
19. **S/O** — generator obiektów F5: nakładka podglądu, leniwe sceny. Niszczalne beczki ✅, dźwignie bram ✅ (2026-10-21).

## 4. Dni

20. **O** — krzywe XP do lv 100 i skala drabiny sprzętu (od tego zależą ceny, drop, koszt ulepszeń i wzór pancerza).
21. ✅ **O** — wspólny szkielet interakcji z NPC: usługi sklep / odpoczynek / nauka / rozmowa (2026-10-21, `kontekst/npc.md`). Zostały: kowal, zadania NPC.
22. ✅ **O** — sklep z tierami blokowanymi flagami fabularnymi (mechanizm; flagi to placeholdery).
23. **O** — kowal i bronie z potencjałem.
24. **O** — rekrutacja towarzyszy, ich skille klasowe i sloty umiejętności.
25. **O** — logika miasta: flagi, NPC, wnętrza.
26. **O** — finał: fabuła, zabranie towarzyszy, „Wzmocnienie tarczy”, fazy bossa, umiejętność 10. poziomu.

Odłożone poza inżynierkę: tilesety kolejnych map i dalsze przyspieszanie generatora.

**Następny sensowny krok:** Opus robi szkic ekonomii/drabiny sprzętu (20) i szkielet NPC (21); potem UI scen (15, 22) może zrobić Sonnet albo Antigravity z briefem. Bez blokady: 19 (nakładka podglądu), 16 (warianty skrzyń).
