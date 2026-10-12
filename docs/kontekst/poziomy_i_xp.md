# Poziomy, XP i budżet na 15 map (2026-10-12)

Decyzja usera: **docelowo 15 map; wyczyszczenie 120 % wrogów z każdej mapy (dodatkowe 20 % to wrogowie „z chodzenia”) daje razem
poziom 100.** Jaskinie (mapa 1) szybciej: do lv 8–9. Statystyki „coś pomiędzy” jedną wspólną krzywą a liniową; ekwipunek ma być
bardzo ważny.

## Co jest zrobione (faza 1: XP i poziomy wrogów)
- `PlayerStats.MAX_LEVEL = 100` (krzywe), **`PlayerStats.LEVEL_CAP = 20`** (aktualny limit poziomu — decyzja usera 2026-10-12: limit rośnie z
  rozwojem gry, np. cmentarz = limit na 3 mapy; XP ponad limit przepada). HP bohatera: lv 1 334, **lv 20 1402 jak dotąd** (FNaFB1), dalej
  jedna gładka krzywa (bez załamania w lv 20) do **50 000 na lv 100** (lv 5 ≈ 500, 9 ≈ 690, 40 ≈ 3,9 tys., 60 ≈ 9,4 tys., 80 ≈ 22 tys.; `QuizRpgHeroData.hp_for_level` / `curve_value`: first + B × (e^(k(lvl−1)) − 1) przez trzy punkty, pola
  `hp_ref_level` / `hp_ref_value` / `hp_at_max_level`; SP tą samą funkcją, dziś liniowo); SP 139 -> 1739 (lv 20 nadal 446, koszty umiejętności bez zmian). Krzywa XP: EXP klasy z RPG Makera VX Ace (`QuizRpgHeroData.xp_total_for_level`), do lv 100 ≈ 7,1 mln XP.
- `QuizRpgEnemyXp.kill_xp(level, tier, boss)` = `KILL_FRACTION` (0,08) × XP do następnego poziomu z poziomu wroga × waga
  tieru (1: 0,6, 2: 1,0, 3: 1,6); boss ×`BOSS_MULT` (6). Wróg z `enemy_level` 0 ma stałe `xp_reward` (tutorial).
- Poziom wroga: `enemy_data.enemy_level` / `EnemyBase.set_enemy_level(level, xp_scale)`; mapa nadaje poziomy z companion-JSON
  `"enemy_levels": {"1": [1, 3], "2": [3, 7], "3": [9, 9], "ref_spawns": 32}` (pasmo tieru, poziom deterministycznie z `hash(pozycji)`).
- **Rozmiar mapy:** XP za wroga jest skalowane `ref_spawns / liczba zwykłych spawnów mapy` (0,25–4), więc budżet mapy nie zależy od jej
  wielkości (100×100 … 250×250 dają lv 8,6–9,3 po 120 % wrogów; `tests/diag_cave_xp.gd`). Boss bez skali.
  Pokrętło `enemy_levels.xp_size_exponent` (domyślnie 1,0 = pełna normalizacja, jak dotąd; brak pola = 1,0): skala = (ref_spawns / spawny)^wykładnik,
  zakres 0,25–4, boss bez skali. Wartość < 1 (np. 0,75) = większe mapy dają więcej łącznego XP (100×100 lv 8,2 … 250×250 lv 9,6 po 120 % wrogów
  przy 0,75); do testów w grze: porównać 1,0 i 0,75 (poziom przy bossie, liczba walk i czas między awansami). `EXPO=0.75` w `tests/diag_cave_xp.gd`.
- **Tiery w jaskiniach (decyzja usera 2026-10-12):** boss końcowy = **tier 4** (pokój wyjścia, `fungus_old`, lv 9), a w dalszej części mapy
  kilku **minibossów tier 3** (`fungus_heavy`: 900 HP, 90 / 90, zawsze pojedynczo, lv 8–9; `tier3_from` 0,6, `tier3_chance` 0,2 — od 1 na
  100×100 do ok. 6 na 250×250). Wpis puli `enemies` o indeksie `tier - 1`; poziomy w `enemy_levels` ("3", "4"). Skala XP po rozmiarze mapy
  obejmuje wrogów i minibossów (bez bossa); `ref_spawns` = 34. Wcześniej tier 3 w puli był bossem `fungus_old` (8000 XP) i losowo pojawiał
  się jako zwykły wróg.
