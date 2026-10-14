extends Node
## CardUseResolver: 드래그 중인 카드의 대상·조건 판정과 사용 확정(기획서 v0.3 §6·9).
## evaluate()는 미리보기용, commit()은 놓는 순간 같은 판정을 다시 수행한 뒤 소비와 임무 등록을 함께 확정한다.
## 무효 대상·조건 미충족은 소비하지 않는다. 화면 좌표를 그대로 소환 위치로 쓰지 않는다.

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")

const PICK_ENEMY_PX := 46.0
const PICK_TREE_PX := 62.0

var game


func _ready() -> void:
	name = "CardUseResolver"


# ───────────────────────── 대상 찾기 ─────────────────────────

func _ground_at(sp: Vector2):
	var cam: Camera3D = game.world.camera
	var from := cam.project_ray_origin(sp)
	var dir := cam.project_ray_normal(sp)
	if absf(dir.y) < 0.001:
		return null
	return from + dir * (-from.y / dir.y)


func _lodge_hit(sp: Vector2) -> bool:
	var cam: Camera3D = game.world.camera
	var from := cam.project_ray_origin(sp)
	var q := PhysicsRayQueryParameters3D.create(from, from + cam.project_ray_normal(sp) * 400.0, Cfg.L_OBSTACLE)
	var hit: Dictionary = game.get_world_3d().direct_space_state.intersect_ray(q)
	return not hit.is_empty() and hit["collider"] == game.world.lodge


func enemy_at(sp: Vector2):
	var cam: Camera3D = game.world.camera
	var best = null
	var best_d := PICK_ENEMY_PX
	for e in game.get_tree().get_nodes_in_group("enemies"):
		if e.dead:
			continue
		if game.world.fog_of_war != null and not game.world.fog_of_war.is_visible_at(e.global_position): continue
		var d := cam.unproject_position(e.global_position + Vector3(0, 0.7, 0)).distance_to(sp)
		if d < best_d:
			best_d = d
			best = e
	return best


func tree_at(sp: Vector2):
	var cam: Camera3D = game.world.camera
	var best = null
	var best_d := PICK_TREE_PX
	for t in game.world.harvest_trees:
		var d := cam.unproject_position(t["pos"] + Vector3(0, 1.6, 0)).distance_to(sp)
		if d < best_d:
			best_d = d
			best = t
	return best


## 지면 위치를 이동 가능한 가까운 아군 위치로 보정. 불가능하면 사유 문자열.
func valid_ground(p: Vector3):
	var nav := NavigationServer3D.map_get_closest_point(game.get_world_3d().navigation_map, p)
	nav.y = 0.0
	if Vector2(nav.x - p.x, nav.z - p.z).length() > 1.2:
		return "이동할 수 없는 곳입니다"
	var c := Vector2(Layout.CAMERA_TARGET.x, Layout.CAMERA_TARGET.z)
	if Vector2(nav.x, nav.z).distance_to(c) > Layout.BOUNDARY_RADIUS - 0.8:
		return "아직 발견하지 않은 숲입니다"
	if game.world.lodge.distance_to(nav) < 0.4:
		return "건물 안에는 소환할 수 없습니다"
	if game.world.pasture.inside(nav, 0.2):
		return "목장 안에는 소환할 수 없습니다"
	return nav


func work_position(tree: Dictionary) -> Vector3:
	var to: Vector3 = Layout.CAMERA_TARGET - tree["pos"]
	to.y = 0.0
	var p: Vector3 = tree["pos"] + to.normalized() * 1.0
	var nav := NavigationServer3D.map_get_closest_point(game.get_world_3d().navigation_map, p)
	nav.y = 0.0
	return nav


# ───────────────────────── 판정 ─────────────────────────

func _fail(reason: String, where = null) -> Dictionary:
	return {"ok": false, "reason": reason, "pos": where}


