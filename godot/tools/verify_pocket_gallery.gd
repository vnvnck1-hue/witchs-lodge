extends SceneTree
## 마녀의 주머니 갤러리 검증: 카드가 넓게(한 줄에 여러 장) 펼쳐지는지, 마우스를 올린 카드가 들어 올려져 커지고
## 나머지가 어두워지는지, 툴팁이 올린 카드 옆·화면 안에 놓이는지, 해제·닫기 뒤 상태가 돌아오는지.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_pocket_gallery.gd

var results: Array = []
var failures := 0
var game
var hand
var gal


func _initialize() -> void:
	create_timer(90.0, true, false, true).timeout.connect(func():
		print("FAIL 시간 초과")
		quit(1))
	change_scene_to_file("res://scenes/main.tscn")
	call_deferred("_run")


func check(name: String, ok: bool, detail := "") -> void:
	results.append({"check": name, "ok": ok})
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func frames(n := 2) -> void:
	for i in n:
		await process_frame


func _run() -> void:
	while current_scene == null or current_scene.get("cards") == null or current_scene.get("hud") == null:
		await process_frame
	game = current_scene
	await frames(10)
	hand = game.hud.card_hand
	gal = hand.pocket_gallery
	# 시작 고르기 화면이 떠 있으면 바로 확정해 치운다
	var mul = game.mulligan_ui
	if mul != null and mul.active:
		var t := 0.0
		while mul._phase != "pick" and t < 6.0:
			await process_frame
			t += root.get_process_delta_time()
		mul.confirm()
		t = 0.0
		while mul.active and t < 10.0:
			await process_frame
			t += root.get_process_delta_time()
	# 주머니·손패·활동·버림패에 고루 카드를 둔다
	game.cards.entries.clear()
	game.cards.in_play.clear()
	game.cards.discard.clear()
	game.cards.last_drawn.clear()
	var ids := ["frost_rune", "ward_lantern", "timber", "raw_meat", "wool", "rabbit_pelt", "treasure_chest", "old_spellbook", "poison_mushroom", "guest_invitation", "lamb", "forest_monster"]
	for i in ids.size():
		game.cards.add(ids[i], 1 if ids[i] != "timber" else 4)
	game.cards.changed.emit()
	await frames(2)
	var total: int = game.cards.pocket().size() + game.cards.hand().size() + game.cards.in_play.size() + game.cards.discard.size()
	check("검증용 카드가 주머니에도 손패에도 있음", game.cards.pocket().size() >= 3 and game.cards.hand().size() >= 3, "pocket=%d hand=%d" % [game.cards.pocket().size(), game.cards.hand().size()])

	hand.open_pocket()
	await frames(4)
	check("주머니 창 열림·갤러리 구성", hand.pocket_panel.visible and gal != null and gal.list == hand.pocket_list and hand.pocket_list.get_parent() is ScrollContainer)
	check("펼친 카드 수 = 주머니+손패+활동+버림패", gal.tiles.size() == total, "tiles=%d total=%d" % [gal.tiles.size(), total])
	var buttons := 0
	for row in hand.pocket_list.get_children():
		for c in row.get_children():
			if c is BaseButton:
				buttons += 1
	check("카드 타일은 버튼이 아님(보기 전용)", buttons == 0)
	var panel_w: float = hand.pocket_panel.size.x
	check("창이 넓다(디자인 폭 1500 이상)", panel_w >= 1400.0, "w=%.0f" % panel_w)
	var fits: bool = hand.get_viewport_rect().grow(-10).encloses(hand.pocket_panel.get_global_rect())
	check("창이 화면 안에 들어간다", fits, str(hand.pocket_panel.get_global_rect()))
	# 가로로 넓게: 첫 섹션의 처음 두 장이 같은 줄, 한 줄에 여러 장
	var pocket_tiles: Array = gal.tiles.filter(func(t): return t["zone"] == "pocket")
	var same_row: bool = pocket_tiles.size() >= 2 and is_equal_approx(pocket_tiles[0]["node"].global_position.y, pocket_tiles[1]["node"].global_position.y) and pocket_tiles[1]["node"].global_position.x > pocket_tiles[0]["node"].global_position.x
	check("카드가 가로로 나란히 펼쳐진다", same_row)
	var per_row := 0
	if not pocket_tiles.is_empty():
		var y0: float = pocket_tiles[0]["node"].global_position.y
		for t in pocket_tiles:
			if is_equal_approx(t["node"].global_position.y, y0):
				per_row += 1
	var cap := int((hand.pocket_list.size.x + gal.GAP.x) / (gal.CARD.x + gal.GAP.x))
	check("한 줄에 들어갈 수 있는 카드 수가 6장 이상", cap >= 6, "cap=%d per_row=%d" % [cap, per_row])
	check("카드 크기 2:3", is_equal_approx(gal.CARD.x / gal.CARD.y, 2.0 / 3.0))
	check("열었을 때는 올린 카드·어둠·툴팁 없음", not gal.hovering() and not gal.lifted.visible and not hand.tooltip.visible)

	# 마우스 오버 → 들어 올림
	gal.hover_index(0)
	await frames(1)
	var info: Dictionary = gal.tiles[0]
	check("오버: 올린 카드가 보이고 그 카드의 그림을 쓴다", gal.lifted.visible and gal.lifted.art.texture == info["art"].texture and gal.hover_entry == info["entry"])
	check("오버: 확대 배율 목표 %.1f배·들어 올림" % gal.LIFT_SCALE, is_equal_approx(gal.lifted.t_scl, gal.LIFT_SCALE) and gal.lifted.t_lift == 1.0)
	var start_scl: float = gal.lifted.scl
	await frames(40)
	check("스프링으로 커진다(제자리 1.0 → 목표 근처)", start_scl < 1.2 and absf(gal.lifted.scl - gal.LIFT_SCALE) < 0.08, "start=%.2f now=%.2f" % [start_scl, gal.lifted.scl])
	check("나머지 카드가 어두워진다(어둠 α > 0.5)", gal.dim.visible and gal.dim.color.a > 0.5, "a=%.2f" % gal.dim.color.a)
	var lr: Rect2 = gal.lifted_rect()
	var tile_r: Rect2 = Rect2(info["art"].global_position, info["art"].size * info["art"].get_global_transform().get_scale())
	check("올린 카드가 원래 타일보다 크고 타일을 덮는다", lr.size.x > tile_r.size.x * 1.4 and lr.intersects(tile_r))
	var panel_r: Rect2 = hand.pocket_panel.get_global_rect()
	check("올린 카드가 창 안에 남는다", panel_r.grow(2).encloses(lr), str(lr) + " in " + str(panel_r))
	check("오버: 툴팁 표시·구역 설명", hand.tooltip.visible and hand.tip_use.text == gal.ZONE_NOTE["pocket"] and hand.tip_title.text != "")
	var tr: Rect2 = hand.tooltip.get_global_rect()
	var vp: Rect2 = hand.get_viewport_rect()
	check("툴팁이 올린 카드와 겹치지 않고 옆에 붙는다", not tr.intersects(lr) and (absf(tr.position.x - lr.end.x - 14.0) < 1.0 or absf(tr.end.x - lr.position.x + 14.0) < 1.0), "tip=%s card=%s" % [tr, lr])
	check("툴팁이 화면 안에 있다", vp.encloses(tr), str(tr))
	# 손패 카드 툴팁 경로는 끊겨 있어야 한다(창 뒤 손패 카드에 반응하지 않음)
	check("오버 중 손패 드래그 불가", not hand.can_drag())

	# 다른 카드로 옮기기 → 그 카드로 바뀜
	var last: int = gal.tiles.size() - 1
	gal.hover_index(last)
	await frames(2)
	check("다른 카드로 옮기면 그 카드를 올린다", gal.hover_entry == gal.tiles[last]["entry"] and gal.lifted.visible)
	check("버림패 카드 툴팁 설명", hand.tip_use.text == gal.ZONE_NOTE[gal.tiles[last]["zone"]], gal.tiles[last]["zone"])
	var lr2: Rect2 = gal.lifted_rect()
	check("오른쪽 끝 카드도 창 안에 남는다", panel_r.grow(2).encloses(lr2), str(lr2))

	# 해제 → 내려놓고 어둠이 걷힘
	gal.hover_index(-1)
	await frames(45)
	check("해제: 올린 카드 사라짐·어둠 걷힘·툴팁 숨김", not gal.hovering() and not gal.lifted.visible and gal.dim.color.a < 0.05 and not hand.tooltip.visible, "a=%.2f" % gal.dim.color.a)

	# 소유 변화 시 다시 펼쳐도 오버 상태가 남지 않음
	gal.hover_index(1)
	await frames(2)
	game.cards.add("frost_rune")
	await frames(2)
	check("카드가 바뀌어 다시 펼치면 올린 카드가 정리된다", not gal.hovering() and gal.tiles.size() == total + 1, "tiles=%d" % gal.tiles.size())

	hand.close_pocket()
	await frames(2)
	check("닫기", not hand.pocket_panel.visible and not hand.tooltip.visible)
	print("RESULT %d/%d" % [results.size() - failures, results.size()])
	quit(0 if failures == 0 else 1)
