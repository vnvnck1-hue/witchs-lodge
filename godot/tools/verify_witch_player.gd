extends SceneTree
## 플레이어 마녀(북쪽의 마녀) 파츠 캐릭터 헤드리스 검증(docs/character-3d-pipeline.md 4단계).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_witch_player.gd
## 실제 main.tscn 의 플레이어에서 모델 교체·지팡이·가위·크기와 상태별 애니메이션(서 있기·걷기·공격 준비·발사·털 깎기·괴로움)을 확인한다.

var passed := 0
var total := 0

func check(ok: bool, label: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)

func world_box(n: Node, skip: Node = null) -> AABB:
	var out := AABB()
	var first := true
	for mi in n.find_children("*", "MeshInstance3D", true, false):
		if mi.mesh == null or not mi.is_visible_in_tree(): continue
		if skip != null and (mi == skip or skip.is_ancestor_of(mi)): continue
		var b: AABB = mi.global_transform * mi.mesh.get_aabb()
		out = b if first else out.merge(b)
		first = false
	return out

func _initialize() -> void: call_deferred("_run")

func frames(n: int) -> void:
	for i in n: await process_frame

func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	get_root().add_child(game)
	await frames(20)
	game.session.set_process(false)
	game.economy.set_process(false)
	var p = game.player

	var model: Node = null
	for n in p.visual.find_children("*", "Node3D", true, false):
		if str(n.get_meta("character_id", "")) == "witch_north": model = n
	check(model != null, "플레이어가 북쪽의 마녀 파츠 모델로 나온다")
	check(p.rig != null and p.rig.pivots.size() == 8, "묶음 피벗 8개 애니메이터")
	check(p.staff != null and p.staff.get_parent().name == "Hand_arm_l", "지팡이를 왼손(arm_l)에 쥔다")
	check(p.staff_tip != null and p.staff.is_ancestor_of(p.staff_tip), "지팡이 끝(Tip) 표식")
	check(p.shears != null and p.shears.get_parent().name == "Hand_arm_r", "털 깎는 가위는 오른손")

	var witch_box := world_box(p.visual, p.staff)
	var staff_box := world_box(p.staff)
	var h: float = witch_box.size.y
	check(h > 1.3 and h < 1.65, "마녀 키 %.2fm (니브 1.3m 보다 조금 크게)" % h)
	check(absf(witch_box.position.y - p.global_position.y) < 0.05, "발이 땅(y %.3f)" % (witch_box.position.y - p.global_position.y))
	check(absf(staff_box.size.y - 1.48) < 0.12 and staff_box.position.y - p.global_position.y < 0.15,
		"지팡이 길이 %.2fm·밑동 높이 %.2fm(기존 크기 유지)" % [staff_box.size.y, staff_box.position.y - p.global_position.y])
	check(p.visual.find_child("Mouth", true, false) != null, "입김 위치 표식(Mouth)")

	# 서 있기 → 걷기
	p._animate(0.016, false)
	await frames(2)
	check(p.rig.state == "idle", "멈춰 있으면 idle")
	p._animate(0.016, true)
	var leg: Node3D = p.rig.pivots["leg_r"]
	var lantern: Node3D = p.rig.pivots["lantern"]
	var lo := 999.0
	var hi := -999.0
	var lan := 0.0
	var walk_seen := false
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 1000:   # 실제 1초(헤드리스는 프레임이 빨라 횟수로 세면 한 걸음도 안 된다)
		p._animate(0.016, true)
		walk_seen = walk_seen or p.rig.state == "walk"   # 실제 물리 갱신이 멈춘 플레이어를 idle 로 되돌릴 수 있어 마지막 상태가 아니라 보인 적이 있는지 본다
		await process_frame
		lo = minf(lo, leg.rotation_degrees.x)
		hi = maxf(hi, leg.rotation_degrees.x)
		lan = maxf(lan, absf(lantern.rotation_degrees.x))
	check(walk_seen and hi - lo > 20.0, "걷기 다리 흔들림 %.0f°" % (hi - lo))
	check(lan > 5.0, "걸을 때 허리 등불이 흔들린다(%.0f°)" % lan)

	# 공격 준비 → 발사
	p.attack_windup = p.ATTACK_WINDUP * 0.2
	p._animate(0.016, false)
	await frames(2)
	p._animate(0.016, false)
	var arm: Node3D = p.rig.pivots["arm_l"]
	check(p.rig.state == "windup" and arm.rotation_degrees.x < -40.0, "공격 준비: 지팡이 팔을 든다(%.0f°)" % arm.rotation_degrees.x)
	p.attack_windup = 0.0
	p._cast_t = 0.3
	p._animate(0.016, false)
	await frames(3)
	check(p.rig.state == "cast", "발사(cast)")
	p._cast_t = 0.0

	# 털 깎기
	p.shearing = true
	p._animate(0.016, false)
	await frames(2)
	p._animate(0.016, false)
	check(p.rig.state == "work" and p.shears.visible and p.rig.pivots["arm_r"].rotation_degrees.x < -40.0, "털 깎기: 오른손을 내밀고 가위를 든다")
	p.shearing = false

	# 괴로움
	p.suffering = 0.5
	p._suffer_total = 1.0
	p._animate_suffer(0.016)
	await frames(2)
	check(p.rig.state == "hurt", "괴로움(hurt): 몸을 감싼다")
	p.suffering = 0.0
	p._animate_suffer(0.0)

	# 늑대 변신 시 마녀 몸(지팡이 포함) 숨김
	p.set_wolf(true)
	await frames(2)
	check(not model.is_visible_in_tree() and not p.staff.is_visible_in_tree(), "늑대 변신 때 마녀 모델·지팡이 숨김")
	p.set_wolf(false)
	await frames(2)
	check(model.is_visible_in_tree(), "변신 해제 후 다시 보임")
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
