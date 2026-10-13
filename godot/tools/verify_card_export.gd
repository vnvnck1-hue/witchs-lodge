extends SceneTree
## Run this external source script against an exported PCK to verify inclusion.

func _initialize() -> void:
	var catalog_path := "res://assets/cards/catalog.json"
	if not FileAccess.file_exists(catalog_path):
		push_error("Card catalogue missing from exported PCK")
		quit(1)
		return
	var catalog = JSON.parse_string(FileAccess.get_file_as_string(catalog_path))
	if not catalog is Dictionary or catalog.get("cards", []).size() != 4:
		push_error("Invalid exported catalogue")
		quit(1)
		return
	var paths: Array[String] = [catalog.back, catalog.back_hand]
	for entry in catalog.cards:
		paths.append(entry.texture)
		paths.append(entry.hand_texture)
	for path in paths:
		if not ResourceLoader.exists(path) or not load(path) is Texture2D:
			push_error("Texture missing from exported PCK: " + path)
			quit(1)
			return
	print("CARD_EXPORT_VERIFY passed: catalogue and 10 textures in exported PCK")
	quit()
