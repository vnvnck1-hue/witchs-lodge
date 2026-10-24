extends Node
## 떠돌이 행상 브로크·상점 자동 검증(docs/merchant-shop-v01.md). 실제 게임 장면에서
## 방문 요일(3일마다)·시각(낮 한가운데)·혼자 방문, 좌판 5장의 무작위성과 인물 카드 제외, 가치에 따른 가격,
## 도착 → 자동 상점 열림 → 구매·골드 부족 → 말풍선으로 다시 열기 → 밤에 떠남, 장날 대체를 확인한다.
## 결과: res://art_sources/merchant-verify.json

const Cfg := preload("res://scripts/config.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")
const ChapterData := preload("res://scripts/game/chapter_data.gd")
const Data := preload("res://scripts/game/merchant_data.gd")
const MerchantScript := preload("res://scripts/game/merchant.gd")

var main
var results: Array = []
var failures := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	while get_tree().current_scene == null or get_tree().current_scene.get("session") == null:
		await get_tree().process_frame
	main = get_tree().current_scene
	await get_tree().process_frame
	await _run()
	var out := {"passed": failures == 0, "checks": results.size(), "failures": failures, "results": results}
	var f := FileAccess.open("res://art_sources/merchant-verify.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t") + "\n")
	print("RESULT %d/%d" % [results.size() - failures, results.size()])
	get_tree().quit(0 if failures == 0 else 1)


func check(name: String, ok: bool, detail := "") -> void:
	results.append({"check": name, "ok": ok, "detail": detail})
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func frames(n := 2) -> void:
	for i in n:
		await get_tree().process_frame


## 낮(준비 시간)의 day 일차, prep_elapsed 초로 맞춘다. 정해진 손님 묶음은 비워 행상만 본다.
func set_day(day: int, t: float) -> void:
	var s = main.session
	s.wave_index = day - 1
	s.state = SessionScript.State.PREP
	s.prep_elapsed = t
	main.economy.batches.clear()
	main.economy.prep_time = t


func hold_clock(t: float) -> void:
	main.session.prep_elapsed = t


func merchant_visits() -> Array:
	return main.guest_events.visits.filter(func(e): return e.profile.get("merchant", false))