- Skan pokazuje poziom wroga „(lv N)”.

## Statystyki wrogów z poziomu (faza 2, krok 1, 2026-10-12)
`QuizRpgEnemyStats` (`scripts/enemies/enemy_stats.gd`): wróg z `enemy_level` > 0 dostaje HP / ATK / DEF dobrane do **bohatera wzorcowego** z jego poziomu
(statystyki z krzywych + ekwipunek idący po krzywej wykładniczej: broń +10 -> +320 ATK, pancerz +14 -> +194 DEF od lv 1 do 100). Zwykły atak wroga zabiera
`HIT_FRAC` maks. HP bohatera (tier 1: 10 %, 2: 14 %, 3: 16 %, 4: 15 %), bohater zabija go w `HITS_TO_KILL` zwykłych trafieniach (1,5 / 4 / 6 / 12),
DEF wroga = 0,7 × ATK bohatera. ATK = MAT, DEF = MDF. Odmiany (np. nietoperz z mniejszym HP) zachowują stosunek do bazy tieru (`TIER_BASE` = dotychczasowe 100 / 400 /
900 / 2500). Poziom 0 (tutorial) zostaje przy statystykach z danych. Tabela: `tests/diag_enemy_stats.gd`; test `check_enemy_stats`.
- **Waga ekwipunku:** bohater bez ekwipunku wzorcowego jest wyraźnie słabszy (lv 20: wróg tieru 2 zabiera 17 % HP zamiast 14 %, a bohater zabija go w 6,5 trafieniach zamiast 4;
  lv 100 bez ekwipunku praktycznie nie zabije nikogo). Parametry krzywej ekwipunku (`GEAR_*`) to pokrętło „jak ważny jest ekwipunek”.
- **Naprawiony błąd z fazy 1:** `set_enemy_level` było wołane przed `add_child`, a `_ready` wczytywał `enemy_data` i **nadpisywał** poziom, XP i statystyki — wrogowie
  z `enemy_data` (pixel_crawler) mieli więc stałe XP, a poziom z mapy działał tylko dla wrogów bez `enemy_data` (slime). Poziom jest teraz zapamiętany i nakładany po wczytaniu
  danych (`_apply_spawn_level`).
- **Uwaga — skille wrogów:** umiejętności z dużą stałą bazą (np. +200 w Relentless Assault) nie skalują się z poziomem; do przeglądu przy strojeniu map 2+.

## Budżet 15 map (hero lv po 120 % wrogów; ok. 72 zabić na mapę)
Mapa 1 kończy na lv 8,5, dalsze równo do lv 100 (~6,5 poziomu na mapę). XP wroga ≈ 8–9 % XP do następnego poziomu — dlatego jedna stała
`KILL_FRACTION` obsługuje wszystkie mapy; trzeba tylko nadać wrogom poziomy z pasma mapy.

| Mapa | poziom bohatera (start -> koniec) | XP / mapa @120 % |
|---|---|---|
| 1 | 1,0 -> 8,5 | 6 505 |
| 2 | 8,5 -> 15,0 | 30 104 |
| 3 | 15,0 -> 21,6 | 73 003 |
| 4 | 21,6 -> 28,1 | 132 349 |
| 5 | 28,1 -> 34,6 | 205 856 |
| 6 | 34,6 -> 41,2 | 288 787 |
| 7 | 41,2 -> 47,7 | 377 981 |
| 8 | 47,7 -> 54,2 | 469 192 |
| 9 | 54,2 -> 60,8 | 559 573 |
| 10 | 60,8 -> 67,3 | 646 637 |
| 11 | 67,3 -> 73,9 | 728 327 |
| 12 | 73,9 -> 80,4 | 804 015 |
| 13 | 80,4 -> 86,9 | 872 369 |
| 14 | 86,9 -> 93,5 | 934 102 |
| 15 | 93,5 -> 100,0 | 988 351 |

