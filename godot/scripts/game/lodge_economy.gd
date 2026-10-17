extends Node
## LodgeEconomy: 숙박 예약·입실·지급의 단일 기록과 골드·구매.
## 각 묶음은 정해진 시각에 도착하고, 도착 시점의 정원만큼 인원이 정해지며, 20초 뒤 한 번만 지불한다.
## 카드 코어 v0.3 §5: 정산을 마친 손님 중 고용 가능한 사람이 문가에서 10초 기다린다. 고용하면 용병 계약 카드.

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const TravelerScript := preload("res://scripts/actors/traveler.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")

signal gold_changed(gold: int)
signal offers_changed
signal batch_arrived(profiles: Array)
signal guest_departed(profile: Dictionary, reason: String)

var game
var gold := Cfg.START_GOLD
var total_earned := 0
var capacity := Cfg.BASE_CAPACITY
var batches: Array = []
var guests: Array = []
var offers: Array = []      # {person, guest, expires}
var prep_time := 0.0
var guest_visit_counts: Dictionary = {} # 첫인사와 재방문 대사. 낮이 바뀌어도 유지한다.


func _ready() -> void:
	name = "LodgeEconomy"


func begin_prep() -> void:
	batches.clear()
	for t in Cfg.GUEST_ARRIVALS:
		batches.append({"arrive": t, "pay": t + Cfg.GUEST_STAY, "count": 0, "spawned": false, "paid": false, "guests": []})


func update_prep(t: float) -> void:
	prep_time = t
	for o in offers.duplicate():
		if t >= o["expires"]:
			_close_offer(o, false)
	for bi in batches.size():
		var b: Dictionary = batches[bi]
		if not b["spawned"] and t >= b["arrive"]:
			b["spawned"] = true
			b["count"] = capacity
			_spawn_batch(b)
		if b["spawned"] and not b["paid"] and t >= b["pay"]:
			b["paid"] = true
			var amount: int = b["count"] * Cfg.GUEST_FEE
			_add_gold(amount)
			game.toast("+%dG 숙박비 (%d명)" % [amount, b["count"]], Color(1.0, 0.85, 0.45))
			var hire_slot: int = 0 if bi in Cfg.HIRE_BATCHES or b.get("invited", false) else -1
			for i in b["guests"].size():
				var g = b["guests"][i]
				if not is_instance_valid(g):
					continue
				if i == hire_slot:
					_open_offer(g, t)
					continue
				var back: Array = Layout.TRAVELER_ROUTE.duplicate()
				back.reverse()
				g.leave(back, i * 0.5)
				guest_departed.emit(g.profile, "퇴실")


## 숙박 초대장: 손님 한 무리를 지금 바로 부른다. 정원만큼 묵고 숙박비를 내며, 한 명은 고용 제안을 한다.
## 사용 가능 여부는 invite_block_reason()으로 먼저 확인한다.
func invite_block_reason() -> String:
	if game.session.state != SessionScript.State.PREP:
		return "손님 초대는 준비 시간에만 가능합니다"
	if game.session.prep_remaining() < Cfg.INVITE_MIN_TIME:
		return "손님이 묵을 시간이 부족합니다 (남은 시간 %d초 이상 필요)" % int(Cfg.INVITE_MIN_TIME)
	return ""


func invite_batch() -> bool:
	if invite_block_reason() != "":
		return false
	batches.append({"arrive": prep_time, "pay": prep_time + Cfg.GUEST_STAY, "count": 0, "spawned": false, "paid": false,
		"guests": [], "invited": true})
	return true


func _pick_name(preferred: String = "") -> String:
	var used: Array = game.cards.persons_in_use() + game.contracts.persons_active()
	for o in offers:
		used.append(o["person"])
	for g in guests:
		if is_instance_valid(g) and g.profile.get("hireable", false):
			used.append(g.profile["person"])
	for n in [preferred] + Cfg.MERC_NAMES:
		if n != "" and not n in used:
			return n
	return "용병 %d" % (game.cards.stats["hired"] + 1)


func _open_offer(g, t: float) -> void:
	var person: String = g.profile.get("person", _pick_name())
	var o := {"person": person, "guest": g, "expires": t + Cfg.HIRE_WAIT, "job": GuestProfiles.job_of(person)}
	g.wait_at(Layout.DOOR_FRONT + Vector3(-0.9, 0, 0.7))
	offers.append(o)
	game.toast("손님 %s이(가) 일자리를 찾습니다 — %s 계약 %dG" % [o["person"], Cfg.JOB_NAMES[o["job"]], Cfg.CONTRACT_COST], Color(1.0, 0.88, 0.6))
	game.sounds.play("offer_open")
	offers_changed.emit()


func _close_offer(o: Dictionary, hired: bool) -> void:
	offers.erase(o)
	var g = o["guest"]
	if is_instance_valid(g):
		if hired:
			g.vanish()
			guest_departed.emit(g.profile, "계약 완료")
		else:
			var back: Array = Layout.TRAVELER_ROUTE.duplicate()
			back.reverse()
			g.leave(back, 0.0)
			guest_departed.emit(g.profile, "퇴실")
			game.sounds.play("offer_expire")
	offers_changed.emit()


