extends SceneTree
## 모닥불 연료 실제 화면 캡처(docs/resource-uses-expansion-v01.md v0.3). 헤드리스 더미 렌더러로 확인할 수 없는 것만 본다:
## 불 위 링 게이지의 실제 모양·색, 다친 용병이 모닥불 곁에서 쉬는 모습, 밤에 불이 꺼졌을 때 앞마당이 어두워지는 정도.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_campfire.gd
## 결과: godot/screenshots/campfire/*.png

const OUT := "res://screenshots/campfire/"
const Layout := preload("res://scripts/world/layout.gd")
var game


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(file: String) -> void:
	await _wait(6)
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(OUT + file + ".png")
	print("SHOT ", file)


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	game = current_scene
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1774, 887)
	await _wait(40)
	game.session.set_process(false)
	game.economy.set_process(false)
	var yard = game.world.yard
	# 낮: 목재 2개분, 다친 전투용병 둘이 모닥불 곁에서 쉼, 마녀가 불 가까이(링 표시)
	game.world.day_cycle.set_mode("day")
	yard.fuel = 115.0
	yard.gauge_shown = yard.fuel_ratio()
	for i in 2:
		var a = game.contracts.spawn_guard("merc", "검증 전사%d" % i, Layout.CAMPFIRE + Vector3(2.5 + i, 0, 1.5), null, "warrior")
		a.hp = a.max_hp * 0.35
	game.player.position = Layout.CAMPFIRE + Vector3(-2.2, 0, 1.4)
	game.player.moving = false
	game.world.player_camera.recenter()
	await _wait(120)
	await _shot("01-day-ring-resting-mercs")
	# 연료가 얼마 안 남음(붉은 링)
	yard.fuel = 20.0
	await _wait(60)
	await _shot("02-day-ring-low")
	# 밤: 켜진 불 / 꺼진 불
	game.world.day_cycle.set_mode("night")
	yard.fuel = 150.0
	yard.gauge_shown = yard.fuel_ratio()
	await _wait(40)
	await _shot("03-night-lit")
	yard.fuel = 0.0
	await _wait(60)
	await _shot("04-night-out")
	quit(0)
