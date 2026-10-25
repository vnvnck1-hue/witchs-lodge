extends SceneTree
## 용병 관리 창·메달 툴팁 종족 줄 검증(사용자 요청 2026-10-24).
## 메달 줄이 꽉 차면 "+N" 원이 클릭 영역이 되고, 누르면 용병 관리 창이 열려 전원이 한 줄씩 보인다.
## 메달 툴팁에는 종족 줄이 나온다. 창은 시간을 멈추고 Esc·닫기·바깥 클릭으로 닫힌다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_merc_panel.gd

const Layout := preload("res://scripts/world/layout.gd")
const Races := preload("res://scripts/game/races.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")

var game
var failures := 0
var total := 0


func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func frames(n := 2) -> void:
	for i in n:
		await process_frame


func _hit_part(pf, part: String) -> Dictionary:
	for h in pf._hits:
		if h.get("part", "") == part:
			return h
	return {}


func _hit_of(pf, holder) -> Dictionary:
	for h in pf._hits:
		if h["holder"] == holder and h.get("part", "") == "medal":
			return h
	return {}


func _click(at: Vector2) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	ev.position = at
	ev.global_position = at
	root.push_input(ev, true)


func _run() -> void:
	root.size = Vector2i(1600, 900)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(8)
	game.session.set_process(false)
	game.economy.set_process(false)
	game.waves.set_process(false)
	var hud = game.hud
	var pf = hud.party_frame
	check("용병 관리 창 노드 있음", hud.merc_panel != null and hud.merc_list != null)
	check("처음엔 닫혀 있음", not hud.merc_panel.visible)

	# 종족이 섞인 용병 8명 — 메달 줄(최대 5칸)을 넘긴다
	var people := ["브람", "토르그림", "파르그", "티슬", "올라프", "사야", "우르소", "모미"]
	var base: Vector3 = Layout.DOOR_FRONT + Vector3(2.5, 0, 2.0)
	var allies: Array = []
	for i in people.size():
		var a = game.contracts.spawn_guard("merc", people[i], base + Vector3(i * 1.1, 0, 0), null, "warrior")
		a.set_physics_process(false)
		allies.append(a)
	await frames(6)
	var n: int = pf.mercs().size()
	check("용병 8명 활동 중", n == 8, str(n))
	check("메달은 일부만 그려짐", pf.shown_count > 0 and pf.shown_count < n, "shown=%d" % pf.shown_count)
	var more := _hit_part(pf, "more")
	check("\"+N\" 원이 클릭 영역으로 등록", not more.is_empty())
	check("\"+N\" 위는 장비 드롭 대상이 아님", more.is_empty() or pf.holder_at((more["rect"] as Rect2).get_center()) == null)

	# "+N"에 올리면 안내 툴팁
	if not more.is_empty():
		pf.hover_override = (more["rect"] as Rect2).get_center()
		await frames(3)
		var t: Array = pf.last_tooltip
		check("\"+N\" 툴팁 — 남은 인원·클릭 안내", t.size() >= 2 and ("%d명 더" % (n - pf.shown_count)) in str(t[0][0]) and "용병 관리" in str(t[1][0]), str(t))
		pf.hover_override = Vector2(-1, -1)

	# 메달 툴팁 종족 줄
	var first = allies[0]
	var mh := _hit_of(pf, first)
	check("첫 메달 영역 있음", not mh.is_empty())
	if not mh.is_empty():
		pf.hover_override = (mh["rect"] as Rect2).get_center()
		await frames(3)
		var race_name := Races.name_of(GuestProfiles.race_of(first.person))
		var found := false
		for l in pf.last_tooltip:
			if str(l[0]) == "종족 — " + race_name:
				found = true
		check("메달 툴팁에 종족 줄(%s · %s)" % [first.person, race_name], found, str(pf.last_tooltip))
		pf.hover_override = Vector2(-1, -1)
	for a in allies:
		var hit := _hit_of(pf, a)
		if hit.is_empty():
			continue
		pf.hover_override = (hit["rect"] as Rect2).get_center()
		await frames(2)
		var want := "종족 — " + Races.name_of(GuestProfiles.race_of(a.person))
		var ok := false
		for l in pf.last_tooltip:
			ok = ok or str(l[0]) == want
		check("툴팁 종족 %s → %s" % [a.person, want], ok)
	pf.hover_override = Vector2(-1, -1)

	# "+N" 클릭 → 용병 관리 창
	if not more.is_empty():
		_click((more["rect"] as Rect2).get_center())
		await frames(3)
	check("\"+N\" 클릭으로 용병 관리 창 열림", hud.merc_panel.visible)
	check("창이 열린 동안 시간 정지", paused)
	await frames(2)
	var rows: Array = hud.merc_list.rows
	check("창에 용병 전원(8줄)", rows.size() == 8, str(rows.size()))
	var shown_people: Array = []
	for r in rows:
		shown_people.append(r["ally"].person)
	var hidden_ok := true
	for i in range(pf.shown_count, n):
		hidden_ok = hidden_ok and pf.mercs()[i].person in shown_people
	check("메달 줄에서 접힌 용병도 창에 있음", hidden_ok, str(shown_people))
	# 각 줄에 종족 표기
	var race_ok := true
	for r in rows:
		var want := "종족 " + Races.name_of(GuestProfiles.race_of(r["ally"].person))
		var row_has := false
		for l in r["medal"].get_parent().find_children("*", "Label", true, false):
			row_has = row_has or (l as Label).text == want
		race_ok = race_ok and row_has
	check("창의 줄마다 종족 표기", race_ok)
	check("창의 체력 글자 갱신", "체력" in rows[0]["hp"].text, rows[0]["hp"].text)

	# 용병이 쓰러지면 줄이 줄어든다
	allies[7].dead = true
	await frames(3)
	check("쓰러진 용병은 창에서 빠짐", hud.merc_list.rows.size() == 7, str(hud.merc_list.rows.size()))

	# Esc 로 닫기
	var esc := InputEventKey.new()
	esc.keycode = KEY_ESCAPE
	esc.pressed = true
	root.push_input(esc)
	await frames(3)
	check("Esc 로 닫힘", not hud.merc_panel.visible)
	check("닫으면 시간 다시 흐름", not paused)
	# 다시 열고 닫기 버튼 경로
	hud.open_merc_panel()
	await frames(2)
	check("다시 열림(open_merc_panel)", hud.merc_panel.visible)
	hud.dismiss_top_modal()
	await frames(2)
	check("바깥 클릭(dismiss_top_modal)으로 닫힘", not hud.merc_panel.visible)

	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
