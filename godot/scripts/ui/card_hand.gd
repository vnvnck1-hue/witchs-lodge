extends Control
## 하단 손패(기획서 v0.3 §9·14): 카드 표시·확대 설명·월드로 드래그·대상 강조/미리보기, 창고, 고용 제안, 양털 판매 창.
## 카드의 누르기·드래그·놓기는 모두 여기서 소비하므로 마녀 이동으로 전달되지 않는다.
## 판정과 소비는 CardUseResolver, 소유는 CardInventory가 맡는다(이 UI는 상태를 표시하고 입력만 전달).

const Cfg := preload("res://scripts/config.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")

const CW := 118.0
const CH := 177.0
const HAND_MAX_W := 900.0
const C_OK := Color(0.6, 1.0, 0.6)
const C_BAD := Color(1.0, 0.45, 0.45)
const C_AMBER := Color(1.0, 0.78, 0.4)
const C_DIM := Color(0.75, 0.7, 0.88)

var game
var hud
var views: Dictionary = {}          # uid -> CardView
var textures: Dictionary = {}
var hover_uid := -1
var drag_uid := -1
var drag_pos := Vector2.ZERO
var plan: Dictionary = {}
var draw_layer: Control
var tooltip: PanelContainer
var tip_title: Label
var tip_sub: Label
var tip_body: Label
var tip_use: Label
var preview: PanelContainer
var preview_title: Label
var preview_body: Label
var offer_box: VBoxContainer
var offer_rows: Array = []
var storage_btn: Button
var storage_panel: PanelContainer
var storage_list: VBoxContainer
var sale_panel: PanelContainer
var sale_uid := -1
var sale_qty := 1
var sale_info: Label
var sale_qty_label: Label
var sale_total: Label
var empty_hint: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	empty_hint = hud._label("손패가 비어 있습니다 — 손님 고용 · 양털 수확 · 표식 괴물 처치로 카드를 얻습니다", 14, Color(0.85, 0.82, 1.0, 0.6))
	empty_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud._place(empty_hint, 0.5, 1, 0.5, 1, -400, -40, 400, -16)
	add_child(empty_hint)
	_build_offers()
	_build_storage()
	_build_sale()
	_build_tooltip()
	draw_layer = DrawLayer.new()
	draw_layer.hand = self
	draw_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	draw_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(draw_layer)
	_build_preview()
	# 카드 위에 떠야 하는 것들은 맨 뒤로(그리기·입력 모두 위)
	for top in [tooltip, storage_panel, sale_panel]:
		move_child(top, -1)
	game.cards.changed.connect(_sync)
	game.economy.offers_changed.connect(_sync_offers)
	_sync()


func _tex(id: String, hand := true) -> Texture2D:
	var key := id + ("_h" if hand else "")
	if not textures.has(key):
		textures[key] = Catalog.texture(id, hand)
	return textures[key]


# ───────────────────────── 구성 ─────────────────────────

func _build_tooltip() -> void:
	tooltip = PanelContainer.new()
	tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip.add_theme_stylebox_override("panel", hud._sb(Color(0.1, 0.08, 0.2, 0.94), Color(1.0, 0.75, 0.45, 0.55), 10, 12))
	tooltip.custom_minimum_size = Vector2(320, 0)
	tooltip.visible = false
	add_child(tooltip)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	tooltip.add_child(v)
	tip_title = hud._label("", 21, C_AMBER)
	v.add_child(tip_title)
	tip_sub = hud._label("", 13, C_DIM)
	v.add_child(tip_sub)
	tip_body = hud._label("", 14)
	tip_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip_body.custom_minimum_size.x = 296
	v.add_child(tip_body)
	tip_use = hud._label("", 14, C_OK)
	tip_use.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip_use.custom_minimum_size.x = 296
	v.add_child(tip_use)


func _build_preview() -> void:
	preview = PanelContainer.new()
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.add_theme_stylebox_override("panel", hud._sb(Color(0.08, 0.06, 0.16, 0.92), Color(0.6, 1.0, 0.6, 0.5), 8, 10))
	preview.visible = false
	add_child(preview)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	preview.add_child(v)
	preview_title = hud._label("", 17, C_OK)
	v.add_child(preview_title)
	preview_body = hud._label("", 14)
	v.add_child(preview_body)


