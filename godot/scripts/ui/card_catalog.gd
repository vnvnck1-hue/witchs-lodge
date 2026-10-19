extends RefCounted
## Card asset catalogue (names, rules text, textures). Ownership lives in game/card_inventory.gd,
## use rules in game/card_use_resolver.gd.

const DATA_PATH := "res://assets/cards/catalog.json"
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")

## 실행 중 한 번만 읽어 두는 읽기 전용 사본과 id → 항목 색인(find·texture·back 이 쓴다).
## 카드 화면을 열 때마다 카드 장수만큼 33KB JSON 을 다시 읽던 것을 없앤다.
static var _cached: Dictionary = {}
static var _by_id: Dictionary = {}

## 원본 JSON 을 새로 읽어 고쳐도 되는 사본으로 돌려준다(검증·도구용).
static func read() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if not parsed is Dictionary:
		push_error("Invalid card catalogue: " + DATA_PATH)
		return {}
	return parsed

static func _data() -> Dictionary:
	if _cached.is_empty():
		_cached = read()
		_by_id.clear()
		for entry in _cached.get("cards", []):
			var id: String = entry.get("id", "")
			if not _by_id.has(id):
				_by_id[id] = entry
	return _cached

static func find(card_id: String) -> Dictionary:
	_data()
	var entry = _by_id.get(card_id)
	return entry.duplicate(true) if entry != null else {}

static func texture(card_id: String, hand := false) -> Texture2D:
	var entry := find(card_id)
	var key := "hand_texture" if hand else "texture"
	# 원화가 아직 납품되지 않은 카드는 공용 뒷면으로 대신 보인다.
	if not entry.has(key) or not ResourceLoader.exists(entry[key]):
		return back(hand)
	return load(entry[key]) as Texture2D

## 종족별 직업 카드(docs/race-job-cards-v01.md): 고용 계약 카드는 그 손님의 종족 그림을 쓴다.
## 경로 res://assets/cards/races/<race>/<job>.png (손패용 .../hand/<job>.png). 인간·이름 풀 밖 인물·미납품이면 null → 기본 카드.
const RACE_JOB_CARDS := ["warrior", "hunter", "lumberjack", "gatherer"]
const RACE_DIR := "res://assets/cards/races/"

static func race_texture_path(card_id: String, race: String, hand := false) -> String:
	if not card_id in RACE_JOB_CARDS or race == "" or race == "human":
		return ""
	return RACE_DIR + race + ("/hand/" if hand else "/") + card_id + ".png"

static func race_texture(card_id: String, person: String, hand := false) -> Texture2D:
	if person == "" or not card_id in RACE_JOB_CARDS:
		return null
	var path := race_texture_path(card_id, GuestProfiles.race_of(person), hand)
	if path == "" or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

## 계약 카드 그림: 인물의 종족 그림이 있으면 그것, 없으면 기본 카드.
static func texture_for(card_id: String, person: String, hand := false) -> Texture2D:
	var t := race_texture(card_id, person, hand)
	return t if t != null else texture(card_id, hand)

static func back(hand := false) -> Texture2D:
	var data := _data()
	var key := "back_hand" if hand else "back"
	return load(data[key]) as Texture2D if data.has(key) else null
