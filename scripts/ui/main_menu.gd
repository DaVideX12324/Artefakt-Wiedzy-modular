extends CanvasLayer

signal launch_requested(manifest: Dictionary)

@onready var _panel: PanelContainer = $Center/Panel
@onready var _margin: MarginContainer = $Center/Panel/Margin
@onready var _vbox: VBoxContainer = $Center/Panel/Margin/VBox
@onready var _title: Label = $Center/Panel/Margin/VBox/Title
@onready var _subtitle: Label = $Center/Panel/Margin/VBox/Subtitle
@onready var _module_list: VBoxContainer = $Center/Panel/Margin/VBox/ModuleList
@onready var _status: Label = $Center/Panel/Margin/VBox/Status
@onready var _btn_questions: Button = $Center/Panel/Margin/VBox/HBoxMeta/BtnQuestions
@onready var _btn_options: Button = $Center/Panel/Margin/VBox/HBoxMeta/BtnOptions
@onready var _btn_credits: Button = $Center/Panel/Margin/VBox/HBoxMeta/BtnCredits
@onready var _btn_quit: Button = $Center/Panel/Margin/VBox/HBoxMeta/BtnQuit
@onready var _ver_label: Label = $VerLabel
@onready var _update_btn: LinkButton = $UpdateBtn
@onready var _options_menu: CanvasLayer = $OptionsMenu
@onready var _question_editor: CanvasLayer = $QuestionEditor
@onready var _credits: CanvasLayer = $CreditsScreen

const BASE_PANEL_MIN_W := 380.0
const BASE_PANEL_PADDING := 24
const BASE_SEP_VBOX := 12
const BASE_BTN_MODULE := Vector2(360.0, 62.0)
const BASE_BTN_META := Vector2(170.0, 38.0)


func _ready() -> void:
	_btn_questions.pressed.connect(_on_questions)
	_btn_options.pressed.connect(_on_options)
	_btn_credits.pressed.connect(_on_credits)
	_btn_quit.pressed.connect(_on_quit)
	ModuleRegistry.modules_changed.connect(refresh_modules)
	UIScaleService.scale_changed.connect(_on_scale_changed)
	if I18nService:
		I18nService.language_changed.connect(func(_l: String) -> void: refresh_modules())
	refresh_modules()
	_ver_label.text = "Artefakt Wiedzy " + version_label(UpdateService.current_version()) + build_suffix()
	_on_scale_changed(UIScaleService.scale_factor)
	UpdateService.update_available.connect(_on_update_available)
	if AudioService:
		AudioService.play_music("host_menu")
	# Menu jest ukrywane na czas modułu i pokazywane po wyjściu z niego — wtedy wraca muzyka menu
	# (inaczej grała dalej muzyka poziomu modułu).
	visibility_changed.connect(func() -> void:
		if visible and AudioService:
			AudioService.play_music("host_menu"))


func refresh_modules() -> void:
	for child in _module_list.get_children():
		child.queue_free()

	var modules := ModuleRegistry.all()
	if modules.is_empty():
		_status.text = I18nService.t("host.menu.no_modules", "Brak modułów w res://modules.")
		return

	_status.text = ""
	for manifest in modules:
		if str(manifest.get("id", "")).begins_with("_"):
			continue
		_module_list.add_child(_build_module_button(manifest))

	if _module_list.get_child_count() == 0:
		_status.text = I18nService.t("host.menu.no_active_modules", "Brak aktywnych modułów. Template jest ukryty.")


func show_status(message: String) -> void:
	_status.text = message


func _build_module_button(manifest: Dictionary) -> Button:
	var button := Button.new()
	button.custom_minimum_size = UIScaleService.sz2(BASE_BTN_MODULE.x, BASE_BTN_MODULE.y)
	# Rozmiar od razu — lista budowana jest też po powrocie z modułu, a _on_scale_changed woła się tylko przy zmianie skali.
	button.add_theme_font_size_override("font_size", UIScaleService.px(18))
	button.text = _module_button_text(manifest)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.pressed.connect(func():
		if AudioService: AudioService.play_sfx_by_name("click")
		launch_requested.emit(manifest)
	)
	return button


