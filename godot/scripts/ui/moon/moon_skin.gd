extends RefCounted
## 달빛 마법 UI 스킨: 색·글꼴·텍스처 조회·공통 StyleBox.
## 텍스처는 ID로 찾는다. 우선순위: runtime(Codex 최종 납품) → interim(승인 아틀라스에서 숫자만 지운 임시본).
## 최종 에셋이 들어오면 같은 ID 파일을 runtime/ 에 넣는 것만으로 교체된다(코드 변경 없음).

const RUNTIME_DIR := "res://assets/ui/moon_runes/runtime/"
const INTERIM_DIR := "res://assets/ui/moon_runes/interim/"
const ATLAS_PATH := "res://assets/ui/moon_runes/approved/atlas.png"
const BUTTON_SHADER := preload("res://shaders/moon_button.gdshader")
const Extension := preload("res://scripts/ui/moon/moon_extension.gd")

# 승인 시안에서 채취한 색
const INK := Color8(22, 12, 40)            # 패널 바탕(짙은 인디고)
const INK_SOFT := Color8(44, 26, 74)       # 버튼·행 바탕
const TRACK := Color8(39, 24, 66)          # 게이지 빈 트랙
const CREAM := Color8(252, 231, 176)       # 얇은 경계·숫자
const CREAM_DIM := Color8(214, 200, 178)
const TEAL := Color8(57, 189, 193)         # 작은 곡선·포커스
const LAVENDER := Color8(167, 150, 205)    # 보조 글
const WITCH_RED := Color8(215, 76, 99)
const PAPER_INK := Color8(48, 30, 44)      # 종이 위 글
const BAD := Color8(255, 132, 132)
const GOOD := Color8(150, 236, 196)

static var _cache: Dictionary = {}
static var _font: Font
static var _font_bold: Font


static func font(bold := false) -> Font:
	if _font == null:
		var names := PackedStringArray(["Malgun Gothic", "맑은 고딕", "Noto Sans KR", "Segoe UI"])
		var f := SystemFont.new()
		f.font_names = names
		f.font_weight = 500
		_font = f
		var b := SystemFont.new()
		b.font_names = names
		b.font_weight = 700
		_font_bold = b
	return _font_bold if bold else _font


## id에 해당하는 텍스처. 없으면 null.
static func tex(id: String) -> Texture2D:
	if _cache.has(id):
		return _cache[id]
	var t: Texture2D = null
	for dir in [RUNTIME_DIR, INTERIM_DIR]:
		var path: String = dir + id + ".png"
		if ResourceLoader.exists(path):
			t = load(path) as Texture2D
			break
	_cache[id] = t
	return t


## 최종 런타임 에셋이 쓰이는 중인지(검증·카탈로그 보고용)
static func source_of(id: String) -> String:
	if ResourceLoader.exists(RUNTIME_DIR + id + ".png"):
		return "runtime"
	if ResourceLoader.exists(INTERIM_DIR + id + ".png"):
		return "interim"
	return "missing"


static func atlas() -> Texture2D:
	if not _cache.has("__atlas"):
		_cache["__atlas"] = load(ATLAS_PATH) as Texture2D
	return _cache["__atlas"]


## 카드 손패 표면(제목+그림, 규칙 문구 없음): runtime/cards → interim/cards → 기존 카탈로그 손패 그림.
static func card_surface(card_id: String, fallback: Texture2D) -> Texture2D:
	var key := "cards/" + card_id
	if not _cache.has(key):
		_cache[key] = null
		for dir in [RUNTIME_DIR, INTERIM_DIR]:
			var path: String = dir + key + ".png"
			if ResourceLoader.exists(path):
				_cache[key] = load(path) as Texture2D
				break
	var t: Texture2D = _cache[key]
	if t == null or fallback == null:
		return t if t != null else fallback
	# 임시 표면은 손패 카드(2:3)와 비율이 같을 때만 쓴다. 비율이 다르면 그림이 눌리므로 카탈로그 손패 그림을 쓴다.
	var ratio_t := float(t.get_width()) / maxf(1.0, float(t.get_height()))
	var ratio_f := float(fallback.get_width()) / maxf(1.0, float(fallback.get_height()))
	return t if absf(ratio_t - ratio_f) < 0.03 else fallback


static func button_material() -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = BUTTON_SHADER
	return m


static func flat(bg: Color, border := Color(0, 0, 0, 0), radius := 12, margin := 12, width := 1) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(margin)
	s.anti_aliasing = true
	if border.a > 0.0:
		s.border_color = border
		s.set_border_width_all(width)
	return s


