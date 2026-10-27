extends SceneTree
## 밸런스 측정 기준선(코어 방향 §5.4 · §8 2단계): 12일 챕터를 헤드리스 자동 플레이로 끝까지 돌려
## 밤마다 산장·마녀 체력, 골드, 용병 수, 덱 구성을 기록한다. 카드·시스템을 바꿀 때마다 이 숫자와 비교한다.
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/sim_balance.gd -- --policy=steady --seed=1
## 정책:
##   idle   — 아무것도 하지 않는다(마녀는 제자리, 카드·고용·구매 없음).
##   hire   — 고용 제안을 모두 받고 계약 카드를 산장 마당에 놓기만 한다. 다른 카드·구매·마녀 조작 없음.
##   steady — 무난한 운영: 고용·배치 + 손패 카드를 쓸 수 있는 곳에 쓰기 + 증축·수리·회복 구매 + 털 수확 + 마녀가 산장 가까운 적을 공격 이동.
## 결과: 콘솔의 NIGHT/RESULT 줄과 art_sources/sim-balance/<policy>-s<seed>.json.
## 목표 곡선(시험값, 코어 방향 §5.4): idle은 2일째 밤에 진다 · hire는 6~9일에 무너진다 · steady는 12일을 깨되 여유 30% 안팎.

const Layout := preload("res://scripts/world/layout.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")

const TIME_SCALE := 8.0
const STATE_NAMES := ["PREP", "COMBAT", "CLEARING", "VICTORY", "DEFEAT"]
const BUYS := ["repair", "heal", "extension", "bunks", "pasture", "sheep"]

var policy := "steady"
var seed_value := 1
var game
var last_state := -1
var nights: Array = []
var night_start := {}
var card_uses := 0
var card_uses_night := 0
var hires := 0
var buys_log: Array = []
var stalls := 0
var _card_cd := 0.0
var _move_cd := 0.0
var _last_real := 0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--policy="):
			policy = a.trim_prefix("--policy=")
		elif a.begins_with("--seed="):
			seed_value = int(a.trim_prefix("--seed="))
	if not policy in ["idle", "hire", "steady"]:
		push_error("unknown policy " + policy)
		quit(2)
		return
	seed(seed_value)
	# 게임 시간 12일(낮 90초 + 밤)을 넉넉히 덮는 실제 시간 상한
	create_timer(1500.0, true, false, true).timeout.connect(func(): _finish("timeout"))
	call_deferred("run")


func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 12:
		await physics_frame
	game.grant_starter_cards(false)
	Engine.time_scale = TIME_SCALE
	print("SIM policy=%s seed=%d days=%d" % [policy, seed_value, game.session.total_days()])
	_last_real = Time.get_ticks_msec()
	while true:
		await physics_frame
		if game == null:
			return
		_tick(1.0 / Engine.physics_ticks_per_second)


func _tick(dt: float) -> void:
	var s = game.session
	if s.state != last_state:
		_on_state(s)
		last_state = s.state
		if s.is_over():
			_finish("victory" if s.state == SessionScript.State.VICTORY else "defeat")
			return
	_unstick()
	if policy == "idle":
		return
	_hire_and_place()
	if policy == "hire":
		return
	_card_cd -= dt
	_move_cd -= dt
	if s.state == SessionScript.State.PREP:
		_shop()
		_harvest()
	elif s.state == SessionScript.State.COMBAT:
		_witch_fight()
	if _card_cd <= 0.0:
		_card_cd = 0.5
		_use_cards()


# ───────────────────────── 기록 ─────────────────────────

func _on_state(s) -> void:
	match s.state:
		SessionScript.State.COMBAT:
			card_uses_night = 0
			night_start = _snapshot()
		SessionScript.State.CLEARING, SessionScript.State.DEFEAT, SessionScript.State.VICTORY:
			if s.state != SessionScript.State.VICTORY or nights.size() < s.wave_index:
				_record_night(s)


