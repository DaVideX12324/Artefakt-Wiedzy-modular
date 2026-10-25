# Dokumentacja projektu „Artefakt Wiedzy” / „Cień Mgły”

Główny indeks dokumentacji projektowej, architektonicznej i roboczej w katalogu `docs/`.

> **Zasady organizacji dokumentacji:**
> - **Pojedyncze źródło prawdy dla błędów i zadań:** [`docs/znane_problemy.md`](znane_problemy.md) — zawiera priorytety `⚠ WAŻNE:` (odczytywane przez hook startowy Claude Code), sekcje „Do zrobienia”, „Do sprawdzenia w grze”, „Pułapki konfiguracji” i „Rozwiązane”.
> - **Bieżący stan sesji (handoff):** najnowszy [`docs/kontekst/sesja_2026-10-24.md`](kontekst/sesja_2026-10-24.md) (Cień Mgły; od 2026-10-21 handoffy są w plikach `kontekst/sesja_*.md`, [`otwarte.md`](kontekst/otwarte.md) — starsze), BitBomber: `modules/BitBomber/docs/zadania.md`.
> - **Indeks dokumentów roboczych modułu RPG:** [`docs/kontekst/README.md`](kontekst/README.md).
> - **Materiały zarchiwizowane:** [`docs/archiwum/`](archiwum/).
> - **Submoduły:** kod gier leży w repo modułów (`modules/BitBomber`, `modules/quiz_rpg` = Cień Mgły), a dokumentacja Cienia Mgły — w tym katalogu hosta. README modułów są w ich repo (zmiana = commit w repo modułu + nowy wskaźnik submodułu w hoście).

---

## 1. Zasady i kontekst roboczy

| Plik | Opis zawartości | Status |
|---|---|---|
| [znane_problemy.md](znane_problemy.md) | Jedyne źródło prawdy dla todo i problemów: priorytety `⚠ WAŻNE:` (hook), Do zrobienia, Do sprawdzenia w grze, Pułapki konfiguracji, Rozwiązane. | `W TOKU` |
| [wersjonowanie.md](wersjonowanie.md) | Numery wersji i etapy (Alpha / Beta / RC) hosta i modułów, gdzie są zapisane, plan wydań 0.9 / 1.0 / 2.0, changelogi, kroki wydania. Aktualnie: Artefakt Wiedzy i Cień Mgły `0.8.0-alpha`, BitBomber `0.9.0-beta`. | `ZROBIONE` |
| [module_contract.md](module_contract.md) | Kontrakt modułowy gry, izolacja modułów, konwencje ścieżek (`QuizRpgPaths`) i synchronizacja zasobów hosta. | `ZROBIONE` |
| [kontekst/README.md](kontekst/README.md) | Szczegółowy indeks dokumentów technicznych i specyfikacji roboczych w folderze `docs/kontekst/`. | `ZROBIONE` |
| [kontekst/otwarte.md](kontekst/otwarte.md) | Zwięzłe przekazanie stanu bieżącej sesji (handoff), ostatnie decyzje usera oraz odnośniki do `znane_problemy.md`. | `W TOKU` |
| [kontekst/zasady.md](kontekst/zasady.md) | Stałe zasady pracy z repozytorium (commity, ochrona kodu), uruchamianie testów i reguły submodułu. | `ZROBIONE` |
| [kontekst/narzedzia_diag.md](kontekst/narzedzia_diag.md) | Skrypty diagnostyczne headless w `tests/` do testów generatora, siatki nawigacji i renderów. | `ZROBIONE` |
| [kontekst/backlog_druzyna_balans.md](kontekst/backlog_druzyna_balans.md) | Rejestr zadań (sprint backlog S1–S7 i O1–O7) prac na gałęzi `druzyna-balans`. | `W TOKU` |
| [kontekst/zadania_wg_trudnosci.md](kontekst/zadania_wg_trudnosci.md) | Widok pomocniczy (nie źródło prawdy): zadania od najłatwiejszych do najtrudniejszych z oznaczeniem wykonawcy (user / Gemini / Sonnet / Opus), stan na 2026-10-13. | `W TOKU` |
| [kontekst/sesja_2026-10-13_miasto_ldtk.md](kontekst/sesja_2026-10-13_miasto_ldtk.md) | Zrzut kontekstu sesji 2026-10-12/13 (handoff): miasto w LDtk, TileSet free packa Pixel Crawler, decyzje o budynkach i wnętrzach. | `W TOKU` |
| [kontekst/sesja_2026-10-15_assety_i_przejscia.md](kontekst/sesja_2026-10-15_assety_i_przejscia.md) | Handoff 2026-10-14/15: prywatny submoduł `assets`, przepisana historia, przejścia, drobne poprawki. | `HISTORYCZNE` |
| [kontekst/sesja_2026-10-16_druzyna_ui.md](kontekst/sesja_2026-10-16_druzyna_ui.md) | Handoff 2026-10-15/16: drużyna, AGI, szyk, paski, opcje, merge `druzyna-balans` do main. | `AKTUALNE` |
| [kontekst/sesja_2026-10-16b_walka_fnafb_fabula.md](kontekst/sesja_2026-10-16b_walka_fnafb_fabula.md) | Handoff 2026-10-16 cz. 2: skala UI, runda / TP / prędkość jak w FNaFB, dołączanie w walce, decyzje fabuły finału. | `AKTUALNE` |
| [kontekst/sesja_2026-10-16c_i18n.md](kontekst/sesja_2026-10-16c_i18n.md) | Handoff 2026-10-16 cz. 3: tłumaczenia PL / EN (fazy 0–5), ekran zapisów z koszem. | `ZROBIONE` |
| [kontekst/sesja_2026-10-24.md](kontekst/sesja_2026-10-24.md) | Handoff 2026-10-24/25: wersjonowanie i eksport, koniec gry po wyjściu ze ścieków, imię bohatera + easter eggi, kroki, grupy SFX, boss + stała świta, statystyki wrogów z poziomu i sprzętu mapy, mikstury procentowe, schody, menu zapisu; niezacommitowane testy postaci (SRW / Tiny Questers). | `AKTUALNE` |
| [kontekst/sesja_2026-10-22.md](kontekst/sesja_2026-10-22.md) | Handoff 2026-10-22/23: łup w `.tres`, zakończenie (boss ścieków), logika miasta, zadania NPC, boss powrotny, minimapa, spotkania w ściekach, bronie z potencjałem, atlas Props usunięty; następne: user kończy mapę miasta. | `AKTUALNE` |
| [kontekst/sesja_2026-10-21.md](kontekst/sesja_2026-10-21.md) | Handoff 2026-10-21 (Opus): skala FNaFB1, kowal, sloty umiejętności, imiona, fabuła NPC, co czeka. | `AKTUALNE` |

