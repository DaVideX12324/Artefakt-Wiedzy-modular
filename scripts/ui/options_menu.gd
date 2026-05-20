extends CanvasLayer

@onready var _btn_windowed: Button = $Panel/Margin/VBox/Tabs/Ekran/HBoxMode/BtnWindowed
@onready var _btn_borderless: Button = $Panel/Margin/VBox/Tabs/Ekran/HBoxMode/BtnBorderless
@onready var _btn_fullscreen: Button = $Panel/Margin/VBox/Tabs/Ekran/HBoxMode/BtnFullscreen
@onready var _res_option: OptionButton = $Panel/Margin/VBox/Tabs/Ekran/ResOption
@onready var _res_note: Label = $Panel/Margin/VBox/Tabs/Ekran/ResNote
@onready var _monitor_option: OptionButton = $Panel/Margin/VBox/Tabs/Ekran/MonitorOption
@onready var _scale_option: OptionButton = $Panel/Margin/VBox/Tabs/Ekran/ScaleOption
@onready var _mode_label: Label = $Panel/Margin/VBox/Tabs/Ekran/ModeLabel
@onready var _monitor_label: Label = $Panel/Margin/VBox/Tabs/Ekran/MonitorLabel
@onready var _res_label: Label = $Panel/Margin/VBox/Tabs/Ekran/ResLabel
@onready var _scale_label: Label = $Panel/Margin/VBox/Tabs/Ekran/ScaleLabel

@onready var _slider_master: HSlider = $Panel/Margin/VBox/Tabs/Dzwiek/SliderMaster
@onready var _slider_music: HSlider = $Panel/Margin/VBox/Tabs/Dzwiek/SliderMusic
@onready var _slider_sfx: HSlider = $Panel/Margin/VBox/Tabs/Dzwiek/SliderSfx
@onready var _lbl_master: Label = $Panel/Margin/VBox/Tabs/Dzwiek/LblMaster
@onready var _lbl_music: Label = $Panel/Margin/VBox/Tabs/Dzwiek/LblMusic
@onready var _lbl_sfx: Label = $Panel/Margin/VBox/Tabs/Dzwiek/LblSfx

@onready var _binds_list: VBoxContainer = $Panel/Margin/VBox/Tabs/Sterowanie/BindsList
@onready var _lbl_info: Label = $Panel/Margin/VBox/Tabs/Sterowanie/LblInfo

@onready var _panel: PanelContainer = $Panel
@onready var _margin: MarginContainer = $Panel/Margin
@onready var _title_label: Label = $Panel/Margin/VBox/Title
@onready var _tabs: TabContainer = $Panel/Margin/VBox/Tabs
@onready var _btn_apply: Button = $Panel/Margin/VBox/HBoxButtons/BtnApply
@onready var _btn_close: Button = $Panel/Margin/VBox/HBoxButtons/BtnClose

@onready var _confirm_popup: PanelContainer = $ConfirmPopup
@onready var _lbl_countdown: Label = $ConfirmPopup/VBoxConfirm/LblCountdown
@onready var _lbl_question: Label = $ConfirmPopup/VBoxConfirm/LblQuestion
@onready var _btn_confirm: Button = $ConfirmPopup/VBoxConfirm/HBoxConfirm/BtnConfirm
@onready var _btn_revert: Button = $ConfirmPopup/VBoxConfirm/HBoxConfirm/BtnRevert

const CONFIRM_TIMEOUT := 20.0

const BASE_PANEL_HALF_W := 300.0
const BASE_PANEL_HALF_H := 360.0
const BASE_CONFIRM_HALF_W := 220.0
const BASE_CONFIRM_HALF_H := 100.0
const BASE_BTN_MODE_SIZE := Vector2(80.0, 36.0)
const BASE_BTN_ACTION_SIZE := Vector2(130.0, 40.0)
const BASE_BTN_CONFIRM_SIZE := Vector2(140.0, 40.0)
const BASE_PANEL_PADDING := 20

const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

