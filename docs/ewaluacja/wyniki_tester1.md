# Wyniki — tester 1 (2026-11-05)

Oryginalne formularze: `H:/Pobrane/etap1_formularz(1).md`, `H:/Pobrane/etap2_formularz(1).md`.

**Profil:** 23 lata, rzadko gry imprezowe / turowe i aplikacje do nauki. PC (R9 9900X3D, RTX 5070 Ti) — płynnie.
Etap 1: >20 min (BitBomber 0.9.0-beta). Etap 2: ~1 h (Cień Mgły 0.9.13.2-beta).

## Wyniki liczbowe

- Wszystkie zadania (B1, B1a, B1b, B2, B3, B4) — bez pomocy. Brak awarii, błędów grafiki, zacięć.
- SUS: **75** w obu etapach. Uwaga: odpowiedzi SUS identyczne w obu formularzach (możliwe skopiowanie).
- Etap 1: C1 = 4, C2 = raczej nie, D5 = 4, D7 (zasady BitBombera) = 3, D9 boty w sam raz.
- Etap 2: C1 = 4, C2 = może kiedyś, D2 trudność w sam raz, D3 pytanie = irytujący przerywnik, E1 w sam raz.

## Uwagi i działania

| # | Uwaga | Działanie |
|---|---|---|
| 1 | CM: zapamiętywał pozycję odpowiedzi i zgadywał po długości (D4) | **zrobione** — losowa kolejność odpowiedzi (QuizService.start_quiz). Bias długości sprawdzony: poprawna najdłuższa w 29% pytań (losowo 25%) — OK |
| 2 | BB: w 20 min nie trafił na quiz (D8) | **zrobione** — 35% power-upów zamkniętych pytaniem (znaczek ❓); D8 w formularzu do przeredagowania |
| 3 | BB: „dziwne przyciąganie w kwadratach” przy ruchu (H) | **zrobione** — ciało 52 px zamiast 62, wyrównanie z pełną prędkością (było 150 px/s) |
| 4 | CM: po wyjściu z miasta nudno, brak celu i nagród (E2) | **zrobione** — cel główny na HUD, skrzynie na minimapie (bez nisz), komunikat serii, premia za pierwsze przejście mapy |
| 5 | CM: konfiguracja rozgrywki przy starcie nowej gry, do Opcji nie zajrzał (H) | **zrobione** — ekran ustawień po imieniu: trudność (nowa), losowe spotkania, tempo walki, bez quizów |
| 6 | BB: zasady 3/5 (D7) | **zrobione** — nazwa power-upu nad graczem po zebraniu, zamknięte power-upy w Instrukcji |
| 7 | Formularz: D10 niezrozumiałe; D8 pyta o „quiz między rundami”, a takiego nie ma | poprawić formularz |
| 8 | Uwaga o numeracji wersji (A4) | — |
| 9 | (user) Prawdziwe tutoriale w strefie samouczka | **zrobione** — okna wskazówek (tutorial_hint.gd), pomijanie pojedynczych / wszystkich |