func _record_night(s) -> void:
	if night_start.is_empty():
		return
	var end := _snapshot()
	var lodge = game.world.lodge
	var row := {
		"day": s.wave_index,
		"night": game.chapter.day_cfg(s.wave_index).get("night", "") if game.get("chapter") != null else "",
		"result": "defeat" if s.state == SessionScript.State.DEFEAT else "cleared",
		"lodge_hp": end["lodge_hp"], "lodge_max": lodge.max_hp,
		"lodge_lost": snappedf(night_start["lodge_hp"] - end["lodge_hp"], 0.1),
		"witch_hp": end["witch_hp"], "witch_lost": snappedf(night_start["witch_hp"] - end["witch_hp"], 0.1),
		"gold": end["gold"], "earned": end["earned"], "mercs": end["mercs"], "mercs_start": night_start["mercs"],
		"deck": end["deck"], "hand": end["hand"], "sheep": end["sheep"],
		"card_uses": card_uses_night, "night_seconds": snappedf(s.play_time - night_start["t"], 0.1),
	}
	nights.append(row)
	print("NIGHT %2d %-11s %-7s lodge %5.1f/%-4d(-%5.1f) witch %5.1f(-%5.1f) gold %4d earned %4d mercs %d→%d deck %2d cards %2d sheep %d %4.1fs" % [
		row["day"], row["night"], row["result"], row["lodge_hp"], int(row["lodge_max"]), row["lodge_lost"], row["witch_hp"], row["witch_lost"],
		row["gold"], row["earned"], row["mercs_start"], row["mercs"], row["deck"], row["card_uses"], row["sheep"], row["night_seconds"]])


func _snapshot() -> Dictionary:
	var c = game.cards
	return {
		"t": game.session.play_time,
		"lodge_hp": snappedf(game.world.lodge.hp, 0.1),
		"witch_hp": snappedf(game.player.hp, 0.1),
		"gold": game.economy.gold, "earned": game.economy.total_earned,
		"mercs": game.contracts.mercs_alive(),
		"deck": c.hand().size() + c.pocket_size(), "hand": c.hand().size(),
		"sheep": game.world.pasture.alive_count(),
	}


func _finish(outcome: String) -> void:
	if game == null:
		return
	var s = game.session
	var summary := {
		"policy": policy, "seed": seed_value, "outcome": outcome,
		"days_survived": s.wave_index - (1 if outcome == "defeat" else 0), "total_days": s.total_days(),
		"defeat_reason": s.defeat_reason, "defeat_day": s.wave_index if outcome == "defeat" else 0,
		"lodge_hp_end": snappedf(game.world.lodge.hp, 0.1), "lodge_max": game.world.lodge.max_hp,
		"lodge_margin": snappedf(game.world.lodge.hp / maxf(game.world.lodge.max_hp, 1.0), 0.01),
		"witch_margin": snappedf(game.player.hp / maxf(game.player.max_hp, 1.0), 0.01),
		"gold_end": game.economy.gold, "earned": game.economy.total_earned,
		"hires": hires, "card_uses": card_uses, "buys": buys_log, "sheep_lost": game.sheep_lost, "stalls": stalls,
		"game_seconds": snappedf(s.play_time, 0.1), "real_seconds": snappedf((Time.get_ticks_msec() - _last_real) / 1000.0, 0.1),
		"nights": nights,
	}
	DirAccess.make_dir_recursive_absolute("res://art_sources/sim-balance")
	var path := "res://art_sources/sim-balance/%s-s%d.json" % [policy, seed_value]
	FileAccess.open(path, FileAccess.WRITE).store_string(JSON.stringify(summary, "  "))
	print("RESULT policy=%s seed=%d outcome=%s survived=%d/%d reason=%s lodge=%.0f%% witch=%.0f%% earned=%d hires=%d cards=%d game=%.0fs real=%.0fs" % [
		policy, seed_value, outcome, summary["days_survived"], summary["total_days"], s.defeat_reason,
		summary["lodge_margin"] * 100.0, summary["witch_margin"] * 100.0, summary["earned"], hires, card_uses,
		summary["game_seconds"], summary["real_seconds"]])
	game = null
	Engine.time_scale = 1.0
	quit(0 if outcome != "timeout" else 2)


