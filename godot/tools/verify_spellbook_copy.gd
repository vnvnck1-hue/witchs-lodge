extends SceneTree
## 오래된 마법서적 복제 규칙(2026-10-18) 헤드리스 검증: 고른 카드는 주머니에서 빠지지 않고 복제본이 손패로 들어온다.
## main 장면 없이 CardInventory만 띄워 copy_uid()를 확인한다(선택 화면은 spellbook_picker.gd가 copy_uid()를 부른다).
## 실행: godot --headless --path . --script res://tools/verify_spellbook_copy.gd

const Cfg := preload("res://scripts/config.gd")
const InventoryScript := preload("res://scripts/game/card_inventory.gd")

var passed := 0
var total := 0


func check(label: String, ok: bool, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print("%s %s%s" % ["PASS" if ok else "FAIL", label, ("  (" + detail + ")") if detail != "" and not ok else ""])


func _initialize() -> void:
	var cards = InventoryScript.new()
	root.add_child(cards)
	cards._ready()

	# 1. 묶음 자원: 주머니 생고기 3개 중 1개 복제 → 주머니 3개 그대로, 손패 1개
	cards.add("raw_meat", 3, "", "pocket")
	var meat: int = cards.pocket().filter(func(e): return e["id"] == "raw_meat")[0]["uid"]
	var units: int = cards.pocket_units()
	var drawn_before: int = cards.stats["drawn"]
	var got: Dictionary = cards.copy_uid(meat)
	check("묶음 자원 복제: 손패에 1개", not got.is_empty() and got["zone"] == "hand" and int(got["count"]) == 1 and got["uid"] != meat, str(got))
	check("묶음 자원 복제: 원본 주머니 수량 그대로", int(cards.get_entry(meat).get("count", 0)) == 3 and cards.get_entry(meat)["zone"] == "pocket" and cards.pocket_units() == units)
	check("복제도 드로우 통계에 셈", cards.stats["drawn"] == drawn_before + 1)
	# 같은 자원을 한 번 더 복제하면 손패 묶음에 합산
	var again: Dictionary = cards.copy_uid(meat)
	check("두 번째 복제는 손패 묶음에 합산", not again.is_empty() and again["uid"] == got["uid"] and int(again["count"]) == 2 and cards.hand().size() == 1)

	# 2. 낱장 카드: 원본 uid는 주머니에, 새 uid가 손패에
	cards.add("moss_bandage", 1, "", "pocket")
	var band: int = cards.pocket().filter(func(e): return e["id"] == "moss_bandage")[0]["uid"]
	var copy: Dictionary = cards.copy_uid(band)
	check("낱장 카드 복제: 새 카드가 손패로", not copy.is_empty() and copy["uid"] != band and copy["zone"] == "hand")
	check("낱장 카드 복제: 원본은 주머니에", cards.get_entry(band).get("zone", "") == "pocket" and cards.pocket_count_of("moss_bandage") == 1 and cards.hand_count_of("moss_bandage") == 1)

	# 3. 손패가 가득 차면 복제 실패 · 원본 그대로
	while not cards.hand_full():
		cards.add("moss_bandage", 1, "", "hand")
	cards.add("black_wool", 1, "", "pocket")
	var wool: int = cards.pocket().filter(func(e): return e["id"] == "black_wool")[0]["uid"]
	var hand_n: int = cards.hand().size()
	check("손패 가득: 복제 없음", cards.copy_uid(wool).is_empty() and cards.hand().size() == hand_n and cards.get_entry(wool).get("zone", "") == "pocket")
	check("손패 가득이어도 같은 자원 묶음엔 합산", not cards.copy_uid(meat).is_empty() and cards.hand().size() == hand_n and int(cards.get_entry(meat)["count"]) == 3)

	# 4. 주머니가 아닌 카드는 복제 불가
	check("손패 카드 uid는 복제 불가", cards.copy_uid(copy["uid"]).is_empty())

	# 5. 선택 화면이 draw_uid가 아니라 copy_uid를 부른다
	var src := FileAccess.get_file_as_string("res://scripts/ui/spellbook_picker.gd")
	check("선택 화면은 copy_uid로 복제", src.contains("cards.copy_uid(") and not src.contains("cards.draw_uid("))

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
