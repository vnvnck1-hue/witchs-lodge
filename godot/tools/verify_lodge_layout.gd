extends SceneTree
## A안 산장 주변 재배치 헤드리스 검증(docs/handoff/lodge-map-layout-a-v01.md 8절 체크리스트의 로직 항목).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_lodge_layout.gd
## 출력: PASS/FAIL 줄과 마지막 RESULT n/m. 실패가 있으면 종료 코드 1.
const Layout := preload("res://scripts/world/layout.gd")
const Cfg := preload("res://scripts/config.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const Forest := preload("res://scripts/world/forest_composition.gd")
var passed := 0
var total := 0
var game
var nav_map: RID


func _initialize() -> void:
	create_timer(180.0, true, false, true).timeout.connect(func(): push_error("lodge layout check timed out"); quit(2))
	call_deferred("_run")


func check(ok: bool, message: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + message)


func ticks(count: int) -> void:
	for i in count: await physics_frame
	await process_frame


func flat(p: Vector3) -> Vector2:
	return Vector2(p.x, p.z)


## 내비 경로의 끝점이 목표 가까이 닿는가(도달 가능).
func reachable(from: Vector3, to: Vector3, tolerance := 0.8) -> bool:
	var path := NavigationServer3D.map_get_path(nav_map, from, to, true)
	return path.size() > 1 and flat(path[-1]).distance_to(flat(to)) <= tolerance


## 두 지점 사이 내비 경로가 산장·목장 바로 뒤(후면 띠 안쪽 구간)를 지나는가.
func passes_behind(from: Vector3, to: Vector3) -> bool:
	var path := NavigationServer3D.map_get_path(nav_map, from, to, true)
	for p in path:
		if p.z < -3.0 and p.x > -2.6 and p.x < 8.6: return true
	return false


func path_end_distance(from: Vector3, to: Vector3) -> float:
	var path := NavigationServer3D.map_get_path(nav_map, from, to, true)
	if path.size() == 0: return 1e9
	return flat(path[-1]).distance_to(flat(to))


func walk_to(dest: Vector3, label: String, frames := 1400) -> void:
	game.player.set_destination(dest)
	var arrived := false
	for frame in frames:
		await physics_frame
		if flat(game.player.global_position).distance_to(flat(dest)) < 0.7:
			arrived = true
			break
	game.player.moving = false
	check(arrived, "마녀 실제 보행: " + label + " " + str(game.player.global_position))


func _run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await ticks(6)
	game.session.set_process(false)
	Engine.time_scale = 4.0
	nav_map = game.get_world_3d().navigation_map
	var world = game.world
	var door: Vector3 = Layout.DOOR_FRONT
	var fire: Vector3 = Layout.CAMPFIRE
	# 내비메시가 실제로 동기화된 뒤에만 경로 검사를 시작한다(아니면 '경로 없음' 검사가 헛되이 통과한다).
	var nav_ready := false
	for i in 400:
		await physics_frame
		NavigationServer3D.map_force_update(nav_map)
		if reachable(door, fire + Vector3(0, 0, Layout.REST_RING_INNER), 0.6):
			nav_ready = true
			break
	check(nav_ready, "내비메시 준비(현관 → 모닥불 경로 존재)")

	# ── 1. 배치 관계(산장·왼쪽 증축 여유·오른쪽 목장·중앙 모닥불) ──
	check(Layout.EXTENSION_RESERVE.end.x <= Layout.LODGE_RECT.position.x + 0.25 and Layout.EXTENSION_RESERVE.grow(0.01).encloses(Layout.EXTENSION_RECT),
		"증축 예약 눈밭이 본채 왼쪽 벽에 이어지고 현재 증축 사각형을 포함한다")
	var pasture_rect: Rect2 = Cfg.PASTURE_LEVELS[-1]["rect"]
	check(pasture_rect.position.x >= Layout.LODGE_RECT.end.x - 0.01, "목장은 산장 오른쪽(+X)")
	check(fire.z > door.z + 6.0 and fire.z < door.z + 9.0, "모닥불은 현관 앞 생활 중심(현관에서 %.1fm)" % flat(fire).distance_to(flat(door)))
	check(world.yard != null and world.yard.campfire != null, "LodgeYard 모닥불 노드")
	check(world.rear_blocker != null and world.rear_blocker.rock_count >= 20, "RearBlocker 바위 %d개" % (world.rear_blocker.rock_count if world.rear_blocker != null else 0))

	# ── 2. 공터: 감시탑 2곳, 제단 1곳. 길·서로·목장 문과 겹치지 않는다 ──
	var sites: Array = world.yard.site_nodes
	var towers: Array = sites.filter(func(s): return s.get_meta("reserved_site") == "tower")
	var altars: Array = sites.filter(func(s): return s.get_meta("reserved_site") == "altar")
	check(towers.size() == 2 and altars.size() == 1, "건설 예약 공터: 감시탑 %d, 제단 %d" % [towers.size(), altars.size()])
	var half := Layout.TOWER_SITE_SIZE * 0.5
	for c in [Layout.TOWER_SITE_LEFT, Layout.TOWER_SITE_RIGHT]:
		check(Layout.dist_to_trails(c) >= half + 1.0, "감시탑 공터 %s 가 길과 겹치지 않음(길 중심선까지 %.1fm)" % [c, Layout.dist_to_trails(c)])
		check(c.distance_to(flat(fire)) > Layout.REST_RING_OUTER + half + 0.5, "감시탑 공터 %s 와 모닥불 쉼터 분리" % c)
	var gate: Vector3 = world.pasture.gate_center()
	check(Layout.tower_site_rect(Layout.TOWER_SITE_RIGHT).grow(1.2).has_point(flat(gate)) == false, "오른쪽 감시탑 공터가 목장 문 앞을 비움")
	check(Layout.TOWER_SITE_LEFT.x < fire.x and Layout.TOWER_SITE_RIGHT.x > fire.x, "감시탑 공터가 모닥불 좌우에 하나씩")
	var altar_trail := 1e9
	for path in Layout.EXPLORATION_PATHS:
		if path != Layout.PATH_ALTAR: altar_trail = minf(altar_trail, Layout.dist_to_path(Layout.ALTAR_SITE, path))
	check(altar_trail >= Layout.ALTAR_SITE_RADIUS + 0.8, "제단 공터가 주동선 중심선에서 떨어져 있음(%.1fm)" % altar_trail)
	check(Layout.dist_to_path(Layout.ALTAR_SITE, Layout.PATH_ALTAR) < Layout.ALTAR_SITE_RADIUS + 0.3, "제단 공터에 가지 길이 닿음")
	check(Layout.dist_to_trails(flat(fire)) > Layout.REST_RING_INNER, "길이 모닥불 중앙을 지나지 않음")

	# ── 3. 후면 차단: 마녀·일꾼·적 경로가 산장 뒤로 생기지 않는다 ──
	# 산장·목장 바로 뒤(z -3.6)와 증축 예약 뒤 띠 안(z -4.6), 바위 정원 안쪽. 증축 예약 눈밭은 띠 앞면(z≈-3.3)까지 열린 땅이다.
	var rear_probe := [Vector3(0, 0, -3.6), Vector3(4, 0, -3.6), Vector3(-4, 0, -4.6), Vector3(-7.5, 0, -4.6), Vector3(0, 0, -6), Vector3(-6, 0, -8)]
	for p in rear_probe:
		check(not reachable(door, p, 0.6), "산장 뒤 %s 에 닿는 경로 없음" % p)
	for p in load("res://scripts/world/graveyard.gd").plots():
		check(not reachable(door, p, 1.0), "묘지 %s 는 걸어 들어갈 수 없는 포켓" % p)
	check(not passes_behind(Vector3(-7, 0, -1.5), Vector3(10, 0, -1.5)), "왼쪽 눈밭↔목장 동쪽 경로가 산장 뒤를 지나지 않음(앞마당으로 돌아감)")
	# 경계 자원 나무를 모두 베어도 후면 우회가 열리지 않는다(자원 나무 충돌을 끄고 다시 굽는다)
	for t in world.harvest_trees:
		for cs in t["body"].get_children():
			if cs is CollisionShape3D: cs.disabled = true
	world.bake_nav()
	await ticks(20)
	NavigationServer3D.map_force_update(nav_map)
	check(not reachable(door, Vector3(0, 0, -3.6), 1.0) and not reachable(door, Vector3(-4, 0, -6), 1.0), "자원 나무를 모두 베어도 후면 우회가 열리지 않음")
	for t in world.harvest_trees:
		for cs in t["body"].get_children():
			if cs is CollisionShape3D: cs.disabled = false
	world.bake_nav()
	await ticks(20)
	NavigationServer3D.map_force_update(nav_map)
	# 모든 벌목 가능 나무(장식 숲 포함)는 마당 시설·증축 예약·후면 띠 밖에 있다. 세 자원 나무 래퍼는 접근도 가능해야 한다.
	var tree_in_reserve := 0
	for t in world.harvest_trees:
		var p: Vector2 = flat(t["pos"])
		if Layout.in_yard_reserve(p, 0.5) or Layout.in_rear_enclosure(p): tree_in_reserve += 1
	check(tree_in_reserve == 0, "예약 영역·후면 띠 안의 벌목 나무 %d그루" % tree_in_reserve)
	for wrapper in Layout.TREES:
		var at := Vector2(wrapper[0], wrapper[1])
		var found := false
		for t in world.harvest_trees:
			if flat(t["pos"]).distance_to(at) < 0.05:
				found = true
				check(world.tree_access(t) == "", "자원 나무 %s 벌목 접근 가능" % at)
		check(found, "자원 나무 래퍼 %s 존재" % at)
	# 숲 군집 부품이 마당 시설·증축 예약을 침범하지 않는다
	var intruders := 0
	for group in Forest.layout().groups:
		for part in group.parts:
			var p := Vector2(part.position[0], part.position[1])
			if Layout.in_yard_reserve(p, 0.3): intruders += 1
	check(intruders == 0, "마당 시설·증축 예약 영역 안의 숲 부품 %d개" % intruders)

	# ── 4. 좌우 웨이브 진입과 스폰 지점 ──
	for s in [Layout.SPAWN_A, Layout.SPAWN_B]:
		var on_nav := NavigationServer3D.map_get_closest_point(nav_map, s)
		check(flat(on_nav).distance_to(flat(s)) < 0.6, "스폰 %s 가 내비메시 위" % s)
		check(reachable(s, door, 1.5), "스폰 %s → 현관 앞 경로" % s)
		check(reachable(s, gate + Vector3(0.6, 0, 0), 1.0), "스폰 %s → 목장 문 경로" % s)
	check(Layout.SPAWN_A.x < Layout.LODGE_RECT.position.x and Layout.SPAWN_B.x > Layout.LODGE_RECT.end.x, "스폰이 산장 기준 왼쪽·오른쪽 숲")
	check(absf(flat(Layout.SPAWN_A).distance_to(flat(door)) - flat(Layout.SPAWN_B).distance_to(flat(door))) < 5.0, "좌우 스폰의 현관 거리 차이 5m 이내")
	var lodge = world.lodge
	for ap in lodge.attack_points:
		check(ap.z > Layout.REAR_BLOCKER[0].y and reachable(Layout.SPAWN_B, ap, 0.9), "공격 지점 %s 가 앞·옆면이며 도달 가능" % ap)
	check(lodge.attack_points.size() >= 6, "공격 지점 %d개" % lodge.attack_points.size())
	# 실제 적 한 마리가 오른쪽 숲에서 산장까지 걸어와 공격 상태가 된다. 마녀의 자동 공격에 죽지 않게 마녀를 멀리 두고 체력을 크게 준다.
	game.player.position = Vector3(Layout.ALTAR_SITE.x, 0, Layout.ALTAR_SITE.y + 3.0)
	game.player.moving = false
	var m := MonsterScript.new()
	m.setup(game, 100000.0, false)
	m.configure("forest")
	m.position = Layout.SPAWN_B
	game.actors.add_child(m)
	var arrived_lodge := false
	for frame in 2400:
		await physics_frame
		if not is_instance_valid(m) or m.dead: break
		if lodge.distance_to(m.global_position) <= m.reach + 0.3:
			arrived_lodge = true
			break
	var m_alive := is_instance_valid(m) and not m.dead
	check(arrived_lodge, "오른쪽 스폰 적이 산장 공격 위치에 도달 " + (str(m.global_position) if m_alive else "(적이 사라짐)"))
	check(m_alive and m.global_position.z > -3.3, "적이 산장 뒤로 돌아가지 않음")
	if is_instance_valid(m): m.queue_free()

	# ── 5. 생활 동선: 현관·목장 수확·모닥불 집결·제단 공터·감시탑 공터 ──
	var rest := Layout.rest_slots()
	check(rest.size() == 16, "모닥불 대기 자리 16")
	var rest_ok := true
	for r in rest:
		var d := flat(r).distance_to(flat(fire))
		if d < Layout.CAMPFIRE_RADIUS + 0.4 or flat(NavigationServer3D.map_get_closest_point(nav_map, r)).distance_to(flat(r)) > 0.35:
			rest_ok = false
	check(rest_ok, "대기 자리가 불에서 떨어진 내비메시 위")
	check(flat(game.contracts.yard_spot(null)).distance_to(flat(fire)) < Layout.REST_RING_OUTER + 0.1, "대기 용병 자리가 모닥불 둘레")
	var altar_edge := Vector3(Layout.PATH_ALTAR[-1].x, 0, Layout.PATH_ALTAR[-1].y)
	check(reachable(door, fire + Vector3(0, 0, Layout.REST_RING_INNER), 0.6), "현관 → 모닥불")
	check(reachable(door, gate + Vector3(0.6, 0, 0), 0.6), "현관 → 목장 문")
	check(reachable(door, altar_edge, 0.6), "현관 → 제단 공터")
	for c in [Layout.TOWER_SITE_LEFT, Layout.TOWER_SITE_RIGHT]:
		check(reachable(door, Vector3(c.x, 0, c.y), 0.6), "현관 → 감시탑 공터 %s" % c)
	for landmark in Layout.LANDMARKS:
		var p: Vector2 = landmark.pos
		check(reachable(door, Vector3(p.x, 0, p.y), 0.8), "현관 → " + landmark.id + " 탐험 연결")
	check(reachable(Vector3(Layout.TRAVELER_ROUTE[0]), door, 0.8), "손님 경로 시작 → 현관")
	# 실제 보행(현관 → 모닥불 → 제단 공터 → 목장 문 → 현관)
	game.player.position = door
	await walk_to(fire + Vector3(0, 0, Layout.REST_RING_INNER), "모닥불")
	await walk_to(altar_edge, "제단 공터")
	await walk_to(gate + Vector3(0.6, 0, 0), "목장 문")
	await walk_to(door, "현관")

	# ── 6. 증축·목장 최대 단계 뒤에도 도달 영역·공격 지점 유효 ──
	lodge.build_extension()
	while world.pasture.level < Cfg.PASTURE_LEVELS.size() - 1:
		world.pasture.upgrade()
	await ticks(30)
	NavigationServer3D.map_force_update(nav_map)
	gate = world.pasture.gate_center()
	check(reachable(door, Vector3(-7.5, 0, 4.5), 0.6), "증축 뒤 증축 앞 눈밭 도달")
	check(reachable(door, gate + Vector3(0.6, 0, 0), 0.6), "최대 목장 문 도달")
	check(not reachable(door, Vector3(0, 0, -3.6), 1.0) and not reachable(door, Vector3(4, 0, -3.6), 1.0), "증축 뒤에도 산장·목장 뒤에 닿는 경로 없음")
	check(not passes_behind(Vector3(-7, 0, -1.5), Vector3(10, 0, -1.5)), "증축 뒤에도 왼쪽↔오른쪽 경로가 산장 뒤를 지나지 않음")
	var ap_ok := true
	for ap in lodge.attack_points:
		if ap.z <= Layout.REAR_BLOCKER[0].y or not reachable(Layout.SPAWN_A, ap, 0.9): ap_ok = false
	check(ap_ok and lodge.attack_points.size() >= 8, "증축 뒤 공격 지점 %d개 모두 앞·옆면·도달 가능" % lodge.attack_points.size())

	# ── 7. 길·식생 ──
	var seg := 0
	for path in Layout.EXPLORATION_PATHS: seg += path.size() - 1
	check(seg <= 64, "바닥 셰이더 길 구간 %d ≤ 64" % seg)
	var keep_out: Callable = world.grass.keep_out
	check(keep_out.call(flat(fire)) and keep_out.call(Layout.TOWER_SITE_LEFT) and keep_out.call(Layout.ALTAR_SITE) and keep_out.call(Layout.EXTENSION_RESERVE.get_center()),
		"풀밭이 모닥불·공터·증축 예약을 비움")
	check(game.altar.position.distance_to(Vector3(8, 0, -26)) < 0.1, "기존 제단은 북쪽 랜드마크에 그대로")

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
