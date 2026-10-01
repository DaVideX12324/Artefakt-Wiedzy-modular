# Kontekst pracy (stan na 2026-09-29)

Krótkie notatki na start nowej sesji. Moduł `modules/quiz_rpg`, Godot 4.7.2.

| Plik | O czym |
|---|---|
| [zasady.md](zasady.md) | stałe zasady pracy (commity, czego nie ruszać) i uruchamianie testów |
| [sciany_i_kafle.md](sciany_i_kafle.md) | generator jaskiń: filary 2H, wypustki, fasady płaskowyżu |
| [obiekty.md](obiekty.md) | generator obiektów: duże obiekty przy ścianach, dostęp do skrzyń |
| [ekran_ladowania.md](ekran_ladowania.md) | scena ekranu ładowania, tła map, prompty do grafik |
| [wrogowie.md](wrogowie.md) | zasięg wykrywania, dziedziczenie scen, znane pułapki |
| [narzedzia_diag.md](narzedzia_diag.md) | skrypty headless do renderów i porównań (katalog `tests/`, poza gitem) |
| [otwarte.md](otwarte.md) | co zostało do zrobienia / sprawdzenia |

Pełniejsze listy: `docs/znane_problemy.md` (sekcje „Do zrobienia” i „Rozwiązane”),
`docs/plan_generator_obiektow.md`, `docs/game_design.md`.

Przypomnienia na start sesji Claude Code: hook `SessionStart` w `.claude/settings.json` uruchamia
`.claude/hooks/przypomnienia.sh` — każde przypomnienie sprawdza stan repo i znika samo, gdy sprawa jest
załatwiona (dziś: pliki `.import` poza repo). Nowe przypomnienie = nowy blok w tym skrypcie.
