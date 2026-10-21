extends SceneTree
## 마녀 Q 번개 일격(Lightning Lance) 헤드리스 검증.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_lightning.gd
## 셰이더 그래프 구성·렌더 모드, 판정(줄기 위 적 관통 피해·감전 감속, 줄기 밖 적 무사), 쿨다운·늑대 모습 차단,
## Q 키 연결, 연출 노드 구성·시간표·자동 정리를 확인한다. 모양·색은 capture_lightning.gd(창)로 따로 본다.

const Cfg := preload("res://scripts/config.gd")
const DIR := "res://shaders/vfx/lightning/"

var main
var passed := 0
var total := 0


func check(label: String, ok: bool, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print("%s %s %s" % ["PASS" if ok else "FAIL", label, detail])


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _check_shaders() -> void:
	var want := {"lt_bolt": ["reach", "dissolve", "intensity", "thickness", "seed"],
		"lt_orb": ["pulse", "arcs", "fade", "seed"], "lt_scorch": ["wave", "spread", "cool", "fade", "seed"]}
	for f in want:
		var sh = load(DIR + f + ".tres")
		check("셰이더 %s 는 VisualShader" % f, sh is VisualShader)
		if not (sh is VisualShader):
			continue
		var code: String = sh.get_code()
		for p in want[f]:
			check("  %s 파라미터 %s" % [f, p], code.contains("uniform float " + p))
		check("  %s 렌더 모드" % f, code.contains("blend_add" if f != "lt_scorch" else "blend_mix") and code.contains("unshaded"))


func _run() -> void:
	_check_shaders()
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	main = current_scene
	await _wait(20)
	main.session.start_wave()
	var foes: Array = []
	for i in 2400:
		await physics_frame
		foes = main.get_tree().get_nodes_in_group("enemies").filter(func(e): return not e.dead and e.is_inside_tree() and e.get("hp") != null)
		if foes.size() >= 3:
			break
	check("밤 전투에서 적 3마리 이상 등장", foes.size() >= 3, "n=%d" % foes.size())
	if foes.size() < 3:
		_finish()
		return
	var p = main.player
	# 마녀 앞(+X) 줄 위에 둘, 줄 밖에 하나
	var o: Vector3 = p.global_position
	o.y = 0.0
	foes[0].global_position = o + Vector3(2.5, 0, 0.2)
	foes[1].global_position = o + Vector3(6.0, 0, -0.4)
	foes[2].global_position = o + Vector3(4.0, 0, 3.5)
	for e in foes:
		e.set_physics_process(false)
		e.set_process(false)
	await _wait(2)
	var hp0: Array = foes.map(func(e): return e.hp)
	p.lightning_cd = 0.0
	var ok: bool = p.cast_lightning(o + Vector3(5.0, 0, 0))
	check("시전 성공", ok and p.lightning_casts == 1)
	check("줄기 위 적 2마리 관통", p.lightning_hits == 2, "hits=%d" % p.lightning_hits)
	check("앞 적 피해", foes[0].dead or foes[0].hp < hp0[0])
	check("뒤 적 피해(관통)", foes[1].dead or foes[1].hp < hp0[1])
	check("줄기 밖 적 무사", foes[2].hp == hp0[2])
	check("감전 감속", foes[0].dead or foes[0].slow_factor() < 1.0)
	check("마녀가 시전 방향을 봄", absf(wrapf(p.visual.rotation.y - PI * 0.5, -PI, PI)) < 0.05)
	check("쿨다운 시작", absf(p.lightning_cd - Cfg.LIGHTNING_CD) < 0.01)
	check("쿨다운 중 재시전 불가", not p.cast_lightning(o + Vector3(5.0, 0, 0)) and p.lightning_casts == 1)
	# 연출 노드
	await _wait(1)
	var vfx: Array = p.get_parent().get_children().filter(func(n): return n.name.begins_with("LightningVfx_"))
	var kinds := {}
	for n in vfx:
		kinds[n.kind] = kinds.get(n.kind, 0) + 1
	check("줄기 두 겹", kinds.get(0, 0) == 2, str(kinds))
	check("구체: 지팡이·끝점·맞은 적 2", kinds.get(1, 0) == 4, str(kinds))
	check("지면 방전 자국", kinds.get(2, 0) == 1)
	var shaded := 0
	for n in vfx:
		for m in n.find_children("*", "MeshInstance3D", true, false):
			if m.material_override is ShaderMaterial and m.material_override.shader is VisualShader:
				shaded += 1
	check("모든 연출 면이 VisualShader 재질", shaded == vfx.size(), "%d/%d" % [shaded, vfx.size()])
	var bolt = vfx.filter(func(n): return n.kind == 0)[0]
	var bm: ShaderMaterial = bolt._mi.material_override
	var axis: Vector3 = bolt._mi.global_basis.x.normalized()
	check("줄기 판이 시전 방향으로 놓임", axis.dot(Vector3(1, 0, 0)) > 0.95, str(axis))
	check("줄기 길이 = 사거리 근처", absf((bolt._mi.mesh as PlaneMesh).size.x - Cfg.LIGHTNING_RANGE) < 1.5, str((bolt._mi.mesh as PlaneMesh).size.x))
	check("빛: 줄기·끝점", vfx.reduce(func(a, n): return a + n.find_children("*", "OmniLight3D", true, false).size(), 0) == 2)
	await create_timer(0.08).timeout
	check("0.08초: 줄기 끝까지 뻗음", bm.get_shader_parameter("reach") > 0.99)
	var s0 = bm.get_shader_parameter("seed")
	await create_timer(0.05).timeout
	check("지직거림: 모양 씨앗이 바뀜", bm.get_shader_parameter("seed") != s0)
	await create_timer(0.17).timeout
	check("0.3초: 꼬리부터 사라지는 중", is_instance_valid(bolt) and bm.get_shader_parameter("dissolve") > 0.3)
	await create_timer(1.6).timeout
	var left: int = p.get_parent().get_children().filter(func(n): return n.name.begins_with("LightningVfx_")).size()
	check("1.9초 뒤 연출 노드 모두 정리", left == 0, "left=%d" % left)
	# 늑대 모습에서는 Q 가 할퀴기로 간다
	p.lightning_cd = 0.0
	p.set_wolf(true)
	check("늑대 모습에서는 번개 불가", not p.cast_lightning(o + Vector3(5, 0, 0)))
	var ev := InputEventKey.new()
	ev.pressed = true
	ev.keycode = KEY_Q
	ev.physical_keycode = KEY_Q
	var claws0: int = p.claws_done
	main.controls.handle_input(ev)
	check("늑대 Q = 할퀴기 유지", p.claws_done == claws0 + 1)
	p.set_wolf(false)
	await _wait(2)
	p.lightning_cd = 0.0
	main.controls.handle_input(ev)
	check("마녀 Q 키 = 번개 일격", p.lightning_casts == 2)
	check("효과음 등록", main.sounds != null and main.sounds.has_method("play") and FileAccess.file_exists("res://assets/audio/sfx-lightning_strike.wav"))
	_finish()


func _finish() -> void:
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
