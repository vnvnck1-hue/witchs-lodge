extends SceneTree
## 달빛 마법 UI 실제 실행 검증(명세 §7-5·6). 실제 게임 장면을 띄워 상태를 바꾸고
## 표시 값·입력·시간 정지·배치를 확인하며 각 상태를 캡처한다. 게임 규칙은 기존 함수만 호출한다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/verify_moon_runtime.gd -- --out=<폴더>

const SessionScript := preload("res://scripts/game/game_session.gd")
const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/ui/moon/moon_layout.gd")

var failures: Array[String] = []
var records: Array = []
var game
var out_dir := ""


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_dir = a.trim_prefix("--out=").trim_suffix("/") + "/"
	create_timer(240.0, true, false, true).timeout.connect(func(): push_error("moon runtime check timed out"); quit(2))
	call_deferred("_run")


func check(ok: bool, msg: String) -> void:
	records.append({"check": msg, "ok": ok})
	if not ok:
		failures.append(msg)
		push_error("MOON_RT FAIL: " + msg)


func frames(n := 3) -> void:
	for i in n:
		await process_frame


func capture(id: String) -> void:
	if out_dir == "":
		return
	for i in 6:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out_dir + id + ".png")


func _new_game() -> void:
	if game != null:
		paused = false
		game.queue_free()
		await frames(2)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(30)
	for c in game.hud.toast_box.get_children():
		c.queue_free()


## 라벨 글자가 자기 영역 안에 들어가는지(숫자가 길어져도 초상·게이지를 침범하지 않음)
func fits(l: Label) -> bool:
	var f: Font = l.get_theme_font("font")
	var fs: int = l.get_theme_font_size("font_size")
	return f.get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x <= l.size.x + 0.5


func click(c: Control) -> void:
	var at := c.get_global_rect().get_center()
	# 실제 사용자처럼 먼저 마우스를 옮긴다(직전 버튼의 툴팁을 닫고 hover를 갱신)
	var mv := InputEventMouseMotion.new()
	mv.position = at
	mv.global_position = at
	root.push_input(mv, true)
	await frames(3)
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = pressed
		ev.position = at
		ev.global_position = at
		root.push_input(ev, true)
		await frames(2)


