extends SceneTree
## 손님 대화 '마녀의 대답' 선택지 레이아웃·입력 검증(헤드리스).
## 선택지가 손님 패널 아래로 분리돼 있고, 대사 글 열에 맞춰 왼쪽 정렬되며, 마우스 호버·숫자 키·↑↓ 로 고를 수 있고,
## 줄 사이 틈을 눌러도 대화가 닫히지 않는지 실제 입력으로 확인한다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_dialogue_choices.gd [-- --choice-layout=below]
## 기본(side)은 넓힌 패널 오른쪽 열, below 는 패널 아래 목록을 검사한다.

const Profiles := preload("res://scripts/ui/guest_profiles.gd")

var game
var failures := 0
var total := 0


func _initialize() -> void:
	create_timer(60.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok: failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func frames(n := 2) -> void:
	for i in n: await process_frame


func mouse(at: Vector2, pressed := -1) -> void:
	var m := InputEventMouseMotion.new()
	m.position = at
	m.global_position = at
	root.push_input(m, true)
	await frames(1)
	if pressed < 0: return
	for down in [true, false]:
		var e := InputEventMouseButton.new()
		e.position = at
		e.global_position = at
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = down
		root.push_input(e, true)
		await frames(2)


func key(code: Key) -> void:
	for down in [true, false]:
		var e := InputEventKey.new()
		e.keycode = code
		e.pressed = down
		root.push_input(e, true)
		await frames(1)


func open(ui) -> void:
	var events = game.guest_events
	var profile: Dictionary = Profiles.all_profiles()[0]
	profile["character_id"] = profile["id"]
	events._on_batch([profile])
	events.admit(profile)
	ui.open_conversation(int(profile["visit_uid"]))
	await frames(30)
	ui.advance_dialogue()
	await frames(30)


func _run() -> void:
	root.size = Vector2i(1774, 887)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(12)
	game.session.set_process(false)
	var ui = game.guest_ui
	var pres = ui.presenter

	await open(ui)
	check("선택지 단계", ui.dialogue_phase == "choices" and ui.choices.is_visible_in_tree() and not ui.next_button.visible)
	var panel_rect: Rect2 = pres.panel.get_global_transform() * Rect2(Vector2.ZERO, pres.panel.size)
	var first: Rect2 = ui.choice_buttons[0].get_global_rect()
	var second: Rect2 = ui.choice_buttons[1].get_global_rect()
	var side: bool = ui.choice_layout == "side"
	print("layout: ", ui.choice_layout)
	var text_end: float = pres.stage.position.x + (524.0 + 580.0) * pres.stage.scale.x
	if side:
		check("선택지가 대사 글 열 오른쪽", first.position.x >= text_end, "%.1f vs %.1f" % [first.position.x, text_end])
		check("선택지가 넓힌 패널 안", panel_rect.encloses(first) and panel_rect.encloses(second), str(panel_rect))
		check("세로 카드는 줄바꿈 허용", not ui.choice_buttons[0].clip_text)
	else:
		check("선택지가 패널 아래로 분리", first.position.y >= panel_rect.end.y, "%s vs panel end %.1f" % [first, panel_rect.end.y])
		check("대사 글 열과 같은 왼쪽 정렬", absf(first.position.x - (pres.stage.position.x + 518.0 * pres.stage.scale.x)) < 4.0)
	check("두 줄이 위아래로 겹치지 않음", second.position.y >= first.end.y)
	check("화면 안에 들어옴", second.end.y <= root.size.y and second.end.x <= root.size.x and first.position.x >= 0.0)
	check("왼쪽 정렬", ui.choice_buttons[0].alignment == HORIZONTAL_ALIGNMENT_LEFT)
	check("번호 칩 1·2", ui.choice_buttons[0].key == "1" and ui.choice_buttons[1].key == "2")
	check("선택지 문구", ui.choice_buttons[0].line != "" and ui.choice_buttons[1].text != "")
	check("띄어쓰기에서만 줄바꿈", ui.choice_buttons[0].text.replace("\n", " ") == ui.choice_buttons[0].line and ui.choice_buttons[1].text.replace("\n", " ") == ui.choice_buttons[1].line)
	check("첫 줄에 포커스", ui.choice_buttons[0].has_focus())
	await create_timer(0.7, true, false, true).timeout
	check("등장 모션이 끝나 완전히 보임", is_equal_approx(ui.choice_buttons[1].modulate.a, 1.0))

	await mouse(ui.choice_buttons[1].get_global_rect().get_center())
	await create_timer(0.4, true, false, true).timeout
	check("마우스를 올리면 그 줄로 포커스", ui.choice_buttons[1].has_focus() and ui.choice_buttons[1].lit > 0.9)
	# 버튼 바탕은 네모 상자가 아니라 뒤 패널과 같은 일렁이는 잉크 셰이더
	for i in 2:
		var row = ui.choice_buttons[i]
		var ink: ColorRect = row.get_node("InkBack")
		var mat := ink.material as ShaderMaterial
		check("대답 %d 잉크 셰이더 바탕" % (i + 1), mat != null and mat.shader.resource_path.ends_with("guest_ink_button.gdshader") and ink.show_behind_parent)
		check("대답 %d 패널과 같은 시계" % (i + 1), is_equal_approx(float(mat.get_shader_parameter("motion_time")), pres.clock), "%s vs %s" % [mat.get_shader_parameter("motion_time"), pres.clock])
		var origin: Vector2 = mat.get_shader_parameter("panel_origin")
		var expect: Vector2 = ui.choices.position + row.position + ink.position - row.panel_frame.position
		check("대답 %d 패널 좌표로 일렁임" % (i + 1), origin.distance_to(expect) < 0.5 and is_equal_approx(row.panel_frame.size.x, 1130.0 + pres.panel_extend), str(origin))
	var lit_mat := (ui.choice_buttons[1].get_node("InkBack") as ColorRect).material as ShaderMaterial
	var dim_mat := (ui.choice_buttons[0].get_node("InkBack") as ColorRect).material as ShaderMaterial
	var lit_edge: Color = lit_mat.get_shader_parameter("border_color")
	var dim_edge: Color = dim_mat.get_shader_parameter("border_color")
	check("포커스 줄 금빛 2.5px 테두리", lit_edge.a > 0.8 and lit_edge.r > lit_edge.b and float(lit_mat.get_shader_parameter("border_px")) == 2.5, str(lit_edge))
	var lit_fill: Color = lit_mat.get_shader_parameter("fill_color")
	check("바탕은 손님 이름 글자색(크림)", Color(lit_fill, 1.0).is_equal_approx(pres.name_label.get_theme_color("font_color")) or lit_fill.r8 == 250 and lit_fill.g8 == 230 and lit_fill.b8 == 188, str(lit_fill))
	check("크림 바탕 위 글자는 짙은 잉크", ui.choice_buttons[1].get_theme_color("font_color").get_luminance() < 0.25)
	check("네모 윤곽·울퉁불퉁 출렁임", float(lit_mat.get_shader_parameter("radius_px")) < 40.0 and float(lit_mat.get_shader_parameter("bump_px")) > 2.0)
	check("나머지 줄 옅은 라벤더 1px 테두리", dim_edge.a < 0.3 and float(dim_mat.get_shader_parameter("border_px")) == 1.0, str(dim_edge))
	var t0: float = lit_mat.get_shader_parameter("motion_time")
	await frames(6)
	check("잉크가 시간에 따라 일렁임", float(lit_mat.get_shader_parameter("motion_time")) > t0)
	await key(KEY_UP)
	check("↑ 키로 위 줄", ui.choice_buttons[0].has_focus())

	var gap := Vector2(first.get_center().x, (first.end.y + ui.choice_buttons[1].get_global_rect().position.y) * 0.5)
	await mouse(gap, 1)
	check("줄 사이 틈 클릭 → 대화 유지", ui.dialogue_active and ui.dialogue_phase == "choices")

	var expected: String = ui.choice_buttons[1].line
	await key(KEY_2)
	check("숫자 2 키 → 두 번째 대답", ui.dialogue_phase == "reply" and ui.selected_choice == expected, ui.selected_choice)
	var next_rect: Rect2 = ui.next_button.get_global_rect()
	check("다음 줄(이야기 이어 듣기) 표시", ui.next_button.visible and not ui.choices.visible and (panel_rect.encloses(next_rect) and next_rect.position.x >= text_end if side else next_rect.position.y >= panel_rect.end.y))

	await mouse(ui.close_button.get_global_rect().get_center(), 1)
	check("✕ Esc 버튼 → 닫힘", not ui.dialogue_active)
	check("닫기 버튼이 패널 안 오른쪽 위", panel_rect.encloses(ui.close_button.get_global_rect()))

	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