---

## 2. Projekt gry i mechaniki (dokumenty systemowe)

| Plik | Opis zawartości | Status |
|---|---|---|
| [game_design.md](game_design.md) | Główny dokument projektowy gry Cień Mgły (fabuła i zakończenia, kolejność 12 stref — docelowo ok. 15 map, mechaniki, progresja, pętla rozgrywki). | `W TOKU` |
| [kontekst/scieki.md](kontekst/scieki.md) | Specyfikacja techniczna i parametry generatora ścieków (układ structured, kanały, kładki, platformy). | `ZROBIONE` |
| [kontekst/sciany_i_kafle.md](kontekst/sciany_i_kafle.md) | Generator jaskiń: autotiling ścian, filary 2H, wypustki, fasady płaskowyżu i warianty kafli RIM. | `ZROBIONE` |
| [kontekst/obiekty.md](kontekst/obiekty.md) | Generator obiektów: katalogi JSON, obiekty jako sceny, niszczalne beczki, skrzynie i obiekty ścieków. | `ZROBIONE` |
| [kontekst/npc.md](kontekst/npc.md) | NPC miasta: sceny-szablony, usługi (rozmowa, sklep, nauczyciel, zapis), flagi, sklepy podzielone, fabuła NPC. Kod niezależny od mapy. | `ZROBIONE (MVP)` |
| [kontekst/domy_modularne.md](kontekst/domy_modularne.md) | Domy modułowe z Pixel Crawler Free Pack: narzędzie `house_builder.py`, presety, dach, cień, do zrobienia. | `W TOKU` |
| [kontekst/walka.md](kontekst/walka.md) | System walki w stylu RPG Makera: UI WYSIWYG, mechanika tur, tła 16:9, trapezy pól i log. | `W TOKU` |
| [kontekst/wrogowie.md](kontekst/wrogowie.md) | Konfiguracja przeciwników: zasięg wykrywania, dziedziczenie scen, stany AI, scan_text i log wrogów. | `W TOKU` |
| [kontekst/pytania.md](kontekst/pytania.md) | System pytań quizowych, edytor pytań w grze, eksport/import JSON i kategorie. | `ZROBIONE` |
| [kontekst/menu_i_opcje.md](kontekst/menu_i_opcje.md) | Menu główne, menu pauzy Esc, HUD, ustawienia okna/grafiki/dźwięku i konfiguracja sterowania. | `ZROBIONE` |
| [kontekst/ekran_ladowania.md](kontekst/ekran_ladowania.md) | Ekran ładowania map, podgląd tła, obsługa wątku w tle i prompty grafik. | `ZROBIONE` |
| [kontekst/poziomy_i_xp.md](kontekst/poziomy_i_xp.md) | Matematyka poziomów wrogów, skalowania statystyk z poziomu oraz krzywe doświadczenia na 15 map. | `W TOKU` |

