extends "res://scripts/game/card_module.gd"
## 용병 고유 키트 v04 1차 — 인간 4명(브람·올라프·토르빈·미라). docs/mercenary-unique-kit-v04.md(사용자 승인 2026-10-26).
## 용병 = 고유 카드(고용하면 주머니로) + 고유 패시브 + 고유 스킬(기세 100에서 자동). 효과는 모두 눈에 보이는 것 하나.
## 오토배틀 토대:
##  - 기세(0~100): 평타가 맞으면 +10, 피해를 받으면 받은 만큼(1회 최대 +15), 비전투직(나무꾼·채집가)은 밤에 초당 +5.
##  - 마력: 밤 전투 시작 3, 초당 0.5, 최대 10. 이 모듈의 카드만 마력을 쓴다(기존 카드는 그대로).
##  - 전투 중 드로우 없음: 밤 손패는 5장까지만 뽑고(card_inventory.phase_swap), 스택 드로우는 밤에 멈춘다(_count_use).
##  - 생성 카드: 용병이 만들어 손패에 넣는 카드. 이번 전투만 — 쓰면 사라지고(버림패로 가지 않음) 전투가 끝나면 손패에서 지운다.
##    손패가 가득하면 대기열(최대 3)에 있다가 자리가 나면 들어온다.
## 시험 방향이라 --classic-cards 로 끈다(enabled = false 면 아무 훅도 동작하지 않는다). 수치는 모두 시험값이다.

const Fx := preload("res://scripts/visual/fx.gd")
const Cfg := preload("res://scripts/config.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")

static var enabled := true

const MOMENTUM_MAX := 100.0
const HIT_MOMENTUM := 10.0
const HURT_MOMENTUM_CAP := 15.0
const IDLE_MOMENTUM := 5.0        # 비전투직: 밤에 산장 안에서 초당
const MANA_START := 3.0
const MANA_REGEN := 0.5
const MANA_MAX := 10.0
const START_HAND := 5             # 밤 시작 손패(card_inventory.phase_swap 이 읽는다)
const GEN_QUEUE := 3

# ── 브람 ──
const SHIELD_RADIUS := 4.0
const SHIELD_TIME := 4.0
const SHIELD_TAKEN := 0.5
const HORN_DAMAGE := 15.0
const HORN_RADIUS := 3.0
const HORN_DASH := 0.5            # 초
# ── 올라프 ──
const FIRE_ARROWS := 3
const FIRE_DAMAGE := 12.0
const FIRE_CLUSTER := 3.0         # 몰림 판단 반경
const FIRE_REACH := 20.0
const MARK_TIME := 8.0
const MARK_TAKEN := 1.5
# ── 토르빈 ──
const LOG_DAMAGE := 15.0
const LOG_WIDTH := 1.5
const LOG_LENGTH := 16.0
const LOG_PUSH := 3.0
# ── 미라 ──
const HERB_HEAL := 30.0
const CAULDRON_HEAL := 20.0

## 인물(표시 이름) → 키트. cards: 고용하면 주머니에 넣는 고유 카드와 장수.
const KITS := {
	"브람": {"id": "bram", "cards": {"merc_war_horn": 2}, "skill": "방패벽"},
	"올라프": {"id": "olaf", "cards": {"merc_hunt_mark": 1}, "skill": "불화살"},
	"토르빈": {"id": "torbin", "cards": {"merc_rolling_log": 1}, "skill": "말뚝 깎기"},
	"미라": {"id": "mira", "cards": {"merc_big_cauldron": 1}, "skill": "약초 달이기"},
}
## 카드 → 주인(고유 카드). 주인이 산장에 없으면 쓸 수 없다.
const OWNER := {"merc_war_horn": "브람", "merc_hunt_mark": "올라프", "merc_rolling_log": "토르빈", "merc_big_cauldron": "미라"}
const COST := {"merc_war_horn": 2, "merc_hunt_mark": 0, "merc_rolling_log": 2, "merc_big_cauldron": 2,
	"gen_rally": 0, "gen_log_wall": 0, "gen_herb_water": 0}
