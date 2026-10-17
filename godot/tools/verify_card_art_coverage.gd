extends SceneTree
## 게임이 지급할 수 있는 모든 카드가 카탈로그에 있고, 임시(placeholder)가 아닌 정식 원화를 쓰는지 검사한다.
## 임시 카드(tools/build_expansion_placeholder_cards.py)는 단색 면이라 원화 영역의 색 수가 매우 적다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_card_art_coverage.gd

const Cfg := preload("res://scripts/config.gd")
const ChapterData := preload("res://scripts/game/chapter_data.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")

const MIN_ART_COLORS := 300   # 원화 영역 표본의 서로 다른 색 수 하한(임시 카드는 수십 개)

var passed := 0
var total := 0


func _initialize() -> void:
	var catalog := Catalog.read()
	var by_id := {}
	for e in catalog.get("cards", []):
		by_id[e["id"]] = e

	# 게임 코드가 지급하는 카드 id 전부
	var granted := {}
	for pair in Cfg.STARTER_CARDS:
		granted[pair[0]] = "시작 카드"
	for id in Cfg.JOB_CARDS:
		granted[id] = "용병"
	for id in Cfg.RELICS:
		granted[id] = "유물"
	for id in Cfg.CORRUPTION_CARDS:
		granted[id] = "침식"
	for r in Cfg.RITUALS.values():
		granted[r["power"]] = "의식 권능"
	granted[Cfg.BOSS_TROPHY] = "보스 전리품"
	for row in Cfg.GATHER_TABLE:
		if row[0] != "":
			granted[row[0]] = "채집"
	for id in ChapterData.REWARD_POOL + ChapterData.MARKET_POOL:
		granted[id] = "보상·장날"
	for id in ["forest_monster", "wool", "black_wool", "timber", "raw_meat", "rabbit_pelt", "relic_unknown"]:
		granted[id] = "기본"

	for id in granted:
		_check(by_id.has(id), "카탈로그 등록: %s (%s)" % [id, granted[id]])

	for id in by_id:
		var e: Dictionary = by_id[id]
		_check(not e.get("placeholder", false), "placeholder 표시 없음: " + id)
		_check(ResourceLoader.exists(e.get("texture", "")), "게임용 텍스처 존재: " + id)
		_check(ResourceLoader.exists(e.get("hand_texture", "")), "손패 텍스처 존재: " + id)
		var colors := _art_colors(e.get("texture", ""))
		_check(colors >= MIN_ART_COLORS, "정식 원화(색 %d ≥ %d): %s" % [colors, MIN_ART_COLORS, id])
		_check(Catalog.texture(id) != Catalog.back(), "공용 뒷면으로 대체되지 않음: " + id)

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)


## 원화 영역(카드 중앙 위쪽)을 8px 간격으로 표본해 서로 다른 색 수를 센다.
func _art_colors(path: String) -> int:
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	if img == null or img.is_empty():
		return 0
	var w := img.get_width()
	var h := img.get_height()
	var seen := {}
	for y in range(int(h * 0.2), int(h * 0.65), 8):
		for x in range(int(w * 0.2), int(w * 0.8), 8):
			seen[img.get_pixel(x, y).to_rgba32()] = true
	return seen.size()


func _check(ok: bool, label: String) -> void:
	total += 1
	if ok:
		passed += 1
		print("PASS " + label)
	else:
		print("FAIL " + label)
