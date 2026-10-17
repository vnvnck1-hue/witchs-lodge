extends SceneTree
## 무료 BGM(output/bgm-free-v01) 적용 검증: 파일 존재·두 selected.json 일치·슬롯 등록·trim_db·출처 기록(sources.json)·크레딧 필요 곡 표기.
## 실행: godot --headless --path . --script res://tools/verify_bgm_free_sources.gd
var results: Array = []

func check(label: String, ok: bool, detail := "") -> void:
	results.append(ok)
	print(("PASS " if ok else "FAIL ") + label + ("  — " + detail if detail != "" else ""))

func _initialize() -> void:
	call_deferred("run")

func load_json(path: String):
	if not FileAccess.file_exists(path): return null
	return JSON.parse_string(FileAccess.get_file_as_string(path))

func run() -> void:
	var root := ProjectSettings.globalize_path("res://").rstrip("/").get_base_dir()  # 프로젝트 루트(godot/의 부모)
	var src = load_json(root.path_join("output/bgm-free-v01/sources.json"))
	check("sources.json 읽힘", src is Dictionary and src.get("tracks", []) is Array and src["tracks"].size() == 4)
	var tracks: Array = src["tracks"] if src is Dictionary else []
	var expect := {"bgm_combat": ["bgm-combat-21.mp3", "bgm-combat-22.mp3"], "bgm_field": ["bgm-day-21.mp3", "bgm-day-22.mp3"]}
	var sel_a = load_json("res://assets/audio/selected.json")
	var sel_b = load_json(root.path_join("build/audio/selected.json"))
	check("두 selected.json 모두 읽힘", sel_a is Dictionary and sel_b is Dictionary)
	for slot in expect:
		var ea: Dictionary = sel_a["sounds"].get(slot, {}) if sel_a is Dictionary else {}
		var eb: Dictionary = sel_b["sounds"].get(slot, {}) if sel_b is Dictionary else {}
		check("%s 파일 목록 = %s" % [slot, str(expect[slot])], ea.get("files", []) == expect[slot], str(ea.get("files", [])))
		check("%s godot·build 설정 동일" % slot, ea == eb)
		for f in expect[slot]:
			check("%s 파일 존재(godot·build)" % f, FileAccess.file_exists("res://assets/audio/" + f) and FileAccess.file_exists(root.path_join("build/audio/" + f)))
			var trims: Dictionary = ea.get("trim_db", {})
			check("%s trim_db 지정(음수)" % f, trims.has(f) and float(trims[f]) < 0.0 and float(trims[f]) > -10.0, str(trims.get(f)))
			var mp3 := AudioStreamMP3.new()
			mp3.data = FileAccess.get_file_as_bytes("res://assets/audio/" + f)
			check("%s 디코딩·길이 60초 이상" % f, mp3.get_length() >= 60.0, "%.1fs" % mp3.get_length())
	var by_file := {}
	for t in tracks: by_file[t.get("game_file", "")] = t
	for slot in expect:
		for f in expect[slot]:
			var t: Dictionary = by_file.get(f, {})
			check("%s 출처 기록(URL·라이선스)" % f, t.get("page", "").begins_with("https://") and t.get("license", "") in ["CC0 1.0", "CC BY 4.0"] and t.get("slot", "") == slot, str(t.get("license", "")))
			check("%s 원본 파일 보관" % f, FileAccess.file_exists(root.path_join("output/bgm-free-v01/" + t.get("raw", "?"))))
	var need_credit: Array = []
	for t in tracks:
		if t.get("attribution_required", false): need_credit.append(t.get("title", ""))
	check("크레딧 필요 곡 = Dentaneosuchus Hunt(CC BY 4.0) 1곡", need_credit == ["Dentaneosuchus Hunt"], str(need_credit))
	var credits := root.path_join("docs/credits.md")
	check("docs/credits.md 에 Kevin MacLeod 크레딧 표기", FileAccess.file_exists(credits) and FileAccess.get_file_as_string(credits).contains("Dentaneosuchus Hunt") and FileAccess.get_file_as_string(credits).contains("incompetech.com"))
	var passed := results.count(true)
	print("RESULT %d/%d" % [passed, results.size()])
	quit(0 if passed == results.size() else 1)
