extends Control
## 최대 8장 손패 폭에 고정한 후면 장식. 카드 수·확대·드래그에 따라 이동하지 않는다.

const Layout := preload("res://scripts/ui/moon/moon_layout.gd")
const APPROVED := preload("res://assets/ui/hand_workbench/approved/layout-v04.png")
const UNDER_CARDS := preload("res://assets/ui/hand_workbench/approved/layout-v03.png")

# 승인 원화 좌표를 그대로 쓴다. 외곽만 마스킹하며 색·형태·개별 크기·간격은 재해석하지 않는다.
# 원화의 카드 높이 282px -> 실제 카드 147px. 카드 바닥선도 기존 y=772에 맞춘다.
const ART_SCALE := 147.0 / 282.0
const ART_CENTER_X := 724.0
const ART_CARD_BOTTOM := 499.0

var game
var pieces: Array[Control] = []
var source_canvas: Control


func _ready() -> void:
	name = "HandWorkbench"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	source_canvas = Control.new()
	source_canvas.name = "ApprovedArtCoordinates"
	source_canvas.size = Vector2(1448, 543)
	source_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(source_canvas)
	_piece("SpellbookAndCandle", APPROVED, [
		Vector2(106,316),Vector2(111,332),Vector2(106,348),Vector2(119,350),Vector2(125,367),
		Vector2(140,373),Vector2(153,371),Vector2(172,377),Vector2(199,385),Vector2(225,393),
		Vector2(259,398),Vector2(296,410),Vector2(303,434),Vector2(317,444),Vector2(331,455),
		Vector2(324,466),Vector2(337,475),Vector2(324,479),Vector2(333,489),Vector2(310,490),
		Vector2(297,496),Vector2(269,494),Vector2(245,499),Vector2(223,505),Vector2(199,500),
		Vector2(182,507),Vector2(158,500),Vector2(145,508),Vector2(123,500),Vector2(103,501),
		Vector2(100,490),Vector2(84,492),Vector2(87,481),Vector2(73,479),Vector2(80,465),
		Vector2(66,457),Vector2(72,447),Vector2(70,435),Vector2(78,425),Vector2(72,414),
		Vector2(84,408),Vector2(83,389),Vector2(80,377),Vector2(87,369),Vector2(85,350),
		Vector2(99,347),Vector2(100,334),
	])
	_piece("PotionsAndHerbs", APPROVED, [
		Vector2(1268,297),Vector2(1285,292),Vector2(1309,294),Vector2(1333,302),Vector2(1328,326),
		Vector2(1342,341),Vector2(1335,357),Vector2(1339,370),Vector2(1358,382),Vector2(1376,405),
		Vector2(1384,432),Vector2(1400,413),Vector2(1408,442),Vector2(1403,460),Vector2(1412,468),
		Vector2(1406,481),Vector2(1414,487),Vector2(1399,492),Vector2(1405,499),Vector2(1386,501),
		Vector2(1370,497),Vector2(1357,504),Vector2(1345,496),Vector2(1324,502),Vector2(1307,495),
		Vector2(1287,504),Vector2(1279,496),Vector2(1256,502),Vector2(1251,493),Vector2(1233,500),
		Vector2(1223,491),Vector2(1206,496),Vector2(1202,487),Vector2(1185,491),Vector2(1187,481),
		Vector2(1165,483),Vector2(1177,471),Vector2(1155,468),Vector2(1173,457),Vector2(1160,450),
		Vector2(1184,444),Vector2(1188,430),Vector2(1196,408),Vector2(1205,400),Vector2(1208,383),
		Vector2(1202,375),Vector2(1217,348),Vector2(1235,369),Vector2(1233,382),Vector2(1237,398),
		Vector2(1243,401),Vector2(1255,383),Vector2(1271,371),Vector2(1276,354),Vector2(1265,346),
		Vector2(1260,335),Vector2(1272,325),
	])
	_piece("InkAndQuill", APPROVED, [
		Vector2(315,357),Vector2(335,358),Vector2(355,371),Vector2(376,393),Vector2(393,414),
		Vector2(409,421),Vector2(425,422),Vector2(437,434),Vector2(433,445),Vector2(444,454),
		Vector2(442,492),Vector2(419,501),Vector2(389,489),Vector2(383,458),Vector2(384,447),
		Vector2(371,436),Vector2(365,421),Vector2(349,407),Vector2(333,387),Vector2(321,375),
	])
	_piece("DriedHerbs", UNDER_CARDS, [
		Vector2(450,446),Vector2(464,452),Vector2(462,437),Vector2(480,446),Vector2(488,439),
		Vector2(500,451),Vector2(515,447),Vector2(528,459),Vector2(541,451),Vector2(557,457),
		Vector2(563,468),Vector2(578,468),Vector2(572,479),Vector2(578,485),Vector2(566,488),
		Vector2(572,500),Vector2(552,498),Vector2(548,508),Vector2(532,502),Vector2(519,508),
		Vector2(508,497),Vector2(491,501),Vector2(482,489),Vector2(465,491),Vector2(460,481),
		Vector2(447,483),Vector2(452,470),Vector2(441,465),Vector2(455,461),
	])
	_piece("RolledParchment", UNDER_CARDS, [
		Vector2(568,454),Vector2(601,453),Vector2(627,447),Vector2(651,446),Vector2(663,451),
		Vector2(668,471),Vector2(659,481),Vector2(634,483),Vector2(606,485),Vector2(574,487),
	])
	_piece("IngredientPouch", APPROVED, [
		Vector2(1008,408),Vector2(1016,398),Vector2(1031,398),Vector2(1048,393),Vector2(1062,391),
		Vector2(1070,401),Vector2(1062,415),Vector2(1068,429),Vector2(1077,445),Vector2(1087,465),
		Vector2(1089,481),Vector2(1079,491),Vector2(1059,497),Vector2(1039,494),Vector2(1020,488),
		Vector2(1007,478),Vector2(1001,463),Vector2(1009,442),Vector2(1020,424),Vector2(1020,416),
	])
	_piece("MoonCharm", APPROVED, [
		Vector2(1092,438),Vector2(1102,438),Vector2(1108,447),Vector2(1103,459),Vector2(1119,461),
		Vector2(1128,469),Vector2(1114,471),Vector2(1103,480),Vector2(1106,489),Vector2(1120,491),
		Vector2(1131,484),Vector2(1126,497),Vector2(1115,502),Vector2(1099,500),Vector2(1085,490),
		Vector2(1082,477),Vector2(1088,465),Vector2(1094,459),Vector2(1088,452),
	])
	resized.connect(_place)
	_place()


