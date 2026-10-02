extends CanvasLayer

## Edytor pytań (menu główne -> Pytania): zestawy (nowy, import JSON, eksport, zmiana nazwy, usunięcie /
## przywrócenie oryginału), pytania (dodaj, edytuj, duplikuj, usuń, włącz / wyłącz w grze) — 5 typów.
## Dane: QuestionBank (user://quizzes, user://quiz_selection.json); po każdej zmianie
## QuizService.reload_all(), więc gra od razu używa nowych pytań.

signal closed

@onready var _root: Control = $Root
@onready var _title: Label = $Root/Margin/VBox/Header/Title
@onready var _btn_close: Button = $Root/Margin/VBox/Header/BtnClose
@onready var _sets_tree: Tree = $Root/Margin/VBox/Body/SetsBox/SetsTree
@onready var _btn_new_set: Button = $Root/Margin/VBox/Body/SetsBox/SetButtons/BtnNewSet
@onready var _btn_import: Button = $Root/Margin/VBox/Body/SetsBox/SetButtons/BtnImport
@onready var _btn_export: Button = $Root/Margin/VBox/Body/SetsBox/SetButtons/BtnExport
@onready var _btn_rename: Button = $Root/Margin/VBox/Body/SetsBox/SetButtons/BtnRename
@onready var _btn_delete_set: Button = $Root/Margin/VBox/Body/SetsBox/SetButtons/BtnDeleteSet
@onready var _search: LineEdit = $Root/Margin/VBox/Body/QuestionsBox/Filters/Search
@onready var _type_filter: OptionButton = $Root/Margin/VBox/Body/QuestionsBox/Filters/TypeFilter
@onready var _q_tree: Tree = $Root/Margin/VBox/Body/QuestionsBox/QuestionsTree
@onready var _btn_add: Button = $Root/Margin/VBox/Body/QuestionsBox/QButtons/BtnAdd
@onready var _btn_edit: Button = $Root/Margin/VBox/Body/QuestionsBox/QButtons/BtnEdit
@onready var _btn_duplicate: Button = $Root/Margin/VBox/Body/QuestionsBox/QButtons/BtnDuplicate
@onready var _btn_delete: Button = $Root/Margin/VBox/Body/QuestionsBox/QButtons/BtnDelete
@onready var _btn_all_on: Button = $Root/Margin/VBox/Body/QuestionsBox/QButtons/BtnAllOn
@onready var _btn_all_off: Button = $Root/Margin/VBox/Body/QuestionsBox/QButtons/BtnAllOff
@onready var _status: Label = $Root/Margin/VBox/Status

@onready var _edit_dialog: Control = $Root/EditDialog
@onready var _dlg_title: Label = $Root/EditDialog/Center/Panel/Margin/VBox/DlgTitle
@onready var _type_option: OptionButton = $Root/EditDialog/Center/Panel/Margin/VBox/Common/TypeOption
@onready var _diff_spin: SpinBox = $Root/EditDialog/Center/Panel/Margin/VBox/Common/DiffSpin
@onready var _category_edit: LineEdit = $Root/EditDialog/Center/Panel/Margin/VBox/Common/CategoryEdit
@onready var _form: VBoxContainer = $Root/EditDialog/Center/Panel/Margin/VBox/Scroll/Form
@onready var _error: Label = $Root/EditDialog/Center/Panel/Margin/VBox/Error
@onready var _btn_save: Button = $Root/EditDialog/Center/Panel/Margin/VBox/DlgButtons/BtnSave
@onready var _btn_cancel: Button = $Root/EditDialog/Center/Panel/Margin/VBox/DlgButtons/BtnCancel

@onready var _import_dialog: FileDialog = $ImportDialog
@onready var _export_dialog: FileDialog = $ExportDialog
@onready var _confirm_dialog: ConfirmationDialog = $ConfirmDialog
@onready var _name_dialog: ConfirmationDialog = $NameDialog
@onready var _name_edit: LineEdit = $NameDialog/NameEdit
@onready var _report_dialog: AcceptDialog = $ReportDialog

const MAX_ANSWERS := 6
const MAX_PAIRS := 8
const COLOR_OK := Color(0.6, 0.85, 0.6)
const COLOR_ERR := Color(1.0, 0.5, 0.5)