# ───────────────────────── 막힘 풀기 ─────────────────────────

## 자동 플레이 중 열린 선택 화면(새벽 보상·장날·상자·마법서·제단)이 게임을 멈추면 정책대로 닫는다.
## idle·hire는 고르지 않고 닫고(닫을 수 없으면 첫 항목), steady는 첫 항목을 고른다.
func _unstick() -> void:
	if game.session.is_over():
		return
	var ui = game.offer_ui
	if ui != null and ui.active:
		stalls += 1
		if policy != "steady" and ui.get("closable") == true:
			ui.close()
		elif not ui.pick(0):
			ui.close()
	if game.chest_ui != null and game.chest_ui.active:
		game.chest_ui.close()
	if game.spellbook_ui != null and game.spellbook_ui.active:
		if policy != "steady" or not game.spellbook_ui.pick(0):
			game.spellbook_ui.close()
	if game.altar_ui != null and game.altar_ui.active:
		game.altar_ui.close()
	if game.mulligan_ui != null and game.mulligan_ui.active and game.mulligan_ui.has_method("confirm"):
		game.mulligan_ui.confirm()
	if game.tutorial != null and game.tutorial.hold:
		game.tutorial.hold = false
	if paused and not game.session.is_over():
		game.hud.refresh_pause()


# ───────────────────────── 고용·배치 ─────────────────────────

func _hire_and_place() -> void:
	var s = game.session
	if s.state == SessionScript.State.PREP:
		for o in game.economy.offers.duplicate():
			if game.economy.hire_block_reason(o) == "" and game.economy.hire(o):
				hires += 1
	# 계약 카드(용병)는 낮이든 밤이든 손에 들어오는 대로 마당에 놓는다
	for e in game.cards.hand():
		if e["id"] in ["warrior", "hunter", "gatherer", "lumberjack"]:
			if _try_card(e, _contract_points(e["id"])):
				return


func _contract_points(id: String) -> Array:
	var pts: Array = []
	if id == "lumberjack":
		for t in game.world.harvest_trees:
			if not t.get("removed", false):
				pts.append(t["pos"] + Vector3(0, minf(t["height"] * 0.45, 2.4), 0))
		pts.sort_custom(func(a, b): return a.distance_to(Layout.DOOR_FRONT) < b.distance_to(Layout.DOOR_FRONT))
		return pts.slice(0, 8)
	for i in 8:
		var ang := i * TAU / 8.0
		pts.append(Layout.DOOR_FRONT + Vector3(cos(ang), 0, sin(ang)) * (2.5 + i * 0.3))
	return pts


# ───────────────────────── steady: 카드·구매·마녀 ─────────────────────────

func _shop() -> void:
	var econ = game.economy
	var lodge = game.world.lodge
	if lodge.hp < lodge.max_hp * 0.7:
		_buy("repair")
	if game.player.hp < game.player.max_hp * 0.6:
		_buy("heal")
	# 저녁 무렵(낮 끝 15초 전)에 남은 돈으로 수리·회복·증축·양
	if game.session.prep_elapsed > 75.0:
		for k in ["repair", "heal"]:
			if econ.gold >= econ.cost_of(k) + 60:
				_buy(k)
		if econ.gold >= econ.cost_of("sheep") + 80:
			_buy("sheep")
		for k in ["extension", "bunks", "pasture"]:
			if econ.gold >= econ.cost_of(k) + 30:
				_buy(k)
		for t in game.world.towers:
			var k: String = "tower_" + t.site_id
			if econ.gold >= econ.cost_of(k) + 30:
				_buy(k)