const CARD_IDS := ["merc_war_horn", "merc_hunt_mark", "merc_rolling_log", "merc_big_cauldron", "gen_rally", "gen_log_wall", "gen_herb_water"]

var mana := 0.0
var momentum: Dictionary = {}     # ally instance id → 기세
var _shield: Dictionary = {}      # ally instance id → 방패벽이 끝나는 시각(초)
var _mark = null                  # 사냥 표식이 붙은 적
var _mark_until := 0.0
var _queue: Array = []            # 손패가 가득해 기다리는 생성 카드 [id, person]
var _clock := 0.0
var stats := {"casts": 0, "generated": 0, "queued": 0, "dropped": 0, "mana_spent": 0, "marks_returned": 0}


func _ready() -> void:
	name = "MercKit"
	if "--classic-cards" in OS.get_cmdline_user_args():
		enabled = false
	if game.get("session") != null and game.session != null:
		game.session.state_changed.connect(_on_state)


func handles(id: String) -> bool:
	return enabled and id in CARD_IDS


static func is_generated_id(id: String) -> bool:
	return id.begins_with("gen_")


# ───────────────────────── 낮밤 ─────────────────────────

func _on_state(state) -> void:
	if not enabled:
		return
	if state == SessionScript.State.COMBAT:
		start_battle()
	elif state == SessionScript.State.CLEARING or state == SessionScript.State.PREP:
		end_battle()


## 전투 시작: 마력·기세를 처음으로, 패시브(전투 시작 생성 카드).
func start_battle() -> void:
	mana = MANA_START
	momentum.clear()
	_shield.clear()
	_mark = null
	for a in kit_mercs():
		match a.person:
			"브람": generate("gen_rally", a.person)
			"토르빈":
				generate("gen_log_wall", a.person)
				generate("gen_log_wall", a.person)
			"미라":
				generate("gen_herb_water", a.person)
				generate("gen_herb_water", a.person)


## 전투 끝: 생성 카드를 지우고 대기열·표식·방패를 비운다.
func end_battle() -> void:
	_queue.clear()
	_shield.clear()
	_mark = null
	momentum.clear()
	purge_generated()


func purge_generated() -> int:
	var n := 0
	for e in game.cards.entries.duplicate():
		if e.get("generated", false):
			game.cards.entries.erase(e)
			n += 1
	if n > 0:
		game.cards.changed.emit()
	return n


# ───────────────────────── 매 프레임 ─────────────────────────

func _process(delta: float) -> void:
	if not enabled or game.session == null:
		return
	_clock += delta
	if not _night() or game.session.state != SessionScript.State.COMBAT:
		return
	mana = minf(mana + MANA_REGEN * delta, MANA_MAX)
	tick(delta)


## 기세 충전(비전투직)·스킬 시전·대기열·표식 정리. 검증에서 직접 부른다.
func tick(delta: float) -> void:
	for a in kit_mercs():
		if a.is_noncombat_job():
			add_momentum(a, IDLE_MOMENTUM * delta)
		if momentum_of(a) >= MOMENTUM_MAX and cast_skill(a):
			momentum[a.get_instance_id()] = 0.0
			stats["casts"] += 1
	_flush_queue()
	if _mark != null:
		if not is_instance_valid(_mark):
			_mark = null
		elif _mark.dead:
			# 숲지기의 눈: 표식한 적이 쓰러지면 [사냥 표식]이 돌아온다
			_mark = null
			if alive_merc("올라프") != null:
				generate("merc_hunt_mark", "올라프")
				stats["marks_returned"] += 1
		elif _clock > _mark_until:
			_mark = null


# ───────────────────────── 용병 ─────────────────────────

