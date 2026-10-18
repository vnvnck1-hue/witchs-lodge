extends SceneTree
## 식생 구분선 시안 실제 화면 캡처. 헤드리스 더미 렌더러로는 볼 수 없는 항목만 본다:
## 시안별 식생 띠의 실제 실루엣·밀도·가림, 길목이 좁아 보이는 정도, 기본 추적 카메라 + 손패 HUD 에서의 시야.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_yard_hedges.gd
## 결과: godot/screenshots/yard-hedges/<시안>-<장면>.png + compare-*.png 비교판

const OUT := "res://screenshots/yard-hedges/"
const Layout := preload("res://scripts/world/layout.gd")
const Hedges := preload("res://scripts/world/yard_hedges.gd")
const VARIANTS := ["none", "a", "b", "c"]
## 장면: id, 마녀 위치(추적 카메라 기준), HUD 표시, 조감 여부
const SCENES := [
	{"id": "01-overview", "at": Layout.PLAYER_START, "hud": false, "overview": true},
	{"id": "02-follow-hud", "at": Layout.PLAYER_START, "hud": true, "overview": false},
	{"id": "03-left-lane", "at": Vector3(-11.0, 0, 6.5), "hud": false, "overview": false},
	{"id": "04-right-lane", "at": Vector3(15.5, 0, 6.0), "hud": false, "overview": false},
]
var game
var shots: Dictionary = {}


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(file: String) -> Image:
	await _wait(6)
	await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(OUT + file + ".png")
	print("SHOT ", file)
	return img


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	game = current_scene
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1774, 887)
	await _wait(40)
	game.session.set_process(false)
	game.economy.set_process(false)
	game.world.day_cycle.set_mode("day")
	game.player.moving = false
	for v in VARIANTS:
		var label: String = game.world.yard_hedges.rebuild(v)
		print("VARIANT ", v, " ", label, " parts=", game.world.yard_hedges.count())
		await _wait(20)
		for scene in SCENES:
			game.player.position = scene.at
			game.hud.visible = scene.hud
			if game.world.player_camera.follow_enabled == scene.overview:
				game.world.player_camera.toggle_overview()
			if not scene.overview: game.world.player_camera.recenter()
			await _wait(24)
			shots[v + "/" + scene.id] = await _shot(v + "-" + scene.id)
	# 비교판: 시안 4종을 2×2 로 붙인다(조감·왼쪽 길목·오른쪽 길목)
	for scene_id in ["01-overview", "03-left-lane", "04-right-lane"]:
		var first: Image = shots[VARIANTS[0] + "/" + scene_id]
		var w := first.get_width()
		var h := first.get_height()
		var sheet := Image.create(w * 2, h * 2, false, first.get_format())
		for i in VARIANTS.size():
			var img: Image = shots[VARIANTS[i] + "/" + scene_id]
			sheet.blit_rect(img, Rect2i(0, 0, w, h), Vector2i((i % 2) * w, (i / 2) * h))
		sheet.resize(w, h, Image.INTERPOLATE_LANCZOS)
		sheet.save_png(OUT + "compare-" + scene_id + ".png")
		print("SHEET compare-", scene_id, " (좌상 현재 · 우상 A · 좌하 B · 우하 C)")
	quit(0)