func offer_time_left(o: Dictionary) -> float:
	return maxf(o["expires"] - prep_time, 0.0)


func hire_block_reason(o: Dictionary) -> String:
	if game.session.state != SessionScript.State.PREP:
		return "준비 시간에만 고용"
	if not o in offers:
		return "기회 종료"
	if gold < Cfg.CONTRACT_COST:
		return "골드 부족"
	if game.world.graveyard.free_slots() <= game.contracts.mercs_alive() + _merc_cards():
		return "묘지가 가득 참 — 묘지 확장 필요"
	return ""


## 아직 사용하지 않은 용병 계약 카드 수(손패·주머니, 네 직업 합계).
func _merc_cards() -> int:
	var n := 0
	for id in Cfg.JOB_CARDS:
		n += game.cards.count_of(id)
	return n


## 고용 제안의 직업 카드 id.
func offer_job(o: Dictionary) -> String:
	return o.get("job", GuestProfiles.job_of(o["person"]))


## 고용: 계약료 1회 결제 → 용병 계약 카드. 숙박비 정산과는 별개다.
func hire(o: Dictionary) -> bool:
	if hire_block_reason(o) != "":
		return false
	gold -= Cfg.CONTRACT_COST
	gold_changed.emit(gold)
	game.sounds.play("gold_spend")
	game.sounds.play("hire")
	var job := offer_job(o)
	game.cards.add(job, 1, o["person"])
	game.toast("%s을(를) 고용했습니다 — %s 계약 카드 획득" % [o["person"], Cfg.JOB_NAMES[job]], Color(1.0, 0.85, 0.5))
	_close_offer(o, true)
	return true


## 자원 판매(양털·생고기·토끼 가죽): 판매할 때만 골드가 생긴다(자동 판매 없음).
func sell_wool(uid: int, amount: int) -> bool:
	return sell_resource(uid, amount)


func sell_resource(uid: int, amount: int) -> bool:
	var e: Dictionary = game.cards.get_entry(uid)
	if e.is_empty() or not Cfg.SALE_PRICES.has(e["id"]) or amount <= 0 or amount > int(e["count"]):
		return false
	if game.session.state != SessionScript.State.PREP:
		return false
	var id: String = e["id"]
	if not game.cards.consume(uid, amount):
		return false
	if id == "wool":
		game.cards.stats["wool_sold"] += amount
	var price: int = Cfg.SALE_PRICES[id]
	_add_gold(amount * price)
	game.toast("%s %d개 판매 +%dG" % [game.cards.def(id).get("name", id), amount, amount * price], Color(1.0, 0.85, 0.45))
	game.sounds.play("card_play")
	return true


func _spawn_batch(b: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var arriving: Array = []
	var batch_index := batches.find(b)
	var preferred := GuestProfiles.preferred_mercenary(batch_index, game.session.day())
	for i in b["count"]:
		var g := TravelerScript.new()
		g.profile = GuestProfiles.make_guest(i, batch_index, game.session.day(), _pick_name(preferred))
		var visitor_id: String = g.profile["character_id"]
		var visits: int = guest_visit_counts.get(visitor_id, 0)
		g.profile["line"] = GuestProfiles.greeting(g.profile, visits)
		guest_visit_counts[visitor_id] = visits + 1
		arriving.append(g.profile)
		var pts: Array = []
		for p in Layout.TRAVELER_ROUTE:
			pts.append(p + Vector3(rng.randf_range(-0.25, 0.25), 0, rng.randf_range(-0.25, 0.25)))
		pts[pts.size() - 1] = Layout.DOOR_FRONT
		g.setup(pts, i * 0.55)
		g.position = pts[0]
		game.actors.add_child(g)
		b["guests"].append(g)
		guests.append(g)
	batch_arrived.emit(arriving)


## 준비 시간 종료: 남은 손님 표시를 정리(정상 진행이면 모두 지불·퇴장한 뒤).
func end_prep() -> void:
	for o in offers.duplicate():
		_close_offer(o, false)
	for g in guests:
		if is_instance_valid(g):
			guest_departed.emit(g.profile, "퇴실")
			g.queue_free()
	guests.clear()


func guests_inside() -> int:
	var n := 0
	for b in batches:
		if b["spawned"] and not b["paid"]:
			n += b["count"]
	return n


func next_arrival_in(t: float) -> float:
	for b in batches:
		if not b["spawned"]:
			return b["arrive"] - t
	return -1.0


func next_payment_in(t: float) -> float:
	for b in batches:
		if b["spawned"] and not b["paid"]:
			return b["pay"] - t
	return -1.0


func _add_gold(amount: int) -> void:
	gold += amount
	total_earned += amount
	if amount > 0:
		game.sounds.play("gold_reward")
	gold_changed.emit(gold)


## 골드 지출(장날 구매·정화). 부족하면 아무것도 바꾸지 않는다.
func spend(amount: int) -> bool:
	if amount < 0 or gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true


func debug_add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)


