# Backlog: drużyna, balans, umiejętności (stan 2026-10-11)

> **Następny etap po tym backlogu: miasto / hub** (priorytet usera 2026-10-11) — opis w `znane_problemy.md` „(5) miasto z modularnych zasobów paczki free”.

Gałąź CienMgly: `druzyna-balans` (niezmergowana). Podział: **S** = Sonnet (mechaniczne), **G** = Gemini (dane / teksty), **O** = Opus (projekt, zmiany przekrojowe).

## Zrobione (skrót)
HP bohatera 334 → 1402 (lv 1–20), XP 100 × L^1.5, staty ATK / DEF / MAT / MDF, walka ATK×4 − DEF×2, wspólny model umiejętności i statusów
(`QuizRpgSkillBase`, `QuizRpgStatusData`), skille bohatera (CC z poziomów 5 / 10 / 15, FM do nauczenia przez NPC), przedmioty tierów ×2,
18 statusów, umiejętności wrogów (tier − 1, boss 3), obrona 1/4 (dobra odpowiedź) / 1/2 (zła), wróg tieru 1 = 100 HP, ogólne nazwy skilli.

## Do zrobienia
**S — mechaniczne**
1. ~~Statusy w wierszach drużyny w walce~~ — zrobione 2026-10-11 (`StatusLabel`).
2. ~~Typy broni~~ — zrobione 2026-10-11: `weapon_type` (none, sword, dagger, axe, spear, mace, staff, bow — wg arkuszy broni z paczek Pixel Crawler) w przedmiotach, `required_weapon_type` i `consumes_weapon` w umiejętnościach; nowy skill Ostatni Zamach (wymaga miecza, niszczy go).
3. ~~Odporność 50 % na statusy podczas obrony~~ — zrobione 2026-10-11.
4. ~~Dokumentacja obrony w `walka.md`~~ — zrobione 2026-10-11 (skille / statusy FNaFB3 do opisania).
5. Strojenie tierów 2–4 względem CC (Party Hat β / γ / Ω: 400 / 1200 / 2400 HP) po sprawdzeniu w grze.
6. Przejrzeć skille sojuszników od Gemini (wartości, `learn_level`), sprawdzić obsługę statusów FNaFB3 (obłęd, urok, prowokacja) w walce.
7. ~~Niepodpięte skille wrogów~~ — przeskalowane 2026-10-11 do poziomu skilli bossa (Wirujące Cięcie ≈ 1350 przy ATK 150 / DEF 50): Szał Natarcia ×0,3 (8 trafień ≈ 1200), Nieustępliwy Szturm ×0,45 (6 ≈ 1080), Miażdżący Cios = wartości z FNaFB (Golden Bash: 25000 stałych, 16 % trafienia, rozrzut 100 %) — decyzja usera: na bossa strzegącego fragmentu, gdzie i tak będzie inflacja HP; do tego czasu nie podpinać. Wciąż niepodpięte do żadnego wroga — do decyzji, komu je dać.

**O — projekt**
1. **Skalowanie tierów przy kilkunastu mapach:** `enemy_level` + archetypy + krzywa XP + generator `.tres` (patrz `znane_problemy.md`).
2. AGI i kolejność tur (z statusami AGI w górę / w dół; TODO w `game_design.md`), „zawsze rusza ostatni” (Marsz / Usypiająca Melodia), Dzielenie Tempa naprawdę na AGI.
   - **Opis zadania dla Opusa (2026-10-11), unik / pudło / blok:** dziś zwykły atak wroga trafia ZAWSZE (pudłuje tylko przy statusach
     z `hit_mult`: Oślepienie ×0,4, Przestrach ×0,75; „Unik!” w `_enemy_turn`), bohater nie ma uniku ani losowego bloku
     (jest tylko akcja Obrona: obrażenia ×0,25 po dobrej odpowiedzi / ×0,5 po złej; `can_be_blocked = false` ją omija).
     Szansa trafienia bohatera: 0,8 po dobrej / 0,2 po złej odpowiedzi (`ATTACK_HIT_CHANCE_*`, × `member_hit_mult`).
     Do zaprojektowania razem z AGI: szansa wroga na pudło i bohatera na unik / blok z AGI (a nie stała), wpływ statusów
     AGI w górę / w dół, kolejność tur, „zawsze rusza ostatni” (Marsz / Usypiająca Melodia), Dzielenie Tempa naprawdę na AGI,
     skalowanie względem inflacji HP przy strażnikach (Miażdżący Cios 25000 / 16 % jak w FNaFB). Miejsca w kodzie:
     `quiz_combat_controller.gd` (`_enemy_turn`, `_enemy_use_skill`, `_resolve_attack`), `QuizRpgSkillMath.roll_hit`, `QuizRpgStatusData.hit_mult`.
3. Combo (TP 100, serie pytań), umiejętność „raz na walkę” (Death Inhale z lv 20).
4. Poziomy umiejętności od użyć (jak FNaFB3: 20 użyć → LV2, +30 → MAX) — też jako remedium na dryf siły skilli względem zwykłego ataku.
5. Przywołania, towarzysze (skład, role, pule HP, wybór sojusznika kursorem w walce), sklep / nauczyciele umiejętności (NPC, którym wracają wspomnienia).
6. Klucze i wytrychy uniwersalne (przedmioty otwierające dowolną skrzynię; `znane_problemy.md`).
7. Nazwy jako zmienne / stałe + tłumaczenia w JSON (`znane_problemy.md`).

**G — dane / teksty**
- Pozostałe skille postaci (Bonnie / Chica / Foxy / BB) z `F:\Programy\GitHub\fnafb_skille\` jako `.tres` w ogólnych nazwach (nie nazwy FNaFB — specyficzne dla serii).
- Pytania quizowe, dialogi NPC, opisy przedmiotów, prompty teł walki.

## Zasady
- Nazwy umiejętności / statusów **ogólne**, nie z FNaFB (specyficzne dla serii).
- Wzór liczb: FNaFB1 FM; skille bazowe z CC; koszt w CC bywa w notatce `<Custom MP Cost>`, nie w `mpCost`.
- Dane FNaFB tylko do odczytu; commit osobno dla każdej zmiany, submoduł pierwszy, potem wskaźnik hosta.

## UI (2026-10-11)
- Zrobione: ramki sekcji `QuizFrame` w panelach menu pauzy (motyw st_* = tekstura z paczki UI; klasyczny = obrys), opcja „Menu pauzy tylko na szerokość treści”.
- ~~UI walki — umiejętności nie powinny wymuszać pełnej szerokości~~ — zrobione 2026-10-11 (walka.md „Zmiany 2026-10-11”).
- Niestabilny test lokalny: `diag_enemy_chase` (tutorial_area) waha się 200–600 / 3000 przy progu 600 (losowe wałęsanie).
