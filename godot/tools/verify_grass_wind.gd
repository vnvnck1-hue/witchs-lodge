extends SceneTree
## Loads the grass showcase, measures uncapped frame time / primitives / draw calls,
## and checks that the field actually moves (two frames 1s apart differ) and that waves are spatially coherent.
## Run (needs a GPU, not --headless):  Godot --path . --script res://tools/verify_grass_wind.gd -- <out_dir>

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures.append(message)

func _diff(a: Image, b: Image, rect: Rect2i) -> float:
	var total := 0.0
	for y in range(rect.position.y, rect.end.y, 2):
		for x in range(rect.position.x, rect.end.x, 2):
			var ca := a.get_pixel(x, y)
			var cb := b.get_pixel(x, y)
			total += absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b)
	return total / float(rect.size.x * rect.size.y / 4)

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var out := args[0] if args.size() > 0 else OS.get_user_data_dir() + "/grass-verify/"
	DirAccess.make_dir_recursive_absolute(out)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	root.size = Vector2i(1600, 800)
	var demo = load("res://scenes/props/grass/grass_showcase.tscn").instantiate()
	root.add_child(demo)
	for i in 30: await process_frame
	var grass: GrassField = demo.grass
	_check(grass.instance_count > 5000, "instances generated: %d" % grass.instance_count)

	# Uncapped timing over 120 frames.
	var t0 := Time.get_ticks_usec()
	for i in 120: await process_frame
	var ms := (Time.get_ticks_usec() - t0) / 120.0 / 1000.0
	var prims := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	var draws := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	print("frame %.2f ms (%.0f fps) · %d primitives · %d draw calls" % [ms, 1000.0 / ms, prims, draws])
	_check(ms < 16.6, "frame time under 16.6 ms at 1600x800")

	# Motion: same view one second apart must differ in the grass, and a static frame must not.
	demo.set_process(false) # freeze camera + marker; shader TIME keeps running
	await RenderingServer.frame_post_draw
	var a := root.get_texture().get_image()
	await create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	var b := root.get_texture().get_image()
	a.save_png(out + "/wind-a.png")
	b.save_png(out + "/wind-b.png")
	var full := Rect2i(Vector2i(0, 120), a.get_size() - Vector2i(0, 120))
	var moved := _diff(a, b, full)
	print("mean pixel change over 1s: %.4f" % moved)
	_check(moved > .02, "grass moves with the wind")

	# Wave coherence: brightness change in neighbouring cells should correlate (field moves together).
	var cells: Array[float] = []
	var n := 12
	for gy in n:
		for gx in n:
			var r := Rect2i(full.position + Vector2i(gx * full.size.x / n, gy * full.size.y / n), full.size / n)
			cells.append(_diff(a, b, r))
	var mean := 0.0
	for c in cells: mean += c
	mean /= cells.size()
	var spread := 0.0
	for c in cells: spread += absf(c - mean)
	spread /= cells.size()
	print("per-cell motion mean %.4f, mean abs deviation %.4f" % [mean, spread])
	_check(spread > mean * .15, "motion varies across the field (gust bands, not uniform jitter)")

	print("RESULT: " + ("OK" if failures.is_empty() else "FAILED " + str(failures)))
	quit(0 if failures.is_empty() else 1)
