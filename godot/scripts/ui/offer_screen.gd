extends CanvasLayer
## 새벽 보상·장날 화면(볼륨 확장 E3 — 기획: docs/game-volume-expansion-plan.md §3.3·3.4).
## - 새벽 보상: 카드 3장 중 1장을 골라 받는다(받지 않을 수도 있음). 받은 카드는 손패 우선.
## - 장날: 행상의 카드 4장을 골드로 산다(여러 장 가능). 침식 카드 정화(골드)도 여기서 한다.
## - 선택(choice): 종족 카드 v1(docs/race-cards-v01.md)의 카드 고르기 — 맞바꿈·꿈 기록장·언데드 보상·소개장·상인 마차·대청소 등.
##   항목 {id, uid?, person?, price?, texture?, label?}, 고르면 on_pick(i) -> bool(true면 닫음). game.race_cards.open_choice()가 연다.
## 열려 있는 동안 게임은 멈춘다(hud.refresh_pause()가 active를 본다).

const Cfg := preload("res://scripts/config.gd")
const ChapterData := preload("res://scripts/game/chapter_data.gd")
const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")
const Stage := preload("res://scripts/ui/center_stage.gd")
const OutsideClick := preload("res://scripts/ui/outside_click.gd")

const CARD := Vector2(200, 300)
const GAP := 34.0

var game
var active := false
var mode := ""              # reward | market | choice
var ids: Array = []         # 새벽 보상 후보
var offers: Array = []      # 장날 [{id, price, sold}]
var root: Control
var stage: Control          # 화면 가운데 무대 — 카드·제목·버튼은 가운데 기준 좌표(창 비율이 바뀌어도 가운데 유지)
var dim: ColorRect
var title: Label
var hint: Label
var row: Control
var buttons: Array = []     # [{btn, price_label}]
var close_btn: Button
var purify_btn: Button
var choice_items: Array = []        # 선택 모드 항목
var _choice_pick := Callable()
var _choice_close := Callable()
var _choice_closable := false


func _ready() -> void:
	name = "OfferScreen"
	layer = 12
	process_mode = Node.PROCESS_MODE_ALWAYS
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.visible = false
	root.theme = MoonSkin.make_theme()
	root.gui_input.connect(_on_root_input)
	add_child(root)
	dim = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.05, 0.02, 0.1, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(dim)
	stage = Stage.make(root)
	title = _label(30, true, MoonSkin.CREAM)
	hint = _label(16, false, MoonSkin.LAVENDER)
	row = Control.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(row)
	close_btn = Button.new()
	close_btn.custom_minimum_size = Vector2(200, 44)
	close_btn.pressed.connect(close)
	stage.add_child(close_btn)
	purify_btn = Button.new()
	purify_btn.custom_minimum_size = Vector2(260, 44)
	purify_btn.pressed.connect(purify)
	stage.add_child(purify_btn)


