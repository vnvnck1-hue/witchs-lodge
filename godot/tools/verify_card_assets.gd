extends SceneTree
## Verify shipping files and imported resources, not card gameplay.

const Catalog = preload("res://scripts/ui/card_catalog.gd")
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
		_verify_texture(entry.texture, Vector2i(1024, 1536))
		_verify_texture(entry.hand_texture, Vector2i(256, 384))
		_check(Catalog.texture(id) != null, "Catalogue cannot load: " + id)
		_check(Catalog.texture(id, true) != null, "Catalogue cannot load hand: " + id)
	_check(ids == ["axe_mercenary", "wool", "timber", "forest_monster"], "Card list differs from v0.3")
	_verify_texture(catalog.get("back", ""), Vector2i(1024, 1536))
	_verify_texture(catalog.get("back_hand", ""), Vector2i(256, 384))
	_check(Catalog.back() != null and Catalog.back(true) != null, "Missing shared back")
	_check(Catalog.texture("unknown_card") == null, "Unknown card should return null")
	var result := {"passed": failures.is_empty(), "cards": ids, "texture_count": 10, "failures": failures}
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
