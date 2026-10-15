extends Node
## 신규 카드 v01(서리 룬·수호 등불·숙박 초대장·새끼양) 자동 검증. 실제 게임 장면에서 판정·소비·효과·성장을 재현한다.
## 실행: godot --headless --path . --script res://tools/verify_new_cards.gd

const Cfg := preload("res://scripts/config.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")

const NEW_IDS := ["frost_rune", "ward_lantern", "guest_invitation", "lamb"]

var main
var results: Array = []
var failures := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	while get_tree().current_scene == null or get_tree().current_scene.get("session") == null:
		await get_tree().process_frame
	main = get_tree().current_scene
	main.world.player_camera.toggle_overview()
	await get_tree().process_frame
	Engine.time_scale = 4.0
	await _run()
	var out := {"passed": failures == 0, "checks": results.size(), "failures": failures, "results": results}
	var f := FileAccess.open("res://art_sources/new-cards-verify.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t") + "\n")
	print("NEW_CARDS_VERIFY passed=", failures == 0, " checks=", results.size(), " failures=", failures)
	get_tree().quit(0 if failures == 0 else 1)


func check(name: String, ok: bool, detail := "") -> void:
	results.append({"check": name, "ok": ok, "detail": detail})
	if not ok:
		failures += 1
	print(("  PASS " if ok else "  FAIL ") + name + ("  — " + detail if detail != "" else ""))


func wait_until(cond: Callable, timeout := 60.0) -> bool:
	var t := 0.0
	while not cond.call():
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		if t > timeout:
			return false
	return true


func frames(n := 2) -> void:
	for i in n:
		await get_tree().physics_frame


## 준비 시간·손님 정산은 _process에서 돈다. time_scale이 크면 물리 프레임 여러 번이 한 프로세스 프레임에 몰리므로 따로 기다린다.
func pframes(n := 3) -> void:
	for i in n:
		await get_tree().process_frame


func sp(p: Vector3) -> Vector2:
	return main.world.camera.unproject_position(p)


func uid_of(id: String) -> int:
	for e in main.cards.entries:
		if e["id"] == id:
			return e["uid"]
	return -1


func next_day() -> void:
	main.session.wave_index += 1
	main.session._enter_prep()
	await frames(2)