## 키트가 있는 살아 있는 용병(산장 안 비전투직 포함).
func kit_mercs() -> Array:
	if game.get("contracts") == null:
		return []
	return game.contracts.allies.filter(func(a): return is_instance_valid(a) and not a.dead and a.kind == "merc" and KITS.has(a.person))


func alive_merc(person: String):
	for a in kit_mercs():
		if a.person == person:
			return a
	return null


func momentum_of(a) -> float:
	return float(momentum.get(a.get_instance_id(), 0.0))


func add_momentum(a, amount: float) -> void:
	if not enabled or not KITS.has(a.person):
		return
	momentum[a.get_instance_id()] = minf(momentum_of(a) + amount, MOMENTUM_MAX)


## ally.on_hit: 평타가 적에게 맞음.
func on_ally_hit(a, _e) -> void:
	if enabled and _night():
		add_momentum(a, HIT_MOMENTUM)


## ally.take_damage: 실제로 받은 피해(배율 적용 뒤).
func on_ally_hurt(a, amount: float) -> void:
	if enabled and _night():
		add_momentum(a, minf(amount, HURT_MOMENTUM_CAP))


## ally.take_damage 가 곱하는 받는 피해 배율(방패벽).
func taken_mult(a) -> float:
	if not enabled:
		return 1.0
	return SHIELD_TAKEN if float(_shield.get(a.get_instance_id(), -1.0)) > _clock else 1.0


## monster.take_damage 가 곱하는 받는 피해 배율(사냥 표식).
func enemy_taken_mult(e) -> float:
	return MARK_TAKEN if enabled and _mark == e and _clock <= _mark_until else 1.0


func shielded(a) -> bool:
	return taken_mult(a) < 1.0


func marked():
	return _mark


func _heal(a, amount: float) -> void:
	a.hp = minf(a.hp + amount, a.max_hp)
	Fx.heal(a.global_position + Vector3(0, 1.0, 0))
	Fx.float_text(a.get_parent(), a.global_position + Vector3(0, 2.2, 0), "+%d" % int(amount), Color(0.6, 1.0, 0.6))


## 체력 비율이 가장 낮은 다친 용병(없으면 null).
func most_hurt():
	var best = null
	var best_f := 1.0
	for a in game.contracts.allies:
		if not is_instance_valid(a) or a.dead or a.kind != "merc":
			continue
		var f: float = a.hp / a.max_hp
		if f < best_f:
			best_f = f
			best = a
	return best


func _enemies() -> Array:
	return game.get_tree().get_nodes_in_group("enemies").filter(func(e): return not e.dead)


# ───────────────────────── 고유 스킬(기세 100) ─────────────────────────

## 반환: 썼는가. 쓸 대상이 없으면 기세 100인 채 기다린다.
func cast_skill(a) -> bool:
	match a.person:
		"브람":
			# 방패벽: 4초간 주변 4m 아군 받는 피해 절반
			for m in game.contracts.allies:
				if is_instance_valid(m) and not m.dead and _flat(m.global_position, a.global_position) <= SHIELD_RADIUS:
					_shield[m.get_instance_id()] = _clock + SHIELD_TIME
					Fx.burst(m.get_parent(), m.global_position + Vector3(0, 1.0, 0), Color(1.0, 0.85, 0.35), 10, 2.0)
		"올라프":
			# 불화살: 적이 가장 많은 곳에 3발(각 12)
			var hits := fire_targets(a.global_position)
			if hits.is_empty():
				return false
			for e in hits:
				Fx.hit(e.global_position + Vector3(0, 0.8, 0), Color(1.0, 0.55, 0.2), true)
				e.take_damage(FIRE_DAMAGE)
		"토르빈":
			generate("gen_log_wall", a.person)
		"미라":
			var t = most_hurt()
			if t == null:
				return false
			_heal(t, HERB_HEAL)
		_:
			return false
	_announce(a, str(KITS[a.person]["skill"]))
	return true


