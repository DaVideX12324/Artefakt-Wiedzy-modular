extends CanvasLayer

## DevMenu — Menu Deweloperskie / Debug Menu
## Dostępne pod F1, tyldą (~) lub przyciskiem w prawym górnym rogu ekranu.

signal menu_visibility_changed(is_visible: bool)

var _main_panel: PanelContainer
var _drag_button: Control
var _is_dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

# Przełączniki i kontrolki
var _btn_toggle_enemies: CheckButton
var _btn_toggle_quizzes: CheckButton
var _btn_toggle_god_mode: CheckButton
var _btn_instant_win: Button
var _btn_full_heal: Button
var _btn_add_xp: Button
var _btn_add_streak: Button
var _opt_speed: OptionButton
var _opt_quizzes: OptionButton
var _opt_quiz_layout: OptionButton
var _lbl_fps: Label
var _lbl_info: Label

var _floating_toggle_btn: Button


func _ready() -> void:
	layer = 125
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_floating_button()
	_build_menu_ui()
	_refresh_controls_state()

	var cheat_service := get_node_or_null("/root/CheatService")
	if cheat_service:
		if cheat_service.has_signal("enemies_toggled"):
			cheat_service.enemies_toggled.connect(func(_val): _refresh_controls_state())
		if cheat_service.has_signal("quizzes_toggled"):
			cheat_service.quizzes_toggled.connect(func(_val): _refresh_controls_state())
		if cheat_service.has_signal("god_mode_toggled"):
			cheat_service.god_mode_toggled.connect(func(_val): _refresh_controls_state())


func _process(_delta: float) -> void:
	if _main_panel and _main_panel.visible:
		if _lbl_fps:
			_lbl_fps.text = "FPS: %d | Klatka: %.1f ms" % [Engine.get_frames_per_second(), (1.0 / max(1.0, float(Engine.get_frames_per_second()))) * 1000.0]
		if _lbl_info:
			var core_mgr = get_node_or_null("/root/CoreManager")
			var mod_id: String = core_mgr.get_active_module_id() if core_mgr and core_mgr.has_method("get_active_module_id") else "Brak"
			var gm = core_mgr.get_singleton("GameManager") if core_mgr else null
			var state_str: String = str(gm.current_state) if gm and "current_state" in gm else "-"
			var ps = core_mgr.get_singleton("PlayerStats") if core_mgr else null
			var hp_str: String = "%d/%d" % [ps.hp, ps.max_hp] if ps and "hp" in ps else "-"
			_lbl_info.text = "Moduł: %s | Stan gry: %s | HP gracza: %s" % [mod_id, state_str, hp_str]


func toggle() -> void:
	if _main_panel == null:
		return
	_main_panel.visible = not _main_panel.visible
	if _main_panel.visible:
		_refresh_controls_state()
	menu_visibility_changed.emit(_main_panel.visible)


func open() -> void:
	if _main_panel and not _main_panel.visible:
		toggle()


func close() -> void:
	if _main_panel and _main_panel.visible:
		toggle()


func is_menu_open() -> bool:
	return _main_panel != null and _main_panel.visible


