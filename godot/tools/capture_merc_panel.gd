extends SceneTree
## 용병 관리 창 실제 화면 캡처 — 헤드리스 더미 렌더러로는 창 안 초상 오림·체력 고리·글자 배치를 볼 수 없어 창으로 짧게 찍는다.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_merc_panel.gd
## 결과: godot/screenshots/merc-panel/*.png

const OUT := "res://screenshots/merc-panel/"
const Layout := preload("res://scripts/world/layout.gd")
var game


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(file: String) -> void:
	await _wait(4)
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
	game.economy.set_process(false)
	game.waves.set_process(false)
	game.world.day_cycle.set_mode("day")
	var people := ["브람", "토르그림", "파르그", "티슬", "올라프", "사야", "우르소", "모미"]
	var base: Vector3 = Layout.DOOR_FRONT + Vector3(2.5, 0, 2.0)
	var allies: Array = []
	for i in people.size():
		var a = game.contracts.spawn_guard("merc", people[i], base + Vector3(i * 1.1, 0, 0), null, ["warrior", "hunter", "lumberjack"][i % 3])
		a.set_physics_process(false)
		a.hp = a.max_hp * [1.0, 0.7, 0.4, 0.2][i % 4]
		allies.append(a)
	await _wait(30)
	var pf = game.hud.party_frame
	for h in pf._hits:
		if h["holder"] == allies[2] and h.get("part", "") == "medal":
			pf.hover_override = (h["rect"] as Rect2).get_center()
	await _shot("medal-tooltip-race")
	for h in pf._hits:
		if h.get("part", "") == "more":
			pf.hover_override = (h["rect"] as Rect2).get_center()
	await _shot("more-hover")
	pf.hover_override = Vector2(-1, -1)
	game.hud.open_merc_panel()
	await _wait(10)
	await _shot("merc-panel")
	quit(0)
