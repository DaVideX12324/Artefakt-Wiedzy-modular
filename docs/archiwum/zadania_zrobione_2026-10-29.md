# Zadania zrobione / anulowane — przeniesione 2026-10-29

> Źródło: `docs/kontekst/zadania_wg_trudnosci.md`. Wpisy ✅ i ✖ per 2026-10-29.

## Minuty

3. ✅ **U** — `world_build` przywrócony do `assets/_nieuzywane/` (2026-10-22, assets `1c92671`).
4. ✅ **S** — nieśledzona kopia `pixel_crawler_free.tres` usunięta (sprawdzone 2026-10-22).

## Godziny

5. ✅ **S** — przegląd gry po angielsku (skan danych i scen UI).
6. ✅ **S** — poprawki i18n: klucze `bb.options.bind_*`, imiona bohaterów (Kael, Eldon, Selene — EN = PL), kolizje msgid usunięte (2026-10-21).
7. ✅ **S** — pancerz zmierzony, decyzja usera „zostaw na razie" do czasu drabiny sprzętu.
8. ✅ **S** — `optimize_member_equipment` z MAT/MDF.
10. ✅ **S** — scroll drużyny > 4 w pauzie; okno pytania: najpierw max, potem rośnie w górę.
11. ✅ **S** — stare FAIL-e testów naprawione (`check_combat_lists`, `check_start_safety`, `check_pause_lists`).
12. ✅ **U/S** — tabela mikstur w tierach (2026-10-21), ikony Kyrise 16x16 CC BY 4.0 (2026-10-22).

## Pół dnia

13. ✅ **S** — klucze i wytrychy uniwersalne (2026-10-11, `kontekst/obiekty.md`).
14. ✖ ~~konwerter LDtk → `TileMapLayer`~~ — odpada (2026-10-22, miasto w Godocie bezpośrednio).
15. ✅ **S** — interfejs sklepu (2026-10-21, `kontekst/npc.md`); ceny robocze do czasu pkt 20.
17. ✅ **S** — zapis map na dysk `map_disk_cache.gd` ≈ 0,25 s; zapis z wyprzedzeniem (2026-10-22).
18. ✅ **S/O** — skrzynie specjalne w rzadkich pokojach (tier 3, 2026-10-21). Nisze out: przedmiot / skrzynia t2 / sekretny pokój; krypta relikwii z bossem (2026-10-21).
19. ✅ **S/O** — generator obiektów F5: beczki, dźwignie, nakładka podglądu (2026-10-21).

## Dni

20. ✅ **O** — krzywe XP do lv 100 i skala drabiny sprzętu jak FNaFB1 (2026-10-21, `ekwipunek_szkic.md` sekcja 12).
21. ✅ **O** — wspólny szkielet interakcji z NPC (2026-10-21, `kontekst/npc.md`).
22. ✅ **O** — sklep z tierami blokowanymi flagami fabularnymi (mechanizm; flagi to placeholdery).
23. ✅ **O** — kowal i Ostrze Mgły (2026-10-21, `kontekst/npc.md`).
24. ✅ **O** — rekrutacja towarzyszy, skille klasowe, sloty umiejętności (2026-10-21, `druzyna_szkic.md`, `sloty_umiejetnosci_szkic.md`).
27. ✅ **S/O** — uproszczone zakończenie na inżynierkę: boss ścieków z `ends_game: true`, ekran `end_screen.tscn`, flaga `game:completed`, „Ukończono" w slocie, test `check_end_screen` (2026-10-22).

## Z znanych problemów — wpisy ✅

- ✅ **S** — zduplikowany UID ikony BitBombera (`icon.png.import` ma własny UID, 2026-10-21).
- ✅ **S** — resztki i18n: etapy generowania (`gen.stage.*`) doszły; zostają tylko narzędzia i debug (2026-10-21).
- ✅ **S/O** — umiejętności wrogów skalowane z poziomu (ATK/MAT, Mroczna Regeneracja 25 % maks. HP, 2026-10-21).
- ✅ **O** — minimapa z fog of war (2026-10-21): róg + pełna mapa pod M, linia wzroku, maska w zapisie.
- ✅ **O** — losowe spotkania jak w JRPG: tryb `cleared` w jaskiniach, `always` w ściekach (2026-10-21).
