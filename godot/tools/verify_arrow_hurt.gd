extends SceneTree
## 화살 포물선·비행 시간·꼬리, 모든 적의 피격 반동 헤드리스 검증(2026-10-21).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_arrow_hurt.gd

const Cfg := preload("res://scripts/config.gd")
const ArrowScript := preload("res://scripts/actors/arrow.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const InsectScript := preload("res://scripts/actors/venom_insect.gd")
const DT := 1.0 / 60.0

var passed := 0
var total := 0


func check(ok: bool, label: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)


func _initialize() -> void: call_deferred("_run")


class Dummy extends Node3D:
	var dead := false
	var hp_offset := 1.5
	var taken := 0.0
	func take_damage(a: float) -> void:
		taken += a


func _run() -> void:
	# ── 화살: 7m 거리
	var world := Node3D.new()
	get_root().add_child(world)
	var foe := Dummy.new()
	world.add_child(foe)
	foe.global_position = Vector3(7, 0, 0)
	var arrow = ArrowScript.new()
	arrow.target = foe
	arrow.damage = 6.0
	world.add_child(arrow)
	arrow.global_position = Vector3(0, 1.0, 0)
	arrow.set_process(false)
	var peak := 0.0
	var steps := 0
	var head_forward := true
	while is_instance_valid(arrow) and steps < 200:
		arrow._process(DT)
		steps += 1
		if not is_instance_valid(arrow) or arrow.is_queued_for_deletion():
			break
		var u: float = clampf(arrow.t / arrow.flight, 0.0, 1.0)
		var line_y: float = lerpf(1.0, 0.675, u)
		peak = maxf(peak, arrow.global_position.y - line_y)
		# 화살촉(-Z 앞)이 날아가는 쪽(+X)을 본다
		if steps == 10 and (-arrow.global_basis.z).dot(Vector3.RIGHT) < 0.5: head_forward = false
		await process_frame
	var flight := steps * DT
	check(foe.taken == 6.0, "arrow: hits target (damage %.0f)" % foe.taken)
	check(flight > 0.7 and flight < 0.9, "arrow: 7m flight %.2fs (was %.2fs at 16m/s)" % [flight, 7.0 / Cfg.ARROW_SPEED])
	check(peak > 0.5 and peak < 1.1, "arrow: arcs %.2fm above the straight line" % peak)
	check(head_forward, "arrow: arrowhead points the way it flies")
	var ribbons := 0
	for c in world.get_children():
		if c.get_script() != null and str(c.get_script().resource_path).ends_with("ribbon_trail.gd"): ribbons += 1
	check(ribbons == 1, "arrow: tail trail ribbon spawned")

	# ── 적: 모든 종류가 피격 반응을 가진다
	for kind in Cfg.ENEMY_KINDS:
		var m = MonsterScript.new()
		m.configure(kind)
		world.add_child(m)
		m.set_physics_process(false)
		m.set_process(false)
		var native: bool = m.visual.has_method("hurt")
		m.hp = 9999.0
		m.take_damage(1.0)
		if native:
			check(true, "%s: visual has own hurt animation (%s)" % [kind, m.visual.get_script().resource_path.get_file()])
		else:
			var lean := 0.0
			var sq := 1.0
			for i in 4:
				m._animate(DT, false)
				lean = minf(lean, m.body.rotation.x)
				sq = minf(sq, m.body.scale.y)
			check(lean < -0.15 and sq < 0.95, "%s: recoils back %.2f rad and squashes %.2f" % [kind, lean, sq])
			for i in 40: m._animate(DT, false)
			check(m._hurt_t < 0.0 and absf(m.body.scale.y - 1.0) < 0.001, "%s: settles back after hurt" % kind)
		m.queue_free()

	# ── 영역 적: 맹독 곤충(지역 거주)
	var ins = InsectScript.new()
	ins.site = {"seed": 7}
	world.add_child(ins)
	ins.set_physics_process(false)
	ins.set_process(false)
	ins._hurt_t = 0.0
	var ilean := 0.0
	for i in 4:
		ins._animate(DT)
		ilean = minf(ilean, ins.body.rotation.x)
	check(ilean < -0.15 and ins.body.scale.y < 0.95, "venom insect: recoils %.2f rad on hit" % ilean)
	for i in 40: ins._animate(DT)
	check(ins._hurt_t < 0.0 and absf(ins.body.scale.y - 1.0) < 0.001, "venom insect: settles back")

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