func _label(size: int, bold: bool, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", MoonSkin.font(bold))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(l)
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


func open_choice(t: String, h: String, items: Array, on_pick: Callable, closable := false, close_text := "그만두기", on_close := Callable()) -> void:
	if active or items.is_empty():
		return
	mode = "choice"
	choice_items = items
	_choice_pick = on_pick
	_choice_close = on_close
	_choice_closable = closable
	offers = []
	ids = []
	_open(t, h, items)
	close_btn.text = close_text
	close_btn.visible = closable
	close_btn.position.x = -100
	purify_btn.visible = false
	_refresh_choice()


func _refresh_choice() -> void:
	for i in buttons.size():
		var sold: bool = choice_items[i].get("sold", false)
		buttons[i]["btn"].disabled = sold
		buttons[i]["btn"].modulate = Color(0.5, 0.45, 0.6) if sold else Color.WHITE
		if sold:
			buttons[i]["label"].text = _item_name(choice_items[i]) + "\n구매함"
	if choice_items.any(func(it): return it.has("price")):
		hint.text = hint.text.split("\n")[0] + "\n골드 %dG" % game.economy.gold


func _item_name(it: Dictionary) -> String:
	if it.has("label"):
		return str(it["label"])
	var nm: String = game.cards.def(it["id"]).get("name", it["id"])
	return nm + ("\n" + str(it["person"]) if str(it.get("person", "")) != "" else "")


func _item_texture(it: Dictionary) -> Texture2D:
	var path := str(it.get("texture", ""))
	if path != "" and ResourceLoader.exists(path):
		return load(path) as Texture2D
	if int(it.get("art", -1)) >= 0:
		return Catalog.variant_texture(it["id"], int(it["art"]), false)
	if str(it.get("person", "")) != "":
		return Catalog.texture_for(it["id"], it["person"])
	return Catalog.texture(it["id"], false)


func _open(t: String, h: String, items: Array) -> void:
	active = true
	root.visible = true
	title.text = t
	hint.text = h
	for b in buttons:
		b["btn"].queue_free()
	buttons.clear()
	var vp := Stage.view(stage)  # 무대 좌표의 원점이 화면 가운데다
	var n := items.size()
	# 선택 모드에서 카드가 많으면(산장 대청소 등) 여러 줄로 작게 놓는다
	var per_row := n if n <= 6 else 8
	var rows := int(ceil(float(n) / per_row))
	var card := CARD if rows == 1 else CARD * (0.62 if rows == 2 else 0.46)
	var gap := GAP if rows == 1 else GAP * 0.5
	var row_h := card.y + (46.0 if rows > 1 else 0.0)
	var total := mini(n, per_row) * card.x + (mini(n, per_row) - 1) * gap
	var x0 := -total * 0.5
	var y0 := -(row_h * rows) * 0.5 - 30 if rows > 1 else -CARD.y * 0.5 - 30
	title.size = Vector2(vp.x, 40)
	title.position = Vector2(-vp.x * 0.5, y0 - 100)
	hint.size = Vector2(vp.x - 120, 50)
	hint.position = Vector2(-vp.x * 0.5 + 60, y0 - 52)
	for i in n:
		var it: Dictionary = items[i]
		var d: Dictionary = game.cards.def(it["id"])
		var btn := TextureButton.new()
		btn.texture_normal = _item_texture(it) if mode == "choice" else Catalog.texture(it["id"], false)
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.size = card
		btn.position = Vector2(x0 + (i % per_row) * (card.x + gap), y0 + (i / per_row) * row_h)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.tooltip_text = "%s\n%s" % [d.get("name", it["id"]), d.get("description", "")]
		btn.pressed.connect(_on_card.bind(i))
		stage.add_child(btn)
		var nm := Label.new()
		nm.add_theme_font_override("font", MoonSkin.font(true))
		nm.add_theme_font_size_override("font_size", 17 if rows == 1 else 13)
		nm.add_theme_color_override("font_color", MoonSkin.CREAM)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.size = Vector2(card.x + 40, 50)
		nm.position = Vector2(-20, card.y + 6)
		nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
		nm.text = d.get("name", it["id"]) + ("\n%dG" % int(it["price"]) if mode == "market" else "")
		if mode == "choice":
			nm.text = _item_name(it) + ("\n%dG" % int(it["price"]) if it.has("price") else "")
			btn.tooltip_text = "%s\n%s" % [nm.text, d.get("description", "")]
		btn.add_child(nm)
		buttons.append({"btn": btn, "label": nm})
	close_btn.position = Vector2(20, y0 + (row_h * rows if rows > 1 else CARD.y) + 80)
	purify_btn.position = Vector2(-280, y0 + CARD.y + 80)
	if mode == "reward":
		close_btn.position.x = -100
	if game.hud != null:
		game.hud.refresh_pause()
	game.sounds.play_or("panel_open", "card_shuffle")


func _on_card(i: int) -> void:
	if mode == "choice":
		choose(i)
	elif mode == "reward":
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


## 선택 모드 i번을 고른다(검증 도구도 이것을 부른다). on_pick 이 true 를 돌려주면 닫는다.
func choose(i: int) -> bool:
	if not active or mode != "choice" or i < 0 or i >= choice_items.size():
		return false
	if choice_items[i].get("sold", false):
		return false
	var cb := _choice_pick
	var done := true
	if cb.is_valid():
		done = bool(cb.call(i))
	game.sounds.play("card_draw")
	if done:
		_choice_close = Callable()
		close()
	else:
		_refresh_choice()
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
	if mode == "choice" and _choice_close.is_valid():
		_choice_close.call()
	_choice_close = Callable()
	_choice_pick = Callable()
	close_btn.visible = true
	active = false
	mode = ""
	root.visible = false
	for b in buttons:
		b["btn"].queue_free()
	buttons.clear()
	if game.hud != null:
		game.hud.refresh_pause()
	game.sounds.play("panel_close")


## 장날 화면은 카드·버튼 둘레 밖(허공)을 클릭하면 '장 보기 마침'처럼 닫힌다.
## 새벽 선물은 잘못 눌러 보상을 잃지 않도록 '받지 않기' 버튼으로만 닫는다.
func _on_root_input(event: InputEvent) -> void:
	if not active or mode != "market" or not OutsideClick.is_press(event):
		return
	var content: Array = [close_btn, purify_btn]
	for b in buttons:
		content.append(b["btn"])
		content.append(b["label"])
	if not OutsideClick.hits(event.position, content, 24.0):
		root.accept_event()
		close()


func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventMouseButton or event is InputEventKey:
		get_viewport().set_input_as_handled()
