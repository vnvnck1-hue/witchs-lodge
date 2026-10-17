extends SceneTree
## 서리 거미 실제 렌더 캡처(창 실행). 헤드리스 더미 렌더러로 확인할 수 없는 눈 셰이더 컴파일·눈꺼풀 모양·스키닝 결과·
## 실제 움직임만 확인한다. 걷기(달리다 멈칫) → 정지(더듬기·씹기·깜빡임) → 제자리 회전 → 공격 2회 → 피격 → 죽음.
## 실행(영상+정지 화면):
##   .tools/Godot-4.7.2.exe --path godot --resolution 1280x720 --fixed-fps 30 --write-movie screenshots/spider/spider_showcase.avi --script res://tools/capture_spider.gd
## 결과: screenshots/spider/*.png, spider_showcase.avi

const SpiderVisual := preload("res://scripts/visual/spider_visual.gd")
const OUT := "res://screenshots/spider/"
const END := 10.4

var holder: CharacterBody3D
var spider: Node3D
var cam: Camera3D
var t := 0.0
var shots := {1.05: "walk-a", 1.12: "walk-b", 1.19: "walk-c", 4.1: "idle", 6.62: "strike-rear", 6.78: "strike-hit", 9.9: "death"}
var done := {}
var events := {}


func _initialize() -> void:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.09, 0.09, 0.17)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.42, 0.42, 0.7)
	env.environment.ambient_light_energy = 0.7
	env.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment.glow_enabled = true
	root.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 35, 0)
	sun.light_energy = 0.9
	sun.light_color = Color(0.78, 0.8, 1.0)
	sun.shadow_enabled = true
	root.add_child(sun)
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(30, 30)
	ground.mesh = pm
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color(0.46, 0.47, 0.66)
	gm.roughness = 1.0
	ground.material_override = gm
	root.add_child(ground)
	holder = CharacterBody3D.new()
	root.add_child(holder)
	holder.position = Vector3(-2.6, 0, 0)
	spider = SpiderVisual.new()
	holder.add_child(spider)
	spider.rotation.y = PI * 0.5
	cam = Camera3D.new()
	cam.fov = 38.0
	root.add_child(cam)
	cam.transform = Transform3D(Basis(), Vector3(0.3, 2.6, 5.2)).looking_at(Vector3(0, 0.35, 0))


func _process(delta: float) -> bool:
	t += delta
	var vel := Vector3.ZERO
	if t < 3.0:
		# 달리다 멈칫(게임과 같은 리듬): 0.95초 달리고 0.25초 멈춘다
		var c := fmod(t, 1.2)
		vel = Vector3(1, 0, 0) * (2.05 if c < 0.95 else 0.14)
	elif t >= 5.4 and t < 6.2:
		spider.rotation.y = lerp_angle(spider.rotation.y, 0.25, delta * 4.0)   # 카메라 쪽으로 돌아선다
	holder.velocity = vel
	holder.global_position += vel * delta
	_once(3.5, func(): spider._tap_t = 0.0; spider._tap_leg = "R1")
	_once(6.4, func(): spider.strike(Vector3.ZERO))
	_once(7.0, func(): spider.strike(Vector3.ZERO))
	_once(7.7, func(): spider.hurt())
	_once(8.3, func(): _closeup())
	_once(9.3, func(): spider.die_curl())
	if t > 2.4 and t < 5.4:
		cam.position = cam.position.lerp(holder.global_position + Vector3(0.6, 1.5, 3.0), delta * 2.0)
		cam.look_at(holder.global_position + Vector3(0, 0.35, 0))
	for k in shots:
		if t >= k and not done.has(k):
			done[k] = true
			_save(shots[k])
	return t >= END


func _once(at: float, f: Callable) -> void:
	if t >= at and not events.has(at):
		events[at] = true
		f.call()


## 정면 근접: 눈 뜸 / 반쯤 / 감음 3장
func _closeup() -> void:
	spider.set_process(false)
	var face: Vector3 = spider.head_mesh.global_position
	var fwd: Vector3 = spider.global_basis.z.normalized()
	cam.global_position = holder.global_position + fwd * 1.7 + Vector3(0, 0.75, 0)
	cam.look_at(holder.global_position + Vector3(0, 0.38, 0) + fwd * 0.3)
	for b in [[0.0, "eyes-open"], [0.55, "eyes-half"], [1.0, "eyes-closed"]]:
		spider.set_blink(b[0], b[0])
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		_save(b[1])
	spider.set_process(true)
	cam.position = Vector3(holder.global_position.x + 0.5, 2.0, 3.6)
	cam.look_at(holder.global_position + Vector3(0, 0.3, 0))


func _save(n: String) -> void:
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + n + ".png"))
	print("SHOT ", n, " t=%.2f" % t)
