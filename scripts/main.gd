extends Control

const ModuleHostScript := preload("res://scripts/core/module_host.gd")
const MainMenuScene := preload("res://scenes/ui/main_menu.tscn")

var _module_host: ModuleHost
var _module_layer: Control
var _menu


func _ready() -> void:
	_module_layer = Control.new()
	_module_layer.name = "ModuleLayer"
	_module_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_module_layer)

	_module_host = ModuleHostScript.new()
	_module_host.name = "ModuleHost"
	add_child(_module_host)
	_module_host.module_started.connect(_on_module_started)
	_module_host.module_exited.connect(_on_module_exited)
	_module_host.module_failed.connect(_on_module_failed)

	_menu = MainMenuScene.instantiate()
	add_child(_menu)
	_menu.connect("launch_requested", _start_module)


func _start_module(manifest: Dictionary) -> void:
	_menu.visible = false
	_module_host.start_module(manifest, _module_layer)


func _on_module_started(_module_id: String) -> void:
	pass


func _on_module_exited(_module_id: String) -> void:
	_return_to_menu()


func _on_module_failed(_module_id: String, reason: String) -> void:
	_return_to_menu()
	if _menu.has_method("show_status"):
		_menu.call("show_status", reason)


func _return_to_menu() -> void:
	_menu.visible = true
	if _menu.has_method("refresh_modules"):
		_menu.call("refresh_modules")