func _module_button_text(manifest: Dictionary) -> String:
	var unknown_name: String = I18nService.t("host.menu.unknown_module") if I18nService else "Unknown"
	var title := str(manifest.get("name", manifest.get("id", unknown_name)))
	var version := str(manifest.get("version", ""))
	var lines: Array[String] = [title + ("  ·  " + version_label(version) if version != "" else "")]
	var description := str(manifest.get("description", ""))
	if description != "":
		lines.append(description)
	# Ostatni wynik sesji (SessionResults) — tekst „summary” przygotowany przez moduł.
	var summary := str(SessionResults.get_last(str(manifest.get("id", ""))).get("summary", ""))
	if summary != "":
		lines.append(I18nService.tf("host.menu.last_session", {"summary": summary}, "Ostatnio: {summary}"))
	return "\n".join(lines)


## " (build N)" z resources/build.json (podbijany przy eksporcie release przez wtyczkę ExportCheck); bez pliku — "".
## Info z UpdateService: link do pełnego exe albo (url pusty) prośba o ponowne uruchomienie po pobraniu paczek.
func _on_update_available(text: String, url: String) -> void:
	_update_btn.text = text
	_update_btn.uri = url
	_update_btn.disabled = url == ""
	_update_btn.visible = true


static func build_suffix() -> String:
	var build := UpdateService.current_build()
	return " (build %d)" % build if build > 0 else ""


## Wersja do wyświetlenia: "0.8.0-alpha" -> "0.8.0 Alpha" (zasady: docs/wersjonowanie.md).
static func version_label(version: String) -> String:
	var parts := version.split("-", true, 1)
	if parts.size() < 2:
		return version
	var stage := parts[1]
	stage = "RC" + stage.substr(2) if stage.begins_with("rc") else stage.left(1).to_upper() + stage.substr(1)
	return "%s %s" % [parts[0], stage]


func _on_scale_changed(_scale: float) -> void:
	_panel.custom_minimum_size = Vector2(UIScaleService.sz(BASE_PANEL_MIN_W), 0)
	_vbox.add_theme_constant_override("separation", UIScaleService.px(BASE_SEP_VBOX))

	_title.add_theme_font_size_override("font_size", UIScaleService.px(34))
	_subtitle.add_theme_font_size_override("font_size", UIScaleService.px(15))
	_status.add_theme_font_size_override("font_size", UIScaleService.px(13))
	_ver_label.add_theme_font_size_override("font_size", UIScaleService.px(11))

	_btn_questions.add_theme_font_size_override("font_size", UIScaleService.px(17))
	_btn_questions.custom_minimum_size = UIScaleService.sz2(BASE_BTN_META.x, BASE_BTN_META.y)
	_btn_options.add_theme_font_size_override("font_size", UIScaleService.px(17))
	_btn_quit.add_theme_font_size_override("font_size", UIScaleService.px(17))
	_btn_options.custom_minimum_size = UIScaleService.sz2(BASE_BTN_META.x, BASE_BTN_META.y)
	_btn_quit.custom_minimum_size = UIScaleService.sz2(BASE_BTN_META.x, BASE_BTN_META.y)
	_btn_credits.add_theme_font_size_override("font_size", UIScaleService.px(17))
	_btn_credits.custom_minimum_size = UIScaleService.sz2(BASE_BTN_META.x, BASE_BTN_META.y)

	for child in _module_list.get_children():
		if child is Button:
			child.add_theme_font_size_override("font_size", UIScaleService.px(18))
			child.custom_minimum_size = UIScaleService.sz2(BASE_BTN_MODULE.x, BASE_BTN_MODULE.y)

	var pad := UIScaleService.px(BASE_PANEL_PADDING)
	_margin.add_theme_constant_override("margin_left", pad)
	_margin.add_theme_constant_override("margin_top", pad)
	_margin.add_theme_constant_override("margin_right", pad)
	_margin.add_theme_constant_override("margin_bottom", pad)


## Edytor pytań: zestawy, import JSON, edycja pytań, wybór używanych w grze.
func _on_questions() -> void:
	if AudioService: AudioService.play_sfx_by_name("click")
	_question_editor.call("open")


func _on_options() -> void:
	if AudioService: AudioService.play_sfx_by_name("click")
	if _options_menu.has_method("open"):
		_options_menu.call("open")
	else:
		_options_menu.visible = true


func _on_credits() -> void:
	if AudioService: AudioService.play_sfx_by_name("click")
	_credits.call("open")


func _on_quit() -> void:
	if AudioService: AudioService.play_sfx_by_name("click")
	get_tree().quit()
