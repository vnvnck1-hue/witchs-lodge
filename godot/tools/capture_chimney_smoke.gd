extends SceneTree
## 굴뚝 연기 실제 렌더 캡처(창 실행). 헤드리스 더미 렌더러로는 셰이더 컴파일·반투명 합성·연기 모양을 볼 수 없어서 쓴다.
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_chimney_smoke.gd
## 결과: godot/screenshots/chimney_smoke/ 에 전체 화면 1장 + 굴뚝 주변 확대 연속 6장 + 강풍 확대 1장.

const Layout := preload("res://scripts/world/layout.gd")
const OUT := "res://screenshots/chimney_smoke/"


func _initialize() -> void:
	_run.call_deferred()


func _crop(cam: Camera3D) -> Rect2i:
	var a := cam.unproject_position(Layout.CHIMNEY_TOP + Vector3(0, -1.0, 0))
	var b := cam.unproject_position(Layout.CHIMNEY_TOP + Vector3(0, 5.8, 0))
	var hgt := absf(a.y - b.y)
	var r := Rect2i(Vector2i(int(a.x - hgt * 0.55), int(b.y)), Vector2i(int(hgt * 1.1), int(hgt)))
	return r.intersection(Rect2i(Vector2i.ZERO, root.size))


func _grab(path: String, rect := Rect2i()) -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	if rect.size.x > 0:
		img = img.get_region(rect)
	img.save_png(ProjectSettings.globalize_path(OUT + path))
	print("saved ", path)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1600, 900)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 30:
		await process_frame
	await create_timer(3.0).timeout
	var world = game.world
	# 실제 게임 카메라(안개·렌즈 연출 포함)를 쓰되, 따라갈 대상을 가짜 노드로 바꿔
	# 굴뚝 위 연기가 화면 가운데 오게 한다. HUD 는 숨긴다.
	_hide_ui(root)
	var cam: Camera3D = world.camera
	var pc = world.player_camera
	var aim := Layout.CHIMNEY_TOP + Vector3(0, 2.4, 0)
	var down := -cam.global_basis.z
	var ground := aim + down * (aim.y / -down.y)
	var fwd := Vector3(down.x, 0, down.z).normalized()
	var dummy := Node3D.new()
	world.add_child(dummy)
	dummy.global_position = ground - fwd * 1.8
	pc.target = dummy
	pc.desired_height = 13.0
	await create_timer(1.5).timeout
	# 연도 구멍 확대(연기를 잠깐 끄고): 테두리·안쪽 벽·그을린 바닥이 보여야 한다.
	var smoke_node: Node3D = world.get_node("ChimneySmoke")
	smoke_node.visible = false
	var c := cam.unproject_position(Layout.CHIMNEY_TOP)
	await _grab("hole.png", Rect2i(Vector2i(int(c.x) - 200, int(c.y) - 150), Vector2i(320, 260)))
	smoke_node.visible = true
	await _grab("hole_smoke.png", Rect2i(Vector2i(int(c.x) - 200, int(c.y) - 260), Vector2i(320, 370)))
	await _grab("full.png")
	var rect := _crop(cam)
	for i in 6:
		await _grab("seq_%d.png" % i, rect)
		await create_timer(0.5).timeout
	# 돌풍: 바람을 강하게 걸고 잠시 기다린다.
	var smoke = world.get_node("ChimneySmoke")
	var weather = world.weather_vfx
	weather.set("gust", 1.0)
	weather.set("_gust_target", 1.0)
	weather.set("_gust_timer", 99.0)
	weather.set("_gust_len", 99.0)
	await create_timer(3.0).timeout
	print("gust wind cells/s = ", smoke.wind_cells)
	await _grab("gust.png", rect)
	quit()


func _hide_ui(n: Node) -> void:
	if n is CanvasLayer:
		n.visible = false
	for c in n.get_children():
		_hide_ui(c)
