extends CanvasLayer

## Ekran „Autorzy”: credits hosta (res://resources/credits.json) i każdego modułu z polem `credits` w manifeście.
## Układ w scenie, tu tylko składanie tekstu z plików JSON ({title, sections: [{title, entries: [{name, author, license, note, url}]}]}).

const HOST_CREDITS := "res://resources/credits.json"

@onready var _text: RichTextLabel = %Text
@onready var _btn_close: Button = %BtnClose


func _ready() -> void:
	visible = false
	_btn_close.pressed.connect(close)


func open() -> void:
	var parts: PackedStringArray = [_render(HOST_CREDITS)]
	for manifest in ModuleRegistry.all():
		if manifest.has("credits_path"):
			parts.append(_render(str(manifest["credits_path"])))
	_text.text = "\n".join(parts)
	_text.scroll_to_line(0)
	visible = true
	_btn_close.grab_focus()


func close() -> void:
	if AudioService: AudioService.play_sfx_by_name("click")
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


static func _render(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (data is Dictionary):
		return ""
	var out := "[font_size=26][b]%s[/b][/font_size]\n" % str(data.get("title", ""))
	for section in data.get("sections", []):
		out += "\n[color=#e0c070][b]%s[/b][/color]\n" % str(section.get("title", ""))
		for e in section.get("entries", []):
			var line := "[b]%s[/b]" % str(e.get("name", ""))
			if e.has("author"):
				line += " — " + str(e["author"])
			if e.has("license"):
				line += " [color=#8890a0](%s)[/color]" % str(e["license"])
			if e.has("note"):
				line += "\n    [color=#a0a8b8]%s[/color]" % str(e["note"])
			if e.has("url"):
				line += "\n    [color=#7fb0ff]%s[/color]" % str(e["url"])
			out += line + "\n"
	return out + "\n"