func _run() -> void:
	var m = main.merchant
	var defs: Dictionary = main.cards.defs
	await frames(5)
	main.waves.set_process(false)
	if main.get_tree().paused:
		main.get_tree().paused = false

	# ── 1. 인물·방문 규칙
	var brock := GuestProfiles.character(Data.CHARACTER_ID)
	check("브로크 프로필: 오소리 수인 떠돌이 행상·고용 불가", not brock.is_empty() and brock["race"] == "beastfolk" and brock["role"] == "떠돌이 행상" and not brock["hireable"])
	check("브로크는 무작위 손님 명부(CATALOG)에 없음", GuestProfiles.CATALOG.all(func(c): return c["id"] != Data.CHARACTER_ID))
	var visit_days: Array = range(1, 13).filter(func(d): return Data.is_visit_day(d))
	check("3일마다 방문: 3·6·9·12일차", visit_days == [3, 6, 9, 12], str(visit_days))
	check("낮 한가운데 도착(준비 시간의 절반)", is_equal_approx(Data.ARRIVE_AT, Cfg.PREP_TIME * 0.5), "%.1f초 / %.1f초" % [Data.ARRIVE_AT, Cfg.PREP_TIME])
	check("기존 장날 플래그 제거(행상이 대신함)", range(1, 13).all(func(d): return not ChapterData.day_cfg(d).get("market", false)))

	# ── 2. 상품 풀·가격
	var pool: Array = Data.pool(defs)
	var persons: Array = pool.filter(func(id): return id in Cfg.JOB_CARDS or str(defs[id].get("category", "")).begins_with("인물"))
	check("상품 풀에 인물 카드 없음(용병 계약 4종·주점 손님 에린)", persons.is_empty() and not "drunken_erin" in pool and Cfg.JOB_CARDS.all(func(id): return not id in pool), str(persons))
	check("침식·내부·이야기 전용 카드 제외", pool.all(func(id): return defs[id].get("kind", "") != "corruption" and not id in Data.EXCLUDED_IDS))
	check("상품 풀이 충분함(5장보다 훨씬 많음)", pool.size() >= 40, "%d종" % pool.size())
	var bad_price: Array = pool.filter(func(id): return Data.price_of(id, defs[id]) <= 0)
	check("모든 상품에 가격", bad_price.is_empty(), str(bad_price))
	var resale: Array = pool.filter(func(id): return Data.price_of(id, defs[id]) < int(Cfg.SALE_PRICES.get(id, 0)) * 2)
	check("되팔기 이득 없음(판매가의 2배 이상)", resale.is_empty(), str(resale))
	var p := func(id): return Data.price_of(id, defs[id])
	check("가치 순서: 유물 > 주문 > 재화", p.call("moonlit_charm") > p.call("frost_rune") and p.call("frost_rune") > p.call("timber"),
		"유물 %d · 서리 룬 %d · 목재 %d" % [p.call("moonlit_charm"), p.call("frost_rune"), p.call("timber")])
	check("예전 장날 가격을 이어받음", p.call("treasure_chest") == 45 and p.call("old_spellbook") == 30 and p.call("moss_bandage") == 15)
	check("등급 구간: 흔함 → 진귀함", Data.grade_of(10)["name"] == "흔한 물건" and Data.grade_of(20)["name"] == "쓸 만한 물건"
		and Data.grade_of(30)["name"] == "귀한 물건" and Data.grade_of(55)["name"] == "진귀한 물건")
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var seen := {}
	var all_ok := true
	var first: Array = []
	for i in 300:
		var roll: Array = Data.roll_offers(defs, rng)
		var ids: Array = roll.map(func(o): return o["id"])
		if i == 0:
			first = ids
		var uniq := {}
		for id in ids:
			uniq[id] = true
			seen[id] = true
		all_ok = all_ok and roll.size() == 5 and uniq.size() == 5 and ids.all(func(id): return id in pool)
		all_ok = all_ok and roll.all(func(o): return int(o["price"]) == Data.price_of(o["id"], defs[o["id"]]) and not o["sold"])
	check("좌판 5장: 서로 다른 카드·풀 안·가격 일치(300회)", all_ok)
	check("무작위: 300회에 풀의 대부분이 등장", seen.size() >= int(pool.size() * 0.9), "%d / %d종" % [seen.size(), pool.size()])

	# ── 3. 방문 시각·혼자 방문
	set_day(2, 50.0)
	await frames(3)
	check("2일차에는 오지 않음", not m.present())
	set_day(3, 40.0)
	await frames(3)
	check("3일차 낮 40초에는 아직 오지 않음", not m.present())
	var guests_before: int = main.economy.guests.size()
	var visits_before: int = main.guest_events.visits.size()
	set_day(3, Data.ARRIVE_AT + 0.2)
	await frames(3)
	check("3일차 낮 한가운데 도착", m.present() and m.visited_day == 3)
	check("혼자 방문: 손님 기록 1명 추가·숙박 손님 묶음은 그대로",
		main.guest_events.visits.size() == visits_before + 1 and main.economy.guests.size() == guests_before)
	var mv: Array = merchant_visits()
	check("손님 기록에 브로크(행상) 등록", mv.size() == 1 and mv[0].profile.person == "브로크")
	check("좌판 5장 준비", m.offers.size() == Data.OFFER_COUNT)
	check("길 끝이 좌판 자리", m.actor.route.size() > 0 and m.actor.route.back().is_equal_approx(MerchantScript.STALL_SPOT))
	check("도착 알림 문구가 행상 전용", main.guest_arrival.notice.get_node("Count").text.contains("행상"), main.guest_arrival.notice.get_node("Count").text)
	set_day(3, Data.ARRIVE_AT + 0.4)
	await frames(2)
	check("같은 날 두 번 오지 않음", merchant_visits().size() == 1)

	# 소개 연출이 끝나 입실할 때까지(최대 15초) 기다린다. 걸음은 좌판 자리로 바로 옮긴다
	m.actor.position = MerchantScript.STALL_SPOT
	m.actor.route.clear()
	var waited := 0.0
	while not m.admitted and waited < 15.0:
		hold_clock(Data.ARRIVE_AT + 1.0)
		await get_tree().create_timer(0.1).timeout
		waited += 0.1
	check("도착 소개 후 입실", m.admitted, "%.1f초" % waited)
	await frames(3)
	var ui = main.offer_ui
	check("좌판 자리에 서면 상점이 자동으로 열림", ui.active and ui.merchant_mode and ui.mode == "market")
	check("상점 화면: 카드 5장·가격표·등급", ui.buttons.size() == 5 and ui.buttons.all(func(b): return b.has("price_label") and b.has("grade_label")))
	var tags_ok := true
	var tags: Array = []
	for i in 5:
		tags.append(ui.buttons[i]["price_label"].text)
		tags_ok = tags_ok and ui.buttons[i]["price_label"].text == "%dG" % int(m.offers[i]["price"])
	check("가격표 글자 = 가격", tags_ok, str(tags))
	check("행상 장식(간판·좌판·초상) 표시", ui.deco != null and ui.deco.get_child_count() >= 5)
	check("상점이 열린 동안 게임 정지", main.get_tree().paused)
	check("제목에 행상 이름", ui.title.text.contains("브로크"), ui.title.text)
	var vp: Vector2 = ui.stage.get_viewport_rect().size
	var inside := true
	for b in ui.buttons:
		var r: Rect2 = b["btn"].get_global_rect()
		inside = inside and r.position.x >= 0 and r.end.x <= vp.x and r.position.y >= 0 and r.end.y <= vp.y
	check("카드 5장이 화면 안", inside, str(vp))

	# ── 4. 구매
	main.economy.gold = 1000
	var o0: Dictionary = m.offers[0]
	var before: int = main.cards.count_of(o0["id"])
	var gold0: int = main.economy.gold
	var bought: bool = ui.buy(0)
	check("구매: 카드 획득·가격만큼 골드 차감", bought and main.cards.count_of(o0["id"]) == before + 1 and main.economy.gold == gold0 - int(o0["price"]),
		"%s %dG" % [o0["id"], int(o0["price"])])
	check("팔린 칸 표시", o0["sold"] and ui.buttons[0]["price_label"].text == "팔림" and ui.buttons[0]["btn"].disabled)
	check("같은 칸 두 번 못 삼", not ui.buy(0) and main.cards.count_of(o0["id"]) == before + 1)
	check("행상 구매 기록", m.stats["bought"] == 1 and m.stats["spent"] == int(o0["price"]))
	main.economy.gold = 0
	var o1: Dictionary = m.offers[1]
	var before1: int = main.cards.count_of(o1["id"])
	check("골드가 모자라면 못 삼", not ui.buy(1) and main.cards.count_of(o1["id"]) == before1 and not o1["sold"])
	ui.close()
	await frames(2)
	check("닫으면 게임 재개·행상은 남음", not ui.active and not main.get_tree().paused and m.present())

	# ── 5. 다시 열기(말풍선·손님 탭)
	var entry: Dictionary = mv[0]
	check("좌판 말풍선 대기(상점 다시 열기)", entry in main.guest_events.pending_events() and entry.story.get("special", "") == "merchant")
	main.guest_ui.open_conversation(int(entry.uid), true)
	await frames(2)
	check("말풍선/손님 탭 → 같은 좌판 다시 열림", ui.active and ui.merchant_mode and ui.offers == m.offers and m.offers[0]["sold"])
	check("대화 창은 열리지 않음", not main.guest_ui.dialogue_active)
	ui.close()
	await frames(2)
	# 다른 손님 이야기가 있으면 행상 말풍선은 뒤로
	var fake := {"uid": 99999, "profile": {"person": "시험", "character_id": "bram", "portrait": brock["portrait"]}, "present": true,
		"admitted": true, "ready": true, "read": false, "story": {"prompt": "?", "title": "?"}}
	main.guest_events.visits.append(fake)
	var pend: Array = main.guest_events.pending_events()
	check("손님 이야기 말풍선이 행상 좌판보다 먼저", pend.size() >= 2 and pend[0] == fake and pend.back() == entry)
	main.guest_events.visits.erase(fake)

	# ── 6. 밤이 되면 떠남
	var actor = m.actor
	main.session.start_wave()
	await frames(3)
	check("밤이 되면 떠남", not m.present() and not entry.present)
	check("행상 액터 정리", actor == null or not is_instance_valid(actor) or actor.is_queued_for_deletion() or actor.leaving)
	main.session.state = SessionScript.State.PREP
	check("밤에는 상점을 열 수 없음", m.shop_block_reason() != "")

	# ── 7. 다음 방문(6일차): 새 좌판
	var old_offers: Array = m.offers.duplicate(true)
	set_day(6, Data.ARRIVE_AT + 0.2)
	await frames(3)
	check("6일차에 다시 찾아옴", m.present() and m.visited_day == 6 and merchant_visits().size() == 2)
	check("새 좌판(모두 안 팔린 상태)", m.offers.size() == 5 and m.offers.all(func(o): return not o["sold"]))
	check("방문마다 인사가 바뀜", m.profile["line"] == GuestProfiles.greeting(brock, 1), m.profile["line"])
	m.leave("검증 정리")
	if ui.active:
		ui.close()
	await frames(2)
	print("첫 좌판 예: ", first, "  이전 좌판: ", old_offers.map(func(o): return "%s %dG" % [o["id"], o["price"]]))
