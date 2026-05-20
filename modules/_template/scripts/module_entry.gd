extends Control

signal exit_requested

@onready var _title: Label = $Panel/Margin/VBox/Title
@onready var _mode: Label = $Panel/Margin/VBox/Mode
@onready var _exit_button: Button = $Panel/Margin/VBox/ExitButton

var _host_api
var _manifest: Dictionary = {}


func _ready() -> void:
	_exit_button.pressed.connect(_on_exit_pressed)
	_refresh_text()


func embedded_start(host_api, manifest: Dictionary) -> void:
	_host_api = host_api
	_manifest = manifest
	_refresh_text()


func embedded_stop() -> void:
	_host_api = null
	_manifest = {}


func _refresh_text() -> void:
	if not is_node_ready():
		return
	var module_name := str(_manifest.get("name", "Template Module"))
	_title.text = module_name
	_mode.text = "Tryb: embedded" if _host_api else "Tryb: standalone"


func _on_exit_pressed() -> void:
	if _host_api:
		_host_api.request_exit()
	else:
		get_tree().quit()
