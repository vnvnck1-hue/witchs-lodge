extends SceneTree
## 카드 고르기 화면의 호버 들어 올리기(scripts/ui/card_lift.gd) 검증.
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_card_lift.gd

const CardLift := preload("res://scripts/ui/card_lift.gd")

var _pass := 0
var _total := 0
var _phase := "pick"
var _hovers := 0


func _check(label: String, ok: bool) -> void:
	_total += 1
	if ok:
		_pass += 1
	print(("PASS " if ok else "FAIL ") + label)


func _run(lift, frames: int) -> void:
	for i in frames:
		lift.step(1.0 / 60.0)


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	var root := Control.new()
	root.size = Vector2(1600, 900)
	get_root().add_child(root)
	var btn := TextureButton.new()
	btn.size = Vector2(200, 300)
	btn.position = Vector2(-5000, -5000)  # 헤드리스 마우스(0,0)가 닿지 않는 곳
	root.add_child(btn)
	await process_frame
	var lift = CardLift.attach(btn, func(): return _phase == "pick", func(): _hovers += 1)
	_check("CardLift 노드가 버튼에 붙음", btn.get_node_or_null("CardLift") == lift)
	_check("피벗이 카드 가운데", btn.pivot_offset == Vector2(100, 150))

	# 쉬는 동안엔 버튼 위치(연출 트윈)를 따라간다
	btn.position = Vector2(300, 200)
	_run(lift, 3)
	_check("쉬는 동안 base 가 버튼 위치를 따라감", lift.base == Vector2(300, 200) and btn.position == Vector2(300, 200))

	# 호버: 위로 솟고 커지고 위에 그려진다
	lift.forced = true
	_run(lift, 40)
	_check("호버 시작에 소리 콜백 1번", _hovers == 1)
	_check("호버하면 위로 솟음(%.1fpx)" % (200.0 - btn.position.y), btn.position.y < 200.0 - CardLift.LIFT * 0.9)
	_check("호버하면 x 는 그대로", is_equal_approx(btn.position.x, 300.0))
	_check("호버하면 조금 커짐", btn.scale.x > 1.0 + CardLift.GROW * 0.9 and btn.scale.x <= 1.0 + CardLift.GROW + 0.001)
	_check("들린 카드가 위에 그려짐", btn.z_index == 1)
	_check("들린 동안 쉬는 자리 아래 띠도 호버 영역", lift.zone().has_point(Vector2(400, 200 + 290)) and lift.zone().has_point(Vector2(400, 200 - CardLift.LIFT + 1)))

	# 호버 해제: 제자리로 돌아온다
	lift.forced = false
	_run(lift, 60)
	_check("마우스가 떠나면 제자리·원래 크기", btn.position == Vector2(300, 200) and btn.scale == Vector2.ONE and btn.rotation_degrees == 0.0 and btn.z_index == 0)

	# 판매됨(비활성) 버튼은 들리지 않는다
	btn.disabled = true
	lift.forced = true
	_run(lift, 30)
	_check("비활성(구매함) 카드는 들리지 않음", btn.position == Vector2(300, 200) and btn.scale == Vector2.ONE)
	btn.disabled = false

	# 고른 뒤(연출 단계)엔 손을 떼고 트윈에 맡긴다 — 위치를 되돌리지 않는다
	_run(lift, 40)
	var lifted_y := btn.position.y
	_phase = "reveal"
	_run(lift, 5)
	_check("연출 단계로 넘어가면 그 자리에서 손을 뗌", is_equal_approx(btn.position.y, lifted_y) and lift.hovered == false)
	btn.position = Vector2(500, 260)
	_run(lift, 3)
	_check("손을 뗀 뒤엔 트윈 위치를 덮어쓰지 않음", btn.position == Vector2(500, 260))
	lift.forced = false

	# 네 화면 모두 카드 버튼에 CardLift 를 붙인다
	for path in ["res://scripts/ui/offer_screen.gd", "res://scripts/ui/mulligan_screen.gd",
			"res://scripts/ui/chest_opening.gd", "res://scripts/ui/spellbook_picker.gd"]:
		var src := FileAccess.get_file_as_string(path)
		_check("%s 카드에 CardLift.attach" % path.get_file(), src.contains("CardLift.attach(btn"))
		_check("%s 옛 1.06 확대 제거" % path.get_file(), not src.contains("Vector2(1.06, 1.06)"))
		var scr: GDScript = load(path)
		_check("%s 로드" % path.get_file(), scr != null and scr.can_instantiate())

	print("RESULT %d/%d" % [_pass, _total])
	quit(0 if _pass == _total else 1)
