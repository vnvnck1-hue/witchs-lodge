extends SceneTree
## 화염 VFX(fire_vfx.gd) 헤드리스 검증.
##  1부 — 모듈: 세 겹(연기·불꽃·불티) 구성과 그리기 순서, 프리셋 색, size 비례(반경·속도·크기·불빛), 생성량, 불티 on/off, 세기·꺼짐,
##        바람이 입자를 다시 시작하지 않음.
##  2부 — 게임 연결: 앞마당 모닥불이 hearth 화염을 쓰고 예전 원기둥 불꽃이 없음, 연료 0 이면 꺼지고 다시 켜짐.
## 셰이더 컴파일·블렌딩·글로우는 더미 렌더러로 볼 수 없어 tools/capture_fire_vfx.gd 로 따로 캡처한다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_fire_vfx.gd

const FireVfx := preload("res://scripts/visual/vfx/fire_vfx.gd")

var failures := 0
var total := 0


func _initialize() -> void:
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _pm(p: GPUParticles3D) -> ParticleProcessMaterial:
	return p.process_material


func _mat(p: GPUParticles3D) -> ShaderMaterial:
	return (p.draw_pass_1 as QuadMesh).material


func _run() -> void:
	# ── 1부: 모듈 ──
	var f := FireVfx.new()
	root.add_child(f)
	await _wait(2)
	check("세 겹 입자와 불빛", f.smoke != null and f.flame != null and f.cinders != null and f.light != null)
	check("그리기 순서: 연기 < 불꽃 < 불티", _mat(f.smoke).render_priority < _mat(f.flame).render_priority and _mat(f.flame).render_priority < _mat(f.cinders).render_priority)
	check("셰이더 연결", _mat(f.flame).shader.resource_path.ends_with("fire_flame.gdshader") and _mat(f.smoke).shader.resource_path.ends_with("fire_smoke.gdshader")
		and _mat(f.cinders).shader.resource_path.ends_with("fire_cinder.gdshader"))
	check("입자 그림자 없음", f.flame.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF and f.smoke.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	check("입자별 무작위 값(anim_offset 0~1)", _pm(f.flame).anim_offset_max == 1.0 and _pm(f.smoke).anim_offset_max == 1.0)
	check("켜진 상태로 시작", f.flame.emitting and f.smoke.emitting and f.cinders.emitting and f.light.visible)

	for key in FireVfx.PRESETS:
		f.preset = key
		var p: Dictionary = FireVfx.PRESETS[key]
		var mid: Color = _mat(f.flame).get_shader_parameter("mid_color")
		var sm: Color = _mat(f.smoke).get_shader_parameter("smoke_color")
		check("프리셋 %s 색 반영" % key, mid.is_equal_approx(p.mid) and sm.is_equal_approx(p.smoke) and f.light.light_color.is_equal_approx(p.light))
	f.preset = "hearth"

	var r1 := _pm(f.flame).emission_sphere_radius
	var v1 := _pm(f.flame).initial_velocity_max
	var sc1 := _pm(f.smoke).scale_max
	var g1 := _pm(f.smoke).gravity
	var range1 := f.light.omni_range
	f.size = 2.0
	check("size 2 → 반경·속도·크기·중력·불빛 범위 2배",
		is_equal_approx(_pm(f.flame).emission_sphere_radius, r1 * 2.0) and is_equal_approx(_pm(f.flame).initial_velocity_max, v1 * 2.0)
		and is_equal_approx(_pm(f.smoke).scale_max, sc1 * 2.0) and _pm(f.smoke).gravity.is_equal_approx(g1 * 2.0) and is_equal_approx(f.light.omni_range, range1 * 2.0))
	f.size = 1.0

	var n1 := f.flame.amount
	f.spawn_amount = 2.0
	check("spawn_amount 2 → 불꽃 입자 2배", f.flame.amount == n1 * 2, "%d → %d" % [n1, f.flame.amount])
	f.spawn_amount = 1.0

	f.cinders_on = false
	check("cinders_on 끔 → 불티만 멈춤", not f.cinders.emitting and f.flame.emitting)
	f.cinders_on = true
	check("cinders_on 켬 → 불티 다시", f.cinders.emitting)

	f.puffiness = 0.2
	check("puffiness → 셰이더", is_equal_approx(_mat(f.smoke).get_shader_parameter("puffiness"), 0.2) and is_equal_approx(_mat(f.flame).get_shader_parameter("puffiness"), 0.2))
	f.puffiness = 0.7

	f.intensity = 0.3
	check("세기 0.3 → 생성 비율 낮아짐", f.flame.amount_ratio < 0.7 and f.smoke.amount_ratio < 0.7 and f.flame.emitting)
	f.intensity = 1.0
	check("세기 1 → 생성 비율 1", is_equal_approx(f.flame.amount_ratio, 1.0))

	f.lit = false
	check("꺼짐 → 입자·불빛 멈춤", not f.flame.emitting and not f.smoke.emitting and not f.cinders.emitting and not f.light.visible)
	f.lit = true
	check("다시 켬", f.flame.emitting and f.light.visible)

	f.with_light = false
	check("with_light 끔 → 모듈 불빛 숨김", not f.light.visible)

	var amount_before := f.smoke.amount
	f.wind = Vector3(1.5, 0, 0.5)
	check("바람 → 연기 중력에 반영", _pm(f.smoke).gravity.x > 1.0)
	check("바람 바꿔도 입자 수 그대로(재시작 없음)", f.smoke.amount == amount_before)
	f.queue_free()

	# ── 2부: 게임 연결 ──
	change_scene_to_file("res://scenes/main.tscn")
	while current_scene == null or current_scene.get("world") == null or current_scene.world.get("yard") == null:
		await process_frame
	await _wait(20)
	var yard = current_scene.world.yard
	check("모닥불에 화염 VFX", yard.fire_vfx != null and yard.fire_vfx.is_inside_tree() and yard.fire_vfx.get_parent() == yard.campfire)
	check("모닥불 화염 = hearth, 불빛은 마당 fire_light 가 맡음", yard.fire_vfx.preset == "hearth" and not yard.fire_vfx.with_light)
	var old_cyl := 0
	for c in yard.campfire.get_children():
		if c is MeshInstance3D and (c as MeshInstance3D).mesh is CylinderMesh and (c as MeshInstance3D).mesh.top_radius == 0.0:
			old_cyl += 1
	check("예전 원기둥 불꽃 제거", old_cyl == 0, "남은 원뿔 %d" % old_cyl)
	yard.fuel = 100.0
	await _wait(5)
	check("연료 있음 → 화염 켜짐", yard.fire_vfx.lit and yard.fire_vfx.flame.emitting)
	yard.fuel = 3.0
	await _wait(5)
	check("연료 적음 → 화염 약해짐", yard.fire_vfx.intensity < 0.5 and yard.fire_vfx.lit)
	yard.fuel = 0.0
	await _wait(5)
	check("연료 0 → 화염 꺼짐", not yard.fire_vfx.lit and not yard.fire_vfx.flame.emitting)
	yard.fuel = 60.0
	await _wait(5)
	check("다시 켜짐", yard.fire_vfx.lit and yard.fire_vfx.flame.emitting)

	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
