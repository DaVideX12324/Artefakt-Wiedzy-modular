extends SceneTree

## Prototyp (jednorazowy, tests/ poza gitem): wczytuje grid z proto_layout.py (PP_IN), przepuszcza go przez
## przejścia czyszczące ścieków w kolejności z interior_room_layout_generator.gd (flagi z sewer.json)
## i zapisuje grid po przejściach (PP_OUT). Kanały jak dziś: woda = FLOOR w gridzie.

const Wall3HPassScript = preload("res://modules/quiz_rpg/scripts/generation/preprocess/wall_3h_pass.gd")
const WallTopAlignPassScript = preload("res://modules/quiz_rpg/scripts/generation/preprocess/wall_top_align_pass.gd")
const DiagonalTouchPassScript = preload("res://modules/quiz_rpg/scripts/generation/preprocess/diagonal_touch_pass.gd")
const SlopeThicknessPassScript = preload("res://modules/quiz_rpg/scripts/generation/preprocess/slope_thickness_pass.gd")
const CONFIG := "res://modules/quiz_rpg/resources/maps/config/sewer.json"


func _initialize() -> void:
	var src: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("PP_IN")))
	var w := int(src["w"])
	var h := int(src["h"])
	var cfg := GeneratorBehaviourConfig.load_from_json_path(CONFIG)
	var ctx := GenerationContext.new()
	ctx.flags = cfg.build_flags(GenerationFlags.new())
	ctx.width = w
	ctx.height = h
	ctx.rng = MapGeneratorBase.create_rng(int(src["seed"]))
	var rows: Array = src["grid"]
	for y in range(h):
		var row: String = rows[y]
		for x in range(w):
			ctx.grid[Vector2i(x, y)] = CellType.FLOOR if row[x] == "." else CellType.WALL
	var t0 := Time.get_ticks_usec()
	# P5–P7 + ściany 3H / wyrównanie
	GridPreprocessor.run(ctx, [Remove1hWallsPass.new(), WallThicknessPass.new()])
	_wall_shape(ctx)
	# P10 (bez portali — prototyp) + ponownie kształt ścian
	if ctx.flags.enable_grid_cleanup:
		GridPreprocessor.run_convergent(ctx, [SpikeCleanupPass.new(), ThinBridgeCleanupPass.new(), StaircaseNormalizerPass.new()], 4)
	_wall_shape(ctx)
	# P11a
	GridPreprocessor.run(ctx, [ShortLedgeRaisePass.new(), DiagonalTouchPassScript.new(), SlopeThicknessPassScript.new()])
	var dt := (Time.get_ticks_usec() - t0) / 1000.0
	var out := []
	for y in range(h):
		var s := ""
		for x in range(w):
			s += "." if ctx.grid[Vector2i(x, y)] != CellType.WALL else "#"
		out.append(s)
	var f := FileAccess.open(OS.get_environment("PP_OUT"), FileAccess.WRITE)
	f.store_string(JSON.stringify({"grid": out, "stats": ctx.preprocess_stats, "ms": dt}))
	f.close()
	print("prepass ok ", dt, " ms ", ctx.preprocess_stats)
	quit()


func _wall_shape(ctx: GenerationContext) -> void:
	if ctx.flags.enforce_3h_walls:
		GridPreprocessor.run(ctx, [Wall3HPassScript.new()])
	if ctx.flags.align_wall_tops:
		GridPreprocessor.run(ctx, [WallTopAlignPassScript.new()])
		if ctx.flags.enforce_3h_walls:
			GridPreprocessor.run(ctx, [Wall3HPassScript.new()])
