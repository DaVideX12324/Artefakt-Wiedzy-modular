extends SceneTree

## Uruchamiany przez wtyczkę na wyeksportowanej paczce: godot --headless --main-pack <exe/pck> -s check_pack.gd
## -- <wzorzec.json> <wynik.txt>. Porównuje zasoby z paczki ze stanem z edytora (wzorzec) i zapisuje różnice.

## Funkcje statyczne poniżej używa też wtyczka (plugin.gd) — ten plik jest samodzielny, bo na paczce nie ma addons/.


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		quit(2)
		return
	var ref: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	var lines: Array[String] = []
	for path: String in ref:
		if not ResourceLoader.exists(path):
			lines.append("%s: brak w paczce" % path)
			continue
		var res := load(path)
		if res == null:
			lines.append("%s: nie wczytuje się" % path)
			continue
		var now: Dictionary = JSON.parse_string(JSON.stringify(snapshot(res)))
		var want: Dictionary = ref[path]
		for key: String in want:
			if JSON.stringify(now.get(key)) != JSON.stringify(want[key]):
				lines.append("%s: %s — edytor %s, eksport %s" % [path.get_file(), key, JSON.stringify(want[key]), JSON.stringify(now.get(key))])
	var f := FileAccess.open(args[1], FileAccess.WRITE)
	f.store_string("OK %d\n" % ref.size() if lines.is_empty() else "\n".join(lines))
	f.close()
	quit(0 if lines.is_empty() else 1)


## Foldery z danymi gry (rekurencyjnie, .tres / .res).
const DATA_DIRS: Array[String] = [
	"res://modules/quiz_rpg/resources/items",
	"res://modules/quiz_rpg/resources/enemies",
	"res://modules/quiz_rpg/resources/skills",
	"res://modules/quiz_rpg/resources/loot",
	"res://modules/quiz_rpg/resources/heroes",
	"res://modules/quiz_rpg/resources/statuses",
]


static func data_paths() -> PackedStringArray:
	var out := PackedStringArray()
	for d in DATA_DIRS:
		_collect(d, out)
	out.sort()
	return out


static func _collect(dir: String, out: PackedStringArray) -> void:
	for f in ResourceLoader.list_directory(dir):
		if f.ends_with("/"):
			_collect(dir.path_join(f.trim_suffix("/")), out)
		elif f.ends_with(".tres") or f.ends_with(".res"):
			out.append(dir.path_join(f))


## Pola zasobu zapisywane w pliku (bez skryptu i ścieżki) jako tekst — zasoby zagnieżdżone przez ścieżkę albo
## rekurencyjnie (wbudowane), tablice zasobów element po elemencie.
static func snapshot(res: Resource, depth: int = 0) -> Dictionary:
	var out := {}
	if res == null:
		return out
	for p in res.get_property_list():
		if not (int(p.usage) & PROPERTY_USAGE_STORAGE) or str(p.name) in ["script", "resource_path", "resource_name", "resource_local_to_scene"]:
			continue
		out[str(p.name)] = _value(res.get(p.name), depth)
	return out


static func _value(v: Variant, depth: int) -> Variant:
	if v is Resource:
		var r := v as Resource
		if r.resource_path != "" and not r.resource_path.contains("::"):
			return "@" + r.resource_path
		return snapshot(r, depth + 1) if depth < 3 else "<zasób>"
	if v is Array:
		var arr := []
		for e in v:
			arr.append(_value(e, depth))
		return arr
	if v is Dictionary:
		return var_to_str(v)
	return var_to_str(v)
