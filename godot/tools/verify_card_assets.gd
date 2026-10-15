extends SceneTree
## Verify shipping files and imported resources, not card gameplay.

const Catalog = preload("res://scripts/ui/card_catalog.gd")
const NEW_CARD_TEXT := {"frost_rune":["서리 룬","주문 · 마녀의 룬",["적이나 땅에 새기면 터집니다.","주변 적을 얼려 느리게 합니다."]],"ward_lantern":["수호 등불","설치물 · 마녀의 등불",["땅에 놓으면 불을 밝힙니다.","빛 안의 적은 느려집니다."]],"guest_invitation":["숙박 초대장","산장 · 손님 초대",["산장에 놓으면 손님이 옵니다.","낮에만 사용할 수 있습니다."]],"lamb":["새끼양","가축 · 목장 입식",["목장에 놓으면 새끼양이 옵니다.","이틀 뒤 어른 양이 됩니다."]]}
var failures: Array[String] = []

func _initialize() -> void:
	var catalog := Catalog.read()
	var entries: Array = catalog.get("cards", [])
	var ids: Array[String] = []
	for entry in entries:
		var id: String = entry.id
		_check(not ids.has(id), "Duplicate id: " + id)
		ids.append(id)
		_check(not entry.description.is_empty(), "Missing description: " + id)
		_check(entry.printed_rules.size() == 2, "Missing rules: " + id)
		if NEW_CARD_TEXT.has(id):
			var expected: Array = NEW_CARD_TEXT[id]
			_check(entry.get("name", "") == expected[0], "Title differs from handoff: " + id)
			_check(entry.get("category", "") == expected[1], "Category differs from handoff: " + id)
			_check(entry.get("printed_rules", []) == expected[2], "Printed rules differ from handoff: " + id)
		_verify_texture(entry.texture, Vector2i(1024, 1536))
		_verify_texture(entry.hand_texture, Vector2i(256, 384))
		_check(Catalog.texture(id) != null, "Catalogue cannot load: " + id)
		_check(Catalog.texture(id, true) != null, "Catalogue cannot load hand: " + id)
	_check(ids == ["axe_mercenary", "wool", "timber", "forest_monster", "frost_rune", "ward_lantern", "guest_invitation", "lamb"], "Card list differs from new-cards-v01")
	_verify_texture(catalog.get("back", ""), Vector2i(1024, 1536))
	_verify_texture(catalog.get("back_hand", ""), Vector2i(256, 384))
	_check(Catalog.back() != null and Catalog.back(true) != null, "Missing shared back")
	_check(Catalog.find("unknown_card").is_empty(), "Unknown card should have no catalogue entry")
	_check(Catalog.texture("unknown_card") == Catalog.back(), "Unknown card should use shared back")
	_check(Catalog.texture("unknown_card", true) == Catalog.back(true), "Unknown hand card should use shared back")
	var result := {"passed": failures.is_empty(), "cards": ids, "texture_count": (ids.size() + 1) * 2, "failures": failures}
	var file := FileAccess.open("res://assets/cards/verification.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(result, "\t") + "\n")
	print("CARD_ASSETS_VERIFY ", JSON.stringify(result))
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _verify_texture(path: String, expected: Vector2i) -> void:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty():
		_check(false, "Missing PNG: " + path)
		return
	_check(image.get_size() == expected, "Wrong dimensions: " + path)
	_check(image.get_format() == Image.FORMAT_RGBA8, "Expected RGBA PNG: " + path)
	for pos in [Vector2i.ZERO, Vector2i(expected.x - 1, 0), Vector2i(0, expected.y - 1), expected - Vector2i.ONE]:
		_check(image.get_pixelv(pos).a < 0.02, "Opaque corner: " + path + " " + str(pos))
	_check(image.get_pixelv(expected / 2).a > 0.95, "Transparent card centre: " + path)
	var inset: int = maxi(3, expected.x / 64)
	for pos in [Vector2i(expected.x / 2, inset), Vector2i(inset, expected.y / 2), Vector2i(expected.x - 1 - inset, expected.y / 2), Vector2i(expected.x / 2, expected.y - 1 - inset)]:
		_check(image.get_pixelv(pos).a > 0.95, "Translucent or missing outer card edge: " + path + " " + str(pos))
	var texture = load(path)
	_check(texture is Texture2D, "Import failed: " + path)
	if texture is Texture2D:
		_check(Vector2i(texture.get_size()) == expected, "Import dimensions: " + path)
