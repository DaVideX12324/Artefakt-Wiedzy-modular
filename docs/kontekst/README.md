# Indeks dokumentów kontekstowych (`docs/kontekst/`)

Krótkie notatki robocze, specyfikacje i ustalenia dotyczące modułu RPG `quiz_rpg` — Cień Mgły (Godot 4.7.2). Kod modułu jest w submodule `modules/quiz_rpg` (repo CienMgly); ścieżki w opisach (`scripts/…`, `scenes/…`) są względem folderu modułu.

> **Przypomnienia na start sesji (hook Claude Code):** hook `SessionStart` w `.claude/settings.json` uruchamia `.claude/hooks/przypomnienia.sh`, który wypisuje wszystkie nagłówki `### ⚠ WAŻNE: …` z [`docs/znane_problemy.md`](../znane_problemy.md). Nowe ważne todo = nowy nagłówek z tym znacznikiem; po załatwieniu usunąć nagłówek albo znacznik — przypomnienie znika samo.
>
> **Pojedyncze źródło prawdy dla błędów i zadań:** [`docs/znane_problemy.md`](../znane_problemy.md).  
> **Bieżący stan sesji (handoff):** [`otwarte.md`](otwarte.md).  
> **Archiwum dzienników sesji:** [`docs/archiwum/kontekst_README_sesje_do_2026-10-06.md`](../archiwum/kontekst_README_sesje_do_2026-10-06.md).

---

## Skorowidz plików w `docs/kontekst/`

