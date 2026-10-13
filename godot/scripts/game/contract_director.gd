extends Node
## ContractDirector: 카드로 소환한 용병·하수인의 임무·대기·귀가·사망과 활동 상한(기획서 v0.3 §5·6·8).
## 소유 카드(미사용 계약)는 CardInventory가, 월드에 나온 인물은 이 모듈이 관리한다.

const Cfg := preload("res://scripts/config.gd")
const AllyScript := preload("res://scripts/actors/ally.gd")

var game
var allies: Array = []
var stats := {"returned": 0, "died": 0, "minions": 0}


func _ready() -> void:
	name = "ContractDirector"


## 임무 수행·중단 대기·귀가 중인 용병과 하수인. 미사용 카드는 포함하지 않는다.
func active_count() -> int:
	return allies.filter(func(a): return is_instance_valid(a) and not a.dead).size()


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
	if a.dead or a.task != "chop" or a.state == AllyScript.State.RETURNING:
		return
	var tree: Dictionary = a.tree
	var amount := mini(Cfg.CHOP_YIELD, int(tree["remaining"]))
	tree["remaining"] -= amount
	tree["reserved"] = null
	game.cards.add("timber", amount)
	game.toast("%s — 목재 +%d, 일을 마치고 귀가합니다" % [a.person, amount], Color(0.95, 0.8, 0.55))
	if tree["remaining"] <= 0:
		game.world.deplete_tree(tree)
	a.go_home()


func on_ally_died(a) -> void:
	stats["died"] += 1
	if a.task == "chop" and a.tree != null and a.tree.get("reserved") == a:
		a.tree["reserved"] = null
	if a.kind == "merc":
		var lost := " (미완료 벌목 손실)" if a.task == "chop" else ""
		game.toast("용병 %s이(가) 쓰러졌습니다 — 계약 손실%s" % [a.person, lost], Color(1.0, 0.6, 0.6))
	else:
		game.toast("하수인이 쓰러졌습니다", Color(1.0, 0.7, 0.7))


func on_ally_removed(a) -> void:
	if a.state == AllyScript.State.RETURNING and a.hp > 0.0:
		stats["returned"] += 1
	allies.erase(a)


# ───────────────────────── 낮밤 전환(GameSession이 호출) ─────────────────────────

func on_wave_start() -> void:
	for a in allies.duplicate():
		if is_instance_valid(a):
			a.interrupt()


## 밤의 적이 모두 정리됨: 전투 계약 종료 → 용병 귀가, 하수인 퇴장.
func on_combat_end() -> void:
	for a in allies.duplicate():
		if is_instance_valid(a):
			a.end_combat()


func on_prep_start() -> void:
	for a in allies.duplicate():
		if is_instance_valid(a):
			a.resume()
