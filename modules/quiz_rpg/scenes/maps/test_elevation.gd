extends Node2D

## Ręczna scena testowa platform 2.5D (Faza 0 — bez kodu generacji).
## Namaluj na warstwie "Map" półkę z kafli klifu (te z physics_layer_1/2/3) + schodek.
## Gracz ma ElevationSensorUp (mask 64 = detektor _2) i ElevationSensorDown (mask 128 = detektor _3).
## Label pokazuje na żywo poziom / z_index / maskę kolizji / liczniki nakładania sensorów.

@onready var _player: CharacterBody2D = $Player
@onready var _label: Label = $DebugLayer/Label


## Stub GameManagera — scena uruchamiana samodzielnie nie bootstrapuje modułu quiz_rpg,
## więc CoreManager nie ma zarejestrowanego GameManagera i gracz (bramkowany is_exploring())
## byłby zamrożony. Rejestrujemy go w _enter_tree, BO Player._ready (cache _gm) odpala się PÓŹNIEJ.
class ExploreStub extends Node:
	func is_exploring() -> bool: return true
	func is_in_quiz() -> bool: return false
	func change_state(_s: int) -> void: pass


func _enter_tree() -> void:
	if CoreManager and CoreManager.has_method("get_singleton") and CoreManager.get_singleton("GameManager") == null:
		var stub := ExploreStub.new()
		stub.name = "TestGameManagerStub"
		add_child(stub)
		CoreManager.register_singleton("GameManager", stub)


func _process(_delta: float) -> void:
	if _player == null or _label == null:
		return
	_label.text = "elevation: %d\nz_index: %d\ncollision_mask: %d\nup (_2): %d\ndown (_3): %d\npos: %s" % [
		int(_player.get("elevation")),
		_player.z_index,
		_player.collision_mask,
		int(_player.get("_up_overlaps")),
		int(_player.get("_down_overlaps")),
		str(_player.global_position.round())]
