extends SceneTree
## 산장 뒤 구석 진동 버그 회귀 검증(2026-10-18). 원인: 장애물 윗면이 고립 내비 섬으로 구워져 map_get_closest_point 가
## 산장 뒤·막힌 포켓을 돌려줬고, 정찰 지점·벌목 작업 위치·채집 지점이 닿을 수 없는 곳에 잡혀 캐릭터가 벽에 부딪혀 진동했다.
## 검사: 고립 섬 0, 정찰 지점 시뮬레이션 전부 앞마당·도달 가능, 접근 가능 나무의 작업 위치 전부 현관에서 도달, 실제 용병이
## 정찰·벌목 중 멈춤 감시에 걸리지 않고 산장 뒤로 가지 않음, 마녀 클릭 이동 보정이 섬을 피함.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_rear_nav.gd
const Layout := preload("res://scripts/world/layout.gd")
const Cfg := preload("res://scripts/config.gd")
const NavUtil := preload("res://scripts/world/nav_util.gd")
var passed := 0
var total := 0
var game
var nav: RID


func _initialize() -> void:
	create_timer(240.0, true, false, true).timeout.connect(func(): push_error("rear nav check timed out"); quit(2))
	call_deferred("_run")


func check(ok: bool, message: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + message)


func _run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 30: await physics_frame
	game.session.set_process(false)
	nav = game.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(nav)
	for i in 10: await physics_frame
	var door: Vector3 = Layout.DOOR_FRONT
	# 1. 고립 섬: 장애물 윗면에 내비 폴리곤이 없다
	var islands := 0
	for x in range(-30, 31, 2):
		for z in range(-30, 31, 2):
			var c := NavigationServer3D.map_get_closest_point(nav, Vector3(x, 0, z))
			if c.y > NavUtil.GROUND_Y: islands += 1
	check(islands == 0, "장애물 윗면 고립 내비 섬 0 (발견 %d)" % islands)
	for probe in [Vector3(4, 0, -5), Vector3(0, 0, -6), Vector3(-6, 0, -7)]:
		var c := NavigationServer3D.map_get_closest_point(nav, probe)
		check(c.y <= NavUtil.GROUND_Y and not Layout.in_rear_enclosure(Vector2(c.x, c.z)), "산장 뒤 %s 의 가장 가까운 내비 점이 띠 밖 지면 %s" % [probe, c])
	# 2. 정찰 지점 시뮬레이션(ally._pick_patrol_point 규칙)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var bad := 0
	var picked := 0
	for i in 2000:
		var a := rng.randf_range(0.0, TAU)
		var r := rng.randf_range(Cfg.PATROL_RADIUS[0], Cfg.PATROL_RADIUS[1])
		var p := Vector3(cos(a) * r, 0, sin(a) * r)
		if p.z < -0.5 or Layout.in_rear_enclosure(Vector2(p.x, p.z)): continue
		var q = NavUtil.walkable_from(nav, door, p, 1.5, 0.6)
		if q == null: continue
		picked += 1
		if q.z < -0.5 or Layout.in_rear_enclosure(Vector2(q.x, q.z)) or not NavUtil.reachable(nav, door, q, 0.6): bad += 1
	check(picked > 600 and bad == 0, "정찰 지점 %d개 모두 앞마당·도달 가능 (불량 %d)" % [picked, bad])
	# 3. 접근 가능한 모든 나무의 작업 위치가 현관에서 도달 가능하고 지면 위
	var accessible := 0
	var bad_work := 0
	for t in game.world.harvest_trees:
		if game.world.tree_access(t) != "": continue
		accessible += 1
		var wp: Vector3 = game.resolver.work_position(t)
		if wp.y > NavUtil.GROUND_Y or not NavUtil.reachable(nav, door, wp, 0.9) or Layout.in_rear_enclosure(Vector2(wp.x, wp.z)): bad_work += 1
	check(accessible >= 40 and bad_work == 0, "접근 가능 나무 %d그루의 작업 위치 전부 도달 가능 (불량 %d)" % [accessible, bad_work])
	var behind_access := 0
	for t in game.world.harvest_trees:
		var p: Vector3 = t["pos"]
		if p.z < -12.0 and p.z > -18.0 and absf(p.x) < 12.0 and game.world.tree_access(t) == "": behind_access += 1
	check(true, "후면 띠 바로 뒤(z −12~−18) 접근 가능 판정 나무 %d그루(참고)" % behind_access)
	# 4. 마녀 클릭 보정: 산장 뒤를 클릭해도 띠 밖 지면으로
	var dest := NavUtil.ground_or_near(nav, Vector3(3, 0, -6))
	check(not Layout.in_rear_enclosure(Vector2(dest.x, dest.z)) and NavUtil.reachable(nav, door, dest, 0.8), "산장 뒤 클릭 → 띠 밖 지면 %s" % dest)
	# 5. 실제 용병: 정찰 전사 2 + 나무꾼 1 을 60초(4배속) 돌려 멈춤·후면 진입이 없다
	Engine.time_scale = 4.0
	var allies: Array = []
	for spec in [["warrior", Vector3(2, 0, 6)], ["warrior", Vector3(-2, 0, 6)], ["lumberjack", Vector3(0, 0, 8)]]:
		var a = game.contracts.spawn_guard("merc", "검증-" + spec[0], spec[1], null, spec[0])
		if a != null: allies.append(a)
	check(allies.size() == 3, "검증 용병 %d명 생성" % allies.size())
	var stuck_events := 0
	var rear_frames := 0
	var moved_total := 0.0
	var last: Array = []
	for a in allies: last.append(a.global_position)
	for frame in 60 * 60:
		await physics_frame
		for i in allies.size():
			var a = allies[i]
			if not is_instance_valid(a): continue
			if Layout.in_rear_enclosure(Vector2(a.global_position.x, a.global_position.z)) or a.global_position.z < -3.0: rear_frames += 1
			if a._stuck_t == 0.0 and a.velocity.length() > 0.05 and frame > 0:
				pass
			if frame % 150 == 149:
				var d: float = Vector2(a.global_position.x - last[i].x, a.global_position.z - last[i].z).length()
				moved_total += d
				# 2.5초 동안 움직이려 했는데 0.3m 도 못 가면 멈춤(감시가 풀어 줘도 사건으로 센다)
				if a.state in [a.State.PATROL, a.State.GO_WORK, a.State.IDLE] and a.velocity.length() > 0.05 and d < 0.3: stuck_events += 1
				last[i] = a.global_position
	Engine.time_scale = 1.0
	check(rear_frames == 0, "용병이 산장 뒤·후면 띠 안에 들어간 프레임 0 (실제 %d)" % rear_frames)
	check(stuck_events == 0, "용병 멈춤 사건 0 (실제 %d), 총 이동 %.1fm" % [stuck_events, moved_total])
	check(moved_total > 20.0, "용병들이 실제로 돌아다님(총 %.1fm)" % moved_total)
	for a in allies:
		if is_instance_valid(a) and a.state == a.State.GO_WORK:
			check(NavUtil.reachable(nav, a.global_position, a.work_pos, 0.9), "나무꾼 작업 위치 %s 도달 가능" % a.work_pos)
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