const BINDS: Array = [
	["Gracz 1 - ruch", ["p1_up", "p1_down", "p1_left", "p1_right", "move_up", "move_down", "move_left", "move_right"]],
	["Gracz 1 - akcja", ["p1_bomb", "interact"]],
	["Gracz 2 - ruch", ["p2_up", "p2_down", "p2_left", "p2_right"]],
	["Gracz 2 - akcja", ["p2_bomb"]],
	["Pauza", ["pause", "ui_cancel"]],
]

var _mode_btns: Array[Button] = []
var _resolutions: Array[Vector2i] = []

var _sel_mode := WindowService.MODE_WINDOWED
var _sel_scale: int = UIScaleService.ScaleMode.NORMAL
var _scale_manually_changed := false

var _prev_mode := WindowService.MODE_WINDOWED
var _prev_res := Vector2i(1280, 720)
var _prev_monitor := 0
var _prev_scale: int = UIScaleService.ScaleMode.NORMAL
var _prev_scale_user_picked := false

var _countdown := 0.0
var _confirming := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_mode_btns = [_btn_windowed, _btn_borderless, _btn_fullscreen]
	_btn_apply.pressed.connect(_on_apply)
	_btn_close.pressed.connect(_on_close)
	_btn_confirm.pressed.connect(_on_confirm)
	_btn_revert.pressed.connect(_on_revert)
	for index in range(_mode_btns.size()):
		var mode := index
		_mode_btns[index].pressed.connect(func(): _select_mode(mode))
	_populate_monitors()
	_monitor_option.item_selected.connect(_on_monitor_changed)
	_populate_resolutions(_monitor_option.selected)
	_populate_scale()
	_setup_audio_sliders()
	_populate_binds()
	UIScaleService.scale_changed.connect(_on_scale_changed)
	_on_scale_changed(UIScaleService.scale_factor)


func _process(delta: float) -> void:
	if not _confirming:
		return
	_countdown -= delta
	if _countdown <= 0.0:
		_on_revert()
		return
	_lbl_countdown.text = "Przywrocenie za: %ds" % ceili(_countdown)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		if _confirming:
			_on_revert()
		else:
			_on_close()
		get_viewport().set_input_as_handled()


func open() -> void:
	_prev_mode = WindowService.window_mode_idx
	_prev_res = WindowService.resolution
	_prev_monitor = WindowService.monitor_idx
	_prev_scale = UIScaleService.current_mode
	_prev_scale_user_picked = UIScaleService.user_picked
	_sel_mode = _prev_mode
	_sel_scale = _prev_scale
	_scale_manually_changed = false
	_sync_mode_buttons()
	_monitor_option.selected = _prev_monitor
	_populate_resolutions(_prev_monitor)
	_sync_resolution()
	_sync_scale()
	_sync_audio_sliders()
	visible = true


func _on_close() -> void:
	if _confirming:
		_on_revert()
	else:
		hide()


func _select_mode(mode: int) -> void:
	_sel_mode = mode
	_sync_mode_buttons()


func _sync_mode_buttons() -> void:
	for index in range(_mode_btns.size()):
		_mode_btns[index].button_pressed = index == _sel_mode
	_update_res_note()


func _sync_resolution() -> void:
	for index in range(_resolutions.size()):
		if _resolutions[index] == WindowService.resolution:
			_res_option.selected = index
			return
	_res_option.selected = 0


func _sync_scale() -> void:
	_scale_option.selected = UIScaleService.current_mode


func _populate_monitors() -> void:
	_monitor_option.clear()
	for index in range(DisplayServer.get_screen_count()):
		var size := DisplayServer.screen_get_size(index)
		var label := "Monitor %d (%d x %d)" % [index + 1, size.x, size.y]
		if index == DisplayServer.get_primary_screen():
			label += " [glowny]"
		_monitor_option.add_item(label)


func _on_monitor_changed(index: int) -> void:
	_populate_resolutions(index)
	_res_option.selected = max(0, _resolutions.size() - 1)