## 채택된 달빛 확장 원화의 공통 프레임(모달·툴팁·토스트).
static func modal_box() -> StyleBox:
	return Extension.modal()


static func tooltip_box() -> StyleBox:
	return Extension.paper()


static func toast_box() -> StyleBox:
	return Extension.toast()


static func row_box() -> StyleBox:
	return Extension.row()


static func make_theme() -> Theme:
	var t := Theme.new()
	t.default_font = font()
	t.default_font_size = 17
	t.set_stylebox("panel", "PanelContainer", modal_box())
	t.set_color("font_color", "Label", Color(0.96, 0.93, 0.98))
	t.set_constant("outline_size", "Label", 0)
	for state in ["normal", "hover", "pressed", "disabled"]:
		t.set_stylebox(state, "Button", Extension.button(state))
	t.set_stylebox("focus", "Button", Extension.focus())
	t.set_color("font_color", "Button", CREAM)
	t.set_color("font_hover_color", "Button", PAPER_INK)
	t.set_color("font_pressed_color", "Button", CREAM_DIM)
	t.set_color("font_focus_color", "Button", CREAM)
	t.set_color("font_disabled_color", "Button", Color(0.55, 0.52, 0.62))
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		t.set_stylebox(state, "OptionButton", t.get_stylebox(state, "Button"))
	t.set_color("font_color", "OptionButton", CREAM)
	t.set_color("font_hover_color", "OptionButton", PAPER_INK)
	t.set_icon("arrow", "OptionButton", Extension.scaled("arrow", 14))
	t.set_constant("arrow_margin", "OptionButton", 12)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		t.set_stylebox(state, "CheckButton", StyleBoxEmpty.new())
	for state in ["checked", "checked_disabled", "checked_mirrored"]:
		t.set_icon(state, "CheckButton", Extension.scaled("toggle_on", 48))
	for state in ["unchecked", "unchecked_disabled", "unchecked_mirrored"]:
		t.set_icon(state, "CheckButton", Extension.scaled("toggle_off", 48))
	t.set_color("font_color", "CheckButton", CREAM)
	t.set_color("font_hover_color", "CheckButton", CREAM)
	for type in ["TabContainer", "TabBar"]:
		t.set_stylebox("tab_selected", type, Extension.tab("hover"))
		t.set_stylebox("tab_unselected", type, Extension.tab())
		t.set_stylebox("tab_hovered", type, Extension.tab("hover"))
		t.set_stylebox("tab_disabled", type, Extension.tab("disabled"))
		t.set_stylebox("tab_focus", type, Extension.focus())
		t.set_color("font_selected_color", type, PAPER_INK)
		t.set_color("font_unselected_color", type, CREAM)
		t.set_color("font_hovered_color", type, PAPER_INK)
		t.set_font_size("font_size", type, 19)
		t.set_constant("h_separation", type, 6)
	t.set_constant("side_margin", "TabContainer", 4)
	t.set_stylebox("panel", "TabContainer", StyleBoxEmpty.new())
	t.set_stylebox("panel", "PopupMenu", Extension.modal())
	t.set_stylebox("hover", "PopupMenu", Extension.button("hover"))
	t.set_color("font_color", "PopupMenu", Color(0.92, 0.9, 0.96))
	t.set_color("font_hover_color", "PopupMenu", PAPER_INK)
	t.set_stylebox("panel", "TooltipPanel", tooltip_box())
	t.set_color("font_color", "TooltipLabel", PAPER_INK)
	t.set_font_size("font_size", "TooltipLabel", 15)
	t.set_stylebox("background", "ProgressBar", Extension.box("bar_track", 100, Vector4(6, 2, 6, 2), Vector4.ZERO))
	t.set_stylebox("fill", "ProgressBar", Extension.box("bar_fill", 100, Vector4(6, 2, 6, 2), Vector4.ZERO, TEAL))
	t.set_stylebox("scroll", "VScrollBar", Extension.box("scroll_vertical_track", 14, Vector4(4, 14, 4, 14), Vector4(7, 0, 7, 0)))
	for state in ["grabber", "grabber_highlight", "grabber_pressed"]:
		t.set_stylebox(state, "VScrollBar", Extension.box("scroll_vertical_thumb", 14, Vector4(4, 14, 4, 14), Vector4(7, 8, 7, 8)))
	var sep := StyleBoxLine.new()
	sep.color = Color(CREAM, 0.22)
	sep.thickness = 1
	t.set_stylebox("separator", "HSeparator", sep)
	return t
