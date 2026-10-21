extends SceneTree
## 늑대인간 애니메이션 자세 시트(창 필요: 자세·실루엣·타이밍은 눈으로만 판단 가능).
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_werewolf_poses.gd
## 결과: godot/screenshots/characters/werewolf_witch/poses-front.png, poses-side.png (각 4×3 칸)
## 애니메이터의 _process 를 고정 간격(1/60초)으로 직접 돌려 같은 순간을 매번 같게 찍는다.

const WerewolfVisual := preload("res://scripts/visual/werewolf_visual.gd")
const OUT := "res://screenshots/characters/werewolf_witch/"
const CELL := 420
const DT := 1.0 / 60.0

var ww: Node3D
var cam: Camera3D


func _initialize() -> void: call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	get_root().size = Vector2i(CELL, CELL)
	var stage := Node3D.new()
	get_root().add_child(stage)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.2, 0.21, 0.27)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.72, 0.72, 0.8)
	stage.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -35, 0)
	stage.add_child(sun)
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(8, 8)
	ground.mesh = pm
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color(0.86, 0.88, 0.95)
	ground.material_override = gm
	stage.add_child(ground)
	cam = Camera3D.new()
	cam.fov = 38
	stage.add_child(cam)
	var holder := Node3D.new()
	holder.scale = Vector3.ONE * 1.3     # 플레이어 visual 배율
	stage.add_child(holder)
	ww = WerewolfVisual.new()
	holder.add_child(ww)
	ww.set_process(false)
	await process_frame
	# [제목, 준비 함수(사건), 돌릴 시간(초)]
	var shots := [
		["idle 1", func(): ww.speed = 0.0, 1.0],
		["idle 2 (pant)", func(): ww.speed = 0.0, 0.09],
		["run A", func(): ww.speed = 6.5, 0.6],
		["run B", func(): ww.speed = 6.5, 0.2],
		["bite windup", func(): ww.speed = 0.0; ww.set_windup(1.0), 0.15],
		["bite lunge", func(): ww.strike(), 0.09],
		["claw R raise", func(): ww.claw_swipe(1.0), 0.035],
		["claw R cut", func(): ww.claw_swipe(1.0), 0.085],
		["claw L cut", func(): ww.claw_swipe(-1.0), 0.085],
		["pounce crouch", func(): ww.set_pounce(0.1), 0.05],
		["pounce fly", func(): ww.set_pounce(0.45), 0.08],
		["roar howl", func(): ww.roar(), 0.55],
	]
	for view in ["front", "side"]:
		var sheet := Image.create(CELL * 4, CELL * 3, false, Image.FORMAT_RGBA8)
		_reset()
		for i in shots.size():
			var s: Array = shots[i]
			# 앞 칸 동작이 남지 않게 매 칸 정지 자세에서 시작한다(물기 선딜 → 물기만 이어 찍음)
			if s[0] != "bite lunge":
				_reset()
			(s[1] as Callable).call()
			if s[0] == "pounce fly":
				# 덮치기는 진행값을 시간에 따라 넣는다
				for k in 6:
					ww.set_pounce(0.3 + k * 0.03)
					ww._process(DT)
			for f in int(float(s[2]) / DT):
				ww._process(DT)
			if view == "front":
				cam.look_at_from_position(Vector3(1.5, 1.9, 3.3), Vector3(0, 0.95, 0))
			else:
				cam.look_at_from_position(Vector3(3.6, 1.5, 0.2), Vector3(0, 0.95, 0))
			for k in 3: await process_frame
			await RenderingServer.frame_post_draw
			var img := get_root().get_texture().get_image()
			img.convert(Image.FORMAT_RGBA8)
			sheet.blit_rect(img, Rect2i(0, 0, CELL, CELL), Vector2i((i % 4) * CELL, (i / 4) * CELL))
			print("shot ", view, " ", s[0])
		sheet.save_png(ProjectSettings.globalize_path(OUT + "poses-%s.png" % view))
	print("SAVED ", ProjectSettings.globalize_path(OUT))
	quit()


func _reset() -> void:
	ww.speed = 0.0
	ww.set_windup(0.0)
	ww.set_pounce(-1.0)
	ww._land = 0.0
	ww._roar = 0.0
	ww._strike = 0.0
	ww._claw = 0.0
	ww._claw_combo = 0.0
	ww._t = 0.0
	for f in 60: ww._process(DT)