## 반환: {ok, reason, action, pos, tree, enemy, title, lines}
func evaluate(uid: int, sp: Vector2) -> Dictionary:
	var entry: Dictionary = game.cards.get_entry(uid)
	if entry.is_empty():
		return _fail("카드가 없습니다")
	var s = game.session
	if s.is_over():
		return _fail("게임이 끝났습니다")
	if game.get_tree().paused:
		return _fail("일시 정지 중에는 사용할 수 없습니다")
	match entry["id"]:
		"axe_mercenary", "forest_monster":
			return _eval_summon(entry, sp)
		"wool":
			return _eval_wool(entry, sp)
		"timber":
			return _eval_timber(entry, sp)
	return _fail("사용할 수 없는 카드입니다")


func _eval_summon(entry: Dictionary, sp: Vector2) -> Dictionary:
	var s = game.session
	var merc: bool = entry["id"] == "axe_mercenary"
	var who: String = entry["person"] if merc else "큰 숲의 괴물 하수인"
	var spend := "계약 1장 소비" if merc else "카드 1장 소비"
	var tree = tree_at(sp) if merc else null
	var enemy = enemy_at(sp)
	var cap_full: bool = game.contracts.active_count() >= Cfg.ACTIVE_LIMIT
	if s.state == SessionScript.State.CLEARING:
		return _fail("밤 전투를 정리하는 중입니다")
	if tree != null and enemy == null:
		var wp := work_position(tree)
		if s.state != SessionScript.State.PREP:
			return _fail("벌목은 평상시 낮에만 시작합니다", wp)
		if tree["remaining"] <= 0:
			return _fail("목재가 남지 않은 나무입니다", wp)
		if tree["reserved"] != null:
			return _fail("다른 용병이 작업 중인 나무입니다", wp)
		if cap_full:
			return _fail("활동 상한 %d명에 도달했습니다" % Cfg.ACTIVE_LIMIT, wp)
		return {"ok": true, "action": "chop", "pos": wp, "tree": tree, "title": "벌목 — " + who,
			"lines": ["%d초 작업 · 목재 +%d (나무에 %d 남음)" % [int(Cfg.CHOP_TIME), mini(Cfg.CHOP_YIELD, tree["remaining"]), tree["remaining"]],
				spend + " · 일을 마치면 산장에 남아 다음 나무를 벌목", "밤이 되면 산장 앞을 지키고, 다음 낮에 재개"]}
	if enemy != null:
		var lodge_dir: Vector3 = Layout.DOOR_FRONT - enemy.global_position
		lodge_dir.y = 0.0
		var spot = valid_ground(enemy.global_position + lodge_dir.normalized() * 1.2)
		if spot is String:
			spot = valid_ground(enemy.global_position)
		if spot is String:
			return _fail(spot)
		if cap_full:
			return _fail("활동 상한 %d명에 도달했습니다" % Cfg.ACTIVE_LIMIT, spot)
		return {"ok": true, "action": "guard", "pos": spot, "enemy": enemy, "title": "전투 — " + who,
			"lines": ["이 적을 먼저 공격한 뒤 주변 적을 상대", spend, "이번 밤이 끝나면 " + ("산장 마당에 남음 (쓰러질 때까지)" if merc else "시들어 목재 1개가 됨")]}
	var g = _ground_at(sp)
	if g == null:
		return _fail("대상을 찾지 못했습니다")
	if _lodge_hit(sp):
		return _fail("산장에는 사용할 수 없습니다")
	var spot2 = valid_ground(g)
	if spot2 is String:
		return _fail(spot2, g)
	if cap_full:
		return _fail("활동 상한 %d명에 도달했습니다" % Cfg.ACTIVE_LIMIT, spot2)
	var until := "오늘 밤 전투가 끝날 때까지 이 자리를 방어" if s.state == SessionScript.State.PREP else "이번 밤 적이 정리될 때까지 이 자리를 방어"
	return {"ok": true, "action": "guard", "pos": spot2, "title": ("방어 배치 — " if s.state == SessionScript.State.PREP else "전투 — ") + who,
		"lines": [until, spend, "끝나면 " + ("산장 마당에 남음 (쓰러질 때까지)" if merc else "시들어 목재 1개가 됨 (쓰러져도 동일)")]}


