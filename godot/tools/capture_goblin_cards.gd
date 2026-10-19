extends SceneTree
## 고블린 카드 v1 · 처치 골드 실제 화면 캡처(docs/goblin-cards-v01.md).
## 헤드리스 더미 렌더러로는 동전이 흩뿌려지는 모양·고블린 졸개(니브 모델 축소)·미끼 빛·덫·방책 블록아웃을 볼 수 없어 창으로 짧게 찍는다.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_goblin_cards.gd
## 결과: godot/screenshots/goblin-cards/*.png

const OUT := "res://screenshots/goblin-cards/"
const Layout := preload("res://scripts/world/layout.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const LureScript := preload("res://scripts/actors/goblin_lure.gd")
const TrapScript := preload("res://scripts/actors/goblin_trap.gd")
const BarricadeScript := preload("res://scripts/actors/junk_barricade.gd")
var game


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(file: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(OUT + file + ".png")
	print("SHOT ", file)


func _enemy(pos: Vector3):
	var m := MonsterScript.new()
	m.setup(game, 400.0, false)
	m.configure("spider")
	m.position = pos
	game.actors.add_child(m)
	return m


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	game = current_scene
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1774, 887)
	await _wait(40)
	game.economy.set_process(false)
	game.waves.set_process(false)
	game.world.day_cycle.set_mode("day")
	var c: Vector3 = Layout.DOOR_FRONT + Vector3(3.0, 0, 4.0)
	game.player.position = c + Vector3(-2.5, 0, 1.5)
	game.world.player_camera.recenter()
	await _wait(20)
	# 1) 졸개·미끼·덫·방책
	for i in 4:
		var a := TAU * i / 4.0
		game.goblin.spawn_minion(c + Vector3(cos(a), 0, sin(a)) * 1.0, "gang")
	var lure := LureScript.new()
	lure.game = game
	lure.position = c + Vector3(2.0, 0, -0.8)
	lure.time_left = 999.0
	game.actors.add_child(lure)
	for i in 3:
		var t := TrapScript.new()
		t.game = game
		t.position = c + Vector3(-1.6 + i * 0.7, 0, -1.6)
		game.actors.add_child(t)
	var bar := BarricadeScript.new()
	bar.game = game
	bar.position = c + Vector3(0.5, 0, -2.6)
	game.actors.add_child(bar)
	await _wait(30)
	for m in game.goblin.minions():
		m.set_physics_process(false)
	await _wait(5)
	await _shot("01-minions-lure-traps-barricade")
	# 2) 처치 골드: 적 셋을 쓰러뜨리고 동전이 흩어지는 순간
	var es: Array = []
	for i in 3:
		es.append(_enemy(c + Vector3(-1.0 + i * 1.2, 0, 1.6)))
	await _wait(20)
	for e in es:
		e.set_physics_process(false)
	for e in es:
		e.take_damage(99999.0)
	await _wait(14)
	await _shot("02-kill-gold-scatter")
	await _wait(22)
	await _shot("03-kill-gold-collect")
	quit()
