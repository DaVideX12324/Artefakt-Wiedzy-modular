# Kontekst pracy (stan na 2026-10-04)

Krótkie notatki na start nowej sesji. Moduł `modules/quiz_rpg`, Godot 4.7.2.

| Plik | O czym |
|---|---|
| [zasady.md](zasady.md) | stałe zasady pracy (commity, czego nie ruszać) i uruchamianie testów |
| [scieki.md](scieki.md) | ścieki: gałąź sewer-tileset, kafle, flagi generatora, kanały i kładki (stan prac) |
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

Sesja 2026-10-03/04 (skrót; szczegóły w plikach tematycznych i `docs/znane_problemy.md` „Rozwiązane”):
- Cień Mgły = submoduł CienMgly (kopie hosta w `_host/`, sync `tools/sync_host_copies.gd`, potem
  `git checkout -- project.godot.off`), jeden seed na zapis, mapy jako sceny dziedziczone (`levels/cave.tscn`),
  powrót do poprzedniego poziomu, rebind klawiszy, podpowiedź „[E] …” nad skrzyniami.
- Menu: główne menu gry na środku, „Wczytaj / Statystyki / Opcje” na osobnym ekranie (wzór FNaFB); opcje
  wbudowane w prawy panel menu Esc; potwierdzanie tylko zmian ekranu; Sterowanie z listą „Gra:”, czcionka 18,
  opcje z manifestu (`control_options`) — bieg / chód (`sprint`, Shift). Menu deweloperskie skalowane.
- Okno (`WindowService`): jeden autoload, start na zapisanym monitorze, poprawna pozycja okna z ramką,
  lista rozdzielczości okna z ramką + „maks. okno”, ręczny rozmiar / maksymalizacja zapamiętywane,
  wyjście z „bez ramki” na cały ekran — [menu_i_opcje.md](menu_i_opcje.md).
- Przejścia: spawny odsunięte od Area2D (`MapGeneratorBase.arrival_cell`, w samouczku marker
  `Spawns/Tutorial-Caves`), opcjonalnie pod E (`portal_use_key` / `portal_prompt`).
- Motyw: jasność bez przebudowy motywu (`QuizTheme.set_brightness`), styl pasków „Pas, dwustronny” ubywa
  od prawej, menu Esc nie przygasza wierszy bez wyboru — [walka.md](walka.md).

Sesja 2026-10-05 (ścieki na gałęzi `sewer-gen-v2` w submodule `modules/quiz_rpg`):
- Nowa architektura Structured Generator v2: determinizm PRNG (Fisher-Yates `shuffle_array`), podwójny szum binarny
  0/1 do podziału na suche koryto i ścieki kwasowe.
- Spójność i naprawa koryt przy ścianach: `canal_placer.gd` nie traktuje ścian jako kwasu (proste brzegi), koryto może
  bezpośrednio przylegać do ściany (`want[pk] = 0`), usunięto rozcinające ściany `_ensure_canal_clearance`.
- Prepassy ścian 3H chronią koryta (`_can_fill` w `Wall3HPass` sprawdza `canals.cells`), eliminacja ścian 1H i 2H.
- `BridgeConnectivityResolver` gwarantuje dokładnie 1 składową spójną oraz kładki o długości 6 oparte na `FLOOR`.
- Kładki na dedykowanej warstwie TileMapLayer `Bridges` (`z_index = -1`, y-sort) wydzielone z `FloorDecor`.
- 100% ciągłości krawędzi opuszczonej `CANAL_FACE` (4, 13) w `canal_placer.gd` (uniezależnienie `_is_face` od przechodniości pola na północ).
- Rozszerzenie kładki poziomej `BRIDGE_H` w atlasie `Props.png` do pełnego formatu 6×2 (kolumny 5–10, `origin = Vector2i(5, 12)`).
- Testy: `diag_sewer_full_test.gd` PASS (160x160, 250x250), `diag_sewer_slice_fixture.gd` PASS (13/0).

