extends SceneTree
## 서리 거미(기본 적) 헤드리스 검증: GLB·리그 구성, IK 정확도, 교대 보행·발 고정, 늘어남 없음, 깜빡임,
## 공격·피격·죽음 동작, 달리다 멈칫 평균 속도, 실제 게임 웨이브 출현(기본 적 = 서리 거미, 표식 개체 = 큰 숲의 괴물).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_spider.gd

const SpiderVisual := preload("res://scripts/visual/spider_visual.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const ChapterData := preload("res://scripts/game/chapter_data.gd")
const Cfg := preload("res://scripts/config.gd")
const DT := 1.0 / 60.0

var passed := 0
var total := 0


func _initialize() -> void:
	call_deferred("_run")


func check(label: String, ok: bool, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print(("PASS " if ok else "FAIL ") + label + ("  — " + detail if detail != "" else ""))


func _run() -> void:
	check("GLB 자산 존재", ResourceLoader.exists(SpiderVisual.GLB))
	var holder := CharacterBody3D.new()
	root.add_child(holder)
	var v: Node3D = SpiderVisual.new()
	holder.add_child(v)
	v.set_process(false)
	var mesh: ArrayMesh = v.legs_mesh.mesh
	check("다리 8개(원본 6 + 뒷다리 복제 2)·뼈 32개", mesh.get_surface_count() == 8 and v.skeleton.get_bone_count() == 32,
		"surfaces=%d bones=%d" % [mesh.get_surface_count(), v.skeleton.get_bone_count()])
	var parts_ok: bool = v.head_mesh != null and v.get_node_or_null("Body/Abdomen/tripo_part_1") != null \
		and v.get_node_or_null("Body/Head/FangL/tripo_part_13") != null and v.get_node_or_null("Body/Head/FangR/tripo_part_12") != null
	check("머리(눈 셰이더)·배·송곳니 2개 부품 연결", parts_ok and v.head_mesh.mesh.surface_get_material(0).shader == SpiderVisual.EYES)
	var weights_ok := true
	for s in mesh.get_surface_count():
		var arr := mesh.surface_get_arrays(s)
		var w: PackedFloat32Array = arr[Mesh.ARRAY_WEIGHTS]
		var b: PackedInt32Array = arr[Mesh.ARRAY_BONES]
		for i in range(0, w.size(), 4):
			if absf(w[i] + w[i + 1] + w[i + 2] + w[i + 3] - 1.0) > 0.001 or b[i] / 4 != s or b[i + 1] / 4 != s:
				weights_ok = false
	check("스킨 가중치 합 1·각 다리는 자기 뼈 4개만 사용", weights_ok)
	var chain_ok := true
	var chain_bad := []
	for id in SpiderVisual.LEG_ORDER:
		var leg: Dictionary = v._rig["legs"][id]
		var j: Array = leg["joints"]
		var knee_up: bool = j[2].y > j[4].y + 0.05 and j[2].y >= j[0].y - 0.05   # 앞다리 무릎은 엉덩이 높이 근처
		var leg_ok: bool = knee_up and j[4].y - SpiderVisual.GROUND_DROP < 0.03 and float(leg["length"]) > 0.2 and float(leg["l1"]) > float(leg["length"]) * 0.25
		if not leg_ok: chain_bad.append("%s(knee=%.2f tip=%.3f l1=%.3f)" % [id, j[2].y, j[4].y, leg["l1"]])
		chain_ok = chain_ok and leg_ok
	check("관절 추출: 무릎이 발끝보다 높고 넓적마디가 충분히 길며 몸을 내린 뒤 발끝이 지면 근처(<3cm)", chain_ok, " ".join(chain_bad))

	# 휴식 자세 IK: 발끝이 목표에 정확히
	v._process(DT)
	var rest_err := 0.0
	for li in 8:
		rest_err = maxf(rest_err, v.leg_tip_world(li).distance_to(v.feet[SpiderVisual.LEG_ORDER[li]]["foot"]))
	check("정지 자세: 8다리 발끝이 디딘 점과 일치(<1cm)", rest_err < 0.01, "max=%.4f" % rest_err)

	# 걷기 + 회전: 3초 직진, 2초 원 돌기
	var max_err := 0.0
	var slide := 0.0
	var both := 0
	var over := 0.0
	var prev: Dictionary = {}
	var t := 0.0
	var steps0: int = v.steps_taken
	for f in 300:
		t += DT
		var dir := Vector3(0, 0, 1) if t < 3.0 else Vector3(cos(t * 2.0), 0, sin(t * 2.0))
		holder.velocity = dir * 1.7
		holder.global_position += holder.velocity * DT
		v.rotation.y = lerp_angle(v.rotation.y, atan2(dir.x, dir.z), DT * 8.0)
		v._process(DT)
		var a := 0
		var b := 0
		for li in 8:
			var id: String = SpiderVisual.LEG_ORDER[li]
			var st: Dictionary = v.feet[id]
			var tip: Vector3 = v.leg_tip_world(li)
			var leg: Dictionary = v._rig["legs"][id]
			var hip: Vector3 = v.skeleton.global_transform * (leg["joints"][0] as Vector3)
			over = maxf(over, hip.distance_to(st["foot"]) / (float(leg["length"]) * v._gscale() + 0.06 * v._gscale()))
			if st["step"]:
				if id in SpiderVisual.GROUP_A: a += 1
				else: b += 1
				prev.erase(id)
			else:
				max_err = maxf(max_err, tip.distance_to(st["foot"]))
				if prev.has(id):
					slide = maxf(slide, (prev[id] as Vector3).distance_to(st["foot"]))
				prev[id] = st["foot"]
		if a > 0 and b > 0:
			both += 1
	var steps: int = v.steps_taken - steps0
	check("걷기: 5초 동안 발걸음 발생(>= 60)", steps >= 60, "steps=%d" % steps)
	check("걷기: 디딘 발은 미끄러지지 않음", slide < 0.002, "max slide=%.4f" % slide)
	check("걷기: 디딘 발 끝이 목표와 일치(<3cm)", max_err < 0.03, "max=%.4f" % max_err)
	check("교대 4족 보행: 두 무리가 동시에 공중인 프레임 10% 미만", both < 30, "frames=%d/300" % both)
	check("다리가 길이 이상 늘어나지 않음(엉덩이~발 ≤ 다리 길이 +여유)", over <= 1.0, "ratio=%.3f" % over)

	# 정지 후 발이 제자리로 모임
	holder.velocity = Vector3.ZERO
	for f in 90:
		v._process(DT)
	var settle := 0.0
	for id in SpiderVisual.LEG_ORDER:
		var hw: Vector3 = v._home_world(id)
		settle = maxf(settle, Vector2(hw.x, hw.z).distance_to(Vector2(v.feet[id]["foot"].x, v.feet[id]["foot"].z)))
	check("멈추면 발이 서 있는 자세로 정리됨", settle < SpiderVisual.IDLE_SETTLE * v._gscale() * 1.6, "max=%.3f" % settle)

	# 깜빡임: 15초 동안 2회 이상, 완전히 감았다 다시 뜸
	var closed_max := 0.0
	var b0: int = v.blinks
	var reopened := false
	for f in 900:
		v._process(DT)
		var bv: Vector2 = v.blink_values()
		closed_max = maxf(closed_max, maxf(bv.x, bv.y))
		if closed_max > 0.95 and bv.x < 0.01 and bv.y < 0.01:
			reopened = true
	check("눈 깜빡임: 15초에 2회 이상, 완전히 감았다 뜸", v.blinks - b0 >= 2 and closed_max > 0.95 and reopened, "blinks=%d max=%.2f" % [v.blinks - b0, closed_max])

	# 공격: 앞다리를 들어 올리고 몸을 세웠다 내리찍음
	v.strike(holder.global_position + Vector3(0, 0, 2))
	var raise_max := 0.0
	var pitch_min := 0.0
	var pitch_max := 0.0
	var fang_max := 0.0
	for f in 36:
		v._process(DT)
		raise_max = maxf(raise_max, float(v.feet["L1"]["raise"]))
		pitch_min = minf(pitch_min, v.body.rotation.x)
		pitch_max = maxf(pitch_max, v.body.rotation.x)
		fang_max = maxf(fang_max, absf(v.fangs["FangL"].rotation.z))
	var front_up: float = (v.leg_tip_world(0)).y
	check("공격: 앞다리 들기·몸 세우기→내리찍기·송곳니 벌림", raise_max > 0.95 and pitch_min < -0.2 and pitch_max > 0.05 and fang_max > 0.2,
		"raise=%.2f pitch=%.2f..%.2f fang=%.2f" % [raise_max, pitch_min, pitch_max, fang_max])
	check("공격 종료 후 앞다리 복귀", float(v.feet["L1"]["raise"]) == 0.0 and v._strike_t < 0.0 and front_up < 0.05)

	# 피격 움찔
	v.hurt()
	var hurt_z := 0.0
	for f in 10:
		v._process(DT)
		hurt_z = minf(hurt_z, v.body.position.z - SpiderVisual.BODY_PIVOT.z)
	check("피격: 몸이 뒤로 움찔", hurt_z < -0.01, "dz=%.3f" % hurt_z)

	# 죽음: 뒤집히며 다리를 오므림
	var spread0 := 0.0
	for li in 8:
		spread0 += Vector2(v.leg_tip_world(li).x - v.global_position.x, v.leg_tip_world(li).z - v.global_position.z).length()
	v.die_curl()
	for f in int(SpiderVisual.DEATH_TIME / DT) + 4:
		v._process(DT)
	var spread1 := 0.0
	for li in 8:
		spread1 += Vector2(v.leg_tip_world(li).x - v.global_position.x, v.leg_tip_world(li).z - v.global_position.z).length()
	check("죽음: 몸이 뒤집히고(>150°) 다리가 오므라듦", v.body.rotation.z > 2.6 and spread1 < spread0 * 0.75 and v.blink_values().x > 0.99,
		"roll=%.2f spread %.2f→%.2f" % [v.body.rotation.z, spread0, spread1])
	holder.queue_free()

	# 달리다 멈칫: 평균 속도 배율 ≈ 1
	var m := MonsterScript.new()
	m.kind = "spider"
	var sum := 0.0
	var pauses := 0
	var was_go := true
	for f in 6000:
		var k: float = m._scuttle(DT)
		sum += k
		if was_go and k < 0.5:
			pauses += 1
		was_go = k >= 0.5
	var avg := sum / 6000.0
	check("달리다 멈칫: 평균 속도 배율 0.95~1.05, 100초에 멈칫 50회 이상", absf(avg - 1.0) < 0.05 and pauses >= 50, "avg=%.3f pauses=%d" % [avg, pauses])
	m.free()

	# 게임 데이터
	check("기본 적 종류 = 서리 거미", Cfg.ENEMY_KINDS.has("spider") and ChapterData.group_kind([0.0, 3]) == "spider" and Cfg.ENEMY_KINDS["spider"]["name"] == "서리 거미")

	# 실제 게임 장면: 1일차 밤 출현
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	for i in 12:
		await physics_frame
	main.session.set_process(false)
	main.economy.set_process(false)
	main.session.state = main.session.State.COMBAT
	main.waves.start_wave(1)
	main.waves.time = 100.0
	main.waves._spawn_due()
	for i in 3:
		await physics_frame
	var spiders: Array = []
	var bigs := 0
	for e in main.get_tree().get_nodes_in_group("wave_enemies"):
		if e.kind == "spider" and e.visual.get_script() == SpiderVisual:
			spiders.append(e)
		elif e.kind == "forest" and e.big and e.card_drop == "forest_monster":
			bigs += 1
	var n1: int = ChapterData.night_count(1)
	check("1일차 밤: 서리 거미 %d + 표식 큰 숲의 괴물 1" % (n1 - 1), spiders.size() == n1 - 1 and bigs == 1, "spider=%d big=%d" % [spiders.size(), bigs])
	# 실제 이동: 2초 뒤 거미가 움직이고 발걸음을 뗌
	var s0: Node3D = spiders[0]
	var p0: Vector3 = s0.global_position
	for i in 120:
		await physics_frame
	check("게임 안에서 거미가 경로를 따라 이동·보행", s0.global_position.distance_to(p0) > 0.8 and s0.visual.steps_taken > 10,
		"moved=%.2f steps=%d" % [s0.global_position.distance_to(p0), s0.visual.steps_taken])
	# 처치: 죽음 동작 후 사라짐
	s0.take_damage(99999.0)
	var dying_ok: bool = s0.dead and s0.visual.dying
	var t_end := Time.get_ticks_msec() + 3000
	while is_instance_valid(s0) and Time.get_ticks_msec() < t_end:
		await process_frame
	check("처치: 죽음 동작 실행 후 노드 제거", dying_ok and not is_instance_valid(s0))
	main.waves.stop()

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
