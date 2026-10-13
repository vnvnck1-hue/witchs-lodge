extends Node
## LodgeEconomy: 숙박 예약·입실·지급의 단일 기록과 골드·구매.
## 각 묶음은 정해진 시각에 도착하고, 도착 시점의 정원만큼 인원이 정해지며, 20초 뒤 한 번만 지불한다.

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const TravelerScript := preload("res://scripts/actors/traveler.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")

signal gold_changed(gold: int)

var game
var gold := 0
var total_earned := 0
var capacity := Cfg.BASE_CAPACITY
var batches: Array = []
var guests: Array = []


func _ready() -> void:
	name = "LodgeEconomy"


func begin_prep() -> void:
	batches.clear()
	for t in Cfg.GUEST_ARRIVALS:
		batches.append({"arrive": t, "pay": t + Cfg.GUEST_STAY, "count": 0, "spawned": false, "paid": false, "guests": []})


func update_prep(t: float) -> void:
	for b in batches:
		if not b["spawned"] and t >= b["arrive"]:
			b["spawned"] = true
			b["count"] = capacity
			_spawn_batch(b)
		if b["spawned"] and not b["paid"] and t >= b["pay"]:
			b["paid"] = true
			var amount: int = b["count"] * Cfg.GUEST_FEE
			_add_gold(amount)
			game.toast("+%dG 숙박비 (%d명)" % [amount, b["count"]], Color(1.0, 0.85, 0.45))
			for i in b["guests"].size():
				var g = b["guests"][i]
				if is_instance_valid(g):
					var back: Array = Layout.TRAVELER_ROUTE.duplicate()
					back.reverse()
					g.leave(back, i * 0.5)


func _spawn_batch(b: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in b["count"]:
		var g := TravelerScript.new()
		var pts: Array = []
		for p in Layout.TRAVELER_ROUTE:
			pts.append(p + Vector3(rng.randf_range(-0.25, 0.25), 0, rng.randf_range(-0.25, 0.25)))
		pts[pts.size() - 1] = Layout.DOOR_FRONT
		g.setup(pts, i * 0.55)
		g.position = pts[0]
		game.actors.add_child(g)
		b["guests"].append(g)
		guests.append(g)
	game.toast("여행자 %d명이 도착합니다" % b["count"], Color(0.95, 0.9, 1.0))


## 준비 시간 종료: 남은 손님 표시를 정리(정상 진행이면 모두 지불·퇴장한 뒤).
func end_prep() -> void:
	for g in guests:
		if is_instance_valid(g):
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
	gold_changed.emit(gold)


func debug_add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)


# ───────────────────────── 구매 ─────────────────────────

func cost_of(kind: String) -> int:
	match kind:
		"extension": return Cfg.COST_EXTENSION
		"repair": return Cfg.COST_REPAIR
		"heal": return Cfg.COST_HEAL
		"sheep": return Cfg.COST_SHEEP
		"dragon": return Cfg.COST_DRAGON
	return 0


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
		match kind:
			"extension":
				if game.world.lodge.extension_built:
					return "이미 완료"
			"repair":
				if game.world.lodge.hp >= game.world.lodge.max_hp:
					return "체력 최대"
			"heal":
				if game.player.hp >= game.player.max_hp:
					return "체력 최대"
			"sheep":
				if not game.world.pasture.has_empty_slot():
					return "빈자리 없음"
	if gold < cost_of(kind):
		return "골드 부족"
	return ""


## 조건 확인과 차감·효과를 한 번에 처리한다(연속 클릭에도 1회만 차감).
func buy(kind: String) -> bool:
	if block_reason(kind) != "":
		return false
	var cost := cost_of(kind)
	match kind:
		"extension":
			gold -= cost
			capacity = Cfg.EXT_CAPACITY
			game.world.lodge.build_extension()
			game.toast("객실 증축 완료 — 다음 손님부터 정원 3명", Color(1.0, 0.85, 0.5))
		"repair":
			gold -= cost
			var r: float = game.world.lodge.repair(Cfg.REPAIR_AMOUNT)
			game.toast("산장 수리 +%d" % int(r), Color(0.9, 0.9, 1.0))
		"heal":
			gold -= cost
			var h: float = game.player.heal(Cfg.HEAL_AMOUNT)
			game.toast("마녀 회복 +%d" % int(h), Color(0.8, 1.0, 0.8))
		"sheep":
			gold -= cost
			game.world.pasture.add_sheep()
			game.toast("양 한 마리를 들였습니다", Color(1.0, 1.0, 0.95))
		"dragon":
			gold -= cost
			game.dragon.summon()
			game.toast("용에게 공물을 바쳤습니다!", Color(1.0, 0.6, 0.3))
	gold_changed.emit(gold)
	return true
