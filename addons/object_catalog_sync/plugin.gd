@tool
extends EditorPlugin

## Zapis sceny obiektu -> jej wpis w katalogu biomu (ObjectCatalogSync.sync_scene):
## nowa scena zostaje dopisana, metadane object_* (object_group, object_terrain…) nadpisują wpis.
## Tylko sceny w scenes/objects/<biom>/ biomów, które mają już config/objects_<biom>.json.
## Hurt i sprzątanie usuniętych scen: tools/sync_object_catalogs.gd.


func _enter_tree() -> void:
	scene_saved.connect(_on_scene_saved)


func _exit_tree() -> void:
	if scene_saved.is_connected(_on_scene_saved):
		scene_saved.disconnect(_on_scene_saved)


func _on_scene_saved(path: String) -> void:
	var rep := ObjectCatalogSync.sync_scene(path)
	if rep.is_empty():
		return
	for e in rep["errors"]:
		push_warning("[ObjectCatalogSync] %s" % e)
	if not rep["written"]:
		return
	var what := PackedStringArray()
	if not rep["added"].is_empty():
		what.append("dodano " + ", ".join(rep["added"]))
	if not rep["updated"].is_empty():
		what.append("zaktualizowano " + ", ".join(rep["updated"]))
	print("[ObjectCatalogSync] %s: %s" % [rep["json"], "; ".join(what)])
	if not rep["unused_groups"].is_empty():
		print("[ObjectCatalogSync] grupy bez obiektów (zostają w pliku): %s" % ", ".join(rep["unused_groups"]))
	ObjectCatalog.clear_cache()
	EditorInterface.get_resource_filesystem().update_file(rep["json"])
