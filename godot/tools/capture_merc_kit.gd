extends SceneTree
## 용병 고유 키트 v04 1차 실제 화면 캡처(docs/mercenary-unique-kit-v04.md).
## 헤드리스 더미 렌더러로는 초상 메달의 기세 고리·마력 칸·생성 카드 손패·벽 외형·지대(가시덤불·꽃밭·재 구름·덫) 모양을 볼 수 없어 창으로 짧게 찍는다.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_merc_kit.gd
## 결과: godot/screenshots/merc-kit/*.png

const OUT := "res://screenshots/merc-kit/"
const Layout := preload("res://scripts/world/layout.gd")
var game


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(file: String) -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.get_viewport().get_texture().get_image().save_png(OUT + file + ".png")
	print("SHOT ", file)


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	game = current_scene
	root.size = Vector2i(1774, 887)
	await _wait(40)
	game.session.set_process(false)
	game.economy.set_process(false)
	var kit = game.merc_kit
	for p in ["브람", "올라프", "토르빈", "미라"]:
		kit.on_hired(p)
	var c: Vector3 = Layout.CAMPFIRE
	var bram = game.contracts.spawn_guard("merc", "브람", c + Vector3(2.0, 0, 0), null, "warrior")
	var olaf = game.contracts.spawn_guard("merc", "올라프", c + Vector3(-2.0, 0, 0), null, "hunter")
	var torbin = game.contracts.spawn_guard("merc", "토르빈", c + Vector3(0, 0, -2.0), null, "lumberjack")
	var mira = game.contracts.spawn_gatherer("미라", c + Vector3(0, 0, 2.2))
	await _wait(10)
	game.session.start_wave()
	game.waves.set_process(false)
	kit.set_process(false)
	await _wait(30)
	kit.mana = 6.5
	kit.momentum[bram.get_instance_id()] = 100.0
	kit.momentum[olaf.get_instance_id()] = 60.0
	kit.momentum[torbin.get_instance_id()] = 35.0
	kit.momentum[mira.get_instance_id()] = 80.0
	kit._shield[bram.get_instance_id()] = kit._clock + 999.0
	olaf.hp = olaf.max_hp * 0.55
	game.race_cards._build("log_wall", c + Vector3(4.5, 0, 3.0))
	game.player.position = c + Vector3(1.5, 0, 3.5)
	game.world.player_camera.recenter()
	await _wait(40)
	await _shot("01_night_hud")
	# 2) 2차(24명): 갱목 방벽·급조 방책과 지대(가시덤불·꽃밭·재 구름·올가미 덫)
	var p: Vector3 = c + Vector3(1.5, 0, 6.0)
	game.race_cards._build("timber_wall", p + Vector3(-3.0, 0, 0))
	game.race_cards._build("junk_wall", p + Vector3(3.0, 0, 0))
	kit._add_zone("hedge", p + Vector3(-3.0, 0, 3.0), kit.HEDGE_RADIUS, 999.0)
	kit._add_zone("garden", p + Vector3(3.0, 0, 3.0), kit.GARDEN_RADIUS, 999.0)
	kit._add_zone("ash", p + Vector3(0, 0, 6.0), kit.ASH_RADIUS, 999.0)
	kit._add_zone("trap", p + Vector3(0, 0, 2.0), kit.TRAP_TRIGGER, 999.0)
	game.player.position = p + Vector3(0, 0, 1.0)
	game.world.player_camera.recenter()
	await _wait(40)
	await _shot("03_walls_zones")
	quit(0)
