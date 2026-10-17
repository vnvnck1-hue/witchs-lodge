extends SceneTree
## 볼륨 확장 E1~E3 실제 화면 캡처. 헤드리스 더미 렌더러로는 확인할 수 없는 표시(적 종류 표식·보스 크기·제단 모형·
## 새벽 보상/장날 화면의 카드 배치·임시 카드 원화)를 짧게 확인한다.
## 실행(창 모드): godot --path . --script res://tools/capture_chapter.gd
## 결과: res://screenshots/chapter/*.png

const OUT := "res://screenshots/chapter/"
const SessionScript := preload("res://scripts/game/game_session.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")

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


func _spawn(kind: String, pos: Vector3) -> void:
	var m := MonsterScript.new()
	m.setup(main, 60.0, false)
	m.configure(kind)
	m.position = pos
	main.actors.add_child(m)


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	main = current_scene
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	await _wait(30)
	main.session.set_process(false)
	main.economy.set_process(false)
	var ch = main.chapter

	# 1. 새벽 보상 화면(임시 카드 원화)
	main.offer_ui.open_reward(["moss_bandage", "resin_torch", "firefly_swarm"])
	await _wait(20)
	await _shot("01-dawn-reward")
	main.offer_ui.close()

	# 2. 장날 화면
	main.economy.gold = 80
	main.cards.add("corrupt_prayer", 1, "", "pocket")
	main.offer_ui.open_market([{"id": "vine_snare", "price": 20, "sold": false}, {"id": "winter_firewood", "price": 15, "sold": false},
		{"id": "frost_rune", "price": 25, "sold": false}, {"id": "treasure_chest", "price": 45, "sold": false}])
	await _wait(20)
	await _shot("02-market")
	main.offer_ui.close()

	# 3. 복구된 제단과 제단 창
	ch.altar_unlocked = true
	main.cards.add("timber", 10)
	ch.restore_altar()
	main.player.global_position = ch.altar_pos() + Vector3(-1.8, 0, 1.2)
	main.player.set_destination(main.player.global_position)
	await _wait(60)
	await _shot("03-altar")
	main.altar_ui.open()
	await _wait(10)
	await _shot("04-altar-panel")
	main.altar_ui.close()

	# 4. 밤: 적 종류(숲의 괴물·침식된 자·맹독 곤충·공성 괴물·보스)
	main.player.global_position = Vector3(1.5, 0, 9.5)
	main.player.set_destination(main.player.global_position)
	main.session.state = SessionScript.State.COMBAT
	main.session.wave_index = 12
	var base := Vector3(-3, 0, 6.5)
	_spawn("forest", base + Vector3(0, 0, 0))
	_spawn("cultist", base + Vector3(1.6, 0, 0))
	_spawn("insect", base + Vector3(3.0, 0, 0))
	_spawn("brute", base + Vector3(4.8, 0, 0))
	_spawn("boss", base + Vector3(8.0, 0, 0.6))
	await _wait(8)
	for e in main.get_tree().get_nodes_in_group("enemies"):
		e.set_physics_process(false)
	await _wait(60)
	await _shot("05-enemy-kinds")
	quit(0)
