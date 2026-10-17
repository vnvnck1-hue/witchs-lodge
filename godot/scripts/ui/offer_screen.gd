extends CanvasLayer
## 새벽 보상·장날 화면(볼륨 확장 E3 — 기획: docs/game-volume-expansion-plan.md §3.3·3.4).
## - 새벽 보상: 카드 3장 중 1장을 골라 받는다(받지 않을 수도 있음). 받은 카드는 손패 우선.
## - 장날: 행상의 카드 4장을 골드로 산다(여러 장 가능). 침식 카드 정화(골드)도 여기서 한다.
## 열려 있는 동안 게임은 멈춘다(hud.refresh_pause()가 active를 본다).

const Cfg := preload("res://scripts/config.gd")
const ChapterData := preload("res://scripts/game/chapter_data.gd")
const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")

const CARD := Vector2(200, 300)
const GAP := 34.0

var game
var active := false
var mode := ""              # reward | market
var ids: Array = []         # 새벽 보상 후보
var offers: Array = []      # 장날 [{id, price, sold}]
var root: Control
var dim: ColorRect
var title: Label
var hint: Label
var row: Control
var buttons: Array = []     # [{btn, price_label}]
var close_btn: Button
var purify_btn: Button


func _ready() -> void:
	name = "OfferScreen"
	layer = 12
	process_mode = Node.PROCESS_MODE_ALWAYS
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.visible = false
	root.theme = MoonSkin.make_theme()
	add_child(root)
	dim = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.05, 0.02, 0.1, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(dim)
	title = _label(30, true, MoonSkin.CREAM)
	hint = _label(16, false, MoonSkin.LAVENDER)
	row = Control.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(row)
	close_btn = Button.new()
	close_btn.custom_minimum_size = Vector2(200, 44)
	close_btn.pressed.connect(close)
	root.add_child(close_btn)
	purify_btn = Button.new()
	purify_btn.custom_minimum_size = Vector2(260, 44)
	purify_btn.pressed.connect(purify)
	root.add_child(purify_btn)


