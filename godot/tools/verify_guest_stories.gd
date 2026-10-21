extends SceneTree
## 손님 말 걸기 이야기(scripts/game/guest_dialogues.gd STORIES) 헤드리스 검증 — 2026-10-22 사용자 요청으로 42편을
## 성격·세계관이 드러나게 다시 썼다. 42명 전원에게 이야기가 있고 구조(prompt·title·opening·choices 2·closing)가 맞는지,
## 모든 문장이 대화 창(715px·33px)과 도착 창(580px·28px) 기준 3줄 안에 들어가는지, 이야기가 서로 같지 않은지,
## 영문 사전(assets/i18n/en.json)에 모든 문장의 영문이 있고 한글이 섞이지 않았는지.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_guest_stories.gd

const Dialogues := preload("res://scripts/game/guest_dialogues.gd")
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")

var passed := 0
var total := 0


func _check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print("%s %s%s" % ["PASS" if ok else "FAIL", label, ("  — " + detail) if detail != "" else ""])


## guest_arrival._wrap_dialogue 와 같은 규칙으로 줄 수를 센다(단어 단위, 패널보다 긴 단어만 글자 단위).
func _rows(text: String, font: Font, size: int, width: float) -> int:
	var rows := 0
	for paragraph in text.split("\n"):
		var line := ""
		for word in paragraph.split(" ", false):
			var candidate: String = word if line.is_empty() else line + " " + word
			if not line.is_empty() and font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width - 4.0:
				rows += 1
				line = ""
			if not line.is_empty(): line += " "
			for character in word:
				if font.get_string_size(line + character, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width - 4.0:
					rows += 1
					line = ""
				line += character
		rows += 1
	return rows


func _init() -> void:
	var font: Font = MoonSkin.font()
	var en_raw := FileAccess.get_file_as_string("res://assets/i18n/en.json")
	var en: Dictionary = JSON.parse_string(en_raw) if en_raw != "" else {}
	var hangul := RegEx.new()
	hangul.compile("[\\p{Hangul}]")

	var ids: Array = []
	for p in Profiles.CATALOG:
		ids.append(p["id"])
	_check(ids.size() == 42, "손님 명부 42명", str(ids.size()))

	var missing: Array[String] = []
	var bad_shape: Array[String] = []
	var overflow: Array[String] = []
	var no_en: Array[String] = []
	var en_hangul: Array[String] = []
	var openings := {}
	var dup: Array[String] = []
	for id in ids:
		if not Dialogues.STORIES.has(id):
			missing.append(id)
			continue
		var s: Dictionary = Dialogues.STORIES[id]
		var ok: bool = s.has("prompt") and s.has("title") and s.has("opening") and s.has("closing") and s.get("choices", []).size() == 2
		if ok:
			for c in s["choices"]:
				ok = ok and c.has("text") and c.has("reply") and String(c["text"]) != "" and String(c["reply"]) != ""
		if not ok:
			bad_shape.append(id)
			continue
		if openings.has(s["opening"]):
			dup.append(id + "=" + openings[s["opening"]])
		openings[s["opening"]] = id
		var texts: Array = [["prompt", s["prompt"]], ["title", s["title"]], ["opening", s["opening"]], ["closing", s["closing"]]]
		for i in 2:
			texts.append(["text%d" % i, s["choices"][i]["text"]])
			texts.append(["reply%d" % i, s["choices"][i]["reply"]])
		for t in texts:
			var k: String = t[0]
			var v: String = t[1]
			if k in ["opening", "closing", "reply0", "reply1"]:
				var r1 := _rows(v, font, 33, 715.0)
				var r2 := _rows(v, font, 28, 580.0)
				if r1 > 3 or r2 > 3:
					overflow.append("%s/%s(%d·%d)" % [id, k, r1, r2])
			if not en.has(v):
				no_en.append(id + "/" + k)
			elif hangul.search(String(en[v])) != null:
				en_hangul.append(id + "/" + k)

	_check(missing.is_empty(), "42명 전원에게 말 걸기 이야기가 있다", ", ".join(missing))
	_check(bad_shape.is_empty(), "이야기 구조(prompt·title·opening·choices 2·closing)", ", ".join(bad_shape))
	_check(dup.is_empty(), "이야기 도입이 서로 다르다", ", ".join(dup))
	_check(overflow.is_empty(), "모든 대사가 대화 창·도착 창 3줄 안에 들어간다", ", ".join(overflow))
	_check(no_en.is_empty(), "모든 대사의 영문이 사전에 있다", ", ".join(no_en))
	_check(en_hangul.is_empty(), "영문 대사에 한글이 없다", ", ".join(en_hangul))

	# 특별 이야기(늑대의 피·에린)는 그대로이며 구조만 확인한다.
	var wolf: Dictionary = Dialogues.wolf_story()
	_check(wolf.get("special", "") == "wolf" and wolf["choices"].size() == 2 and wolf["choices"][0].get("effect", "") == "wolf_blood", "늑대의 피 특별 이야기 유지")
	var erin: Dictionary = Dialogues.erin_story()
	_check(erin.get("special", "") == "erin" and erin["choices"].size() == 2, "에린 특별 이야기 유지")
	_check(Dialogues.story("없는_id")["title"] == Dialogues.STORIES["bram"]["title"], "모르는 id 는 브람의 이야기로 대체")

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