func _buy(kind: String) -> void:
	if game.economy.block_reason(kind) == "" and game.economy.buy(kind):
		buys_log.append({"day": game.session.day(), "kind": kind})


func _harvest() -> void:
	var p = game.player
	if p.get("harvest_target") != null:
		return
	for sh in game.world.pasture.slots:
		if sh != null and not sh.dead and sh.wool_ready:
			p.harvest(sh)
			return


## 산장 문 앞을 지키는 마녀: 문에서 LEASH m 안으로 들어온 적만 공격하고, 체력이 RETREAT 아래면 문 앞으로 물러나 사거리 안 적만 쏜다.
const LEASH := 12.0
const RETREAT := 0.5

func _witch_fight() -> void:
	if _move_cd > 0.0:
		return
	_move_cd = 0.6
	var p = game.player
	var low: bool = p.hp < p.max_hp * RETREAT
	var best = null
	var bd := 1e9
	for e in game.get_tree().get_nodes_in_group("enemies"):
		if e.dead:
			continue
		var d: float = e.global_position.distance_to(Layout.DOOR_FRONT)
		if d < bd:
			bd = d
			best = e
	if best != null and bd <= LEASH and not low:
		p.command_attack_move(best.global_position, best)
	elif p.global_position.distance_to(Layout.DOOR_FRONT) > 2.5:
		p.command_attack_move(Layout.DOOR_FRONT)


## 손패에서 지금 쓸 수 있는 카드를 한 장 쓴다. 대상 후보(가까운 적·마녀·용병·산장 마당·목장·나무)를 차례로 판정해 첫 성공 자리에 놓는다.
## 모닥불에 태우기는 하지 않는다. 낮의 재화 카드(목재·양털)는 상점 결제·판매에 맡긴다.
func _use_cards() -> void:
	var c = game.cards
	for e in c.hand():
		if e["id"] in ["warrior", "hunter", "gatherer", "lumberjack", "timber", "wool", "ore"]:
			continue
		if not c.usable_now(e["id"]):
			continue
		if _try_card(e, _card_points()):
			card_uses += 1
			card_uses_night += 1 if game.session.state == SessionScript.State.COMBAT else 0
			return


func _card_points() -> Array:
	var pts: Array = []
	var foes: Array = game.get_tree().get_nodes_in_group("enemies").filter(func(x): return not x.dead)
	foes.sort_custom(func(a, b): return a.global_position.distance_to(Layout.DOOR_FRONT) < b.global_position.distance_to(Layout.DOOR_FRONT))
	for f in foes.slice(0, 3):
		pts.append(f.global_position + Vector3(0, 0.7, 0))
	pts.append(game.player.global_position + Vector3(0, 0.8, 0))
	for a in game.get_tree().get_nodes_in_group("allies"):
		if is_instance_valid(a) and not a.get("dead"):
			pts.append(a.global_position + Vector3(0, 0.8, 0))
			break
	pts.append(game.world.lodge.global_position + Vector3(0, 1.5, 0))
	pts.append(Layout.DOOR_FRONT + Vector3(2.0, 0, 2.0))
	var pr: Rect2 = game.world.pasture.rect
	pts.append(Vector3(pr.get_center().x, 0, pr.get_center().y))
	return pts


func _try_card(e: Dictionary, points: Array) -> bool:
	var cam: Camera3D = game.world.camera
	var r = game.resolver
	for p in points:
		if cam.is_position_behind(p):
			continue
		var sp: Vector2 = cam.unproject_position(p)
		var plan: Dictionary = r.evaluate(e["uid"], sp)
		if not plan.get("ok", false) or plan.get("action", "") == "burn":
			continue
		var done: Dictionary = r.commit(e["uid"], sp)
		if done.get("ok", true):
			return true
	return false
