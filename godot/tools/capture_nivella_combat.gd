extends SceneTree
## 니벨라 전투 실제 화면 캡처(창 실행): 보스 체력바 등장 차오름·지연 게이지·금·단 파괴·실드·빈사 박동, 공격 패턴 4종 예고·적중.
## 헤드리스 더미 렌더러로는 UI 그리기·장판 셰이더·VFX 외형을 볼 수 없어 짧게 찍는다. 결과: godot/screenshots/nivella_combat/
## 실행: .tools/Godot-4.7.2.exe --path godot --resolution 1600x900 --script res://tools/capture_nivella_combat.gd
const OUT := "res://screenshots/nivella_combat/"

var game


func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): quit(2))
	call_deferred("_run")


func _wait(sec: float) -> void:
	var end := Time.get_ticks_msec() + int(sec * 1000.0)
	while Time.get_ticks_msec() < end:
		await process_frame


func _shot(n: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + n + ".png"))
	print("SHOT ", n)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await _wait(1.5)
	game.session.set_process(false)
	var p = game.player
	p.set_physics_process(false)
	p.max_hp = 5000.0
	p.hp = 5000.0
	if game.world.fog_of_war != null:
		game.world.fog_of_war.set_enabled(false)
	game.world.day_cycle.set_mode("night")
	var room = game.world.boss_room
	var boss = room.combat
	var bar = room.hp_bar
	p.global_position = room.global_position + Vector3(3.0, 0, 9.0)
	# 등장: 포효 정점(약 2.1초) 직후부터 차오름
	await _wait(2.35)
	await _shot("01-intro-appear")
	await _wait(0.5)
	await _shot("02-intro-filling")
	await _wait(1.2)
	await _shot("03-intro-full")
	await _wait(1.5)
	boss.auto_patterns = false
	# 피격: 잔상·흔들림·누적 대미지·선단 파편
	boss.take_damage(18.0)
	await _wait(0.05)
	boss.take_damage(30.0)
	await _wait(0.06)
	await _shot("04-hit-ghost")
	await _wait(1.6)
	for i in 4:
		boss.take_damage(40.0)
	await _wait(1.2)
	await _shot("05-cracks")
	# 단 파괴
	while boss.stock_left() == 3:
		boss.take_damage(40.0)
	await _wait(0.12)
	await _shot("06-stock-shatter")
	await _wait(1.5)
	await _shot("07-stock-orange")
	while boss.stock_left() == 2:
		boss.take_damage(60.0)
	await _wait(1.2)
	await _shot("08-shield")
	boss.take_damage(150.0)
	await _wait(0.1)
	await _shot("09-shield-break")
	boss.hp = boss.max_hp * 0.18
	await _wait(1.5)
	await _shot("10-low-hp-pulse")
	await _wait(1.5)
	# 공격 패턴
	var dir: Vector3 = p.global_position - boss.global_position
	dir.y = 0
	dir = dir.normalized()
	p.global_position = boss.global_position + dir * (boss.hit_radius + 3.0)
	boss._stomp(p)
	await _wait(0.6)
	await _shot("11-stomp-telegraph")
	await _wait(0.5)
	await _shot("12-stomp-impact")
	await _wait(1.5)
	p.global_position = boss.global_position + dir * (boss.hit_radius + 8.0)
	boss._spikes(p)
	await _wait(0.55)
	await _shot("13-spikes-telegraph")
	await _wait(0.6)
	await _shot("14-spikes-erupt")
	await _wait(1.8)
	boss._web(p)
	await _wait(0.55)
	await _shot("15-web-flight")
	await _wait(0.75)
	await _shot("16-web-land")
	await _wait(2.0)
	p.global_position = boss.global_position + dir * (boss.hit_radius + 5.0)
	boss._nova()
	await _wait(1.2)
	await _shot("17-nova-telegraph")
	await _wait(0.75)
	await _shot("18-nova-impact")
	await _wait(1.5)
	while not boss.dead:
		boss.take_damage(150.0)
	await _wait(0.15)
	await _shot("19-defeat")
	quit()