func _populate_resolutions(screen: int) -> void:
	_resolutions = WindowService.get_available_resolutions(screen)
	_res_option.clear()
	var screen_size := DisplayServer.screen_get_size(screen)
	for resolution in _resolutions:
		var label := "%d x %d" % [resolution.x, resolution.y]
		if resolution == screen_size:
			label += " (natywna)"
		_res_option.add_item(label)


func _populate_scale() -> void:
	_scale_option.clear()
	for label in UIScaleService.get_mode_labels():
		_scale_option.add_item(label)
	_sync_scale()
	if not _scale_option.item_selected.is_connected(_on_scale_item_selected):
		_scale_option.item_selected.connect(_on_scale_item_selected)


func _on_scale_item_selected(index: int) -> void:
	_sel_scale = index
	_scale_manually_changed = true


func _update_res_note() -> void:
	_res_option.disabled = false
	_res_note.visible = false


func _setup_audio_sliders() -> void:
	_slider_master.value_changed.connect(func(value: float): _on_bus_changed(BUS_MASTER, value))
	_slider_music.value_changed.connect(func(value: float): _on_bus_changed(BUS_MUSIC, value))
	_slider_sfx.value_changed.connect(func(value: float): _on_bus_changed(BUS_SFX, value))


func _sync_audio_sliders() -> void:
	_slider_master.value = SettingsService.get_bus_volume(BUS_MASTER)
	_slider_music.value = SettingsService.get_bus_volume(BUS_MUSIC)
	_slider_sfx.value = SettingsService.get_bus_volume(BUS_SFX)


func _on_bus_changed(bus_name: String, value: float) -> void:
	SettingsService.set_bus_volume(bus_name, value, true)


func _populate_binds() -> void:
	for child in _binds_list.get_children():
		child.queue_free()
	for entry in BINDS:
		var section: String = entry[0]
		var actions: Array = entry[1]
		var lbl_sec := Label.new()
		lbl_sec.text = section
		lbl_sec.add_theme_font_size_override("font_size", UIScaleService.px(14))
		lbl_sec.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
		_binds_list.add_child(lbl_sec)
		var keys: Array[String] = []
		for action in actions:
			if not InputMap.has_action(action):
				continue
			for event in InputMap.action_get_events(action):
				if event is InputEventKey:
					keys.append(event.as_text_physical_keycode())
					break
		var lbl_keys := Label.new()
		lbl_keys.text = "  " + ", ".join(keys) if keys.size() > 0 else "  (brak)"
		lbl_keys.add_theme_font_size_override("font_size", UIScaleService.px(13))
		lbl_keys.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6))
		_binds_list.add_child(lbl_keys)


func _on_apply() -> void:
	var resolution_index := _res_option.selected
	var resolution := WindowService.resolution
	if resolution_index >= 0 and resolution_index < _resolutions.size():
		resolution = _resolutions[resolution_index]
	if _scale_manually_changed:
		UIScaleService.set_mode(_sel_scale)
	else:
		if not _prev_scale_user_picked:
			UIScaleService.reset_to_auto()
	SettingsService.apply_settings(_sel_mode, resolution, _monitor_option.selected)
	_start_confirm()


func _start_confirm() -> void:
	_countdown = CONFIRM_TIMEOUT
	_confirming = true
	_confirm_popup.visible = true
	_lbl_countdown.text = "Przywrocenie za: %ds" % ceili(_countdown)


func _on_confirm() -> void:
	_confirming = false
	_confirm_popup.visible = false
	hide()


func _on_revert() -> void:
	_confirming = false
	_confirm_popup.visible = false
	_scale_manually_changed = false
	if _prev_scale_user_picked:
		UIScaleService.set_mode(_prev_scale)
	else:
		UIScaleService.reset_to_auto()
	SettingsService.apply_settings(_prev_mode, _prev_res, _prev_monitor)
	_sel_mode = _prev_mode
	_sel_scale = _prev_scale
	_sync_mode_buttons()
	_monitor_option.selected = _prev_monitor
	_populate_resolutions(_prev_monitor)
	_sync_resolution()
	_sync_scale()
	_sync_audio_sliders()


