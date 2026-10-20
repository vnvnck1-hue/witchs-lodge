extends SceneTree
## 게임 전체 영문판(F8 → English) 헤드리스 검증: 번역 사전·서식 번역·UI 글꼴 교체·실제 게임/타이틀 화면에 남은 한글.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_i18n.gd
## 사전은 tools/i18n/(extract → seed_catalog → merge)이 만든 godot/assets/i18n/en.json. 설정 파일은 건드리지 않는다.

const GameLanguage := preload("res://scripts/ui/game_language.gd")
const SkinUI := preload("res://scripts/ui/moon/moon_skin.gd")
const CardFace := preload("res://scripts/ui/card_face.gd")
## 영문판에서도 일부러 한글로 두는 문구(언어 선택지 이름 등)
const KEEP_KO := ["한국어"]
const PLAY_FRAMES := 8000

var passed := 0
var total := 0
var lit_seen := 0   # _missing_literals 가 읽은 한글 리터럴 수
var hangul := RegEx.create_from_string("[\\x{AC00}-\\x{D7A3}\\x{3131}-\\x{318E}]")


func _initialize() -> void:
	create_timer(600.0, true, false, true).timeout.connect(func() -> void:
		print("FAIL timeout")
		quit(1))
	call_deferred("_run")


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print(("PASS " if ok else "FAIL ") + name + ("" if detail.is_empty() else "  — " + detail))


