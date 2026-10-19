extends SceneTree
## 고블린 니브 손님 실제 플레이 카메라 캡처(창 필요: 애니메이션 자세·타이밍은 눈으로만 판단 가능).
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_nib_guest.gd
## 결과: godot/screenshots/characters/goblin_nib/ingame-*.png (걷기 4장·인사 4장·손 흔들기 4장) + 근접 인사 장면

const TravelerScript := preload("res://scripts/actors/traveler.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")
const Layout := preload("res://scripts/world/layout.gd")
const OUT := "res://screenshots/characters/goblin_nib/"

func _initialize() -> void: call_deferred("_run")

func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var game = load("res://scenes/main.tscn").instantiate()
	get_root().add_child(game)
	for i in 30: await physics_frame
	game.session.set_process(false)
	game.economy.set_process(false)
	for c in game.actors.get_children():
		if "leaving" in c and "route" in c: c.queue_free()
	# 마녀를 문 앞 마당에 세워 실제 카메라가 문과 손님 길을 함께 담게 한다.
	game.player.global_position = Layout.DOOR_FRONT + Vector3(0.6, 0, 3.2)
	game.player.moving = false
	game.world.player_camera.recenter()
	for i in 20: await process_frame
	var g := TravelerScript.new()
	g.profile = GuestProfiles.guest_profile("nib")
	var pts: Array = Layout.TRAVELER_ROUTE.duplicate()
	pts[pts.size() - 1] = Layout.DOOR_FRONT
	g.setup(pts, 0.0)
	g.position = pts[0]
	game.actors.add_child(g)
	# 문까지 6m 남을 때까지 빨리 보낸 뒤 실제 속도로 찍는다.
	Engine.time_scale = 8.0
	while g.position.distance_to(Layout.DOOR_FRONT) > 6.0: await process_frame
	Engine.time_scale = 1.0
	for k in 4:
		for i in 5: await process_frame
		await shot("ingame-walk-%d" % k)
	while g.rig.state != "greet": await process_frame
	for k in 4:
		for i in 9: await process_frame
		await shot("ingame-greet-%d" % k)
	while g.visible: await process_frame
	var back: Array = Layout.TRAVELER_ROUTE.duplicate()
	back.reverse()
	g.leave(back, 0.0)
	for k in 4:
		for i in 6: await process_frame
		await shot("ingame-wave-%d" % k)
	print("CAPTURED ", ProjectSettings.globalize_path(OUT))
	quit()