func _build_offers() -> void:
	offer_box = VBoxContainer.new()
	offer_box.alignment = BoxContainer.ALIGNMENT_END
	offer_box.add_theme_constant_override("separation", 6)
	offer_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud._place(offer_box, 0, 1, 0, 1, 16, -330, 420, -16)
	add_child(offer_box)


func _build_storage() -> void:
	storage_btn = Button.new()
	storage_btn.text = "창고"
	storage_btn.add_theme_font_size_override("font_size", 15)
	hud._place(storage_btn, 0.5, 1, 0.5, 1, 470, -58, 580, -16)
	storage_btn.pressed.connect(open_storage)
	add_child(storage_btn)
	storage_panel = hud._modal(560, 470)
	storage_panel.reparent(self)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	storage_panel.add_child(v)
	v.add_child(hud._label("산장 창고", 26, C_AMBER))
	v.add_child(hud._label("손패는 %d장까지 보입니다. 넘친 카드는 창고에 보관되며 잃지 않습니다." % Cfg.HAND_VISIBLE, 13, C_DIM))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(scroll)
	storage_list = VBoxContainer.new()
	storage_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	storage_list.add_theme_constant_override("separation", 6)
	scroll.add_child(storage_list)
	var close := Button.new()
	close.text = "닫기"
	close.custom_minimum_size = Vector2(0, 42)
	close.pressed.connect(close_storage)
	v.add_child(close)


func _build_sale() -> void:
	sale_panel = hud._modal(420, 300)
	sale_panel.reparent(self)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	sale_panel.add_child(v)
	v.add_child(hud._label("산장 교역 — 양털 판매", 24, C_AMBER))
	sale_info = hud._label("", 14, C_DIM)
	v.add_child(sale_info)
	var h := HBoxContainer.new()
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_theme_constant_override("separation", 10)
	v.add_child(h)
	for pair in [["−", -1], ["+", 1]]:
		var b := Button.new()
		b.text = pair[0]
		b.custom_minimum_size = Vector2(52, 44)
		var d: int = pair[1]
		b.pressed.connect(func(): _set_qty(sale_qty + d))
		h.add_child(b)
		if d < 0:
			sale_qty_label = hud._label("1", 26)
			sale_qty_label.custom_minimum_size.x = 60
			sale_qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			h.add_child(sale_qty_label)
	var all := Button.new()
	all.text = "전부"
	all.custom_minimum_size = Vector2(70, 44)
	all.pressed.connect(func(): _set_qty(999))
	h.add_child(all)
	sale_total = hud._label("", 18, C_AMBER)
	sale_total.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(sale_total)
	var h2 := HBoxContainer.new()
	h2.add_theme_constant_override("separation", 10)
	v.add_child(h2)
	var sell := Button.new()
	sell.text = "판매"
	sell.custom_minimum_size = Vector2(0, 44)
	sell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sell.pressed.connect(_confirm_sale)
	h2.add_child(sell)
	var cancel := Button.new()
	cancel.text = "취소"
	cancel.custom_minimum_size = Vector2(0, 44)
	cancel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel.pressed.connect(close_sale)
	h2.add_child(cancel)


# ───────────────────────── 손패 동기화·배치 ─────────────────────────

func _sync() -> void:
	var hand: Array = game.cards.hand()
	var keep: Dictionary = {}
	for e in hand:
		keep[e["uid"]] = true
		if not views.has(e["uid"]):
			var cv := CardView.new()
			cv.hand = self
			cv.uid = e["uid"]
			cv.texture = _tex(e["id"])
			cv.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			cv.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			cv.size = Vector2(CW, CH)
			cv.pivot_offset = Vector2(CW * 0.5, CH)
			cv.mouse_filter = Control.MOUSE_FILTER_STOP
			cv.position = Vector2(get_viewport_rect().size.x * 0.5 - CW * 0.5, get_viewport_rect().size.y + 20)
			cv.badge = _badge(cv)
			add_child(cv)
			move_child(cv, draw_layer.get_index() if draw_layer != null else get_child_count() - 1)
			views[e["uid"]] = cv
		var view: CardView = views[e["uid"]]
		if e["id"] in ["wool", "timber"]:
			view.badge.text = "×%d" % e["count"]
		elif e["person"] != "":
			view.badge.text = e["person"]
		else:
			view.badge.text = ""
		view.badge.get_parent().visible = view.badge.text != ""
	for uid in views.keys():
		if not keep.has(uid):
			views[uid].queue_free()
			views.erase(uid)
			if hover_uid == uid:
				hover_uid = -1
	if drag_uid != -1 and not keep.has(drag_uid):
		_cancel_drag()
	storage_btn.text = "창고 %d" % game.cards.storage().size() if game.cards.storage().size() > 0 else "창고"
	empty_hint.visible = hand.is_empty()
	if storage_panel.visible:
		_fill_storage()


