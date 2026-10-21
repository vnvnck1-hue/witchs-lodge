extends SceneTree
## 카드 툴팁 소개문(catalog.json 의 description) 헤드리스 검증: 모든 카드에 소개문이 있고, 설명서처럼 수치·확률·조작 안내를
## 적지 않았는지(사용자 결정 2026-10-22: 툴팁은 세계관이 느껴지는 소개문으로, 규칙 요약은 카드 앞면 printed_rules 가 맡는다),
## 영문 사전(assets/i18n/en.json)에 모든 소개문의 영문이 있고 한글이 섞이지 않았는지.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_card_lore.gd

var passed := 0
var total := 0

## 설명서 냄새가 나는 표현. 숫자·퍼센트·골드 단위·초 단위·UI 조작어.
const MANUAL_PATTERNS := ["[0-9]", "%", "초 동안", "클릭", "드래그", "끌어 놓", "칸에 끼우", "사용할 수 없습니다", "사용할 수 있습니다", "표시됩니다"]


func _check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print("%s %s%s" % ["PASS" if ok else "FAIL", label, ("  — " + detail) if detail != "" else ""])


func _init() -> void:
	var cat: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cards/catalog.json"))
	var cards: Array = cat.get("cards", [])
	_check(cards.size() >= 100, "카탈로그 카드 수", str(cards.size()))

	var en_raw := FileAccess.get_file_as_string("res://assets/i18n/en.json")
	var en: Dictionary = JSON.parse_string(en_raw) if en_raw != "" else {}
	_check(not en.is_empty(), "영문 사전 로드", str(en.size()))

	var hangul := RegEx.new()
	hangul.compile("[\\p{Hangul}]")
	var regs: Array[RegEx] = []
	for p in MANUAL_PATTERNS:
		var r := RegEx.new()
		r.compile(p)
		regs.append(r)

	var empty: Array[String] = []
	var too_short: Array[String] = []
	var manual: Array[String] = []
	var no_en: Array[String] = []
	var en_has_hangul: Array[String] = []
	for c in cards:
		var id := String(c.get("id", "?"))
		var d := String(c.get("description", ""))
		if d.strip_edges() == "":
			empty.append(id)
			continue
		if d.length() < 20:
			too_short.append(id)
		for i in regs.size():
			if regs[i].search(d) != null:
				manual.append("%s(%s)" % [id, MANUAL_PATTERNS[i]])
				break
		if not en.has(d):
			no_en.append(id)
		elif hangul.search(String(en[d])) != null:
			en_has_hangul.append(id)

	_check(empty.is_empty(), "모든 카드에 소개문이 있다", ", ".join(empty))
	_check(too_short.is_empty(), "소개문이 한 문장 이상(20자 이상)", ", ".join(too_short))
	_check(manual.is_empty(), "소개문에 수치·확률·조작 안내가 없다", ", ".join(manual))
	_check(no_en.is_empty(), "모든 소개문의 영문이 사전에 있다", ", ".join(no_en))
	_check(en_has_hangul.is_empty(), "영문 소개문에 한글이 없다", ", ".join(en_has_hangul))

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
