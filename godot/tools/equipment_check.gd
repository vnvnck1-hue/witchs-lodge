extends Node
## 장착 장비 v0 + 용병 초상 프레임 자동 검증(docs/equipment-and-party-frames-v01.md).
## 실제 게임 장면에서 장비 카드를 마녀·용병(월드·초상)에 끼우고, 수치(체력·피해·받는 피해·이동·회복),
## 같은 칸 교체·벗기기·용병 사망 시 반환, 초상 프레임 두 프리셋의 드롭 대상·칸 클릭을 확인한다.
## 결과: res://art_sources/equipment-verify.json

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")

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
	var f := FileAccess.open("res://art_sources/equipment-verify.json", FileAccess.WRITE)
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


func sp(p: Vector3) -> Vector2:
	return main.world.camera.unproject_position(p)


func give(id: String) -> int:
	# 손패 자리를 비워 두고 넣는다
	while main.cards.hand_full():
		var h: Array = main.cards.hand()
		main.cards.entries.erase(h[0])
	main.cards.add(id, 1, "", "hand")
	await frames(1)
	var best := -1
	for e in main.cards.entries:
		if e["id"] == id and e["zone"] == "hand":
			best = maxi(best, e["uid"])
	return best


func in_play(uid: int) -> bool:
	return main.cards.in_play.any(func(e): return e["uid"] == uid)


func zone_of(uid: int) -> String:
	var e: Dictionary = main.cards.get_entry(uid)
	return e.get("zone", "")


func _ally_sp(a) -> Vector2:
	return sp(a.global_position + Vector3(0, a.hp_offset * 0.5, 0))


