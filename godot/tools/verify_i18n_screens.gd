extends SceneTree
## 영문판 화면별 헤드리스 검증: 타이틀(설정·마녀 선택) → 새 이야기(프롤로그·새벽·시작 손패·튜토리얼) →
## 게임 안의 모든 창(일시 정지·설정·지도·산장 관리 탭·창고·카드 툴팁·새벽 보상·장날·시작 손패·마법서·제단·보물상자·
## 손님 대화 전 인물·손님 소개·배너·참고 카드·게임 오버·챕터 완료)을 차례로 열고, 그때마다 **숨은 노드까지 포함한**
## 모든 글자(Label·Button·RichTextLabel·LineEdit·Label3D·툴팁)를 번역해 한글이 남는지 본다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_i18n_screens.gd
## 설정 파일·튜토리얼 기록은 검증 전용 경로를 쓴다.

const Flow := preload("res://scripts/game/flow.gd")
const GameLanguage := preload("res://scripts/ui/game_language.gd")
const CardFace := preload("res://scripts/ui/card_face.gd")
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const KEEP_KO := ["한국어"]
const Cfg := preload("res://scripts/config.gd")
## 코드가 한글 조각을 이어 붙여 만드는 문장(scripts 안 "+" 연결 68곳의 대표 모양) — 실제 값으로 만들어 번역한다
const CONCAT := ["정찰 중 · 보관 3", "벌목 — 브람", "마녀: 정찰 중", "화면 설정  ▾", "무기 칸", "무기 — 비어 있음", "왼쪽 감시탑", "오른쪽 감시탑",
	"가시 방책 · 어린 가시", "잠자는 가시 씨앗
구매함", "채집가 오스윈", "마녀 — 정찰 중", "고용할 수 없습니다 — 손패가 가득 찼습니다",
	"브람  ·  인간 전투용병", "브람 · 이야기 듣기", "브람 · 대화 2건", "활동 중 — 정찰 중", "잠자는 가시 씨앗 — 복제본을 손패로",
	"새로 뽑은 카드 — 잠자는 가시 씨앗", "달빛 돌 제단 — 아직 제단의 문양을 읽을 수 없습니다 (4일차부터)", "◆ 괴물에게서 산장을 지키세요", "브람
3일차",
	"브람와 대화 · 화살이 돌아온 날", "올라프  ·  계약 인물: 브람  ·  획득: 양에게 접근해 수확"]

var passed := 0
var total := 0
var hangul := RegEx.create_from_string("[\\x{AC00}-\\x{D7A3}\\x{3131}-\\x{318E}]")
var main
var start_lang := "ko"


func _initialize() -> void:
	create_timer(600.0, true, false, true).timeout.connect(func() -> void:
		print("FAIL timeout")
		quit(1))
	start_lang = CardFace.language()
	Flow.ftue_path = "user://ftue-i18n-verify.cfg"
	Flow.prologue_enabled = true
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Flow.ftue_path))
	change_scene_to_file(Flow.TITLE_SCENE)
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print(("PASS " if ok else "FAIL ") + name + ("" if detail.is_empty() else "  — " + detail))


func frames(n: int) -> void:
	for i in n:
		await physics_frame


func wait_until(cond: Callable, timeout_frames := 1800) -> bool:
	for i in timeout_frames:
		if cond.call():
			return true
		await physics_frame
	return cond.call()


## 화면 단계 하나: 숨은 노드까지 모든 글자를 번역해 한글이 남으면 FAIL.
func step(name: String) -> void:
	await frames(3)
	var left := _hangul_nodes(root)
	check("[%s] 한글 없음" % name, left.is_empty(), "%d개 예: %s" % [left.size(), "\n  ".join(left.slice(0, 12))])
	var bad_font := _non_en_fonts(root)
	check("[%s] 영문 글꼴" % name, bad_font.is_empty(), "%d개 예: %s" % [bad_font.size(), "\n  ".join(bad_font.slice(0, 8))])


