extends SceneTree
## 화염 VFX(scripts/visual/vfx/fire_vfx.gd) 실제 렌더 캡처. 헤드리스 더미 렌더러로는 셰이더 컴파일·가산/혼합 블렌딩·글로우·입자 모양을 볼 수 없어 창으로 찍는다.
## 레퍼런스(어두운 회청 배경 위 빨강/초록+자홍 연기/청록+보라 연기 세 불)와 같은 구도로 프리셋을 나란히 놓는다.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_fire_vfx.gd
## 결과: godot/screenshots/fire_vfx/*.png

const OUT := "res://screenshots/fire_vfx/"
const FireVfx := preload("res://scripts/visual/vfx/fire_vfx.gd")


func _initialize() -> void:
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(file: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(OUT + file + ".png")
	print("SHOT ", file)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1228, 663)
	var scene := Node3D.new()
	root.add_child(scene)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("3a4152")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("3a4256")
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = true
	e.glow_intensity = 0.8
	e.glow_strength = 1.1
	e.glow_bloom = 0.05
	e.glow_hdr_threshold = 0.9
	env.environment = e
	scene.add_child(env)
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(40, 40)
	ground.mesh = plane
	var gm := StandardMaterial3D.new()
	gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gm.albedo_color = Color("3a4152")
	ground.material_override = gm
	scene.add_child(ground)
	var cam := Camera3D.new()
	cam.fov = 42.0
	scene.add_child(cam)
	cam.look_at_from_position(Vector3(0, 5.2, 9.0), Vector3(0, 1.4, 0))

	var fires := []
	var keys := ["hearth", "toxic", "arcane"]
	for i in keys.size():
		var f := FireVfx.new()
		f.preset = keys[i]
		f.wind = Vector3(0.45, 0.0, -0.2)
		f.position = Vector3((i - 1) * 3.6, 0, 0)
		scene.add_child(f)
		fires.append(f)
	await _wait(150)
	await _shot("01-presets")
	# 크기·덩어리 조절: 왼쪽은 작게, 가운데 기본, 오른쪽 크게 + 덩어리 강하게
	fires[0].size = 0.6
	fires[2].size = 1.5
	fires[2].puffiness = 1.0
	await _wait(150)
	await _shot("02-size-puffiness")
	# 마녀 보랏불, 불티 끔, 세기 약함
	fires[0].size = 1.0
	fires[0].preset = "witch"
	fires[1].cinders_on = false
	fires[2].size = 1.0
	fires[2].puffiness = 0.7
	fires[2].intensity = 0.3
	await _wait(150)
	await _shot("03-witch-nocinders-low")
	quit(0)