func _run() -> void:
	var eq = main.equipment
	var res = main.resolver
	var cards = main.cards
	var p = main.player
	await frames(5)
	main.waves.set_process(false)

	# ── 1. 데이터
	check("장비 모듈이 붙어 있음", eq != null and main.get_node_or_null("Equipment") == eq)
	var all_ok := true
	for id in Cfg.EQUIPMENT:
		var d: Dictionary = cards.def(id)
		all_ok = all_ok and d.get("kind", "") == "equipment" and cards.phase_of(id) == "both" and Cfg.EQUIPMENT[id]["slot"] in Cfg.EQUIP_SLOTS
	check("시험 장비 5종: 카탈로그 kind=equipment · 낮밤 공용 · 칸 지정", all_ok and Cfg.EQUIPMENT.size() >= 5)

	# 용병 둘(마녀·산장과 떨어진 곳)
	var spot: Vector3 = Layout.DOOR_FRONT + Vector3(5, 0, 3)
	var w = main.contracts.spawn_guard("merc", "브람", spot, null, "warrior")
	var h = main.contracts.spawn_guard("merc", "올라프", spot + Vector3(2.0, 0, 0), null, "hunter")
	p.global_position = Layout.DOOR_FRONT + Vector3(-5, 0, 2)
	await frames(4)
	for a in [w, h]:
		a.set_physics_process(false)
	var psp: Vector2 = sp(p.global_position + Vector3(0, 1.0, 0))

	# ── 2. 마녀 전용 지팡이
	var staff: int = await give("oak_staff")
	var r: Dictionary = res.evaluate(staff, _ally_sp(w))
	check("참나무 지팡이를 용병에게 → 거부(마녀 전용)", not r["ok"] and str(r["reason"]).contains("마녀만"), str(r.get("reason", "")))
	r = res.evaluate(staff, psp)
	check("마녀에게 → 장착 판정(무기 칸)", r["ok"] and r["action"] == "equip" and r["holder"] == p, str(r.get("title", r.get("reason", ""))))
	r = res.commit(staff, psp)
	check("장착 확정: 마녀 무기 칸 · 카드는 활동 중(손패에서 빠짐)", r["ok"] and eq.equipped(p, "weapon").get("id", "") == "oak_staff" and in_play(staff) and cards.get_entry(staff).is_empty())
	check("마녀 마법탄 피해 배율 ×1.25", absf(eq.damage_mult(p) - 1.25) < 0.001, "%.2f" % eq.damage_mult(p))

	# ── 3. 누빈 솜옷: 최대 체력·받는 피해
	p.hp = p.max_hp - 30.0
	var hp0: float = p.hp
	var mhp0: float = p.max_hp
	var coat: int = await give("quilted_gambeson")
	res.commit(coat, psp)
	check("솜옷: 마녀 최대 체력 +15 · 현재 체력도 +15", absf(p.max_hp - (mhp0 + 15.0)) < 0.01 and absf(p.hp - (hp0 + 15.0)) < 0.01, "%.0f/%.0f" % [p.hp, p.max_hp])
	var before: float = p.hp
	p.take_damage(20.0)
	check("솜옷: 받는 피해 -15% (20 → 17)", absf((before - p.hp) - 17.0) < 0.01, "%.2f" % (before - p.hp))

	# ── 4. 같은 칸 교체: 이전 장비는 손패로
	var coat2: int = await give("quilted_gambeson")
	r = res.evaluate(coat2, psp)
	check("같은 칸에 또 놓으면 교체 안내", r["ok"] and str(r["lines"]).contains("손패로 돌아옵니다"))
	res.commit(coat2, psp)
	check("교체: 새 솜옷 착용 · 이전 솜옷은 같은 uid로 손패 · 최대 체력은 그대로", eq.equipped(p, "armor").get("uid", -1) == coat2 and zone_of(coat) == "hand" and absf(p.max_hp - (mhp0 + 15.0)) < 0.01, "zone=%s max=%.0f" % [zone_of(coat), p.max_hp])

	# ── 5. 용병 장비: 장검·장화·부적
	var sword: int = await give("rusty_longsword")
	r = res.evaluate(sword, psp)
	check("녹슨 장검을 마녀에게 → 거부(용병 전용)", not r["ok"] and str(r["reason"]).contains("용병만"), str(r.get("reason", "")))
	r = res.commit(sword, _ally_sp(w))
	check("장검을 전투용병(월드)에 장착 → 피해 ×1.3", r["ok"] and eq.equipped(w, "weapon").get("id", "") == "rusty_longsword" and absf(w._damage_mult() - 1.3) < 0.001, "%.2f" % w._damage_mult())
	var boots: int = await give("traveler_boots")
	res.commit(boots, _ally_sp(h))
	check("나그네 장화: 사냥꾼 이동 배율 ×1.15", absf(eq.speed_mult(h) - 1.15) < 0.001)
	var charm: int = await give("rowan_charm")
	res.commit(charm, _ally_sp(w))
	w.hp = w.max_hp - 10.0
	var whp: float = w.hp
	await get_tree().create_timer(1.0).timeout
	check("마가목 부적: 다친 용병이 초당 0.4 회복", w.hp > whp + 0.3 and w.hp < whp + 0.9, "%.2f → %.2f" % [whp, w.hp])

	# ── 6. 초상 메달(오른쪽 세로 줄): 드롭 대상·칸 클릭·스튜
	var pf = main.hud.party_frame
	check("HUD에 용병 초상 메달이 있음", pf != null)
	pf.queue_redraw()
	await frames(3)
	var view: Vector2 = pf.size
	var medals: Array = pf._hits.filter(func(x): return x.get("part", "") == "medal")
	check("용병마다 메달이 그려짐", medals.size() == 2, "hits=%d" % pf._hits.size())
	var on_right := medals.size() == 2
	for m in medals:
		var rc: Rect2 = m["rect"]
		on_right = on_right and rc.position.x > view.x * 0.85 and rc.end.x <= view.x
	check("메달은 화면 오른쪽 가장자리에 세로로 늘어섬", on_right and absf((medals[0]["rect"] as Rect2).position.x - (medals[1]["rect"] as Rect2).position.x) < 1.0 and (medals[1]["rect"] as Rect2).position.y > (medals[0]["rect"] as Rect2).end.y)
	var row: Dictionary = {}
	for hit in medals:
		if hit["holder"] == h:
			row = hit
	if not row.is_empty():
		var at: Vector2 = (row["rect"] as Rect2).get_center()
		check("메달 위 지점 → 그 용병", pf.holder_at(at) == h)
		r = res.evaluate(coat, at)
		check("솜옷 카드를 메달에 놓으면 그 용병에게 장착 판정", r["ok"] and r["holder"] == h, str(r.get("title", r.get("reason", ""))))
		var mh0: float = h.max_hp
		res.commit(coat, at)
		check("메달 드롭으로 장착: 사냥꾼 최대 체력 +15", eq.equipped(h, "armor").get("uid", -1) == coat and absf(h.max_hp - (mh0 + 15.0)) < 0.01)
	pf.queue_redraw()
	await frames(2)
	var slot_hit: Dictionary = {}
	for hit in pf._hits:
		if hit["holder"] == h and hit["slot"] == "trinket":
			slot_hit = hit
	check("메달 장비 점 3개 영역", not slot_hit.is_empty())
	if not slot_hit.is_empty():
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = true
		ev.position = (slot_hit["rect"] as Rect2).get_center()
		pf._input(ev)
		check("채워진 장비 점 클릭 → 장화를 벗겨 같은 uid로 손패", eq.equipped(h, "trinket").is_empty() and zone_of(boots) == "hand" and absf(eq.speed_mult(h) - 1.0) < 0.001)
	var witch_hit: Dictionary = {}
	for hit in pf._hits:
		if hit["holder"] == p and hit["slot"] == "":
			witch_hit = hit
	check("마녀 장비 3칸(상태판 옆) → 드롭 대상 마녀", not witch_hit.is_empty() and pf.holder_at((witch_hit["rect"] as Rect2).get_center()) == p)
	var medal: Dictionary = {}
	for hit in medals:
		if hit["holder"] == w:
			medal = hit
	if not medal.is_empty():
		w.hp = w.max_hp * 0.5
		var stew: int = await give("meat_stew")
		r = res.evaluate(stew, (medal["rect"] as Rect2).get_center())
		check("고기 스튜도 메달에 놓으면 그 용병 회복 판정", r["ok"] and r["ally"] == w, str(r.get("title", r.get("reason", ""))))
	# 메달·배지·이름표가 이웃 메달과 겹치지 않음(용병 5명), 지도 창과도 겹치지 않음
	var extra: Array = []
	for k in 3:
		var a2 = main.contracts.spawn_guard("merc", "검증%d" % k, spot + Vector3(-2.0 - k, 0, 0), null, "hunter")
		a2.set_physics_process(false)
		extra.append(a2)
	pf.queue_redraw()
	await frames(3)
	var owners: Array = pf.mercs()
	var clash := ""
	for x in pf._hits:
		for y in pf._hits:
			if x["holder"] != y["holder"] and x["holder"] != p and y["holder"] != p and (x["rect"] as Rect2).intersects(y["rect"]):
				clash = "%s ↔ %s" % [x["holder"].person, y["holder"].person]
	check("용병 5명: 메달·직업 배지·이름표가 이웃과 겹치지 않음", owners.size() == 5 and clash == "", clash)
	var lowest := 0.0
	for x in pf._hits:
		if x["holder"] != p:
			lowest = maxf(lowest, (x["rect"] as Rect2).end.y)
	check("다섯째 이름표가 화면 안(아래 산장 관리 버튼 위)", lowest < view.y * 0.86, "%.0f / %.0f" % [lowest, view.y])
	main.hud.set_map_visible(true)
	pf.queue_redraw()
	await frames(3)
	var map_rect: Rect2 = main.hud.map_window.get_global_rect()
	check("지도 창은 메달 줄과 겹치지 않는 왼쪽에 열림", not pf._hits.any(func(x): return x["holder"] != p and (x["rect"] as Rect2).intersects(map_rect)) and map_rect.position.x < view.x * 0.3, str(map_rect))
	main.hud.set_map_visible(false)
	for a2 in extra:
		a2.dismiss()
	await frames(2)

	# ── 8. 용병 사망 → 장비 반환
	var sword_in_play := in_play(sword)
	w.take_damage(9999.0)
	await frames(2)
	check("장비 낀 용병이 쓰러지면 장검·부적이 손패/주머니로 돌아옴", sword_in_play and not in_play(sword) and not in_play(charm) and zone_of(sword) != "" and zone_of(charm) != "", "sword=%s charm=%s" % [zone_of(sword), zone_of(charm)])
	pf.queue_redraw()
	await frames(2)
	check("쓰러진 용병은 프레임에서 빠짐", not pf._hits.any(func(x): return x["holder"] == w))

	# ── 9. 계약 해지 → 장비 반환
	var coat_on_h: int = eq.equipped(h, "armor").get("uid", -1)
	h.dismiss()
	await frames(2)
	check("계약 해지해도 장비는 돌아옴", coat_on_h != -1 and zone_of(coat_on_h) != "" and not in_play(coat_on_h))
