extends SceneTree
## 늑대의 피 실제 화면 캡처(docs/wolf-blood-event-design.md §5). 헤드리스 더미 렌더러로 확인할 수 없는 것만 본다:
## 늑대의 피를 마신 마녀의 괴로워하는 자세·섬광, 달 카드가 주머니로 날아가는 연출, 임시 늑대 블록아웃 모델의 실제 모양·달빛 고리·스킬 바, Q 할퀴기 이펙트.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_wolf_blood.gd
## 결과: godot/screenshots/wolf-blood/*.png

const OUT := "res://screenshots/wolf-blood/"
const Cfg := preload("res://scripts/config.gd")
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


func _psp() -> Vector2:
	return game.world.camera.unproject_position(game.player.global_position + Vector3(0, 1.0, 0))


func _uid(id: String) -> int:
	for e in game.cards.entries:
		if e["id"] == id:
			return e["uid"]
	return -1


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	game = current_scene
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1774, 887)
	await _wait(40)
	game.economy.set_process(false)
	game.world.day_cycle.set_mode("day")
	var player = game.player
	player.position = Vector3(-1.5, 0, 5.0)
	game.world.player_camera.recenter()
	game.cards.add("wolf_blood", 1)
	await _wait(30)
	await _shot("01-day-wolf-blood-in-hand")
	# 늑대의 피 사용 → 괴로워하는 자세(0.5초 뒤)와 달 카드가 주머니로 날아가는 순간(1.3초 뒤)
	game.resolver.commit(_uid("wolf_blood"), _psp())
	await _wait(30)
	await _shot("02-suffering")
	await _wait(45)
	await _shot("03-moon-cards-fly-to-pocket")
	await _wait(90)
	# 밤: 보름달 → 늑대
	game.session.start_wave()
	await _wait(10)
	game.waves.stop()
	for e in get_nodes_in_group("enemies"):
		e.queue_free()
	await _wait(5)
	game.world.day_cycle.set_mode("night")
	var full := _uid("full_moon")
	if game.cards.get_entry(full)["zone"] != "hand":
		game.cards.draw_uid(full)
	await _wait(20)
	await _shot("04-night-full-moon-in-hand")
	game.resolver.commit(full, _psp())
	await _wait(50)
	await _shot("05-wolf-form-idle-skillbar")
	# 적 둘을 앞에 두고 Q 할퀴기
	var ahead: Vector3 = player.global_position + Vector3(0, 0, 1.6)
	game.waves.spawn_extra(ahead, "forest")
	game.waves.spawn_extra(ahead + Vector3(0.9, 0, 0.4), "forest")
	await _wait(5)
	for e in get_nodes_in_group("enemies"):
		e.set_physics_process(false)
	player.cast_claw(ahead)
	await _wait(10)
	await _shot("06-wolf-claw-q")
	await _wait(30)
	# 달리기 자세
	player.set_destination(player.global_position + Vector3(4.0, 0, -2.0))
	await _wait(14)
	await _shot("07-wolf-running")
	quit(0)