func _badge(cv: Control) -> Label:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", hud._sb(Color(0.12, 0.08, 0.22, 0.92), Color(1.0, 0.8, 0.5, 0.8), 8, 3))
	cv.add_child(p)
	var l: Label = hud._label("", 15, Color(1.0, 0.92, 0.75))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.add_child(l)
	p.position = Vector2(CW - 48, -8)
	p.custom_minimum_size = Vector2(54, 0)
	return l


func hand_top() -> float:
	return get_viewport_rect().size.y - CH - 34.0


func _layout(delta: float) -> void:
	var vp := get_viewport_rect().size
	var hand: Array = game.cards.hand()
	var n := hand.size()
	var spacing := minf(CW + 10.0, HAND_MAX_W / maxf(n, 1))
	var total := spacing * (n - 1) + CW
	var x0 := vp.x * 0.5 - total * 0.5
	var k := clampf(delta * 14.0, 0.0, 1.0)
	for i in n:
		var view: CardView = views.get(hand[i]["uid"])
		if view == null:
			continue
		var c := i - (n - 1) * 0.5
		var pos := Vector2(x0 + i * spacing, vp.y - CH - 12.0 + c * c * 1.6)
		var rot := c * 2.2
		var scl := 1.0
		var alpha := 1.0
		if view.uid == hover_uid and drag_uid == -1:
			pos.y -= 64.0
			rot = 0.0
			scl = 1.5
		if view.uid == drag_uid:
			alpha = 0.3
		view.position = view.position.lerp(pos, k)
		view.rotation_degrees = lerpf(view.rotation_degrees, rot, k)
		view.scale = view.scale.lerp(Vector2.ONE * scl, k)
		view.modulate.a = lerpf(view.modulate.a, alpha, k)
	# 그리기 순서: 왼쪽→오른쪽, 확대 중인 카드는 맨 위
	var order: Array = []
	for e in hand:
		if views.has(e["uid"]) and e["uid"] != hover_uid:
			order.append(views[e["uid"]])
	if views.has(hover_uid):
		order.append(views[hover_uid])
	var base := draw_layer.get_index() - order.size()
	for j in order.size():
		if order[j].get_index() != base + j:
			move_child(order[j], base + j)


# ───────────────────────── 설명(마우스 올림) ─────────────────────────

func _usage_text(e: Dictionary) -> String:
	var st: int = game.session.state
	match e["id"]:
		"axe_mercenary":
			if st == SessionScript.State.PREP:
				return "▶ 나무로 끌어 벌목 · 지면으로 끌어 오늘 밤 방어 배치"
			if st == SessionScript.State.COMBAT:
				return "▶ 적이나 지면으로 끌어 전투에 소환"
		"forest_monster":
			if st == SessionScript.State.PREP or st == SessionScript.State.COMBAT:
				return "▶ 적이나 지면으로 끌어 하수인 소환"
		"wool":
			if st == SessionScript.State.PREP:
				return "▶ 산장으로 끌어 판매 (1개 %dG)" % Cfg.WOOL_PRICE
			return "판매는 준비 시간에만 가능합니다"
		"timber":
			if st == SessionScript.State.PREP:
				return "▶ 산장으로 끌어 수리 (%d개 → 체력 +%d)" % [Cfg.TIMBER_REPAIR_COST, int(Cfg.TIMBER_REPAIR_AMOUNT)]
			return "수리는 준비 시간에만 가능합니다"
	return "지금은 사용할 수 없습니다"