Pasma poziomów wrogów dla kolejnej mapy: tier 1 = początek mapy .. +1/3 zakresu, tier 2 = środek .. koniec, boss = poziom końca mapy.

## Do zrobienia (faza 2, Opus)
- ~~**Statystyki wrogów z poziomu**~~ — zrobione (sekcja wyżej). Pierwotny opis: generator z krzywej: HP / ATK / DEF z `enemy_level` i archetypu; tiery jako mnożniki, tak
  żeby proporcje walki z `backlog_druzyna_balans.md` S5 (cios wroga ≈ 14 % HP bohatera, bohater zabija w 3–4 trafieniach) trzymały się
  na każdej mapie. Dziś staty wrogów są stałe (tiery 1–4 z S5) — poziom wpływa tylko na XP.
- **Krzywe bohatera do lv 100:** ATK +1,95 / DEF +1,1 na poziom (lv 100 ≈ 214 / 120 bez ekwipunku) vs ekwipunek +320 ATK / +192 DEF —
  przemyśleć wagę ekwipunku (decyzja usera: bardzo ważny), tiery przedmiotów na 15 map, sklepy.
- **Poziomy umiejętności z poziomu bohatera** (dziś uczone na lv 1 / 5 / 10 / 15 / 20 — rozciągnąć na 100).
- Tutorial: wrogowie mają stałe XP (enemy_level 0); upewnić się, że tutorial + jaskinie dają łącznie lv 8–9.

## Status celu „120 %” i test w grze (2026-10-12)
- „120 % wrogów = lv 100” to **scenariusz kalkulacji budżetu**, a nie wymaganie wobec gracza (nie trzeba czyścić map). `KILL_FRACTION` zostaje 0,08
  do pierwszego przejścia jaskiń; zmiana na ok. 0,107 (90 %) / 0,128 (75 %) to tylko proporcjonalne przeliczenie nagród i nie gwarantuje celu
  (zależy, których wrogów gracz pokona: poziomy, tiery, boss ×6, tutorial ze stałym XP) — po zmianie trzeba przeliczyć budżet ponownie.
- **Test:** przejść jaskinie naturalnie (zaglądać do odnóg, nie wracać po pominiętych wrogów), przy bossie zapisać: poziom bohatera, liczbę
  walk, czas przejścia, odstępy między awansami. Pytania: czy boss jest do pokonania bez grindu, czy awanse dają satysfakcję, czy
  męczy raczej liczba / długość / powtarzalność walk (wtedy więcej XP nie pomoże, trzeba ruszyć liczbę spotkań). Nie ma pomiarów, ile
  mapy gracze czyszczą — nie zakładać „60–80 %”.
- **Log progresji do testów** (`QuizRpgProgressLog`, `scripts/tools/progress_log.gd`; działa też w buildzie bez debugu): `user://progress_log.txt`
  (Windows: `%APPDATA%\Godot\app_userdata\Artefakt Wiedzy Modular\progress_log.txt`), dopisywany. Wpisy: start sesji, wejście na mapę
  i podsumowanie poprzedniej, każda walka (wygrana / ucieczka / porażka, wrogowie z poziomem i tierem, XP, tury, czas, numer walki, BOSS) i
  awans (ile walk i czasu od poprzedniego awansu). Linia: `[czas sesji] Lv (XP/następny) HP | zdarzenie | szczegóły`. Testerzy odsyłają plik —
  z niego widać poziom przy bossie, liczbę walk i odstępy między awansami. Test `check_progress_log`.
  Podsumowanie w tabelę (mapy, walki W / U / P, XP, poziom na wejściu i wyjściu, bossowie, awanse): `python modules/quiz_rpg/tools/progress_summary.py plik1.txt [plik2.txt …]` (po jednym pliku od każdego testera).
