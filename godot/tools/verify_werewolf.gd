extends SceneTree
## 보름달 늑대인간(정식 모델·애니메이션·스킬 VFX) 헤드리스 검증.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_werewolf.gd
## 모양·색은 capture_werewolf_poses.gd / capture_werewolf_ingame.gd(창)로 따로 본다.

const WerewolfVisual := preload("res://scripts/visual/werewolf_visual.gd")
const WerewolfVfx := preload("res://scripts/visual/vfx/werewolf_vfx.gd")
const CharacterModels := preload("res://scripts/visual/character_models.gd")
const DT := 1.0 / 60.0

var passed := 0
var total := 0


func check(ok: bool, label: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)


func _initialize() -> void: call_deferred("_run")


func _run() -> void:
	# ── 모델
	check(CharacterModels.has_model("werewolf_witch"), "model: werewolf_witch scene registered")
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/werewolf_witch/report.json"))
	var groups: Dictionary = report.get("groups", {})
	for g in ["torso", "head", "arm_r", "fore_r", "arm_l", "fore_l", "leg_r", "leg_l", "tail"]:
		check(groups.has(g) and int(groups[g].triangles) > 40, "model: group %s has mesh" % g)
	var drop := 0
	for k in report.get("splits", {}):
		if str(k).ends_with("_drop"): drop += int(report.splits[k])
	check(drop > 10, "model: hip stub tail dropped (%d tris)" % drop)
	check(int(report.get("triangles", 0)) > 3500 and int(report.get("triangles", 0)) < 5000, "model: triangles %d in 3.5k~5k" % int(report.get("triangles", 0)))

	var holder := Node3D.new()
	holder.scale = Vector3.ONE * 1.3
	get_root().add_child(holder)
	var ww: Node3D = WerewolfVisual.new()
	holder.add_child(ww)
	ww.set_process(false)
	await process_frame
	check(ww.name == "WolfVisual" and ww.get_node_or_null("Body") != null and ww.head != null, "visual: Body/head pivot convention")
	for n in ["torso", "head", "arm_r", "arm_l", "fore_r", "fore_l", "leg_r", "leg_l", "tail", "mouth"]:
		check(ww.get(n) != null, "visual: joint %s found" % n)
	_settle(ww, 1.0)
	var box := _world_box(ww)
	check(box.size.y > 1.55 and box.size.y < 2.1, "visual: standing height %.2fm (witch 1.46m, target ~1.8m)" % box.size.y)
	# 꼬리: 엉덩이 뒤(몸통 피벗보다 뒤, 허리 높이)
	var tail_l: Vector3 = ww.tail.position
	check(tail_l.z < -0.08 and tail_l.y > -0.1 and tail_l.y < 0.15, "visual: tail attached behind hips %s" % tail_l)

	# ── 정지: 등 굽힘 + 헐떡임
	var lean_idle: float = ww.torso.rotation_degrees.x
	check(lean_idle > 10.0, "idle: hunched torso lean %.1f°" % lean_idle)
	var mn := 999.0
	var mx := -999.0
	for i in 30:
		ww._process(DT)
		mn = minf(mn, ww.torso.rotation_degrees.x)
		mx = maxf(mx, ww.torso.rotation_degrees.x)
	check(mx - mn > 1.5, "idle: panting chest heave %.1f°" % (mx - mn))

	# ── 달리기: 더 깊이 숙이고 다리가 엇갈린다
	ww.speed = 6.5
	var opp := false
	var lean_run := 0.0
	for i in 60:
		ww._process(DT)
		lean_run = maxf(lean_run, ww.torso.rotation_degrees.x)
		if ww.leg_r.rotation_degrees.x * ww.leg_l.rotation_degrees.x < -100.0: opp = true
	check(lean_run > lean_idle + 8.0, "run: deeper lean %.1f° > idle" % lean_run)
	check(opp, "run: legs swing opposite")
	ww.speed = 0.0
	_settle(ww, 0.8)

	# ── 물기 선딜 → 물기
	ww.set_windup(1.0)
	_settle(ww, 0.15)
	var head_wind: float = ww.head.rotation_degrees.x
	check(head_wind < -20.0, "bite: windup pulls head back %.1f°" % head_wind)
	ww.strike()
	var max_z := 0.0
	var max_lean := 0.0
	for i in 16:
		ww._process(DT)
		max_z = maxf(max_z, ww.body.position.z)
		max_lean = maxf(max_lean, ww.torso.rotation_degrees.x)
	check(max_z > 0.06 and max_lean > lean_idle + 15.0, "bite: lunges forward (z %.2f, lean %.1f°)" % [max_z, max_lean])
	_settle(ww, 0.6)

	# ── 할퀴기: 해당 팔을 크게 들었다 베어 내림
	for side in [1.0, -1.0]:
		ww.claw_swipe(side)
		var arm: Node3D = ww.arm_r if side > 0.0 else ww.arm_l
		var other: Node3D = ww.arm_l if side > 0.0 else ww.arm_r
		var lo := 0.0
		var yaw := 0.0
		for i in 9:
			ww._process(DT)
			lo = minf(lo, arm.rotation_degrees.x)
			yaw = maxf(yaw, absf(ww.torso.rotation_degrees.y))
		check(lo < -70.0 and other.rotation_degrees.x > -40.0, "claw %s: swinging arm raised %.0f°, other stays" % ["R" if side > 0 else "L", lo])
		check(yaw > 8.0, "claw %s: torso twists %.0f°" % ["R" if side > 0 else "L", yaw])
		_settle(ww, 0.4)

	# ── 덮치기: 몸이 떠서 수평으로, 착지에 눌림
	var peak := 0.0
	var flat := 0.0
	for i in 15:
		ww.set_pounce(i / 14.0)
		ww._process(DT)
		peak = maxf(peak, ww.body.position.y)
		flat = maxf(flat, ww.torso.rotation_degrees.x)
	check(peak > 0.2 and flat > 55.0, "pounce: airborne %.2f, body flat %.0f°" % [peak, flat])
	ww.set_pounce(-1.0)
	ww._process(DT)
	ww._process(DT)
	check(ww.body.scale.y < 0.99, "pounce: landing squash %.3f" % ww.body.scale.y)
	_settle(ww, 0.6)

	# ── 변신 울부짖음
	ww.roar()
	var howl := 0.0
	var spread := 0.0
	for i in 45:
		ww._process(DT)
		howl = minf(howl, ww.head.rotation_degrees.x)
		spread = maxf(spread, ww.arm_l.rotation_degrees.z)
	check(howl < -30.0 and spread > 40.0, "roar: head up %.0f°, arms spread %.0f°" % [howl, spread])
	_settle(ww, 1.0)

	# ── 타격 멈춤: 시간이 흐르지 않는다
	var t0: float = ww._t
	ww.impact(1.0)
	for i in 3: ww._process(DT)
	check(is_equal_approx(ww._t, t0), "impact: hit-stop freezes animation")
	for i in 10: ww._process(DT)
	check(ww._t > t0, "impact: resumes after hit-stop")

	# ── VFX VisualShader
	var want := {"ww_claw_rake": ["progress", "burn"], "ww_bite_snap": ["close", "flash"], "ww_ground_slam": ["wave", "crack", "cool"],
		"ww_moon_sigil": ["reveal"], "ww_rage_wisp": ["rise"]}
	for f in want:
		var sh = load("res://shaders/vfx/werewolf/%s.tres" % f)
		var names := []
		if sh is VisualShader:
			for u in (sh as VisualShader).get_shader_uniform_list(): names.append(u.name)
		var ok: bool = sh is VisualShader
		for p in want[f]: ok = ok and names.has(p)
		check(ok, "vfx: %s is VisualShader with %s" % [f, want[f]])

	# ── VFX 생성 · 스스로 사라짐
	var world := Node3D.new()
	get_root().add_child(world)
	var cam := Camera3D.new()
	world.add_child(cam)
	cam.look_at_from_position(Vector3(0, 8, 6), Vector3.ZERO)
	cam.current = true
	WerewolfVfx.claw_rake(world, Vector3.ZERO, Vector3.FORWARD, 1.0)
	WerewolfVfx.bite_snap(world, Vector3(0, 0.8, 1), Vector3.FORWARD)
	WerewolfVfx.slam(world, Vector3.ZERO, Vector3.FORWARD)
	WerewolfVfx.moon_burst(world, Vector3.ZERO)
	var body := Node3D.new()
	world.add_child(body)
	WerewolfVfx.rage_trail(world, body, 0.3)
	var kinds := {}
	for c in world.get_children():
		if str(c.name).begins_with("WerewolfVfx_"): kinds[str(c.name).get_slice("_", 1)] = true
	check(kinds.has("RAKE") and kinds.has("BITE") and kinds.has("SLAM") and kinds.has("MOON") and kinds.has("WISP"), "vfx: all effects spawn %s" % [kinds.keys()])
	var rake: Node3D = null
	for c in world.get_children():
		if str(c.name).begins_with("WerewolfVfx_RAKE"): rake = c
	await _frames(8)
	check(rake != null and is_instance_valid(rake) and float((rake._mat as ShaderMaterial).get_shader_parameter("progress")) > 0.3, "vfx: claw rake draws on")
	var t_end := Time.get_ticks_msec() + 2800
	while Time.get_ticks_msec() < t_end:
		await process_frame
	var left := 0
	for c in world.get_children():
		if str(c.name).begins_with("WerewolfVfx_"): left += 1
	check(left == 0, "vfx: all effects freed themselves (left %d)" % left)

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)


func _settle(ww: Node3D, sec: float) -> void:
	for i in int(sec / DT): ww._process(DT)


func _frames(n: int) -> void:
	for i in n: await process_frame


func _world_box(root: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var b: AABB = (mi as MeshInstance3D).global_transform * (mi as MeshInstance3D).mesh.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box
