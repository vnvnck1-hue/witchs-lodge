extends SceneTree
## 달빛 스택(주머니 버튼 옆 동그란 돌 3개) 실제 화면 캡처.
## 헤드리스로는 count 값만 확인할 수 있고, 돌의 색·고리·가득 찼을 때의 청록 빛과 주머니 버튼과의 겹침은 실제 렌더로만 볼 수 있어서 캡처한다.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_draw_stack.gd
## 결과: res://screenshots/draw_stack/01-stack-0.png, 02-stack-2.png, 03-stack-3-waiting.png (좌하단 주머니 부분 확대)

const OUT := "res://screenshots/draw_stack/"


func _initialize() -> void:
	print("DRAW_STACK initialize")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	create_timer(240.0, true, false, true).timeout.connect(func(): print("DRAW_STACK timeout"); quit(1))
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func frames(n: int) -> void:
	for i in n:
		await process_frame


func _shot(name: String) -> void:
	await frames(20)
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	var h: int = img.get_height()
	var w: int = img.get_width()
	img.get_region(Rect2i(0, int(h * 0.62), int(w * 0.28), h - int(h * 0.62))).save_png(ProjectSettings.globalize_path(OUT + name))
	print("DRAW_STACK saved ", name)


func _run() -> void:
	while current_scene == null or current_scene.get("cards") == null:
		await process_frame
	var game = current_scene
	print("DRAW_STACK scene ready")
	root.size = Vector2i(1600, 900)
	await frames(30)
	game.world.day_cycle.set_mode("day")
	game.session.set_process(false)
	var cards = game.cards
	for e in cards.entries.duplicate():
		cards.remove_uid(e["uid"])
	cards.draw_stack = 0
	cards.stack_changed.emit(0)
	for i in 4:
		cards.add("moss_bandage")
	cards.add("frost_rune", 1, "", "pocket")   # 낮에는 뽑을 수 없는 카드만 주머니에 → 3개가 차면 대기 상태
	await frames(60)
	await _shot("01-stack-0.png")
	cards.consume(cards.hand()[0]["uid"])
	cards.consume(cards.hand()[0]["uid"])
	await _shot("02-stack-2.png")
	cards.consume(cards.hand()[0]["uid"])
	await frames(40)
	await _shot("03-stack-3-waiting.png")
	quit(0)
