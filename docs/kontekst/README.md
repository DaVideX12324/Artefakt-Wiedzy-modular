# Indeks dokumentów kontekstowych (`docs/kontekst/`)

Krótkie notatki robocze, specyfikacje i ustalenia dotyczące modułu RPG `quiz_rpg` — Cień Mgły (Godot 4.7.2). Kod modułu jest w submodule `modules/quiz_rpg` (repo CienMgly); ścieżki w opisach (`scripts/…`, `scenes/…`) są względem folderu modułu.

> **Przypomnienia na start sesji (hook Claude Code):** hook `SessionStart` w `.claude/settings.json` uruchamia `.claude/hooks/przypomnienia.sh`, który wypisuje wszystkie nagłówki `### ⚠ WAŻNE: …` z [`docs/znane_problemy.md`](../znane_problemy.md). Nowe ważne todo = nowy nagłówek z tym znacznikiem; po załatwieniu usunąć nagłówek albo znacznik — przypomnienie znika samo.
>
> **Pojedyncze źródło prawdy dla błędów i zadań:** [`docs/znane_problemy.md`](../znane_problemy.md).  
> **Bieżący stan sesji (handoff):** najnowszy [`sesja_2026-10-24.md`](sesja_2026-10-24.md) (od 2026-10-21 handoffy są w plikach `sesja_*.md`; [`otwarte.md`](otwarte.md) — starsze).  
> **Archiwum dzienników sesji:** [`docs/archiwum/kontekst_README_sesje_do_2026-10-06.md`](../archiwum/kontekst_README_sesje_do_2026-10-06.md).

---

## Skorowidz plików w `docs/kontekst/`