func _piece(id: String, tex: Texture2D, outline: PackedVector2Array) -> void:
	var pic := ArtPiece.new()
	pic.name = id
	pic.texture = tex
	pic.outline = outline
	var bounds := Rect2(outline[0], Vector2.ZERO)
	for point in outline:
		bounds = bounds.expand(point)
	pic.source_origin = bounds.position
	pic.position = bounds.position
	pic.size = bounds.size
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	source_canvas.add_child(pic)
	pieces.append(pic)


func _process(_delta: float) -> void:
	if game != null:
		visible = not game.session.is_over()


func _place() -> void:
	var s := Layout.ui_scale(size)
	source_canvas.position = Layout.to_view(Vector2(800 - ART_CENTER_X * ART_SCALE,
		772 - ART_CARD_BOTTOM * ART_SCALE), Vector2(0.5, 1), size)
	source_canvas.scale = Vector2.ONE * ART_SCALE * s


class ArtPiece extends Control:
	var texture: Texture2D
	var outline: PackedVector2Array
	var source_origin: Vector2

	func _draw() -> void:
		var points := PackedVector2Array()
		var uv := PackedVector2Array()
		for point in outline:
			points.append(point - source_origin)
			uv.append(point / texture.get_size())
		draw_polygon(points, PackedColorArray([Color.WHITE]), uv, texture)