var _theme := Theme.new()
var _set_id := ""
var _set: Dictionary = {}          # bieżący zestaw (kopia; zapis przez QuestionBank.save_set)
var _edit_index := -1              # indeks edytowanego pytania w _set.questions, -1 = nowe
var _edit_original: Dictionary = {}
var _confirm_action: Callable
var _name_action: Callable
var _refreshing := false

# Pola formularza bieżącego typu (budowane w _build_form).
var _f: Dictionary = {}


func _ready() -> void:
	_root.theme = _theme
	for d: Window in [_import_dialog, _export_dialog, _confirm_dialog, _name_dialog, _report_dialog]:
		d.theme = _theme
	_apply_scale()
	if UIScaleService.scale_changed.is_connected(_on_scale_changed) == false:
		UIScaleService.scale_changed.connect(_on_scale_changed)
	_setup_trees()
	_type_filter.add_item("Wszystkie typy", 0)
	for i in range(QuestionBank.TYPES.size()):
		_type_filter.add_item(QuestionBank.TYPE_NAMES[QuestionBank.TYPES[i]], i + 1)
		_type_option.add_item(QuestionBank.TYPE_NAMES[QuestionBank.TYPES[i]], i)
	_btn_close.pressed.connect(close)
	_btn_new_set.pressed.connect(_on_new_set)
	_btn_import.pressed.connect(func() -> void: _import_dialog.popup_centered())
	_btn_export.pressed.connect(_on_export)
	_btn_rename.pressed.connect(_on_rename)
	_btn_delete_set.pressed.connect(_on_delete_set)
	_btn_add.pressed.connect(func() -> void: _open_edit(-1))
	_btn_edit.pressed.connect(func() -> void: _open_edit(_selected_question_index()))
	_btn_duplicate.pressed.connect(_on_duplicate)
	_btn_delete.pressed.connect(_on_delete_question)
	_btn_all_on.pressed.connect(func() -> void: _set_all_questions(true))
	_btn_all_off.pressed.connect(func() -> void: _set_all_questions(false))
	_search.text_changed.connect(func(_t: String) -> void: _refresh_questions())
	_type_filter.item_selected.connect(func(_i: int) -> void: _refresh_questions())
	_sets_tree.item_selected.connect(_on_set_selected)
	_sets_tree.item_edited.connect(_on_set_edited)
	_q_tree.item_edited.connect(_on_question_edited)
	_q_tree.item_activated.connect(func() -> void: _open_edit(_selected_question_index()))
	_q_tree.item_selected.connect(_update_buttons)
	_import_dialog.file_selected.connect(_import_file)
	_import_dialog.files_selected.connect(func(paths: PackedStringArray) -> void:
		for p in paths:
			_import_file(p))
	_export_dialog.file_selected.connect(_on_export_path)
	_confirm_dialog.confirmed.connect(func() -> void:
		if _confirm_action.is_valid():
			_confirm_action.call())
	_name_dialog.confirmed.connect(func() -> void:
		if _name_action.is_valid():
			_name_action.call(_name_edit.text.strip_edges()))
	_name_edit.text_submitted.connect(func(_t: String) -> void:
		_name_dialog.hide()
		if _name_action.is_valid():
			_name_action.call(_name_edit.text.strip_edges()))
	_type_option.item_selected.connect(func(i: int) -> void: _build_form(QuestionBank.TYPES[i], {}))
	_btn_save.pressed.connect(_on_save_question)
	_btn_cancel.pressed.connect(func() -> void: _edit_dialog.visible = false)
	get_tree().root.files_dropped.connect(_on_files_dropped)


func open() -> void:
	visible = true
	_edit_dialog.visible = false
	_refresh_sets(_set_id)


func close() -> void:
	visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		if _edit_dialog.visible:
			_edit_dialog.visible = false
		else:
			close()
		get_viewport().set_input_as_handled()


# --- Wygląd ------------------------------------------------------------------------------------------

func _on_scale_changed(_s: float) -> void:
	_apply_scale()


func _apply_scale() -> void:
	_theme.default_font_size = UIScaleService.px(18)
	_apply_check_icons(UIScaleService.px(18))
	_title.add_theme_font_size_override("font_size", UIScaleService.px(30))
	_dlg_title.add_theme_font_size_override("font_size", UIScaleService.px(24))


