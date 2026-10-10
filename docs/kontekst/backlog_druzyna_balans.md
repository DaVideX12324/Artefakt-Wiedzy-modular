# Backlog: drużyna, balans, umiejętności (stan 2026-10-11)

Gałąź CienMgly: `druzyna-balans` (niezmergowana). Podział: **S** = Sonnet (mechaniczne), **G** = Gemini (dane / teksty), **O** = Opus (projekt, zmiany przekrojowe).

## Zrobione (skrót)
HP bohatera 334 → 1402 (lv 1–20), XP 100 × L^1.5, staty ATK / DEF / MAT / MDF, walka ATK×4 − DEF×2, wspólny model umiejętności i statusów
(`QuizRpgSkillBase`, `QuizRpgStatusData`), skille bohatera (CC z poziomów 5 / 10 / 15, FM do nauczenia przez NPC), przedmioty tierów ×2,
18 statusów, umiejętności wrogów (tier − 1, boss 3), obrona 1/4 (dobra odpowiedź) / 1/2 (zła), wróg tieru 1 = 100 HP, ogólne nazwy skilli.

## Do zrobienia
**S — mechaniczne**
1. Statusy w wierszach drużyny w walce (krótka nazwa / ikona przy postaci).
2. Typy broni: `weapon_type` w przedmiotach, `required_weapon_type` i `consumes_weapon` w umiejętnościach (mikrofon do Przeszywającego Krzyku, gitara do skilla z gitary).
3. Odporność 50 % na statusy podczas obrony (jak Guard w FNaFB; w `_inflict_status`).
4. Dokumentacja obrony (1/4 / 1/2) i nowych skilli / statusów w `walka.md`.
5. Strojenie tierów 2–4 względem CC (Party Hat β / γ / Ω: 400 / 1200 / 2400 HP) po sprawdzeniu w grze.
6. Przejrzeć skille sojuszników od Gemini (wartości, `learn_level`), sprawdzić obsługę statusów FNaFB3 (obłęd, urok, prowokacja) w walce.
7. Niepodpięte skille wrogów (Miażdżący Cios, Szał Natarcia, Nieustępliwy Szturm) — zbyt mocne; decyzja: boss z limitem trafień albo przeskalować.

**O — projekt**
1. **Skalowanie tierów przy kilkunastu mapach:** `enemy_level` + archetypy + krzywa XP + generator `.tres` (patrz `znane_problemy.md`).
2. AGI i kolejność tur (z statusami AGI w górę / w dół; TODO w `game_design.md`), „zawsze rusza ostatni” (Marsz / Usypiająca Melodia), Dzielenie Tempa naprawdę na AGI.
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
