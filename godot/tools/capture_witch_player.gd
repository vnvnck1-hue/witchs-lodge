extends SceneTree
## 플레이어 마녀 실제 플레이 카메라 캡처(창 필요: 화면 속 크기·자세는 눈으로만 판단 가능).
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_witch_player.gd
## 결과: godot/screenshots/characters/witch_north/ingame-<상태>.png, ingame-sheet.png(마녀 주변 확대)

const OUT := "res://screenshots/characters/witch_north/"

func _initialize() -> void: call_deferred("_run")

func shot(name: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "ingame-" + name + ".png"))

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var game = load("res://scenes/main.tscn").instantiate()
	get_root().add_child(game)
	for i in 30: await physics_frame
	game.session.set_process(false)
	game.economy.set_process(false)
	var p = game.player
	# 문 앞 마당(트인 눈밭)에 세우고 카메라 쪽(+Z)을 보게 한다.
	p.global_position = load("res://scripts/world/layout.gd").DOOR_FRONT + Vector3(0.6, 0, 3.2)
	p.visual.rotation.y = 0.0
	game.world.player_camera.recenter()
	await shot("idle")
	p.set_destination(p.global_position + Vector3(3, 0, 1.5))
	for i in 12: await physics_frame
	await shot("walk")
	p.command_stop()
	for i in 10: await physics_frame
	p.attack_windup = p.ATTACK_WINDUP * 0.1
	await shot("windup")
	p.attack_windup = 0.0
	p._cast_t = 0.25
	await shot("cast")
	p._cast_t = 0.0
	p.shearing = true
	await shot("work")
	p.shearing = false
	print("CAPTURED ", ProjectSettings.globalize_path(OUT))
	quit()