---

## 3. Plany wykonawcze i optymalizacje

| Plik | Opis zawartości | Status |
|---|---|---|
| [plan_generator_sciekow.md](plan_generator_sciekow.md) | Plan wykonawczy układu structured dla generatora ścieków (reguły R1–R7, kanały, kładki). | `ZROBIONE` |
| [plan_generator_obiektow.md](plan_generator_obiektow.md) | Plan faz F0–F5 generatora obiektów i dekoracji (obiekty jako sceny, niszczalność, interakcje). | `ZROBIONE` |
| [plan_zapis_map.md](plan_zapis_map.md) | Zapis gotowych map na dysk (`map_disk_cache.gd`): pomiary, format, jak działa — jaskinie i ścieki. | `ZROBIONE` |
| [plan_przyspieszenie_generowania.md](plan_przyspieszenie_generowania.md) | Plan optymalizacji czasu generacji poziomów (wątek roboczy, chunking navmesh 64×64). | `W TOKU` |
| [ewaluacja/etap1_scenariusz.md](ewaluacja/etap1_scenariusz.md) | Szkice testów z użytkownikami w dwóch etapach: etap 1 (platforma, edytor pytań, BitBomber; formularz [etap1_formularz.md](ewaluacja/etap1_formularz.md)) i etap 2 (Cień Mgły: [etap2_scenariusz.md](ewaluacja/etap2_scenariusz.md), [etap2_formularz.md](ewaluacja/etap2_formularz.md)); w formularzach SUS. | `SZKIC (niezatwierdzone)` |
| [zakres_inzynierka.md](zakres_inzynierka.md) | Zakres pracy inżynierskiej: wycinek gry (miasto + NPC, BitBomber), harmonogram do obrony, klify w Pixel Crawler, mapy BitBombera. Narzędzia: [prototypy/makieta_miasta](prototypy/makieta_miasta/README.md). | `SZKIC (niezatwierdzone)` |
| [universal_interior_generator_refactor.md](universal_interior_generator_refactor.md) | Architektura etapowa i plan refaktoryzacji uniwersalnego generatora wnętrz (architektura etapowa). | `W TOKU` |
| [migration_plan.md](migration_plan.md) | Plan początkowej migracji projektów do architektury modułowej (zrealizowany na starcie). | `HISTORYCZNE` |

---

## 4. Analizy i narzędzia developerskie

| Plik | Opis zawartości | Status |
|---|---|---|
| [analiza_ai_przeciwnikow.md](analiza_ai_przeciwnikow.md) | Analiza zachowań AI wrogów w jaskiniach (nawigacja, widoczność 4-way, pościg, wałęsanie). | `ZROBIONE` |
| [battle_layout_preview.md](battle_layout_preview.md) | Narzędzie i instrukcja graficznego dopasowywania trapezów pól walki do teł 16:9. | `ZROBIONE` |
| [krytyczne_zawieszenia_klatek.md](krytyczne_zawieszenia_klatek.md) | Analiza i rozwiązanie problemu wielosekundowych przycięć silnika Godot przy obsłudze wejścia. | `ZROBIONE` |

---

## 5. Szkice projektowe (niezatwierdzone / propozycje)

