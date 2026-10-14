extends SceneTree
## Real game: grass is built around the lodge, keeps buildings/walk/trails clear, follows the witch,
## moves with the wind, and costs little frame time (grass shown vs hidden, uncapped).
## Run (GPU, not --headless):  Godot --path . --script res://tools/verify_grass_meadow.gd -- <out_dir>
const Layout := preload("res://scripts/world/layout.gd")
const Cfg := preload("res://scripts/config.gd")
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures.append(message)

func _frame_ms(frames: int) -> float:
	var t0 := Time.get_ticks_usec()
	for i in frames: await process_frame
	return (Time.get_ticks_usec() - t0) / float(frames) / 1000.0

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var out := args[0] if args.size() > 0 else OS.get_user_data_dir() + "/grass-meadow/"
	DirAccess.make_dir_recursive_absolute(out)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	root.size = Vector2i(1600, 800)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 40: await process_frame
	var grass: GrassField = game.world.grass
	_check(grass != null and grass.instance_count > 1000, "grass built: %d tufts in %d chunks" % [grass.instance_count, grass.get_child_count()])
	_check(grass.push_target == game.player, "push target is the witch")

	# Keep-out: no tuft root inside lodge / pasture / door walk / trails.
	var walk := [Vector2(Layout.DOOR_FRONT.x, Layout.DOOR_FRONT.z)]
	for s in Layout.STEPPING_STONES: walk.append(Vector2(s[0], s[1]))
	var bad := 0
	for mmi: MultiMeshInstance3D in grass.get_children():
		var mm := mmi.multimesh
		for i in mm.instance_count:
			var g := mmi.global_transform * mm.get_instance_transform(i).origin
			var p := Vector2(g.x, g.z)
			if Layout.LODGE_RECT.has_point(p) or (Cfg.PASTURE_LEVELS[-1].rect as Rect2).has_point(p) \
				or Layout.dist_to_path(p, walk) < 1.4 or Layout.dist_to_trails(p) < 1.7: bad += 1
	_check(bad == 0, "no grass on lodge, pasture, stepping-stone walk or trails (%d violations)" % bad)

	# Cost: same view with grass visible vs hidden.
	game.process_mode = Node.PROCESS_MODE_DISABLED
	await _frame_ms(30)
	var with_grass := await _frame_ms(150)
	grass.visible = false
	await _frame_ms(30)
	var without := await _frame_ms(150)
	grass.visible = true
	print("frame %.2f ms with grass, %.2f ms without (+%.2f ms)" % [with_grass, without, with_grass - without])
	_check(with_grass - without < 1.5, "grass adds under 1.5 ms")

	await RenderingServer.frame_post_draw
	var a := root.get_texture().get_image()
	await create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	var b := root.get_texture().get_image()
	a.save_png(out + "/game-a.png")
	b.save_png(out + "/game-b.png")
	var changed := 0
	for y in range(150, 700, 3):
		for x in range(300, 1300, 3):
			var ca := a.get_pixel(x, y); var cb := b.get_pixel(x, y)
			if absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b) > .06: changed += 1
	print("pixels changed by wind over 1s: %d" % changed)
	_check(changed > 300, "grass moves in the real game view")
	print("RESULT: " + ("OK" if failures.is_empty() else "FAILED " + str(failures)))
	quit(0 if failures.is_empty() else 1)
