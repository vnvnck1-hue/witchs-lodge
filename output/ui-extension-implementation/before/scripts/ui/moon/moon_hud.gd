extends Control
## 달빛 마법 상시 HUD: 마녀·산장 상태, 오늘의 할 일, 낮/밤, 자원, 일시정지, 손패 트레이, 마녀의 주머니, 산장 관리·용 공물.
## 값은 실제 게임 상태에서만 읽는다(시안의 예시 숫자를 고정하지 않는다). 판정·가격·소비는 기존 모듈 호출.
## 동작 연결: hud(관리창·일시정지), card_hand(주머니), economy.buy("dragon").

const Cfg := preload("res://scripts/config.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const Layout := preload("res://scripts/ui/moon/moon_layout.gd")
const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")
const W := preload("res://scripts/ui/moon/moon_widgets.gd")

var game
var hud
var groups: Dictionary = {}
var player_gauge: W.MoonGauge
var lodge_gauge: W.MoonGauge
var player_val: W.MoonLabel
var lodge_val: W.MoonLabel
var status_hover: Control
var phase_title: W.MoonLabel
var phase_sub: W.MoonLabel
var phase_gauge: W.MoonGauge
var phase_hover: Control
var gold_val: W.MoonLabel
var timber_val: W.MoonLabel
var wool_val: W.MoonLabel
var res_hovers: Array = []
var objective_text: W.MoonLabel
var pause_btn: W.MoonButton
var storage_btn: W.MoonButton
var storage_badge: Control
var storage_count: W.MoonLabel
var lodge_btn: W.MoonButton
var dragon_btn: W.MoonButton
var dragon_label: W.MoonLabel
var _tip_timer := 0.0


func _ready() -> void:
	name = "MoonHud"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_status()
	_build_objective()
	_build_phase()
	_build_resources()
	_build_pause()
	_build_hand_tray()
	_build_storage()
	_build_actions()
	refresh(true)


func _group(id: String) -> W.MoonGroup:
	var g := W.MoonGroup.new().setup(id)
	add_child(g)
	groups[id] = g
	return g


func _button(g: W.MoonGroup, tex_id: String, abs_rect: Rect2, disabled_id := "") -> W.MoonButton:
	var b := W.MoonButton.new()
	b.name = tex_id
	b.setup(MoonSkin.tex(tex_id), g.local(abs_rect), MoonSkin.tex(disabled_id) if disabled_id != "" else null)
	g.add_child(b)
	return b


# ───────────────────────── 구성 (좌표: 원본 아틀라스 px) ─────────────────────────

func _build_status() -> void:
	var g := _group("player_status")
	g.add_piece("player_status", Rect2(6, 6, 577, 195))
	player_gauge = _gauge(g, "gauge_fill_red", Rect2(312, 70, 135, 12))
	lodge_gauge = _gauge(g, "gauge_fill_teal", Rect2(312, 126, 134, 13))
	player_val = g.add_label(Rect2(454, 58, 98, 34), 22, MoonSkin.CREAM)
	lodge_val = g.add_label(Rect2(454, 114, 100, 36), 22, MoonSkin.CREAM)
	status_hover = g.add_hover(Rect2(40, 20, 530, 175))


func _gauge(g: W.MoonGroup, tex_id: String, abs_rect: Rect2) -> W.MoonGauge:
	var ga := W.MoonGauge.new()
	ga.fill_tex = MoonSkin.tex(tex_id)
	var r := g.local(abs_rect)
	ga.position = r.position
	ga.size = r.size
	g.add_child(ga)
	return ga


func _build_objective() -> void:
	var g := _group("objective")
	g.add_piece("objective", Rect2(5, 197, 398, 148))
	objective_text = g.add_label(Rect2(124, 260, 222, 42), 19, MoonSkin.PAPER_INK, true)
	objective_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_text.min_size = 14


func _build_phase() -> void:
	var g := _group("phase")
	g.add_piece("phase", Rect2(625, 7, 526, 175))
	phase_gauge = _gauge(g, "phase_fill", Rect2(754, 124, 268, 14))
	phase_title = g.add_label(Rect2(782, 30, 208, 44), 30, MoonSkin.CREAM)
	phase_sub = g.add_label(Rect2(782, 79, 208, 28), 19, Color8(226, 218, 236), true)
	phase_hover = g.add_hover(Rect2(700, 20, 380, 130))


func _build_resources() -> void:
	var g := _group("resources")
	g.add_piece("resources", Rect2(1197, 29, 468, 143))
	gold_val = g.add_label(Rect2(1279, 72, 66, 34), 28, MoonSkin.CREAM)
	timber_val = g.add_label(Rect2(1433, 72, 62, 34), 28, MoonSkin.CREAM)
	wool_val = g.add_label(Rect2(1576, 72, 62, 34), 28, MoonSkin.CREAM)
	for r in [Rect2(1210, 50, 148, 76), Rect2(1366, 50, 140, 76), Rect2(1510, 50, 140, 76)]:
		res_hovers.append(g.add_hover(r))


func _build_pause() -> void:
	var g := _group("pause")
	pause_btn = _button(g, "pause", Rect2(1668, 34, 105, 116))
	pause_btn.tooltip_text = "일시 정지 · Esc"
	pause_btn.pressed.connect(func(): hud._toggle_pause())


func _build_hand_tray() -> void:
	var g := _group("hand")
	g.add_piece("hand_tray", Rect2(460, 539, 856, 340))


func _build_storage() -> void:
	var g := _group("storage")
	storage_btn = _button(g, "storage", Rect2(3, 694, 195, 185))
	storage_btn.pressed.connect(func(): hud.card_hand.open_pocket())
	# 보관 장수 배지: 시안의 수량 배지 바탕 재사용(창고가 비면 숨김)
	storage_badge = Control.new()
	storage_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	storage_badge.position = g.local(Rect2(140, 700, 52, 44)).position
	storage_badge.size = Vector2(52, 44)
	g.add_child(storage_badge)
	var bg := TextureRect.new()
	bg.texture = MoonSkin.tex("stack_badge")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.size = storage_badge.size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	storage_badge.add_child(bg)
	storage_count = W.MoonLabel.new()
	storage_count.base_size = 22
	storage_count.add_theme_font_override("font", MoonSkin.font(true))
	storage_count.add_theme_font_size_override("font_size", 22)
	storage_count.add_theme_color_override("font_color", MoonSkin.CREAM)
	storage_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	storage_count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	storage_count.size = storage_badge.size
	storage_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	storage_badge.add_child(storage_count)


func _build_actions() -> void:
	var g := _group("actions")
	lodge_btn = _button(g, "lodge_button", Rect2(1315, 696, 225, 183))
	lodge_btn.pressed.connect(func(): hud.open_lodge_panel(1 if not game.guest_events.current_guests().is_empty() else 0))
	# 비활성: 시안의 보라·회색 용 그림 그대로. 활성: dragon_active 납품본(없으면 같은 그림을 착색).
	var active_id := "dragon_active" if MoonSkin.tex("dragon_active") != null else "dragon_disabled"
	dragon_btn = _button(g, active_id, Rect2(1540, 696, 233, 183), "dragon_disabled")
	if active_id == "dragon_disabled":
		dragon_btn.active_tint = Color(0.86, 0.74, 1.0, 0.55)
		dragon_btn._refresh()
	dragon_btn.pressed.connect(_on_dragon)
	dragon_label = g.add_label(Rect2(1556, 803, 194, 42), 22, Color8(160, 156, 172))


func _on_dragon() -> void:
	# 중복 소환·이중 차감 방지는 economy/dragon 모듈이 맡는다. 여기서는 한 번만 호출.
	game.economy.buy("dragon")


# ───────────────────────── 갱신 ─────────────────────────

func _process(delta: float) -> void:
	_tip_timer -= delta
	refresh(false)


func refresh(instant: bool) -> void:
	if game == null:
		return
	var s = game.session
	var eco = game.economy
	var pl = game.player
	var lo = game.world.lodge
	player_gauge.set_value(pl.hp / pl.max_hp if pl.max_hp > 0 else 0.0, instant)
	lodge_gauge.set_value(lo.hp / lo.max_hp if lo.max_hp > 0 else 0.0, instant)
	player_val.set_value("%d/%d" % [int(ceil(pl.hp)), int(pl.max_hp)])
	lodge_val.set_value("%d/%d" % [int(ceil(lo.hp)), int(lo.max_hp)])

	gold_val.set_value(str(eco.gold))
	timber_val.set_value(str(game.cards.hand_count_of("timber")))
	wool_val.set_value(str(game.cards.hand_count_of("wool")))

	_refresh_phase(s, instant)
	objective_text.set_value("◆ " + objective())

	var stored: int = game.cards.pocket().size()
	storage_badge.visible = stored > 0
	storage_count.set_value(str(stored))
	var over: bool = s.is_over()
	storage_btn.disabled = over

	var prep: bool = s.state == SessionScript.State.PREP
	lodge_btn.disabled = not prep
	var dr: String = eco.block_reason("dragon")
	dragon_btn.disabled = dr != ""
	# 활성 그림이 납품되기 전에는 같은 실루엣을 보라·크림으로 살짝 밝혀 활성 상태를 구분한다
	dragon_label.set_value("용 공물 %dG" % eco.cost_of("dragon"))
	dragon_label.add_theme_color_override("font_color", MoonSkin.CREAM if dr == "" else Color8(160, 156, 172))

	if _tip_timer <= 0.0 or instant:
		_tip_timer = 0.25
		_refresh_tooltips(dr)


func _refresh_phase(s, instant: bool) -> void:
	match s.state:
		SessionScript.State.PREP:
			var rem: float = s.prep_remaining()
			var sec := int(ceil(rem))
			phase_title.set_value("%d일차 · 낮" % s.day())
			phase_sub.set_value("밤까지 %02d:%02d" % [sec / 60, sec % 60])
			phase_gauge.set_value(s.prep_elapsed / Cfg.PREP_TIME, instant)
		SessionScript.State.COMBAT:
			var total: int = int(Cfg.WAVES[s.wave_index - 1]["count"]) if s.wave_index >= 1 else 0
			var left: int = game.waves.alive() + game.waves.pending()
			phase_title.set_value("웨이브 %d / %d" % [s.wave_index, Cfg.WAVES.size()])
			phase_sub.set_value("남은 적 %d · 출현 대기 %d" % [game.waves.alive(), game.waves.pending()])
			# 밤에는 시간 카운트다운 대신 이번 웨이브 처치 진행도
			phase_gauge.set_value(1.0 - float(left) / float(total) if total > 0 else 1.0, instant)
		SessionScript.State.CLEARING:
			phase_title.set_value("웨이브 %d 정리" % s.wave_index)
			phase_sub.set_value("용이 떠나는 중…" if game.dragon.is_present() else "숨을 고르는 중…")
			phase_gauge.set_value(1.0, instant)
		SessionScript.State.VICTORY:
			phase_title.set_value("시연 완료")
			phase_sub.set_value("모든 밤을 막아 냈습니다")
			phase_gauge.set_value(1.0, instant)
		SessionScript.State.DEFEAT:
			phase_title.set_value("게임 오버")
			phase_sub.set_value(s.defeat_reason)


## 오늘의 할 일(명세 §4.4): 종료 > 전투 > 정리 > 고용 제안 > 양털 준비 > 기본 방문 안내. 한 문구만.
func objective() -> String:
	var s = game.session
	match s.state:
		SessionScript.State.VICTORY:
			return "산장을 지켜 냈습니다"
		SessionScript.State.DEFEAT:
			return "다시 도전하세요"
		SessionScript.State.COMBAT:
			return "괴물에게서 산장을 지키세요"
		SessionScript.State.CLEARING:
			return "다음 밤을 준비하세요"
	if not game.economy.offers.is_empty():
		return "손님을 고용하세요"
	if game.world.pasture.ready_count() > 0:
		return "털 난 양을 수확하세요"
	return "손님을 맞이하세요"


func _refresh_tooltips(dragon_reason: String) -> void:
	var pasture = game.world.pasture
	var tip := "마녀 %d/%d · 산장 %d/%d\n양 %d/%d마리 · 털 준비 %d\n활동 중인 아군 %d/%d · 무덤 %d/%d" % [
		int(ceil(game.player.hp)), int(game.player.max_hp),
		int(ceil(game.world.lodge.hp)), int(game.world.lodge.max_hp),
		pasture.alive_count(), pasture.capacity(), pasture.ready_count(),
		game.contracts.active_count(), Cfg.ACTIVE_LIMIT, game.world.graveyard.count(), game.world.graveyard.capacity()]
	status_hover.tooltip_text = tip
	var s = game.session
	var eco = game.economy
	var parts: Array = []
	if s.state == SessionScript.State.PREP:
		parts.append("숙박 %d명 / 정원 %d" % [eco.guests_inside(), eco.capacity])
		var na: float = eco.next_arrival_in(s.prep_elapsed)
		if na >= 0.0:
			parts.append("다음 손님 %d초" % int(ceil(na)))
		var np: float = eco.next_payment_in(s.prep_elapsed)
		if np >= 0.0:
			parts.append("숙박비 %d초 후" % int(ceil(np)))
		parts.append("다음 웨이브 %d/%d" % [s.wave_index + 1, Cfg.WAVES.size()])
	else:
		parts.append("웨이브 %d/%d" % [s.wave_index, Cfg.WAVES.size()])
	phase_hover.tooltip_text = "\n".join(parts)
	res_hovers[0].tooltip_text = "골드 %dG\n숙박비·양털 판매로 벌고 산장 관리·고용·용 공물에 씁니다" % eco.gold
	res_hovers[1].tooltip_text = "목재 %d (손패) · 주머니 %d개는 뽑아야 사용\n준비 시간에 산장으로 끌어 수리 · %d개 → 체력 +%d" % [
		game.cards.hand_count_of("timber"), game.cards.pocket_count_of("timber"), Cfg.TIMBER_REPAIR_COST, int(Cfg.TIMBER_REPAIR_AMOUNT)]
	res_hovers[2].tooltip_text = "양털 %d (손패) · 주머니 %d개는 뽑아야 사용
준비 시간에 산장으로 끌어 판매 · 1개 %dG
생고기 %d · 토끼 가죽 %d · 보물상자 %d" % [game.cards.hand_count_of("wool"), game.cards.pocket_count_of("wool"), Cfg.WOOL_PRICE, game.cards.count_of("raw_meat"), game.cards.count_of("rabbit_pelt"), game.cards.count_of("treasure_chest")]
	var stored: int = game.cards.pocket().size()
	storage_btn.tooltip_text = "마녀의 주머니(덱) %d장 · 버림패 %d장 (손패 %d/%d)\n아침마다 주머니에서 무작위로 한 장이 손패로 옵니다" % [stored, game.cards.discard.size(), game.cards.hand().size(), Cfg.HAND_VISIBLE]
	lodge_btn.tooltip_text = "산장 관리 — 시설 · 손님과 대화 · 고용 · 대화 기록" if s.state == SessionScript.State.PREP else "산장 관리는 준비 시간(낮)에만 열 수 있습니다"
	dragon_btn.tooltip_text = ("용에게 공물 %dG — 지붕 위에 용이 내려와 불덩이를 쏩니다" % eco.cost_of("dragon")) if dragon_reason == "" else dragon_reason


# ───────────────────────── 원본 재현 모드 ─────────────────────────

## 승인 원본 8개 그룹을 같은 슬롯·같은 맞춤(KEEP_ASPECT_CENTERED)으로 배치한다. 픽셀 비교·시각 기준 전용.
## 예시 숫자가 그려진 그림이므로 일반 플레이에서는 쓰지 않는다.
class Reference extends Control:
	var rects: Dictionary = {}

	func _ready() -> void:
		name = "MoonReference"
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var atlas_tex: Texture2D = MoonSkin.atlas()
		for id in Layout.ORDER:
			var at := AtlasTexture.new()
			at.atlas = atlas_tex
			at.region = Layout.SLOTS[id]["atlas"]
			at.filter_clip = true
			var t := TextureRect.new()
			t.texture = at
			t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			t.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(t)
			rects[id] = t
		resized.connect(_relayout)
		_relayout()

	func _relayout() -> void:
		for id in rects:
			var r := Layout.slot_rect(id, size)
			rects[id].position = r.position
			rects[id].size = r.size