func _refresh_controls_state() -> void:
	var cheat_service = get_node_or_null("/root/CheatService")
	var settings_service = get_node_or_null("/root/SettingsService")

	if _btn_toggle_enemies and cheat_service and "enemies_disabled" in cheat_service:
		_btn_toggle_enemies.set_pressed_no_signal(bool(cheat_service.enemies_disabled))
		_btn_toggle_enemies.text = "Przeciwnicy: WYŁĄCZENI" if cheat_service.enemies_disabled else "Przeciwnicy: WŁĄCZENI (Normalnie)"

	if _btn_toggle_quizzes and settings_service and settings_service.has_method("is_quizless_mode_enabled"):
		var is_quizless: bool = settings_service.is_quizless_mode_enabled()
		_btn_toggle_quizzes.set_pressed_no_signal(is_quizless)
		_btn_toggle_quizzes.text = "Quizy: WYŁĄCZONE (Auto-pass)" if is_quizless else "Quizy: WŁĄCZONE (Standard)"

	if _btn_toggle_god_mode and cheat_service and "god_mode" in cheat_service:
		_btn_toggle_god_mode.set_pressed_no_signal(bool(cheat_service.god_mode))
		_btn_toggle_god_mode.text = "God Mode: AKTYWNY (Nieskończone HP)" if cheat_service.god_mode else "God Mode: Wyłączony"

	if _opt_speed and cheat_service and "player_speed_mult" in cheat_service:
		var mult: float = float(cheat_service.player_speed_mult)
		if is_equal_approx(mult, 1.0): _opt_speed.selected = 0
		elif is_equal_approx(mult, 1.5): _opt_speed.selected = 1
		elif is_equal_approx(mult, 2.0): _opt_speed.selected = 2
		elif is_equal_approx(mult, 3.0): _opt_speed.selected = 3

	if _opt_quizzes and cheat_service:
		var active_quiz: String = str(cheat_service.active_quiz_override) if "active_quiz_override" in cheat_service else ""
		for i in range(_opt_quizzes.item_count):
			if _opt_quizzes.get_item_metadata(i) == active_quiz:
				_opt_quizzes.selected = i
				break

	if _opt_quiz_layout and cheat_service and "quiz_ui_mode" in cheat_service:
		_opt_quiz_layout.selected = 1 if cheat_service.quiz_ui_mode == "popup" else 0


func _build_floating_button() -> void:
	_floating_toggle_btn = Button.new()
	_floating_toggle_btn.text = "🛠️ DEV"
	_floating_toggle_btn.tooltip_text = "Menu Deweloperskie [F1 / ~]"
	_floating_toggle_btn.focus_mode = Control.FOCUS_NONE
	_floating_toggle_btn.mouse_filter = Control.MOUSE_FILTER_STOP

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.18, 0.85)
	style.border_color = Color(0.3, 0.6, 1.0, 0.7)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	_floating_toggle_btn.add_theme_stylebox_override("normal", style)

	_floating_toggle_btn.anchor_left = 1.0
	_floating_toggle_btn.anchor_right = 1.0
	_floating_toggle_btn.anchor_top = 0.0
	_floating_toggle_btn.anchor_bottom = 0.0
	_floating_toggle_btn.offset_left = -78
	_floating_toggle_btn.offset_right = -12
	_floating_toggle_btn.offset_top = 10
	_floating_toggle_btn.offset_bottom = 36
	_floating_toggle_btn.pressed.connect(toggle)

	add_child(_floating_toggle_btn)


func _build_menu_ui() -> void:
	_main_panel = PanelContainer.new()
	_main_panel.name = "DevMenuPanel"
	_main_panel.visible = false
	_main_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.08, 0.12, 0.96)
	panel_style.border_color = Color(0.3, 0.6, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(10)
	panel_style.content_margin_left = 16
	panel_style.content_margin_right = 16
	panel_style.content_margin_top = 12
	panel_style.content_margin_bottom = 14
	panel_style.shadow_color = Color(0, 0, 0, 0.6)
	panel_style.shadow_size = 12
	_main_panel.add_theme_stylebox_override("panel", panel_style)

	_main_panel.set_anchors_preset(Control.PRESET_CENTER)
	_main_panel.custom_minimum_size = Vector2(740, 540)
	_main_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_main_panel.grow_vertical = Control.GROW_DIRECTION_BOTH

	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 10)
	_main_panel.add_child(root_vbox)

	# --- Pasek Tytułowy (Header) ---
	var header_hbox := HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 12)

	var title_lbl := Label.new()
	title_lbl.text = "🛠️ MENU DEWELOPERSKIE (DEV MENU)"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	header_hbox.add_child(title_lbl)

	_lbl_fps = Label.new()
	_lbl_fps.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_fps.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lbl_fps.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	_lbl_fps.add_theme_font_size_override("font_size", 13)
	header_hbox.add_child(_lbl_fps)

	var close_btn := Button.new()
	close_btn.text = " ✕ "
	close_btn.tooltip_text = "Zamknij [F1 / ~ / ESC]"
	close_btn.pressed.connect(close)
	header_hbox.add_child(close_btn)

	root_vbox.add_child(header_hbox)

	var sep := HSeparator.new()
	root_vbox.add_child(sep)

	# --- Zakładki (Tabs) ---
	var tab_container := TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(tab_container)

	# TAB 1: Cheaty i Przełączniki
	var tab_cheats := _build_tab_cheats()
	tab_cheats.name = "⚡ Cheaty i Opcje"
	tab_container.add_child(tab_cheats)

	# TAB 2: Baza Quizów
	var tab_quizzes := _build_tab_quizzes()
	tab_quizzes.name = "📚 Baza Quizów"
	tab_container.add_child(tab_quizzes)

	# TAB 3: Rozgrywka i Ruch
	var tab_gameplay := _build_tab_gameplay()
	tab_gameplay.name = "🎮 Rozgrywka i Postać"
	tab_container.add_child(tab_gameplay)

	# --- Stopka z informacjami ---
	_lbl_info = Label.new()
	_lbl_info.text = "Ładowanie informacji..."
	_lbl_info.add_theme_font_size_override("font_size", 12)
	_lbl_info.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	root_vbox.add_child(_lbl_info)

	add_child(_main_panel)


