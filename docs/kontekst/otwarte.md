# Otwarte sprawy i handoff sesji

> **Rola tego pliku:** zwięzłe przekazanie stanu bieżącej sesji (handoff) — co zrobiono w ostatniej sesji, kluczowe decyzje usera oraz najbliższe kroki.
> **Uwaga:** Pełna lista błędów, zadań i zaległości (single source of truth) znajduje się w [`docs/znane_problemy.md`](../znane_problemy.md). Archiwum historycznych notatek z sesji do 2026-10-12 przeniesiono do [`docs/archiwum/otwarte_do_2026-10-12.md`](../archiwum/otwarte_do_2026-10-12.md).

---

## Sesja 2026-10-12 (część 3): ekwipunek, złoto, klucze — stan i do podjęcia

Szkic i decyzje: `ekwipunek_szkic.md` (sekcje 8–11), obiekty: `obiekty.md`.

**Zrobione (prototyp w jaskiniach):** klasy postaci (`character_class`, `allowed_classes`); złoto (`PlayerStats.gold`, złoto z wrogów od tutorialu, wpis w logu); tabele łupu z JSON mapy (`chest_loot`, `enemy_loot`) w jaskiniach i ściekach;
beczki z wzorem 3/(2n) (1. przedmiot gwarantowany); klucze na tier skrzyni (brązowy / srebrny / szafirowy / złoty = uniwersalny) i wygląd skrzyń wg tieru; język i „Gra bez quizów” w zakładce „Ogólne” opcji.

**Decyzje usera (część 3):** sklepy po odblokowaniu miasta (wyjście z jaskiń), tiery sprzętu w sklepie blokowane flagami fabularnymi (kowal „nie pamięta”); w jaskiniach sprzęt z dropów wrogów i skrzyń / nisz; złoto od tutorialu;
większość złota idzie na mikstury HP / SP (stałe wartości, nie %; walka z 2 wrogami ≈ 70 % HP); rzadki drop = broń z potencjałem, moc początkowa ≤ mapa + 2, rozwój u kowala; beczki: 1. przedmiot pewny, kolejne wg 3/(2n).

**Do podjęcia (ekwipunek i skrzynie):**
- **Skrzynie specjalne w rzadkich pomieszczeniach / niszach** (pomysł usera; **nie dodane**): rzadkie pokoje z wyższym tierem skrzyni (np. 3–4, wygląd złoty / niebieski, ewent. skrzynia z czaszką z arkusza „RPG Chests” kolumna 8 jako przeklęta), z lepszym łupem
  (sprzęt tieru 2, później broń z potencjałem). Wymaga: znacznika „rzadki pokój / nisza” w generatorze obiektów (dziś skrzynie tylko preferują nisze, `objects_caves.json`), osobnego `chest_tier` / tabeli łupu dla takiej skrzyni, ewent. wymogu klucza wyższego tieru.
- Sklep i interfejs zakupu (po mieście; do czasu miasta w menu deweloperskim), tiery sklepu z flagami fabularnymi (`LevelStateManager.register_device_progress`), ceny w „zabiciach” (pełne leczenie ≈ 1,2–1,3 × złoto z wroga).
- Mikstury w kolejnych tierach ze stałymi wartościami (tabela w `ekwipunek_szkic.md`, sekcja 9) i ich ikony (user); więcej mikstur w jaskiniach (beczki, skrzynie, wrogowie) po teście w grze.
- Bronie z potencjałem: etapy jako osobne `item_id`, `upgrade_to`, flagi i koszt ulepszeń u kowala, pole `budget_map` + test limitu mapa + 2; sekretne bronie ponad budżet (osobna decyzja); skala drabiny sprzętu przy 100 poziomach (pułap sklepu ≈ 600 ATK / zmniejszenie wzrostu z poziomu / bez zmian) — pytanie otwarte w szkicu.
- Poprawka: pancerz prawie nie wpływa na przeżywalność późno (cios wroga liczony z ułamka HP) — przejrzeć definicję w `enemy_stats.gd` niezależnie od reszty (szczegóły w `docs/znane_problemy.md`).
- Optymalizacja ekwipunku (`optimize_member_equipment`) liczy tylko ATK + DEF (pomija MAT / MDF i efekty; szczegóły w `docs/znane_problemy.md`).
- Ewent.: osobne warianty skrzyń z innych paczek (zielona, czerwona, ozdobna z „RPG Chests”; `All Chest Sheet.png` 16×16; pustynia `Props.png`).
- Sprawdzić w grze: czterokrotnie większy łup z beczek (średnio ≈ 2,3 losowania zamiast 0,45), wygląd skrzyń wg tieru i koszt walki (≈ 70 % HP) w jaskiniach.

