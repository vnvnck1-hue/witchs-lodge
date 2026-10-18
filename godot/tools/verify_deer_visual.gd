extends SceneTree
## 새 사슴 모델(assets/animals/deer/deer.glb + scripts/visual/deer_visual.gd) 헤드리스 검증:
## 뼈대·스키닝 구성, 크기·정면 방향·발 접지·고개 펴기, 상태별 모션(걷기 4박자·들 때 무릎 접기·달리기 바운드·
## 풀 뜯기·경계·꼬리·움찔), 실제 게임 야생동물 사슴이 새 비주얼을 쓰고 움직임을 넘기는지.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_deer_visual.gd

const DeerVisual := preload("res://scripts/visual/deer_visual.gd")
const DT := 1.0 / 60.0

var failures := 0
var total := 0


func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
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


func _bone_pos(v, bone: String) -> Vector3:
	return v.skeleton.get_bone_global_rest(v.skeleton.find_bone(bone)).origin


func _run() -> void:
	var v = DeerVisual.new()
	root.add_child(v)
	v.set_process(false)
	var sk: Skeleton3D = v.skeleton

	# 구성
	check("Body/Head 노드", v.has_node("Body/Head"))
	var need := ["Body", "Neck", "Neck2", "Head", "EarL", "EarR", "Tail"]
	for id in ["FL", "FR", "BL", "BR"]:
		need.append(id + "_upper")
		need.append(id + "_lower")
	var missing := need.filter(func(b): return sk.find_bone(b) < 0)
	check("뼈대 15본(몸통·목 2·머리·귀 2·꼬리·다리 4×2)", missing.is_empty() and sk.get_bone_count() == 15, str(missing))
	var meshes: Array = v.find_children("*", "MeshInstance3D", true, false)
	check("부품 11개 모두 스키닝", meshes.size() == 11 and meshes.all(func(m): return m.skin != null and m.mesh.surface_get_material(0) is ShaderMaterial))
	var body_mesh: MeshInstance3D = v.get_node("Body/Skeleton/DeerBody")
	var arr: Array = body_mesh.mesh.surface_get_arrays(0)
	var bones: PackedInt32Array = arr[Mesh.ARRAY_BONES]
	var w: PackedFloat32Array = arr[Mesh.ARRAY_WEIGHTS]
	var per := {}
	for i in w.size():
		if w[i] > 0.5:
			per[bones[i]] = per.get(bones[i], 0) + 1
	check("몸통 메시가 목·꼬리 뼈에 나뉨", per.get(sk.find_bone("Neck"), 0) > 30 and per.get(sk.find_bone("Neck2"), 0) > 30 and per.get(sk.find_bone("Tail"), 0) > 15, str(per))
	var sums_ok := true
	for i in range(0, w.size(), 4):
		sums_ok = sums_ok and absf(w[i] + w[i + 1] + w[i + 2] + w[i + 3] - 1.0) < 0.001
	check("정점 가중치 합 1", sums_ok)

	# 크기·방향
	var box := _bounds(v)
	check("발이 땅에 닿음", absf(box.position.y) < 0.02, str(box))
	check("키 1.4~1.7m(기존 사슴 1.6m)", box.size.y > 1.4 and box.size.y < 1.7, str(box.size))
	check("몸길이 1.3~1.7m", box.size.z > 1.3 and box.size.z < 1.7, str(box.size))
	check("머리가 +Z 쪽", _bone_pos(v, "Head").z > 0.2 and _bone_pos(v, "Tail").z < -0.5)
	check("앞다리 앞·뒷다리 뒤", _bone_pos(v, "FL_upper").z > 0.0 and _bone_pos(v, "BL_upper").z < -0.2)
	check("왼쪽 다리 +X", _bone_pos(v, "FL_upper").x > _bone_pos(v, "FR_upper").x and _bone_pos(v, "BL_upper").x > _bone_pos(v, "BR_upper").x)
	var ears_mid := (_bone_pos(v, "EarL") + _bone_pos(v, "EarR")) * 0.5
	check("고개 펴기: 두 귀가 목 위 좌우 대칭(앞뒤 차 작음)", absf(_bone_pos(v, "EarL").z - _bone_pos(v, "EarR").z) < 0.06 and absf(ears_mid.x - _bone_pos(v, "Head").x) < 0.06,
		"L %s R %s" % [_bone_pos(v, "EarL"), _bone_pos(v, "EarR")])
	check("무릎이 다리 중간", _bone_pos(v, "FL_lower").y > 0.15 and _bone_pos(v, "FL_lower").y < _bone_pos(v, "FL_upper").y)

	# 걷기: 4박자(다리 위상이 1/4씩 어긋남), 드는 다리는 무릎을 접는다
	v.speed = 0.9
	_step(v, 1.5)
	var max_leg := 0.0
	var flexed := 0
	var lift_order := []
	var was_lifted := {}
	for i in 120:
		v._process(DT)
		for id in ["BL", "FL", "BR", "FR"]:
			max_leg = maxf(max_leg, absf(v.leg_angle[id]))
			var lifted: bool = absf(v.knee_angle[id]) > 0.3
			if lifted: flexed += 1
			if lifted and not was_lifted.get(id, false):
				lift_order.append(id)
			was_lifted[id] = lifted
	var seq := "".join(lift_order.slice(0, 8))
	check("걷기: 다리 흔들림", max_leg > 0.25, "%.2f" % max_leg)
	check("걷기: 드는 다리 무릎 접힘", flexed > 60, str(flexed))
	check("걷기: 뒤왼→앞왼→뒤오→앞오 순서", seq in ["BLFLBRFRBLFLBRFR", "FLBRFRBLFLBRFRBL", "BRFRBLFLBRFRBLFL", "FRBLFLBRFRBLFLBR"], seq)
	check("걷기: 고개 거의 수평", v.neck_pitch > -0.05 and v.neck_pitch < 0.2, "%.2f" % v.neck_pitch)

	# 달리기(경계): 앞 한 쌍·뒤 한 쌍이 함께, 크게 뛰고 고개·꼬리를 든다
	v.speed = 2.6
	v.alarmed = true
	_step(v, 1.0)
	var pair := 0
	var bob := 0.0
	var pitch := 0.0
	for i in 60:
		v._process(DT)
		if absf(v.leg_angle["FL"] - v.leg_angle["FR"]) < 0.35 and absf(v.leg_angle["BL"] - v.leg_angle["BR"]) < 0.35: pair += 1
		bob = maxf(bob, v.body.position.y)
		pitch = maxf(pitch, absf(v.body.rotation.x))
	check("달리기: 앞뒤 한 쌍씩 함께", pair >= 50, str(pair))
	check("달리기: 크게 뛰어오름", bob > 0.1, "%.3f" % bob)
	check("달리기: 몸 앞뒤로 흔들림", pitch > 0.08, "%.3f" % pitch)
	check("경계: 목을 세움", v.neck_pitch < -0.1, "%.2f" % v.neck_pitch)
	var tail_q: Quaternion = sk.get_bone_pose_rotation(sk.find_bone("Tail"))
	check("경계: 꼬리 치켜듦", tail_q.get_euler().x > 0.25, "%.2f" % tail_q.get_euler().x)

	# 풀 뜯기: 목을 깊이 숙였다가 들고 씹는다
	v.speed = 0.0
	v.alarmed = false
	v.grazing = true
	v._graze_up = false
	v._graze_t = 3.0
	_step(v, 2.5)
	var low: float = v.neck_pitch
	var head_low: float = sk.get_bone_global_pose(sk.find_bone("Head")).origin.y
	var up_min := 9.0
	for i in 150:
		v._process(DT)
		up_min = minf(up_min, v.neck_pitch)
	check("풀 뜯기: 목을 깊이 숙임", low > 1.2, "%.2f" % low)
	check("풀 뜯기: 머리가 등보다 한참 아래로", head_low < 0.9, "%.2f(등 높이 약 1.27)" % head_low)
	check("풀 뜯기: 중간에 고개 들고 씹음", up_min < 0.3, "%.2f" % up_min)
	check("정지: 다리 제자리", absf(v.leg_angle["FL"]) < 0.05)
	check("Head 노드가 머리 뼈를 따름", v.head.position.is_equal_approx(sk.get_bone_global_pose(sk.find_bone("Head")).origin))

	# 움찔
	v.grazing = false
	_step(v, 1.0)
	v.flinch()
	var fl := 1.0
	for i in 20:
		v._process(DT)
		fl = minf(fl, v.neck_pitch)
	check("움찔: 목 젖힘", fl < -0.2, "%.2f" % fl)
	v.free()

	# 실제 게임: 야생동물 사슴이 새 비주얼을 쓰고 움직임을 넘긴다
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	for i in 8:
		await process_frame
	var deer = game.wildlife.spawn("deer", Vector3(-6.0, 0, 11.0))
	check("게임 사슴 출현", deer != null)
	if deer != null:
		await process_frame
		check("게임 사슴이 새 비주얼 사용", deer.visual is DeerVisual and deer.head != null)
		deer._wait = 0.0
		deer._target = deer.global_position + Vector3(2.5, 0, 0)
		var moved := 0.0
		for i in 30:
			await physics_frame
			moved = maxf(moved, deer.visual.speed)
		check("게임 사슴 이동 속도 전달", moved > 0.3, "%.2f" % moved)
		deer.take_damage(0.1)
		check("피격 시 움찔", deer.visual._flinch > 0.5)
	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
