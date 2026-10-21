extends SceneTree
## 종족 공용 손님(인간·드워프)을 실제 플레이 카메라로 캡처(창 필요: 화면 속 크기·색·걷는 자세는 눈으로만 판단 가능).
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_race_common_guests.gd
## 결과: godot/screenshots/characters/race_common/ingame-lineup.png(마녀 옆에 인간·드워프·요정·고블린·수인·오크가 서 있는 모습),
##       ingame-walk-<n>.png(숲길을 함께 걸어오는 모습)

const TravelerScript := preload("res://scripts/actors/traveler.gd")
const AllyScript := preload("res://scripts/actors/ally.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")
const Layout := preload("res://scripts/world/layout.gd")
const OUT := "res://screenshots/characters/race_common/"
const IDS := ["bram", "harald", "thistle", "graz", "fargh", "garok"]

func _initialize() -> void: call_deferred("_run")

func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))

func spawn(game, id: String, pts: Array):
	var g := TravelerScript.new()
	g.profile = GuestProfiles.guest_profile(id)
	g.setup(pts, 0.0)
	g.position = pts[0]
	game.actors.add_child(g)
	return g

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var game = load("res://scenes/main.tscn").instantiate()
	get_root().add_child(game)
	for i in 30: await physics_frame
	game.session.set_process(false)
	game.economy.set_process(false)
	for c in game.actors.get_children():
		if "leaving" in c and "route" in c: c.queue_free()
	var base: Vector3 = Layout.DOOR_FRONT + Vector3(0.6, 0, 3.2)
	game.player.global_position = base
	game.player.moving = false
	game.world.player_camera.recenter()
	for i in 20: await process_frame

	# 1) 마녀 옆에 나란히 서서 카메라 쪽을 본다.
	var lineup: Array = []
	for k in IDS.size():
		var p: Vector3 = base + Vector3(0.9 + 0.75 * k, 0, 0.3)
		var g = spawn(game, IDS[k], [Layout.DOOR_FRONT])
		g.wait_at(p)   # 고용 대기처럼 문가에서 걸어 나와 그 자리에 선다(입실해 숨지 않게)
		lineup.append(g)
	Engine.time_scale = 4.0
	for i in 240: await process_frame
	Engine.time_scale = 1.0
	for i in 10: await process_frame
	await shot("ingame-lineup")
	for g in lineup: g.queue_free()
	for i in 4: await process_frame

	# 1-b) 고용된 용병(직업 소품 포함): 나무꾼 토르그림·사냥꾼 사야·전투 가로크·채집 페른.
	var mercs: Array = []
	var crew := [["토르그림", "lumberjack"], ["사야", "hunter"], ["가로크", "warrior"], ["페른", "gatherer"]]
	for k in crew.size():
		var a := AllyScript.new()
		var p: Vector3 = base + Vector3(1.0 + 0.9 * k, 0, 0.6)
		a.setup(game, "merc", crew[k][0], crew[k][1], p)
		a.position = p
		game.actors.add_child(a)
		mercs.append(a)
	for i in 30: await process_frame
	for a in mercs:
		a.set_physics_process(false)
		a.set_process(false)
		a.visual.rotation_degrees.y = 20.0
	for i in 5: await process_frame
	await shot("ingame-mercs")
	for a in mercs: a.queue_free()
	for i in 4: await process_frame

	# 2) 숲길에서 문까지 함께 걸어온다.
	var walkers: Array = []
	for k in IDS.size():
		var pts: Array = Layout.TRAVELER_ROUTE.duplicate()
		pts[pts.size() - 1] = Layout.DOOR_FRONT
		var g = spawn(game, IDS[k], pts)
		g.position += Vector3(0.7 * (k - 1), 0, 0)
		walkers.append(g)
	Engine.time_scale = 8.0
	while walkers[0].position.distance_to(Layout.DOOR_FRONT) > 5.0: await process_frame
	Engine.time_scale = 1.0
	for k in 3:
		for i in 6: await process_frame
		await shot("ingame-walk-%d" % k)
	print("CAPTURED ", ProjectSettings.globalize_path(OUT))
	quit()