func _run() -> void:
	var start_lang := CardFace.language()
	var tr_obj = GameLanguage.translation()
	check("사전 로드(항목 2500개 이상)", tr_obj.exact.size() >= 2500, "%d" % tr_obj.exact.size())

	# 1) 사전 전체: 번역 결과에 한글이 남지 않는다
	var left: Array = []
	for ko in tr_obj.exact:
		if ko in KEEP_KO:
			continue
		if hangul.search(String(tr_obj.exact[ko])) != null:
			left.append(ko)
	check("사전 값에 한글 없음", left.is_empty(), "%d개 예: %s" % [left.size(), str(left.slice(0, 3))])

	# 1-b) 코드의 한글 문자열(한 줄 리터럴)이 모두 사전에 있다 — 새 문구를 넣으면 여기서 잡힌다(docs/english-ui-runtime.md 절차로 추가)
	var no_entry := _missing_literals("res://scripts", tr_obj)
	check("스크립트 한글 문자열 %d개 모두 사전에 있음" % lit_seen, lit_seen > 2000 and no_entry.is_empty(), "%d개 예: %s" % [no_entry.size(), str(no_entry.slice(0, 5))])

	GameLanguage.apply("en")
	check("locale en", TranslationServer.get_locale().begins_with("en"))
	check("통째 번역", TranslationServer.translate("정찰 중") == tr_obj.exact.get("정찰 중", "?") and hangul.search(TranslationServer.translate("정찰 중")) == null,
		TranslationServer.translate("정찰 중"))

	# 2) 서식 문장: 사전의 모든 서식 원문에 예시 값을 넣어 번역해도 한글이 남지 않고 값이 보존된다
	var spec := RegEx.create_from_string("%(%|[-+0#]*\\d*(?:\\.\\d+)?[dsfxXc])")
	var bad_fmt: Array = []
	var n_fmt := 0
	for ko in tr_obj.exact:
		var k := String(ko)
		var ms := spec.search_all(k)
		if ms.is_empty():
			continue
		var args: Array = []
		var ok_spec := true
		for m in ms:
			var sp := m.get_string(1)
			if sp == "%":
				continue
			if sp.ends_with("s") or sp.ends_with("c"):
				args.append("Bram")
			elif sp.ends_with("f"):
				args.append(7.5)
			else:
				args.append(37)
		var formatted := ""
		if ok_spec:
			formatted = k % args if not args.is_empty() else k.replace("%%", "%")
		n_fmt += 1
		var out := TranslationServer.translate(formatted)
		if hangul.search(out) != null and not (k in KEEP_KO):
			bad_fmt.append("%s → %s" % [formatted, out])
		elif args.has(37) and not out.contains("37"):
			bad_fmt.append("값 누락 %s → %s" % [formatted, out])
	check("서식 문장 %d개 번역(한글·값 누락 없음)" % n_fmt, bad_fmt.is_empty(), "%d개 예: %s" % [bad_fmt.size(), "\n  ".join(bad_fmt.slice(0, 20))])

	# 3) 글꼴: UI 글꼴과 엔진 기본 글꼴이 Alegreya, 한글 폴백 포함
	var f := SkinUI.font() as FontVariation
	var base := f.base_font if f != null else null
	check("UI 글꼴 English = Alegreya", base is FontVariation and (base as FontVariation).base_font != null
		and (base as FontVariation).base_font.resource_path == SkinUI.EN_UI_FONT, str(base))
	check("UI 굵은 글꼴도 Alegreya", ((SkinUI.font(true) as FontVariation).base_font as FontVariation).base_font.resource_path == SkinUI.EN_UI_FONT)
	check("한글 폴백 유지", not (base as FontVariation).fallbacks.is_empty())
	check("엔진 기본 글꼴도 교체", ThemeDB.fallback_font == SkinUI.font())

	# 4) 실제 화면: 타이틀과 게임에서 보이는 모든 글자(Label·Button·RichTextLabel·툴팁·Label3D)
	#    한국어로 되돌린 뒤 F8 과 같은 경로(CardLanguage.set_language)로 영어로 바꾼다
	GameLanguage.apply("ko")
	for scene in ["res://scenes/title.tscn", "res://scenes/main.tscn"]:
		if not ResourceLoader.exists(scene):
			continue
		change_scene_to_file(scene)
		for i in 60:
			await physics_frame
		var cl = current_scene.get_node_or_null("CardLanguage")
		check("%s CardLanguage 있음" % scene.get_file(), cl != null)
		if cl != null:
			cl.set_language("en", false)
		check("%s F8 경로로 locale en" % scene.get_file(), TranslationServer.get_locale().begins_with("en"))
		for i in 10:
			await process_frame
		var found := _visible_hangul(root)
		var bad_font := _non_en_fonts(root)
		check("%s 화면 글자 모두 영문 글꼴" % scene.get_file(), bad_font.is_empty(), "%d개 예: %s" % [bad_font.size(), "
  ".join(bad_font.slice(0, 10))])
		check("%s 화면에 한글 없음" % scene.get_file(), found.is_empty(), "%d개 예: %s" % [found.size(), "\n  ".join(found.slice(0, 30))])
		if scene.ends_with("main.tscn"):
			# HUD 이미지에 박힌 한글(마녀·산장·산장 관리·창고·오늘의 할 일)은 글자 지운 조각 + 영문 Label 로 덮는다
			var covers := current_scene.find_children("TextCover", "", true, false)
			var shown_covers := covers.filter(func(c): return c.is_visible_in_tree() and c.size.x > 10.0)
			check("HUD 글자 덮개 4곳 표시", shown_covers.size() == 4, "%d/%d" % [shown_covers.size(), covers.size()])
			# 시간을 빨리 돌려 손님 도착·알림·밤 전투 등 진행 중에 뜨는 글자도 모은다
			Engine.time_scale = 8.0
			var seen := {}
			var font_seen := {}
			for i in PLAY_FRAMES:
				await physics_frame
				if i % 20 == 0:
					for s in _visible_hangul(root):
						seen[s] = true
					for s in _non_en_fonts(root):
						font_seen[s] = true
			Engine.time_scale = 1.0
			check("플레이 중 글자 모두 영문 글꼴", font_seen.is_empty(), "%d개 예: %s" % [font_seen.size(), "
  ".join(font_seen.keys().slice(0, 10))])
			check("플레이 %d프레임 동안 한글 없음" % PLAY_FRAMES, seen.is_empty(), "%d개 예: %s" % [seen.size(), "\n  ".join(seen.keys().slice(0, 60))])

	# 5) 한국어로 되돌리기
	GameLanguage.apply("ko")
	check("한국어 복귀: 원문 그대로", TranslationServer.translate("정찰 중") == "정찰 중")
	check("한국어 복귀: UI 글꼴 SystemFont", (SkinUI.font() as FontVariation).base_font is SystemFont)
	for _i in 2:
		await process_frame
	var still := current_scene.find_children("TextCover", "", true, false).filter(func(c): return c.visible)
	check("한국어 복귀: HUD 글자 덮개 숨김", still.is_empty(), "%d" % still.size())
	GameLanguage.apply(start_lang)
	CardFace.set_language(start_lang)

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)


## 화면에 보이는 노드 중 번역 후에도 한글이 남은 글자 목록.
func _visible_hangul(n: Node) -> Array:
	var out: Array = []
	var texts: Array = []
	if n is CanvasItem and not (n as CanvasItem).is_visible_in_tree():
		return out
	if n is Label or n is Button or n is RichTextLabel or n is Label3D or n is LineEdit:
		texts.append(n.get("text"))
	if n is Control and String((n as Control).tooltip_text) != "":
		texts.append((n as Control).tooltip_text)
	for t in texts:
		var s := String(t)
		if s.is_empty():
			continue
		var shown := n.atr(s) if n.can_auto_translate() else s
		if hangul.search(shown) != null and not (s in KEEP_KO):
			out.append("%s: %s" % [n.name, shown.left(400).replace("\n", "/")])
	for c in n.get_children():
		out.append_array(_visible_hangul(c))
	return out


## scripts 아래 .gd 의 한 줄 문자열 리터럴 중 한글이 있는데 사전(파생 항목 포함)에 없는 것.
func _missing_literals(dir: String, tr_obj) -> Array:
	var out: Array = []
	var lit := RegEx.create_from_string("\"((?:[^\"\\\\]|\\\\.)*)\"")
	for f in DirAccess.get_files_at(dir):
		if not f.ends_with(".gd"):
			continue
		var lines := FileAccess.get_file_as_string(dir.path_join(f)).split("\n")
		for i in lines.size():
			var line := lines[i].strip_edges()
			if line.begins_with("#"):
				continue
			var code := line
			var hash_at := _comment_start(line)
			if hash_at >= 0:
				code = line.substr(0, hash_at)
			for m in lit.search_all(code):
				var k := m.get_string(1).replace("\\n", "\n").replace("\\\"", "\"").replace("\\t", "\t")
				if hangul.search(k) == null or k in KEEP_KO:
					continue
				lit_seen += 1
				if not tr_obj.exact.has(k):
					out.append("%s:%d %s" % [f, i + 1, k.left(40)])
	for d in DirAccess.get_directories_at(dir):
		out.append_array(_missing_literals(dir.path_join(d), tr_obj))
	return out


## 줄 끝 주석(문자열 밖의 #) 위치. 없으면 -1.
func _comment_start(line: String) -> int:
	var in_str := ""
	var i := 0
	while i < line.length():
		var ch := line[i]
		if in_str != "":
			if ch == "\\":
				i += 2
				continue
			if ch == in_str:
				in_str = ""
		elif ch == "\"" or ch == "'":
			in_str = ch
		elif ch == "#":
			return i
		i += 1
	return -1



## 화면에 보이는 글자 노드 중 영문 글꼴(UI Alegreya 또는 fonts/en/)을 쓰지 않는 것.
func _non_en_fonts(n: Node) -> Array:
	var out: Array = []
	if n is CanvasItem and not (n as CanvasItem).is_visible_in_tree():
		return out
	var f: Font = null
	var txt := ""
	if n is Label or n is Button or n is LineEdit:
		f = (n as Control).get_theme_font("font")
		txt = String(n.get("text"))
	elif n is RichTextLabel:
		f = (n as Control).get_theme_font("normal_font")
		txt = (n as RichTextLabel).text
	elif n is Label3D:
		f = (n as Label3D).font if (n as Label3D).font != null else ThemeDB.fallback_font
		txt = (n as Label3D).text
	if f != null and txt.strip_edges() != "" and not _is_en_font(f):
		out.append("%s(%s): %s" % [n.name, n.get_class(), txt.left(30).replace("\n", "/")])
	for c in n.get_children():
		out.append_array(_non_en_fonts(c))
	return out


func _is_en_font(f: Font) -> bool:
	# UI 글꼴(moon_skin.font)은 언어와 상관없이 같은 객체라 안쪽 base_font 를 따라가 실제 파일을 본다
	var cur: Font = f
	for i in 4:
		if cur == null:
			return false
		if cur.resource_path.contains("/fonts/en/"):
			return true
		if cur is FontVariation:
			cur = (cur as FontVariation).base_font
		else:
			return false
	return false
