extends Node

## Gałka pada w UI: Godot traktuje każde drgnięcie osi (InputEventJoypadMotion) jako nowe wciśnięcie ui_*, więc fokus
## przeskakuje o wiele pól. Tu ruchy osi ui_* są pochłaniane, a kierunek gałki zamieniany na pojedyncze kroki
## z powtarzaniem przy przytrzymaniu (jak klawiatura). Stan Input (get_vector w grze) zostaje nietknięty.
## Pochłaniane są też osie akcji ruchu modułów (move_*) — menu modułów czytają je jako zdarzenia.
## Domyślne ui_* Godota nie mają przycisków pada — _ready dopisuje A / B i krzyżak.

const ACTIONS: Array[StringName] = [&"ui_up", &"ui_down", &"ui_left", &"ui_right",
	&"move_up", &"move_down", &"move_left", &"move_right"]
const PAD_BUTTONS := {&"ui_accept": JOY_BUTTON_A, &"ui_cancel": JOY_BUTTON_B, &"ui_up": JOY_BUTTON_DPAD_UP,
	&"ui_down": JOY_BUTTON_DPAD_DOWN, &"ui_left": JOY_BUTTON_DPAD_LEFT, &"ui_right": JOY_BUTTON_DPAD_RIGHT}
const DEADZONE := 0.5
## Przytrzymanie kierunku (gałka, krzyżak, strzałki, WASD): pojedynczy krok, po REPEAT_DELAY s przewijanie.
const REPEAT_DELAY := 3.0
const REPEAT_RATE := 0.12

var _held: StringName = &""
var _timer := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for action: StringName in PAD_BUTTONS:
		var ev := InputEventJoypadButton.new()
		ev.device = -1
		ev.button_index = PAD_BUTTONS[action]
		if not InputMap.action_has_event(action, ev):
			InputMap.action_add_event(action, ev)


func _input(event: InputEvent) -> void:
	# Ruch gałki i powtórzenia (echo) klawiszy pochłaniane — kroki i przewijanie robi _process.
	if not (event is InputEventJoypadMotion or event.is_echo()):
		return
	for a in ACTIONS:
		if event.is_action(a):
			get_viewport().set_input_as_handled()
			return


func _process(delta: float) -> void:
	var stick := _stick_action()
	var dir := stick if stick != &"" else _held_button_action()
	if dir != _held:
		_held = dir
		_timer = REPEAT_DELAY
		if stick != &"":  # klawisz / krzyżak dał już pierwszy krok sam
			_press(dir)
		return
	if dir == &"":
		return
	_timer -= delta
	if _timer <= 0.0:
		_timer = REPEAT_RATE
		_press(dir)


## Kierunek trzymany klawiszem / krzyżakiem (ui_* albo move_*) jako akcja ui_* albo "".
func _held_button_action() -> StringName:
	for a in ACTIONS:
		if InputMap.has_action(a) and Input.is_action_pressed(a):
			return StringName("ui_" + str(a).get_slice("_", 1))
	return &""


## Kierunek gałki ponad martwą strefą (dominująca oś) albo "" — tylko z osi, przyciski krzyżaka działają po staremu.
func _stick_action() -> StringName:
	var best: StringName = &""
	var best_v := DEADZONE
	for pad in Input.get_connected_joypads():
		var x := Input.get_joy_axis(pad, JOY_AXIS_LEFT_X)
		var y := Input.get_joy_axis(pad, JOY_AXIS_LEFT_Y)
		for c in [[-y, &"ui_up"], [y, &"ui_down"], [-x, &"ui_left"], [x, &"ui_right"]]:
			if c[0] > best_v:
				best_v = c[0]
				best = c[1]
	return best


func _press(action: StringName) -> void:
	if action == &"":
		return
	# Akcja trzymana klawiszem / krzyżakiem: bez puszczenia — inaczej stan Input gubi trzymanie i przewijanie staje.
	var held := Input.is_action_pressed(action)
	for pressed in ([true] if held else [true, false]):
		var ev := InputEventAction.new()
		ev.action = action
		ev.pressed = pressed
		Input.parse_input_event(ev)
