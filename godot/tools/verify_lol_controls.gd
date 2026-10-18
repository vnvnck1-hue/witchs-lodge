extends SceneTree
## 롤식 전투 조작 헤드리스 검증(사용자 요청 2026-10-18, docs/lol-controls-v01.md).
## 실제 main.tscn 에 서리 거미를 세워 두고(움직이지 않게 고정) 실제 입력 이벤트(root.push_input)로 확인한다:
## 우클릭 이동·대상 평타, 이동 명령의 대상 해제, 선딜 취소(무빙 평타), A 공격 이동·커서 근처 적 우선, S 정지, Space 카메라 복귀,
## C·A 사거리 표시, 서 있을 때 자동 대상·이동 중 무발사, 마우스오버/대상 붉은 외곽선, 땅 좌클릭 무이동, 방향키 전용 이동 바인딩.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_lol_controls.gd

const Cfg := preload("res://scripts/config.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const Outline := preload("res://scripts/visual/enemy_outline.gd")
const NavUtil := preload("res://scripts/world/nav_util.gd")

var game
var pl
var ctl
var passed := 0
var total := 0


func check(label: String, ok: bool, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print("%s %s%s" % ["PASS" if ok else "FAIL", label, "" if detail == "" else " — " + detail])


func _initialize() -> void:
	create_timer(240.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); print("RESULT %d/%d" % [passed, total + 1]); quit(1))
	_run.call_deferred()


func frames(n: int) -> void:
	for i in n:
		await physics_frame


func wait_until(cond: Callable, seconds: float) -> bool:
	var end := Time.get_ticks_msec() + int(seconds * 1000.0 / maxf(Engine.time_scale, 0.01))
	while not cond.call():
		if Time.get_ticks_msec() > end:
			return false
		await physics_frame
	return true


func screen_of(p: Vector3) -> Vector2:
	return game.world.camera.unproject_position(p)


func move_mouse(at: Vector2) -> void:
	var m := InputEventMouseMotion.new()
	m.position = at
	m.global_position = at
	root.push_input(m, true)
	await process_frame
	await process_frame


func click(at: Vector2, button: int) -> void:
	await move_mouse(at)
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = button
		e.pressed = pressed
		e.position = at
		e.global_position = at
		root.push_input(e, true)
	await process_frame


func key(code: int) -> void:
	for pressed in [true, false]:
		var e := InputEventKey.new()
		e.keycode = code
		e.physical_keycode = code
		e.pressed = pressed
		root.push_input(e, true)
	await process_frame


func ground_near(p: Vector3) -> Vector3:
	return NavUtil.ground_or_near(game.get_world_3d().navigation_map, p)


## 움직이지 않는(물리 처리 끈) 서리 거미. 체력이 매우 커서 기본으로는 죽지 않는다.
func spawn_dummy(p: Vector3, hp := 1.0e6):
	var m := MonsterScript.new()
	m.setup(game, hp, false)
	m.configure("spider")
	m.position = ground_near(p)
	game.actors.add_child(m)
	m.set_physics_process(false)
	return m


func clear_enemies() -> void:
	for e in get_nodes_in_group("enemies"):
		e.remove_from_group("enemies")
		e.queue_free()
	for b in game.actors.get_children():
		if b.get_script() == preload("res://scripts/actors/magic_bolt.gd"):
			b.queue_free()
	await frames(2)


## 마녀를 x 로 옮기고 정지시킨다.
func reset_player(p: Vector3) -> void:
	pl.command_stop()
	pl.global_position = ground_near(p)
	pl.attack_cd = 0.0
	game.world.player_camera.recenter()
	await frames(3)


func overlay_is(e, state: int) -> bool:
	var ms: Array = Outline.meshes(e)
	if ms.is_empty():
		return false
	var want = null if state == Outline.NONE else Outline.material(state)
	return ms.all(func(mi): return mi.material_overlay == want)


func _run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(10)
	pl = game.player
	ctl = game.controls
	var rng: float = pl.attack_range()
	check("롤 조작 노드가 붙어 있다", ctl != null and ctl.get_script().resource_path.ends_with("lol_controls.gd"))
	check("낮(준비) 상태에서 시작", game.session.state == 0)
	for e in get_nodes_in_group("enemies"):
		e.queue_free()
	await frames(2)

	# ── 키 바인딩: WASD 이동 제거, 방향키 이동 유지
	var has_key := func(action: String, code: int) -> bool:
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey and (ev.physical_keycode == code or ev.keycode == code):
				return true
		return false
	check("A·S·W·D 는 이동 키가 아니다(롤 A·S 와 충돌 제거)", not has_key.call("walk_left", KEY_A) and not has_key.call("walk_down", KEY_S) and not has_key.call("walk_up", KEY_W) and not has_key.call("walk_right", KEY_D))
	check("방향키 이동은 유지된다", has_key.call("walk_left", KEY_LEFT) and has_key.call("walk_down", KEY_DOWN) and has_key.call("walk_up", KEY_UP) and has_key.call("walk_right", KEY_RIGHT))

	Engine.time_scale = 2.0
	var home: Vector3 = ground_near(pl.global_position)
	await reset_player(home)

	# ── 땅 좌클릭으로는 움직이지 않는다 / 땅 우클릭은 이동
	var side := Vector3(3.0, 0, 0)
	var p0: Vector3 = pl.global_position
	await click(screen_of(ground_near(p0 + side)), MOUSE_BUTTON_LEFT)
	await frames(20)
	check("땅 좌클릭: 이동하지 않는다(롤)", pl.global_position.distance_to(p0) < 0.05 and not pl.moving)
	await click(screen_of(ground_near(p0 + side)), MOUSE_BUTTON_RIGHT)
	var moved := await wait_until(func(): return pl.global_position.distance_to(p0) > 0.8, 3.0)
	check("땅 우클릭: 그 지점으로 이동한다", moved)
	await reset_player(home)

	# ── 마우스오버: 공격 커서 + 붉은 외곽선
	var far_e = spawn_dummy(home + Vector3(rng + 4.0, 0, 0))
	await frames(4)
	var ep: Vector2 = screen_of(far_e.global_position + Vector3(0, 0.4, 0))
	await move_mouse(ep)
	await frames(2)
	check("적 위에 커서: 그 적이 hovered", ctl.hovered == far_e, "hovered=%s gui=%s" % [str(ctl.hovered), str(root.gui_get_hovered_control())])
	check("마우스오버한 적에 밝은 붉은 외곽선", overlay_is(far_e, Outline.HOVER))
	check("마우스오버 시 공격 커서로 바뀐다", ctl.cursor_mode == "attack")
	var hm: ShaderMaterial = Outline.material(Outline.HOVER)
	var tm: ShaderMaterial = Outline.material(Outline.TARGET)
	var hc: Color = hm.get_shader_parameter("line_color")
	var tc: Color = tm.get_shader_parameter("line_color")
	check("외곽선 색은 붉은색, 대상은 더 진하고 두껍다", hc.r > 0.8 and hc.g < 0.35 and tc.r > 0.5 and tc.g < 0.1 and tc.v < hc.v and float(tm.get_shader_parameter("width_px")) > float(hm.get_shader_parameter("width_px")))
	check("외곽선 셰이더는 target_outline.gdshader", hm.shader.resource_path.ends_with("target_outline.gdshader"))
	await move_mouse(screen_of(home + Vector3(-3.0, 0, 2.0)))
	await frames(2)
	check("커서가 떠나면 외곽선·커서 원복", ctl.hovered == null and overlay_is(far_e, Outline.NONE) and ctl.cursor_mode == "")

	# ── 적 우클릭: 사거리까지 다가가 평타 계속, 대상 외곽선 유지
	var shots0: int = pl.shots_fired
	await click(ep, MOUSE_BUTTON_RIGHT)
	check("적 우클릭: 그 적이 평타 대상(직접 지정)", pl.target_enemy == far_e and pl.attack_forced)
	await move_mouse(screen_of(home + Vector3(-3.0, 0, 2.0)))
	await frames(2)
	check("대상으로 잡힌 적은 진한 붉은 외곽선 유지(커서가 떠나도)", overlay_is(far_e, Outline.TARGET))
	var fired := await wait_until(func(): return pl.shots_fired >= shots0 + 2, 8.0)
	var d_now: float = pl._flat_dist(far_e.global_position)
	check("사거리 밖 적에게 다가가 평타를 계속한다", fired and d_now <= rng + 0.05, "발사 %d, 거리 %.2f/사거리 %.2f" % [pl.shots_fired - shots0, d_now, rng])
	check("사거리 안에서는 멈춰 서서 쏜다", not pl.moving)

	# ── 평타 주기 = BOLT_INTERVAL(선딜 포함)
	var t0 := Time.get_ticks_msec()
	var s0: int = pl.shots_fired
	await wait_until(func(): return pl.shots_fired >= s0 + 3, 8.0)
	var period := float(Time.get_ticks_msec() - t0) / 1000.0 * Engine.time_scale / 3.0
	check("평타 주기 ≈ BOLT_INTERVAL", absf(period - Cfg.BOLT_INTERVAL) < 0.25, "%.2f초" % period)

	# ── 선딜 중 이동 명령: 평타 취소(발사·쿨다운 소모 없음)
	await wait_until(func(): return pl.attack_windup > 0.0, 3.0)
	var s1: int = pl.shots_fired
	var cd_before: float = pl.attack_cd
	await click(screen_of(ground_near(pl.global_position + Vector3(-2.0, 0, 0))), MOUSE_BUTTON_RIGHT)
	await frames(3)
	check("선딜 중 이동 명령: 평타가 취소된다", pl.attack_windup == 0.0 and pl.shots_fired == s1 and pl.attack_cd <= cd_before + 0.001)
	check("이동 명령은 평타 대상을 해제한다", pl.target_enemy == null and not pl.attack_forced and pl.moving)
	await frames(2)
	check("대상 해제 뒤 외곽선도 사라진다", overlay_is(far_e, Outline.NONE))

	# ── 무빙 평타: 발사 직후(후딜) 이동 명령이 바로 먹힌다
	await reset_player(far_e.global_position + Vector3(-rng + 1.0, 0, 0))
	pl.command_attack(far_e)
	var s2: int = pl.shots_fired
	await wait_until(func(): return pl.shots_fired > s2, 3.0)
	check("발사 직후 후딜 상태", pl.attack_backswing > 0.0)
	var pa: Vector3 = pl.global_position
	pl.set_destination(pa + Vector3(-2.5, 0, 0))
	await frames(4)
	check("후딜 중에도 이동 명령으로 바로 움직인다(무빙 평타)", pl.global_position.distance_to(pa) > 0.05 and pl.attack_backswing >= 0.0)
	await frames(10)
	pl.command_attack(far_e)
	var re_fire := await wait_until(func(): return pl.shots_fired > s2 + 1, 4.0)
	check("다시 우클릭하면 쿨다운이 돌아오는 대로 다시 쏜다", re_fire)

	# ── S: 정지
	pl.set_destination(pl.global_position + Vector3(-3.0, 0, 0))
	await frames(3)
	await key(KEY_S)
	await frames(2)
	check("S: 이동·평타 대상을 모두 멈춘다", not pl.moving and pl.target_enemy == null and pl.attack_windup == 0.0 and not pl.attack_move_active)

	# ── 서 있으면 사거리 안의 적을 스스로 잡고, 이동 중에는 쏘지 않는다
	await clear_enemies()
	await reset_player(home)
	var near_e = spawn_dummy(home + Vector3(rng - 1.2, 0, 0))
	await frames(3)
	var s3: int = pl.shots_fired
	var auto_fire := await wait_until(func(): return pl.shots_fired > s3, 3.0)
	check("서 있을 때 사거리 안의 적을 자동으로 잡아 쏜다", auto_fire and pl.target_enemy == near_e and not pl.attack_forced)
	pl.set_destination(home + Vector3(-1.5, 0, 6.0))
	var s4: int = pl.shots_fired
	await frames(30)
	check("이동 명령 중에는 평타하지 않는다", pl.shots_fired == s4 and pl.target_enemy == null)

	# ── A + 좌클릭: 공격 이동(경로 위 적 자동 공격, 처치 후 목적지로)
	await clear_enemies()
	await reset_player(home)
	var dest: Vector3 = ground_near(home + Vector3(rng * 3.0, 0, 0))
	var path_e = spawn_dummy(home + Vector3(rng * 1.5, 0, 0.4), 30.0)
	await frames(3)
	await move_mouse(screen_of(home + Vector3(0, 0, 3.0)))
	await key(KEY_A)
	await frames(2)
	check("A: 공격 이동 대기 + 공격 커서", ctl.attack_armed and ctl.cursor_mode == "attack")
	check("A 대기 중 공격 사거리 표시(반지름 = 사거리)", ctl.range_ring.visible and absf(ctl._ring_mesh.inner_radius + 0.05 - rng) < 0.01)
	await click(screen_of(dest), MOUSE_BUTTON_LEFT)
	check("A+좌클릭: 공격 이동 시작, A 대기 해제", pl.attack_move_active and not ctl.attack_armed and pl.moving)
	var engaged := await wait_until(func(): return pl.target_enemy == path_e, 6.0)
	check("공격 이동 중 경로 위 적을 자동으로 잡는다", engaged)
	var killed := await wait_until(func(): return not is_instance_valid(path_e) or path_e.dead, 10.0)
	check("잡은 적을 처치한다", killed)
	var resumed := await wait_until(func(): return pl._flat_dist(dest) < 0.6, 8.0)
	check("처치 뒤 목적지까지 계속 간다", resumed, "남은 거리 %.2f" % pl._flat_dist(dest))
	check("목적지 도착 뒤 공격 이동 종료", await wait_until(func(): return not pl.attack_move_active, 2.0))

	# ── A + 적 근처 좌클릭: 커서 근처 적 우선
	await clear_enemies()
	await reset_player(home)
	var close_e = spawn_dummy(home + Vector3(rng - 1.0, 0, 0))
	var picked_e = spawn_dummy(home + Vector3(-(rng + 2.0), 0, 0.5))
	await frames(3)
	await key(KEY_A)
	await click(screen_of(picked_e.global_position + Vector3(0, 0.4, 0)), MOUSE_BUTTON_LEFT)
	await frames(2)
	check("A+적 좌클릭: 더 가까운 적이 있어도 커서 아래 적을 대상", pl.target_enemy == picked_e and pl.attack_move_active, "대상=%s" % str(pl.target_enemy))
	await frames(10)
	check("그 적에게 다가간다(가까운 적으로 바꾸지 않음)", pl.target_enemy == picked_e)

	# ── A 취소: 우클릭 / Esc
	await key(KEY_A)
	await click(screen_of(home + Vector3(0, 0, 2.0)), MOUSE_BUTTON_RIGHT)
	check("A 대기 중 우클릭: A 취소하고 이동", not ctl.attack_armed and not pl.attack_move_active)
	await key(KEY_A)
	await key(KEY_ESCAPE)
	check("A 대기 중 Esc: A 만 취소", not ctl.attack_armed and not game.hud.pause_panel.visible)

	# ── C: 사거리 표시 토글
	await key(KEY_C)
	await frames(1)
	var on: bool = ctl.show_range and ctl.range_ring.visible
	await key(KEY_C)
	await frames(1)
	check("C: 공격 사거리 표시 켜기/끄기", on and not ctl.show_range and not ctl.range_ring.visible)

	# ── Space: 카메라를 마녀에게 복귀
	game.world.player_camera.toggle_overview()
	check("(전제) 카메라가 마녀를 떠나 있다", not game.world.player_camera.follow_enabled)
	await key(KEY_SPACE)
	check("Space: 카메라가 마녀를 다시 따라간다", game.world.player_camera.follow_enabled)

	# ── 좌클릭 상호작용 유지: 털 난 양 / 우클릭 양도 수확
	await clear_enemies()
	await reset_player(home)
	var pen = game.world.pasture
	while pen.slots.filter(func(s): return is_instance_valid(s) and not s.dead and not s.is_lamb).size() < 2 and pen.has_empty_slot():
		pen.spawn_sheep(1)
	await frames(3)
	var herd: Array = pen.slots.filter(func(s): return is_instance_valid(s) and not s.dead and not s.is_lamb)
	var sh = herd[0]
	sh.wool_ready = true
	await click(screen_of(sh.global_position + Vector3(0, 0.4, 0)), MOUSE_BUTTON_RIGHT)
	check("털 난 양 우클릭: 수확하러 간다", pl.harvest_target == sh)
	pl.command_stop()
	await click(screen_of(sh.global_position + Vector3(0, 0.4, 0)), MOUSE_BUTTON_LEFT)
	check("털 난 양 좌클릭(기존): 수확 그대로", pl.harvest_target == sh)
	pl.command_stop()
	sh.wool_ready = false

	# ── 카드 드래그 중 우클릭은 손패(드래그 취소)에 맡긴다
	var hand = game.hud.card_hand
	var old_uid: int = hand.drag_uid
	hand.drag_uid = 999999
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_RIGHT
	ev.pressed = true
	ev.position = screen_of(home)
	var taken: bool = ctl.handle_input(ev)
	hand.drag_uid = old_uid
	check("카드 드래그 중 우클릭은 이동 명령으로 가로채지 않는다", not taken)

	Engine.time_scale = 1.0
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