| Plik | Opis zawartości | Status |
|---|---|---|
| [kontekst/druzyna_szkic.md](kontekst/druzyna_szkic.md) | Szkic systemu drużyny: 3 towarzyszy, zadania rekrutacyjne, osobne pule XP i brak limitu w walce. | `SZKIC (niezatwierdzone)` |
| [kontekst/ekwipunek_szkic.md](kontekst/ekwipunek_szkic.md) | Szkic ekonomii i ekwipunku: złoto, mikstury, tiery skrzyń i kluczy, sklepy oraz ulepszenia broni. | `SZKIC (niezatwierdzone)` |
| [kontekst/fabula_krag_i_zakonczenia_szkic.md](kontekst/fabula_krag_i_zakonczenia_szkic.md) | Szkic fabuły: zamiana ciał, krąg zamiast maszyny, magia 10. poziomu, trzy zakończenia, NG+ i walka finałowa. | `SZKIC (niezatwierdzone)` |
| [kontekst/fabula_szkic_dopiski_i_konflikty.md](kontekst/fabula_szkic_dopiski_i_konflikty.md) | Dopiski 2026-10-16 do szkicu fabuły, konflikty z `game_design.md`, otwarte sprawy. | `SZKIC (niezatwierdzone)` |
| [kontekst/sloty_umiejetnosci_szkic.md](kontekst/sloty_umiejetnosci_szkic.md) | Szkic mechaniki slotów umiejętności, 4 tierów, budżetu slotów oraz odblokowywania trybu combo. | `SZKIC (niezatwierdzone)` |
| [kontekst/klasy_postaci_i_bronie.md](kontekst/klasy_postaci_i_bronie.md) | Szkic klas postaci (Wojownik, Łotrzyk, Mag, Kapłan) i 16 broni na strefę (Pixel Crawler). | `SZKIC (niezatwierdzone)` |
| [kontekst/balans_i_skalowanie.md](kontekst/balans_i_skalowanie.md) | Szkic i wstępna kalibracja parametrów walki (HP, ATK, DEF, TTK) względem FNaFB. | `SZKIC (niezatwierdzone)` |
| [kontekst/skille_i_pierwowzory.md](kontekst/skille_i_pierwowzory.md) | Zestawienie umiejętności bohaterów i wrogów z pierwowzorami z FNaFB, kosztami i efektami. | `SZKIC (niezatwierdzone)` |
| [kontekst/skille_i_pierwowzory.docx](kontekst/skille_i_pierwowzory.docx) | Źródłowy plik dokumentacji Word z tabelami umiejętności i kosztami SP/TP. | `SZKIC (niezatwierdzone)` |

---

## 6. Briefy i zadania pomocnicze

| Plik | Opis zawartości | Status |
|---|---|---|
| [kontekst/zadania_dla_antigravity.md](kontekst/zadania_dla_antigravity.md) | Centralny rejestr zadań roboczych delegowanych modelom pomocniczym (Gemini/Antigravity). | `W TOKU` |
| [kontekst/porzadkowanie_docs_dla_gemini.md](kontekst/porzadkowanie_docs_dla_gemini.md) | Brief uporządkowania struktury folderu `docs/`, ujednolicenia statusów i indeksów (Zadanie E). | `W TOKU` |
| [kontekst/i18n_opisy_dla_gemini.md](kontekst/i18n_opisy_dla_gemini.md) | Brief i słownik do tłumaczenia nazw i opisów 44 umiejętności oraz 18 statusów do JSON. | `ZROBIONE` |
| [kontekst/i18n_log_wrogow_dla_gemini.md](kontekst/i18n_log_wrogow_dla_gemini.md) | Brief dla Gemini na przygotowanie komunikatów logu walki umiejętności przeciwników. | `ZROBIONE` |
| [kontekst/i18n_calosc_dla_gemini.md](kontekst/i18n_calosc_dla_gemini.md) | Brief dla Gemini: tłumaczenia PL / EN całego Artefaktu (host, Cień Mgły, BitBomber) — `I18nService`, sceny przez `TranslationServer`, fazy 0–5. | `ZROBIONE` |
| [kontekst/i18n_calosc_raport.md](kontekst/i18n_calosc_raport.md) | Raport z wdrożenia i18n — faza 0 (infrastruktura, `I18nService`). | `ZROBIONE` |
| [kontekst/imiona_postaci_dla_gemini.md](kontekst/imiona_postaci_dla_gemini.md) | Brief i propozycje imion (towarzysze, NPC, Strażnik, Arcymag); imiona wdrożone 2026-10-21. | `ZROBIONE` |
| [kontekst/raport_porzadkowania.md](kontekst/raport_porzadkowania.md) | Raport z przeprowadzonego porządkowania dokumentacji, weryfikacji linków i ewentualnych rozbieżności. | `ZROBIONE` |

---

## 7. Archiwum

| Plik | Opis zawartości | Status |
|---|---|---|
| [archiwum/otwarte_do_2026-10-12.md](archiwum/otwarte_do_2026-10-12.md) | Historyczne notatki, listy todo i dzienniki sesji przeniesione z `otwarte.md`. | `HISTORYCZNE` |
| [archiwum/kontekst_README_sesje_do_2026-10-06.md](archiwum/kontekst_README_sesje_do_2026-10-06.md) | Dzienniki sesji roboczych (2026-10-02 do 2026-10-06) przeniesione z `docs/kontekst/README.md`. | `HISTORYCZNE` |
