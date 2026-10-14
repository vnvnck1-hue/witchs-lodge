extends Node
## ContractDirector: 카드로 소환한 용병·하수인의 임무·대기·사망과 활동 상한(기획서 v0.3 §5·6·8).
## 소유 카드(미사용 계약)는 CardInventory가, 월드에 나온 인물은 이 모듈이 관리한다.
## 용병은 쓰러질 때까지 남는다: 임무를 마치면 산장 마당에서 쉬고, 낮에는 남은 나무를 찾아 벌목한다.
## 쓰러진 용병은 산장 뒤편 묘지에 묻힌다. 하수인은 쓰러지거나 낮이 되면 목재 1개가 된다.

const Cfg := preload("res://scripts/config.gd")
const AllyScript := preload("res://scripts/actors/ally.gd")

var game
var allies: Array = []
var stats := {"died": 0, "minions": 0, "withered": 0}
var _assign_t := 0.0

## 산장 마당의 대기 자리(문 오른쪽, 손님 동선과 목장 문을 피한 곳)
const YARD := [Vector3(2.0, 0, 4.5), Vector3(2.9, 0, 5.0), Vector3(1.4, 0, 5.3), Vector3(2.4, 0, 5.9),
	Vector3(3.5, 0, 5.8), Vector3(1.0, 0, 6.2), Vector3(3.1, 0, 6.7), Vector3(1.9, 0, 6.9)]


func _ready() -> void:
	name = "ContractDirector"


## 임무 수행·중단 대기·귀가 중인 용병과 하수인. 미사용 카드는 포함하지 않는다.
func active_count() -> int:
	return allies.filter(func(a): return is_instance_valid(a) and not a.dead).size()


func mercs_alive() -> int:
	return allies.filter(func(a): return is_instance_valid(a) and not a.dead and a.kind == "merc").size()


## 비어 있는 마당 자리(다른 용병이 쓰지 않는 곳).
func yard_spot(for_ally) -> Vector3:
	var used: Array = []
	for a in allies:
		if a != for_ally and is_instance_valid(a) and not a.dead and a.kind == "merc" and a.task == "idle":
			used.append(a.guard_point)
	for p in YARD:
		if not p in used:
			return p
	return YARD[0] + Vector3(randf_range(-0.6, 0.6), 0, randf_range(-0.6, 0.6))


func persons_active() -> Array:
	var out: Array = []
	for a in allies:
		if is_instance_valid(a) and not a.dead and a.person != "":
			out.append(a.person)
	return out


func spawn_chop(person: String, tree: Dictionary, work_pos: Vector3):
	var a := AllyScript.new()
	a.setup(game, "merc", person, "chop", work_pos)
	a.position = work_pos
	a.tree = tree
	a.work_pos = work_pos
	tree["reserved"] = a
	_register(a)
	game.toast("%s — 벌목을 시작합니다 (%d초)" % [person, int(Cfg.CHOP_TIME)], Color(1.0, 0.88, 0.6))
	return a


func spawn_guard(kind: String, person: String, pos: Vector3, priority = null):
	var a := AllyScript.new()
	a.setup(game, kind, person, "guard", pos)
	a.position = pos
	a.priority = priority
	_register(a)
	if kind == "minion":
		stats["minions"] += 1
	return a


func _register(a) -> void:
	game.actors.add_child(a)
	allies.append(a)


func finish_chop(a) -> void:
	if a.dead or a.task != "chop" or a.state != AllyScript.State.WORKING:
		return
	var tree: Dictionary = a.tree
	var amount := mini(Cfg.CHOP_YIELD, int(tree["remaining"]))
	tree["remaining"] -= amount
	tree["reserved"] = null
	game.cards.add("timber", amount)
	game.toast("%s — 목재 +%d, 산장으로 돌아와 다음 일을 기다립니다" % [a.person, amount], Color(0.95, 0.8, 0.55))
	if tree["remaining"] <= 0:
		game.world.deplete_tree(tree)
	a.become_idle(yard_spot(a))
	_assign_t = 1.5


## 낮 동안 쉬는 용병에게 남은 자원 나무를 맡긴다(가까운 나무부터, 한 나무에 한 명).
func _process(delta: float) -> void:
	if game == null or game.session == null or game.session.state != 0:
		return
	_assign_t -= delta
	if _assign_t > 0.0:
		return
	_assign_t = 1.0
	for a in allies:
		if not is_instance_valid(a) or a.dead or a.kind != "merc" or a.state != AllyScript.State.IDLE:
			continue
		var best = null
		var best_d := 1e9
		for t in game.world.harvest_trees:
			if t["remaining"] <= 0 or t["reserved"] != null:
				continue
			var d: float = a.global_position.distance_to(t["pos"])
			if d < best_d:
				best_d = d
				best = t
		if best == null:
			return
		var wp: Vector3 = game.resolver.work_position(best)
		best["reserved"] = a
		a.set_chop(best, wp)
		game.toast("%s — 다음 나무를 벌목하러 갑니다" % a.person, Color(1.0, 0.88, 0.6))
		return


func on_ally_died(a) -> void:
	stats["died"] += 1
	if a.task == "chop" and a.tree != null and a.tree.get("reserved") == a:
		a.tree["reserved"] = null
	var lost := " (미완료 벌목 손실)" if a.task == "chop" else ""
	game.world.graveyard.bury(a.person, game.session.day())
	game.toast("용병 %s이(가) 쓰러졌습니다 — 산장 뒤편에 묻혔습니다%s" % [a.person, lost], Color(1.0, 0.6, 0.6))


## 하수인이 쓰러지거나 낮이 됨: 시들어 목재 1개로 손패에 들어온다.
func wither_minion(a, why: String) -> void:
	if a.dead:
		return
	stats["withered"] += 1
	if why == "쓰러져":
		stats["died"] += 1
	game.cards.add("timber", Cfg.MINION_TIMBER)
	game.toast("숲의 괴물이 %s 시들었습니다 — 목재 +%d" % [why, Cfg.MINION_TIMBER], Color(0.85, 0.95, 0.6))
	a.wither_out()


func on_ally_removed(a) -> void:
	allies.erase(a)


# ───────────────────────── 낮밤 전환(GameSession이 호출) ─────────────────────────

func on_wave_start() -> void:
	for a in allies.duplicate():
		if is_instance_valid(a):
			a.interrupt()


## 밤의 적이 모두 정리됨(낮이 밝음): 전투 용병은 마당으로 돌아와 남고, 하수인은 시들어 목재가 된다.
func on_combat_end() -> void:
	for a in allies.duplicate():
		if is_instance_valid(a):
			a.end_combat(yard_spot(a))


func on_prep_start() -> void:
	for a in allies.duplicate():
		if is_instance_valid(a):
			a.resume()
