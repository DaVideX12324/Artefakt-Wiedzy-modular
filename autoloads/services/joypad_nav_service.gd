extends Node

## Gałka pada w UI: Godot traktuje każde drgnięcie osi (InputEventJoypadMotion) jako nowe wciśnięcie ui_*, więc fokus
## przeskakuje o wiele pól. Tu ruchy osi ui_* są pochłaniane, a kierunek gałki zamieniany na pojedyncze kroki
## z powtarzaniem przy przytrzymaniu (jak klawiatura). Stan Input (get_vector w grze) zostaje nietknięty.

const ACTIONS: Array[StringName] = [&"ui_up", &"ui_down", &"ui_left", &"ui_right"]
const DEADZONE := 0.5
const REPEAT_DELAY := 0.4
const REPEAT_RATE := 0.12

var _held: StringName = &""
var _timer := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if not event is InputEventJoypadMotion:
		return
	for a in ACTIONS:
		if event.is_action(a):
			get_viewport().set_input_as_handled()
			return


func _process(delta: float) -> void:
	var dir := _stick_action()
	if dir != _held:
		_held = dir
		_timer = REPEAT_DELAY
		_press(dir)
		return
	if dir == &"":
		return
	_timer -= delta
	if _timer <= 0.0:
		_timer = REPEAT_RATE
		_press(dir)


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
	for pressed in [true, false]:
		var ev := InputEventAction.new()
		ev.action = action
		ev.pressed = pressed
		Input.parse_input_event(ev)