func _eval_wool(entry: Dictionary, sp: Vector2) -> Dictionary:
	if not _lodge_hit(sp):
		return _fail("산장에 놓으면 판매합니다")
	var lodge_pos: Vector3 = game.world.lodge.global_position
	if game.session.state != SessionScript.State.PREP:
		return _fail("판매는 준비 시간에만 가능합니다", lodge_pos)
	return {"ok": true, "action": "sell", "pos": lodge_pos, "title": "산장 교역 — 양털 판매",
		"lines": ["보유 %d개 · 1개 %dG" % [entry["count"], Cfg.WOOL_PRICE], "놓은 뒤 판매 수량을 고릅니다"]}


func _eval_timber(entry: Dictionary, sp: Vector2) -> Dictionary:
	if not _lodge_hit(sp):
		return _fail("산장에 놓으면 수리합니다")
	var lodge = game.world.lodge
	if game.session.state != SessionScript.State.PREP:
		return _fail("수리는 준비 시간에만 가능합니다", lodge.global_position)
	if lodge.hp >= lodge.max_hp:
		return _fail("산장 체력이 최대입니다", lodge.global_position)
	if int(entry["count"]) < Cfg.TIMBER_REPAIR_COST:
		return _fail("목재가 %d개 필요합니다 (보유 %d)" % [Cfg.TIMBER_REPAIR_COST, entry["count"]], lodge.global_position)
	var gain := minf(Cfg.TIMBER_REPAIR_AMOUNT, lodge.max_hp - lodge.hp)
	return {"ok": true, "action": "repair", "pos": lodge.global_position, "title": "재료 수리 — 산장",
		"lines": ["목재 %d개 사용 · 산장 체력 +%d" % [Cfg.TIMBER_REPAIR_COST, int(gain)], "%d → %d" % [int(ceil(lodge.hp)), int(ceil(lodge.hp + gain))]]}


# ───────────────────────── 확정 ─────────────────────────

## 놓는 순간 호출. 반환: 판정 결과(ok=false면 카드는 손패로 돌아간다).
func commit(uid: int, sp: Vector2) -> Dictionary:
	var plan := evaluate(uid, sp)
	if not plan["ok"]:
		return plan
	var entry: Dictionary = game.cards.get_entry(uid)
	match plan["action"]:
		"sell":
			return plan  # 판매 수량 선택 창에서 확정한다(여기서는 소비하지 않음).
		"repair":
			if not game.cards.consume(uid, Cfg.TIMBER_REPAIR_COST):
				return _fail("목재가 부족합니다")
			var r: float = game.world.lodge.repair(Cfg.TIMBER_REPAIR_AMOUNT)
			game.toast("목재 %d개로 산장 수리 +%d" % [Cfg.TIMBER_REPAIR_COST, int(r)], Color(0.95, 0.85, 0.6))
		"chop":
			var person: String = entry["person"]
			if not game.cards.consume(uid):
				return _fail("카드가 없습니다")
			game.contracts.spawn_chop(person, plan["tree"], plan["pos"])
		"guard":
			var merc: bool = entry["id"] == "axe_mercenary"
			var person2: String = entry["person"]
			if not game.cards.consume(uid):
				return _fail("카드가 없습니다")
			game.contracts.spawn_guard("merc" if merc else "minion", person2, plan["pos"], plan.get("enemy"))
			if merc:
				game.toast("%s — 계약을 맺고 전투에 나섭니다" % person2, Color(1.0, 0.85, 0.6))
			else:
				game.toast("큰 숲의 괴물 하수인을 소환했습니다", Color(0.7, 1.0, 0.7))
	return plan
