extends SceneTree
## 기체 입김(breath_vapor.gd) 헤드리스 검증.
##  1부 — 날숨 유체: 유한성, 앞으로 뻗음, 떠오름, 퍼짐(무른 가장자리), 흩어져 사라짐, 변형끼리 다름.
##  2부 — 굽기: 아틀라스 크기·정규화·첫 장/마지막 장.
##  3부 — 게임 연결: 노드·셰이더·ActorVfx 연결, 실제 입김이 기체 판으로 나오고 입자 PUFF 를 안 씀, 좌우 뒤집기, 수명 후 회수.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_breath_vapor.gd

const BreathVapor := preload("res://scripts/visual/vfx/breath_vapor.gd")

var failures := 0
var total := 0


func _initialize() -> void:
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func _stats(d: PackedFloat32Array) -> Dictionary:
	var w := BreathVapor.NX + 2
	var s := 0.0
	var c := Vector2.ZERO
	var peak := 0.0
	var finite := true
	for j in range(1, BreathVapor.NY + 1):
		for i in range(1, BreathVapor.NX + 1):
			var v := d[i + w * j]
			if not is_finite(v):
				finite = false
			s += v
			c += Vector2(i, j) * v
			peak = maxf(peak, v)
	c = c / s if s > 1e-6 else Vector2.ZERO
	var spread := 0.0
	for j in range(1, BreathVapor.NY + 1):
		for i in range(1, BreathVapor.NX + 1):
			spread += (Vector2(i, j) - c).length_squared() * d[i + w * j]
	spread = sqrt(spread / s) if s > 1e-6 else 0.0
	# 윗가장자리: 그 장 최댓값의 15% 를 넘는 가장 높은 줄
	var top := 0
	for j in range(1, BreathVapor.NY + 1):
		for i in range(1, BreathVapor.NX + 1):
			if d[i + w * j] > peak * 0.15:
				top = j
	return {"mass": s, "c": c, "peak": peak, "spread": spread, "finite": finite, "top": top}