func _build_tab_cheats() -> Control:
	var scroll := ScrollContainer.new()
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 14)
	scroll.add_child(vbox)

	# 1. Przełącznik wrogów
	var enemy_box := _create_card_box("Przeciwnicy na mapie [F10 / O]", "Wyłącza pościg, agresję i inicjowanie walk przez wrogów.")
	_btn_toggle_enemies = CheckButton.new()
	_btn_toggle_enemies.text = "Przeciwnicy: WŁĄCZENI"
	_btn_toggle_enemies.toggled.connect(func(_pressed):
		var cheat_service = get_node_or_null("/root/CheatService")
		if cheat_service and cheat_service.has_method("toggle_enemies"):
			cheat_service.toggle_enemies()
	)
	enemy_box.add_child(_btn_toggle_enemies)
	vbox.add_child(enemy_box)

	# 2. Przełącznik quizów
	var quiz_box := _create_card_box("Quizy [F11 / P]", "W trybie wyłączonym pytania są pomijane i automatycznie zaliczane jako poprawne.")
	_btn_toggle_quizzes = CheckButton.new()
	_btn_toggle_quizzes.text = "Quizy: WŁĄCZONE"
	_btn_toggle_quizzes.toggled.connect(func(_pressed):
		var cheat_service = get_node_or_null("/root/CheatService")
		if cheat_service and cheat_service.has_method("toggle_quizzes"):
			cheat_service.toggle_quizzes()
	)
	quiz_box.add_child(_btn_toggle_quizzes)
	vbox.add_child(quiz_box)

	# 3. Instant Win
	var win_box := _create_card_box("Natychmiastowe Zwycięstwo [F9 / K]", "W walce zadaje 9999 obrażeń wrogom i kończy starcie. Przy drzwiach natychmiast je otwiera.")
	_btn_instant_win = Button.new()
	_btn_instant_win.text = "🏆 Aktywuj Natychmiastowe Zwycięstwo (Instant Win)"
	_btn_instant_win.pressed.connect(func():
		var cheat_service = get_node_or_null("/root/CheatService")
		if cheat_service and cheat_service.has_method("trigger_instant_win"):
			cheat_service.trigger_instant_win()
	)
	win_box.add_child(_btn_instant_win)
	vbox.add_child(win_box)

	# 4. God Mode
	var god_box := _create_card_box("God Mode (Nieśmiertelność)", "Bohater nie otrzymuje żadnych obrażeń.")
	_btn_toggle_god_mode = CheckButton.new()
	_btn_toggle_god_mode.text = "God Mode: Wyłączony"
	_btn_toggle_god_mode.toggled.connect(func(pressed):
		var cheat_service = get_node_or_null("/root/CheatService")
		if cheat_service and cheat_service.has_method("set_god_mode"):
			cheat_service.set_god_mode(pressed)
	)
	god_box.add_child(_btn_toggle_god_mode)
	vbox.add_child(god_box)

	return scroll


