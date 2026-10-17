extends SceneTree
## 산장 관리 '계약' 탭 실제 화면 캡처(헤드리스로는 글자 넘침·버튼 배치를 볼 수 없어서).
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_contract_tab.gd
## 결과: res://screenshots/contracts/01-contract-tab.png

const OUT := "res://screenshots/contracts/"


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	create_timer(60.0, true, false, true).timeout.connect(func(): quit(1))
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1600, 900)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	for i in 10:
		await process_frame
	game.world.day_cycle.set_mode("day")
	var cd = game.contracts
	cd.spawn_guard("merc", "브람", Vector3(2.0, 0, 6.0), null, "warrior")
	var lj = cd.spawn_guard("merc", "토르빈", Vector3(2.9, 0, 5.0), null, "lumberjack")
	lj.add_carry("timber", 10)
	lj.become_idle(cd.yard_spot(lj))
	game.cards.add("hunter", 1, "올라프")
	game.cards.add("gatherer", 1, "미라")
	game.hud.open_lodge_panel(3)
	for i in 20:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "01-contract-tab.png"))
	print("saved")
	quit(0)
