extends SceneTree
## 신규 카드 v01 실제 화면 캡처: 시작 손패, 낮(등불·새끼양 라벨), 밤(등불 빛·서리 룬 폭발).
## 실행(창 모드): godot --path . --script res://tools/capture_new_cards.gd
## 결과: res://screenshots/new-cards/*.png

const OUT := "res://screenshots/new-cards/"
const Cfg := preload("res://scripts/config.gd")

var main


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(name: String) -> void:
	await _wait(4)
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(OUT + name + ".png")
	print("SHOT ", name)


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	main = current_scene
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	await _wait(30)
	for pair in Cfg.STARTER_CARDS:
		main.cards.add(pair[0], pair[1])
	await _wait(90)
	await _shot("01-starter-hand")

	var cam: Camera3D = main.world.camera
	var pasture = main.world.pasture
	main.resolver.commit(_uid("lamb"), cam.unproject_position(Vector3(pasture.rect.get_center().x, 0, pasture.rect.get_center().y)))
	main.resolver.commit(_uid("ward_lantern"), cam.unproject_position(Vector3(-1.2, 0, 4.5)))
	await _wait(60)
	await _shot("02-day-lantern-lamb")

	main.session.start_wave()
	var t := 0
	while t < 1800:
		await physics_frame
		t += 1
		var near := false
		for e in main.get_tree().get_nodes_in_group("enemies"):
			if not e.dead and main.world.lodge.distance_to(e.global_position) < 6.0:
				near = true
		if near:
			break
	await _shot("03-night-lantern")
	for e in main.get_tree().get_nodes_in_group("enemies"):
		if not e.dead and main.world.lodge.distance_to(e.global_position) < 7.0:
			main.cards.add("frost_rune")
			main.resolver.commit(_uid("frost_rune"), cam.unproject_position(e.global_position))
			break
	await _wait(10)
	await _shot("04-night-frost-rune")
	quit(0)


func _uid(id: String) -> int:
	for e in main.cards.entries:
		if e["id"] == id:
			return e["uid"]
	return -1
