# Plan: menedżer okien UI (Cień Mgły)

Stan 2026-10-30. Wzór: `Amon-Ra/amon-ra/scripts/ui/uiManager.gd` (jedno `current_open_menu`, nazwy okien i `match`
na sztywno). Tu wersja ogólna — stos okien, okna rejestrują się same.

## Problem
Każde okno samo łapie Esc / pauzę / blokadę gracza w `_input` / `_unhandled_input`; kolejność zależy od drzewa.
Objawy: Esc przy pełnej minimapie otwierał pauzę (łatka: grupa `quiz_modal_ui` w `pause_menu._modal_open()`),
wcześniej szybkie inputy w walce, ekran śmierci pod pauzą, skrzynie bez pauzy.

## Projekt
Autoload `QuizRpgUi` (`modules/quiz_rpg/autoloads/ui_stack.gd`, w `module_manifest.json` jak inne autoloady modułu).

```gdscript
signal changed(top: Node)
func open(window: Node, opts := {}) -> void   # opts: pause (bool), blocks_player (bool), closable (bool, Esc)
func close(window: Node) -> void
func top() -> Node
func is_open(window: Node) -> bool
func any_open() -> bool
```

- Stos okien; `open` kładzie na wierzch (drugi `open` tego samego = przeniesienie na wierzch), `close` zdejmuje
  (także ze środka). Okno usunięte z drzewa (`tree_exiting`) zdejmuje się samo.
- Esc / `menu_cancel` / B na padzie: obsługa w `_input` autoloadu (przed wszystkimi) — gdy stos niepusty i okno na
  wierzchu `closable`, woła na nim `request_close()` (okno samo się chowa i woła `close`), zdarzenie oznaczone.
  Pusty stos + eksploracja = otwarcie pauzy (przeniesione z `pause_menu._input`).
- Pauza gry (`get_tree().paused`) i blokada gracza (`player.input_blocked`) liczone ze stosu: którekolwiek okno
  z `pause` / `blocks_player` — zamiast ustawiania w każdym oknie (dziś: pause_menu, death_screen, end_screen,
  loot_manager, walka/puzzle, enemy_base).
- Okna bez zmian w wyglądzie (sceny WYSIWYG zostają); w skryptach tylko `QuizRpgUi.open(self, …)` przy pokazaniu,
  `close(self)` przy ukryciu i `request_close()`.

## Okna do przepięcia (kolejność = od najprostszych)
1. `minimap.gd` (pełna mapa) — zdjąć grupę `quiz_modal_ui` i `_modal_open()` z pause_menu.
2. `shop_panel.gd`, `skill_teacher_panel.gd`, `upgrade_panel.gd` (NPC; dziś Esc lokalnie + `QuizRpgUiKeys.forward`).
3. `dialog_box.gd`.
4. `autoloads/loot_manager.gd` (podsumowanie skrzyni — pauza).
5. `pause_menu.gd` (pod-tryby: ekwipunek, zapisy, potwierdzenie wyjścia — jedno okno, wewnętrzny „wstecz” zostaje
   w nim; opcje hosta nad pauzą = osobne okno na stosie).
6. `death_screen.gd`, `end_screen.gd` (nie `closable`, pauza).
7. Walka / puzzle (`quiz_combat_controller.gd`, `quiz_puzzle_controller.gd`) — jako okno `blocks_player`, bez pauzy;
   Esc w walce zostaje lokalny (wybór akcji / wstecz), stos tylko blokuje pauzę.

## Zasady
- Po każdym kroku test ręczny: Esc / X / B w danym oknie, pauza z mapy, otwarcie okna podczas innego.
- Commit po każdym oknie (submoduł, potem wskaźnik w hoście).
- Nie ruszać `pause_menu` przed krokami 1–4 (największe ryzyko).
- Usunąć martwe: lokalne obsługi Esc i ustawienia `paused` / `input_blocked` zastąpione stosem.
