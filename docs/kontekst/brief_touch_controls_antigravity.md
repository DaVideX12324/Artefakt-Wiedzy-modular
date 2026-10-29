# Brief dla Antigravity: sterowanie dotykowe (Android)

Godot 4.7, gra „Cień Mgły” (`modules/quiz_rpg`, osobny submoduł git — commituj w nim). Preset Android już jest w `export_presets.cfg`.

## Zadanie
1. Scena WYSIWYG `modules/quiz_rpg/scenes/ui/touch_controls.tscn` (korzeń `CanvasLayer`, layer 100) + skrypt `scripts/ui/touch_controls.gd` (tylko logika, układ w scenie).
   - Lewy dolny róg: wirtualny joystick (baza + gałka, `TextureRect`/`Control`), obsługa `InputEventScreenTouch`/`InputEventScreenDrag` z indeksem palca (multi-touch).
     Joystick wywołuje `Input.action_press/action_release` dla `move_up/move_down/move_left/move_right` (z siłą = wychylenie, martwa strefa 0.2).
   - Prawy dolny róg: przyciski `TouchScreenButton` z polem `action`: `interact` (E), `ui_accept`, `ui_cancel` (pauza/wstecz), `sprint`.
   - Grafiki: wyłącznie istniejące z `assets/UI/Pixel UI pack 3/Full.png` (AtlasTexture), nie kopiuj PNG.
   - Widoczne tylko gdy `DisplayServer.is_touchscreen_available()` lub feature `mobile` (`OS.has_feature("mobile")`); inaczej `queue_free()`.
2. Dodaj scenę do tego samego miejsca co HUD gracza (tam, gdzie instancjonowany jest minimap / interact_prompt — znajdź przez grep `InteractPromptScene`).
3. Ukryj sterowanie, gdy otwarta jest walka, quiz, dialog lub pauza (te UI obsługują dotyk jako kliknięcia myszą — `emulate_mouse_from_touch` jest domyślnie włączone).

## Zasady
- Nie zmieniaj logiki ruchu gracza ani walki — tylko akcje wejścia.
- Nie edytuj `quiz_combat_controller.gd`, `pause_menu.gd` (zrobi to Claude).
- UID w .tscn: baza 34 (znaki a–y i 0–8, bez `z` i `9`).
- Teksty przez i18n (`resources/i18n/pl.json`, `en.json`), jeśli jakieś są.
- Pliki z końcami linii LF.
- Test: uruchom grę z `--screen 1` i w Ustawieniach projektu włącz tymczasowo `input_devices/pointing/emulate_touch_from_mouse` (NIE commituj tego).
