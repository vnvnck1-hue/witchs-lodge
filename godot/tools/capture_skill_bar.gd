extends SceneTree
## 플레이어 스킬 바 자리 실제 화면 캡처(2026-10-22: 산장 관리 버튼 왼쪽 아래 빈자리로 이동).
## 헤드리스로 확인할 수 없는 것: 스킬 원·번개 문양·라벨이 물약 소품·산장 관리 버튼과 실제로 겹치지 않는 모습.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_skill_bar.gd
## 결과: godot/screenshots/skill-bar/*.png (마녀 Q 번개 일격 / 늑대 Q·E, 16:9 와 넓은 화면)

const OUT := "res://screenshots/skill-bar/"
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
	game.world.day_cycle.set_mode("day")
	game.cards.add("timber", 2)
	game.cards.add("poison_mushroom", 2)
	await _wait(20)
	await _shot("01-witch-lightning-16x9")
	game.player.set_wolf(true)
	await _wait(20)
	await _shot("02-wolf-claw-pounce-16x9")
	game.player.set_wolf(false)
	root.size = Vector2i(2200, 887)
	await _wait(20)
	await _shot("03-witch-lightning-wide")
	quit(0)
