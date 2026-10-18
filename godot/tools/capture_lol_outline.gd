extends SceneTree
## 롤식 적 외곽선 실제 렌더 캡처(창 실행). 헤드리스 더미 렌더러로는 셰이더 컴파일·실제 색·두께를 볼 수 없어 짧게 찍는다.
## 마우스오버 적(밝은 붉은 외곽선), 공격 대상 적(진한 붉은 외곽선 + 옅은 붉은 덧칠), 강조 없는 적, 공격 사거리 고리를 낮·밤에 한 장씩.
## 실행: .tools/Godot-4.7.2.exe --path godot --resolution 1600x900 --script res://tools/capture_lol_outline.gd
const MonsterScript := preload("res://scripts/actors/monster.gd")
const NavUtil := preload("res://scripts/world/nav_util.gd")
const OUT := "res://screenshots/lol_controls/"
const Outline := preload("res://scripts/visual/enemy_outline.gd")

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


func _dummy(p: Vector3, kind: String, big := false):
	var m := MonsterScript.new()
	m.setup(game, 1.0e6, false)
	m.configure(kind)
	if big:
		m.make_big()
	m.position = NavUtil.ground_or_near(game.get_world_3d().navigation_map, p)
	game.actors.add_child(m)
	m.set_physics_process(false)
	return m


func _hover(e) -> void:
	var at: Vector2 = game.world.camera.unproject_position(e.global_position + Vector3(0, 0.4, 0))
	var mm := InputEventMouseMotion.new()
	mm.position = at
	mm.global_position = at
	root.push_input(mm, true)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await _wait(1.5)
	var pl = game.player
	var c: Vector3 = pl.global_position
	pl.set_physics_process(false)
	var hovered = _dummy(c + Vector3(-2.6, 0, 1.4), "spider")
	var target = _dummy(c + Vector3(2.4, 0, 1.0), "forest", true)
	var plain = _dummy(c + Vector3(0.3, 0, 3.4), "spider")
	pl.target_enemy = target
	pl.attack_forced = true
	game.controls.show_range = true
	game.world.player_camera.recenter()
	for z in 4:
		game.world.player_camera.zoom(-1.0)
	await _wait(1.2)
	_hover(hovered)
	await _wait(0.4)
	print("mouse=", game.controls.mouse_pos, " gui=", root.gui_get_hovered_control(), " allowed=", game.movement_input_allowed(), " hovered=", game.controls.hovered == hovered, " target_state=", Outline.state_of(target), " plain_state=", Outline.state_of(plain))
	await _shot("outline-day")
	game.session.wave_index = 0
	game.session.start_wave()
	for e in get_nodes_in_group("wave_enemies"):
		if e != hovered and e != target and e != plain:
			e.queue_free()
	pl.target_enemy = target
	await _wait(2.5)
	for e in get_nodes_in_group("wave_enemies"):
		if e != hovered and e != target and e != plain:
			e.queue_free()
	pl.target_enemy = target
	_hover(hovered)
	await _wait(0.4)
	await _shot("outline-night")
	quit()
