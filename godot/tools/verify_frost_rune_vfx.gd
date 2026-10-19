extends SceneTree
## 서리 룬 VFX(VisualShader 기반) 헤드리스 검증.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_frost_rune_vfx.gd
## 셰이더 그래프 구성·렌더 모드, 폭발 연출 노드 구성·시간표, 판정 유지(피해·감속·hits), 감속 서리 자국 켜짐/녹음, 자동 정리를 확인한다.

const Cfg := preload("res://scripts/config.gd")
const FrostRune := preload("res://scripts/actors/frost_rune.gd")
const DIR := "res://shaders/vfx/frost_rune/"

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


func _run() -> void:
	_check_shaders()
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	main = current_scene
	await _wait(20)
	main.session.start_wave()
	var target = null
	for i in 2400:
		await physics_frame
		for e in main.get_tree().get_nodes_in_group("enemies"):
			if not e.dead and e.is_inside_tree():
				target = e
				break
		if target != null:
			break
	check("밤 전투에서 적 등장", target != null)
	if target == null:
		_finish()
		return
	var hp_before: float = target.hp if target.get("hp") != null else -1.0
	var rune := FrostRune.new()
	rune.game = main
	rune.position = Vector3(target.global_position.x, 0, target.global_position.z)
	main.actors.add_child(rune)
	check("판정 유지: 반경 안 적 피해·hits", rune.hits >= 1 and (hp_before < 0 or target.dead or target.hp < hp_before), "hits=%d" % rune.hits)
	check("판정 유지: 감속 적용", target.dead or target.slow_factor() < 1.0)
	var vfx: Node3D = rune.get_node_or_null("FrostRuneVfx")
	check("연출 노드 생성", vfx != null)
	if vfx == null:
		_finish()
		return
	var shaded := 0
	for n in vfx.find_children("*", "MeshInstance3D", true, false):
		var m = n.material_override
		if m is ShaderMaterial and m.shader is VisualShader:
			shaded += 1
	check("모든 연출 메시가 VisualShader 재질", shaded >= 4 + 12, "meshes=%d" % shaded)
	var clusters: Array = vfx._clusters
	check("얼음 결정 무리(12 + 적 결빙)", clusters.size() >= 12 + mini(rune.hits, 8), "clusters=%d" % clusters.size())
	check("빛기둥·차가운 빛", vfx.get_node_or_null("FrostPillar") != null and vfx.find_children("*", "OmniLight3D", true, false).size() == 1)
	await create_timer(0.3).timeout
	var sig: ShaderMaterial = vfx._sigil.material_override
	var rime: ShaderMaterial = vfx._rime.material_override
	check("0.3초: 문양 다 그려짐·서리 다 번짐", sig.get_shader_parameter("reveal") > 0.99 and rime.get_shader_parameter("spread") > 0.95)
	var mark: MeshInstance3D = target._frost_mark if is_instance_valid(target) else null
	if is_instance_valid(target) and not target.dead:
		check("감속 서리 자국 표시", mark != null and mark.visible and mark.material_override.shader is VisualShader)
	await create_timer(1.6).timeout
	check("1.9초: 결정이 녹는 중", is_instance_valid(vfx) and vfx._clusters[0]["mat"].get_shader_parameter("melt") > 0.0)
	await create_timer(1.2).timeout
	check("3.1초: 연출·룬 노드 정리", not is_instance_valid(vfx) and not is_instance_valid(rune))
	if is_instance_valid(target) and not target.dead and mark != null:
		target._slows.clear()
		target._sync_frost_mark()
		await create_timer(0.6).timeout
		check("감속 해제 시 서리 자국이 녹아 숨김", not mark.visible)
	_finish()


func _check_shaders() -> void:
	var expect := {
		"frost_sigil": "blend_add", "frost_rime": "blend_mix", "frost_shock": "blend_add",
		"frost_pillar": "blend_add", "frost_crystal": "blend_mix"}
	for f in expect:
		var sh = load(DIR + f + ".tres")
		var ok: bool = sh is VisualShader
		var exprs := 0
		var code := ""
		if ok:
			code = sh.get_code()
			for id in sh.get_node_list(VisualShader.TYPE_FRAGMENT):
				if sh.get_node(VisualShader.TYPE_FRAGMENT, id) is VisualShaderNodeExpression:
					exprs += 1
		check("VisualShader %s" % f, ok and exprs >= 1 and expect[f] in code and "unshaded" in code, "expr=%d" % exprs)
	var crystal = load(DIR + "frost_crystal.tres")
	check("결정 셰이더 알파 시저(디졸브)", "ALPHA_SCISSOR_THRESHOLD" in crystal.get_code())


func _finish() -> void:
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