## Wyraźne pola wyboru (domyślne niezaznaczone giną na ciemnym tle): kwadrat / kółko z jasną ramką,
## zaznaczone — wypełnione kolorem akcentu.
func _apply_check_icons(size: int) -> void:
	var on := _check_icon(size, true, false)
	var off := _check_icon(size, false, false)
	var r_on := _check_icon(size, true, true)
	var r_off := _check_icon(size, false, true)
	for t in [&"Tree", &"CheckBox"]:
		_theme.set_icon(&"checked", t, on)
		_theme.set_icon(&"unchecked", t, off)
	_theme.set_icon(&"radio_checked", &"CheckBox", r_on)
	_theme.set_icon(&"radio_unchecked", &"CheckBox", r_off)


func _check_icon(size: int, checked: bool, round: bool) -> ImageTexture:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var border := Color(0.85, 0.87, 0.95)
	var fill := Color(0.35, 0.75, 1.0)
	var c := (size - 1) * 0.5
	var b := maxf(1.5, size / 10.0)
	for y in range(size):
		for x in range(size):
			var col := Color(0, 0, 0, 0)
			if round:
				var d := Vector2(x - c, y - c).length()
				if d <= c and d > c - b:
					col = border
				elif checked and d <= c - b * 2.0:
					col = fill
			else:
				var edge := minf(minf(x, y), minf(size - 1 - x, size - 1 - y))
				if edge < b:
					col = border
				elif checked and edge >= b * 2.0:
					col = fill
			img.set_pixel(x, y, col)
	return ImageTexture.create_from_image(img)


func _setup_trees() -> void:
	_sets_tree.set_column_title(0, "W grze")
	_sets_tree.set_column_title(1, "Zestaw")
	_sets_tree.set_column_title(2, "Pytań")
	_sets_tree.set_column_expand(0, false)
	_sets_tree.set_column_custom_minimum_width(0, UIScaleService.px(70))
	_sets_tree.set_column_expand(2, false)
	_sets_tree.set_column_custom_minimum_width(2, UIScaleService.px(70))
	_q_tree.set_column_title(0, "W grze")
	_q_tree.set_column_title(1, "Typ")
	_q_tree.set_column_title(2, "Treść")
	_q_tree.set_column_title(3, "Trudn.")
	_q_tree.set_column_title(4, "Kategoria")
	for c in [0, 1, 3, 4]:
		_q_tree.set_column_expand(c, false)
	_q_tree.set_column_custom_minimum_width(0, UIScaleService.px(70))
	_q_tree.set_column_custom_minimum_width(1, UIScaleService.px(190))
	_q_tree.set_column_custom_minimum_width(3, UIScaleService.px(70))
	_q_tree.set_column_custom_minimum_width(4, UIScaleService.px(160))


func _say(text: String, ok: bool = true) -> void:
	_status.text = text
	_status.add_theme_color_override("font_color", COLOR_OK if ok else COLOR_ERR)


# --- Zestawy -----------------------------------------------------------------------------------------

func _refresh_sets(select_id: String = "") -> void:
	_refreshing = true
	_sets_tree.clear()
	var root := _sets_tree.create_item()
	var sel := QuestionBank.load_selection()
	var first: TreeItem = null
	var to_select: TreeItem = null
	for s in QuestionBank.list_sets():
		var it := _sets_tree.create_item(root)
		var id := str(s["id"])
		it.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		it.set_editable(0, true)
		it.set_checked(0, QuestionBank.is_set_enabled(id, sel))
		var tag: String = {"builtin": "", "edited": "  (edytowany)", "user": "  (własny)"}.get(str(s["source"]), "")
		it.set_text(1, str(s["name"]) + tag)
		it.set_tooltip_text(1, "%s\nid: %s" % [str(s.get("description", "")), id])
		it.set_text(2, str((s["questions"] as Array).size()))
		it.set_metadata(0, id)
		if first == null:
			first = it
		if id == select_id:
			to_select = it
	_refreshing = false
	if to_select == null:
		to_select = first
	if to_select:
		to_select.select(1)
		_on_set_selected()
	else:
		_set_id = ""
		_set = {}
		_refresh_questions()


func _on_set_selected() -> void:
	var it := _sets_tree.get_selected()
	if it == null:
		return
	_set_id = str(it.get_metadata(0))
	_set = QuestionBank.get_set(_set_id)
	_refresh_questions()


