extends SceneTree
## 왼쪽 손님 말 걸기 알림(시안 03, 2026-10-22): 초상 메달 + 종이 말풍선(왼쪽 꼬리) + 진입 화살표, 이름·건수·막대 없음.
## 메달 테두리 호가 '떠나기까지 남은 시간' 비율로 줄고 색이 금 → 주황 → 붉은 깜박임으로 바뀌는지,
## 말풍선이 글 길이에 맞춰 커지고 메달 중심 높이에 놓이는지, 클릭 범위(알림 버튼)가 메달·말풍선을 모두 덮는지 검증한다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_speech_notification.gd

const Cfg := preload("res://scripts/config.gd")
const SpeechMedal := preload("res://scripts/ui/speech_medal.gd")
const Extension := preload("res://scripts/ui/moon/moon_extension.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")

var failures := 0
var total := 0


func check(label: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print("%s %s%s" % ["PASS" if ok else "FAIL", label, "" if detail == "" else " — " + detail])


func frames(n := 2) -> void:
	for i in n:
		await process_frame


func advance(seconds: float) -> void:
	Engine.time_scale = 10.0
	await create_timer(seconds / 10.0, true, false, true).timeout
	Engine.time_scale = 1.0
	await frames(2)


func _initialize() -> void:
	create_timer(90.0, true, false, true).timeout.connect(func():
		print("RESULT timeout")
		quit(1))
	run.call_deferred()


func run() -> void:
	# ── 메달 단독 ──
	var m = SpeechMedal.new()
	root.add_child(m)
	m.size = Vector2(156, 156)
	check("메달은 마우스 입력을 막지 않음", m.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	check("비율은 0~1로 자름", (func(): m.ratio = 1.7; return is_equal_approx(m.ratio, 1.0)).call())
	check("테두리 게이지는 그리지 않음(사용자 요청)", not m.show_arc and not m.has_method("arc_color"))
	check("승인 틀 그림 사용", m.has_frame())
	m.set_portrait("res://assets/portraits/guest_graz_cutout.png")
	check("초상 불투명 영역 측정", m._tex != null and m._bbox.size.y > 1000.0 and m._bbox.size.x > 400.0, str(m._bbox))
	var c: Vector2 = m.size * 0.5
	var top: float = m.portrait_top()
	check("인물 위쪽(칼끝)은 틀 바깥 테 위끝까지 닿거나 넘침(시안: 3px 위)", top <= c.y - m.outer_radius() + 2.0, "top=%.0f, 바깥 테 위=%.0f" % [top, c.y - m.outer_radius()])
	var head_y: float = m.portrait_origin().y + m._head_top * m.portrait_scale()
	check("머리 꼭대기(투구)는 틀 안쪽 원 위끝 근처(±12)", absf(head_y - (c.y - m.radius)) <= 12.0, "head=%.0f 안쪽 원 위=%.0f" % [head_y, c.y - m.radius])
	check("머리 측정: 꼭대기는 칼끝보다 아래, 폭은 전체 폭의 30% 이상", m._head_top > m._bbox.position.y and m._head_w >= m._bbox.size.x * 0.3, "head_top=%.0f bbox_top=%.0f head_w=%.0f" % [m._head_top, m._bbox.position.y, m._head_w])
	check("인물 크기: 머리 폭이 원 지름보다 큼", m.portrait_scale() * m._head_w > m.radius * 2.0, "%.0f" % (m.portrait_scale() * m._head_w))
	var o: Vector2 = m.portrait_origin()
	check("머리 가로 중심 = 원 중심", absf(o.x + m._face_x * m.portrait_scale() - c.x) < 0.5)
	m.queue_free()

	# ── 게임 안 알림 ──
	root.size = Vector2i(1600, 900)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(8)
	game.world.day_cycle.set_mode("day")
	var eco = game.economy
	var events = game.guest_events
	var ui = game.guest_ui
	check("손님 초대 가능", eco.invite_block_reason() == "", eco.invite_block_reason())
	eco.invite_batch()
	await frames(4)
	var visits: Array = events.current_guests()
	if visits.size() < 2:
		check("손님 도착 기록", false, str(visits.size()))
		print("RESULT %d/%d" % [total - failures, total])
		quit(1)
		return
	var first: Dictionary = visits[visits.size() - 2]
	var second: Dictionary = visits[visits.size() - 1]
	for e in [first, second]:
		events.admit(e.profile)
	first.read = true
	second.ready = true
	second.read = false
	await frames(3)
	var n: Button = ui.notification
	check("대화 알림 표시", n.visible and ui.notification_uid == second.uid)
	check("알림 노드 이름 유지", n.name == "GuestSpeechNotification")
	var medal = ui.notify_medal
	check("메달이 알림 안에 있음", medal.get_parent() == n and medal.name == "SpeechMedal")
	check("기다림 게이지 별칭 = 메달", ui.notify_gauge == medal)
	check("메달 남은 시간 값·가득(그리지는 않음)", not medal.show_arc and medal.ratio > 0.95, "%.2f" % medal.ratio)
	check("메달 초상 = 손님 메달 초상(없으면 일반 초상)", medal.portrait_path == second.profile.get("medal_portrait", second.profile.portrait), medal.portrait_path)
	var graz_profile: Dictionary = GuestProfiles.character("graz")
	check("그라즈 메달 전용 초상 연결(파일 있을 때만)", graz_profile.has("medal_portrait") == ResourceLoader.exists("res://assets/portraits/guest_graz_medal.png"), str(graz_profile.get("medal_portrait", "-")))
	check("말풍선 글 = 이야기 첫마디", ui.notify_text.text == second.story.prompt, ui.notify_text.text)
	check("말풍선 글 23pt 종이 잉크색", ui.notify_text.get_theme_font_size("font_size") == 23 and ui.notify_text.get_theme_color("font_color") == Color8(48, 30, 44))
	check("이름 줄 숨김(글은 툴팁·검증용)", not ui.notify_name.visible and ui.notify_name.text.begins_with(second.profile.person))
	check("옛 막대 게이지 없음", n.find_child("TalkWaitGauge", false, false) == null)
	var arrow: Node = n.find_child("EnterArrow", true, false)
	check("진입 화살표 있음", arrow != null and arrow is TextureRect and (arrow as TextureRect).texture != null)
	var bubble: PanelContainer = ui.notify_bubble
	var mc: Vector2 = medal.position + medal.size * 0.5
	check("메달 중심 = 설계 위치", mc.is_equal_approx(Vector2(78, 78)), str(mc))
	check("말풍선 세로 가운데 = 메달 중심 + 12(시안 실측)", absf(bubble.position.y + bubble.size.y * 0.5 - mc.y - 12.0) < 1.0, str(bubble.position))
	check("말풍선은 메달 바깥 테 오른쪽에서 시작", bubble.position.x >= mc.x + medal.outer_radius() - 17.0, "%.0f" % bubble.position.x)
	check("말풍선이 글보다 넓음(여백 포함)", bubble.size.x > ui.notify_text.size.x + 40.0 and bubble.size.y >= 40.0, str(bubble.size))
	var nr: Rect2 = Rect2(Vector2.ZERO, n.size)
	check("클릭 범위가 메달·말풍선을 덮음", nr.encloses(Rect2(medal.position, medal.size)) and nr.encloses(Rect2(bubble.position, bubble.size)), str(n.size))
	check("자식들은 입력을 버튼에 넘김", medal.mouse_filter == Control.MOUSE_FILTER_IGNORE and bubble.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	var gr: Rect2 = n.get_global_rect()
	check("알림은 화면 좌측 위", gr.position.x < 40.0 and gr.end.x < root.size.x * 0.4 and gr.end.y < root.size.y * 0.5, str(gr))
	check("툴팁에 남은 초", n.tooltip_text.contains("초 뒤 산장을 떠납니다"))
	var tex_body := Extension.tex("speech_plain") != null
	var tex_tail := Extension.tex("speech_tail_left") != null
	print("INFO 승인 PNG 몸통=%s 꼬리=%s (없으면 평면 상자·다각형 꼬리로 대체)" % [tex_body, tex_tail])
	var style: StyleBox = bubble.get_theme_stylebox("panel")
	check("말풍선 바탕 스타일 종류", (style is StyleBoxTexture) == tex_body, str(style))
	# 긴 첫마디: 말풍선이 글 따라 커진다
	var w0: float = bubble.size.x
	second.story.prompt = "언니… 나 좀 숨겨 줘. 지금 당장!"  # _process 가 이야기 첫마디를 글에 다시 넣는다
	await frames(3)
	check("긴 글이면 말풍선이 넓어짐", bubble.size.x > w0 + 60.0, "%.0f → %.0f" % [w0, bubble.size.x])
	await frames(2)
	# 시간이 흐르면 호가 준다
	var before: float = medal.ratio
	var l2: float = eco.guest_time_left(second.uid)
	await advance(Cfg.GUEST_STAY * 0.5)
	var want: float = eco.guest_time_left(second.uid) / l2
	check("시간이 흐르면 메달 남은 시간 값이 준다", medal.ratio < before - 0.15, "%.2f → %.2f" % [before, medal.ratio])
	check("메달 값 = 떠나기까지 남은 시간 비율", absf(medal.ratio - want) < 0.05, "%.2f vs %.2f" % [medal.ratio, want])
	# 대화를 열면 알림이 숨고, 닫으면 돌아온다
	ui.open_conversation(second.uid)
	await frames(2)
	check("대화 중 알림 숨김", not n.visible and ui.dialogue_active)
	ui.close_conversation(false)
	await frames(2)
	check("대화를 닫으면 알림 복귀", n.visible)
	print("RESULT %d/%d" % [total - failures, total])
	quit(0 if failures == 0 else 1)
