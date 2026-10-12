# Zadania od najłatwiejszych / najszybszych

> Widok pomocniczy, **nie** źródło prawdy — szczegóły i statusy: [`docs/znane_problemy.md`](../znane_problemy.md). Stan na 2026-10-13.
> Skróty: **U** = robi user (gra/LDtk/grafika), **G** = nadaje się dla Gemini/Antigravity (brief w docs), **S** = Sonnet wystarczy, **O** = lepiej Opus (projekt/architektura).

## 1. Minuty (sprawdzenia i drobiazgi)

1. **U** — otworzyć `miasto.ldtk` w LDtk, zamalować próbkę trawy/kamienia/ziemi/cegieł (zwykłe i flat), sprawdzić wynik reguł; zgłosić, który kafel cegieł nie pasuje.
2. **U** — zdecydować, co z 78 cudzymi usunięciami w `assets/pixel_crawler/environments/world_build/` (przywrócić albo skomitować).
3. **U** — skomitować `Floor_Full.xcf` i `miasto.ldtk` (submoduł: commit + push, potem wskaźnik w hoście).
4. **U** — sprawdzić w grze: ekran śmierci + trucizna, wygląd skrzyń i klucze na tier, beczki 3/(2n), złoto, koszt walki (~70 % HP na parę wrogów), zakładka „Ogólne” w opcjach, klik po odzyskaniu fokusu, build wydaniowy bez narzędzi dev.
5. **S** — usunąć nieśledzoną kopię `modules/quiz_rpg/resources/maps/pixel_crawler_free.tres` po sprawdzeniu referencji (`grep`).
6. **S** — odebrać i zweryfikować pracę Gemini: zadanie E (porządkowanie `docs/` — `sh .claude/hooks/przypomnienia.sh`, linki, `git diff --stat`, commit) i D (teksty logu wrogów `skill.<plik>.log`).

## 2. Godziny (jasno określone, małe ryzyko)

7. **G/S** — teksty logu wrogów i opisy i18n (briefy `i18n_log_wrogow_dla_gemini.md`, `i18n_opisy_dla_gemini.md`).
8. **U** — Snow i Sand: reguły autotile w LDtk przy ich mapach (analogicznie do Grass/Stone; dodać wartość IntGrid `Sand`).
9. **S** — poprawka pancerza: cios wroga liczony z ułamka HP, przez co DEF prawie nie wpływa późno (`enemy_stats.gd`, opis w `znane_problemy.md`).
10. **S** — `optimize_member_equipment` uwzględniający MAT/MDF i efekty (dziś tylko ATK + DEF).
11. **U/S** — ikony mikstur (user) i tabela mikstur w tierach ze stałymi wartościami (`ekwipunek_szkic.md`, sekcja 9) po teście w grze.
12. **S** — aktualizacja `miasto_makieta.ldtk` względem nowych warstw/reguł (opcjonalne).
13. **S** — szkielety scen wnętrz budynków (osobna scena na budynek, wyjście do `town.tscn`).

## 3. Pół dnia (wymaga uwagi, schemat znany)

14. **S** — konwerter LDtk JSON → `TileMapLayer` (`pixel_crawler_free.tres`) + encje → węzły gry; test headless; zasilenie `town.tscn` (wzorzec `cave.tscn`: spawn, wyjścia, kolizje z `Kolizje` + `Sciany`).
15. **S** — interfejs zakupu w sklepie (po mieście; dotąd menu deweloperskie), ceny w „zabiciach” (pełne leczenie ≈ 1,2–1,3 × złoto z wroga).
16. **S** — dodatkowe warianty skrzyń z innych paczek (zielona, czerwona, ozdobna, pustynia).
17. **S/O** — skrzynie specjalne w rzadkich pomieszczeniach/niszach: znacznik „rzadki pokój” w generatorze obiektów, osobny `chest_tier`/tabela łupu, ewent. klucz wyższego tieru.
18. **S** — więcej mikstur w jaskiniach (beczki, skrzynie, wrogowie) po teście.

## 4. Dni (projekt, balans, architektura — Opus po resecie limitu)

19. **O** — krzywe XP i bohatera do lv 100 oraz skala drabiny sprzętu (`ekwipunek_szkic.md`, sekcja 11: pułap sklepu ≈ 600 ATK / mniejszy wzrost z poziomu / bez zmian); skalowanie wrogów przy ~15 mapach.
20. **O** — sklep + tiery blokowane flagami fabularnymi (`LevelStateManager.register_device_progress`).
21. **O** — kowal: bronie z potencjałem (etapy jako osobne `item_id`, `upgrade_to`, koszt, pole `budget_map`, test limitu mapa + 2), sekretne bronie ponad budżet.
22. **O** — rekrutacja towarzyszy (Łotrzyk, Mag, Kapłan), zadania fabularne, skille klasowe Maga i Łotrzyka; sloty umiejętności, 4 tiery (`sloty_umiejetnosci_szkic.md`).
23. **O** — logika miasta/hub: flagi, odblokowanie po wyjściu z jaskiń, NPC, wnętrza budynków.
24. **O** — generator obiektów, faza F5: dźwignie, niszczalne sceny, nakładka podglądu (`plan_generator_obiektow.md`).
25. **O** — generator ścieków na poziomie makiet autora (`plan_generator_sciekow.md`, fazy F0–F7), winiety; schody N/E/W i rury robi user.
26. Merge `druzyna-balans` → `main` — **tylko na polecenie usera**.
