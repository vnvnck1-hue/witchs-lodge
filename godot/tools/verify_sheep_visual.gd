extends SceneTree
## 새 양 모델(assets/animals/sheep/sheep.glb + scripts/visual/sheep_visual.gd) 헤드리스 검증:
## 부품·피벗·스키닝 구성, 크기·방향·발 접지, 상태별 모션(걷기 대각 교대·달리기 바운드·풀 뜯기·놀람·털깎기 떨기·움찔·울기),
## 검은 양 재질, 실제 게임 목장의 양이 새 비주얼을 쓰고 이동 속도를 넘기는지.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_sheep_visual.gd

const SheepVisual := preload("res://scripts/visual/sheep_visual.gd")
const Sheep := preload("res://scripts/actors/sheep.gd")
const DT := 1.0 / 60.0

var failures := 0
var total := 0


func _initialize() -> void:
	create_timer(90.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func _bounds(n: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for mi: MeshInstance3D in n.find_children("*", "MeshInstance3D", true, false):
		var b := mi.global_transform * mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box


func _step(v, seconds: float) -> void:
	for i in int(seconds / DT):
		v._process(DT)


func _run() -> void:
	var v = SheepVisual.new()
	root.add_child(v)
	v.set_process(false)

	# 구성
	check("Body/Head 노드", v.has_node("Body/Head"))
	check("다리 4개", v.legs.size() == 4 and v.has_node("Body/LegFL") and v.has_node("Body/LegBR"))
	check("귀 2개·꼬리", v.ears.size() == 2 and v.has_node("Body/Head/EarL/Ear") and v.has_node("Body/Tail/WoolTail"))
	check("뼈대 2본(몸통·머리)", v.skeleton.get_bone_count() == 2 and v.skeleton.get_bone_parent(1) == 0)
	var wool: MeshInstance3D = v.get_node("Body/Skeleton/WoolBody")
	var arr: Array = wool.mesh.surface_get_arrays(0)
	var w: PackedFloat32Array = arr[Mesh.ARRAY_WEIGHTS]
	var head_v := 0
	var body_v := 0
	for i in range(0, w.size(), 4):
		if w[i + 1] > 0.95:
			head_v += 1
		elif w[i] > 0.95:
			body_v += 1
	check("몸통 메시 스키닝(머리·몸통 정점 모두 있음)", head_v > 50 and body_v > 500, "head %d body %d" % [head_v, body_v])
	var all_paint := true
	for mi: MeshInstance3D in v.find_children("*", "MeshInstance3D", true, false):
		all_paint = all_paint and mi.mesh.surface_get_material(0) is ShaderMaterial
	check("모든 부품 페인트 셰이더 재질", all_paint)

	# 크기·방향·접지
	var box := _bounds(v)
	check("발이 땅에 닿음", absf(box.position.y) < 0.02, str(box))
	check("몸길이 0.8~1.1m", box.size.z > 0.8 and box.size.z < 1.1, str(box.size))
	check("키 0.6~0.8m", box.size.y > 0.6 and box.size.y < 0.8, str(box.size))
	check("머리가 +Z 쪽", v.head.position.z > 0.15 and (v.legs["FL"] as Node3D).position.z > (v.legs["BL"] as Node3D).position.z)
	check("왼쪽 다리가 +X", (v.legs["FL"] as Node3D).position.x > 0.0 and (v.legs["FR"] as Node3D).position.x < 0.0)

	# 걷기: 대각 다리(FL·BR)가 같이, FL·FR 은 반대로
	v.speed = 0.45
	_step(v, 1.0)
	var same := 0
	var opposite := 0
	var max_leg := 0.0
	var max_bob := 0.0
	for i in 60:
		v._process(DT)
		var fl: float = v.legs["FL"].rotation.x
		var fr: float = v.legs["FR"].rotation.x
		var br: float = v.legs["BR"].rotation.x
		if absf(fl - br) < 0.05: same += 1
		if fl * fr < 0.0 or absf(fl) < 0.05: opposite += 1
		max_leg = maxf(max_leg, absf(fl))
		max_bob = maxf(max_bob, v.body.position.y)
	check("걷기: 다리 흔들림", max_leg > 0.3, "%.2f" % max_leg)
	check("걷기: 대각 다리 같은 위상", same >= 55, str(same))
	check("걷기: 좌우 앞다리 반대 위상", opposite >= 55, str(opposite))
	check("걷기: 몸 통통 튐", max_bob > 0.01 and max_bob < 0.04, "%.3f" % max_bob)
	check("걷기: 고개 거의 수평", v.head_pitch > -0.05 and v.head_pitch < 0.2, "%.2f" % v.head_pitch)

	# 달리기(놀람): 앞다리 한 쌍이 함께, 더 크게 뛰고 고개를 든다
	v.speed = 1.1
	v.alarmed = true
	_step(v, 1.0)
	var front_pair := 0
	var run_bob := 0.0
	var run_pitch := 0.0
	for i in 60:
		v._process(DT)
		if absf(v.legs["FL"].rotation.x - v.legs["FR"].rotation.x) < 0.5: front_pair += 1
		run_bob = maxf(run_bob, v.body.position.y)
		run_pitch = maxf(run_pitch, absf(v.body.rotation.x))
	check("달리기: 앞다리 한 쌍이 함께", front_pair >= 55, str(front_pair))
	check("달리기: 크게 뛰어오름", run_bob > 0.045, "%.3f" % run_bob)
	check("달리기: 몸 앞뒤로 흔들림", run_pitch > 0.06, "%.3f" % run_pitch)
	check("놀람: 고개 듦", v.head_pitch < -0.1, "%.2f" % v.head_pitch)
	check("놀람: 귀 뒤로 접힘", absf(v.ears["EarL"].rotation.y) > 0.4, "%.2f" % v.ears["EarL"].rotation.y)
	check("놀람: 꼬리 치켜듦", v.tail.rotation.x > 0.25, "%.2f" % v.tail.rotation.x)

	# 정지·풀 뜯기: 고개를 숙였다 들었다 한다
	v.speed = 0.0
	v.alarmed = false
	v.grazing = true
	var low := 0.0
	var high := 1.0
	_step(v, 1.0)   # 놀란 자세에서 풀 뜯는 자세로 넘어간 뒤부터 잰다
	for i in 600:
		v._process(DT)
		low = maxf(low, v.head_pitch)
		high = minf(high, v.head_pitch)
	check("풀 뜯기: 고개 숙임", low > 0.45, "%.2f" % low)
	check("풀 뜯기: 중간에 고개 들고 씹음", high < 0.2, "%.2f" % high)
	check("정지: 다리 제자리", absf(v.legs["FL"].rotation.x) < 0.05)
	var bone_rot: Quaternion = v.skeleton.get_bone_pose_rotation(1)
	check("머리 뼈가 Head 노드를 따름", bone_rot.is_equal_approx(v.head.quaternion))

	# 털깎기: 붙잡혀 떤다
	v.grazing = false
	v.held = true
	v.shearing = true
	var roll := 0.0
	for i in 60:
		v._process(DT)
		roll = maxf(roll, absf(v.body.rotation.z))
	check("털깎기: 몸 떨림", roll > 0.03, "%.3f" % roll)
	v.held = false
	v.shearing = false
	_step(v, 1.0)

	# 움찔·울기
	v.flinch()
	var fl_pitch := 1.0
	for i in 20:
		v._process(DT)
		fl_pitch = minf(fl_pitch, v.head_pitch)
	check("움찔: 고개 젖힘", fl_pitch < -0.15, "%.2f" % fl_pitch)
	_step(v, 1.5)
	v.bleat()
	var bl := 1.0
	for i in 50:
		v._process(DT)
		bl = minf(bl, v.head_pitch)
	check("울기: 고개 듦", bl < -0.12, "%.2f" % bl)

	# 검은 양
	var bv = SheepVisual.new()
	root.add_child(bv)
	bv.set_black()
	var dark := true
	for mi: MeshInstance3D in bv.find_children("*", "MeshInstance3D", true, false):
		dark = dark and mi.material_override is ShaderMaterial and mi.material_override != mi.mesh.surface_get_material(0)
	check("검은 양: 부품마다 개별 어두운 재질", dark)
	check("검은 양: 공유 재질은 그대로", (wool.mesh.surface_get_material(0) as ShaderMaterial).get_shader_parameter("base_color") != Color("4a3f5e"))
	bv.free()
	v.free()

	# 실제 게임: 목장 양이 새 비주얼을 쓰고 움직임을 넘긴다
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	for i in 8:
		await process_frame
	var herd: Array = get_nodes_in_group("sheep").filter(func(s): return s is Sheep and not s.dead)
	check("목장 양 있음", herd.size() >= 1, str(herd.size()))
	if not herd.is_empty():
		var s = herd[0]
		check("게임 양이 새 비주얼 사용", s.visual is SheepVisual)
		s._wait = 0.0
		var r: Rect2 = s.pasture.wander_rect()
		s._target = Vector3(r.get_center().x, 0, r.get_center().y)
		s.global_position = s._target + Vector3(0.8, 0, 0)
		var moved := 0.0
		for i in 10:
			await process_frame
			moved = maxf(moved, s.visual.speed)
		check("게임 양 이동 속도 전달", moved > 0.2, "%.2f" % moved)
		s.take_damage(0.1)
		check("피격 시 움찔", s.visual._flinch > 0.5)
	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
