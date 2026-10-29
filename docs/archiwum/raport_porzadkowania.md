# Raport z uporządkowania folderu `docs/` (Zadanie E)

> **Data sporządzenia:** 2026-10-12  
> **Wykonawca:** Gemini / Antigravity  
> **Cel:** Uporządkowanie dokumentacji, likwidacja duplikatów i sprzeczności między `otwarte.md` a `znane_problemy.md`, stworzenie spójnych indeksów i archiwum historycznych notatek bez utraty danych merytorycznych.

---

## (a) Lista przeniesień i utworzonych plików

1. **`docs/.gdignore` (nowy plik):**
   - Utworzono plik informujący silnik Godot o ignorowaniu katalogu `docs/` podczas skanowania zasobów i importu assetów.
2. **`docs/archiwum/` (nowy folder):**
   - Utworzono katalog przeznaczony na historyczne dzienniki sesji i nieaktualne zestawienia robocze.
3. **`docs/archiwum/otwarte_do_2026-10-12.md` (nowy plik):**
   - Przeniesiono pełną dotychczasową zawartość `docs/kontekst/otwarte.md` (stan do 2026-10-12) z nagłówkiem proweniencji, wyjaśniającym źródło i powód archiwizacji.
   - Poprawiono 7 linków względnych (dodano prefiks `../kontekst/`), aby wskazywały na aktualne pliki w `docs/kontekst/`.
4. **`docs/kontekst/otwarte.md` (odchudzony handoff):**
   - Przekształcono w lekki dokument przekazania sesji: zachowano w całości sekcję „Sesja 2026-10-12 (część 3): ekwipunek, złoto, klucze”, wydzielono zestawienie obowiązujących decyzji usera (sloty, drużyna, blok/AGI, debug tools na F-klawiszach, model delegowania) oraz podano odnośniki do `docs/znane_problemy.md`.
5. **`docs/archiwum/kontekst_README_sesje_do_2026-10-06.md` (nowy plik):**
   - Przeniesiono historyczny dziennik sesji (od „Sesja 2026-10-02/03…” w dół) z `docs/kontekst/README.md` z nagłówkiem proweniencji.
6. **`docs/kontekst/README.md` (nowy indeks kontekstu):**
   - Zastąpiono dawny dziennik sesji pełną tabelą indeksu obejmującą wszystkie 25 plików znajdujących się w folderze `docs/kontekst/` (w tym nowe szkice projektowe i briefy dla Gemini), z jednozdaniowym opisem i ujednoliconym statusem. Zachowano informację o hooku Claude Code.
7. **`docs/README.md` (nowy centralny indeks dokumentacji):**
   - Utworzono globalny spis wszystkich 38 dokumentów w `docs/` podzielony na 7 przejrzystych kategorii:
     1. Zasady i kontekst roboczy
     2. Projekt gry i mechaniki (dokumenty systemowe)
     3. Plany wykonawcze i optymalizacje
     4. Analizy i narzędzia developerskie
     5. Szkice projektowe (niezatwierdzone / propozycje)
     6. Briefy i zadania pomocnicze
     7. Archiwum

---

## (b) Wykryte sprzeczności między plikami

Podczas przeglądu dokumentów zidentyfikowano następujące rozbieżności, które zostały uporządkowane:

1. **Ekran śmierci drużyny:**
   - *Stan w starym `otwarte.md`:* Zgłoszone jako priorytet #1 z dopiskiem „dziś przegrana kończy się komunikatem Porażka, a gracz chodzi dalej z 0 HP”.
   - *Stan faktyczny w kodzie i `znane_problemy.md` (linia 14):* `ZROBIONE 2026-10-09, DO SPRAWDZENIA W GRZE` (scena `death_screen.tscn` wdrożona w `QuizCombatController`, commity `6482268`, `9a6a049`).
   - *Rozwiązanie:* Stary zapis zdezaktualizowany w `otwarte.md`; w `znane_problemy.md` zachowano status ze wskazaniem do przetestowania w grze.
2. **Generowanie ścieków (Paczka Sewer v2 vs structured):**
   - *Stan w starym `otwarte.md`:* Zadanie „Paczka Sewer v2 (...) Gra dalej na v1”.
   - *Stan faktyczny w repozytorium:* Eksperymentalna gałąź `sewer-gen-v2` została definitywnie zarzucona; nowa gałąź `sewer-structured` została zmergowana do `main` w dniach 2026-10-09/10 (`plan_generator_sciekow.md`, `znane_problemy.md` linia 47).
   - *Rozwiązanie:* Usunięto nieaktualne notatki o v2 z handoffu; w `znane_problemy.md` i `plan_generator_sciekow.md` oznaczono status jako `ZROBIONE` na `main`.
3. **Narzędzia developerskie i skróty klawiszowe:**
   - *Stan w starym `znane_problemy.md` (linia 166):* Opis problemu przechwytywania liter K, O, P w trakcie gry.
   - *Stan faktyczny z 2026-10-12:* Zaimplementowano warunek `OS.is_debug_build()`, usunięto litery K, O, P, pozostawiając wyłącznie klawisze funkcyjne F (F1, F9, F10, F11, `~`).
   - *Rozwiązanie:* Oznaczono w `znane_problemy.md` jako `ZROBIONE 2026-10-12, DO SPRAWDZENIA W EKSPORCIE WYDANIOWYM` z adnotacją, że dawny opis jest historyczny.
