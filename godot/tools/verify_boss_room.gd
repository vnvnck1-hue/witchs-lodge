extends SceneTree
## 니벨라 보스룸 헤드리스 검증: 지형·프랍·임시 보스 배치, 입구 통행, 진입 시 카메라 시야 열기·발견·포효 순서, 분위기 섞기와 복귀.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_boss_room.gd
const Sites := preload("res://scripts/world/hazard_sites.gd")
const SpiderVisual := preload("res://scripts/visual/spider_visual.gd")
const Layout := preload("res://scripts/world/layout.gd")

var passed := 0
var total := 0
var game


func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	call_deferred("_run")


func check(ok: bool, label: String) -> void:
	total += 1
	if ok:
		passed += 1
		print("PASS ", label)
	else:
		print("FAIL ", label)


func frames(n: int) -> void:
	for i in n:
		await physics_frame
	await process_frame


func seconds(s: float) -> void:
	var end := Time.get_ticks_msec() + int(s * 1000.0)
	while Time.get_ticks_msec() < end:
		await process_frame


func _run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(10)
	var room = game.world.boss_room
	var site: Dictionary = Sites.BOSS_ROOM
	check(room != null and room.is_inside_tree(), "보스룸 노드가 월드에 있다")
	var c := Vector3(site.center.x, 0, site.center.y)
	check(room.global_position.distance_to(c) < 0.01, "보스룸이 BOSS_ROOM 중심에 놓인다")
	check(site.radii.x >= 21.0 and site.radii.y >= 16.2, "둥지 크기 %.0f×%.0fm = 처음 14×10.8m의 지름 3배" % [site.radii.x * 2, site.radii.y * 2])
	var deep: Vector3 = room.global_position + Vector3(-2.0, 0, -9.0)
	check(Vector2(deep.x, deep.z).distance_to(Layout.MAP_CENTER) > Layout.BOUNDARY_RADIUS, "둥지 안쪽은 원래 맵 경계 밖(별관)")
	check(Layout.clamp_to_map(deep).distance_to(deep) < 0.01, "둥지 별관 안은 이동 제한에 걸리지 않는다")
	var beyond: Vector3 = room.global_position + Vector3(0, 0, -19.5)
	check(Layout.in_boss_nest(Vector2(Layout.clamp_to_map(beyond).x, Layout.clamp_to_map(beyond).z), 1.0), "둥지 뒤로 벗어난 점은 둥지 안으로 당긴다")
	for other in Sites.SITES:
		check(Sites.normalized_distance(site.center, other) > 1.9, "독 서식지 %s 와 겹치지 않는다" % other.id)
	for lm in Layout.LANDMARKS:
		check(Sites.normalized_distance(lm.pos, site) > 1.3, "랜드마크 %s 와 떨어져 있다" % lm.id)
	# 숲 장식 나무가 방 안에 남지 않았다
	var trees_inside := 0
	for t in game.world.camera_occluders:
		var p: Vector3 = t.pos if t.has("pos") else Vector3.INF
		if p != Vector3.INF and Sites.normalized_distance(Vector2(p.x, p.z), site) < 1.0:
			trees_inside += 1
	check(trees_inside == 0, "방 안에 숲 나무가 없다 (%d)" % trees_inside)
	# 프랍 구성
	var names := {}
	for n in room.find_children("*", "", true, false):
		names[str(n.name)] = true
	check(room.find_child("IceFloor", true, false) != null, "얼음 바닥판")
	check(room.find_children("FrostMist*", "", true, false).size() >= 4, "바닥 안개 4겹")
	check(room.find_child("FrostMotes", true, false) != null, "서리 입자")
	check(room.crystal_lights.size() >= 4, "수정 불빛")
	var meshes: Array = room.find_child("Props", true, false).find_children("*", "MeshInstance3D", true, false)
	check(meshes.size() >= 5 and meshes.size() <= 40, "프랍은 재질별로 합쳐졌다 (%d 메시)" % meshes.size())
	var colliders: Array = game.world.nav_region.find_children("*", "StaticBody3D", true, false).filter(func(b): return b.has_meta("boss_room"))
	check(colliders.size() >= 30, "외곽·기둥 충돌 (%d)" % colliders.size())
	# 임시 보스
	var boss = room.boss
	check(boss is SpiderVisual, "보스 자리에 서리 거미 시각 모델")
	check(absf(boss.global_transform.basis.get_scale().x - SpiderVisual.MODEL_SCALE * room.BOSS_SCALE) < 0.01, "보스는 기본 거미의 %.1f배" % room.BOSS_SCALE)
	check(boss.global_position.distance_to(Layout.clamp_to_map(boss.global_position, 0.0)) < 0.01, "보스가 맵 경계 안에 있다")
	check(room.boss_body != null and room.boss_body.is_inside_tree(), "보스 몸 충돌")
	# 입구 통행: 서쪽 탐험길에서 방 안까지 내비 경로가 이어진다
	var nav_map: RID = game.world.get_world_3d().navigation_map
	for i in 200:
		NavigationServer3D.map_force_update(nav_map)
		if NavigationServer3D.map_get_iteration_id(nav_map) > 0 and NavigationServer3D.map_get_closest_point(nav_map, Vector3(0, 0, -25)).distance_to(Vector3(0, 0, -25)) < 1.0:
			break
		await physics_frame
	var inner: Vector3 = room.global_position + Vector3(2.0, 0, 1.0)
	var path: PackedVector3Array = NavigationServer3D.map_get_path(nav_map, Vector3(0, 0, -25), inner, true)
	check(path.size() > 1 and path[path.size() - 1].distance_to(inner) < 0.8, "길에서 입구로 방 안까지 걸어 들어갈 수 있다")
	var deep_path: PackedVector3Array = NavigationServer3D.map_get_path(nav_map, Vector3(0, 0, -25), deep, true)
	check(deep_path.size() > 1 and deep_path[deep_path.size() - 1].distance_to(deep) < 0.8, "둥지 가장 안쪽(보스 뒤)까지 걸어갈 수 있다")
	var outside_wall: Vector3 = room.global_position + Vector3(-24.5, 0, -4.0)
	var wall_path: PackedVector3Array = NavigationServer3D.map_get_path(nav_map, inner, outside_wall, true)
	check(wall_path.size() == 0 or wall_path[wall_path.size() - 1].distance_to(outside_wall) > 1.5, "둥지 외곽 벽 밖으로는 나갈 수 없다")
	var closest: Vector3 = NavigationServer3D.map_get_closest_point(nav_map, room.boss.global_position)
	check(closest.distance_to(room.boss.global_position) > room.BOSS_RADIUS - 0.4, "보스 몸 자리는 걸을 수 없다")
	# 연출: 플레이어를 직접 옮겨 확인한다(이동 판정 대신)
	game.session.set_process(false)
	game.player.set_physics_process(false)
	var cam = game.world.player_camera
	var base_h: float = cam.desired_height
	game.player.global_position = Vector3(0, 0, -25.0)
	cam.recenter()
	await frames(20)
	check(not room.inside and room.phase == room.Phase.DORMANT, "밖에서는 잠잠하다")
	check(cam.framing_extra < 0.01, "밖에서는 카메라 기본 높이")
	var yaw0: float = boss.rotation.y
	game.player.global_position = room.global_position + Vector3(3.0, 0, 9.0)
	await frames(3)
	check(room.inside and room.enters == 1, "입구 안으로 들어서면 진입")
	check(room.phase == room.Phase.NOTICE, "보스가 발견 단계로")
	await seconds(1.0)
	check(cam.framing_extra > 2.0 and cam.framing_weight > 0.1, "카메라가 물러나며 보스 쪽으로 시야를 연다 (+%.1f)" % cam.framing_extra)
	check(absf(wrapf(boss.rotation.y - yaw0, -PI, PI)) > 0.3, "보스가 몸을 돌린다")
	await seconds(0.7)
	check(room.phase == room.Phase.ROAR and boss.is_roaring() and room.roars == 1, "포효 시작")
	await seconds(0.6)
	check(boss.feet["L1"]["raise"] > 0.8 and boss.body.rotation.x < -0.35, "앞몸을 치켜들고 앞다리를 든다 (pitch %.2f)" % boss.body.rotation.x)
	check(game.world._shake_t > 0.0 or room._flash > 0.0, "포효 순간 화면 흔들림·섬광")
	check(game.banner.history.size() > 0 and game.banner.history[-1].head == "니벨라", "보스 이름 배너")
	var bz = room.last_blizzard
	check(bz != null and is_instance_valid(bz) and bz.ground_mat.shader is VisualShader and bz.wall_mat.shader is VisualShader, "포효 눈보라 VisualShader 2종(바닥 폭발·눈보라 벽)")
	check(bz != null and is_instance_valid(bz) and bz.progress > 0.3 and bz.wall.scale.x > 4.0, "눈보라가 보스 둘레로 퍼져 나간다 (진행 %.2f)" % (bz.progress if is_instance_valid(bz) else -1.0))
	var first_wave = bz
	await seconds(0.9)
	bz = room.last_blizzard
	check(room.blizzards == 3 and bz != first_wave, "첫 포효는 눈보라 세 번 연속 (%d)" % room.blizzards)
	check(bz != null and is_instance_valid(bz) and bz.radius >= 40.0 and bz.intensity < 1.0, "첫 포효 눈보라는 화면 끝까지(반경 %.0fm), 세기는 1 미만" % (bz.radius if is_instance_valid(bz) else 0.0))
	var to_p: Vector3 = game.player.global_position - boss.global_position
	await seconds(2.0)
	check(room.phase == room.Phase.WATCH and not boss.is_roaring(), "포효가 끝나고 노려본다")
	check(not is_instance_valid(bz), "눈보라는 잠깐 뒤 걷혀 사라진다")
	check(absf(wrapf(boss.rotation.y - atan2(to_p.x, to_p.z), -PI, PI)) < 0.35, "보스가 마녀를 향한다")
	check(absf(cam.height - room.FRAME_HEIGHT) < 0.5, "둥지 안에서는 둥지 전체가 보이는 시야 유지 (높이 %.1f)" % cam.height)
	check(cam.desired_height == base_h, "사용자 줌 값은 그대로")
	check(room.influence > 0.95, "분위기 최대")
	var amount: float = game.world.post_mat.get_shader_parameter("boss_amount")
	check(amount > 0.8, "화면 냉색 보정 (%.2f)" % amount)
	check(game.world.env.ambient_light_color.b > game.world.env.ambient_light_color.r, "환경광이 차가운 남청")
	check(boss.feet["L1"]["raise"] < 0.05, "포효 뒤 앞다리 내려놓음")
	# 다시 나가면 원래대로
	game.player.global_position = Vector3(0, 0, -23.0)
	await seconds(2.4)
	check(not room.inside and cam.framing_extra < 0.2, "나가면 카메라가 돌아온다")
	check(room.influence < 0.25, "나가면 분위기가 걷힌다 (%.2f)" % room.influence)
	# 곧바로 다시 들어오면 재포효하지 않는다(쿨다운)
	game.player.global_position = room.global_position + Vector3(3.0, 0, 9.0)
	await frames(5)
	check(room.enters == 2 and room.phase != room.Phase.NOTICE, "쿨다운 안 재진입은 포효 없이 노려보기")
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
