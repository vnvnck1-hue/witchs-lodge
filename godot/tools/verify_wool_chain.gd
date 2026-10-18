extends SceneTree
## 양털 연속 수확 헤드리스 검증(사용자 요청 2026-10-18): 한 마리를 깎기 시작하면 같은 목장의 털 난 양을 가장 가까운 순서로 차례차례 깎고,
## 도중에 다른 털 난 양을 클릭하면 그 양부터 바로 깎는다(깎던 양은 진행을 남기고 대기열로 돌아가 나중에 이어서 깎는다).
## 직접 이동·밤 시작이면 체인이 끝난다. 실제 main.tscn 의 마녀·목장·클릭 입력 경로를 그대로 쓴다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_wool_chain.gd

const Cfg := preload("res://scripts/config.gd")

var game
var passed := 0
var total := 0


func check(label: String, ok: bool, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print("%s %s%s" % ["PASS" if ok else "FAIL", label, "" if detail == "" else " — " + detail])


func _initialize() -> void:
	create_timer(240.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); print("RESULT %d/%d" % [passed, total + 1]); quit(1))
	_run.call_deferred()


func frames(n: int) -> void:
	for i in n:
		await physics_frame


func wait_until(cond: Callable, seconds: float) -> bool:
	var end := Time.get_ticks_msec() + int(seconds * 1000.0 / maxf(Engine.time_scale, 0.01))
	while not cond.call():
		if Time.get_ticks_msec() > end:
			return false
		await physics_frame
	return true


func ready_herd() -> Array:
	return game.world.pasture.slots.filter(func(s): return is_instance_valid(s) and not s.dead and not s.is_lamb)


func click_sheep(s) -> bool:
	var cam: Camera3D = game.world.camera
	var sp: Vector2 = cam.unproject_position(s.global_position + Vector3(0, 0.4, 0))
	var vp := root.get_visible_rect().size
	if cam.is_position_behind(s.global_position) or sp.x < 0 or sp.y < 0 or sp.x > vp.x or sp.y > vp.y:
		return false
	var mb := InputEventMouseButton.new()
	mb.button_index = MOUSE_BUTTON_LEFT
	mb.pressed = true
	mb.position = sp
	mb.global_position = sp
	game._unhandled_input(mb)
	return true


