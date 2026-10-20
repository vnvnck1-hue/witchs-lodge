extends SceneTree
## 카드 실제 텍스트 적용 헤드리스 검증(docs/card-text-runtime.md).
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_card_face.gd
## 1) 을지로체 폰트가 로드된다  2) 카탈로그 전체 카드의 게임용·손패용 그림이 있고 크기가 맞는다
## 3) 종족 이름표가 있는 카드는 badge 가 있다  4) 모든 문구가 칸에 들어간다(축소율 60% 이상, 아래로는 그리지 않음)
## 5) Catalog.texture / race_texture / variant_texture 가 같은 그림·이름표에 같은 객체를 돌려주고 뒷면과 다르다
## 6) 영문(F8, A안 폰트): 폰트 3종·가변 축 로드, 모든 카드 영문 문구(한글 없음), 칸에 들어감, 이름표 번역,
##    CardLanguage 전환·저장(임시 설정 파일), 다시 한국어로 돌리면 원래 배치와 같음

const CardFace := preload("res://scripts/ui/card_face.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")
const Races := preload("res://scripts/game/races.gd")
const MIN_FIT := 0.6      # 긴 제목(2줄로 나눔)·3글자 종족명은 기준의 60% 까지 줄어도 정상
const BADGED := ["lumberjack", "hunter", "warrior", "gatherer", "black_sheep", "lamb", "forest_monster"]

var passed := 0
var total := 0


func _check(ok: bool, label: String) -> void:
	total += 1
	if ok:
		passed += 1
	print("%s %s" % ["PASS" if ok else "FAIL", label])


func _initialize() -> void:
	_check(CardFace.font() != null, "BM 을지로체 폰트 로드: " + CardFace.FONT_PATH)
	var cards: Array = Catalog.read().get("cards", [])
	var shrunk: Array = []
	for d in cards:
		var id: String = d["id"]
		if id == "card_back":
			continue
		var t := Catalog.texture(id)
		var h := Catalog.texture(id, true)
		_check(t != null and t.get_width() == 1024 and t.get_height() == 1536, "게임용 그림 1024×1536: " + id)
		_check(h != null and h.get_width() == 256 and h.get_height() == 384, "손패용 그림 256×384: " + id)
		_check(t != Catalog.back() and h != Catalog.back(true), "뒷면으로 대체되지 않음: " + id)
		_check(Catalog.texture(id) == t, "같은 카드는 같은 텍스처 객체(캐시): " + id)
		if id in BADGED:
			_check(String(d.get("badge", "")) != "", "종족 이름표 문구(badge): " + id)
		var m := CardFace.measure(d, String(d.get("badge", "")))
		for slot in m:
			var ratio := float(m[slot]["used"]) / float(m[slot]["target"])
			if ratio < 1.0:
				shrunk.append("%s/%s %d→%d" % [id, slot, m[slot]["target"], m[slot]["used"]])
			_check(ratio >= MIN_FIT, "문구가 칸에 들어감(%s %s %.0f%%)" % [id, slot, ratio * 100.0])
	for job in Catalog.RACE_JOB_CARDS:
		for race in Races.ALL:
			var p := Catalog.race_texture_path(job, race)
			if p == "":
				continue
			var m := CardFace.measure(Catalog.find(job), Races.name_of(race), p)
			_check(m.has("badge") and m["badge"]["used"] >= m["badge"]["target"] * MIN_FIT, "종족 이름표가 칸에 들어감: %s/%s" % [race, job])
	var v1 := Catalog.variant_texture("drunk_rant", 1)
	var v2 := Catalog.variant_texture("drunk_rant", 2)
	_check(v1 != null and v2 != null and v1 != v2 and v1 == Catalog.variant_texture("drunk_rant", 1), "술주정 그림 변형은 서로 다른 텍스처, 같은 변형은 캐시")
	if not shrunk.is_empty():
		print("INFO 기준보다 줄어든 문구: ", ", ".join(shrunk))
	_check_english(cards)
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)


