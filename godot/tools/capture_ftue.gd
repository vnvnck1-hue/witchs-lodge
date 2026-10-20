extends SceneTree
## 첫 실행 플로우 실제 화면 캡처. 헤드리스 더미 렌더러로는 확인할 수 없는 것 — 타이틀·프롤로그 일러스트와 자막의 실제 합성,
## 1일차 새벽빛 색감(밤 → 새벽), 가운데 배너·혼잣말·튜토리얼 화살표의 실제 겹침 — 만 짧게 확인한다(흐름·타이밍은 verify_first_session.gd).
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_ftue.gd
## 결과: res://screenshots/ftue/*.png

const OUT := "res://screenshots/ftue/"
const Flow := preload("res://scripts/game/flow.gd")

var main


func _initialize() -> void:
	Flow.ftue_path = "user://ftue-capture.cfg"
	Flow.prologue_enabled = true   # 게임에서는 보류 중이어도 프롤로그 컷을 찍는다
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Flow.ftue_path))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	change_scene_to_file(Flow.TITLE_SCENE)
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _until(cond: Callable, limit := 1200) -> void:
	for i in limit:
		if cond.call():
			return
		await process_frame


func _shot(name: String) -> void:
	await _wait(3)
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(OUT + name + ".png")
	print("SHOT ", name)


func _run() -> void:
	await _until(func(): return current_scene != null and current_scene.get("menu") != null)
	var title = current_scene
	await _wait(40)
	await _shot("01-title")
	title._open_settings()
	await _wait(10)
	await _shot("02-title-settings")
	title.close_settings()
	title._open_select()
	await _wait(10)
	await _shot("03-witch-select")
	title.start_story()
	await _until(func(): return current_scene != null and current_scene.get("opening") != null and current_scene.opening != null)
	main = current_scene
	var op = main.opening
	await _wait(50)
	await _shot("04-prologue-1")
	op.prologue.next()
	op.prologue.next()
	await _wait(50)
	await _shot("05-prologue-3")
	op.skip_prologue()
	await _until(func(): return op.phase == "dawn")
	await _until(func(): return op._t >= 0.6)
	await _shot("06-dawn-night")
	await _until(func(): return main.banner.is_showing() and op._t >= 1.6)
	await _shot("07-day-card")
	await _until(func(): return op.bubble.visible and op.bubble.modulate.a > 0.9)
	await _shot("08-monologue")
	await _until(func(): return main.mulligan_ui.active and main.mulligan_ui._phase == "pick")
	await _wait(10)
	main.mulligan_ui.confirm()
	await _until(func(): return not op.active)
	await _wait(30)
	await _shot("09-day1-after-dawn")
	Engine.time_scale = 8.0
	await _until(func(): return main.tutorial.stage == "hire", 4000)
	Engine.time_scale = 1.0
	await _wait(20)
	await _shot("10-tutorial-hire")
	main.tutorial.hire_now()
	await _wait(30)
	await _shot("11-tutorial-place")
	for e in main.cards.hand():
		if e["id"] in preload("res://scripts/config.gd").JOB_CARDS:
			main.resolver.commit(e["uid"], main.world.camera.unproject_position(main.tutorial.place_spot))
	await _wait(30)
	main.session.start_wave()
	await _wait(40)
	await _shot("12-night-banner")
	main.world.lodge.take_damage(99999.0)
	await _wait(30)
	await _shot("13-defeat")
	Engine.time_scale = 1.0
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Flow.ftue_path))
	quit(0)