func _run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(10)
	var pl = game.player
	var pen = game.world.pasture
	check("낮(준비) 상태에서 시작", game.session.state == 0)
	# 어른 양 4마리를 확보하고 모두 털이 나게 한다
	while ready_herd().size() < 4 and pen.has_empty_slot():
		pen.spawn_sheep(1)
	await frames(3)
	var herd := ready_herd()
	check("어른 양 4마리 이상", herd.size() >= 4, str(herd.size()))
	for s in herd:
		s.wool_ready = true
		s.shear_progress = 0.0
		s.hp = 1.0e6
		s.max_hp = 1.0e6
	for e in get_nodes_in_group("enemies"):
		e.queue_free()
	Engine.time_scale = 3.0
	var wool0: int = game.cards.count_of("wool") + game.cards.count_of("black_wool")

	print("── 1. 순서 계산")
	var plan: Array = pl.harvest_plan(pen, pl.global_position)
	check("체인 전 계획에 털 난 양이 모두 들어 있다", plan.size() == herd.size(), "%d/%d" % [plan.size(), herd.size()])
	var greedy_ok := true
	var pos: Vector3 = pl.global_position
	var rest: Array = plan.duplicate()
	for s in plan:
		for o in rest:
			if pl._flat_dist_between(pos, o.global_position) < pl._flat_dist_between(pos, s.global_position) - 0.001:
				greedy_ok = false
		rest.erase(s)
		pos = s.global_position
	check("계획은 매번 가장 가까운 양을 고른다", greedy_ok)

	print("── 2. 한 마리 클릭 → 연속 수확 시작")
	var first = plan[0]
	pl.harvest(first)
	check("수확 시작: 체인 켜짐, 첫 대상 = 클릭한 양, 양이 멈춘다", pl.harvest_chain and pl.harvest_target == first and first.held)
	var ok := await wait_until(func(): return not first.wool_ready, 40.0)
	check("첫 양을 다 깎는다", ok and pl.harvest_done_in_chain == 1)
	await frames(2)
	var second = pl.harvest_target
	check("다 깎으면 저절로 다음 털 난 양으로 넘어간다", pl.harvest_chain and second != null and second != first and second.wool_ready)
	var expect: Array = pl.harvest_plan(pen, first.global_position)
	check("다음 대상은 남은 양 중 가장 가까운 양", true if expect.is_empty() else (second == pl.harvest_plan(pen, first.global_position)[0] or pl._flat_dist_between(first.global_position, second.global_position) <= pl._flat_dist_between(first.global_position, expect[0].global_position) + 0.6))

	print("── 3. 깎는 도중 다른 양을 클릭 → 바로 순서 변경")
	ok = await wait_until(func(): return pl.shearing and pl.harvest_t > 0.6, 30.0)
	check("두 번째 양을 깎는 중", ok and pl.harvest_target == second)
	var others: Array = ready_herd().filter(func(s): return s.wool_ready and s != second)
	var pick = others[others.size() - 1]   # 계획상 맨 뒤 양을 고른다
	var clicked := click_sheep(pick)
	if not clicked:
		print("INFO 카메라 밖이라 클릭 대신 harvest() 직접 호출")
		pl.harvest(pick)
	await frames(2)
	check("클릭한 양이 즉시 대상이 된다(체인 유지)", pl.harvest_target == pick and pl.harvest_chain, "클릭 경로=%s" % str(clicked))
	check("깎던 양은 털이 그대로 남고 진행이 저장된다", second.wool_ready and second.shear_progress > 0.5 and not second.held and not second.shearing, "진행 %.2f초" % second.shear_progress)
	check("깎던 양은 남은 순서에 다시 들어간다", second in pl.harvest_plan())
	check("새 대상의 깎기 진행은 0부터", pl.harvest_t == 0.0 and not pl.shearing)
	check("같은 양을 다시 클릭해도 진행이 초기화되지 않는다", (func():
		pl.harvest(pick)
		return pl.harvest_target == pick).call())

	print("── 4. 끝까지 연속 수확")
	var resumed_from := [-1.0]   # 람다는 지역 변수를 복사로 잡으므로 배열에 담는다
	var watch_second := func():
		if pl.harvest_target == second and resumed_from[0] < 0.0:
			resumed_from[0] = pl.harvest_t
		return not pl.harvest_chain
	ok = await wait_until(watch_second, 90.0)
	check("털 난 양이 없으면 체인이 저절로 끝난다", ok and not pl.harvest_chain and pl.harvest_target == null)
	check("돌아온 양은 저장된 진행에서 이어 깎는다", resumed_from[0] > 0.5, "재개 시점 %.2f초" % resumed_from[0])
	var left := ready_herd().filter(func(s): return s.wool_ready)
	check("목장의 털 난 양을 모두 깎았다", left.is_empty(), "%d마리 남음" % left.size())
	var wool1: int = game.cards.count_of("wool") + game.cards.count_of("black_wool")
	check("깎은 만큼 양털 카드가 들어왔다", wool1 - wool0 == herd.size(), "+%d" % (wool1 - wool0))
	check("깎인 양의 진행값은 0으로 정리된다", herd.all(func(s): return s.shear_progress == 0.0))
	check("모든 양이 다시 자유롭게 움직인다(held 해제)", herd.all(func(s): return not s.held and not s.shearing))

	print("── 5. 직접 이동·밤이면 체인 종료")
	for s in herd:
		s.wool_ready = true
	pl.harvest(herd[0])
	await frames(5)
	pl.set_destination(pl.global_position + Vector3(1.5, 0, 0))
	check("땅 클릭(직접 이동)하면 체인이 끝난다", not pl.harvest_chain and pl.harvest_target == null and not herd[0].held)
	pl.harvest(herd[1])
	await frames(5)
	game.session.start_wave()
	await frames(3)
	check("밤이 시작되면 체인이 끝난다", not pl.harvest_chain and pl.harvest_target == null)
	check("털 난 양은 그대로 남는다(밤에 잃지 않음)", herd[1].wool_ready)

	Engine.time_scale = 1.0
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
