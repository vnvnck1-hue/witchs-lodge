extends SceneTree
## 새 양 모델 실제 렌더 캡처(창 실행). 헤드리스 더미 렌더러로 확인할 수 없는 스키닝 변형(목 이음새)·페인트 재질·검은 양 색만 본다.
## 흰 양: 걷기 → 달아나기 → 풀 뜯기(고개 숙임) → 털깎기, 옆에 검은 양(풀 뜯기)과 새끼양(두리번).
## 실행:
##   .tools/Godot-4.7.2.exe --path godot --resolution 1280x720 --fixed-fps 30 --script res://tools/capture_sheep.gd
## 결과: screenshots/sheep/*.png

const SheepVisual := preload("res://scripts/visual/sheep_visual.gd")
const OUT := "res://screenshots/sheep/"

var white
var black
var lamb
var cam: Camera3D
var t := 0.0
var shots := {1.2: "walk", 1.35: "walk-b", 3.0: "run", 3.12: "run-b", 5.6: "graze", 7.4: "shear", 8.4: "closeup-graze", 9.0: "closeup-side"}
var done := {}


func _initialize() -> void:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.32, 0.36, 0.5)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.6, 0.6, 0.8)
	env.environment.ambient_light_energy = 0.7
	env.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	root.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 35, 0)
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	root.add_child(sun)
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(30, 30)
	ground.mesh = pm
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color(0.42, 0.52, 0.38)
	gm.roughness = 1.0
	ground.material_override = gm
	root.add_child(ground)
	white = SheepVisual.new()
	root.add_child(white)
	white.position = Vector3(-1.2, 0, 0)
	white.rotation.y = PI * 0.5
	black = SheepVisual.new()
	root.add_child(black)
	black.set_black()
	black.position = Vector3(0.6, 0, -1.3)
	black.rotation.y = -0.6
	black.grazing = true
	lamb = SheepVisual.new()
	root.add_child(lamb)
	lamb.scale = Vector3.ONE * 0.62
	lamb.position = Vector3(1.4, 0, -0.4)
	lamb.rotation.y = -1.9
	cam = Camera3D.new()
	cam.fov = 40.0
	root.add_child(cam)
	cam.look_at_from_position(Vector3(0.0, 1.6, 3.4), Vector3(0, 0.35, -0.3))


func _process(delta: float) -> bool:
	t += delta
	var v := 0.0
	if t < 2.0:
		v = 0.45
		white.alarmed = false
	elif t < 3.6:
		v = 1.1
		white.alarmed = true
	else:
		white.alarmed = false
	if t >= 3.6 and t < 6.6:
		white.grazing = true
	if t >= 6.6 and t < 7.8:
		white.grazing = false
		white.held = true
		white.shearing = true
	if t >= 7.8:
		white.held = false
		white.shearing = false
		white.grazing = true
	white.speed = v
	if v > 0.0:
		white.position.x += v * delta
		if white.position.x > 1.6:
			white.position.x = -1.6
	if t >= 8.0 and not done.has("cam1"):
		done["cam1"] = true
		cam.position = white.position + Vector3(0.9, 0.7, 1.4)
		cam.look_at(white.position + Vector3(0.2, 0.4, 0))
	if t >= 8.7 and not done.has("cam2"):
		done["cam2"] = true
		cam.position = white.position + Vector3(0.0, 0.5, 1.7)
		cam.look_at(white.position + Vector3(0, 0.38, 0))
	for k in shots:
		if t >= k and not done.has(k):
			done[k] = true
			root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + shots[k] + ".png"))
			print("SHOT ", shots[k], " t=%.2f" % t)
	return t >= 9.2