func _on_set_edited() -> void:
	if _refreshing:
		return
	var it := _sets_tree.get_edited()
	if it == null:
		return
	var id := str(it.get_metadata(0))
	QuestionBank.set_set_enabled(id, it.is_checked(0))
	_reload_game()
	_say("Zestaw „%s” %s w grze." % [it.get_text(1).strip_edges(), "używany" if it.is_checked(0) else "nieużywany"])


func _on_new_set() -> void:
	_ask_name("Nowy zestaw", "", func(name: String) -> void:
		if name == "":
			return
		var id := QuestionBank.new_set_id(name)
		QuestionBank.save_set(id, {"name": name, "description": "", "questions": []})
		_reload_game()
		_refresh_sets(id)
		_say("Utworzono zestaw „%s”. Dodaj pytania przyciskiem „Dodaj pytanie”." % name))


func _on_rename() -> void:
	if _set.is_empty():
		return
	_ask_name("Zmień nazwę zestawu", str(_set["name"]), func(name: String) -> void:
		if name == "":
			return
		_set["name"] = name
		_save_current("Zmieniono nazwę na „%s”." % name))


func _on_delete_set() -> void:
	if _set.is_empty():
		return
	var source := str(_set["source"])
	if source == "builtin":
		_say("Wbudowanego zestawu nie można usunąć — można go wyłączyć (odznacz „W grze”).", false)
		return
	var name := str(_set["name"])
	var question := "Usunąć zestaw „%s” (%d pytań)? Tego nie da się cofnąć." % [name, (_set["questions"] as Array).size()]
	if source == "edited":
		question = "Przywrócić oryginalny zestaw „%s”? Twoje zmiany w nim zostaną usunięte." % name
	_ask_confirm(question, func() -> void:
		var id := _set_id
		QuestionBank.delete_user_file(id)
		if source == "user":
			QuestionBank.forget_set(id)
		_reload_game()
		_refresh_sets(id if source == "edited" else "")
		_say("Przywrócono oryginał „%s”." % name if source == "edited" else "Usunięto zestaw „%s”." % name))


func _on_export() -> void:
	if _set.is_empty():
		return
	_export_dialog.current_file = _set_id + ".json"
	_export_dialog.popup_centered()


func _on_export_path(path: String) -> void:
	if QuestionBank.export_set(_set_id, path):
		_say("Wyeksportowano „%s” do %s" % [_set["name"], path])
	else:
		_say("Nie udało się zapisać %s" % path, false)


func _on_files_dropped(files: PackedStringArray) -> void:
	if not visible:
		return
	for f in files:
		if f.to_lower().ends_with(".json"):
			_import_file(f)


func _import_file(path: String) -> void:
	var r := QuestionBank.import_file(path)
	if not r["ok"]:
		_say("Import %s: %s" % [path.get_file(), r["error"]], false)
		_report("Import nieudany", "%s\n\n%s" % [path.get_file(), r["error"]] + _skipped_text(r["skipped"]))
		return
	_reload_game()
	_refresh_sets(str(r["id"]))
	var skipped: Array = r["skipped"]
	_say("Zaimportowano „%s”: %d pytań%s." % [r["name"], r["imported"], (", pominięto %d" % skipped.size()) if not skipped.is_empty() else ""])
	if not skipped.is_empty():
		_report("Import: pominięte pytania", "Zaimportowano %d pytań do zestawu „%s”.%s" % [r["imported"], r["name"], _skipped_text(skipped)])


func _skipped_text(skipped: Array) -> String:
	if skipped.is_empty():
		return ""
	var lines := PackedStringArray()
	for s in skipped.slice(0, 20):
		lines.append("• pytanie %d: %s" % [s["index"], s["reason"]])
	if skipped.size() > 20:
		lines.append("… i %d więcej" % (skipped.size() - 20))
	return "\n\nPominięte (%d):\n%s" % [skipped.size(), "\n".join(lines)]


# --- Pytania -----------------------------------------------------------------------------------------

