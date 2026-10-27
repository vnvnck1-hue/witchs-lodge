extends SceneTree
## 에린의 술 카드 v2 연출 실제 화면 캡처: 용의 숨결 불바다 · 서리 거인의 독주 얼음 덩어리 · 건배! 뒤 구토.
## 바닥 데칼의 색·블렌딩, 얼음의 반투명, 입자 모양은 헤드리스 더미 렌더러로 볼 수 없어 창을 띄운다(끝나면 자동 종료).
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_tavern_drinks_v2.gd
## 결과: res://screenshots/tavern-v07/ingame-*.png

const OUT := "res://screenshots/tavern-v07/"
const Layout := preload("res://scripts/world/layout.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")

var game


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	create_timer(90.0, true, false, true).timeout.connect(func(): quit(1))
	_run.call_deferred()


func frames(k: int) -> void:
	for i in k:
		await process_frame


func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	print("saved ", name)


func enemy(pos: Vector3):
	var m := MonsterScript.new()
	m.setup(game, 400.0, false)
	m.configure("spider")
	m.position = pos
	game.actors.add_child(m)
	return m


func _run() -> void:
	root.size = Vector2i(1600, 900)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(12)
	game.waves.set_process(false)
	game.world.day_cycle.set_mode("night")
	game.session.state = SessionScript.State.COMBAT
	var tv = game.tavern
	var spot: Vector3 = Layout.DOOR_FRONT + Vector3(5, 0, 6)
	game.player.global_position = spot + Vector3(-1.5, 0, 2.5)
	await frames(30)

	# 1. 용의 숨결
	var foes: Array = []
	for off in [Vector3(1.0, 0, 0.3), Vector3(-1.2, 0, -0.6), Vector3(0.2, 0, 1.4)]:
		var e = enemy(spot + off)
		e.set_physics_process(false)
		foes.append(e)
	tv.breathe(spot)
	await frames(50)
	await shot("ingame-01-dragon-breath")
	for f in get_nodes_in_group("dragon_breath_fires"):
		f.queue_free()

	# 2. 서리 거인의 독주
	for e in foes:
		e.set_physics_process(true)
	await frames(2)
	tv.freeze_area(spot)
	await frames(30)
	await shot("ingame-02-frost-giant")
	tv._tick_drinks(5.0)
	for e in foes:
		e.queue_free()

	# 3. 건배! → 5초 뒤 구토
	var cd = game.contracts
	cd.spawn_guard("merc", "브람", spot + Vector3(1.4, 0, 0), null, "warrior")
	cd.spawn_guard("merc", "하랄", spot + Vector3(-1.4, 0, 0.4), null, "hunter")
	await frames(10)
	for a in tv.cheer_targets():
		a.set_physics_process(true)
	tv.cheers()
	await frames(12)
	await shot("ingame-03-cheers")
	tv._tick_drinks(tv.CHEERS_TIME)
	await frames(40)
	await shot("ingame-04-vomit")
	quit(0)
