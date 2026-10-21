extends SceneTree
## 직업별 용병 동작(도구를 손에 쥠·반복 동작·공격 임팩트 이징·타격 멈춤·판정 시점) 헤드리스 검증.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_job_anims.gd
## 모양은 capture_job_poses.gd(창)로 따로 본다. 게임 흐름 전체는 verify_jobs.gd.

const CharacterModels := preload("res://scripts/visual/character_models.gd")
const RigAnim := preload("res://scripts/visual/rig_anim.gd")
const AllyScript := preload("res://scripts/actors/ally.gd")
const DT := 1.0 / 60.0

var passed := 0
var total := 0


func check(ok: bool, label: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)


func _initialize() -> void: call_deferred("_run")


## 직업 하나를 모델·rig·도구까지 꾸린다(게임 없이). 반환 {root, rig, ally}
func _make(job: String, model_id: String) -> Dictionary:
	var made := CharacterModels.make(model_id)
	get_root().add_child(made.root)
	var rig: Node = made.anim
	rig.set_process(false)
	var ally = AllyScript.new()
	ally.job = job
	ally.kind = "minion"          # on_hit 의 게임 연동을 건너뛴다
	ally.rig = rig
	ally.body = made.body
	ally.visual = made.root
	var ok: bool = ally._add_held_props(made.body.get_child(0))
	return {"root": made.root, "rig": rig, "ally": ally, "ok": ok}


func _step(rig: Node, sec: float) -> void:
	for i in int(round(sec / DT)): rig._process(DT)


func _arm_group(n: Node) -> String:
	while n != null:
		if n.has_meta("part_group"): return str(n.get_meta("part_group"))
		n = n.get_parent()
	return ""


