extends SceneTree
## 식생 구분선 시안 헤드리스 검증. 시안 A·B·C 를 차례로 조립(F7 순환과 같은 경로)해 다음을 확인한다.
##  - 배치 규칙: 길 여유(충돌 부품 ≥ 2.6+반경, 장식 ≥ 1.9), 예약 영역·후면 띠·산장·목장·문 앞 통로·스폰·랜드마크 밖,
##    기존 숲 부품·자원 나무와 겹치지 않음, 띠마다 최소 밀도(중심선 1m 당 부품 수)·충돌 부품 수.
##  - 동선: 좌우 스폰 → 현관·목장 문, 현관 → 모닥불·목장 문·제단 공터·감시탑 공터·랜드마크 4곳·증축 앞 눈밭,
##    손님 경로 → 현관, 대기 자리 16곳이 내비메시 위, 산장 뒤 도달 불가 유지.
##  - 나무가 벌목 대상(harvest_trees)에 들어가지 않는다. 시안 전환 뒤 부품이 남지 않는다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_yard_hedges.gd
const Layout := preload("res://scripts/world/layout.gd")
const Cfg := preload("res://scripts/config.gd")
const Hedges := preload("res://scripts/world/yard_hedges.gd")
const Forest := preload("res://scripts/world/forest_composition.gd")
const MIN_DENSITY := {"a": 1.6, "b": 1.4, "c": 1.2}   # 띠 중심선 1m 당 부품 수(장식 포함)
const MIN_COLLIDERS := {"a": 20, "b": 30, "c": 22}      # 시안 전체 충돌 부품(나무·바위) 수
var passed := 0
var total := 0
var game
var nav_map: RID


func _initialize() -> void:
	create_timer(240.0, true, false, true).timeout.connect(func(): push_error("yard hedge check timed out"); quit(2))
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


func reachable(from: Vector3, to: Vector3, tolerance := 0.8) -> bool:
	var path := NavigationServer3D.map_get_path(nav_map, from, to, true)
	return path.size() > 1 and flat(path[-1]).distance_to(flat(to)) <= tolerance


