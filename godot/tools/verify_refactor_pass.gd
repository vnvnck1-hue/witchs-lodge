extends SceneTree
## 2026-10-19 리팩토링·1차 최적화가 결과를 바꾸지 않았는지 검증한다.
## - 시야 안개: 건드린 칸만 지우고 인코딩하는 갱신이 전체를 다시 계산한 값과 같다(여러 번 움직이며 비교).
## - VFX 풀: MultiMesh 가 작게 시작해 입자 수만큼 커지고, 버퍼 길이가 항상 instance_count×20 이다.
## - 카드 목록: 캐시한 find()/back() 이 JSON 을 새로 읽은 값과 같다.
## - ActorUtil: 평면 거리·바라보기가 예전 계산식과 같다. 괴물의 대상 고르기가 예전(배열을 이어 붙인) 방식과 같다.
## - 달 게이지·테마 덮어쓰기: 값이 같으면 다시 그리지/걸지 않는다.
## - 미니맵: 카메라 스타일을 바꾸면 회전이 따라간다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_refactor_pass.gd

const Cfg := preload("res://scripts/config.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")
const ActorUtil := preload("res://scripts/actors/actor_util.gd")
const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")
const MoonWidgets := preload("res://scripts/ui/moon/moon_widgets.gd")
const CameraStyle := preload("res://scripts/visual/camera_style.gd")
const FogScript := preload("res://scripts/visual/fog_of_war.gd")

var failures := 0
var total := 0
var game


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(2))
	call_deferred("_run")


func ticks(count: int) -> void:
	for i in count:
		await physics_frame
	await process_frame


func _run() -> void:
	_check_catalog()
	_check_actor_util()
	_check_gauge_and_overrides()
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await ticks(6)
	game.session.set_process(false)
	await _check_fog()
	_check_vfx_pool()
	await _check_monster_foe()
	_check_minimap_yaw()
	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)


func _check_catalog() -> void:
	var fresh: Dictionary = Catalog.read()
	var cards: Array = fresh.get("cards", [])
	check("카드 목록이 비어 있지 않다", cards.size() > 0, str(cards.size()))
	var same := true
	var seen := {}
	for entry in cards:
		var id: String = entry.get("id", "")
		if seen.has(id):
			continue
		seen[id] = true
		if Catalog.find(id) != entry:
			same = false
			print("  다른 항목: ", id)
	check("캐시한 find() 가 새로 읽은 첫 항목과 같다", same)
	check("없는 id 는 빈 사전", Catalog.find("__no_such_card__").is_empty())
	var copy := Catalog.find(str(cards[0].get("id", "")))
	copy["id"] = "__mutated__"
	check("find() 결과를 고쳐도 캐시는 그대로", Catalog.find(str(cards[0].get("id", ""))).get("id", "") == cards[0].get("id", ""))
	check("back() 이 새로 읽은 뒷면과 같다", (Catalog.back(false).resource_path if Catalog.back(false) != null else "") == str(fresh.get("back", "")))


func _check_actor_util() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var same := true
	for i in 200:
		var a := Vector3(rng.randf_range(-50, 50), rng.randf_range(-3, 3), rng.randf_range(-50, 50))
		var b := Vector3(rng.randf_range(-50, 50), rng.randf_range(-3, 3), rng.randf_range(-50, 50))
		if ActorUtil.flat_dist(a, b) != Vector2(a.x - b.x, a.z - b.z).length():
			same = false
	check("flat_dist 가 예전 식과 같다", same)
	var v := Node3D.new()
	var w := Node3D.new()
	same = true
	for i in 100:
		var dir := Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * rng.randf_range(0.0, 2.0)
		var delta := rng.randf_range(0.0, 0.2)
		v.rotation.y = rng.randf_range(-PI, PI)
		w.rotation.y = v.rotation.y
		ActorUtil.face(v, dir, delta, 8.0)
		var d := dir
		d.y = 0.0
		if d.length() >= 0.01:
			w.rotation.y = lerp_angle(w.rotation.y, atan2(d.x, d.z), clampf(delta * 8.0, 0.0, 1.0))
		if v.rotation.y != w.rotation.y:
			same = false
	check("face 가 예전 식과 같다", same)
	v.free()
	w.free()


func _check_gauge_and_overrides() -> void:
	var gauge = MoonWidgets.MoonGauge.new()
	gauge.set_value(0.5, true)
	check("게이지 즉시 값", gauge.value == 0.5 and gauge.shown == 0.5)
	gauge.set_value(0.5)
	check("같은 값은 그대로", gauge.value == 0.5 and gauge.shown == 0.5)
	gauge.set_value(0.25)
	check("새 값은 받아들이고 애니메이션 대상으로 둔다", gauge.value == 0.25 and gauge.shown == 0.5)
	gauge.set_value(0.25, true)
	check("같은 값이라도 instant 면 즉시 맞춘다", gauge.shown == 0.25)
	gauge.free()
	var label := Label.new()
	MoonSkin.set_font_color(label, Color.RED)
	check("글자색 덮어쓰기", label.get_theme_color("font_color") == Color.RED)
	var changes := [0]
	label.theme_changed.connect(func(): changes[0] += 1)
	MoonSkin.set_font_color(label, Color.RED)
	check("같은 글자색은 다시 걸지 않는다", changes[0] == 0, str(changes[0]))
	MoonSkin.set_font_color(label, Color.BLUE)
	check("다른 글자색은 건다", label.get_theme_color("font_color") == Color.BLUE)
	var panel := PanelContainer.new()
	var box := StyleBoxFlat.new()
	MoonSkin.set_stylebox(panel, box)
	check("판 덮어쓰기", panel.get_theme_stylebox("panel") == box)
	label.free()
	panel.free()


