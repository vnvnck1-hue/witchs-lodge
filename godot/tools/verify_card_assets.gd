extends SceneTree
## Verify shipping files and imported resources, not card gameplay.

const Catalog = preload("res://scripts/ui/card_catalog.gd")
const NEW_CARD_TEXT := {"frost_rune":["서리 룬","주문 · 마녀의 룬",["적이나 땅에 새기면 터집니다.","주변 적을 얼려 느리게 합니다."]],"ward_lantern":["수호 등불","설치물 · 마녀의 등불",["땅에 놓으면 불을 밝힙니다.","빛 안의 적은 느려집니다."]],"guest_invitation":["숙박 초대장","산장 · 손님 초대",["산장에 놓으면 손님이 옵니다.","낮에만 사용할 수 있습니다."]],"lamb":["새끼양","가축 · 목장 입식",["목장에 놓으면 새끼양이 옵니다.","이틀 뒤 어른 양이 됩니다."]]}
const JOB_CARD_TEXT := {"lumberjack":["나무꾼","용병 · 벌목 계약",["나무에 사용하면 벌목합니다.","목재를 들고 있다가 건네줍니다."]],"hunter":["사냥꾼","용병 · 사냥 계약",["낮에는 토끼와 사슴을 사냥합니다.","밤에는 활로 산장을 지킵니다."]],"warrior":["전투용병","용병 · 전투 계약",["산장 주변을 정찰합니다.","적이 오면 검으로 맞섭니다."]],"gatherer":["채집가","용병 · 채집 계약",["낮에 숲을 탐색하고 돌아옵니다.","쓸모 있는 것을 주워 옵니다."]],"raw_meat":["생고기","자원 · 사냥 재료",["사냥과 채집으로 얻습니다.","판매하거나 마녀가 먹습니다."]],"rabbit_pelt":["토끼 가죽","자원 · 사냥 재료",["토끼를 사냥하면 얻습니다.","산장에서 판매할 수 있습니다."]],"treasure_chest":["보물상자","보물 · 숲의 발견",["땅에 놓으면 상자가 열립니다.","유물 셋 중 하나를 고릅니다."]],"relic_unknown":["?","유물 · 미공개",[]],"moonlit_charm":["달빛 부적","유물 · 마녀의 힘",["마녀의 마법탄이 강해집니다.","더 멀리 닿습니다."]],"hearth_ember":["화로의 온기석","유물 · 산장의 온기",["산장 곁의 아군이 회복합니다.","아침마다 산장이 아물어 갑니다."]],"old_tree_heart":["고목의 심장","유물 · 숲의 축복",["벌목이 빨라집니다.","목재를 더 많이 얻습니다."]],"wolf_fang_pendant":["늑대 송곳니 목걸이","유물 · 사냥의 본능",["사냥꾼과 전투용병이 강해집니다.","사냥감에서 더 얻습니다."]],"frost_queen_tear":["서리 여왕의 눈물","유물 · 겨울의 저주",["모든 적이 느려집니다.","아침마다 서리 룬을 얻습니다."]]}
const Package = preload("res://tools/package_card_assets.gd")
const POCKET_CARD_TEXT := {
	"poison_mushroom": ["독버섯", "재료 · 숲의 독", ["마녀의 체력을 깎습니다.", "대신 주머니에서 한 장을 뽑습니다."]],
	"old_spellbook": ["오래된 마법서적", "주문 · 마녀의 서적", ["주머니의 카드 세 장을 펼칩니다.", "그중 한 장을 골라 뽑습니다."]]
}
const EXPANSION_CARD_TEXT := {
	"moss_bandage": [
		"이끼 붕대",
		"숲 카드 · 회복과 정화",
		[
			"마녀에게 놓아 체력을 돌봅니다.",
			"침식 카드 한 장을 정화합니다."
		]
	],
	"resin_torch": [
		"송진 횃불",
		"숲 카드 · 지속 불길",
		[
			"밤에 땅이나 적에게 던집니다.",
			"잠시 동안 불길이 적을 태웁니다."
		]
	],
	"firefly_swarm": [
		"반딧불이 떼",
		"숲 카드 · 시야",
		[
			"땅에 풀어 안개를 걷어 냅니다.",
			"오늘 밤 전투가 끝나면 흩어집니다."
		]
	],
	"vine_snare": [
		"덩굴 덫",
		"숲 카드 · 속박",
		[
			"밤에 땅이나 적에게 놓습니다.",
			"주변 적을 덩굴로 묶습니다."
		]
	],
	"winter_firewood": [
		"겨울 장작",
		"숲 카드 · 산장 보강",
		[
			"산장에 놓아 벽을 보강합니다.",
			"밤에도 쓸 수 있습니다."
		]
	],
	"shroud_cloth": [
		"수의",
		"권능 · 수의의 의식",
		[
			"오늘 밤 마녀와 아군이",
			"치명타를 한 번 버팁니다."
		]
	],
	"thorn_bind": [
		"가시 속박",
		"권능 · 가시의 봉헌",
		[
			"밤에 땅이나 적에게 놓습니다.",
			"넓은 범위의 적을 가시로 묶습니다."
		]
	],
	"red_chalice": [
		"붉은 잔",
		"권능 · 붉은 만찬",
		[
			"마녀에게 놓습니다.",
			"오늘 밤 마법탄이 체력을 되돌립니다."
		]
	],
	"hibernation_pelt": [
		"겨울잠 털가죽",
		"전리품 · 빈 굴의 주인",
		[
			"산장에 덮습니다.",
			"오늘 밤 산장이 받는 피해가 절반입니다."
		]
	],
	"corrupt_prayer": [
		"침식된 기도문",
		"침식 · 쓸 수 없음",
		[
			"사용할 수 없습니다.",
			"손패 한 칸을 차지합니다."
		]
	],
	"poison_spore": [
		"독 포자",
		"침식 · 쓸 수 없음",
		[
			"사용할 수 없습니다.",
			"손패에 있으면 새벽마다 체력을 잃습니다."
		]
	],
	"cursed_whisper": [
		"저주의 속삭임",
		"침식 · 쓸 수 없음",
		[
			"사용할 수 없습니다.",
			"손패에 있으면 아침 드로우를 막습니다."
		]
	]
}
var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
	var catalog := Catalog.read()
	var entries: Array = catalog.get("cards", [])
	var ids: Array[String] = []
	var additional_catalog_ids: Array[String] = []
	var pending_catalog_ids: Array[String] = []
	for entry in entries:
		var id: String = entry.id
		if not Package.IDS.has(id):
			additional_catalog_ids.append(id)
			continue
		_check(not ids.has(id), "Duplicate id: " + id)
		ids.append(id)
		_check(not entry.description.is_empty(), "Missing description: " + id)
		_check(entry.printed_rules.size() == (0 if id == "relic_unknown" else 2), "Missing rules: " + id)
		if NEW_CARD_TEXT.has(id) or JOB_CARD_TEXT.has(id) or POCKET_CARD_TEXT.has(id) or EXPANSION_CARD_TEXT.has(id):
			var expected: Array = EXPANSION_CARD_TEXT.get(id, POCKET_CARD_TEXT.get(id, JOB_CARD_TEXT.get(id, NEW_CARD_TEXT.get(id, []))))
			_check(entry.get("name", "") == expected[0], "Title differs from handoff: " + id)
			_check(entry.get("category", "") == expected[1], "Category differs from handoff: " + id)
			_check(entry.get("printed_rules", []) == expected[2], "Printed rules differ from handoff: " + id)
		_verify_texture(entry.texture, Vector2i(1024, 1536))
		_verify_texture(entry.hand_texture, Vector2i(256, 384))
		_check(Catalog.texture(id) != null, "Catalogue cannot load: " + id)
		_check(Catalog.texture(id, true) != null, "Catalogue cannot load hand: " + id)
	for id in Package.IDS:
		if id == "card_back":
			continue
		if id == "axe_mercenary" and not ids.has(id):
			_verify_texture("res://assets/cards/axe_mercenary.png", Vector2i(1024,1536))
			_verify_texture("res://assets/cards/hand/axe_mercenary.png", Vector2i(256,384))
		elif POCKET_CARD_TEXT.has(id) and not ids.has(id):
			# Catalog integration belongs to the concurrent gameplay handoff.
			# Still verify the actual new PNGs and imported textures directly.
			pending_catalog_ids.append(id)
			_verify_texture("res://assets/cards/" + id + ".png", Vector2i(1024,1536))
			_verify_texture("res://assets/cards/hand/" + id + ".png", Vector2i(256,384))
		else:
			_check(ids.has(id), "Missing catalog entry: " + id)
	_check(Package.IDS.size() == 39, "Expected 38 faces including expansion cards + one shared back")
	_verify_texture(catalog.get("back", ""), Vector2i(1024, 1536))
	_verify_texture(catalog.get("back_hand", ""), Vector2i(256, 384))
	_check(Catalog.back() != null and Catalog.back(true) != null, "Missing shared back")
	_check(Catalog.find("unknown_card").is_empty(), "Unknown card should have no catalogue entry")
	_check(Catalog.texture("unknown_card") == Catalog.back(), "Unknown card should use shared back")
	_check(Catalog.texture("unknown_card", true) == Catalog.back(true), "Unknown hand card should use shared back")
	var result := {"passed": failures.is_empty(), "cards": Package.IDS.slice(0,-1), "catalog_ids":ids,
		"asset_ids":Package.IDS, "face_count":38, "shared_back_count":1, "asset_count":39,
		"texture_count":78, "legacy_preserved":["axe_mercenary"],
		"expansion_expected_printed_text":EXPANSION_CARD_TEXT,
		"pending_catalog_ids":pending_catalog_ids, "pocket_expected_printed_text":POCKET_CARD_TEXT,
		"catalog_integration_complete":pending_catalog_ids.is_empty(),
		"validation_profiles":{"production":"All 39 v02 assets: RGBA; exact dimensions; corners < 0.02; centre/side insets > 0.95; imported Texture2D"},
		"additional_catalog_ids_outside_handoff":additional_catalog_ids,
		"count_note":"37 active fronts + preserved axe mercenary + shared back; role-format-v02 including 12 expansion cards.",
		"visual_text_review":"art/cards/expansion-cards-v01-review.md", "failures": failures,
		"checks":checks, "passed_checks":checks - failures.size()}
	var file := FileAccess.open("res://assets/cards/verification.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(result, "\t") + "\n")
	print("CARD_ASSETS_VERIFY ", JSON.stringify(result))
	print("RESULT ", checks - failures.size(), "/", checks)
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool, message: String) -> void:
	checks += 1
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
