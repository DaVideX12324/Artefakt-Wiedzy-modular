# Poziomy, XP i budżet na 15 map (2026-10-12)

Decyzja usera: **docelowo 15 map; wyczyszczenie 120 % wrogów z każdej mapy (dodatkowe 20 % to wrogowie „z chodzenia”) daje razem
poziom 100.** Jaskinie (mapa 1) szybciej: do lv 8–9. Statystyki „coś pomiędzy” jedną wspólną krzywą a liniową; ekwipunek ma być
bardzo ważny.

## Co jest zrobione (faza 1: XP i poziomy wrogów)
- `PlayerStats.MAX_LEVEL = 100`; HP bohatera liniowo 334 -> 5000 (lv 20 ≈ 1230); SP 139 -> 1739 (lv 20 nadal 446, koszty
  umiejętności bez zmian). Krzywa XP: EXP klasy z RPG Makera VX Ace (`QuizRpgHeroData.xp_total_for_level`), do lv 100 ≈ 7,1 mln XP.
- `QuizRpgEnemyXp.kill_xp(level, tier, boss)` = `KILL_FRACTION` (0,08) × XP do następnego poziomu z poziomu wroga × waga
  tieru (1: 0,6, 2: 1,0, 3: 1,6); boss ×`BOSS_MULT` (6). Wróg z `enemy_level` 0 ma stałe `xp_reward` (tutorial).
- Poziom wroga: `enemy_data.enemy_level` / `EnemyBase.set_enemy_level(level, xp_scale)`; mapa nadaje poziomy z companion-JSON
  `"enemy_levels": {"1": [1, 3], "2": [3, 7], "3": [9, 9], "ref_spawns": 32}` (pasmo tieru, poziom deterministycznie z `hash(pozycji)`).
- **Rozmiar mapy:** XP za wroga jest skalowane `ref_spawns / liczba zwykłych spawnów mapy` (0,25–4), więc budżet mapy nie zależy od jej
  wielkości (100×100 … 250×250 dają lv 8,3–9,0 po 120 % wrogów; `tests/diag_cave_xp.gd`). Boss bez skali.
- Jaskinie: `tier3_chance` = 0 (wcześniej 15 % dalszych spawnów to był boss `fungus_old` z 8000 XP; boss tylko w pokoju wyjścia).
- Skan pokazuje poziom wroga „(lv N)”.

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
- **Statystyki wrogów z poziomu** (generator `.tres` z krzywej: HP / ATK / DEF z `enemy_level` i archetypu; tiery jako mnożniki), tak
  żeby proporcje walki z `backlog_druzyna_balans.md` S5 (cios wroga ≈ 14 % HP bohatera, bohater zabija w 3–4 trafieniach) trzymały się
  na każdej mapie. Dziś staty wrogów są stałe (tiery 1–4 z S5) — poziom wpływa tylko na XP.
- **Krzywe bohatera do lv 100:** ATK +1,95 / DEF +1,1 na poziom (lv 100 ≈ 214 / 120 bez ekwipunku) vs ekwipunek +320 ATK / +192 DEF —
  przemyśleć wagę ekwipunku (decyzja usera: bardzo ważny), tiery przedmiotów na 15 map, sklepy.
- **Poziomy umiejętności z poziomu bohatera** (dziś uczone na lv 1 / 5 / 10 / 15 / 20 — rozciągnąć na 100).
- Tutorial: wrogowie mają stałe XP (enemy_level 0); upewnić się, że tutorial + jaskinie dają łącznie lv 8–9.
