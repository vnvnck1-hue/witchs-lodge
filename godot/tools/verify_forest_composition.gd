extends SceneTree
## Structural placement and real traversal across the authored forest, source or packed.
const OUT := "C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/output/forest-composition/"
var failures: Array[String] = []
var walk_records: Array = []
var runtime_parts: Array = []
var packed := false

func _initialize() -> void:
	packed = "--pack" in OS.get_cmdline_user_args()
	create_timer(120.0,true,false,true).timeout.connect(func(): push_error("Forest traversal timed out"); quit(2))
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message); push_error(message)

func collect(node: Node) -> void:
	if node is Node3D and node.has_meta("forest_cluster") and node.has_meta("nature_id"):
		runtime_parts.append(node)
	for child in node.get_children(): collect(child)

func walk(game, at: Vector3, id: String) -> void:
	game.player.set_destination(at)
	var arrived := false
	for tick in 1500:
		await physics_frame
		if game.player.global_position.distance_to(at)<.70:
			arrived = true
			break
	walk_records.append({"site":id,"arrived":arrived,"position":str(game.player.global_position)})
	check(arrived,"Cannot walk to "+id)
	game.player.moving = false
	for tick in 3: await physics_frame

func _run() -> void:
	if packed:
		check(ProjectSettings.load_resource_pack("C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/build/WitchsLodge-forest-composition.pck",true),"Cannot mount composition pack")
	var Layout = load("res://scripts/world/layout.gd")
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/environment/forest_layout.json"))
	check(data.groups.size() == 40,"Missing authored forest groups")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.session.set_process(false)
	game.hud.visible = false
	for frame in 25: await physics_frame
	collect(game.world)
	# forest_composition.gd skips parts inside the hazard clearings; the 3 harvest trees are extra.
	var Hazards = load("res://scripts/world/hazard_sites.gd")
	var skipped := 0
	for group in data.groups:
		for part in group.parts:
			if Hazards.clearing_at(Vector2(part.position[0],part.position[1])): skipped += 1
	check(runtime_parts.size() == data.stats.parts-skipped+3,"Runtime forest placements differ from source: "+str(runtime_parts.size()))
	var assets: Dictionary = {}
	var minimum_height := 100.0
	var maximum_height := 0.0
	for group in data.groups:
		check(group.parts.size()>=4,"Thin isolated group "+group.id)
		var colliders := 0
		var kinds: Dictionary = {}
		for part in group.parts:
			kinds[part.kind] = true
			assets[part.asset] = true
			var at := Vector2(part.position[0],part.position[1])
			if part.kind in ["tree","rock"]:
				colliders += 1
				check(Layout.dist_to_trails(at)>=3.59+part.collider_radius,"Prop blocks a trail: "+group.id)
			if part.kind == "tree":
				minimum_height = minf(minimum_height,part.height)
				maximum_height = maxf(maximum_height,part.height)
		check(colliders>=2,"No substantial forest mass: "+group.id)
		check(kinds.size()>=2,"Group lacks a secondary layer: "+group.id)
	check(assets.size()>=15,"Missing prop diversity")
	check(maximum_height/minimum_height>2.8,"Tree scale hierarchy is too uniform")
	# 직업 분화(2026-10-15) 이후 모든 나무가 벌목 대상이라 래퍼 3그루 "이상"이다.
	check(game.world.harvest_trees.size()>=3,"Resource trees changed")
	# 산장 주변 A안(2026-10-18)에서 자원 나무 래퍼를 예약 영역 밖으로 옮겼다. 기준은 Layout.TREES.
	for pair in Layout.TREES:
		var found := false
		for tree in game.world.harvest_trees:
			if tree.pos.distance_to(Vector3(pair[0],0,pair[1]))<.01: found = true
		check(found,"Missing original harvest tree "+str(pair))
	var nav: RID = game.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(nav)
	# The region/bake updates must reach the server before the first path query.
	for frame in 15: await physics_frame
	for target in [Layout.SPAWN_A,Layout.SPAWN_B]:
		var path := NavigationServer3D.map_get_path(nav,target,Layout.DOOR_FRONT,true)
		check(path.size()>1 and path[-1].distance_to(Layout.DOOR_FRONT)<1.0,"Spawn route blocked")
	Engine.time_scale = 4.0
	for landmark in Layout.LANDMARKS:
		var at := Vector3(landmark.pos.x,0,landmark.pos.y)
		var path := NavigationServer3D.map_get_path(nav,Layout.DOOR_FRONT,at,true)
		check(path.size()>1 and path[-1].distance_to(at)<.75,"Landmark route blocked: "+landmark.id)
		await walk(game,at,landmark.id)
	await walk(game,Layout.DOOR_FRONT,"home")
	Engine.time_scale = 1.0
	var report := {"passed":failures.is_empty(),"failures":failures,"groups":data.groups.size(),
		"authored_parts":data.stats.parts,"runtime_cluster_parts":runtime_parts.size(),"asset_types":assets.keys(),
		"tree_height_range":[minimum_height,maximum_height],"walks":walk_records,"packed":packed}
	# OUT은 원 작성자 PC 경로다. 없으면 user://로 떨어뜨리고 계속 진행한다(파일 실패가 결과 출력까지 막지 않게).
	var file := FileAccess.open(OUT+("pack-" if packed else "")+"verification.json",FileAccess.WRITE)
	if file == null:
		file = FileAccess.open("user://forest-composition-verification.json",FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report,"\t"))
		file.close()
	print("FOREST_VERIFY groups=",data.groups.size()," walks=",walk_records.size()," failures=",failures)
	game.queue_free()
	for frame in 3: await process_frame
	quit(0 if failures.is_empty() else 1)