func _label(size: int, bold: bool, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", MoonSkin.font(bold))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(l)
	return l


func open_reward(choice_ids: Array) -> void:
	if active or choice_ids.is_empty():
		return
	mode = "reward"
	ids = choice_ids.duplicate()
	offers = []
	_open("새벽의 선물", "밤을 버틴 대가로 숲이 카드를 내밉니다 — 한 장을 고르세요 (손패가 차면 주머니로)",
		ids.map(func(id): return {"id": id, "price": 0, "sold": false}))
	close_btn.text = "받지 않기"
	purify_btn.visible = false


func open_market(market_offers: Array) -> void:
	if active or market_offers.is_empty():
		return
	mode = "market"
	offers = market_offers
	ids = []
	_open("장날 — 떠돌이 행상", "", offers)
	close_btn.text = "장 보기 마침"
	purify_btn.visible = true
	_refresh_market()


func _open(t: String, h: String, items: Array) -> void:
	active = true
	root.visible = true
	title.text = t
	hint.text = h
	for b in buttons:
		b["btn"].queue_free()
	buttons.clear()
	var vp := root.get_viewport_rect().size
	var n := items.size()
	var total := n * CARD.x + (n - 1) * GAP
	var x0 := (vp.x - total) * 0.5
	var y0 := vp.y * 0.5 - CARD.y * 0.5 - 30
	title.size = Vector2(vp.x, 40)
	title.position = Vector2(0, y0 - 100)
	hint.size = Vector2(vp.x - 120, 50)
	hint.position = Vector2(60, y0 - 52)
	for i in n:
		var it: Dictionary = items[i]
		var d: Dictionary = game.cards.def(it["id"])
		var btn := TextureButton.new()
		btn.texture_normal = Catalog.texture(it["id"], false)
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.size = CARD
		btn.position = Vector2(x0 + i * (CARD.x + GAP), y0)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.tooltip_text = "%s\n%s" % [d.get("name", it["id"]), d.get("description", "")]
		btn.pressed.connect(_on_card.bind(i))
		root.add_child(btn)
		var nm := Label.new()
		nm.add_theme_font_override("font", MoonSkin.font(true))
		nm.add_theme_font_size_override("font_size", 17)
		nm.add_theme_color_override("font_color", MoonSkin.CREAM)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.size = Vector2(CARD.x + 40, 50)
		nm.position = Vector2(-20, CARD.y + 6)
		nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
		nm.text = d.get("name", it["id"]) + ("\n%dG" % int(it["price"]) if mode == "market" else "")
		btn.add_child(nm)
		buttons.append({"btn": btn, "label": nm})
	close_btn.position = Vector2(vp.x * 0.5 + 20, y0 + CARD.y + 80)
	purify_btn.position = Vector2(vp.x * 0.5 - 280, y0 + CARD.y + 80)
	if mode == "reward":
		close_btn.position.x = vp.x * 0.5 - 100
	if game.hud != null:
		game.hud.refresh_pause()
	game.sounds.play_or("panel_open", "card_shuffle")


func _on_card(i: int) -> void:
	if mode == "reward":
		pick(i)
	else:
		buy(i)


## 새벽 보상 i번을 받는다(검증 도구도 이것을 부른다).
func pick(i: int) -> bool:
	if not active or mode != "reward" or i < 0 or i >= ids.size():
		return false
	game.chapter.take_reward(ids[i])
	game.toast("새벽의 선물 — '%s' 카드를 받았습니다" % game.cards.def(ids[i]).get("name", ids[i]), Color(1.0, 0.95, 0.75))
	game.sounds.play("card_draw")
	close()
	return true


func buy(i: int) -> bool:
	if not active or mode != "market" or i < 0 or i >= offers.size():
		return false
	var why: String = game.chapter.buy_block_reason(offers[i])
	if why != "":
		game.toast("살 수 없습니다 — " + why, Color(1.0, 0.7, 0.7))
		game.sounds.play_or("btn_denied", "card_deny")
		return false
	game.chapter.buy(offers[i])
	game.toast("'%s' 카드를 샀습니다 (-%dG)" % [game.cards.def(offers[i]["id"]).get("name", ""), int(offers[i]["price"])], Color(1.0, 0.9, 0.6))
	_refresh_market()
	return true


func purify() -> String:
	if not active or mode != "market":
		return ""
	var why: String = game.chapter.purify_block_reason()
	if why != "":
		game.toast("정화할 수 없습니다 — " + why, Color(1.0, 0.7, 0.7))
		return ""
	var gone: String = game.chapter.buy_purify()
	game.toast("행상의 향로로 '%s'을(를) 정화했습니다 (-%dG)" % [gone, ChapterData.PURIFY_PRICE], Color(0.85, 0.75, 1.0))
	_refresh_market()
	return gone


func _refresh_market() -> void:
	hint.text = "골드 %dG · 산 카드는 손패로(가득 차면 주머니) · 침식 카드 %d장" % [game.economy.gold, game.chapter.corruption_count()]
	for i in buttons.size():
		var sold: bool = offers[i].get("sold", false)
		buttons[i]["btn"].disabled = sold
		buttons[i]["btn"].modulate = Color(0.5, 0.45, 0.6) if sold else Color.WHITE
		if sold:
			buttons[i]["label"].text = game.cards.def(offers[i]["id"]).get("name", "") + "\n구매함"
	purify_btn.text = "침식 정화 %dG" % ChapterData.PURIFY_PRICE
	purify_btn.disabled = game.chapter.purify_block_reason() != ""


func close() -> void:
	if not active:
		return
	active = false
	mode = ""
	root.visible = false
	for b in buttons:
		b["btn"].queue_free()
	buttons.clear()
	if game.hud != null:
		game.hud.refresh_pause()
	game.sounds.play("panel_close")


func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventMouseButton or event is InputEventKey:
		get_viewport().set_input_as_handled()
