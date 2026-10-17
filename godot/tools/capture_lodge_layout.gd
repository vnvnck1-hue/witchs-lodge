extends SceneTree
## A안 산장 주변 재배치 실제 화면 캡처. 헤드리스 더미 렌더러로는 확인할 수 없는 항목만 본다:
## 바위 띠·모닥불·공터의 실제 외형과 가림, 낮/밤 색감(승인 원화와 비교), 기본 추적 카메라 + 실제 손패 HUD에서의 시야.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_lodge_layout.gd
## 결과: godot/screenshots/lodge-layout/*.png

const OUT := "res://screenshots/lodge-layout/"
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
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(OUT + file + ".png")
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
	game.player.position = Layout.PLAYER_START
	game.player.moving = false
	game.world.player_camera.recenter()
	# 1. 낮 · 기본 추적 카메라 · 실제 HUD(손패) — 마당·길·시설이 손패에 가리지 않는지
	game.world.day_cycle.set_mode("day")
	await _wait(20)
	await _shot("01-day-follow-hud")
	# 2. 낮 · 전체 조감(F4) · HUD 숨김 — 승인 원화와 배치 관계 비교
	game.hud.visible = false
	game.world.player_camera.toggle_overview()
	await _wait(10)
	await _shot("02-day-overview")
	# 3. 밤 · 전체 조감 — 모닥불·창문 주변에만 따뜻한 빛
	game.world.day_cycle.set_mode("night")
	await _wait(20)
	await _shot("03-night-overview")
	# 4. 밤 · 추적 카메라, 마녀가 모닥불 옆에 서 있음
	game.world.player_camera.toggle_overview()
	game.player.position = Layout.CAMPFIRE + Vector3(-2.2, 0, 0.6)
	game.world.player_camera.recenter()
	game.hud.visible = true
	await _wait(20)
	await _shot("04-night-campfire-follow")
	# 5. 낮 · 산장 뒤 바위 띠와 묘지 포켓을 가까이(마녀를 목장 문 앞에 두고 줌 인)
	game.world.day_cycle.set_mode("day")
	game.hud.visible = false
	game.player.position = Vector3(6.5, 0, 2.0)
	game.world.player_camera.recenter()
	game.world.player_camera.zoom(-3)
	await _wait(40)
	await _shot("05-day-rear-ring-zoom")
	quit(0)
