extends RefCounted
## Card asset catalogue (names, rules text, textures). Ownership lives in game/card_inventory.gd,
## use rules in game/card_use_resolver.gd.

const DATA_PATH := "res://assets/cards/catalog.json"

static func read() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if not parsed is Dictionary:
		push_error("Invalid card catalogue: " + DATA_PATH)
		return {}
	return parsed

static func find(card_id: String) -> Dictionary:
	for entry in read().get("cards", []):
		if entry.get("id", "") == card_id:
			return entry.duplicate(true)
	return {}

static func texture(card_id: String, hand := false) -> Texture2D:
	var entry := find(card_id)
	var key := "hand_texture" if hand else "texture"
	# 원화가 아직 납품되지 않은 카드는 공용 뒷면으로 대신 보인다.
	if not entry.has(key) or not ResourceLoader.exists(entry[key]):
		return back(hand)
	return load(entry[key]) as Texture2D

static func back(hand := false) -> Texture2D:
	var data := read()
	var key := "back_hand" if hand else "back"
	return load(data[key]) as Texture2D if data.has(key) else null
