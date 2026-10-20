extends SceneTree
## 에린 첫 대화 대답 두 줄과 산장 관리 '손님' 탭 에린 칸의 술잔 카운터 실제 화면 캡처
## (술잔은 _draw 로 그린 그림이라 헤드리스 더미 렌더러로는 모양·색을 볼 수 없어서).
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_erin_resident.gd
## 결과: res://screenshots/erin/01-first-talk-choices.png · 02-drink-meter-filling.png · 03-drink-meter.png

const OUT := "res://screenshots/erin/"


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	create_timer(60.0, true, false, true).timeout.connect(func(): quit(1))
	_run.call_deferred()


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name))
	print("saved " + name)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _run() -> void:
	root.size = Vector2i(1600, 900)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await _frames(10)
	game.world.day_cycle.set_mode("day")
	var tv = game.tavern
	tv.erin_waiting = true
	game.economy.spawn_extra(tv.lead_guests())
	game.guest_arrival.finish()
	var visit: Dictionary = game.guest_events.visits.back()
	game.guest_events.admit(visit.profile)
	await _frames(4)
	game.guest_ui.open_conversation(visit.uid)
	await _frames(30)
	game.guest_ui.advance_dialogue()
	await _frames(60)
	await _shot("01-first-talk-choices.png")
	game.guest_ui.choose(1)
	await _frames(10)
	game.guest_ui.close_conversation(true)
	await _frames(4)
	tv.on_card_used("fire_ale")
	game.hud.open_lodge_panel(1)
	await _frames(4)
	tv.on_card_used("golden_mead")
	await _frames(12)
	await _shot("02-drink-meter-filling.png")
	await _frames(60)
	await _shot("03-drink-meter.png")
	quit(0)