func _announce(a, skill: String) -> void:
	Fx.float_text(a.get_parent(), a.global_position + Vector3(0, 2.6, 0), skill + "!", Color(1.0, 0.85, 0.4))
	game.sounds.play_or("card_play", "card_play")


## 불화살 대상: 사거리 안에서 주변 3m에 적이 가장 많은 적을 중심으로, 중심에 가까운 적부터 3마리(적이 적으면 같은 적에게 여러 발).
func fire_targets(from: Vector3) -> Array:
	var pool := _enemies().filter(func(e): return _flat(e.global_position, from) <= FIRE_REACH)
	if pool.is_empty():
		return []
	var center = pool[0]
	var best := -1
	for e in pool:
		var n := 0
		for o in pool:
			if _flat(o.global_position, e.global_position) <= FIRE_CLUSTER:
				n += 1
		if n > best:
			best = n
			center = e
	var near := pool.duplicate()
	near.sort_custom(func(x, y): return _flat(x.global_position, center.global_position) < _flat(y.global_position, center.global_position))
	var out: Array = []
	for i in FIRE_ARROWS:
		out.append(near[i % near.size()])
	return out


# ───────────────────────── 생성 카드 ─────────────────────────

## 용병이 카드를 만들어 손패에 넣는다. 손패가 가득하면 대기열(최대 3), 그것도 차면 버린다. 반환: 손패에 들어간 uid(-1 = 대기·버림).
func generate(id: String, person: String) -> int:
	if game.cards.hand_full():
		if _queue.size() < GEN_QUEUE:
			_queue.append([id, person])
			stats["queued"] += 1
		else:
			stats["dropped"] += 1
		return -1
	return _put_in_hand(id, person)


func _put_in_hand(id: String, person: String) -> int:
	game.cards.add(id, 1, person, "hand")
	var e: Dictionary = game.cards.entries.back()
	e["generated"] = true
	stats["generated"] += 1
	game.toast("%s — '%s'" % [person, game.cards.def(id).get("name", id)], Color(1.0, 0.88, 0.55))
	game.cards.changed.emit()
	return int(e["uid"])


func _flush_queue() -> void:
	while not _queue.is_empty() and not game.cards.hand_full():
		var q: Array = _queue.pop_front()
		_put_in_hand(q[0], q[1])


func queue_size() -> int:
	return _queue.size()


# ───────────────────────── 고용·이별 ─────────────────────────

## 고용(lodge_economy.hire): 고유 카드를 주머니에 넣는다(밤 카드).
func on_hired(person: String) -> void:
	if not enabled or not KITS.has(person):
		return
	var cards: Dictionary = KITS[person]["cards"]
	for id in cards:
		for i in int(cards[id]):
			game.cards.add(id, 1, person, "pocket")
	game.toast("%s의 고유 카드 %d장이 주머니에 들어갔습니다" % [person, _sum(cards)], Color(1.0, 0.85, 0.5))


## 용병이 산장을 떠남(쓰러짐·해고): 그 사람의 고유 카드를 손패·주머니·버림패에서 뺀다.
func on_merc_gone(person: String) -> void:
	if not enabled or not KITS.has(person):
		return
	var ids: Dictionary = KITS[person]["cards"]
	var cards = game.cards
	for e in cards.entries.duplicate():
		if ids.has(e["id"]) and e.get("person", "") == person:
			cards.entries.erase(e)
	cards.discard = cards.discard.filter(func(e): return not (ids.has(e["id"]) and e.get("person", "") == person))
	cards.changed.emit()


func _sum(d: Dictionary) -> int:
	var n := 0
	for k in d:
		n += int(d[k])
	return n


# ───────────────────────── 카드 판정 ─────────────────────────

func evaluate(entry: Dictionary, sp: Vector2, r) -> Dictionary:
	var plan := _evaluate(entry, sp, r)
	if plan.get("ok", false):
		plan["action"] = "merc"
		plan["merc_card"] = entry["id"]
	return plan


