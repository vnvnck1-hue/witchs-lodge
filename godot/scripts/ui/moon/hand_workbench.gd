extends Control
## 최대 8장 손패 폭에 고정한 후면 장식. 카드 수·확대·드래그에 따라 이동하지 않는다.

const Layout := preload("res://scripts/ui/moon/moon_layout.gd")
const SHEET := preload("res://assets/ui/hand_workbench/witch-props-v02.png")
const INK := preload("res://assets/ui/hand_workbench/subdued_props.gdshader")

# 원본 영역 / 1600×800 디자인 좌표. 가운데 소품은 카드 바닥선보다 위에 둔다.
const PIECES := [
	["SpellbookAndCandle", Rect2(16, 116, 446, 330), Rect2(328, 654, 176, 130)],
	["PotionsAndHerbs", Rect2(478, 80, 410, 365), Rect2(1100, 638, 164, 146)],
	["InkAndQuill", Rect2(948, 220, 388, 212), Rect2(536, 724, 68, 38)],
	["DriedHerbs", Rect2(1350, 215, 414, 210), Rect2(623, 737, 52, 26)],
	["RolledParchment", Rect2(28, 618, 430, 200), Rect2(757, 738, 55, 25)],
	["IngredientPouch", Rect2(540, 514, 310, 322), Rect2(1024, 724, 36, 38)],
	["MoonCharm", Rect2(1012, 542, 200, 300), Rect2(972, 737, 18, 26)],
]

var game
var pieces: Array[TextureRect] = []


func _ready() -> void:
	name = "HandWorkbench"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var subdued := ShaderMaterial.new()
	subdued.shader = INK
	for spec in PIECES:
		var pic := _piece(spec[0], spec[1])
		pic.material = subdued
		pieces.append(pic)
	resized.connect(_place)
	_place()


func _piece(id: String, region: Rect2) -> TextureRect:
	var atlas := AtlasTexture.new()
	atlas.atlas = SHEET
	atlas.region = region
	atlas.filter_clip = true
	var pic := TextureRect.new()
	pic.name = id
	pic.texture = atlas
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pic)
	return pic


func _process(_delta: float) -> void:
	if game != null:
		visible = not game.session.is_over()


func _place() -> void:
	var s := Layout.ui_scale(size)
	for i in pieces.size():
		var rect: Rect2 = PIECES[i][2]
		pieces[i].position = Layout.to_view(rect.position, Vector2(0.5, 1), size)
		pieces[i].size = rect.size * s
