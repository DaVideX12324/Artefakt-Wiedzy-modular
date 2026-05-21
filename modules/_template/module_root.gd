extends Node

signal exit_requested

const MODULE_ID := "TEMPLATE_MODULE_ID"
const HOST_SCENE_PATH := "res://modules/%s/scenes/game.tscn" % MODULE_ID
const STANDALONE_SCENE_PATH := "res://scenes/game.tscn"

@onready var _scene_root: Node = $SceneRoot

var _host_api
var _manifest: Dictionary = {}


func _ready() -> void:
	call_deferred("_open_default_scene")


func embedded_start(host_api, manifest: Dictionary) -> void:
	_host_api = host_api
	_manifest = manifest.duplicate(true)
	_clear_scene()
	_open_scene(_resolve_scene_path())


func embedded_stop() -> void:
	_clear_scene()
	_host_api = null
	_manifest = {}


func request_exit() -> void:
	if _host_api and _host_api.has_method("request_exit"):
		_host_api.request_exit()
	else:
		exit_requested.emit()


func _open_default_scene() -> void:
	if _scene_root.get_child_count() == 0:
		_open_scene(_resolve_scene_path())


func _resolve_scene_path() -> String:
	if FileAccess.file_exists(STANDALONE_SCENE_PATH):
		return STANDALONE_SCENE_PATH
	return HOST_SCENE_PATH


func _open_scene(path: String) -> void:
	var packed := load(path) as PackedScene
	if packed == null:
		push_warning("Template module cannot load scene: %s" % path)
		return
	_clear_scene()
	_scene_root.add_child(packed.instantiate())


func _clear_scene() -> void:
	for child in _scene_root.get_children():
		child.queue_free()
