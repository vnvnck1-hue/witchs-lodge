extends SceneTree
## 직업별 용병 동작 자세 시트(창 필요: 손에 쥔 도구 위치·임팩트 자세는 눈으로만 판단 가능).
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_job_poses.gd
## 결과: godot/screenshots/jobs/job-poses.png — 줄: 나무꾼·사냥꾼·전투용병·채집가 / 칸: 동작 단계
## 애니메이터를 고정 간격(1/60초)으로 직접 돌려 같은 순간을 찍는다. 도구는 ally.gd 의 _add_held_props 를 그대로 쓴다.

const CharacterModels := preload("res://scripts/visual/character_models.gd")
const AllyScript := preload("res://scripts/actors/ally.gd")
const OUT := "res://screenshots/jobs/"
const CELL := 300
const DT := 1.0 / 60.0

## [직업, 모델, [[칸 제목, 상태, amount 또는 공격 동작, 동작 시작 뒤 초]...]]
const ROWS := [
	["lumberjack", "dwarf_common", [["idle", "idle", 0.0, 0.0], ["raise", "chop", 0.3, 0.0], ["top", "chop", 0.5, 0.0],
		["IMPACT", "chop", 0.645, 0.0], ["stuck", "chop", 0.72, 0.0], ["walk", "walk", 0.0, 0.0]]],
	["hunter", "beastfolk_common", [["idle", "idle", 0.0, 0.0], ["draw", "idle", "draw", 0.16], ["full draw", "idle", "draw", 0.33],
		["RELEASE", "idle", "draw", 0.4], ["lookout", "lookout", 0.0, 0.0], ["walk", "walk", 0.0, 0.0]]],
	["warrior", "human_common", [["idle", "idle", 0.0, 0.0], ["wind", "idle", "slash", 0.14], ["full wind", "idle", "slash", 0.24],
		["IMPACT", "idle", "slash", 0.3], ["hold", "idle", "slash", 0.38], ["flee", "flee", 0.0, 0.0]]],
	["gatherer", "goblin_common", [["idle", "idle", 0.0, 0.0], ["crouch", "pick", 0.06, 0.0], ["reach", "pick", 0.16, 0.0],
		["toss to basket", "pick", 0.36, 0.0], ["walk", "walk", 0.0, 0.0], ["flee", "flee", 0.0, 0.0]]],
]

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
	env.environment.background_color = Color(0.22, 0.23, 0.29)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.72, 0.72, 0.8)
	stage.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -35, 0)
	stage.add_child(sun)
	cam = Camera3D.new()
	cam.fov = 40
	stage.add_child(cam)
	cam.look_at_from_position(Vector3(1.6, 1.5, 2.6), Vector3(0, 0.7, 0))
	var cols := 6
	var sheet := Image.create(CELL * cols, CELL * ROWS.size(), false, Image.FORMAT_RGBA8)
	for r in ROWS.size():
		var row: Array = ROWS[r]
		var made := CharacterModels.make(row[1])
		var root: Node3D = made.root
		stage.add_child(root)
		var rig: Node = made.anim
		rig.set_process(false)
		var ally = AllyScript.new()
		ally.job = row[0]
		ally.rig = rig
		ally.body = made.body
		ally._add_held_props(made.body.get_child(0))
		for c in row[2].size():
			var shot: Array = row[2][c]
			rig._action = ""
			rig._freeze = 0.0
			rig.play("idle")
			for f in 30: rig._process(DT)
			rig.play(shot[1])
			if shot[2] is String:
				rig.action(shot[2])
				for f in int(float(shot[3]) / DT): rig._process(DT)
			else:
				for f in 20:
					rig.amount = float(shot[2])
					rig._process(DT)
			for k in 3: await process_frame
			await RenderingServer.frame_post_draw
			var img := get_root().get_texture().get_image()
			img.convert(Image.FORMAT_RGBA8)
			sheet.blit_rect(img, Rect2i(0, 0, CELL, CELL), Vector2i(c * CELL, r * CELL))
			print("shot ", row[0], " ", shot[0])
		root.queue_free()
		ally.free()
		await process_frame
	sheet.save_png(ProjectSettings.globalize_path(OUT + "job-poses.png"))
	print("SAVED ", ProjectSettings.globalize_path(OUT + "job-poses.png"))
	quit()
