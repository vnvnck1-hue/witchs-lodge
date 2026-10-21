extends SceneTree
## F10 캐릭터 분리 시험 4단계 실제 화면 캡처(창 필요: 외곽선·림·그림자·빛의 실제 색과 블렌딩은 헤드리스로 확인 불가).
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_character_readability.gd
## 결과: godot/screenshots/character-readability/<단계>.png (전체 화면)

const R := preload("res://scripts/visual/character_readability.gd")
const OUT := "res://screenshots/character-readability/"


func _initialize() -> void: call_deferred("_run")


func shot(name: String) -> void:
	for i in 8: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 30: await physics_frame
	game.session.set_process(false)
	game.economy.set_process(false)
	var mod = game.find_child("CharacterReadability", true, false)
	mod.settings_path = "user://capture_readability.cfg"
	var p = game.player
	var at: Vector3 = load("res://scripts/world/layout.gd").DOOR_FRONT + Vector3(0.6, 0, 3.2)
	p.global_position = at
	p.visual.rotation.y = 0.0
	# 비교용 손님(니브)을 마녀 옆 눈밭에 세운다
	var t = load("res://scripts/actors/traveler.gd").new()
	t.profile = {"character_id": "nib", "race": "goblin"}
	game.world.add_child(t)
	t.global_position = at + Vector3(1.6, 0, 0.6)
	t.set_physics_process(false)
	t.set_process(false)
	game.world.player_camera.recenter()
	for id in R.IDS:
		mod.set_mode(id, false)
		await shot(id)
	quit(0)
