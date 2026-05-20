extends CanvasLayer

signal launch_requested(manifest: Dictionary)

@onready var _panel: PanelContainer = $Center/Panel
@onready var _margin: MarginContainer = $Center/Panel/Margin
@onready var _vbox: VBoxContainer = $Center/Panel/Margin/VBox
@onready var _title: Label = $Center/Panel/Margin/VBox/Title
@onready var _subtitle: Label = $Center/Panel/Margin/VBox/Subtitle
@onready var _module_list: VBoxContainer = $Center/Panel/Margin/VBox/ModuleList
@onready var _status: Label = $Center/Panel/Margin/VBox/Status
@onready var _btn_options: Button = $Center/Panel/Margin/VBox/HBoxMeta/BtnOptions
@onready var _btn_quit: Button = $Center/Panel/Margin/VBox/HBoxMeta/BtnQuit
@onready var _ver_label: Label = $VerLabel
@onready var _options_menu: CanvasLayer = $OptionsMenu

const BASE_PANEL_MIN_W := 380.0
const BASE_PANEL_PADDING := 24
const BASE_SEP_VBOX := 12
const BASE_BTN_MODULE := Vector2(360.0, 62.0)
const BASE_BTN_META := Vector2(170.0, 38.0)


func _ready() -> void:
	_btn_options.pressed.connect(_on_options)
	_btn_quit.pressed.connect(_on_quit)
	ModuleRegistry.modules_changed.connect(refresh_modules)
	UIScaleService.scale_changed.connect(_on_scale_changed)
	refresh_modules()
	_on_scale_changed(UIScaleService.scale_factor)


func refresh_modules() -> void:
	for child in _module_list.get_children():
		child.queue_free()

	var modules := ModuleRegistry.all()
	if modules.is_empty():
		_status.text = "Brak modulow w res://modules."
		return

	_status.text = ""
	for manifest in modules:
		if str(manifest.get("id", "")).begins_with("_"):
			continue
		_module_list.add_child(_build_module_button(manifest))

	if _module_list.get_child_count() == 0:
		_status.text = "Brak aktywnych modulow. Template jest ukryty."


func show_status(message: String) -> void:
	_status.text = message


func _build_module_button(manifest: Dictionary) -> Button:
	var button := Button.new()
	button.custom_minimum_size = UIScaleService.sz2(BASE_BTN_MODULE.x, BASE_BTN_MODULE.y)
	button.text = _module_button_text(manifest)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.pressed.connect(func(): launch_requested.emit(manifest))
	return button


func _module_button_text(manifest: Dictionary) -> String:
	var title := str(manifest.get("name", manifest.get("id", "Unknown module")))
	var description := str(manifest.get("description", ""))
	if description == "":
		return title
	return "%s\n%s" % [title, description]


func _on_scale_changed(_scale: float) -> void:
	_panel.custom_minimum_size = Vector2(UIScaleService.sz(BASE_PANEL_MIN_W), 0)
	_vbox.add_theme_constant_override("separation", UIScaleService.px(BASE_SEP_VBOX))

	_title.add_theme_font_size_override("font_size", UIScaleService.px(34))
	_subtitle.add_theme_font_size_override("font_size", UIScaleService.px(15))
	_status.add_theme_font_size_override("font_size", UIScaleService.px(13))
	_ver_label.add_theme_font_size_override("font_size", UIScaleService.px(11))

	_btn_options.add_theme_font_size_override("font_size", UIScaleService.px(17))
	_btn_quit.add_theme_font_size_override("font_size", UIScaleService.px(17))
	_btn_options.custom_minimum_size = UIScaleService.sz2(BASE_BTN_META.x, BASE_BTN_META.y)
	_btn_quit.custom_minimum_size = UIScaleService.sz2(BASE_BTN_META.x, BASE_BTN_META.y)

	for child in _module_list.get_children():
		if child is Button:
			child.add_theme_font_size_override("font_size", UIScaleService.px(18))
			child.custom_minimum_size = UIScaleService.sz2(BASE_BTN_MODULE.x, BASE_BTN_MODULE.y)

	var pad := UIScaleService.px(BASE_PANEL_PADDING)
	_margin.add_theme_constant_override("margin_left", pad)
	_margin.add_theme_constant_override("margin_top", pad)
	_margin.add_theme_constant_override("margin_right", pad)
	_margin.add_theme_constant_override("margin_bottom", pad)


func _on_options() -> void:
	if _options_menu.has_method("open"):
		_options_menu.call("open")
	else:
		_options_menu.visible = true


func _on_quit() -> void:
	get_tree().quit()