func _evaluate(entry: Dictionary, sp: Vector2, r) -> Dictionary:
	var id: String = entry["id"]
	if not _night():
		return _fail("밤 전투 중에만 쓸 수 있습니다")
	var cost := int(COST.get(id, 0))
	if mana < cost:
		return _fail("마력이 모자랍니다 (%d / %d)" % [int(floor(mana)), cost])
	if OWNER.has(id) and alive_merc(OWNER[id]) == null:
		return _fail("%s이(가) 산장에 없습니다" % OWNER[id])
	var cost_line := "마력 %d" % cost
	match id:
		"merc_war_horn":
			var p = _point(sp, r)
			if p is String:
				return _fail(p)
			return {"ok": true, "pos": p, "title": "진격 나팔", "lines": ["무리 전체가 이곳으로 돌격 · 도착하면 주변 적 피해 %d" % int(HORN_DAMAGE), cost_line]}
		"merc_hunt_mark":
			var e = r.enemy_at(sp)
			if e == null:
				return _fail("표식할 적 위에 놓으세요")
			return {"ok": true, "pos": e.global_position, "enemy": e, "title": "사냥 표식", "lines": ["모든 아군이 이 적을 집중 공격 · 받는 피해 %.1f배 (%d초)" % [MARK_TAKEN, int(MARK_TIME)], cost_line]}
		"merc_rolling_log":
			var p = _point(sp, r)
			if p is String:
				return _fail(p)
			return {"ok": true, "pos": p, "title": "굴러가는 통나무", "lines": ["산장에서 이쪽으로 통나무가 굴러감 · 닿는 적 피해 %d · 밀려남" % int(LOG_DAMAGE), cost_line]}
		"merc_big_cauldron":
			if most_hurt() == null:
				return _fail("다친 용병이 없습니다")
			return {"ok": true, "pos": _anywhere(), "title": "큰 약솥", "lines": ["모든 용병 체력 %d 회복" % int(CAULDRON_HEAL), cost_line]}
		"gen_rally":
			var a = r.merc_target(sp)
			if a == null or not KITS.has(a.person):
				return _fail("고유 스킬이 있는 용병(또는 초상)에 놓으세요")
			return {"ok": true, "pos": a.global_position, "ally": a, "title": "호령 — " + a.person, "lines": ["기세가 꽉 차서 바로 %s!" % KITS[a.person]["skill"]]}
		"gen_log_wall":
			var p = _point(sp, r)
			if p is String:
				return _fail(p)
			return {"ok": true, "pos": p, "title": "통나무 벽", "lines": ["너비 3m 통나무 벽 · 체력 60 · 이번 전투 동안"]}
		"gen_herb_water":
			var a = r.merc_target(sp)
			if a == null:
				return _fail("용병(또는 초상)에 놓으세요")
			return {"ok": true, "pos": a.global_position, "ally": a, "title": "약초 물 — " + a.person, "lines": ["체력 %d 회복" % int(HERB_HEAL)]}
	return _fail("알 수 없는 카드")


func commit(uid: int, plan: Dictionary, _r) -> Dictionary:
	var id: String = plan["merc_card"]
	if not game.cards.consume(uid):
		return _fail("카드가 없습니다")
	var cost := int(COST.get(id, 0))
	mana -= cost
	stats["mana_spent"] += cost
	match id:
		"merc_war_horn":
			war_horn(plan["pos"])
		"merc_hunt_mark":
			mark(plan["enemy"])
		"merc_rolling_log":
			rolling_log(plan["pos"])
		"merc_big_cauldron":
			for a in game.contracts.allies:
				if is_instance_valid(a) and not a.dead and a.kind == "merc":
					_heal(a, CAULDRON_HEAL)
		"gen_rally":
			var a = plan["ally"]
			momentum[a.get_instance_id()] = MOMENTUM_MAX
			if cast_skill(a):
				momentum[a.get_instance_id()] = 0.0
				stats["casts"] += 1
		"gen_log_wall":
			game.race_cards._build("log_wall", plan["pos"])
		"gen_herb_water":
			_heal(plan["ally"], HERB_HEAL)
	game.sounds.play_or("card_play", "card_play")
	return plan


