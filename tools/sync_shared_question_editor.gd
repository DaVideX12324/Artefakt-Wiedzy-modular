extends SceneTree
## Kopia edytora pytań hosta dla BitBombera: modules/BitBomber/shared/ (ten sam układ folderów co w hoście).
##
## Uruchamiać po zmianach w edytorze / QuestionBank / ich tekstach:
##   Godot --headless --path <host> -s res://tools/sync_shared_question_editor.gd
##
## Kopia działa w hoście i w BitBomberze uruchomionym samodzielnie (także w wersji TeamBit), bo edytor nie używa
## autoloadów hosta w kodzie, a ścieżki są względne. Przy kopiowaniu:
##   - question_bank.gd bez class_name (w hoście byłaby druga klasa QuestionBank),
##   - w scenach ext_resource ze ścieżką względną (moduł leży w hoście pod modules/BitBomber/, samodzielnie w res://),
##   - skrypty dostają własne pliki .uid (inne niż w hoście; zachowane przy kolejnej synchronizacji),
##   - z resources/i18n/pl.json tylko teksty edytora i pytań (zapasowe teksty bez I18nService).

const DEST := "res://modules/BitBomber/shared"
const FILES: Array[String] = [
	"res://scripts/core/question_bank.gd",
	"res://scripts/ui/question_editor.gd",
	"res://scenes/ui/question_editor.tscn",
	"res://scenes/ui/question_editor_set_row.tscn",
	"res://scenes/ui/question_editor_question_row.tscn",
	"res://resources/ui/question_editor_theme.tres",
	"res://resources/data/question_set_template.json",
]
const I18N_SOURCE := "res://resources/i18n/pl.json"
const I18N_PREFIXES: Array[String] = ["host.question_editor.", "host.quiz.", "host.options.set_"]

var _ext_path_re := RegEx.create_from_string("(\\[ext_resource[^\\]]*?) uid=\"uid://[a-z0-9]+\"")
var _abs_path_re := RegEx.create_from_string("path=\"(res://[^\"]+)\"")


func _initialize() -> void:
	for src in FILES:
		var text := FileAccess.get_file_as_string(src)
		if text == "":
			push_error("Brak pliku: " + src)
			quit(1)
			return
		var dst := DEST.path_join(src.trim_prefix("res://"))
		match src.get_extension():
			"gd":
				text = text.replace("class_name QuestionBank\n", "")
				_store(dst, text)
				_ensure_uid(dst)
			"tscn", "tres":
				_store(dst, _relative_ext_paths(text, src))
			_:
				_store(dst, text)
		print("  ", dst)
	_store(DEST.path_join(I18N_SOURCE.trim_prefix("res://")), _filtered_texts())
	print("Zapisano kopię edytora pytań w ", DEST)
	quit()


## ext_resource: bez uid (kopie mają inne niż host), ścieżka względna do folderu sceny.
func _relative_ext_paths(text: String, src: String) -> String:
	text = _ext_path_re.sub(text, "$1", true)
	var out := text
	for m in _abs_path_re.search_all(text):
		var target := m.get_string(1)
		out = out.replace(m.get_string(0), "path=\"%s\"" % _relative(src.get_base_dir(), target))
	return out


func _relative(from_dir: String, target: String) -> String:
	var from_parts := from_dir.trim_prefix("res://").split("/", false)
	var to_parts := target.trim_prefix("res://").split("/", false)
	var common := 0
	while common < from_parts.size() and common < to_parts.size() - 1 and from_parts[common] == to_parts[common]:
		common += 1
	var parts := PackedStringArray()
	for i in from_parts.size() - common:
		parts.append("..")
	for i in range(common, to_parts.size()):
		parts.append(to_parts[i])
	return "/".join(parts)


func _filtered_texts() -> String:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(I18N_SOURCE))
	var out := {}
	if data is Dictionary:
		for key: String in data:
			for prefix in I18N_PREFIXES:
				if key.begins_with(prefix):
					out[key] = data[key]
					break
	return JSON.stringify(out, "  ", false) + "\n"


func _ensure_uid(script_path: String) -> void:
	var uid_path := script_path + ".uid"
	if FileAccess.file_exists(uid_path):
		return
	_store(uid_path, ResourceUID.id_to_text(ResourceUID.create_id()) + "\n")


## Tekst z LF (repo BitBombera ma eol=lf).
func _store(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text.replace("\r\n", "\n"))
	f.close()