func _run() -> void:
	var cards = main.cards
	var res = main.resolver
	var eco = main.economy
	var pasture = main.world.pasture
	var lodge = main.world.lodge
	var lodge_sp := sp(lodge.global_position + Vector3(0, 2.0, 0))
	var pasture_sp := sp(Vector3(pasture.rect.get_center().x, 0, pasture.rect.get_center().y))

	# ── 0. 카탈로그
	var ok_cat := true
	for id in NEW_IDS:
		ok_cat = ok_cat and cards.defs.has(id) and Catalog.texture(id, true) != null and Catalog.texture(id) != null
	check("카탈로그에 기존 신규 4종 + 텍스처 로딩", ok_cat, "defs=%d" % cards.defs.size())
	check("검증 실행에서는 시작 손패를 지급하지 않음", cards.entries.is_empty())
	for pair in Cfg.STARTER_CARDS:
		cards.add(pair[0], pair[1])
	check("설정된 시작 손패 지급", cards.hand().size() == Cfg.STARTER_CARDS.size())

	# ── 1. 숙박 초대장
	main.session.prep_elapsed = 8.0
	await frames(2)
	var inv := uid_of("guest_invitation")
	check("초대장: 산장 밖에 놓으면 거부", not res.evaluate(inv, pasture_sp)["ok"])
	var before_batches: int = eco.batches.size()
	var r: Dictionary = res.commit(inv, lodge_sp)
	check("초대장: 산장에 놓으면 손님 묶음 추가·카드 소비", r["ok"] and eco.batches.size() == before_batches + 1 and uid_of("guest_invitation") == -1, r.get("reason", ""))
	var invited: Dictionary = eco.batches.back()
	await pframes(3)
	check("초대 손님 즉시 도착(정원만큼)", invited["spawned"] and invited["count"] == eco.capacity,
		"count=%d arrive=%.1f prep_time=%.1f paused=%s dialogue=%s" % [invited["count"], invited["arrive"], eco.prep_time, get_tree().paused, main.guest_ui.dialogue_active if main.guest_ui != null else false])
	var gold0: int = eco.gold
	main.session.prep_elapsed = invited["pay"] + 0.3
	await pframes(3)
	var invited_offer := false
	for o in eco.offers:
		if is_instance_valid(o["guest"]) and o["guest"] in invited["guests"]:
			invited_offer = true
	check("초대 손님 숙박비 지급 + 고용 제안", invited["paid"] and eco.gold >= gold0 + invited["count"] * Cfg.GUEST_FEE and invited_offer, "gold %d→%d" % [gold0, eco.gold])
	cards.add("guest_invitation")
	main.session.prep_elapsed = Cfg.PREP_TIME - 10.0
	await frames(2)
	var late: Dictionary = res.evaluate(uid_of("guest_invitation"), lodge_sp)
	check("초대장: 준비 시간이 부족하면 거부(소비 없음)", not late["ok"] and uid_of("guest_invitation") != -1, late.get("reason", ""))
	cards.consume(uid_of("guest_invitation"))
	main.session.prep_elapsed = 40.0

	# ── 2. 새끼양
	var alive0: int = pasture.alive_count()
	var lamb_uid := uid_of("lamb")
	check("새끼양: 목장 밖에 놓으면 거부", not res.evaluate(lamb_uid, lodge_sp)["ok"])
	r = res.commit(lamb_uid, pasture_sp)
	check("새끼양: 목장에 놓으면 입식·카드 소비", r["ok"] and pasture.alive_count() == alive0 + 1 and pasture.lamb_count() == 1 and uid_of("lamb") == -1, r.get("reason", ""))
	var lamb = pasture.slots.back()
	var day0: int = main.session.day()
	check("새끼양: 작고 약함", lamb.is_lamb and lamb.max_hp == Cfg.LAMB_HP and lamb.visual.scale.x < 0.9, "hp=%d scale=%.2f" % [lamb.max_hp, lamb.visual.scale.x])
	await next_day()
	check("다음 날(+1일): 아직 새끼양·털 없음", lamb.is_lamb and not lamb.wool_ready, "day=%d" % main.session.day())
	await next_day()
	check("이틀 뒤(+2일): 어른 양으로 성장·털 수확 가능", not lamb.is_lamb and lamb.wool_ready and lamb.max_hp == Cfg.SHEEP_HP,
		"day %d→%d" % [day0, main.session.day()])
	main.session.wave_index = 0
	main.session._enter_prep()
	await frames(2)

	# ── 3. 서리 룬·수호 등불 (밤)
	var rune_uid := uid_of("frost_rune")
	check("서리 룬: 낮에는 거부", not res.evaluate(rune_uid, sp(Vector3(-1.0, 0, 6.0)))["ok"])
	var lantern_uid := uid_of("ward_lantern")
	r = res.commit(lantern_uid, sp(Vector3(-1.0, 0, 6.5)))
	check("등불: 낮에 지면 설치·카드 소비", r["ok"] and get_tree().get_nodes_in_group("ward_lanterns").size() == 1 and uid_of("ward_lantern") == -1, r.get("reason", ""))
	var lantern = get_tree().get_nodes_in_group("ward_lanterns")[0]
	check("등불: 시야 발생원 등록", lantern.is_in_group("sight_sources"))
	cards.add("ward_lantern")
	cards.add("ward_lantern")
	r = res.commit(uid_of("ward_lantern"), sp(Vector3(1.5, 0, 6.5)))
	var third: Dictionary = res.evaluate(uid_of("ward_lantern"), sp(Vector3(3.0, 0, 6.0)))
	check("등불: 동시 %d개 상한" % Cfg.LANTERN_LIMIT, r["ok"] and not third["ok"] and uid_of("ward_lantern") != -1, third.get("reason", ""))
	cards.consume(uid_of("ward_lantern"))

	main.session.start_wave()
	# 람다는 바깥 변수를 값으로 캡처하므로 배열에 담아 돌려받는다.
	var found: Array = []
	var got := await wait_until(func():
		for e in get_tree().get_nodes_in_group("enemies"):
			if not e.dead and lodge.distance_to(e.global_position) < 7.0:
				found.append(e)
				return true
		return false, 90.0)
	check("밤: 적이 산장 근처까지 접근", got)
	var near = found[0] if not found.is_empty() else null
	if near != null:
		var slowed_by_lantern := await wait_until(func(): return get_tree().get_nodes_in_group("enemies").any(func(e): return not e.dead and e.slow_factor() < 1.0), 40.0)
		check("등불: 빛 안의 적 감속", slowed_by_lantern)
		var hp0: float = near.hp
		var pos: Vector3 = near.global_position
		r = res.commit(rune_uid, sp(pos))
		await frames(2)
		check("서리 룬: 사용·카드 소비", r["ok"] and uid_of("frost_rune") == -1, r.get("reason", ""))
		check("서리 룬: 피해 + 감속", near.dead or (near.hp <= hp0 - Cfg.FROST_DAMAGE + 0.01 and near.slow_factor() <= Cfg.FROST_SLOW + 0.001),
			"hp %.0f→%.0f slow=%.2f" % [hp0, near.hp, near.slow_factor()])
	main.debug_kill_all()
	var cleared := await wait_until(func(): return main.session.state != SessionScript.State.COMBAT, 20.0)
	await frames(30)
	check("밤 전투 정리 후 등불 소등", cleared and get_tree().get_nodes_in_group("ward_lanterns").is_empty(),
		"state=%d paused=%s lanterns=%d" % [main.session.state, get_tree().paused, get_tree().get_nodes_in_group("ward_lanterns").size()])
