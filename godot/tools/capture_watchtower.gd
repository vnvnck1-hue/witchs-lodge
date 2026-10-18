extends SceneTree
## 감시탑 실제 화면 캡처(docs/watchtower-v01.md). 헤드리스 더미 렌더러로는 확인할 수 없는 항목만 본다:
## 사용자 GLB 탑의 실제 크기·방향(산장·모닥불·공터와의 비율), 원본 칠 셰이더 결과, 탑 위 사냥꾼이 발판에 서 보이는지, 밤 시야.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_watchtower.gd
## 결과: godot/screenshots/watchtower/*.png

const OUT := "res://screenshots/watchtower/"
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


func _perch(tower, n: int) -> void:
	for i in n:
		var h = game.contracts.spawn_guard("merc", "탑사냥꾼%d" % i, tower.climb_spot(), null, "hunter")
		await _wait(2)
		tower.claim(h)
		h.tower = tower
		h._climb()


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	game = current_scene
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1774, 887)
	await _wait(40)
	game.session.set_process(false)
	game.economy.set_process(false)
	var tl = game.world.towers[0]
	var tr = game.world.towers[1]
	# 공터 단계 표시(적립 중)
	tl.deposit(2)
	game.world.day_cycle.set_mode("day")
	game.hud.visible = false
	game.world.player_camera.toggle_overview()
	await _wait(20)
	await _shot("01-day-overview-sites")
	# 왼쪽 1단계, 오른쪽 2단계
	tl.deposit(5)
	tl.construct()
	for lv in 2:
		tr.deposit(5)
		tr.construct()
	await _wait(40)
	await _perch(tl, 1)
	await _perch(tr, 3)
	await _wait(10)
	await _shot("02-day-overview-built")
	game.world.player_camera.toggle_overview()
	game.player.position = Layout.CAMPFIRE + Vector3(-1.5, 0, 0.8)
	game.player.moving = false
	game.world.player_camera.recenter()
	game.hud.visible = true
	await _wait(25)
	await _shot("03-day-follow-hud")
	game.hud.visible = false
	game.world.day_cycle.set_mode("night")
	game.world.player_camera.toggle_overview()
	await _wait(25)
	await _shot("04-night-overview")
	tl.take_damage(99999.0)
	await _wait(40)
	game.world.day_cycle.set_mode("day")
	await _wait(20)
	await _shot("05-day-collapsed-left")
	quit()