# ───────────────────────── 구매 ─────────────────────────

## 건축(생성·증축·업그레이드)의 다음 단계 비용 {gold, timber}. 최대 단계면 빈 사전.
func build_cost(kind: String) -> Dictionary:
	var steps: Array = Cfg.BUILD_COSTS.get(kind, [])
	var step := build_step(kind)
	if step < 0 or step >= steps.size():
		return {}
	return steps[step]


## 다음에 지을 단계 번호(0부터). 건축 항목이 아니면 -1.
func build_step(kind: String) -> int:
	match kind:
		"extension": return 1 if game.world.lodge.extension_built else 0
		"pasture": return game.world.pasture.level
		"graves": return game.world.graveyard.level
	return -1


func is_build(kind: String) -> bool:
	return Cfg.BUILD_COSTS.has(kind)


func cost_of(kind: String) -> int:
	if is_build(kind):
		return int(build_cost(kind).get("gold", 0))
	match kind:
		"repair": return Cfg.COST_REPAIR
		"heal": return Cfg.COST_HEAL
		"sheep": return Cfg.COST_SHEEP
		"dragon": return Cfg.COST_DRAGON
	return 0


func timber_cost_of(kind: String) -> int:
	return int(build_cost(kind).get("timber", 0)) if is_build(kind) else 0


## 쓸 수 있는 목재 = 손패에 뽑힌 목재(확정 규칙 9). 주머니 속 목재는 아침 드로우 등으로 손패에 와야 쓴다.
func timber() -> int:
	return game.cards.hand_count_of("timber")


## 버튼 표기: "60G · 목재 10"
func price_text(kind: String) -> String:
	if is_build(kind) and build_cost(kind).is_empty():
		return "완료"
	var t := timber_cost_of(kind)
	return "%dG" % cost_of(kind) + (" · 목재 %d" % t if t > 0 else "")


## 구매 불가 사유(가능하면 빈 문자열).
func block_reason(kind: String) -> String:
	var s = game.session
	if s.is_over():
		return "게임 종료"
	if kind == "dragon":
		if s.state != SessionScript.State.COMBAT:
			return "전투 중에만 가능"
		if game.dragon.is_present() or game.dragon.used_this_wave:
			return "이번 웨이브에 이미 소환함"
		if game.waves.alive() == 0 and game.waves.pending() == 0:
			return "남은 적 없음"
	else:
		if s.state != SessionScript.State.PREP:
			return "준비 시간에만 가능"
		if is_build(kind) and build_cost(kind).is_empty():
			return "최대 단계"
		match kind:
			"repair":
				if game.world.lodge.hp >= game.world.lodge.max_hp:
					return "체력 최대"
			"heal":
				if game.player.hp >= game.player.max_hp:
					return "체력 최대"
			"sheep":
				if not game.world.pasture.has_empty_slot():
					return "목장이 가득 참 — 목장 증축 필요"
	if gold < cost_of(kind):
		return "골드 부족"
	if timber() < timber_cost_of(kind):
		return "목재 부족 (%d/%d)" % [timber(), timber_cost_of(kind)]
	return ""


## 조건 확인과 차감·효과를 한 번에 처리한다(연속 클릭에도 1회만 차감).
func buy(kind: String) -> bool:
	if block_reason(kind) != "":
		return false
	var cost := cost_of(kind)
	var wood := timber_cost_of(kind)
	if wood > 0 and not game.cards.consume_id("timber", wood):
		return false
	gold -= cost
	match kind:
		"extension":
			capacity = Cfg.EXT_CAPACITY
			game.world.lodge.build_extension()
			game.toast("객실 증축 완료 (목재 %d) — 다음 손님부터 정원 3명" % wood, Color(1.0, 0.85, 0.5))
		"pasture":
			game.world.pasture.upgrade()
			game.toast("목장 증축 완료 (목재 %d) — 양 최대 %d마리" % [wood, game.world.pasture.capacity()], Color(1.0, 0.9, 0.6))
		"graves":
			game.world.graveyard.upgrade()
			game.toast("묘지 확장 완료 (목재 %d) — 무덤 최대 %d기" % [wood, game.world.graveyard.capacity()], Color(0.85, 0.85, 1.0))
		"repair":
			var r: float = game.world.lodge.repair(Cfg.REPAIR_AMOUNT)
			game.toast("산장 수리 +%d" % int(r), Color(0.9, 0.9, 1.0))
		"heal":
			var h: float = game.player.heal(Cfg.HEAL_AMOUNT)
			game.toast("마녀 회복 +%d" % int(h), Color(0.8, 1.0, 0.8))
		"sheep":
			game.world.pasture.add_sheep()
			game.toast("양 한 마리를 들였습니다 (%d/%d)" % [game.world.pasture.alive_count(), game.world.pasture.capacity()], Color(1.0, 1.0, 0.95))
		"dragon":
			game.dragon.summon()
			game.toast("용에게 공물을 바쳤습니다!", Color(1.0, 0.6, 0.3))
	gold_changed.emit(gold)
	if kind != "dragon":
		game.sounds.play("shop_buy")
	return true
