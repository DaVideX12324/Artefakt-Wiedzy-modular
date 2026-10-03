# Kontekst pracy (stan na 2026-10-03)

Krótkie notatki na start nowej sesji. Moduł `modules/quiz_rpg`, Godot 4.7.2.

| Plik | O czym |
|---|---|
| [zasady.md](zasady.md) | stałe zasady pracy (commity, czego nie ruszać) i uruchamianie testów |
| [sciany_i_kafle.md](sciany_i_kafle.md) | generator jaskiń: filary 2H, wypustki, fasady płaskowyżu |
| [obiekty.md](obiekty.md) | generator obiektów: duże obiekty przy ścianach, dostęp do skrzyń |
| [ekran_ladowania.md](ekran_ladowania.md) | scena ekranu ładowania, tła map, prompty do grafik |
| [pytania.md](pytania.md) | zestawy pytań, wybór aktywnych, edytor pytań (menu główne, opcje) |
| [menu_i_opcje.md](menu_i_opcje.md) | opcje hosta (motyw, pytania, sterowanie per moduł), menu Esc, HUD, audio menu |
| [walka.md](walka.md) | UI walki (RPG Maker, WYSIWYG), motywy i style pasków, pola walki per tło, podgląd / edytor pól, tła 16:9 |
| [wrogowie.md](wrogowie.md) | zasięg wykrywania, dziedziczenie scen, znane pułapki |
| [narzedzia_diag.md](narzedzia_diag.md) | skrypty headless do renderów i porównań (katalog `tests/`, poza gitem) |
| [otwarte.md](otwarte.md) | co zostało do zrobienia / sprawdzenia |

Pełniejsze listy: `docs/znane_problemy.md` (sekcje „Do zrobienia” i „Rozwiązane”),
`docs/plan_generator_obiektow.md`, `docs/game_design.md`.

UI walki (2026-09-30): scena `scenes/quiz/quiz_combat_ui.tscn` + motyw `resources/ui/quiz_theme.tres`
(czcionka Jersey 15, typy QuizWindow / QuizLog / QuizMenuItem) są WYSIWYG; pola walki per tło —
`assets/textures/battle_backgrounds/**/<grafika>_layout.tres`, edycja w `scenes/tools/battle_layout_preview.tscn`.
Przypomnienia na start sesji Claude Code: hook `SessionStart` w `.claude/settings.json` uruchamia
`.claude/hooks/przypomnienia.sh`, który wypisuje wszystkie nagłówki `### ⚠ WAŻNE: …` z
`docs/znane_problemy.md`. Nowe ważne todo = nowy nagłówek z tym znacznikiem; po załatwieniu usunąć nagłówek
albo znacznik — przypomnienie znika samo.

Sesja 2026-10-02/03 (skrót): motywy UI `_st` i style pasków z Pixel UI pack 3 (opcje -> Motyw, także menu Esc),
poprawki wyboru myszą w walce i kolejności rysowania wrogów, HUD bez statystyk, muzyka menu, przycisk
„Opcje” w menu Quiz RPG, edytor pytań, sterowanie per moduł, `.gitattributes` eol=lf, pola walki na
y = 765 i cień 35 px, węższe okna komend i tekst walki 36 px, tryb „UI walki na szerokość treści”, prompty
teł 16:9 + korekcyjne, w podglądzie pól strefy UI / cienia i paski HP. Od teraz commity od razu pushowane.