**Dopisek na koniec sesji 2026-10-12 (po części 3):**
- **Zrobione dodatkowo:** narzędzia deweloperskie tylko w buildzie debugowym i **tylko klawisze F** (F9 / F10 / F11, F1 / `~`; litery K / O / P usunięte — decyzja usera); walka ignoruje mysz bez fokusu okna i klik odzyskujący fokus (300 ms po `FOCUS_IN`);
  przegląd i aktualizacja stanów w `docs/znane_problemy.md` (linie `Stan 2026-10-12` przy punktach).
- **Czeka na Gemini:** brief `porzadkowanie_docs_dla_gemini.md` (zadanie E w `zadania_dla_antigravity.md`): uporządkowanie `docs/` — `znane_problemy.md` = jedyne źródło todo i problemów (hook czyta nagłówki `### ⚠ WAŻNE:`), `otwarte.md` = tylko handoff,
  indeksy `docs/README.md` i `kontekst/README.md`, `docs/archiwum/`, statusy planów, raport. Po oddaniu: sprawdzić hook (`sh .claude/hooks/przypomnienia.sh`), linki, `git diff --stat`, potem commit. Zadanie D: teksty logu wrogów (`i18n_log_wrogow_dla_gemini.md`).
- **Najbliższe kroki (Claude):** po resecie limitu — krzywe XP i bohatera do lv 100 oraz skala drabiny sprzętu (pytanie otwarte w `ekwipunek_szkic.md`, sekcja 11: pułap sklepu ≈ 600 ATK / mniejszy wzrost z poziomu / bez zmian), potem sklep i tiery z flagami fabularnymi, mikstury w tierach (stałe wartości), bronie z potencjałem i kowal, rekrutacja towarzyszy.
- **Do sprawdzenia przez usera w grze:** wygląd skrzyń i klucze na tier, beczki 3 / (2n), złoto, koszt walki w jaskiniach (≈ 70 % HP na parę wrogów), zakładka „Ogólne” w opcjach, klik po odzyskaniu fokusu, build wydaniowy bez narzędzi deweloperskich.
- **Repo:** host `main` i submoduł `modules/quiz_rpg` (CienMgly, gałąź `druzyna-balans`) czyste i wypchnięte; merge `druzyna-balans` do `main` dopiero na polecenie usera.

---

## Decyzje usera, których nie ma gdzie indziej

1. **Sloty umiejętności:**
   - 4 tiery slotów na razie (tier 9 zarezerwowany dla arcymaga w true endingu).
   - Poziom umiejętności = tier slotu, w którym jest osadzona; tier startowy umiejętności jest dolną granicą (nie można włożyć skilla T2 do slotu T1).
   - Wspólny budżet jednostek (propozycja: T1 = 1, T2 = 2, T3 = 3, T4 = 5).
   - Umiejętność „Skan” oraz „Tryb combo” pozostają poza budżetem slotów.
   - Combo = osobny tryb po osiągnięciu 100 TP (serie umiejętności za SP, bez używania skilli TP), odblokowywany specjalnymi warunkami (rzadki drop / opanowanie maks. umiejętności / specjalny boss), nigdy z poziomu ani od zwykłego NPC.
   - Akcesoria mogą modyfikować liczbę slotów; blokady fabularne zamku sprawdzają sam fakt opanowania umiejętności, a nie jej przypisanie do slotu.
   - Szczegóły: [`docs/kontekst/sloty_umiejetnosci_szkic.md`](sloty_umiejetnosci_szkic.md).

