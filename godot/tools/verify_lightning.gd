extends SceneTree
## 마녀 Q 번개 일격(Lightning Lance) 헤드리스 검증 — 연출 프리셋 3종(기본 번개·뇌창·흑뢰) 모두.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_lightning.gd
## 셰이더 그래프 구성·렌더 모드, 판정(줄기 위 적 관통 피해·감전 감속, 줄기 밖 적 무사, 프리셋별 피해 시점),
## 쿨다운·늑대 모습 차단, Q·Shift+Q 키 연결, 연출 노드 구성·시간표·자동 정리를 확인한다.
## 모양·색은 capture_lightning.gd(창)로 따로 본다.

const Cfg := preload("res://scripts/config.gd")
const LightningVfx := preload("res://scripts/visual/vfx/lightning_vfx.gd")
const DIR := "res://shaders/vfx/lightning/"
const K_BOLT := 0
const K_ORB := 1
const K_SCORCH := 2
const K_SPEAR := 3
const K_HELIX := 4
const K_STAR := 5
const K_RIFT := 6
const K_PILLAR := 7

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
		"lt_orb": ["pulse", "arcs", "fade", "seed"], "lt_scorch": ["wave", "spread", "cool", "fade", "seed"],
		"lt_spear": ["flare", "fade", "seed"], "lt_helix": ["head", "burn", "len", "seed"], "lt_star": ["burst", "fade", "seed"],
		"lt_rift": ["reach", "open", "fade", "len", "seed"], "lt_pillar": ["drop", "fade", "flash", "seed"]}
	var mix := ["lt_scorch", "lt_rift", "lt_pillar"]
	for f in want:
		var sh = load(DIR + f + ".tres")
		check("셰이더 %s 는 VisualShader" % f, sh is VisualShader)
		if not (sh is VisualShader):
			continue
		var code: String = sh.get_code()
		for p in want[f]:
			check("  %s 파라미터 %s" % [f, p], code.contains("uniform float " + p))
		check("  %s 렌더 모드" % f, code.contains("blend_mix" if f in mix else "blend_add") and code.contains("unshaded"))


func _vfx(p) -> Array:
	return p.get_parent().get_children().filter(func(n): return n.name.begins_with("LightningVfx_"))


func _kinds(p) -> Dictionary:
	var kinds := {}
	for n in _vfx(p):
		kinds[n.kind] = kinds.get(n.kind, 0) + 1
	return kinds


## 마녀 앞 줄 위에 둘(가까이·멀리), 줄 밖에 하나를 세우고 체력을 채운다.
func _place(p, foes: Array) -> Vector3:
	var o: Vector3 = p.global_position
	o.y = 0.0
	foes[0].global_position = o + Vector3(2.0, 0, 0.2)
	foes[1].global_position = o + Vector3(7.0, 0, -0.4)
	foes[2].global_position = o + Vector3(4.0, 0, 3.5)
	for e in foes:
		e.hp = 500.0
		e.set_physics_process(false)
		e.set_process(false)
	return o


func _run() -> void:
	_check_shaders()
	check("기본 프리셋 = Cfg.LIGHTNING_PRESET", Cfg.LIGHTNING_PRESET >= 0 and Cfg.LIGHTNING_PRESET < LightningVfx.PRESET_NAMES.size())
	check("피해 시점: 뇌창은 멀수록 늦게", LightningVfx.hit_delay(1, 1.0) > LightningVfx.hit_delay(1, 0.2) and LightningVfx.hit_delay(1, 1.0) <= 0.2)
	check("피해 시점: 흑뢰는 기둥이 꽂힌 뒤", LightningVfx.hit_delay(2, 0.0) >= LightningVfx.PILLAR_DROP and LightningVfx.hit_delay(2, 1.0) <= 0.25)
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
	p.attack_cd = 999.0
	for preset in [0, 1, 2]:
		await _preset_case(p, foes, preset)
	# 쿨다운·늑대·키
	var o: Vector3 = p.global_position
	p.lightning_cd = 0.0
	p.cast_lightning(o + Vector3(5.0, 0, 0))
	check("쿨다운 시작", absf(p.lightning_cd - Cfg.LIGHTNING_CD) < 0.01)
	check("쿨다운 중 재시전 불가", not p.cast_lightning(o + Vector3(5.0, 0, 0)))
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
	var pr0: int = p.lightning_preset
	var casts0: int = p.lightning_casts
	ev.shift_pressed = true
	main.controls.handle_input(ev)
	check("Shift+Q = 프리셋 바꾸기(시전 안 함)", p.lightning_preset == (pr0 + 1) % 3 and p.lightning_casts == casts0)
	ev.shift_pressed = false
	p.lightning_cd = 0.0
	main.controls.handle_input(ev)
	check("마녀 Q 키 = 번개 일격", p.lightning_casts == casts0 + 1)
	check("효과음 등록", FileAccess.file_exists("res://assets/audio/sfx-lightning_strike.wav"))
	_finish()