func _refresh_questions(select_index: int = -1) -> void:
	_refreshing = true
	_q_tree.clear()
	var root := _q_tree.create_item()
	if _set.is_empty():
		_refreshing = false
		_update_buttons()
		return
	var sel := QuestionBank.load_selection()
	var needle := _search.text.strip_edges().to_lower()
	var type_idx := _type_filter.get_selected_id()
	var questions: Array = _set["questions"]
	for i in range(questions.size()):
		var q: Dictionary = questions[i]
		var t := str(q.get("type", "multiple_choice"))
		if type_idx > 0 and QuestionBank.TYPES[type_idx - 1] != t:
			continue
		var text := QuestionBank.question_text(q)
		if needle != "" and not (text.to_lower().contains(needle) or str(q.get("category", "")).to_lower().contains(needle)):
			continue
		var it := _q_tree.create_item(root)
		it.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		it.set_editable(0, true)
		it.set_checked(0, QuestionBank.is_question_enabled(_set_id, str(q.get("id", "")), sel))
		it.set_text(1, QuestionBank.TYPE_NAMES.get(t, t))
		it.set_text(2, text.replace("\n", " "))
		it.set_tooltip_text(2, text)
		it.set_text(3, str(int(q.get("difficulty", 1))))
		it.set_text(4, str(q.get("category", "")))
		it.set_metadata(0, i)
		if i == select_index:
			it.select(2)
	_refreshing = false
	_update_buttons()


func _selected_question_index() -> int:
	var it := _q_tree.get_selected()
	return int(it.get_metadata(0)) if it else -1


func _update_buttons() -> void:
	var has_set := not _set.is_empty()
	var has_q := _selected_question_index() >= 0
	_btn_add.disabled = not has_set
	_btn_edit.disabled = not has_q
	_btn_duplicate.disabled = not has_q
	_btn_delete.disabled = not has_q
	_btn_all_on.disabled = not has_set
	_btn_all_off.disabled = not has_set
	_btn_export.disabled = not has_set
	_btn_rename.disabled = not has_set
	var source := str(_set.get("source", ""))
	_btn_delete_set.disabled = not has_set or source == "builtin"
	_btn_delete_set.text = "Przywróć oryginał" if source == "edited" else "Usuń zestaw"


func _on_question_edited() -> void:
	if _refreshing:
		return
	var it := _q_tree.get_edited()
	if it == null:
		return
	var q: Dictionary = (_set["questions"] as Array)[int(it.get_metadata(0))]
	QuestionBank.set_question_enabled(_set_id, str(q.get("id", "")), it.is_checked(0))
	_reload_game()


func _set_all_questions(enabled: bool) -> void:
	for q in _set.get("questions", []):
		QuestionBank.set_question_enabled(_set_id, str(q.get("id", "")), enabled)
	_reload_game()
	_refresh_questions(_selected_question_index())
	_say("Wszystkie pytania zestawu %s." % ("włączone" if enabled else "wyłączone"))


func _on_duplicate() -> void:
	var i := _selected_question_index()
	if i < 0:
		return
	var questions: Array = _set["questions"]
	var copy: Dictionary = (questions[i] as Dictionary).duplicate(true)
	copy["id"] = QuestionBank.next_question_id(questions, str(copy.get("type", "multiple_choice")))
	questions.insert(i + 1, copy)
	_save_current("Zduplikowano pytanie.", i + 1)


func _on_delete_question() -> void:
	var i := _selected_question_index()
	if i < 0:
		return
	var q: Dictionary = (_set["questions"] as Array)[i]
	_ask_confirm("Usunąć pytanie „%s”?" % QuestionBank.question_text(q).left(80), func() -> void:
		(_set["questions"] as Array).remove_at(i)
		QuestionBank.set_question_enabled(_set_id, str(q.get("id", "")), true)  # porządek w wyborze
		_save_current("Usunięto pytanie.", mini(i, (_set["questions"] as Array).size() - 1)))


## Zapis bieżącego zestawu (wbudowany -> wersja edytowana w user://) i odświeżenie gry oraz list.
func _save_current(message: String, select_question: int = -1) -> void:
	if not QuestionBank.save_set(_set_id, _set):
		_say("Nie udało się zapisać zestawu.", false)
		return
	_reload_game()
	var keep := _set_id
	_refresh_sets(keep)
	_refresh_questions(select_question)
	_say(message)


func _reload_game() -> void:
	QuizService.reload_all()


# --- Okna pomocnicze ---------------------------------------------------------------------------------

func _ask_confirm(text: String, action: Callable) -> void:
	_confirm_action = action
	_confirm_dialog.dialog_text = text
	_confirm_dialog.popup_centered(Vector2i(UIScaleService.px(620), UIScaleService.px(200)))