# ───────────────────────── 카드 효과 ─────────────────────────

## 진격 나팔: 싸울 수 있는 용병 전원이 지점으로 달려가고(브람이 앞), 도착하면 주변 적 피해.
func war_horn(p: Vector3) -> void:
	var runners: Array = game.contracts.allies.filter(func(a): return is_instance_valid(a) and not a.dead and a.kind == "merc" and not a.hidden and a.is_combat_job())
	var i := 0
	for a in runners:
		var off := Vector3.ZERO if a.person == "브람" else Vector3(cos(i * 1.7), 0, sin(i * 1.7)) * 1.4
		i += 1
		var tw: Tween = a.create_tween()
		tw.tween_property(a, "global_position", Vector3(p.x + off.x, a.global_position.y, p.z + off.z), HORN_DASH).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var t: SceneTreeTimer = game.get_tree().create_timer(HORN_DASH)
	t.timeout.connect(func(): _horn_impact(p))


func _horn_impact(p: Vector3) -> void:
	Fx.burst(game.actors, p + Vector3(0, 0.6, 0), Color(1.0, 0.85, 0.4), 18, 4.0)
	for e in _enemies():
		if _flat(e.global_position, p) <= HORN_RADIUS:
			e.take_damage(HORN_DAMAGE)


## 사냥 표식: 8초간 모든 용병이 이 적을 먼저 치고, 이 적은 피해 1.5배.
func mark(e) -> void:
	_mark = e
	_mark_until = _clock + MARK_TIME
	for a in game.contracts.allies:
		if is_instance_valid(a) and not a.dead and a.is_combat_job():
			a.priority = e
	Fx.float_text(e.get_parent(), e.global_position + Vector3(0, 2.4, 0), "표식", Color(1.0, 0.4, 0.35))


## 굴러가는 통나무: 산장(원점)에서 지점 방향으로 16m. 길 위 적 피해 15, 진행 방향으로 3m 밀림.
func rolling_log(p: Vector3) -> Array:
	var dir := Vector3(p.x, 0, p.z)
	if dir.length() < 0.1:
		dir = Vector3.FORWARD
	dir = dir.normalized()
	var start := dir * 3.0
	var hit: Array = []
	for e in _enemies():
		var rel := Vector3(e.global_position.x, 0, e.global_position.z) - start
		var along := rel.dot(dir)
		if along < 0.0 or along > LOG_LENGTH:
			continue
		if (rel - dir * along).length() <= LOG_WIDTH:
			hit.append(e)
	for e in hit:
		e.take_damage(LOG_DAMAGE)
		if is_instance_valid(e) and not e.dead:
			e.global_position += dir * LOG_PUSH
	_roll_visual(start, dir)
	return hit


func _roll_visual(start: Vector3, dir: Vector3) -> void:
	if game.actors == null:
		return
	var roller := MeshInstance3D.new()
	var m := CylinderMesh.new()
	m.top_radius = 0.35
	m.bottom_radius = 0.35
	m.height = 2.4
	roller.mesh = m
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.45, 0.3, 0.18)
	roller.material_override = mat
	game.actors.add_child(roller)
	roller.global_position = start + Vector3(0, 0.35, 0)
	roller.look_at(roller.global_position + dir.cross(Vector3.UP), Vector3.UP)
	roller.rotate_object_local(Vector3.RIGHT, PI * 0.5)
	var tw := roller.create_tween()
	tw.tween_property(roller, "global_position", start + dir * LOG_LENGTH + Vector3(0, 0.35, 0), 0.7)
	tw.tween_callback(roller.queue_free)
