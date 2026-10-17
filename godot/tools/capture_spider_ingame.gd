extends SceneTree
## 서리 거미 실제 게임 화면 캡처(창 실행): 기본 셰이딩·밤 전투 조명에서 색·크기·마녀와의 비례를 확인한다.
## 헤드리스로는 화면 스타일 전역 셰이더 값이 적용된 실제 색을 볼 수 없어 창으로 짧게 찍는다.
## 실행: .tools/Godot-4.7.2.exe --path godot --resolution 1600x800 --script res://tools/capture_spider_ingame.gd
const Layout := preload("res://scripts/world/layout.gd")
const OUT := "res://screenshots/spider/"

var game


func _initialize() -> void:
	call_deferred("_run")


func _wait(sec: float) -> void:
	var end := Time.get_ticks_msec() + int(sec * 1000.0)
	while Time.get_ticks_msec() < end:
		await process_frame


func _shot(n: String) -> void:
	for i in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + n + ".png"))
	print("SHOT ", n)


func _run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await _wait(1.5)
	game.session.wave_index = 0
	game.session.start_wave()
	await _wait(0.6)
	var spawn: Vector3 = Layout.SPAWN_A
	var lodge: Vector3 = game.world.lodge.global_position
	var watch: Vector3 = spawn.lerp(lodge, 0.42)
	game.player.global_position = watch + (lodge - spawn).normalized().cross(Vector3.UP) * 2.2
	game.player.set_physics_process(false)
	game.world.player_camera.recenter()
	for z in 6:
		game.world.player_camera.zoom(-1.0)
	await _wait(2.6)
	await _shot("ingame-night")
	# 근접 카메라: 가장 가까운 서리 거미
	var best = null
	for e in game.get_tree().get_nodes_in_group("wave_enemies"):
		if e.kind == "spider" and (best == null or e.global_position.distance_to(game.player.global_position) < best.global_position.distance_to(game.player.global_position)):
			best = e
	if best != null:
		var cc := Camera3D.new()
		game.world.add_child(cc)
		cc.fov = 32.0
		cc.current = true
		for k in 3:
			var f: Vector3 = best.global_position + Vector3(0, 0.45, 0)
			var side: Vector3 = best.visual.global_basis.z.normalized().rotated(Vector3.UP, 0.9)
			cc.global_position = f + side * 3.2 + Vector3(0, 1.5, 0)
			cc.look_at(f)
			await _shot("ingame-close-%d" % k)
			await _wait(0.25)
	quit()
