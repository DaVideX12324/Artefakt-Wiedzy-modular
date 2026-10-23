extends Control

const ModuleHostScript := preload("res://scripts/core/module_host.gd")
const MainMenuScene := preload("res://scenes/ui/main_menu.tscn")

var _module_host: ModuleHost
var _module_layer: Control
var _menu
var _transition: ModuleTransition


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
	_module_host.module_exiting.connect(_on_module_exiting)

	_menu = MainMenuScene.instantiate()
	add_child(_menu)
	_menu.connect("launch_requested", _start_module)


## Wejście do modułu: ekran przejścia powstaje pierwszy i jest narysowany, zanim ruszy wczytywanie (scena wejściowa
## w tle, pasek za postępem) i start modułu — ścinka dzieje się pod zasłoną.
func _start_module(manifest: Dictionary, session_config: Dictionary = {}) -> void:
	var default_mod_name: String = I18nService.t("host.transition.default_module") if I18nService else "Module"
	var load_text: String = I18nService.t("host.transition.loading") if I18nService else "Loading"
	_show_transition(str(manifest.get("name", manifest.get("id", default_mod_name))), load_text)
	await _transition.painted()
	var entry_path := str(manifest.get("entry_scene_path", ""))
	if entry_path != "" and ResourceLoader.exists(entry_path):
		ResourceLoader.load_threaded_request(entry_path)
		var progress: Array = []
		while ResourceLoader.load_threaded_get_status(entry_path, progress) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_transition.set_progress(float(progress[0]) * 0.8 if not progress.is_empty() else 0.0)
			await get_tree().process_frame
		var start_text: String = I18nService.t("host.transition.starting") if I18nService else "Starting"
		_transition.set_progress(0.8, start_text)
		await get_tree().process_frame
	_menu.visible = false
	_module_host.start_module(manifest, _module_layer, session_config)


func _on_module_started(_module_id: String) -> void:
	_hide_transition_after_frames()


func _on_module_exiting(_module_id: String) -> void:
	var closing_text: String = I18nService.t("host.transition.closing_game") if I18nService else "Closing game"
	_show_transition("Artefakt Wiedzy", closing_text)


func _on_module_exited(_module_id: String) -> void:
	_return_to_menu()
	_hide_transition_after_frames()


func _on_module_failed(_module_id: String, reason: String) -> void:
	_return_to_menu()
	_hide_transition_after_frames()
	if _menu.has_method("show_status"):
		_menu.call("show_status", reason)


func _show_transition(title: String, stage: String) -> void:
	if is_instance_valid(_transition) and _transition.is_active():
		_transition.reset(title, stage)
		return
	_transition = ModuleTransition.open(get_tree(), title, stage)


## Zdejmuje ekran po kilku klatkach — pierwsze klatki nowej sceny (menu modułu / hosta) są już narysowane.
func _hide_transition_after_frames() -> void:
	if not is_instance_valid(_transition):
		return
	var t := _transition
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2, true).timeout
	if is_instance_valid(t):
		t.fade_out()


func _return_to_menu() -> void:
	_menu.visible = true
	if _menu.has_method("refresh_modules"):
		_menu.call("refresh_modules")