| Plik | Opis zawartości | Status |
|---|---|---|
| [sesja_2026-10-24.md](sesja_2026-10-24.md) | Handoff 2026-10-24/25: wersjonowanie i eksport, koniec gry po wyjściu ze ścieków, imię bohatera + easter eggi, kroki, grupy SFX, boss + stała świta, statystyki wrogów z poziomu i sprzętu mapy, mikstury procentowe, schody, menu zapisu; niezacommitowane testy postaci (SRW / Tiny Questers). | `AKTUALNE` |
| [sesja_2026-10-22.md](sesja_2026-10-22.md) | Handoff 2026-10-22/23: łup w `.tres`, zakończenie (boss ścieków), logika miasta, zadania NPC, boss powrotny, minimapa, spotkania w ściekach, bronie z potencjałem, atlas Props usunięty; następne: user kończy mapę miasta. | `AKTUALNE` |
| [sesja_2026-10-21.md](sesja_2026-10-21.md) | Handoff 2026-10-21 (Opus): skala FNaFB1, kowal, sloty umiejętności, imiona, fabuła NPC, co czeka. | `AKTUALNE` |
| [sesja_2026-10-16b_walka_fnafb_fabula.md](sesja_2026-10-16b_walka_fnafb_fabula.md) | Handoff 2026-10-16 cz. 2: skala UI, runda / TP / prędkość jak w FNaFB, dołączanie w walce, dane FNaFB2, decyzje fabuły finału. | `AKTUALNE` |
| [sesja_2026-10-16_druzyna_ui.md](sesja_2026-10-16_druzyna_ui.md) | Handoff sesji 2026-10-15/16: drużyna + AGI + szyk, merge do main, paski i opcje (V-Sync / FPS), pułapki, następne kroki. | `AKTUALNE` |
| [zasady.md](zasady.md) | Stałe zasady pracy z repozytorium (commity, ochrona kodu), uruchamianie testów i architektura modułu. | `ZROBIONE` |
| [scieki.md](scieki.md) | Specyfikacja techniczna i stan prac nad generatorem ścieków (układ structured, kanały, kładki, platformy). | `ZROBIONE` |
| [sciany_i_kafle.md](sciany_i_kafle.md) | Generator jaskiń: filary 2H, autotiling ścian, wypustki, fasady płaskowyżu i warianty kafli RIM. | `ZROBIONE` |
| [npc.md](npc.md) | NPC miasta: usługi (sklep, odpoczynek, nauka, rozmowa), szablony scen, flagi fabularne, punkt narzuconego zapisu. | `ZROBIONE (MVP)` |
| [obiekty.md](obiekty.md) | Generator obiektów: katalogi JSON, obiekty jako sceny, niszczalne beczki, skrzynie i obiekty ścieków. | `ZROBIONE` |
| [npc.md](npc.md) | NPC miasta: sceny-szablony, usługi (rozmowa, sklep, nauczyciel, zapis), flagi, sklepy podzielone, fabuła NPC. | `ZROBIONE (MVP)` |
| [domy_modularne.md](domy_modularne.md) | Domy modułowe z Pixel Crawler Free Pack: `house_builder.py`, presety, dach, cień, do zrobienia. | `W TOKU` |
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
| [imiona_postaci_dla_gemini.md](imiona_postaci_dla_gemini.md) | Brief i propozycje imion (towarzysze, NPC, Strażnik, Arcymag); imiona wdrożone 2026-10-21. | `ZROBIONE` |
| [i18n_calosc_raport.md](i18n_calosc_raport.md) | Raport z wdrożenia i18n — faza 0 (infrastruktura, `I18nService`). | `ZROBIONE` |
| [fabula_krag_i_zakonczenia_szkic.md](fabula_krag_i_zakonczenia_szkic.md) | Szkic fabuły: zamiana ciał, krąg zamiast maszyny, magia 10. poziomu, trzy zakończenia, NG+ i walka finałowa. | `SZKIC (niezatwierdzone)` |
| [fabula_szkic_dopiski_i_konflikty.md](fabula_szkic_dopiski_i_konflikty.md) | Dopiski 2026-10-16 do szkicu fabuły, konflikty z `game_design.md`, wzór z FNaFB2, otwarte sprawy. | `SZKIC (niezatwierdzone)` |
| [sloty_umiejetnosci_szkic.md](sloty_umiejetnosci_szkic.md) | Szkic mechaniki slotów umiejętności, 4 tierów, budżetu slotów oraz odblokowywania trybu combo. | `SZKIC (niezatwierdzone)` |
| [poziomy_i_xp.md](poziomy_i_xp.md) | Matematyka poziomów wrogów, skalowania statystyk z poziomu oraz krzywe doświadczenia na 15 map. | `W TOKU` |
| [skille_i_pierwowzory.md](skille_i_pierwowzory.md) | Zestawienie umiejętności bohaterów i wrogów z ich pierwowzorami z FNaFB, kosztami i efektami. | `SZKIC (niezatwierdzone)` |
| [skille_i_pierwowzory.docx](skille_i_pierwowzory.docx) | Plik binarny Word zawierający bazową tabelę umiejętności i kosztów SP/TP. | `SZKIC (niezatwierdzone)` |
| [sesja_2026-10-15_assety_i_przejscia.md](sesja_2026-10-15_assety_i_przejscia.md) | Handoff 2026-10-14/15: prywatny submoduł `assets`, przepisana historia, przejścia. | `HISTORYCZNE` |
| [sesja_2026-10-16c_i18n.md](sesja_2026-10-16c_i18n.md) | Handoff: tłumaczenia PL / EN całego Artefaktu (fazy 0–5), poprawki po Gemini, ekran zapisów z koszem, otwarte. | `ZROBIONE` |
| [i18n_opisy_dla_gemini.md](i18n_opisy_dla_gemini.md) | Brief i słownik do tłumaczenia nazw i opisów 44 umiejętności oraz 18 statusów do `pl.json` i `en.json`. | `ZROBIONE` |
| [i18n_log_wrogow_dla_gemini.md](i18n_log_wrogow_dla_gemini.md) | Brief dla Gemini na przygotowanie tekstów logu walki dla umiejętności przeciwników. | `ZROBIONE` |
| [i18n_calosc_dla_gemini.md](i18n_calosc_dla_gemini.md) | Brief dla Gemini: tłumaczenia PL / EN całego Artefaktu (host, Cień Mgły, BitBomber) — `I18nService`, sceny przez `TranslationServer`, fazy 0–5. | `ZROBIONE` |
| [zadania_dla_antigravity.md](zadania_dla_antigravity.md) | Rejestr zadań mechanicznych i tekstowych delegowanych modelom pomocniczym (Gemini/Antigravity). | `W TOKU` |
| [porzadkowanie_docs_dla_gemini.md](porzadkowanie_docs_dla_gemini.md) | Brief na uporządkowanie struktury `docs/`, ujednolicenie statusów i utworzenie indeksów (Zadanie E). | `W TOKU` |
| [raport_porzadkowania.md](raport_porzadkowania.md) | Raport z przeprowadzonego porządkowania dokumentacji, weryfikacji linków i ewentualnych rozbieżności. | `ZROBIONE` |