func _on_scale_changed(_scale: float) -> void:
	var main_size := UIScaleService.px(18)
	_title_label.add_theme_font_size_override("font_size", UIScaleService.px(26))
	_tabs.add_theme_font_size_override("font_size", UIScaleService.px(17))
	_mode_label.add_theme_font_size_override("font_size", main_size)
	_monitor_label.add_theme_font_size_override("font_size", main_size)
	_res_label.add_theme_font_size_override("font_size", main_size)
	_res_note.add_theme_font_size_override("font_size", UIScaleService.px(15))
	_scale_label.add_theme_font_size_override("font_size", main_size)
	_monitor_option.add_theme_font_size_override("font_size", main_size)
	_res_option.add_theme_font_size_override("font_size", main_size)
	_scale_option.add_theme_font_size_override("font_size", main_size)
	_scale_popup_font(_monitor_option, main_size)
	_scale_popup_font(_res_option, main_size)
	_scale_popup_font(_scale_option, main_size)
	_lbl_master.add_theme_font_size_override("font_size", main_size)
	_lbl_music.add_theme_font_size_override("font_size", main_size)
	_lbl_sfx.add_theme_font_size_override("font_size", main_size)
	_lbl_info.add_theme_font_size_override("font_size", UIScaleService.px(14))
	for child in _binds_list.get_children():
		if child is Label:
			child.add_theme_font_size_override("font_size", UIScaleService.px(14))
	_btn_apply.add_theme_font_size_override("font_size", UIScaleService.px(20))
	_btn_close.add_theme_font_size_override("font_size", UIScaleService.px(20))
	_lbl_question.add_theme_font_size_override("font_size", UIScaleService.px(18))
	_lbl_countdown.add_theme_font_size_override("font_size", UIScaleService.px(22))
	_btn_confirm.add_theme_font_size_override("font_size", UIScaleService.px(20))
	_btn_revert.add_theme_font_size_override("font_size", UIScaleService.px(20))
	var mode_font_size := UIScaleService.px(15)
	for button in _mode_btns:
		button.add_theme_font_size_override("font_size", mode_font_size)
		button.custom_minimum_size = UIScaleService.sz2(BASE_BTN_MODE_SIZE.x, BASE_BTN_MODE_SIZE.y)
	_btn_apply.custom_minimum_size = UIScaleService.sz2(BASE_BTN_ACTION_SIZE.x, BASE_BTN_ACTION_SIZE.y)
	_btn_close.custom_minimum_size = UIScaleService.sz2(BASE_BTN_ACTION_SIZE.x, BASE_BTN_ACTION_SIZE.y)
	_btn_confirm.custom_minimum_size = UIScaleService.sz2(BASE_BTN_CONFIRM_SIZE.x, BASE_BTN_CONFIRM_SIZE.y)
	_btn_revert.custom_minimum_size = UIScaleService.sz2(BASE_BTN_CONFIRM_SIZE.x, BASE_BTN_CONFIRM_SIZE.y)
	var panel_half_w := UIScaleService.sz(BASE_PANEL_HALF_W)
	var panel_half_h := UIScaleService.sz(BASE_PANEL_HALF_H)
	_panel.offset_left = -panel_half_w
	_panel.offset_top = -panel_half_h
	_panel.offset_right = panel_half_w
	_panel.offset_bottom = panel_half_h
	var confirm_half_w := UIScaleService.sz(BASE_CONFIRM_HALF_W)
	var confirm_half_h := UIScaleService.sz(BASE_CONFIRM_HALF_H)
	_confirm_popup.offset_left = -confirm_half_w
	_confirm_popup.offset_top = -confirm_half_h
	_confirm_popup.offset_right = confirm_half_w
	_confirm_popup.offset_bottom = confirm_half_h
	var pad := UIScaleService.px(BASE_PANEL_PADDING)
	_margin.add_theme_constant_override("margin_left", pad)
	_margin.add_theme_constant_override("margin_top", pad)
	_margin.add_theme_constant_override("margin_right", pad)
	_margin.add_theme_constant_override("margin_bottom", pad)


func _scale_popup_font(option: OptionButton, font_size: int) -> void:
	option.get_popup().add_theme_font_size_override("font_size", font_size)