func _run() -> void:
	await _new_game()
	var m = game.hud.moon
	var hand = game.hud.card_hand
	var eco = game.economy
	var view: Vector2 = root.get_visible_rect().size

	# ── 기본 HUD: 실제 값
	await frames(5)
	check(m.player_val.text == "100/100" and m.lodge_val.text == "300/300", "base hp labels %s %s" % [m.player_val.text, m.lodge_val.text])
	check(m.gold_val.text == str(eco.gold) and m.timber_val.text == "0" and m.wool_val.text == "0", "base resources %s/%s/%s" % [m.gold_val.text, m.timber_val.text, m.wool_val.text])
	check(m.phase_title.text == "1일차 · 낮", "phase title " + m.phase_title.text)
	check(m.phase_sub.text.begins_with("밤까지 "), "phase sub " + m.phase_sub.text)
	check(m.objective_text.text.begins_with("◆ "), "objective " + m.objective_text.text)
	check(not game.hud.map_window.visible, "map collapsed by default")
	check(hand.empty_hint.visible, "empty hand hint")
	await capture("01-base")

	# ── HP 감소/회복 (같은 프레임 반영)
	game.player.take_damage(25.0)
	game.world.lodge.take_damage(50.0)
	m.refresh(true)
	check(m.player_val.text == "75/100" and is_equal_approx(m.player_gauge.value, 0.75), "player damage " + m.player_val.text)
	check(m.lodge_val.text == "250/300" and is_equal_approx(m.lodge_gauge.value, 250.0 / 300.0), "lodge damage " + m.lodge_val.text)
	await capture("02-hp-damaged")
	eco.debug_add_gold(100)
	check(eco.buy("heal") and eco.buy("repair"), "heal/repair purchase")
	m.refresh(true)
	check(m.player_val.text == "100/100" and m.lodge_val.text == "300/300", "heal/repair labels %s %s" % [m.player_val.text, m.lodge_val.text])
	check(m.gold_val.text == str(eco.gold), "gold after purchase same frame")

	# ── 자원 0/다자리
	eco.debug_add_gold(99999 - eco.gold)
	game.cards.add("timber", 12345)
	game.cards.add("wool", 4)
	m.refresh(true)
	check(m.gold_val.text == "99999" and m.timber_val.text == "12345" and m.wool_val.text == "4", "big resources %s %s %s" % [m.gold_val.text, m.timber_val.text, m.wool_val.text])
	check(fits(m.gold_val) and fits(m.timber_val) and fits(m.wool_val) and fits(m.player_val), "five-digit labels fit their area")
	await capture("03-resources-big")

	# ── 양털 판매: 판매 후 같은 프레임에 골드·양털 수치 일치
	var wool_uid := -1
	for e in game.cards.hand():
		if e["id"] == "wool":
			wool_uid = e["uid"]
	hand.open_sale(wool_uid)
	check(paused and hand.sale_panel.visible, "sale opens and pauses in PREP")
	await capture("04-sale")
	var g0: int = eco.gold
	hand._set_qty(3)
	hand._confirm_sale()
	m.refresh(true)
	check(eco.gold == g0 + 3 * Cfg.WOOL_PRICE and m.wool_val.text == "1" and m.gold_val.text == str(eco.gold), "wool sale updates gold %s wool %s" % [m.gold_val.text, m.wool_val.text])
	check(not paused, "sale close restores time")
	# 남은 자원 정리
	for e in game.cards.entries.duplicate():
		game.cards.consume(e["uid"], int(e["count"]))
	eco.gold = 40
	await frames(3)

	# ── 손패 1/4/8장, 배치·확대
	for n in [1, 4, 8]:
		for e in game.cards.entries.duplicate():
			game.cards.consume(e["uid"], int(e["count"]))
		var ids := ["lumberjack", "wool", "timber", "guest_invitation"]
		for i in n:
			var id: String = ids[i % 4] if n <= 4 else ["lumberjack", "guest_invitation"][i % 2]
			game.cards.add(id, 2 if id in ["wool", "timber"] else 1, eco._pick_name() if id == "lumberjack" else "")
		await frames(40)
		check(hand.views.size() == n, "hand shows %d cards (got %d)" % [n, hand.views.size()])
		var storage_rect: Rect2 = m.storage_btn.get_global_rect()
		var actions_rect: Rect2 = m.lodge_btn.get_global_rect().merge(m.dragon_btn.get_global_rect())
		for v in hand.views.values():
			var r: Rect2 = v.get_global_rect()
			check(Rect2(Vector2.ZERO, view).encloses(r), "card inside view (%d cards)" % n)
			check(not r.intersects(storage_rect) and not r.intersects(actions_rect), "card clear of storage/actions (%d cards)" % n)
		await capture("05-hand-%d" % n)
	# 확대: 가장 오른쪽 카드
	var last_uid: int = game.cards.hand()[-1]["uid"]
	# 카드가 차례로 등장(REVEAL)하므로 마지막 카드가 손패 자리를 잡을 때까지 기다린 뒤 올린다
	var settle := 0
	while not hand.rest.has(last_uid) and settle < 400:
		await frames(1)
		settle += 1
	hand.set_hover(last_uid, true)
	await frames(40)
	var hv = hand.views[last_uid]
	# 확대는 스프링 연출로 배율을 살짝 넘겼다 돌아오므로 위치·배율이 멈출 때까지 기다린다
	settle = 0
	var prev_pos: Vector2 = hv.position
	while settle < 300:
		await frames(1)
		settle += 1
		var moving: bool = hv.position.distance_to(prev_pos) > 0.05 or absf(hv.scale.x - hand.HOVER_SCALE) > 0.003
		prev_pos = hv.position
		if not moving:
			break
	var hr := Rect2(hv.position + hv.size * (Vector2.ONE - hv.scale) * Vector2(0.5, 1.0), hv.size * hv.scale)
	check(Rect2(Vector2.ZERO, view).encloses(hr), "hovered card not clipped")
	check(hand.tooltip.visible and Rect2(Vector2.ZERO, view).encloses(hand.tooltip.get_global_rect()), "card tooltip visible inside view")
	await capture("06-hand-hover")
	hand.set_hover(last_uid, false)

	# 9번째 카드 → 창고, 배지 갱신 / 손패 가득 시 꺼내기 거부
	game.cards.add("guest_invitation")
	m.refresh(true)
	check(game.cards.storage().size() == 1 and m.storage_badge.visible and m.storage_count.text == "1", "storage badge shows overflow")
	await click(m.storage_btn)
	check(hand.pocket_panel.visible and paused, "storage button opens storage (paused in PREP)")
	check(game.cards.draw_uid(game.cards.storage()[0]["uid"]).is_empty(), "full hand refuses draw")
	await capture("07-storage")
	hand.close_pocket()
	check(not paused, "storage close restores time")

	# ── 드래그: 유효 대상 / 불가 대상 / 취소
	for e in game.cards.entries.duplicate():
		game.cards.consume(e["uid"], int(e["count"]))
	game.cards.add("lumberjack", 1, eco._pick_name())
	game.cards.add("timber", 5)
	await frames(30)
	var merc_uid: int = game.cards.hand()[0]["uid"]
	var timber_uid: int = game.cards.hand()[1]["uid"]
	hand.begin_drag(merc_uid)
	var tree_pos: Vector2 = game.world.camera.unproject_position(game.world.harvest_trees[0]["pos"] + Vector3(0, 1.6, 0))
	for i in 20:
		hand.drag_pos = tree_pos
		await process_frame
	check(hand.preview.visible and hand.plan.get("ok", false), "drag merc over tree: valid preview")
	await capture("08-drag-valid")
	var rc := InputEventMouseButton.new()
	rc.button_index = MOUSE_BUTTON_RIGHT
	rc.pressed = true
	hand._input(rc)
	check(hand.drag_uid == -1 and game.cards.get_entry(merc_uid).size() > 0, "right-click cancels drag without consuming")
	hand.begin_drag(timber_uid)
	var ground: Vector2 = game.world.camera.unproject_position(Vector3(6, 0, 6))
	for i in 20:
		hand.drag_pos = ground
		await process_frame
	check(hand.preview.visible and not hand.plan.get("ok", true), "timber on ground: invalid preview")
	await capture("09-drag-invalid")
	hand._cancel_drag()

	# ── 관리창: 시간 정지/복원, 실제 가격
	await click(m.lodge_btn)
	check(game.hud.lodge_panel.visible and paused, "lodge button opens panel and pauses")
	check(game.hud.shop_rows["repair"]["button"].text == "%dG" % eco.cost_of("repair"), "shop shows real price")
	await capture("10-lodge-panel")
	game.hud.close_lodge_panel()
	check(not paused, "lodge close restores time")

	# ── 일시 정지 버튼(클릭 입력) / 재개 / 지도
	await click(m.pause_btn)
	check(game.hud.pause_panel.visible and paused, "pause button click opens pause")
	game.hud._toggle_section(game.hud.pause_settings)
	await capture("11-pause-settings")
	game.hud._toggle_section(game.hud.pause_settings)
	game.hud._open_map_from_pause()
	check(not paused and not game.hud.pause_panel.visible, "map from pause resumes game")
	await frames(3)
	var mw: Rect2 = game.hud.map_window.get_global_rect()
	var s := Layout.ui_scale(view)
	var center := Rect2(Layout.to_view(Layout.CENTER_CLEAR.position, Vector2(0.5, 0.5), view), Layout.CENTER_CLEAR.size * s)
	check(game.hud.map_window.visible and Rect2(Vector2.ZERO, view).encloses(mw) and not mw.intersects(center), "map window inside view and outside center")
	await capture("12-map")
	game.hud.set_map_visible(false)

	# ── 낮 → 밤: 공물 비활성/활성/연속 클릭
	check(m.dragon_btn.disabled, "dragon disabled in PREP")
	game.debug_start_wave()
	await frames(10)
	check(m.phase_title.text == "1일차 밤 / %d" % game.session.total_days() and m.phase_sub.text.begins_with("남은 적"), "combat phase " + m.phase_title.text)
	check(m.objective_text.text == "◆ 괴물에게서 산장을 지키세요", "combat objective " + m.objective_text.text)
	check(m.lodge_btn.disabled, "lodge disabled at night")
	var prep_before: float = game.session.prep_elapsed
	await frames(20)
	check(game.session.prep_elapsed == prep_before, "prep countdown frozen at night")
	eco.gold = 40
	m.refresh(true)
	check(m.dragon_btn.disabled, "dragon disabled when gold short")
	await capture("13-combat-dragon-disabled")
	eco.gold = 300
	m.refresh(true)
	check(not m.dragon_btn.disabled, "dragon enabled in combat with gold")
	await capture("14-combat-dragon-active")
	await click(m.dragon_btn)
	await click(m.dragon_btn)
	check(eco.gold == 300 - Cfg.COST_DRAGON, "double click charges once (gold %d)" % eco.gold)
	m.refresh(true)
	check(m.dragon_btn.disabled, "dragon disabled after summon")
	# 전투 중 창고: 시간 정지하지 않음
	hand.open_pocket()
	check(not paused, "combat storage does not pause")
	hand.close_pocket()
	# 출현 대기 무리까지 모두 나올 때까지 처치(웨이브 1 마지막 무리는 8초 뒤 출현)
	Engine.time_scale = 4.0
	for i in 900:
		game.debug_kill_all()
		await process_frame
		if game.session.state == SessionScript.State.CLEARING:
			break
	Engine.time_scale = 1.0
	m.refresh(true)
	check(game.session.state == SessionScript.State.CLEARING and m.phase_title.text == "1일차 밤 정리", "clearing phase " + m.phase_title.text)
	await capture("15-clearing")

	# ── 패배: HP 0
	game.player.take_damage(9999.0)
	await frames(3)
	m.refresh(true)
	check(m.player_val.text == "0/100" and m.player_gauge.value == 0.0, "hp zero label " + m.player_val.text)
	check(game.hud.end_panel.visible and m.phase_title.text == "게임 오버", "defeat result")
	await capture("16-defeat")

	# ── 승리 (새 게임)
	await _new_game()
	m = game.hud.moon
	game.session.wave_index = game.session.total_days()
	game.session.state = SessionScript.State.CLEARING
	game.session._after_clear()
	await frames(5)
	m.refresh(true)
	check(game.hud.end_panel.visible and m.phase_title.text == "챕터 1 완료", "victory result")
	await capture("17-victory")

	# ── 1920×1080
	await _new_game()
	m = game.hud.moon
	get_root().size = Vector2i(1920, 1080)
	await frames(10)
	var v2: Vector2 = root.get_visible_rect().size
	for id in m.groups:
		var gr: Rect2 = m.groups[id].get_global_rect()
		check(Rect2(Vector2.ZERO, v2).grow(1.0).encloses(gr), "group %s inside 1920x1080" % id)
	await capture("18-1920x1080")

	var report := {"passed": failures.is_empty(), "failures": failures, "checks": records.size(), "records": records}
	if out_dir != "":
		var f := FileAccess.open(out_dir + "moon-runtime-verification.json", FileAccess.WRITE)
		f.store_string(JSON.stringify(report, "\t"))
	print("MOON_RT ", JSON.stringify({"passed": report["passed"], "checks": records.size(), "failures": failures}))
	quit(0 if failures.is_empty() else 1)