func _run() -> void:
	await wait_until(func(): return current_scene != null and current_scene.get("menu") != null)
	var title = current_scene
	GameLanguage.apply("ko")
	title.get_node("CardLanguage").set_language("en", false)   # F8 과 같은 경로
	check("locale en", TranslationServer.get_locale().begins_with("en"))
	var concat_left := CONCAT.filter(func(t): return hangul.search(TranslationServer.translate(t)) != null).map(func(t): return "%s → %s" % [t, TranslationServer.translate(t)])
	check("이어 붙인 문장 %d개 번역" % CONCAT.size(), concat_left.is_empty(), "\n  ".join(concat_left))

	# ── 타이틀 ──
	await step("타이틀")
	title._open_settings()
	await step("타이틀 설정")
	title.close_settings()
	title._open_select()
	await step("마녀 선택")
	title.select_witch(0)
	title.start_story()

	# ── 프롤로그 → 새벽 → 시작 손패 ──
	await wait_until(func(): return current_scene != null and current_scene.get("session") != null and current_scene.get("hud") != null)
	main = current_scene
	var op = main.opening
	var all_slides: Array = op.prologue.SLIDES.map(func(s): return String(s[1]))
	var slide_left := all_slides.filter(func(t): return hangul.search(TranslationServer.translate(t)) != null)
	check("프롤로그 자막 %d장 번역" % all_slides.size(), slide_left.is_empty(), str(slide_left.slice(0, 2)))
	await step("프롤로그")
	for i in 6:
		if op.phase != "prologue":
			break
		_key(KEY_SPACE)
		await frames(20)
		await step("프롤로그 %d장" % (i + 2))
	await wait_until(func(): return op.phase != "prologue", 600)
	await wait_until(func(): return main.mulligan_ui.active, 1200)
	await step("1일차 새벽·시작 손패")
	main.mulligan_ui.close()
	await frames(30)
	await step("튜토리얼 시작")

	# ── 게임 안의 창 ──
	var hud = main.hud
	hud._toggle_pause()
	await step("일시 정지")
	hud.set_map_visible(true)
	await step("탐험 지도")
	hud.set_map_visible(false)
	hud._toggle_pause()
	for tab in 4:
		hud.open_lodge_panel(tab)
		await step("산장 관리 탭 %d" % tab)
	hud.close_lodge_panel()
	hud.card_hand.open_pocket()
	await step("창고(주머니)")
	hud.card_hand.close_all()

	# 카드 툴팁: 카탈로그 전 카드
	var tip_left: Array = []
	for id in main.cards.defs.keys() if main.cards.get("defs") is Dictionary else []:
		hud.card_hand._fill_tooltip({"id": id, "count": 2, "person": "브람"})
		for l in [hud.card_hand.tip_title, hud.card_hand.tip_sub, hud.card_hand.tip_body]:
			var shown: String = l.atr(l.text)
			if hangul.search(shown) != null:
				tip_left.append("%s: %s" % [id, shown.left(60)])
	check("카드 툴팁 전 카드 한글 없음", tip_left.is_empty(), "%d개 예: %s" % [tip_left.size(), "\n  ".join(tip_left.slice(0, 8))])

	var some_ids: Array = ["frost_rune", "lumberjack", "lamb"]
	main.offer_ui.open_reward(some_ids)
	await step("새벽 보상")
	main.offer_ui.close()
	main.offer_ui.open_market(some_ids.map(func(id): return {"id": id, "price": 30, "sold": false}))
	await step("장날")
	main.offer_ui.close()
	main.mulligan_ui.open()
	await step("시작 손패 다시")
	main.mulligan_ui.close()
	main.spellbook_ui.open()
	await step("마법서")
	main.spellbook_ui.close()
	main.altar_ui.open()
	await step("제단")
	main.altar_ui.close()
	main.chest_ui.open(Vector3.ZERO)
	await frames(60)
	await step("보물상자")
	main.chest_ui.close()
	hud.show_reference(true)
	await step("참고 카드")
	hud.show_reference(false)
	main.banner.show_card("night", "첫째 밤 · 습격의 밤", "숲에서 괴물이 몰려옵니다")
	await step("가운데 배너")

	# 손님: 전 인물 소개와 대화(선택지까지 넘기며)
	var ui = main.guest_ui
	var events = main.guest_events
	var profiles: Array = Profiles.all_profiles()
	var talk_left: Array = []
	var talk_seen := 0   # 대화창에서 실제로 읽은 글자 수(대화가 열렸는지 확인)
	for p in profiles:
		var profile: Dictionary = p.duplicate(true)
		profile["character_id"] = profile["id"]
		events._on_batch([profile])
		events.admit(profile)
		main.guest_arrival.show_profile(profile, String(profile.get("greeting", profile.get("detail", ""))))
		await frames(2)
		talk_left.append_array(_hangul_nodes(main.guest_arrival).map(func(s): return "%s 소개 %s" % [profile["id"], s]))
		ui.open_conversation(int(profile["visit_uid"]))
		for i in 8:
			await frames(4)
			talk_left.append_array(_hangul_nodes(ui).map(func(s): return "%s 대화 %s" % [profile["id"], s]))
			talk_seen += ui.find_children("*", "Label", true, false).filter(func(l): return l.is_visible_in_tree() and l.text != "").size()
			if ui.has_method("advance_dialogue"):
				ui.advance_dialogue()
		ui.close_conversation(false)
		await frames(2)
	var uniq := {}
	for s in talk_left:
		uniq[s] = true
	check("손님 대화창이 실제로 열려 글자를 읽음", talk_seen > profiles.size() * 4, "보인 Label %d" % talk_seen)
	check("손님 %d명 소개·대화 한글 없음" % profiles.size(), uniq.is_empty(), "%d개 예: %s" % [uniq.size(), "\n  ".join(uniq.keys().slice(0, 12))])

	# 결말 화면
	main.session.report_defeat("마녀가 쓰러졌습니다")
	await frames(10)
	await step("게임 오버")
	main.hud._on_state_changed(3)   # VICTORY 화면 문구
	await step("챕터 완료")

	GameLanguage.apply(start_lang)
	CardFace.set_language(start_lang)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Flow.ftue_path))
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)


func _key(code: Key) -> void:
	for down in [true, false]:
		var e := InputEventKey.new()
		e.keycode = code
		e.pressed = down
		Input.parse_input_event(e)


## 숨은 노드까지 모든 글자 노드를 번역해 한글이 남은 것.
func _hangul_nodes(n: Node) -> Array:
	var out: Array = []
	var texts: Array = []
	if n is Label or n is Button or n is RichTextLabel or n is Label3D or n is LineEdit:
		texts.append(n.get("text"))
	if n is LineEdit:
		texts.append((n as LineEdit).placeholder_text)
	if n is Control:
		texts.append((n as Control).tooltip_text)
	for t in texts:
		var s := String(t)
		if s.is_empty() or s in KEEP_KO:
			continue
		var shown := n.atr(s) if n.can_auto_translate() else s
		if hangul.search(shown) != null:
			out.append("%s: %s" % [n.name, shown.left(160).replace("\n", "/")])
	for c in n.get_children():
		out.append_array(_hangul_nodes(c))
	return out


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