func _build_tab_quizzes() -> Control:
	var scroll := ScrollContainer.new()
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 14)
	scroll.add_child(vbox)

	var quiz_select_box := _create_card_box("Domyślny Zestaw Quizu (Root Quizzes)", "Wybierz bazę pytań pobieraną z folderu res://resources/quizzes/.")
	_opt_quizzes = OptionButton.new()
	_opt_quizzes.add_item("Domyślny (inf_podst - Szkoła Podstawowa)", 0)
	_opt_quizzes.set_item_metadata(0, "inf_podst")
	_opt_quizzes.add_item("Zaawansowany (informatyka - 100 pytań)", 1)
	_opt_quizzes.set_item_metadata(1, "informatyka")
	_opt_quizzes.item_selected.connect(func(idx):
		var chosen_id: String = str(_opt_quizzes.get_item_metadata(idx))
		var cheat_service = get_node_or_null("/root/CheatService")
		if cheat_service:
			cheat_service.active_quiz_override = chosen_id
			cheat_service.show_toast("📚 Zmieniono aktywny quiz na: %s" % chosen_id, Color(0.4, 0.8, 1.0))
	)
	quiz_select_box.add_child(_opt_quizzes)

	var reload_btn := Button.new()
	reload_btn.text = "🔄 Przeładuj pliki JSON z dysku"
	reload_btn.pressed.connect(func():
		var quiz_service = get_node_or_null("/root/QuizService")
		if quiz_service:
			quiz_service.reload_module("quiz_rpg")
			quiz_service.reload_module("global")
			quiz_service.reload_module("")
		var cheat_service = get_node_or_null("/root/CheatService")
		if cheat_service:
			cheat_service.show_toast("✅ Przeładowano pliki quizów z res://resources/quizzes!", Color(0.4, 1.0, 0.5))
	)
	quiz_select_box.add_child(reload_btn)
	vbox.add_child(quiz_select_box)

	# Wybór układu UI quizu w walce (Dolny pasek vs Popup w centrum)
	var layout_box := _create_card_box("Układ UI Quizu w Walce", "Wybierz sposób wyświetlania pytań podczas pojedynku RPG.")
	_opt_quiz_layout = OptionButton.new()
	_opt_quiz_layout.add_item("📏 Dolny pasek (100% szerokości ekranu, styl RPG)", 0)
	_opt_quiz_layout.set_item_metadata(0, "bottom")
	_opt_quiz_layout.add_item("🖼️ Modal / Popup w centrum ekranu", 1)
	_opt_quiz_layout.set_item_metadata(1, "popup")
	var cheat_service_layout = get_node_or_null("/root/CheatService")
	if cheat_service_layout and "quiz_ui_mode" in cheat_service_layout:
		_opt_quiz_layout.selected = 1 if cheat_service_layout.quiz_ui_mode == "popup" else 0
	_opt_quiz_layout.item_selected.connect(func(idx):
		var mode: String = str(_opt_quiz_layout.get_item_metadata(idx))
		var cs = get_node_or_null("/root/CheatService")
		if cs and cs.has_method("set_quiz_ui_mode"):
			cs.set_quiz_ui_mode(mode)
	)
	layout_box.add_child(_opt_quiz_layout)
	vbox.add_child(layout_box)

	var stats_box := _create_card_box("Ścieżka źródłowa bazy quizów", "Pytania są pobierane bezpośrednio z:\nres://resources/quizzes/inf_podst.json\nres://resources/quizzes/informatyka.json")
	vbox.add_child(stats_box)

	return scroll


