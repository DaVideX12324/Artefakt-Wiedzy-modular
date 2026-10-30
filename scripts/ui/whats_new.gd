extends Control

## Okno „Co nowego”: raz po zmianie wersji (nowy exe albo paczka). Notatki = sekcja CHANGELOG.md tej wersji, którą
## ExportCheck wpisuje do resources/build.json (Markdown: ### nagłówki, - punkty -> BBCode). Tu, a nie w UpdateService:
## autoload ładuje się z exe przed paczkami, więc jego zmiany w paczce nie działają — ta scena tak.

@onready var _title: Label = %Title
@onready var _notes: RichTextLabel = %Notes
@onready var _btn_ok: Button = %BtnOk


func _ready() -> void:
	_btn_ok.pressed.connect(hide)


const BUILD_PATH := "res://resources/build.json"
const SEEN_PATH := "user://seen_version.txt"


## Pokazuje notatki raz na wersję (zapamiętana w user://).
func show_if_new() -> void:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(BUILD_PATH)) if FileAccess.file_exists(BUILD_PATH) else null
	if not data is Dictionary:
		return
	var version := str(data.get("version", ""))
	var seen := FileAccess.get_file_as_string(SEEN_PATH).strip_edges() if FileAccess.file_exists(SEEN_PATH) else ""
	if version == "" or version == seen:
		return
	var f := FileAccess.open(SEEN_PATH, FileAccess.WRITE)
	if f:
		f.store_string(version)
	var notes := str(data.get("notes", ""))
	if notes.strip_edges() != "":
		show_notes(version, notes)


func show_notes(version: String, markdown: String) -> void:
	_title.text = (I18nService.t("update.whats_new", "Co nowego w {version}") if I18nService else "Co nowego w {version}") \
			.replace("{version}", version)
	_notes.text = to_bbcode(markdown)
	show()
	_btn_ok.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide()
		get_viewport().set_input_as_handled()


static func to_bbcode(markdown: String) -> String:
	var out: PackedStringArray = []
	for line in markdown.replace("\r", "").split("\n"):
		var t := line.strip_edges()
		if t.begins_with("#"):
			out.append("[b]%s[/b]" % t.lstrip("# "))
		elif t.begins_with("- "):
			out.append("• " + t.substr(2))
		elif t != "" and not out.is_empty() and line.begins_with("  "):
			out[out.size() - 1] += " " + t  # zawinięty punkt listy
		else:
			out.append(t)
	return "\n".join(out).strip_edges()
