extends SceneTree
## 기체 입김 실제 렌더 캡처(창 실행). 헤드리스 더미 렌더러로는 셰이더 컴파일·반투명 합성·기체 모양을 볼 수 없어서 쓴다.
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_breath_vapor.gd
## 결과: godot/screenshots/breath_vapor/ 에 이전 입자 입김(before_*) 과 기체 입김(after_*) 마녀 얼굴 확대 연속 장면.

const OUT := "res://screenshots/breath_vapor/"
const Fx := preload("res://scripts/visual/fx.gd")


func _initialize() -> void:
	_run.call_deferred()


func _grab(path: String, rect: Rect2i) -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image().get_region(rect.intersection(Rect2i(Vector2i.ZERO, root.size)))
	img.save_png(ProjectSettings.globalize_path(OUT + path))
	print("saved ", path)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1600, 900)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 30:
		await process_frame
	await create_timer(2.0).timeout
	var world = game.world
	_hide_ui(root)
	var player = world.game.player
	var cam: Camera3D = world.camera
	var pc = world.player_camera
	pc.desired_height = 6.0
	await create_timer(1.5).timeout
	var actor_vfx = world.actor_vfx
	var bv = world.get_node("BreathVapor")
	# 자동 입김은 끄고 정해진 박자로만 내쉬게 한다(비교가 같은 조건이 되도록).
	actor_vfx.set_process(false)
	var head: Node3D = player.visual.find_child("Mouth", true, false)
	if head == null:
		head = player.visual.find_child("Head", true, false)
	# 화면 옆으로 내쉬는 모습이 잘 보이게 카메라 오른쪽으로 숨을 보낸다.
	var r := cam.global_basis.x
	r.y = 0
	r = r.normalized()
	var col := Color(1, 1, 1, 0.62)
	var c := Vector2.ZERO
	var scale_px := 200.0
	for mode in ["before", "after"]:
		await create_timer(2.2).timeout
		# 카메라가 따라 움직이므로 매번 내쉬기 직전에 입 위치를 다시 잡는다.
		var fwd: Vector3 = player.visual.global_basis.z.normalized()
		var mouth: Vector3 = head.global_position + fwd * 0.22 + Vector3(0, -0.06, 0)
		c = cam.unproject_position(mouth)
		scale_px = absf(cam.unproject_position(mouth + r * 1.0).x - c.x)
		var rect := Rect2i(Vector2i(int(c.x - scale_px * 0.6), int(c.y - scale_px * 1.0)), Vector2i(int(scale_px * 1.7), int(scale_px * 1.3)))
		print(mode, " mouth px ", c, " 1m = ", scale_px, " px")
		if mode == "before":
			Fx.breath(mouth, r, col, 1.0)
		else:
			bv.exhale(mouth, r, col, 1.0)
		for i in 6:
			await _grab("%s_%d.png" % [mode, i], rect)
			await create_timer(0.28).timeout
	# 실제 게임처럼 자동 입김을 켜고 넓게 한 장.
	actor_vfx.set_process(true)
	await create_timer(3.0).timeout
	var wide := Rect2i(Vector2i(int(c.x - scale_px * 3.0), int(c.y - scale_px * 2.0)), Vector2i(int(scale_px * 6.0), int(scale_px * 3.6)))
	await _grab("game_wide.png", wide)
	quit()


func _hide_ui(n: Node) -> void:
	if n is CanvasLayer:
		n.visible = false
	for ch in n.get_children():
		_hide_ui(ch)