func _build_tab_gameplay() -> Control:
	var scroll := ScrollContainer.new()
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 14)
	scroll.add_child(vbox)

	# 1. Prędkość poruszania się
	var speed_box := _create_card_box("Prędkość poruszania się gracza", "Zwiększ tempo eksploracji mapy.")
	_opt_speed = OptionButton.new()
	_opt_speed.add_item("1.0x (Normalna prędkość)", 0)
	_opt_speed.add_item("1.5x (Szybki chód)", 1)
	_opt_speed.add_item("2.0x (Sprint)", 2)
	_opt_speed.add_item("3.0x (Super prędkość)", 3)
	_opt_speed.item_selected.connect(func(idx):
		var mult := 1.0
		match idx:
			0: mult = 1.0
			1: mult = 1.5
			2: mult = 2.0
			3: mult = 3.0
		var cheat_service = get_node_or_null("/root/CheatService")
		if cheat_service and cheat_service.has_method("set_speed_mult"):
			cheat_service.set_speed_mult(mult)
	)
	speed_box.add_child(_opt_speed)
	vbox.add_child(speed_box)

	# 2. Statystyki drużyny
	var party_box := _create_card_box("Szybkie modyfikatory postaci", "Natychmiastowe operacje na statystykach.")
	var party_btns_grid := GridContainer.new()
	party_btns_grid.columns = 2
	party_btns_grid.add_theme_constant_override("h_separation", 10)
	party_btns_grid.add_theme_constant_override("v_separation", 10)

	_btn_full_heal = Button.new()
	_btn_full_heal.text = "❤️ Pełne Uleczenie (100% HP)"
	_btn_full_heal.pressed.connect(func():
		var core_mgr = get_node_or_null("/root/CoreManager")
		var ps = core_mgr.get_singleton("PlayerStats") if core_mgr else null
		if ps and ps.has_method("heal"):
			ps.call("heal", 9999)
		var cheat_service = get_node_or_null("/root/CheatService")
		if cheat_service:
			cheat_service.show_toast("❤️ Drużyna została w pełni uleczona!", Color(0.4, 1.0, 0.4))
	)
	party_btns_grid.add_child(_btn_full_heal)

	_btn_add_xp = Button.new()
	_btn_add_xp.text = "⭐ Dodaj +100 EXP"
	_btn_add_xp.pressed.connect(func():
		var core_mgr = get_node_or_null("/root/CoreManager")
		var ps = core_mgr.get_singleton("PlayerStats") if core_mgr else null
		if ps and ps.has_method("add_xp"):
			ps.call("add_xp", 100)
		var cheat_service = get_node_or_null("/root/CheatService")
		if cheat_service:
			cheat_service.show_toast("⭐ Dodano +100 EXP!", Color(1.0, 0.85, 0.2))
	)
	party_btns_grid.add_child(_btn_add_xp)

	_btn_add_streak = Button.new()
	_btn_add_streak.text = "🔥 Seria Odpowiedzi (+10)"
	_btn_add_streak.pressed.connect(func():
		var core_mgr = get_node_or_null("/root/CoreManager")
		var ps = core_mgr.get_singleton("PlayerStats") if core_mgr else null
		if ps and "streak" in ps:
			ps.streak += 10
			if ps.has_signal("points_changed"):
				ps.points_changed.emit(ps.points)
		var cheat_service = get_node_or_null("/root/CheatService")
		if cheat_service:
			cheat_service.show_toast("🔥 Zwiększono serię odpowiedzi o +10!", Color(1.0, 0.5, 0.2))
	)
	party_btns_grid.add_child(_btn_add_streak)

	var btn_add_coins := Button.new()
	btn_add_coins.text = "💰 Dodaj 100 Punktów"
	btn_add_coins.pressed.connect(func():
		var core_mgr = get_node_or_null("/root/CoreManager")
		var ps = core_mgr.get_singleton("PlayerStats") if core_mgr else null
		if ps and "points" in ps:
			ps.points += 100
			if ps.has_signal("points_changed"):
				ps.points_changed.emit(ps.points)
		var cheat_service = get_node_or_null("/root/CheatService")
		if cheat_service:
			cheat_service.show_toast("💰 Dodano +100 Punktów!", Color(1.0, 0.9, 0.3))
	)
	party_btns_grid.add_child(btn_add_coins)

	party_box.add_child(party_btns_grid)
	vbox.add_child(party_box)

	return scroll


func _create_card_box(title: String, description: String) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.13, 0.19, 0.85)
	style.border_color = Color(0.25, 0.3, 0.45)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var lbl_title := Label.new()
	lbl_title.text = title
	lbl_title.add_theme_font_size_override("font_size", 15)
	lbl_title.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	vbox.add_child(lbl_title)

	if description != "":
		var lbl_desc := Label.new()
		lbl_desc.text = description
		lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_desc.add_theme_font_size_override("font_size", 12)
		lbl_desc.add_theme_color_override("font_color", Color(0.65, 0.7, 0.8))
		vbox.add_child(lbl_desc)

	return panel