func _ask_name(title: String, current: String, action: Callable) -> void:
	_name_action = action
	_name_dialog.title = title
	_name_edit.text = current
	_name_dialog.popup_centered(Vector2i(UIScaleService.px(620), UIScaleService.px(170)))
	_name_edit.grab_focus()
	_name_edit.select_all()


func _report(title: String, text: String) -> void:
	_report_dialog.title = title
	_report_dialog.dialog_text = text
	_report_dialog.popup_centered(Vector2i(UIScaleService.px(760), UIScaleService.px(460)))


# --- Formularz pytania -------------------------------------------------------------------------------

func _open_edit(index: int) -> void:
	if _set.is_empty():
		return
	_edit_index = index
	var questions: Array = _set["questions"]
	var q: Dictionary = (questions[index] as Dictionary).duplicate(true) if index >= 0 and index < questions.size() else {}
	_edit_original = q
	var t := str(q.get("type", "multiple_choice"))
	_dlg_title.text = ("Edycja pytania  —  %s" % q.get("id", "")) if index >= 0 else "Nowe pytanie  —  zestaw „%s”" % _set["name"]
	_type_option.select(maxi(QuestionBank.TYPES.find(t), 0))
	_diff_spin.value = int(q.get("difficulty", 1))
	_category_edit.text = str(q.get("category", ""))
	_build_form(t, q)
	_error.text = ""
	_edit_dialog.visible = true


func _clear_form() -> void:
	for c in _form.get_children():
		_form.remove_child(c)
		c.queue_free()
	_f = {"type": ""}


func _label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", Color(0.75, 0.78, 0.9))
	_form.add_child(l)
	return l


func _text_edit(value: String, height: int = 90) -> TextEdit:
	var te := TextEdit.new()
	te.text = value
	te.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	te.custom_minimum_size = Vector2(0, UIScaleService.px(height))
	_form.add_child(te)
	return te


func _line_edit(value: String, placeholder: String = "") -> LineEdit:
	var le := LineEdit.new()
	le.text = value
	le.placeholder_text = placeholder
	_form.add_child(le)
	return le


func _build_form(t: String, q: Dictionary) -> void:
	_clear_form()
	_f["type"] = t
	match t:
		"multiple_choice":
			_label("Pytanie:")
			_f["question"] = _text_edit(str(q.get("question", "")))
			_label("Odpowiedzi (zaznacz poprawną):")
			var box := VBoxContainer.new()
			_form.add_child(box)
			_f["answers_box"] = box
			_f["group"] = ButtonGroup.new()
			var answers: Array = q.get("answers", ["", "", "", ""])
			for i in range(answers.size()):
				_add_answer_row(str(answers[i]), i == int(q.get("correct_index", 0)))
			var add := Button.new()
			add.text = "+ Odpowiedź"
			add.pressed.connect(func() -> void:
				if box.get_child_count() < MAX_ANSWERS:
					_add_answer_row("", false))
			_form.add_child(add)
		"true_false":
			_label("Twierdzenie:")
			_f["statement"] = _text_edit(str(q.get("statement", "")))
			_label("Poprawna odpowiedź:")
			var opt := OptionButton.new()
			opt.add_item("Prawda", 0)
			opt.add_item("Fałsz", 1)
			opt.select(0 if bool(q.get("correct_answer", true)) else 1)
			opt.custom_minimum_size = Vector2(UIScaleService.px(220), 0)
			opt.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			_form.add_child(opt)
			_f["correct"] = opt
		"fill_text":
			_label("Pytanie:")
			_f["prompt"] = _text_edit(str(q.get("prompt", "")))
			_label("Odpowiedź:")
			_f["answer"] = _line_edit(str(q.get("answer", "")))
			_label("Inne akceptowane odpowiedzi (oddzielone przecinkami):")
			_f["alts"] = _line_edit(", ".join(PackedStringArray((q.get("accepted_alternatives", []) as Array).map(func(x): return str(x)))), "np. stack")
			_label("Podpowiedź — wzór (puste = pierwsza i ostatnia litera, np. s__s):")
			_f["pattern"] = _line_edit(str(q.get("prefilled_pattern", "")))
			var cs := CheckBox.new()
			cs.text = "Rozróżniaj wielkość liter"
			cs.button_pressed = bool(q.get("case_sensitive", false))
			_form.add_child(cs)
			_f["case"] = cs
		"fill_tiles":
			_label("Tekst z lukami (w miejscu luki wpisz %s):" % QuestionBank.GAP_MARK)
			var te := _text_edit(str(q.get("text_with_gaps", "")))
			_f["text"] = te
			_label("Poprawne odpowiedzi w lukach:")
			var gaps_box := VBoxContainer.new()
			_form.add_child(gaps_box)
			_f["gaps_box"] = gaps_box
			var corrects: Array = []
			for g in q.get("gaps", []):
				corrects.append(str(g.get("correct", "")))
			_f["gap_values"] = corrects
			_rebuild_gap_rows()
			te.text_changed.connect(_rebuild_gap_rows)
			_label("Dodatkowe (błędne) kafelki, oddzielone przecinkami:")
			var extras: Array = []
			for tile in q.get("tiles", []):
				if not corrects.has(str(tile)):
					extras.append(str(tile))
			_f["extras"] = _line_edit(", ".join(PackedStringArray(extras)), "np. bąbelkowy, największego")
		"matching":
			_label("Pary do dopasowania (lewa ↔ prawa):")
			var pairs_box := VBoxContainer.new()
			_form.add_child(pairs_box)
			_f["pairs_box"] = pairs_box
			var left: Array = q.get("left_items", [])
			var right: Array = q.get("right_items", [])
			var pairs: Array = q.get("pairs", [])
			if pairs.is_empty():
				for i in range(3):
					_add_pair_row("", "")
			for p in pairs:
				var li := int(p.get("left_index", -1))
				var ri := int(p.get("right_index", -1))
				_add_pair_row(str(left[li]) if li >= 0 and li < left.size() else "", str(right[ri]) if ri >= 0 and ri < right.size() else "")
			var add := Button.new()
			add.text = "+ Para"
			add.pressed.connect(func() -> void:
				if pairs_box.get_child_count() < MAX_PAIRS:
					_add_pair_row("", ""))
			_form.add_child(add)


