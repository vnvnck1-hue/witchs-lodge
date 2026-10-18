extends SceneTree
## 재화 묶음 수량 배지(카드 왼쪽 아래) 실제 화면 캡처.
## 헤드리스로는 배지 좌표만 확인할 수 있고, 부채꼴 손패에서 옆 카드에 가려지지 않는지는 실제 렌더로만 볼 수 있어서 캡처한다.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_stack_badge.gd
## 결과: res://screenshots/stack_badge/01-hand.png (화면 전체), 02-hand-crop.png (손패 부분)

const OUT := "res://screenshots/stack_badge/"


func _initialize() -> void:
	print("STACK_BADGE initialize")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	create_timer(240.0, true, false, true).timeout.connect(func(): print("STACK_BADGE timeout"); quit(1))
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func frames(n: int) -> void:
	for i in n:
		await process_frame


func _run() -> void:
	while current_scene == null or current_scene.get("cards") == null:
		await process_frame
	var game = current_scene
	print("STACK_BADGE scene ready")
	root.size = Vector2i(1600, 900)
	await frames(30)
	game.world.day_cycle.set_mode("day")
	game.session.set_process(false)
	var cards = game.cards
	for e in cards.entries.duplicate():
		cards.remove_uid(e["uid"])
	# 묶음 재화와 낱장 카드를 섞어 부채꼴로 겹치게 한다
	cards.add("timber", 5)
	cards.add("frost_rune")
	cards.add("wool", 3)
	cards.add("raw_meat", 12)
	cards.add("ward_lantern")
	cards.add("rabbit_pelt", 2)
	cards.add("black_wool", 1)
	await frames(240)
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(OUT + "01-hand.png"))
	var top: int = int(img.get_height() * 0.55)
	img.get_region(Rect2i(0, top, img.get_width(), img.get_height() - top)).save_png(ProjectSettings.globalize_path(OUT + "02-hand-crop.png"))
	print("STACK_BADGE saved ", img.get_size())
	quit(0)