func band_length(band: Dictionary) -> float:
	var total_len := 0.0
	for i in band.points.size() - 1: total_len += band.points[i].distance_to(band.points[i + 1])
	return total_len


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
	check(world.yard_hedges != null and world.yard_hedges.variant_id == "c", "기본 시안은 c(바위 능선, 2026-10-18 선택)")
	check(Hedges.parts_for("none").is_empty(), "none 시안 부품 0")
	var harvest_before: int = world.harvest_trees.size()
	var blockers: Array = []
	for group in Forest.layout().groups:
		for part in group.parts:
			if part.kind == "tree" or part.kind == "rock":
				blockers.append(Vector3(part.position[0], part.position[1], part.collider_radius))

	for v in ["a", "b", "c"]:
		print("── 시안 ", v, " ──")
		var label: String = world.yard_hedges.rebuild(v)
		await ticks(30)
		NavigationServer3D.map_force_update(nav_map)
		var parts: Array = world.yard_hedges.parts
		check(label != "" and world.yard_hedges.variant_id == v, "시안 %s 조립: %s" % [v, label])
		# 배치 규칙
		var lane_bad := 0
		var reserve_bad := 0
		var overlap_bad := 0
		var zone_bad := 0
		var colliders := 0
		var pasture: Rect2 = Cfg.PASTURE_LEVELS[-1].rect
		var gate_corridor := Rect2(pasture.end.x, pasture.position.y - 1.0, 2.15, pasture.size.y + 2.0)
		for p in parts:
			var at: Vector2 = p.at
			var collides: bool = p.kind != "decor"
			if collides: colliders += 1
			var lane: float = (Hedges.LANE_COLLIDER + p.radius) if collides else Hedges.LANE_DECOR
			if Layout.dist_to_trails(at) < lane - 0.001: lane_bad += 1
			if Layout.in_yard_reserve(at, 0.3) or Layout.in_rear_enclosure(at): reserve_bad += 1
			if Layout.LODGE_RECT.grow(2.0).has_point(at) or pasture.grow(0.9).has_point(at) or gate_corridor.grow(p.radius if collides else 0.0).has_point(at): zone_bad += 1
			for s in [Layout.SPAWN_A, Layout.SPAWN_B]:
				if at.distance_to(flat(s)) < 2.0: zone_bad += 1
			if collides:
				for b: Vector3 in blockers:
					if at.distance_to(Vector2(b.x, b.y)) < (0.4 if p.kind == "rock" else p.radius + (0.4 if b.z < 0.45 else 0.0)): overlap_bad += 1
				for t in Layout.TREES:
					if at.distance_to(Vector2(t[0], t[1])) < 1.8: overlap_bad += 1
		check(lane_bad == 0, "길 여유 위반 0 (위반 %d)" % lane_bad)
		check(reserve_bad == 0, "예약 영역·후면 띠 침범 0 (침범 %d)" % reserve_bad)
		check(zone_bad == 0, "산장·목장·문 앞 통로·스폰 침범 0 (침범 %d)" % zone_bad)
		check(overlap_bad == 0, "기존 숲·자원 나무와 겹침 0 (겹침 %d)" % overlap_bad)
		check(colliders >= MIN_COLLIDERS[v], "충돌 부품(나무·바위) %d ≥ %d" % [colliders, MIN_COLLIDERS[v]])
		var thin: Array = []
		for band in Hedges.BANDS:
			var n := 0
			for p in parts:
				if p.band == band.id: n += 1
			var density := n / maxf(band_length(band), 0.1)
			# 공터 테두리 고리는 길에 닿는 변이 비므로 부품 수만 본다
			var minimum: float = 0.45 if band.id.begins_with("ring_") else MIN_DENSITY[v]
			if density < minimum: thin.append("%s %.2f/m" % [band.id, density])
		check(thin.is_empty(), "띠 밀도 ≥ %.1f/m (부족: %s)" % [MIN_DENSITY[v], ", ".join(thin)])
		check(world.harvest_trees.size() == harvest_before, "구분선 나무는 벌목 대상이 아님(자원 나무 %d 그대로)" % world.harvest_trees.size())
		var bodies := 0
		for body in world.nav_region.get_children():
			if body.has_meta("hedge_band"): bodies += 1
		check(bodies == colliders, "충돌 몸체 %d = 충돌 부품 %d" % [bodies, colliders])
		# 동선
		var gate: Vector3 = world.pasture.gate_center()
		for s in [Layout.SPAWN_A, Layout.SPAWN_B]:
			check(reachable(s, door, 1.5), "스폰 %s → 현관" % s)
			check(reachable(s, gate + Vector3(0.6, 0, 0), 1.0), "스폰 %s → 목장 문" % s)
		check(reachable(door, fire + Vector3(0, 0, Layout.REST_RING_INNER), 0.6), "현관 → 모닥불")
		check(reachable(door, gate + Vector3(0.6, 0, 0), 0.6), "현관 → 목장 문")
		check(reachable(door, Vector3(Layout.PATH_ALTAR[-1].x, 0, Layout.PATH_ALTAR[-1].y), 0.6), "현관 → 제단 공터")
		for c in [Layout.TOWER_SITE_LEFT, Layout.TOWER_SITE_RIGHT]:
			check(reachable(door, Vector3(c.x, 0, c.y), 0.6), "현관 → 감시탑 공터 %s" % c)
		check(reachable(door, Vector3(-7.5, 0, 4.5), 0.6), "현관 → 증축 앞 눈밭(예약 포켓 입구 열림)")
		for landmark in Layout.LANDMARKS:
			check(reachable(door, Vector3(landmark.pos.x, 0, landmark.pos.y), 0.8), "현관 → " + landmark.id)
		check(reachable(Vector3(Layout.TRAVELER_ROUTE[0]), door, 0.8), "손님 경로 → 현관")
		var rest_ok := true
		for r in Layout.rest_slots():
			if flat(NavigationServer3D.map_get_closest_point(nav_map, r)).distance_to(flat(r)) > 0.35: rest_ok = false
		check(rest_ok, "대기 자리 16곳 내비메시 위")
		check(not reachable(door, Vector3(0, 0, -3.6), 1.0) and not reachable(door, Vector3(-4, 0, -6), 1.0), "산장 뒤 도달 불가 유지")
		for ap in world.lodge.attack_points:
			if not reachable(Layout.SPAWN_A, ap, 0.9):
				check(false, "공격 지점 %s 도달 가능" % ap)
				break
		check(true, "공격 지점 %d개 검사" % world.lodge.attack_points.size())

	# 시안 해제: none 으로 돌아가면 부품·몸체가 남지 않는다
	world.yard_hedges.rebuild("none")
	await ticks(10)
	var leftover := 0
	for body in world.nav_region.get_children():
		if body.has_meta("hedge_band") and not body.is_queued_for_deletion(): leftover += 1
	check(leftover == 0 and world.yard_hedges.get_child_count() == 0 or world.yard_hedges.get_children().all(func(c): return c.is_queued_for_deletion()),
		"none 복귀 뒤 남은 구분선 부품 0")
	check(world.cycle_yard_hedges() != "", "F7 순환 호출 동작")
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
