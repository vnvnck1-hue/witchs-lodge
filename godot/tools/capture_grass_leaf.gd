extends SceneTree
## 바닥 풀 잎 형태·손그림 질감 실제 화면 캡처. 헤드리스 더미 렌더러로는 셰이더 결과(잎맥·붓결·색 그라데이션)를 볼 수 없어 창 모드로 찍는다.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_grass_leaf.gd -- <접두어>
## 결과: godot/screenshots/grass-leaf/<접두어>-*.png

const OUT := "res://screenshots/grass-leaf/"
const Layout := preload("res://scripts/world/layout.gd")
var game
var prefix := "after"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0: prefix = args[0]
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(file: String) -> void:
	await _wait(6)
	await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(OUT + prefix + "-" + file + ".png")
	print("SHOT ", prefix, "-", file)


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	game = current_scene
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1600, 900)
	await _wait(40)
	game.session.set_process(false)
	game.economy.set_process(false)
	game.hud.visible = false
	game.player.moving = false
	# 1. 낮 · 산장 옆 촘촘한 안쪽 풀밭, 기본 거리
	game.world.day_cycle.set_mode("day")
	game.player.position = Vector3(-5.5, 0, 7.0)
	game.world.player_camera.recenter()
	await _wait(30)
	await _shot("01-day-follow")
	# 2. 낮 · 줌 인 — 잎 하나하나의 형태와 질감
	game.world.player_camera.zoom(-4)
	await _wait(40)
	await _shot("02-day-zoom")
	# 2b. Shift+F6 과 같은 경로로 이전 풀(classic) 프리셋 전환 → 같은 화면, 다시 되돌림
	print("SHAPE ", game.world.cycle_grass_shape())
	await _wait(10)
	await _shot("05-day-zoom-classic-preset")
	print("SHAPE ", game.world.cycle_grass_shape())
	await _wait(10)
	# 3. 밤 · 같은 위치 줌 인 — 레퍼런스와 같은 어두운 톤에서의 읽힘
	game.world.day_cycle.set_mode("night")
	await _wait(30)
	await _shot("03-night-zoom")
	# 4. 낮 · 조감 — 넓은 풀밭이 단조로운 반복으로 보이지 않는지
	game.world.day_cycle.set_mode("day")
	game.world.player_camera.zoom(4)
	game.world.player_camera.toggle_overview()
	await _wait(30)
	await _shot("04-day-overview")
	quit(0)