func _update_tooltip() -> void:
	if hover_uid == -1 or drag_uid != -1 or not views.has(hover_uid):
		tooltip.visible = false
		return
	var e: Dictionary = game.cards.get_entry(hover_uid)
	if e.is_empty():
		tooltip.visible = false
		return
	var d: Dictionary = game.cards.def(e["id"])
	tip_title.text = d.get("name", e["id"]) + ("  ×%d" % e["count"] if game.cards.stackable(e["id"]) else "")
	var sub: String = d.get("category", "")
	if e["person"] != "":
		sub += "  ·  계약 인물: " + e["person"]
	sub += "  ·  획득: " + d.get("acquisition", "")
	tip_sub.text = sub
	tip_body.text = d.get("description", "")
	tip_use.text = _usage_text(e)
	tip_use.add_theme_color_override("font_color", C_OK if tip_use.text.begins_with("▶") else C_DIM)
	var view: CardView = views[hover_uid]
	var vp := get_viewport_rect().size
	tooltip.reset_size()
	var x := view.position.x + CW * 0.5 + CW * 0.75 + 16.0
	if x + tooltip.size.x > vp.x - 16.0:
		x = view.position.x + CW * 0.5 - CW * 0.75 - 16.0 - tooltip.size.x
	tooltip.position = Vector2(x, vp.y - CH * 1.5 - 76.0)
	tooltip.visible = true


# ───────────────────────── 드래그 ─────────────────────────

func can_drag() -> bool:
	return not game.session.is_over() and not get_tree().paused and not modal_open()


func begin_drag(uid: int) -> void:
	if drag_uid != -1:
		return
	if not can_drag():
		return
	drag_uid = uid
	drag_pos = get_viewport().get_mouse_position()
	plan = {}
	tooltip.visible = false


func _cancel_drag() -> void:
	drag_uid = -1
	plan = {}
	preview.visible = false
	draw_layer.queue_redraw()


func _end_drag() -> void:
	var uid := drag_uid
	var pos := drag_pos
	_cancel_drag()
	if pos.y >= hand_top():
		return  # 손패 위에서 놓으면 사용하지 않고 되돌린다
	var result: Dictionary = game.resolver.commit(uid, pos)
	if not result["ok"]:
		game.toast(result["reason"], Color(1.0, 0.65, 0.65))
	elif result["action"] == "sell":
		open_sale(uid)


func _input(event: InputEvent) -> void:
	if drag_uid == -1:
		return
	if event is InputEventMouseMotion:
		drag_pos = event.position
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
			drag_pos = mb.position
			_end_drag()
		elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_cancel_drag()
			game.toast("카드 사용을 취소했습니다", Color(0.85, 0.82, 1.0))
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_cancel_drag()
		get_viewport().set_input_as_handled()


func _update_drag() -> void:
	if drag_uid == -1:
		preview.visible = false
		return
	if not can_drag():
		_cancel_drag()
		return
	if drag_pos.y >= hand_top():
		plan = {}
		preview.visible = false
		draw_layer.queue_redraw()
		return
	plan = game.resolver.evaluate(drag_uid, drag_pos)
	if plan["ok"]:
		preview_title.text = plan["title"]
		preview_title.add_theme_color_override("font_color", C_OK)
		preview_body.text = "\n".join(plan["lines"])
		preview.add_theme_stylebox_override("panel", hud._sb(Color(0.08, 0.06, 0.16, 0.92), Color(0.6, 1.0, 0.6, 0.55), 8, 10))
	else:
		preview_title.text = "사용할 수 없음"
		preview_title.add_theme_color_override("font_color", C_BAD)
		preview_body.text = plan["reason"]
		preview.add_theme_stylebox_override("panel", hud._sb(Color(0.14, 0.05, 0.08, 0.92), Color(1.0, 0.45, 0.45, 0.55), 8, 10))
	preview.reset_size()
	var vp := get_viewport_rect().size
	var p := drag_pos + Vector2(62, -60)
	if p.x + preview.size.x > vp.x - 12:
		p.x = drag_pos.x - 62 - preview.size.x
	p.y = clampf(p.y, 12, vp.y - preview.size.y - 12)
	preview.position = p
	preview.visible = true
	draw_layer.queue_redraw()


func _ring(c: Control, cam: Camera3D, center: Vector3, radius: float, color: Color, width := 2.5) -> void:
	var pts := PackedVector2Array()
	for i in 33:
		var a := TAU * i / 32.0
		pts.append(cam.unproject_position(center + Vector3(cos(a) * radius, 0.05, sin(a) * radius)))
	c.draw_polyline(pts, color, width, true)