4. **Faza F5 generatora obiektów:**
   - *Stan w starym `otwarte.md`:* „dokończyć fazę F5 (niszczalne obiekty, dźwignie, podgląd)”.
   - *Stan faktyczny:* Niszczalne beczki (`barrel.gd`) z modelem dropu 3/(2n) oraz skrzynie z tierami i kluczami są już zrobione; do dokończenia zostały jedynie dźwignie, leniwe sceny i nakładka podglądu.
   - *Rozwiązanie:* Sprecyzowano zakres pozostałych prac w `znane_problemy.md` oraz `plan_generator_obiektow.md`.
5. **Skalowanie wrogów:**
   - *Stan w starszych analizach:* Ręczne statystyki wrogów na sztywnych 4 tierach (HP 100/350/900/2200).
   - *Stan faktyczny z 2026-10-12:* Statystyki wrogów skalowane wzorcową krzywą w kodzie (`QuizRpgEnemyStats` w `enemy_stats.gd`, `poziomy_i_xp.md`).
   - *Rozwiązanie:* Oznaczono w `znane_problemy.md` jako `W TOKU (w większości zrobione)`.

---

## (c) Wpisy oznaczone „DO WERYFIKACJI”

1. **`docs/znane_problemy.md` → `### Skalowanie pancerza w późnej fazie gry (wpływ DEF na przeżywalność)`:**
   - *Status:* `DO WERYFIKACJI`.
   - *Uzasadnienie:* Zgłoszono w `otwarte.md` (część 3), że obecna formuła kalkulacji obrażeń wrogów w `enemy_stats.gd` bazuje na ułamku maksymalnego HP gracza (`HIT_FRAC`), co powoduje, że przyrost statystyki DEF na wysokich poziomach (do lv 100) ma nieproporcjonalnie mały wpływ na przeżywalność. Zagadnienie wymaga weryfikacji matematycznej i decyzji projektowej w sesji Claude Opus.

---

## (d) Odwołania do sekcji, które uległy zmianie

1. W `docs/kontekst/otwarte.md`:
   - Wszystkie nieaktualne listy todo usunięto na rzecz odnośników do jedynego źródła prawdy: `docs/znane_problemy.md`.
2. W `docs/archiwum/otwarte_do_2026-10-12.md`:
   - Zaktualizowano 7 odnośników względnych (`scieki.md`, `klasy_postaci_i_bronie.md`, `balans_i_skalowanie.md`, `walka.md`, `sciany_i_kafle.md`, `poziomy_i_xp.md`), dodając `../kontekst/`.
3. W `docs/znane_problemy.md`:
   - Wpis `Zawartość nisz out, sekretne pokoje, klucze i wytrychy do skrzyń`: przesunięto linię statusu `Stan 2026-10-12: W TOKU` z linii 226 bezpośrednio pod nagłówek sekcji.
   - Wpis `Feedback z zamkniętych testów pre-alpha`: dodano brakującą linię `Stan 2026-10-12: W TOKU` bezpośrednio pod nagłówkiem.
   - Uzupełniono sekcję „Do zrobienia” o 2 brakujące punkty z `otwarte.md`: `Optymalizacja ekwipunku członków drużyny uwzględnia tylko ATK i DEF` oraz `Skalowanie pancerza w późnej fazie gry`.

---

## (e) Propozycja na fazę opcjonalną (dalsze wydzielanie plików)

W sekcji 3.2 briefu przewidziano możliwość wydzielenia części sekcji z pliku `docs/znane_problemy.md` (który liczy obecnie ponad 500 wierszy):
1. **Wydzielenie sekcji `## Rozwiązane` do `docs/archiwum/rozwiazane.md`:**
   - Sekcja zawiera historię kilkudziesięciu rozwiązanych problemów od września 2026 roku.
   - Odwołania w repozytorium do tej sekcji:
     - `docs/kontekst/README.md` (wiersz 21): odwołanie ogólne.
     - `docs/kontekst/zasady.md` (wiersz 73): instrukcja przenoszenia po naprawie.
     - `docs/archiwum/otwarte_do_2026-10-12.md` (wiersze 38, 56).
     - `docs/archiwum/kontekst_README_sesje_do_2026-10-06.md` (wiersz 14).
     - `docs/znane_problemy.md` (wiersze 4, 147, 296).
2. **Wydzielenie sekcji technicznych (`## Wydajność`, `## Pułapki konfiguracji`, `## Do sprawdzenia w grze`):**
   - Mogłyby trafić do dedykowanego pliku `docs/kontekst/wskazowki_i_pulapki.md` lub `docs/baza_wiedzy_technicznej.md`.
3. **Rekomendacja:**
   - Pozostawić strukturę `docs/znane_problemy.md` w obecnym stanie do momentu akceptacji raportu przez Claude'a i usera, ponieważ `znane_problemy.md` stanowi obecnie spójną całość, a hook startowy `.claude/hooks/przypomnienia.sh` działa stabilnie i bezbłędnie.

---

## Podsumowanie stanu linków
Wszystkie linki względne w obrębie całego katalogu `docs/**/*.md` zostały zweryfikowane skryptem Pythona — **0 błędnych odnośników**.