## 예전 refresh() 처럼 모든 칸을 다시 계산한 R·G 바이트를 만든다(지금 sight·explored 에서).
func _full_encode(fog) -> PackedByteArray:
	var data := PackedByteArray()
	data.resize(FogScript.RESOLUTION * FogScript.RESOLUTION * 2)
	for i in fog.sight.size():
		data[i * 2] = int(fog.sight[i] * 255.0)
		data[i * 2 + 1] = fog.explored[i]
	return data


func _check_fog() -> void:
	var fog = game.world.fog_of_war
	check("시야 안개가 있다", fog != null)
	if fog == null:
		return
	var spots := [Vector3(-24, 0, 5), Vector3(-10, 0, -20), Vector3(18, 0, 14), Vector3(2, 0, 2), Vector3(-30, 0, -8)]
	var all_same := true
	var stale_zero := true
	var max_lit := 0
	for p in spots:
		game.player.global_position = p
		await ticks(2)
		fog.refresh()
		var expect := _full_encode(fog)
		if expect != fog._image.get_data():
			all_same = false
		# 지금 밝힌 칸 밖에 남은 시야가 없어야 한다(전체를 지우던 예전과 같은 결과)
		var lit := 0
		for i in fog.sight.size():
			if fog.sight[i] > 0.0:
				lit += 1
				var x: int = i % FogScript.RESOLUTION
				var y: int = i / FogScript.RESOLUTION
				var inside := false
				for r in fog._prev_rects:
					if r.has_point(Vector2i(x, y)):
						inside = true
						break
				if not inside:
					stale_zero = false
		max_lit = maxi(max_lit, lit)
	check("안개 텍스처가 전체 재계산 값과 같다(%d곳)" % spots.size(), all_same)
	check("이번에 밝힌 칸 밖에는 시야가 남지 않는다", stale_zero)
	check("시야가 실제로 밝혀진다", max_lit > 100, str(max_lit))
	check("탐색 기억이 쌓인다", fog.is_explored_at(Vector3(-24, 0, 5)) and fog.is_explored_at(Vector3(18, 0, 14)))


func _check_vfx_pool() -> void:
	var pool = root.find_child("VfxPool", true, false)
	check("VFX 풀이 있다", pool != null)
	if pool == null:
		return
	var layer = pool.billboard
	check("MultiMesh 가 작게 시작한다", layer.mm.instance_count <= 256 and layer.mm.instance_count < layer.cap, str(layer.mm.instance_count))
	var want := 700
	var added := 0
	for i in want:
		if pool.emit(pool.GLOW, Vector3(0, 1, 0), Vector3.UP, 5.0, 0.3, Color.WHITE):
			added += 1
	layer.step(0.016, Vector3.RIGHT, Vector3.UP)
	check("입자 수만큼 커진다", layer.mm.instance_count >= layer.n and layer.n >= added, "count=%d n=%d" % [layer.mm.instance_count, layer.n])
	check("버퍼 길이 = instance_count×20", layer.buf.size() == layer.mm.instance_count * 20)
	check("보이는 수 = 살아 있는 입자 수", layer.mm.visible_instance_count == layer.n)
	check("cap 을 넘지 않는다", layer.mm.instance_count <= layer.cap)


## 예전 _pick_foe: [마녀] + 용병 + 가시덩굴 + 감시탑을 이어 붙인 배열에서 '<=' 로 가장 가까운 대상.
func _old_pick_foe(m):
	var best_d := maxf(Cfg.MONSTER_AGGRO, m.reach)
	var best = null
	var cands: Array = [game.player] + get_nodes_in_group("allies") + get_nodes_in_group("thorn_plants") + get_nodes_in_group("watchtowers")
	for a in cands:
		if not m._foe_valid(a):
			continue
		var d: float = m._foe_dist(a)
		if d <= best_d:
			best_d = d
			best = a
	return best


func _check_monster_foe() -> void:
	game.session.start_wave()
	var spawned := false
	for i in 120:
		await physics_frame
		if get_node_count_in_group("wave_enemies") > 0:
			spawned = true
			break
	check("웨이브 괴물이 나온다", spawned)
	check("alive() 가 그룹 수와 같다", game.waves.alive() == get_nodes_in_group("wave_enemies").size())
	var same := true
	var compared := 0
	for spot in [Vector3(-6, 0, 4), Vector3(8, 0, -3), Vector3(0, 0, 12)]:
		game.player.global_position = spot
		await ticks(1)
		for m in get_nodes_in_group("wave_enemies"):
			if m.dead or m.ignore_units:
				continue
			m.chase = null
			var expect = _old_pick_foe(m)
			m.chase = null
			var got = m._pick_foe()
			compared += 1
			if got != expect:
				same = false
	check("괴물 대상 고르기가 예전과 같다(%d번 비교)" % compared, same and compared > 0)


func _check_minimap_yaw() -> void:
	var mini = game.hud.exploration_map
	var prior: String = CameraStyle.current_id
	for id in CameraStyle.IDS:
		CameraStyle.current_id = id
		var yaw := deg_to_rad(CameraStyle.profile(id).yaw)
		var p := Vector2(8, -26)
		var d: Vector2 = p - preload("res://scripts/world/layout.gd").MAP_CENTER
		var expect := Vector2(mini.size.x * .5, 128) + Vector2(d.x * cos(yaw) - d.y * sin(yaw), d.x * sin(yaw) + d.y * cos(yaw)) * 2.15
		check("미니맵 좌표가 카메라 회전을 따른다: " + id, mini._map_point(p).is_equal_approx(expect))
	CameraStyle.current_id = prior
