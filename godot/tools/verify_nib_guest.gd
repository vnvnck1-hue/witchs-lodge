extends SceneTree
## 고블린 니브 3D 손님 헤드리스 검증(docs/character-3d-pipeline.md 4단계).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_nib_guest.gd
## 실제 main.tscn 에서 손님 생성과 같은 방식으로 니브를 걸려 보내 걷기 → 문 앞 인사 → 입실 → 퇴실(손 흔들기)을 확인한다.

const TravelerScript := preload("res://scripts/actors/traveler.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")
const Layout := preload("res://scripts/world/layout.gd")

var passed := 0
var total := 0

func check(ok: bool, label: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)

func _initialize() -> void: call_deferred("_run")

func frames(n: int) -> void:
	for i in n: await process_frame

func height_of(n: Node) -> float:
	var out := AABB()
	var first := true
	for mi in n.find_children("*", "MeshInstance3D", true, false):
		if mi.mesh == null or not mi.is_visible_in_tree(): continue
		var b: AABB = mi.global_transform * mi.mesh.get_aabb()
		out = b if first else out.merge(b)
		first = false
	return out.size.y

func spawn(game, id: String):
	var g := TravelerScript.new()
	g.profile = GuestProfiles.guest_profile(id)
	var pts: Array = Layout.TRAVELER_ROUTE.duplicate()
	pts[pts.size() - 1] = Layout.DOOR_FRONT
	g.setup(pts, 0.0)
	g.position = pts[0]
	game.actors.add_child(g)
	return g

func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	get_root().add_child(game)
	await frames(20)
	game.session.set_process(false)
	game.economy.set_process(false)
	Engine.time_scale = 6.0

	var nib = spawn(game, "nib")
	await frames(2)
	var model: Node = null
	for n in nib.find_children("*", "Node3D", true, false):
		if str(n.get_meta("character_id", "")) == "goblin_nib": model = n
	check(model != null, "니브 손님이 전용 3D 모델(goblin_nib)로 나온다")
	check(nib.rig != null and nib.rig.pivots.size() == 7, "묶음 피벗 7개 애니메이터 연결")
	# 사용자 지시: 마녀와 비슷하되 더 작게. 서 있는 키(장면 1.0m × 배율)로 비교한다 — 걸을 때 튀는 높이·지팡이는 빼고.
	var CM = load("res://scripts/visual/character_models.gd")
	var nib_h: float = float(CM.CATALOG["nib"].scale)
	var witch_h: float = float(CM.CATALOG["witch_north"].scale) * game.player.visual.scale.y if CM.has_model("witch_north") else 1.84
	check(nib_h < witch_h and nib_h > witch_h * 0.6, "니브 키 %.2fm — 마녀 %.2fm 보다 조금 작게" % [nib_h, witch_h])
	check(nib.visual.find_child("Mouth", true, false) != null, "입김 위치 표식(Mouth)")

	var human = spawn(game, "garok")
	await frames(2)
	var garok_model := ""
	for n in human.find_children("*", "Node3D", true, false):
		if str(n.get_meta("character_id", "")) != "": garok_model = str(n.get_meta("character_id"))
	check(human.rig != null and garok_model == "orc_common", "다른 종족 손님(오크 가로크)은 자기 종족 공용 모델(orc_common)")
	human.queue_free()


	# 걷기: 다리가 번갈아 움직인다.
	await frames(10)
	check(nib.rig.state == "walk", "이동 중 상태 walk")
	var leg: Node3D = nib.rig.pivots["leg_r"]
	var samples := []
	for i in 6:
		samples.append(leg.rotation_degrees.x)
		await frames(3)
	check(samples.max() - samples.min() > 15.0, "걷기 다리 흔들림 %.0f°" % (samples.max() - samples.min()))

	# 문 앞 인사 → 입실.
	var arrived := [false]
	nib.arrived.connect(func(): arrived[0] = true)
	var greeted := false
	var greet_visible := false
	var arm_raise := 0.0
	for i in 4000:
		await process_frame
		if nib.rig.state == "greet":
			greeted = true
			greet_visible = greet_visible or nib.visible
			arm_raise = minf(arm_raise, nib.rig.pivots["arm_r"].rotation_degrees.x)
		if arrived[0]: break
	check(greeted and greet_visible, "문 앞에서 흥정 인사(greet)를 보인다")
	check(arm_raise < -50.0, "인사 때 오른손을 앞으로 내민다(%.0f°)" % arm_raise)
	check(arrived[0] and not nib.visible, "인사 후 입실(숨김)·arrived 신호")
	check(nib.position.distance_to(Layout.DOOR_FRONT) < 0.05, "문 앞 위치에서 입실")

	# 퇴실: 다시 나타나 손을 흔들며 떠난다.
	var back: Array = Layout.TRAVELER_ROUTE.duplicate()
	back.reverse()
	nib.leave(back, 0.0)
	await frames(4)
	check(nib.visible and nib.rig.state == "wave", "퇴실 시작에 손 흔들기(wave)")
	check(nib.rig.pivots["arm_l"].rotation_degrees.z > 60.0, "왼팔을 들어 흔든다")
	var freed := false
	var walked := false
	for i in 6000:
		await process_frame
		if not is_instance_valid(nib):
			freed = true
			break
		if nib.rig.state == "walk": walked = true
	check(walked, "손 흔든 뒤 걷기로 돌아간다")
	check(freed, "숲길 끝에서 퇴장(해제)")
	# 다른 고블린 손님(그라즈)은 등짐·귀걸이를 뺀 공용 고블린, 흥정 인사 없이 바로 입실.
	var gob = spawn(game, "graz")
	await frames(2)
	var common: Node = null
	for n in gob.find_children("*", "Node3D", true, false):
		if str(n.get_meta("character_id", "")) == "goblin_common": common = n
	check(common != null and gob.rig != null and gob.rig.pivots.size() == 6 and not gob.rig.pivots.has("backpack"),
		"고블린 손님(그라즈)은 공용 고블린 모델(등짐 없음, 묶음 6개)")
	var gob_in := [false]
	gob.arrived.connect(func(): gob_in[0] = true)
	var gob_greet := false
	for i in 6000:
		await process_frame
		if gob.rig.state == "greet": gob_greet = true
		if gob_in[0]: break
	check(gob_in[0] and not gob_greet, "공용 고블린은 흥정 인사 없이 바로 입실(니브만의 동작)")
	gob.queue_free()
	Engine.time_scale = 1.0
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