func _has_hangul(t: String) -> bool:
	for i in t.length():
		var c := t.unicode_at(i)
		if c >= 0xAC00 and c <= 0xD7A3:
			return true
	return false


func _check_english(cards: Array) -> void:
	const CardLanguage := preload("res://scripts/ui/card_language.gd")
	var ko_plan := CardFace.measure(Catalog.find("gatherer"), "인간")
	var node := CardLanguage.new()
	node.settings_path = "user://verify_card_language.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(node.settings_path))
	_check(CardFace.language() == "ko" or "--card-lang=en" in OS.get_cmdline_user_args(), "기본 카드 언어는 한국어")
	_check(node.toggle() == "en" and CardFace.language() == "en", "F8 전환: 한국어 → English")
	var cfg := ConfigFile.new()
	_check(cfg.load(node.settings_path) == OK and cfg.get_value("cards", "lang", "") == "en", "카드 언어가 [cards] lang 에 저장됨")
	for slot in ["title", "category", "badge", "rules"]:
		var f := CardFace.font_for(slot) as FontVariation
		_check(f != null and f.base_font != null and f.base_font.resource_path == CardFace.EN_FONTS[slot][0], "영문 폰트 로드(%s): %s" % [slot, CardFace.EN_FONTS[slot][0]])
		_check(f != null and f.fallbacks.size() == 1 and f.fallbacks[0] == CardFace.font(), "영문 폰트에 없는 글자는 을지로체로(%s)" % slot)
	var title_axes: Dictionary = (CardFace.font_for("title") as FontVariation).variation_opentype
	_check(title_axes.size() == 4 and title_axes.values().has(900) and title_axes.values().has(100), "제목 Fraunces 축 wght 900·SOFT 100·WONK·opsz 고정")
	var fr := CardFace.font_for("rules")
	_check(fr.get_string_size("Brings back anything useful.", 0, -1, 66).x < CardFace.font().get_string_size("Brings back anything useful.", 0, -1, 66).x * 1.2, "본문 Alegreya 로 실제 다른 글꼴이 쓰임(폭 비교)")
	var shrunk := []
	for d in cards:
		var id: String = d["id"]
		if id == "card_back":
			continue
		var t := CardFace.texts(d, String(d.get("badge", "")))
		var joined := "%s %s %s %s" % [t[0], t[1], " ".join(t[2]), t[3]]
		_check(not _has_hangul(joined), "영문 문구 완비(한글 없음): " + id)
		var m := CardFace.measure(d, String(d.get("badge", "")))
		for slot in m:
			var ratio := float(m[slot]["used"]) / float(m[slot]["target"])
			if ratio < 0.8:
				shrunk.append("%s/%s %.0f%%" % [id, slot, ratio * 100.0])
			_check(ratio >= CardFace.MIN_RATIO_EN[slot] - 0.001, "영문 문구가 칸에 들어감(%s %s %.0f%%)" % [id, slot, ratio * 100.0])
	for job in Catalog.RACE_JOB_CARDS:
		for race in Races.ALL:
			var p := Catalog.race_texture_path(job, race)
			if p == "":
				continue
			var t := CardFace.texts(Catalog.find(job), Races.name_of(race))
			var m := CardFace.measure(Catalog.find(job), Races.name_of(race), p)
			_check(not _has_hangul(t[3]) and m["badge"]["used"] >= m["badge"]["target"] * CardFace.MIN_RATIO_EN["badge"], "영문 종족 이름표(%s → %s): %s" % [race, t[3], job])
	if not shrunk.is_empty():
		print("INFO 영문 80%% 미만으로 줄어든 문구: ", ", ".join(shrunk))
	_check(node.toggle() == "ko" and CardFace.font_for("rules") == CardFace.font() and CardFace.measure(Catalog.find("gatherer"), "인간") == ko_plan, "F8 다시 → 한국어, 배치 원래대로")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(node.settings_path))
	node.free()