func _add_answer_row(text: String, correct: bool) -> void:
	var box: VBoxContainer = _f["answers_box"]
	var row := HBoxContainer.new()
	var radio := CheckBox.new()
	radio.button_group = _f["group"]
	radio.button_pressed = correct
	radio.tooltip_text = "Poprawna odpowiedź"
	var le := LineEdit.new()
	le.text = text
	le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	le.placeholder_text = "Odpowiedź"
	var del := Button.new()
	del.text = "✕"
	del.tooltip_text = "Usuń odpowiedź"
	del.pressed.connect(func() -> void:
		if box.get_child_count() > 2:
			box.remove_child(row)
			row.queue_free())
	row.add_child(radio)
	row.add_child(le)
	row.add_child(del)
	box.add_child(row)


func _add_pair_row(left: String, right: String) -> void:
	var box: VBoxContainer = _f["pairs_box"]
	var row := HBoxContainer.new()
	var l := LineEdit.new()
	l.text = left
	l.placeholder_text = "Lewa strona"
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var arrow := Label.new()
	arrow.text = "↔"
	var r := LineEdit.new()
	r.text = right
	r.placeholder_text = "Prawa strona"
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var del := Button.new()
	del.text = "✕"
	del.pressed.connect(func() -> void:
		if box.get_child_count() > 2:
			box.remove_child(row)
			row.queue_free())
	for c: Control in [l, arrow, r, del]:
		row.add_child(c)
	box.add_child(row)


## Wiersze luk = liczba „___” w tekście (wartości zachowane przy zmianie tekstu).
func _rebuild_gap_rows() -> void:
	var box: VBoxContainer = _f["gaps_box"]
	var values: Array = _f.get("gap_values", [])
	for i in range(box.get_child_count()):
		var le := box.get_child(i).get_child(1) as LineEdit
		if i < values.size():
			values[i] = le.text
		else:
			values.append(le.text)
	var count := (_f["text"] as TextEdit).text.count(QuestionBank.GAP_MARK)
	if count == box.get_child_count():
		return
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()
	for i in range(count):
		var row := HBoxContainer.new()
		var l := Label.new()
		l.text = "Luka %d:" % (i + 1)
		l.custom_minimum_size = Vector2(UIScaleService.px(90), 0)
		var le := LineEdit.new()
		le.text = str(values[i]) if i < values.size() else ""
		le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		row.add_child(le)
		box.add_child(row)
	_f["gap_values"] = values