func draw_drag(c: Control) -> void:
	if drag_uid == -1:
		return
	var e: Dictionary = game.cards.get_entry(drag_uid)
	if e.is_empty():
		return
	var cam: Camera3D = game.world.camera
	var st: int = game.session.state
	var font := c.get_theme_default_font()
	# 유효 대상 강조
	if e["id"] == "axe_mercenary" and st == SessionScript.State.PREP:
		for t in game.world.harvest_trees:
			var usable: bool = t["remaining"] > 0 and t["reserved"] == null
			var col := Color(0.6, 1.0, 0.55, 0.8) if usable else Color(0.7, 0.65, 0.8, 0.45)
			_ring(c, cam, t["pos"], 1.0, col, 3.0)
			var lp := cam.unproject_position(t["pos"] + Vector3(0, 0.2, 0))
			var txt := "목재 %d" % t["remaining"] if t["remaining"] > 0 else "고갈"
			if t["reserved"] != null:
				txt = "작업 중"
			c.draw_string_outline(font, lp + Vector2(-28, 26), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, 4, Color(0.05, 0.03, 0.1, 0.9))
			c.draw_string(font, lp + Vector2(-28, 26), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, col)
	if e["id"] in ["axe_mercenary", "forest_monster"] and st == SessionScript.State.COMBAT:
		for en in game.get_tree().get_nodes_in_group("enemies"):
			if not en.dead:
				_ring(c, cam, en.global_position, 0.55, Color(1.0, 0.5, 0.45, 0.7), 2.0)
	if e["id"] in ["wool", "timber"] and st == SessionScript.State.PREP:
		_ring(c, cam, game.world.lodge.global_position, 3.6, Color(1.0, 0.8, 0.45, 0.75), 3.0)
	# 실제 소환·작업 위치
	if plan.has("pos") and plan["pos"] != null:
		var ok: bool = plan["ok"]
		var col2 := C_OK if ok else C_BAD
		var where: Vector3 = plan["pos"]
		if plan.get("action", "") in ["guard", "chop"] or not ok:
			_ring(c, cam, where, 0.5, col2, 3.5)
			_ring(c, cam, where, 0.25, Color(col2, 0.5), 2.0)
		c.draw_dashed_line(drag_pos, cam.unproject_position(where), Color(col2, 0.6), 2.0, 8.0)
	# 끌고 있는 카드
	var tex := _tex(e["id"])
	var r := Rect2(drag_pos - Vector2(42, 63), Vector2(84, 126))
	c.draw_texture_rect(tex, r, false, Color(1, 1, 1, 0.92))


# ───────────────────────── 고용 제안 ─────────────────────────

func _sync_offers() -> void:
	for row in offer_rows:
		row["panel"].queue_free()
	offer_rows.clear()
	for o in game.economy.offers:
		var p := PanelContainer.new()
		p.add_theme_stylebox_override("panel", hud._sb(Color(0.14, 0.1, 0.24, 0.92), Color(1.0, 0.78, 0.45, 0.7), 10, 10))
		offer_box.add_child(p)
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 10)
		p.add_child(h)
		var icon := TextureRect.new()
		icon.texture = _tex("axe_mercenary")
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(48, 72)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(icon)
		var v := VBoxContainer.new()
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(v)
		v.add_child(hud._label("손님 %s — 일자리를 찾습니다" % o["person"], 16, C_AMBER))
		v.add_child(hud._label("도끼 용병 계약 · 벌목 또는 전투 한 임무", 13, C_DIM))
		var t: Label = hud._label("", 13, C_DIM)
		v.add_child(t)
		var b := Button.new()
		b.text = "고용 %dG" % Cfg.CONTRACT_COST
		b.custom_minimum_size = Vector2(92, 44)
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		b.pressed.connect(_on_hire.bind(o))
		h.add_child(b)
		offer_rows.append({"panel": p, "offer": o, "time": t, "button": b})


func _on_hire(o: Dictionary) -> void:
	if not game.economy.hire(o):
		game.toast("고용할 수 없습니다 — " + game.economy.hire_block_reason(o), Color(1.0, 0.7, 0.7))


func _update_offers() -> void:
	for row in offer_rows:
		var o: Dictionary = row["offer"]
		var reason: String = game.economy.hire_block_reason(o)
		row["button"].disabled = reason != ""
		var left: float = game.economy.offer_time_left(o)
		row["time"].text = "%d초 뒤 떠남" % int(ceil(left)) + ("  ·  " + reason if reason != "" else "")


# ───────────────────────── 창고 ─────────────────────────

func modal_open() -> bool:
	return storage_panel.visible or sale_panel.visible


