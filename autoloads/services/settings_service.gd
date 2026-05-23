extends Node

signal resolution_changed(new_resolution: Vector2i)
signal settings_saved
signal settings_loaded

const CONFIG_PATH := "user://artefakt_wiedzy_settings.cfg"
const SEC_DISPLAY := "display"
const SEC_AUDIO := "audio"
const KEY_QUIZLESS_MODE := "quizless_mode"

var _cfg := ConfigFile.new()


func _ready() -> void:
	load_settings()
	UIScaleService.load_from_cfg(_cfg)
	if not resolution_changed.is_connected(UIScaleService.on_resolution_changed):
		resolution_changed.connect(UIScaleService.on_resolution_changed)
	_load_audio()
	WindowService.apply_settings(WindowService.window_mode_idx, WindowService.resolution, WindowService.monitor_idx, false)
	if DisplayServer.get_name() != "headless":
		await get_tree().process_frame
		WindowService.center_on_cursor_screen()


func load_settings() -> void:
	_cfg = ConfigFile.new()
	if _cfg.load(CONFIG_PATH) != OK:
		_load_defaults()
	else:
		WindowService.window_mode_idx = _cfg.get_value(SEC_DISPLAY, "window_mode_idx", WindowService.MODE_FULLSCREEN)
		var default_screen := DisplayServer.screen_get_size(0)
		var width: int = _cfg.get_value(SEC_DISPLAY, "resolution_x", default_screen.x)
		var height: int = _cfg.get_value(SEC_DISPLAY, "resolution_y", default_screen.y)
		WindowService.resolution = Vector2i(width, height)
		WindowService.monitor_idx = _cfg.get_value(SEC_DISPLAY, "monitor_idx", 0)
	WindowService.monitor_idx = clampi(WindowService.monitor_idx, 0, max(0, DisplayServer.get_screen_count() - 1))
	settings_loaded.emit()


func save_settings() -> void:
	_cfg.set_value(SEC_DISPLAY, "window_mode_idx", WindowService.window_mode_idx)
	_cfg.set_value(SEC_DISPLAY, "resolution_x", WindowService.resolution.x)
	_cfg.set_value(SEC_DISPLAY, "resolution_y", WindowService.resolution.y)
	_cfg.set_value(SEC_DISPLAY, "monitor_idx", WindowService.monitor_idx)
	UIScaleService.save_to_cfg(_cfg)
	_save_audio_to_cfg()
	_cfg.save(CONFIG_PATH)
	settings_saved.emit()


func apply_settings(mode_idx: int, res: Vector2i, screen: int) -> void:
	var previous_resolution := WindowService.resolution
	WindowService.apply_settings(mode_idx, res, screen, false)
	save_settings()
	if WindowService.resolution != previous_resolution:
		resolution_changed.emit(WindowService.resolution)


func get_available_resolutions() -> Array[Vector2i]:
	return WindowService.get_available_resolutions(WindowService.monitor_idx)


func get_global(key: String, default_value: Variant = null) -> Variant:
	return _cfg.get_value("global", key, default_value)


func set_global(key: String, value: Variant, save_now: bool = true) -> void:
	_cfg.set_value("global", key, value)
	if save_now:
		save_settings()


func is_quizless_mode_enabled() -> bool:
	for key_name in [KEY_QUIZLESS_MODE, "disable_quizzes", "skip_quizzes"]:
		var value: Variant = get_global(key_name, null)
		if value != null:
			return bool(value)
	return false


func set_quizless_mode_enabled(enabled: bool, save_now: bool = true) -> void:
	set_global(KEY_QUIZLESS_MODE, enabled, false)
	if save_now:
		save_settings()


func get_module(module_id: String, key: String, default_value: Variant = null) -> Variant:
	return _cfg.get_value("module:%s" % module_id, key, default_value)


func set_module(module_id: String, key: String, value: Variant, save_now: bool = true) -> void:
	_cfg.set_value("module:%s" % module_id, key, value)
	if save_now:
		save_settings()


func get_bus_volume(bus_name: String) -> float:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		return 1.0
	return db_to_linear(AudioServer.get_bus_volume_db(index))


func set_bus_volume(bus_name: String, value: float, save_now: bool = true) -> void:
	var index := _ensure_bus(bus_name)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.001)))
	_cfg.set_value(SEC_AUDIO, bus_name.to_lower(), value)
	if save_now:
		save_settings()


func _load_defaults() -> void:
	var native := DisplayServer.screen_get_size(0)
	WindowService.resolution = native
	WindowService.window_mode_idx = WindowService.MODE_FULLSCREEN
	WindowService.monitor_idx = 0


func _load_audio() -> void:
	for bus_name in ["Master", "Music", "SFX"]:
		var value: float = _cfg.get_value(SEC_AUDIO, bus_name.to_lower(), 1.0)
		var index := _ensure_bus(bus_name)
		AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.001)))


func _save_audio_to_cfg() -> void:
	for bus_name in ["Master", "Music", "SFX"]:
		_cfg.set_value(SEC_AUDIO, bus_name.to_lower(), get_bus_volume(bus_name))


func _ensure_bus(bus_name: String) -> int:
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0:
		return index
	AudioServer.add_bus()
	index = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(index, bus_name)
	return index