func _preset_case(p, foes: Array, preset: int) -> void:
	var tag := "[%s] " % LightningVfx.preset_name(preset)
	await create_timer(2.0).timeout   # 이전 연출 정리
	var o := _place(p, foes)
	await _wait(2)
	var hp0: Array = foes.map(func(e): return e.hp)
	var hits0: int = p.lightning_hits
	p.lightning_preset = preset
	p.lightning_cd = 0.0
	var ok: bool = p.cast_lightning(o + Vector3(5.0, 0, 0))
	check(tag + "시전 성공", ok)
	check(tag + "줄기 위 적 2마리 관통", p.lightning_hits - hits0 == 2, "hits=%d" % (p.lightning_hits - hits0))
	if preset == 0:
		check(tag + "가까운 적 즉시 피해", foes[0].hp < hp0[0])
	else:
		check(tag + "먼 적은 아직 맞지 않음(연출 시점에 맞춤)", foes[1].hp == hp0[1])
	await _wait(1)
	var k := _kinds(p)
	match preset:
		0:
			check(tag + "줄기 두 겹·구체 4·지면 자국", k.get(K_BOLT, 0) == 2 and k.get(K_ORB, 0) == 4 and k.get(K_SCORCH, 0) == 1, str(k))
		1:
			check(tag + "창머리·나선·별(시전 1+적 2+끝 1)·지면 자국", k.get(K_SPEAR, 0) == 1 and k.get(K_HELIX, 0) == 1 and k.get(K_STAR, 0) == 4 and k.get(K_SCORCH, 0) == 1, str(k))
			check(tag + "옛 줄기 없음", k.get(K_BOLT, 0) == 0)
		2:
			check(tag + "균열·기둥(5+적 2)·지면 자국", k.get(K_RIFT, 0) == 1 and k.get(K_PILLAR, 0) == 7 and k.get(K_SCORCH, 0) == 1, str(k))
	var shaded := 0
	var all := _vfx(p)
	for n in all:
		for m in n.find_children("*", "MeshInstance3D", true, false):
			if m.material_override is ShaderMaterial and m.material_override.shader is VisualShader:
				shaded += 1
	check(tag + "모든 연출 면이 VisualShader 재질", shaded == all.size(), "%d/%d" % [shaded, all.size()])
	if preset == 1:
		var spear = all.filter(func(n): return n.kind == K_SPEAR)[0]
		var x0: float = spear.global_position.x
		await create_timer(0.07).timeout
		check(tag + "창머리가 앞으로 날아감", is_instance_valid(spear) and spear.global_position.x > x0 + 2.0)
	if preset == 2:
		var pil = all.filter(func(n): return n.kind == K_PILLAR).filter(func(n): return n._delay > 0.08)
		check(tag + "기둥이 줄을 따라 차례로(지연 있음)", pil.size() >= 3 and pil.all(func(n): return not n.visible))
		var hb: Basis = pil[0]._mi.global_basis
		check(tag + "기둥 판이 위아래로 섬", absf(hb.z.normalized().y) > 0.3, str(hb.z))
	await create_timer(0.3).timeout
	check(tag + "0.3초 뒤 두 적 모두 피해", foes[0].hp < hp0[0] and foes[1].hp < hp0[1])
	check(tag + "줄기 밖 적 무사", foes[2].hp == hp0[2])
	check(tag + "감전 감속", foes[1].slow_factor() < 1.0)
	await create_timer(1.6).timeout
	check(tag + "연출 노드 모두 정리", _vfx(p).size() == 0, "left=%d" % _vfx(p).size())


func _finish() -> void:
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