func _run() -> void:
	# ── 도구가 손(팔 묶음)에 붙는다
	var want := {"lumberjack": ["axe", "arm_r"], "hunter": ["bow", "arm_l"], "warrior": ["sword", "arm_r"], "gatherer": ["basket", "torso"]}
	var models := {"lumberjack": "dwarf_common", "hunter": "beastfolk_common", "warrior": "human_common", "gatherer": "goblin_common"}
	var made := {}
	for job in want:
		made[job] = _make(job, models[job])
		var rig: Node = made[job].rig
		var prop = rig.props.get(want[job][0])
		check(made[job].ok and prop != null and _arm_group(prop) == want[job][1], "%s: %s held by %s" % [job, want[job][0], want[job][1]])
	check(made["warrior"].rig.props.has("shield") and _arm_group(made["warrior"].rig.props["shield"]) == "arm_l", "warrior: shield on left arm")
	check(made["hunter"].rig.props.has("bow_string") and made["hunter"].rig.props.has("arrow"), "hunter: bow string and arrow")

	# ── 도구 세계 크기 유지(모델 배율 되돌림): 도끼 자루 약 0.66m
	var axe: Node3D = made["lumberjack"].rig.props["axe"]
	check(absf(axe.global_transform.basis.get_scale().x - 1.0) < 0.05, "lumberjack: axe keeps world size (scale %.2f)" % axe.global_transform.basis.get_scale().x)

	# ── 나무꾼 도끼질: 머리 위로 천천히 → 임팩트 직전 순식간에 내리찍음
	var lr: Node = made["lumberjack"].rig
	var arm_r: Node3D = lr.pivots["arm_r"]
	lr.play("chop")
	var samples := {}
	for u in [0.0, 0.25, 0.5, 0.52, 0.55, RigAnim.CHOP_IMPACT, 0.7]:
		lr.amount = u
		lr._process(DT)
		samples[u] = arm_r.rotation_degrees.x
	check(samples[0.5] < -165.0, "chop: axe raised overhead %.0f°" % samples[0.5])
	var slow: float = absf(samples[0.25] - samples[0.0]) / 0.25
	var fast: float = absf(samples[0.55] - samples[0.5]) / 0.05
	check(fast > slow * 4.0, "chop: downswing snap %.0f°/u vs raise %.0f°/u (sharp easing)" % [fast, slow])
	check(absf(samples[RigAnim.CHOP_IMPACT] - (-72.0)) < 8.0, "chop: axe lands forward at impact %.0f°" % samples[RigAnim.CHOP_IMPACT])
	check(lr.pivots["torso"].rotation_degrees.x > 20.0, "chop: body leans into the blow")

	# ── 전투용병 베기: ease-in 감아올림 → 0.06초 만에 내리벰(넘침) → 멈춤
	var wr: Node = made["warrior"].rig
	var warm: Node3D = wr.pivots["arm_r"]
	wr.play("idle")
	_step(wr, 0.3)
	var impact: float = wr.action("slash")
	check(absf(impact - 0.30) < 0.001, "slash: impact at %.2fs" % impact)
	var a0 := warm.rotation_degrees.x
	_step(wr, 0.08)
	var early := warm.rotation_degrees.x
	_step(wr, 0.15)                  # 0.23s: 감아올림 끝 직전
	var top := warm.rotation_degrees.x
	_step(wr, 0.0667)                # 0.30s: 임팩트
	var hit := warm.rotation_degrees.x
	check(top < -150.0, "slash: sword wound up high %.0f°" % top)
	check(absf(early - a0) < 25.0, "slash: wind-up starts slow (%.0f° in first 0.08s)" % absf(early - a0))
	check(hit - top > 100.0, "slash: %.0f° swing within 0.06s at impact" % (hit - top))
	check(hit > -45.0, "slash: reaches the strike pose at impact (%.0f°)" % hit)
	# 타격 멈춤: 자세가 얼어 있다
	wr.freeze(0.085)
	var held := warm.rotation_degrees
	_step(wr, 0.05)
	check(warm.rotation_degrees.is_equal_approx(held), "slash: hit-stop freezes pose")
	_step(wr, 0.8)
	check(not wr.busy() and absf(warm.rotation_degrees.x) < 15.0, "slash: recovers to idle")

	# ── 사냥꾼: 시위를 당겼다(시위 뒤로) 놓으면 앞으로 튕김, 화살은 당기는 동안만
	var hr: Node = made["hunter"].rig
	var string: Node3D = hr.props["bow_string"]
	var arrow: Node3D = hr.props["arrow"]
	hr.play("idle")
	_step(hr, 0.3)
	var rest_z := string.position.z
	var t_rel: float = hr.action("draw")
	_step(hr, 0.33)
	check(string.position.z < rest_z - 0.12 and arrow.visible, "draw: string pulled back %.2f, arrow nocked" % (rest_z - string.position.z))
	check(hr.pivots["arm_l"].rotation_degrees.x < -70.0, "draw: bow arm raised forward")
	_step(hr, t_rel - 0.33 + 0.02)
	check(string.position.z > rest_z - 0.06 and not arrow.visible, "draw: release snaps string, arrow gone")
	var bow: Node3D = hr.props["bow"]
	check(absf(bow.global_transform.basis.y.normalized().dot(Vector3.UP)) > 0.85, "draw: bow stands upright while aiming")

	# ── 채집가 줍기: 쪼그려 앉아 손을 뻗고 → 등 바구니로
	var gr: Node = made["gatherer"].rig
	gr.play("pick")
	gr.amount = 0.16
	gr._process(DT)
	var low: float = gr.pivots["torso"].position.y - gr._rest["torso"].y
	var reach: float = gr.pivots["arm_r"].rotation_degrees.x
	gr.amount = 0.36
	gr._process(DT)
	var toss: float = gr.pivots["arm_r"].rotation_degrees.x
	check(low < -0.05 and reach < -30.0, "pick: crouch %.2f and reach %.0f°" % [low, reach])
	check(toss < -120.0, "pick: tosses into back basket %.0f°" % toss)

	# ── 감시탑 경계·대피·움찔
	_step(hr, 0.6)                   # 활 쏘기 동작이 끝난 뒤
	hr.play("lookout")
	_step(hr, 0.2)
	check(hr.pivots["arm_r"].rotation_degrees.x < -120.0, "lookout: hand shading eyes")
	gr.play("flee")
	_step(gr, 0.2)
	check(gr.pivots["arm_r"].rotation_degrees.x < -100.0, "flee: arms flailing overhead")
	wr.play("idle")
	_step(wr, 0.2)
	var t0: float = wr.pivots["torso"].rotation_degrees.x
	wr.flinch()
	wr._process(DT)
	check(wr.pivots["torso"].rotation_degrees.x < t0 - 5.0, "flinch: recoils when hit")

	# ── 판정 시점: 베기 피해는 임팩트 순간에, 화살은 놓는 순간에
	var foe := _Dummy.new()
	get_root().add_child(foe)
	var w = made["warrior"].ally
	w.state = AllyScript.State.DEAD    # 게임 없이: 상태 처리·이동을 멈춰 둔다
	get_root().add_child(w)
	w.set_physics_process(false)
	w.rig = wr
	w.global_position = Vector3.ZERO
	foe.global_position = Vector3(0, 0, 1.0)
	w._pending = {"kind": "slash", "target": foe, "dmg": 10.0, "t": wr.action("slash")}
	w._tick_pending(0.2)
	check(foe.taken == 0.0, "timing: no damage during wind-up")
	w._tick_pending(0.11)
	check(foe.taken == 10.0, "timing: damage lands at impact")
	check(wr._freeze > 0.0, "timing: impact triggers hit-stop")

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)


class _Dummy extends Node3D:
	var dead := false
	var taken := 0.0
	func take_damage(a: float) -> void:
		taken += a
