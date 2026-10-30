@tool
extends EditorPlugin

## Po każdym eksporcie: wzorzec danych z edytora (przed eksportem) porównany z zasobami w wyeksportowanej paczce
## (osobny proces Godota z --main-pack). Wynik w konsoli i w okienku. Zgłoszenie 2026-10-29: odtrutka gubiła pole przy
## konwersji eksportu — w edytorze działało, w exe nie.

const Check = preload("check_pack.gd")
const CHECK_SCRIPT := "res://addons/export_check/check_pack.gd"

var _export_plugin: ExportHook


func _enter_tree() -> void:
	_export_plugin = ExportHook.new()
	_export_plugin.owner_plugin = self
	add_export_plugin(_export_plugin)


func _exit_tree() -> void:
	remove_export_plugin(_export_plugin)
	_export_plugin = null


## Łatka (patch_path) sprawdzana na bazie (pack_path) — sama ma tylko zmienione pliki. Po udanym sprawdzeniu łatki
## odpala tools/publish_patch.bat (wydanie na GitHubie + gist) w osobnym oknie.
func run_check(pack_path: String, ref: Dictionary, patch_path: String = "") -> void:
	var dir := ProjectSettings.globalize_path("user://export_check")
	DirAccess.make_dir_recursive_absolute(dir)
	var ref_path := dir.path_join("reference.json")
	var out_path := dir.path_join("result.txt")
	var f := FileAccess.open(ref_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(ref))
	f.close()
	if FileAccess.file_exists(out_path):
		DirAccess.remove_absolute(out_path)
	var output := []
	OS.execute(OS.get_executable_path(), ["--headless", "--main-pack", pack_path, "-s",
			ProjectSettings.globalize_path(CHECK_SCRIPT), "--", ref_path, out_path, patch_path], output, true)
	var result := FileAccess.get_file_as_string(out_path) if FileAccess.file_exists(out_path) else "Sprawdzenie nie zwróciło wyniku:\n" + "\n".join(output)
	var ok := result.begins_with("OK")
	print("[ExportCheck] ", result if ok else "BŁĘDY EKSPORTU:\n" + result)
	var dlg := AcceptDialog.new()
	dlg.title = "Sprawdzenie eksportu"
	dlg.dialog_text = ("Eksport OK — dane gry (%s zasobów) takie jak w edytorze." % result.get_slice(" ", 1).strip_edges()) if ok \
			else "Dane w eksporcie różnią się od edytora:\n\n" + result.left(3000)
	dlg.confirmed.connect(dlg.queue_free)
	dlg.canceled.connect(dlg.queue_free)
	EditorInterface.popup_dialog_centered(dlg)  # nad otwartym oknem eksportu (jedno okno modalne naraz)
	if ok and patch_path != "":
		OS.create_process("powershell.exe", ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
			ProjectSettings.globalize_path("res://tools/publish_patch.ps1"), patch_path], true)  # cmd /c gubi ścieżki ze spacjami
		print("[ExportCheck] Publikacja łatki: ", patch_path)


