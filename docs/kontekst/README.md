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

UI walki (2026-09-30): scena `scenes/quiz/quiz_combat_ui.tscn` + motyw `resources/ui/quiz_theme.tres`
(czcionka Jersey 15, typy QuizWindow / QuizLog / QuizMenuItem) są WYSIWYG; pola walki per tło —
`assets/textures/battle_backgrounds/**/<grafika>_layout.tres`, edycja w `scenes/tools/battle_layout_preview.tscn`.