func _run() -> void:
	# ───── 1부: 날숨 유체 ─────
	var probe := BreathVapor.new()
	probe.threaded = false
	var frames: Array = probe.simulate_exhale(0)
	check("exhale records %d frames" % BreathVapor.FRAMES, frames.size() == BreathVapor.FRAMES)
	var early := _stats(frames[3])
	var mid := _stats(frames[12])
	var late := _stats(frames[BreathVapor.FRAMES - 1])
	check("solver stays finite", early.finite and mid.finite and late.finite)
	check("breath pushes forward from the mouth", mid.c.x > BreathVapor.SRC.x + 5.0, "centroid x %.1f (mouth %d)" % [mid.c.x, BreathVapor.SRC.x])
	check("warm breath curls upward", late.top >= early.top + 3 and late.c.y > early.c.y, "top row %d → %d, centroid y %.1f → %.1f" % [early.top, late.top, early.c.y, late.c.y])
	check("vapour spreads out (soft, not a tight blob)", mid.spread > early.spread * 1.3 and late.spread > 3.0,
		"spread %.1f → %.1f → %.1f cells" % [early.spread, mid.spread, late.spread])
	check("vapour thins as it spreads (peak falls)", late.peak < mid.peak * 0.6, "peak mid %.2f late %.2f" % [mid.peak, late.peak])
	check("vapour fades by the end", late.mass < mid.mass * 0.75, "mass mid %.1f late %.1f" % [mid.mass, late.mass])
	check("stays inside the sheet", late.c.x < BreathVapor.NX - 4 and late.c.y < BreathVapor.NY - 3, "late centroid %s" % late.c)
	var other := _stats(probe.simulate_exhale(1)[12])
	check("variants differ", other.c.distance_to(mid.c) > 0.4 or absf(other.mass - mid.mass) > mid.mass * 0.08,
		"v0 %s / v1 %s" % [mid.c, other.c])
	probe.free()

	# ───── 2부: 굽기 ─────
	var bake := BreathVapor.new()
	bake.threaded = false
	root.add_child(bake)
	var img: Image = bake.atlas_image
	var tw := BreathVapor.NX + 2
	var th := BreathVapor.NY + 2
	check("atlas size = frames × variants", img != null and img.get_width() == tw * BreathVapor.FRAMES and img.get_height() == th * BreathVapor.VARIANTS,
		"%dx%d" % [img.get_width(), img.get_height()] if img != null else "null")
	var mx := 0.0
	for y in img.get_height():
		for x in img.get_width():
			mx = maxf(mx, img.get_pixel(x, y).r)
	check("atlas normalised to 0..1", absf(mx - 1.0) < 1e-3, "max %.3f" % mx)
	check("bake is quick enough for a worker", bake.bake_usec < 4_000_000, "%.0f ms" % (bake.bake_usec / 1000.0))
	check("baked material wired", bake.is_ready() and bake.material.get_shader_parameter("atlas") is ImageTexture)
	bake.queue_free()

	# ───── 3부: 게임 연결 ─────
	root.size = Vector2i(1280, 720)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 20:
		await process_frame
	var world = game.world
	var bv = world.get_node_or_null("BreathVapor")
	check("BreathVapor node in world", bv != null and bv.get_script() == BreathVapor)
	if bv == null:
		_finish()
		return
	var t_wait := 0
	while not bv.is_ready() and t_wait < 300:
		await process_frame
		t_wait += 1
	check("bake finishes on worker thread", bv.is_ready(), "%d frames" % t_wait)
	check("uses breath vapour shader", bv.material.shader.resource_path.ends_with("breath_vapor.gdshader"))
	check("ActorVfx routes breath to vapour", world.actor_vfx.breath == bv)
	check("wind source connected", bv.weather == world.weather_vfx and bv.weather != null)
	# 실제 캐릭터들이 숨을 쉬게 둔다.
	var pool = world.vfx_pool
	await create_timer(3.0).timeout
	check("characters exhale vapour", bv.spawned > 0 and bv.active_count() > 0, "spawned %d, live %d" % [bv.spawned, bv.active_count()])
	var sheets: Array = bv.get_children().filter(func(n): return n is MeshInstance3D and n.visible)
	check("each breath is one soft sheet (no hard puff sprites)", sheets.size() == bv.active_count())

	# 좌우: 카메라 오른쪽으로 내쉬면 판이 +x, 왼쪽이면 뒤집힌다.
	var cam: Camera3D = world.camera
	var r := cam.global_basis.x
	r.y = 0
	r = r.normalized()
	var at: Vector3 = world.game.player.global_position + Vector3(0, 1.5, 0)
	var before: int = bv.spawned
	bv.exhale(at, r, Color(1, 1, 1, 0.6), 1.0)
	var right_sheet: MeshInstance3D = bv._live[-1]["node"]
	var sx_r := right_sheet.global_basis.x.dot(r)
	bv.exhale(at, -r, Color(1, 1, 1, 0.6), 1.0)
	var left_sheet: MeshInstance3D = bv._live[-1]["node"]
	var sx_l := left_sheet.global_basis.x.dot(r)
	check("sheet extends toward exhale direction", bv.spawned == before + 2 and sx_r > 0.5 and sx_l < -0.5, "right %.2f left %.2f" % [sx_r, sx_l])
	var back := cam.global_basis.z
	back.y = 0
	check("sheet stands upright facing camera", right_sheet.global_basis.z.normalized().dot(back.normalized()) > 0.99 \
		and absf(right_sheet.global_basis.y.normalized().dot(Vector3.UP) - 1.0) < 1e-4)
	var p0 := right_sheet.global_position
	await create_timer(0.6).timeout
	var age: float = right_sheet.get_instance_shader_parameter("age")
	check("age advances on the sheet", age > 0.2 and age < 0.6, "age %.2f" % age)
	check("vapour drifts (wind/rise)", right_sheet.global_position.distance_to(p0) > 0.01)
	await create_timer(2.0).timeout
	check("sheets recycled after life", not right_sheet.visible or bv._live.any(func(p): return p["node"] == right_sheet and p["age"] < 1.0))
	check("live sheets bounded", bv.active_count() <= BreathVapor.MAX_PUFFS)
	_finish()


func _finish() -> void:
	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
