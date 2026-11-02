extends SceneTree
func _initialize() -> void:
	var sets := []
	for run in 2:
		var lvl: Node = (load("res://modules/quiz_rpg/scenes/maps/levels/cave.tscn") as PackedScene).instantiate()
		lvl.set("async_generation", false)
		lvl.set("level_path", "res://modules/quiz_rpg/scenes/maps/levels/cave.tscn")
		root.add_child(lvl)
		for k in 5: await process_frame
		var ids := []
		for g in ["chests", "barrels", "ground_items", "enemies"]:
			for n in get_nodes_in_group(g):
				if lvl.is_ancestor_of(n):
					ids.append("%s:%s:%s" % [g, str(n.get("unique_id")) if "unique_id" in n else n.name, Vector2i(n.global_position)])
		ids.sort()
		sets.append(ids)
		print("run ", run, " count ", ids.size(), " sample ", ids.slice(0, 4))
		lvl.queue_free()
		for k in 3: await process_frame
	var diff := 0
	for x in sets[0]:
		if not sets[1].has(x): diff += 1
	print("DIFF ", diff)
	quit()