func _split_list(text: String) -> Array:
	var out: Array = []
	for part in text.split(","):
		var p := part.strip_edges()
		if p != "" and not out.has(p):
			out.append(p)
	return out


## Pytanie z formularza (pola innych typów usunięte; pozostałe pola oryginału zachowane).
func _question_from_form() -> Dictionary:
	var t: String = _f["type"]
	var q: Dictionary = _edit_original.duplicate(true) if str(_edit_original.get("type", "")) == t else {}
	for k in ["question", "answers", "correct_index", "statement", "correct_answer", "prompt", "answer",
			"accepted_alternatives", "prefilled_pattern", "case_sensitive", "text_with_gaps", "gaps", "tiles",
			"left_items", "right_items", "pairs"]:
		q.erase(k)
	q["id"] = str(_edit_original.get("id", "")) if _edit_index >= 0 else QuestionBank.next_question_id(_set["questions"], t)
	q["type"] = t
	q["difficulty"] = int(_diff_spin.value)
	q["category"] = _category_edit.text.strip_edges()
	match t:
		"multiple_choice":
			q["question"] = (_f["question"] as TextEdit).text.strip_edges()
			var answers: Array = []
			var correct := -1
			for row in (_f["answers_box"] as VBoxContainer).get_children():
				if (row.get_child(0) as CheckBox).button_pressed:
					correct = answers.size()
				answers.append((row.get_child(1) as LineEdit).text.strip_edges())
			q["answers"] = answers
			q["correct_index"] = correct
		"true_false":
			q["statement"] = (_f["statement"] as TextEdit).text.strip_edges()
			q["correct_answer"] = (_f["correct"] as OptionButton).selected == 0
		"fill_text":
			q["prompt"] = (_f["prompt"] as TextEdit).text.strip_edges()
			var answer := (_f["answer"] as LineEdit).text.strip_edges()
			q["answer"] = answer
			var alts := _split_list((_f["alts"] as LineEdit).text)
			if not alts.is_empty():
				q["accepted_alternatives"] = alts
			var pattern := (_f["pattern"] as LineEdit).text.strip_edges()
			if pattern == "" and answer.length() >= 3:
				pattern = answer.left(1) + "_".repeat(answer.length() - 2) + answer.right(1)
			q["prefilled_pattern"] = pattern
			q["case_sensitive"] = (_f["case"] as CheckBox).button_pressed
		"fill_tiles":
			q["text_with_gaps"] = (_f["text"] as TextEdit).text.strip_edges()
			var gaps: Array = []
			var tiles: Array = []
			var box: VBoxContainer = _f["gaps_box"]
			for i in range(box.get_child_count()):
				var v := (box.get_child(i).get_child(1) as LineEdit).text.strip_edges()
				gaps.append({"index": i, "correct": v})
				if v != "" and not tiles.has(v):
					tiles.append(v)
			for extra in _split_list((_f["extras"] as LineEdit).text):
				if not tiles.has(extra):
					tiles.append(extra)
			tiles.shuffle()
			q["gaps"] = gaps
			q["tiles"] = tiles
		"matching":
			var lefts: Array = []
			var rights: Array = []
			for row in (_f["pairs_box"] as VBoxContainer).get_children():
				var l := (row.get_child(0) as LineEdit).text.strip_edges()
				var r := (row.get_child(2) as LineEdit).text.strip_edges()
				if l == "" and r == "":
					continue
				lefts.append(l)
				rights.append(r)
			var order: Array = range(rights.size())
			order.shuffle()
			var right_items: Array = []
			for idx in order:
				right_items.append(rights[idx])
			var pairs: Array = []
			for i in range(lefts.size()):
				pairs.append({"left_index": i, "right_index": order.find(i)})
			q["left_items"] = lefts
			q["right_items"] = right_items
			q["pairs"] = pairs
	if q["category"] == "":
		q.erase("category")
	return q


func _on_save_question() -> void:
	var q := _question_from_form()
	var err := QuestionBank.validate_question(q)
	if err != "":
		_error.text = "Nie można zapisać: " + err + "."
		return
	var questions: Array = _set["questions"]
	var index := _edit_index
	if index >= 0 and index < questions.size():
		questions[index] = q
	else:
		questions.append(q)
		index = questions.size() - 1
	_edit_dialog.visible = false
	_save_current("Zapisano pytanie „%s”." % QuestionBank.question_text(q).left(60), index)
