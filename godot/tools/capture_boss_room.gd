extends SceneTree
## 니벨라 보스룸 실제 화면 캡처(창 실행): 얼음 바닥 셰이더·냉색 후처리·안개·포효 자세·카메라 줌아웃 구도는
## 헤드리스 더미 렌더러로 볼 수 없어 짧게 찍는다. 결과: godot/screenshots/boss_room/
## 실행: .tools/Godot-4.7.2.exe --path godot --resolution 1600x900 --script res://tools/capture_boss_room.gd
const OUT := "res://screenshots/boss_room/"

var game


func _initialize() -> void:
	create_timer(90.0, true, false, true).timeout.connect(func(): quit(2))
	call_deferred("_run")


func _wait(sec: float) -> void:
	var end := Time.get_ticks_msec() + int(sec * 1000.0)
	while Time.get_ticks_msec() < end:
		await process_frame


func _shot(n: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + n + ".png"))
	print("SHOT ", n)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await _wait(1.5)
	game.session.set_process(false)
	game.player.set_physics_process(false)
	if game.world.fog_of_war != null:
		game.world.fog_of_war.set_enabled(false)
	var mode := "night"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--time="): mode = arg.trim_prefix("--time=")
	game.world.day_cycle.set_mode(mode)
	var room = game.world.boss_room
	var base: Vector3 = room.global_position
	# 접근: 길에서 입구를 바라본다
	game.player.global_position = Vector3(0.4, 0, -25.5)
	game.world.player_camera.recenter()
	await _wait(2.0)
	await _shot(mode + "-01-approach")
	# 진입 → 시야 열림·발견·포효
	game.player.global_position = base + Vector3(3.0, 0, 9.0)
	await _wait(0.35)
	await _shot(mode + "-02-enter")
	await _wait(1.0)
	await _shot(mode + "-03-turn")
	await _wait(0.7)
	# 첫 포효 눈보라 3연타: 0.15초 간격 연속 캡처
	for k in 10:
		await _shot(mode + "-04-blizzard-%02d" % k)
		await _wait(0.15)
	await _wait(0.2)
	await _shot(mode + "-05-roar-hold")
	await _wait(2.0)
	await _shot(mode + "-06-watch")
	# 포효 자세 근접(별도 카메라)
	room._last_roar_end = -100.0
	room._set_phase(room.Phase.TURN)
	room._yaw_from = room.boss.rotation.y
	room._yaw_to = room.boss.rotation.y
	var cc := Camera3D.new()
	game.world.add_child(cc)
	cc.fov = 38.0
	var b: Vector3 = room.boss.global_position
	var fwd: Vector3 = room.boss.global_basis.z.normalized()
	cc.global_position = b + fwd.rotated(Vector3.UP, 0.7) * 18.0 + Vector3(0, 6.0, 0)
	cc.look_at(b + Vector3(0, 2.0, 0))
	cc.current = true
	await _wait(1.75)
	await _shot(mode + "-07-roar-close")
	quit()
