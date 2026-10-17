extends SceneTree
## 기다림 게이지 실제 화면 캡처(헤드리스로는 색·두께·배치를 볼 수 없어서). 대화 알림과 고용 제안이 함께 뜬 좌측을 찍는다.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_wait_gauge.gd
## 결과: res://screenshots/wait-gauge/01-full.png(가득), 02-low.png(끝무렵 붉게)

const OUT := "res://screenshots/wait-gauge/"


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	create_timer(90.0, true, false, true).timeout.connect(func(): quit(1))
	_run.call_deferred()


func frames(n := 2) -> void:
	for i in n:
		await process_frame


func advance(seconds: float) -> void:
	Engine.time_scale = 10.0
	await create_timer(seconds / 10.0, true, false, true).timeout
	Engine.time_scale = 1.0
	await frames(3)


func shot(id: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + id + ".png"))
	print("saved ", OUT + id + ".png")


func _run() -> void:
	root.size = Vector2i(1600, 900)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(10)
	print("step loaded")
	game.world.day_cycle.set_mode("day")
	var eco = game.economy
	var events = game.guest_events
	print("step invite ", eco.invite_block_reason())
	eco.invite_batch()
	await frames(4)
	var visits: Array = events.current_guests()
	var first: Dictionary = visits[visits.size() - 2]
	var second: Dictionary = visits[visits.size() - 1]
	for e in [first, second]:
		events.admit(e.profile)
	first.read = true
	# 고용 제안을 바로 띄워 대화 알림과 함께 보이게 한다
	var guest = eco.batches[eco.batches.size() - 1]["guests"][0]
	eco._open_offer(guest, eco.prep_time)
	second.ready = true
	second.read = false
	await advance(0.5)
	await shot("01-full")
	for i in 12:
		if eco.offers.is_empty() or eco.offer_time_left(eco.offers[0]) < 1.8:
			break
		await advance(1.0)
	await shot("02-low")
	quit(0)