class ExportHook extends EditorExportPlugin:
	var owner_plugin: EditorPlugin
	var _path := ""
	var _ref := {}
	var _bases: PackedStringArray = []  # bazy łatek z presetu (zakładka Patches)

	func _get_name() -> String:
		return "ExportCheck"

	func _export_begin(_features: PackedStringArray, is_debug: bool, path: String, _flags: int) -> void:
		_path = path
		var preset := get_export_preset()
		_bases = preset.get_patches() if preset else PackedStringArray()
		if not is_debug:
			_bump_build()
		_ref = {}
		for p in Check.data_paths():
			var res := load(p)
			if res != null:
				_ref[p] = JSON.parse_string(JSON.stringify(Check.snapshot(res)))

	## Numer builda (resources/build.json) +1 przy eksporcie release — przed spakowaniem, więc trafia do exe.
	func _bump_build() -> void:
		const BUILD_PATH := "res://resources/build.json"
		var data := _build_data()
		var version := str(ProjectSettings.get_setting("application/config/version", ""))
		var build := int(data.get("build", 0)) + 1  # rośnie stale; bazę ustawia eksport exe (_export_end)
		var f := FileAccess.open(BUILD_PATH, FileAccess.WRITE)
		# Wersja też tu: paczki aktualizacji (.pck) nie podmieniają ustawień projektu, a ten plik tak.
		f.store_string(JSON.stringify({"build": build, "base": int(data.get("base", 0)), "version": version, "notes": _changelog_section(version)}) + "
")
		f.close()
		print("[ExportCheck] Build ", build)

	static func _build_data() -> Dictionary:
		const BUILD_PATH := "res://resources/build.json"
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(BUILD_PATH)) if FileAccess.file_exists(BUILD_PATH) else null
		return data if data is Dictionary else {}

	## Po eksporcie exe jego build zostaje bazą kolejnych łatek (publish_patch.ps1 -> "base" w manifeście).
	static func _set_base_from_build() -> void:
		var data := _build_data()
		data["base"] = int(data.get("build", 0))
		var f := FileAccess.open("res://resources/build.json", FileAccess.WRITE)
		f.store_string(JSON.stringify(data) + "\n")
		f.close()
		print("[ExportCheck] Baza łatek = build ", data["base"])

	## Sekcja „## [wersja]” z CHANGELOG.md (bez nagłówka) — okno „Co nowego” w grze; brak = pusto.
	func _changelog_section(version: String) -> String:
		var lines := FileAccess.get_file_as_string("res://CHANGELOG.md").replace("\r", "").split("\n")
		var out: PackedStringArray = []
		var inside := false
		for line in lines:
			if line.begins_with("## ["):
				if inside:
					break
				inside = line.begins_with("## [%s]" % version)
				continue
			if inside:
				out.append(line)
		return "\n".join(out).strip_edges()

	func _export_end() -> void:
		print("[ExportCheck] Koniec eksportu: ", _path, " (zasobów we wzorcu: ", _ref.size(), ")")
		if _path == "" or _ref.is_empty():
			return
		var pack := _path if _path.is_absolute_path() and not _path.begins_with("res://") else ProjectSettings.globalize_path(_path if _path.begins_with("res://") else "res://" + _path)
		# Windows: eksport pisze <nazwa>.tmp i zmienia nazwę na .exe dopiero po _export_end.
		if pack.get_extension().to_lower() == "tmp":
			pack = pack.get_basename() + ".exe"
		if pack.get_extension().to_lower() not in ["exe", "pck", "zip"]:
			print("[ExportCheck] Pominięte (nie exe / pck / zip): ", pack)
			return
		if pack.get_extension().to_lower() == "exe":
			_set_base_from_build()
		var ref := _ref
		var bases := _bases
		var started := Time.get_ticks_msec()
		var plugin := owner_plugin
		# Czekamy, aż paczka będzie na miejscu (zmiana nazwy .tmp -> .exe), najwyżej 60 s.
		var wait := func(self_ref: Callable) -> void:
			if FileAccess.file_exists(pack) and not FileAccess.file_exists(pack.get_basename() + ".tmp"):
				# Łatka = mały .pck przy bazie w presecie (pełny pck ma ~220 MB): sprawdzana na ostatniej bazie.
				var fa := FileAccess.open(pack, FileAccess.READ) if pack.get_extension().to_lower() == "pck" else null
				var size := fa.get_length() if fa else 0
				if size > 0 and size < 50 * 1024 * 1024 and not bases.is_empty():
					var base := bases[bases.size() - 1]
					base = base if base.is_absolute_path() else ProjectSettings.globalize_path("res://" + base)
					plugin.call("run_check", base, ref, pack)
				else:
					plugin.call("run_check", pack, ref)
			elif Time.get_ticks_msec() - started < 60000:
				Engine.get_main_loop().create_timer(1.0).timeout.connect(self_ref.bind(self_ref))
			else:
				print("[ExportCheck] Nie doczekano się paczki: ", pack)
		Engine.get_main_loop().create_timer(1.0).timeout.connect(wait.bind(wait))
