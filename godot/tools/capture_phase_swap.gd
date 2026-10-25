extends SceneTree
## 낮→밤 전환 손패 교체 연출 실제 화면 캡처(사용자 요청 2026-10-18: 한 장씩 주머니로 들어가고 한 장씩 뽑히는 순차 연출).
## 헤드리스로는 대기열·지연값만 확인할 수 있고, 카드가 실제로 차례로 날아가고 가운데에 공개되는 모습은 실제 렌더로만 볼 수 있어서 캡처한다.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_phase_swap.gd
## 2026-10-23: 주머니로 휘어 도는 곡선 흡입(휨·비틀림·말림)은 실제 렌더로만 보여서 흡입 구간(0~1초)을 촘촘히 찍는다. 결과: res://screenshots/phase_swap/01~10-*.png

const OUT := "res://screenshots/phase_swap/"


func _initialize() -> void:
	print("PHASE_SWAP initialize")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	create_timer(240.0, true, false, true).timeout.connect(func(): print("PHASE_SWAP timeout"); quit(1))
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func frames(n: int) -> void:
	for i in n:
		await process_frame


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(OUT + name))
	print("PHASE_SWAP saved ", name)


func _run() -> void:
	while current_scene == null or current_scene.get("cards") == null:
		await process_frame
	var game = current_scene
	print("PHASE_SWAP scene ready")
	root.size = Vector2i(1600, 900)
	await frames(30)
	game.session.set_process(false)
	var cards = game.cards
	for e in cards.entries.duplicate():
		cards.remove_uid(e["uid"])
	cards.draw_stack = 0
	for id in ["ward_lantern", "lamb", "guest_invitation", "sleeping_thorn_seed"]:
		cards.add(id)
	cards.add("timber", 4)
	cards.add("raw_meat", 2)
	for id in ["frost_rune", "vine_snare", "resin_torch", "firefly_swarm", "winter_firewood"]:
		cards.add(id, 1, "", "pocket")
	await frames(90)
	await _shot("01-day-hand.png")
	game.session.start_wave()   # 밤 시작 → phase_swap("night"): 낮 카드 5장 → 주머니, 밤 카드 5장 뽑기
	var times := [0.15, 0.3, 0.45, 0.6, 0.8, 1.05, 1.8, 2.6, 4.2]
	var names := ["02-suck-start", "03-suck-bend", "04-suck-twist", "05-suck-roll", "06-suck-last", "07-out-done", "08-in-first", "09-in-more", "10-night-hand"]
	var t0 := Time.get_ticks_msec()
	for i in times.size():
		while (Time.get_ticks_msec() - t0) / 1000.0 < float(times[i]):
			await process_frame
		await _shot(names[i] + ".png")
	quit(0)