| Plik | Opis zawartości | Status |
|---|---|---|
| [zasady.md](zasady.md) | Stałe zasady pracy z repozytorium (commity, ochrona kodu), uruchamianie testów i architektura modułu. | `ZROBIONE` |
| [scieki.md](scieki.md) | Specyfikacja techniczna i stan prac nad generatorem ścieków (układ structured, kanały, kładki, platformy). | `ZROBIONE` |
| [sciany_i_kafle.md](sciany_i_kafle.md) | Generator jaskiń: filary 2H, autotiling ścian, wypustki, fasady płaskowyżu i warianty kafli RIM. | `ZROBIONE` |
| [obiekty.md](obiekty.md) | Generator obiektów: katalogi JSON, obiekty jako sceny, niszczalne beczki, skrzynie i obiekty ścieków. | `W TOKU` |
| [ekran_ladowania.md](ekran_ladowania.md) | Ekran ładowania map, podgląd tła, obsługa wątku w tle i prompty grafik. | `ZROBIONE` |
| [pytania.md](pytania.md) | System pytań quizowych, edytor pytań w grze, eksport/import JSON i kategorie. | `ZROBIONE` |
| [menu_i_opcje.md](menu_i_opcje.md) | Menu główne, menu pauzy Esc, HUD, ustawienia okna/grafiki/dźwięku i konfiguracja sterowania. | `ZROBIONE` |
| [walka.md](walka.md) | System walki w stylu RPG Makera: UI WYSIWYG, mechanika tur, tła 16:9, trapezy pól i log. | `W TOKU` |
| [wrogowie.md](wrogowie.md) | Konfiguracja przeciwników: zasięg wykrywania, dziedziczenie scen, stany AI, scan_text i log wrogów. | `W TOKU` |
| [narzedzia_diag.md](narzedzia_diag.md) | Skrypty diagnostyczne headless w `tests/` do testów generatora, siatki nawigacji i renderów. | `ZROBIONE` |
| [klasy_postaci_i_bronie.md](klasy_postaci_i_bronie.md) | Projekt 4 klas postaci (Wojownik, Łotrzyk, Mag, Kapłan), 16 broni per strefa oraz struktury drużyny. | `SZKIC (niezatwierdzone)` |
| [balans_i_skalowanie.md](balans_i_skalowanie.md) | Analiza balansu walki, statystyk HP/ATK/DEF, kalkulacji TTK i skalowania wzorowanego na FNaFB. | `SZKIC (niezatwierdzone)` |
| [otwarte.md](otwarte.md) | Podsumowanie ostatniej sesji (handoff), decyzje usera i odnośniki do bieżących zadań w `znane_problemy.md`. | `W TOKU` |
| [backlog_druzyna_balans.md](backlog_druzyna_balans.md) | Sprint backlog (etapy S1–S7 i O1–O7) prac na gałęzi `druzyna-balans`. | `W TOKU` |
| [zadania_wg_trudnosci.md](zadania_wg_trudnosci.md) | Widok pomocniczy (nie źródło prawdy): zadania od najłatwiejszych do najtrudniejszych z oznaczeniem wykonawcy, stan na 2026-10-13. | `W TOKU` |
| [sesja_2026-10-13_miasto_ldtk.md](sesja_2026-10-13_miasto_ldtk.md) | Zrzut kontekstu sesji 2026-10-12/13 (handoff): miasto w LDtk, TileSet free packa Pixel Crawler, decyzje o budynkach. | `W TOKU` |
| [druzyna_szkic.md](druzyna_szkic.md) | Szkic systemu drużyny: 3 towarzyszy, rekrutacja po zadaniach, osobne pule XP i brak limitu w walce. | `SZKIC (niezatwierdzone)` |
| [ekwipunek_szkic.md](ekwipunek_szkic.md) | Szkic ekonomii i ekwipunku: złoto, mikstury, tiery skrzyń i kluczy, sklepy oraz ulepszenia broni. | `SZKIC (niezatwierdzone)` |
| [fabula_krag_i_zakonczenia_szkic.md](fabula_krag_i_zakonczenia_szkic.md) | Szkic fabuły: zamiana ciał, krąg zamiast maszyny, magia 10. poziomu, trzy zakończenia, NG+ i walka finałowa. | `SZKIC (niezatwierdzone)` |
| [sloty_umiejetnosci_szkic.md](sloty_umiejetnosci_szkic.md) | Szkic mechaniki slotów umiejętności, 4 tierów, budżetu slotów oraz odblokowywania trybu combo. | `SZKIC (niezatwierdzone)` |
| [poziomy_i_xp.md](poziomy_i_xp.md) | Matematyka poziomów wrogów, skalowania statystyk z poziomu oraz krzywe doświadczenia na 15 map. | `W TOKU` |
| [skille_i_pierwowzory.md](skille_i_pierwowzory.md) | Zestawienie umiejętności bohaterów i wrogów z ich pierwowzorami z FNaFB, kosztami i efektami. | `SZKIC (niezatwierdzone)` |
| [skille_i_pierwowzory.docx](skille_i_pierwowzory.docx) | Plik binarny Word zawierający bazową tabelę umiejętności i kosztów SP/TP. | `SZKIC (niezatwierdzone)` |
| [i18n_opisy_dla_gemini.md](i18n_opisy_dla_gemini.md) | Brief i słownik do tłumaczenia nazw i opisów 44 umiejętności oraz 18 statusów do `pl.json` i `en.json`. | `ZROBIONE` |
| [i18n_log_wrogow_dla_gemini.md](i18n_log_wrogow_dla_gemini.md) | Brief dla Gemini na przygotowanie tekstów logu walki dla umiejętności przeciwników. | `NIE ZROBIONE` |
| [zadania_dla_antigravity.md](zadania_dla_antigravity.md) | Rejestr zadań mechanicznych i tekstowych delegowanych modelom pomocniczym (Gemini/Antigravity). | `W TOKU` |
| [porzadkowanie_docs_dla_gemini.md](porzadkowanie_docs_dla_gemini.md) | Brief na uporządkowanie struktury `docs/`, ujednolicenie statusów i utworzenie indeksów (Zadanie E). | `W TOKU` |
| [raport_porzadkowania.md](raport_porzadkowania.md) | Raport z przeprowadzonego porządkowania dokumentacji, weryfikacji linków i ewentualnych rozbieżności. | `ZROBIONE` |