func open_storage() -> void:
	if game.session.is_over() or hud.pause_panel.visible:
		return
	_cancel_drag()
	storage_panel.visible = true
	_fill_storage()
	hud.refresh_pause()


func close_storage() -> void:
	storage_panel.visible = false
	hud.refresh_pause()


func _fill_storage() -> void:
	for c in storage_list.get_children():
		c.queue_free()
	var hand_full: bool = game.cards.hand().size() >= Cfg.HAND_VISIBLE
	for zone in ["hand", "storage"]:
		var list: Array = game.cards.hand() if zone == "hand" else game.cards.storage()
		storage_list.add_child(hud._label("손패 %d/%d" % [list.size(), Cfg.HAND_VISIBLE] if zone == "hand" else "창고 %d장" % list.size(), 16, C_AMBER))
		if list.is_empty():
			storage_list.add_child(hud._label("  (비어 있음)", 13, C_DIM))
		for e in list:
			var h := HBoxContainer.new()
			h.add_theme_constant_override("separation", 10)
			storage_list.add_child(h)
			var icon := TextureRect.new()
			icon.texture = _tex(e["id"])
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.custom_minimum_size = Vector2(36, 54)
			h.add_child(icon)
			var d: Dictionary = game.cards.def(e["id"])
			var name_text: String = d.get("name", e["id"])
			if e["person"] != "":
				name_text += " · " + e["person"]
			if game.cards.stackable(e["id"]):
				name_text += "  ×%d" % e["count"]
			var l: Label = hud._label(name_text, 15)
			l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			h.add_child(l)
			var b := Button.new()
			b.custom_minimum_size = Vector2(110, 36)
			var uid: int = e["uid"]
			if zone == "hand":
				b.text = "창고로"
				b.pressed.connect(func(): game.cards.move(uid, "storage"))
			else:
				b.text = "손패로"
				b.disabled = hand_full
				b.pressed.connect(func(): game.cards.move(uid, "hand"))
			h.add_child(b)


# ───────────────────────── 양털 판매 ─────────────────────────

func open_sale(uid: int) -> void:
	var e: Dictionary = game.cards.get_entry(uid)
	if e.is_empty():
		return
	sale_uid = uid
	sale_panel.visible = true
	_set_qty(int(e["count"]))
	hud.refresh_pause()


func close_sale() -> void:
	sale_panel.visible = false
	sale_uid = -1
	hud.refresh_pause()


func _set_qty(q: int) -> void:
	var e: Dictionary = game.cards.get_entry(sale_uid)
	if e.is_empty():
		close_sale()
		return
	sale_qty = clampi(q, 1, int(e["count"]))
	sale_info.text = "보유 양털 %d개 · 1개 %dG · 판매할 때만 골드를 받습니다" % [e["count"], Cfg.WOOL_PRICE]
	sale_qty_label.text = str(sale_qty)
	sale_total.text = "판매 금액 +%dG" % (sale_qty * Cfg.WOOL_PRICE)


func _confirm_sale() -> void:
	game.economy.sell_wool(sale_uid, sale_qty)
	close_sale()


func close_all() -> void:
	_cancel_drag()
	storage_panel.visible = false
	sale_panel.visible = false


# ───────────────────────── 매 프레임 ─────────────────────────

func _process(delta: float) -> void:
	var over: bool = game.session.is_over()
	for v in views.values():
		v.visible = not over
	storage_btn.visible = not over
	offer_box.visible = not over
	if sale_panel.visible and game.session.state != SessionScript.State.PREP:
		close_sale()
	_layout(delta)
	_update_drag()
	_update_tooltip()
	_update_offers()


func set_hover(uid: int, on: bool) -> void:
	if on:
		hover_uid = uid
	elif hover_uid == uid:
		hover_uid = -1


class CardView extends TextureRect:
	var hand
	var uid := -1
	var badge: Label

	func _ready() -> void:
		mouse_entered.connect(func(): hand.set_hover(uid, true))
		mouse_exited.connect(func(): hand.set_hover(uid, false))

	func _gui_input(event: InputEvent) -> void:
		var mb := event as InputEventMouseButton
		if mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			hand.begin_drag(uid)
			accept_event()


class DrawLayer extends Control:
	var hand

	func _process(_delta: float) -> void:
		if hand.drag_uid != -1:
			queue_redraw()

	func _draw() -> void:
		hand.draw_drag(self)
