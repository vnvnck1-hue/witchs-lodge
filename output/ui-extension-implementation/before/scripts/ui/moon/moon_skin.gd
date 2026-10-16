extends RefCounted
## 달빛 마법 UI 스킨: 색·글꼴·텍스처 조회·공통 StyleBox.
## 텍스처는 ID로 찾는다. 우선순위: runtime(Codex 최종 납품) → interim(승인 아틀라스에서 숫자만 지운 임시본).
## 최종 에셋이 들어오면 같은 ID 파일을 runtime/ 에 넣는 것만으로 교체된다(코드 변경 없음).

const RUNTIME_DIR := "res://assets/ui/moon_runes/runtime/"
const INTERIM_DIR := "res://assets/ui/moon_runes/interim/"
const ATLAS_PATH := "res://assets/ui/moon_runes/approved/atlas.png"
const BUTTON_SHADER := preload("res://shaders/moon_button.gdshader")

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
	return t if t != null else fallback


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


## 확장용 공통 프레임(모달·툴팁·토스트). 시안에 없는 팝업이라 승인 패널의 바탕/크림 경계만 따른다.
static func modal_box() -> StyleBox:
	var s := flat(Color(INK, 0.96), Color(CREAM, 0.78), 16, 22, 2)
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 10
	return s


static func tooltip_box() -> StyleBox:
	return flat(Color(INK, 0.95), Color(CREAM, 0.6), 10, 12, 1)


static func toast_box() -> StyleBox:
	return flat(Color(INK, 0.82), Color(TEAL, 0.45), 10, 8, 1)


static func row_box() -> StyleBox:
	return flat(Color(INK_SOFT, 0.55), Color(CREAM, 0.12), 10, 10, 1)


static func make_theme() -> Theme:
	var t := Theme.new()
	t.default_font = font()
	t.default_font_size = 17
	t.set_stylebox("panel", "PanelContainer", modal_box())
	t.set_color("font_color", "Label", Color(0.96, 0.93, 0.98))
	t.set_constant("outline_size", "Label", 0)
	var r := 10
	t.set_stylebox("normal", "Button", flat(Color(INK_SOFT, 0.96), Color(CREAM, 0.55), r, 9))
	t.set_stylebox("hover", "Button", flat(Color8(58, 36, 94), Color(TEAL, 0.9), r, 9))
	t.set_stylebox("pressed", "Button", flat(Color8(34, 20, 58), Color(TEAL, 0.9), r, 9))
	t.set_stylebox("disabled", "Button", flat(Color(0.14, 0.12, 0.2, 0.8), Color(CREAM, 0.16), r, 9))
	t.set_stylebox("focus", "Button", flat(Color(0, 0, 0, 0), Color(TEAL, 0.95), r, 9, 2))
	t.set_color("font_color", "Button", CREAM)
	t.set_color("font_hover_color", "Button", Color(1, 0.97, 0.88))
	t.set_color("font_pressed_color", "Button", CREAM_DIM)
	t.set_color("font_focus_color", "Button", CREAM)
	t.set_color("font_disabled_color", "Button", Color(0.55, 0.52, 0.62))
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		t.set_stylebox(state, "OptionButton", t.get_stylebox(state, "Button"))
	t.set_color("font_color", "OptionButton", CREAM)
	t.set_stylebox("panel", "PopupMenu", flat(Color(INK, 0.98), Color(CREAM, 0.5), 8, 6))
	t.set_stylebox("hover", "PopupMenu", flat(Color(TEAL, 0.28), Color(0, 0, 0, 0), 6, 4))
	t.set_color("font_color", "PopupMenu", Color(0.92, 0.9, 0.96))
	t.set_color("font_hover_color", "PopupMenu", CREAM)
	t.set_stylebox("panel", "TooltipPanel", tooltip_box())
	t.set_color("font_color", "TooltipLabel", Color(0.95, 0.93, 0.98))
	t.set_font_size("font_size", "TooltipLabel", 15)
	t.set_stylebox("background", "ProgressBar", flat(Color(TRACK, 0.95), Color(0, 0, 0, 0), 5, 0))
	t.set_stylebox("fill", "ProgressBar", flat(TEAL, Color(0, 0, 0, 0), 5, 0))
	t.set_stylebox("scroll", "VScrollBar", flat(Color(INK_SOFT, 0.5), Color(0, 0, 0, 0), 4, 2))
	t.set_stylebox("grabber", "VScrollBar", flat(Color(LAVENDER, 0.6), Color(0, 0, 0, 0), 4, 2))
	t.set_stylebox("grabber_highlight", "VScrollBar", flat(Color(TEAL, 0.8), Color(0, 0, 0, 0), 4, 2))
	t.set_stylebox("grabber_pressed", "VScrollBar", flat(TEAL, Color(0, 0, 0, 0), 4, 2))
	var sep := StyleBoxLine.new()
	sep.color = Color(CREAM, 0.22)
	sep.thickness = 1
	t.set_stylebox("separator", "HSeparator", sep)
	return t
