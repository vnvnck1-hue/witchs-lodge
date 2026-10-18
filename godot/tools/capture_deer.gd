extends SceneTree
## 새 사슴 모델 실제 렌더 캡처(창 실행). 헤드리스 더미 렌더러로 확인할 수 없는 스키닝 변형(목·무릎 이음새)·
## 고개 펴기 결과·페인트 재질만 본다. 정지 3방향 → 걷기 → 달아나기 → 풀 뜯기 → 경계.
## 실행:
##   .tools/Godot-4.7.2.exe --path godot --resolution 1280x720 --fixed-fps 30 --script res://tools/capture_deer.gd
## 결과: screenshots/deer/*.png

const DeerVisual := preload("res://scripts/visual/deer_visual.gd")
const OUT := "res://screenshots/deer/"

var deer
var cam: Camera3D
var t := 0.0
var shots := {0.3: "rest-side", 0.5: "rest-front", 0.7: "rest-top", 2.0: "walk", 2.2: "walk-b", 3.6: "run", 3.75: "run-b", 6.0: "graze", 6.4: "graze-close", 7.6: "graze-up", 9.0: "alert"}
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
	sun.shadow_enabled = true
	root.add_child(sun)
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(40, 40)
	ground.mesh = pm
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color(0.42, 0.52, 0.38)
	ground.material_override = gm
	root.add_child(ground)
	deer = DeerVisual.new()
	root.add_child(deer)
	deer.rotation.y = PI * 0.5   # +X 로 걷는다
	cam = Camera3D.new()
	cam.fov = 40.0
	root.add_child(cam)
	_view(Vector3(0, 0.9, 4.2), Vector3(0, 0.8, 0))


func _view(from: Vector3, at: Vector3) -> void:
	cam.look_at_from_position(from, at)


func _process(delta: float) -> bool:
	t += delta
	var v := 0.0
	if t > 0.4 and t < 0.45:
		_view(Vector3(4.2, 0.9, 0.01), Vector3(0, 0.8, 0))
	if t > 0.6 and t < 0.65:
		_view(Vector3(0.01, 4.5, 0), Vector3(0, 0, 0))
	if t > 0.8 and t < 0.85:
		_view(Vector3(0, 1.4, 6.5), Vector3(0, 0.7, 0))
	if t >= 0.9 and t < 2.6:
		v = 0.9
	elif t >= 2.6 and t < 4.2:
		v = 2.6
		deer.alarmed = true
	if t >= 4.2 and not done.has("graze_setup"):
		done["graze_setup"] = true
		deer._graze_up = false
		deer._graze_t = 3.0
	if t > 6.2 and t < 6.25:
		_view(deer.position + Vector3(0.3, 0.7, 2.6), deer.position + Vector3(0.3, 0.55, 0))
	if t > 6.6 and t < 6.65:
		_view(Vector3(0, 1.4, 6.5), Vector3(0, 0.7, 0))
	if t >= 4.2:
		deer.alarmed = t >= 8.0
		deer.grazing = t < 8.0
	deer.speed = v
	deer.position.x += v * delta
	if deer.position.x > 3.5:
		deer.position.x = -3.5
	for k in shots:
		if t >= k and not done.has(k):
			done[k] = true
			root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + shots[k] + ".png"))
			print("SHOT ", shots[k], " t=%.2f" % t)
	return t >= 9.2