2. **Drużyna i progresja towarzyszy:**
   - Role oparte o klasy postaci ([`docs/kontekst/klasy_postaci_i_bronie.md`](klasy_postaci_i_bronie.md): Wojownik, Łotrzyk, Mag, Kapłan).
   - Dołączanie towarzyszy następuje po wykonaniu zadania fabularnego; wstępnie 3 towarzyszy (Łotrzyk, Mag, Kapłan).
   - Każdy członek ma własną pulę XP i poziom; aktywni otrzymują pełne XP (wzorem FNaFB), polegli w walce dostają 50 % XP.
   - Cała drużyna bierze udział w walce (brak limitu w prototypie; rezerwa na późniejszym etapie).
   - Brak sztucznych premii nadrabiania zaległości; poziom odniesienia = najwyższy w drużynie; poziom wroga skalowany jest z mapy, a nie z poziomu gracza.
   - Szczegóły: [`docs/kontekst/druzyna_szkic.md`](druzyna_szkic.md).

3. **Walka i mechanika obrony:**
   - Blok / unik / pudło: unik bazuje na statystyce AGI; blok = 100 % szansy na unik przy określonych warunkach.
   - Koszty umiejętności (ze szkicu S6 i docx) są wartościami wstępnymi/tymczasowymi do pełnego skalowania do lv 100.

4. **Narzędzia i środowisko developerskie:**
   - Narzędzia deweloperskie i cheaty dostępne wyłącznie w buildzie debugowym (`OS.is_debug_build()`).
   - Skróty klawiszowe ograniczone wyłącznie do klawiszy funkcyjnych F (F1, F9, F10, F11, `~`). Litery K, O, P usunięte z globalnej obsługi skrótów.

5. **Organizacja pracy i delegowanie zadań:**
   - Proste, powtarzalne lub obszerne zadania tekstowe, implementację zasobów `.tres`, i18n, opisy oraz porządkowanie dokumentacji delegować modelom Gemini / Antigravity.
   - Projektowanie mechaniki, architekturę silnika i złożone zmiany w kodzie GDScript realizować w sesjach z Claude Opus.

---

## Najbliższe kroki

Zadania i otwarte wątki zostały skonsolidowane w dokumencie [`docs/znane_problemy.md`](../znane_problemy.md):
- **Priorytety `### ⚠ WAŻNE:`:**
  - Weryfikacja ekranu śmierci i trucizny w świecie (`(#1)`).
  - Wdrożenie generatora obiektów — faza F5: dźwignie, niszczalne sceny, nakładka podglądu (`(2)`).
  - Grywalne postacie — rekrutacja towarzyszy, zadania, skille klasowe Maga i Łotrzyka (`(4)`).
  - Kolejny duży etap: Miasto / Hub z modułów paczki free (`(5)`).
- **Zadania w toku i do podjęcia:**
  - Krzywe bohatera i wrogów do lv 100 oraz tiery sprzętu na 15 map (`docs/znane_problemy.md` → „Skalowanie wrogów przy kilkunastu mapach”).
  - Sklepy, kowal, ulepszanie broni z potencjałem (`docs/znane_problemy.md` → „miasto / hub” oraz `docs/kontekst/ekwipunek_szkic.md`).
  - Rewizja wpływu pancerza DEF w późnej fazie gry oraz wielostatystykowej optymalizacji ekwipunku (`docs/znane_problemy.md` → „Do zrobienia”).
  - Teksty logu wrogów `skill.<plik>.log` (brief [`docs/kontekst/i18n_log_wrogow_dla_gemini.md`](i18n_log_wrogow_dla_gemini.md)).
