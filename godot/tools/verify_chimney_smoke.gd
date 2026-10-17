extends SceneTree
## 굴뚝 연기(Stable Fluids) 헤드리스 검증.
##  1부 — 유체 해법(stable_fluid.gd): 유한성, 투영 후 비압축성, 부력 상승, 바람 휘어짐(양방향),
##        큰 dt 무조건 안정, 와도 보존 효과, 열린 경계 정상상태, 입구 닫으면 감쇠.
##  2부 — 게임 연결(chimney_smoke.gd): 노드 위치·판·셰이더·바람 연결, 작업 스레드 진행, 텍스처 갱신,
##        카메라 쪽 방향, 한 단계 비용.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_chimney_smoke.gd

const Fluid := preload("res://scripts/visual/vfx/stable_fluid.gd")
const ChimneySmoke := preload("res://scripts/visual/vfx/chimney_smoke.gd")
const Layout := preload("res://scripts/world/layout.gd")

var failures := 0
var total := 0


func _initialize() -> void:
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


## 게임과 같은 설정의 해법을 seconds 초 돌린다. 입구는 노이즈로 숨 쉰다.
func _plume(seconds: float, wind := 0.0, vorticity := 1.6, dt := 1.0 / 30.0, open := true):
	var f = Fluid.new(32, 56)
	f.buoyancy = 7.0
	f.cooling = 0.15
	f.weight = 0.0
	f.vorticity = vorticity
	f.dissipation = 0.11
	f.wind = wind
	var n := FastNoiseLite.new()
	n.seed = 7
	n.frequency = 0.8
	var t := 0.0
	while t < seconds - 1e-6:
		var puff := 0.78 + 0.3 * n.get_noise_1d(t)
		if open:
			f.set_inflow(14, 17, 9.0 * puff, 0.95 * puff, 1.0, 2.0 * n.get_noise_1d(t * 1.7 + 90.0))
		else:
			f.set_inflow(0, 0, 0.0, 0.0, 0.0)
		f.step(dt)
		t += dt
	return f


func _curl_energy(f) -> float:
	var s := 0.0
	for j in range(2, f.ny):
		for i in range(2, f.nx):
			var k: int = f.idx(i, j)
			s += absf(0.5 * ((f.v[k + 1] - f.v[k - 1]) - (f.u[k + f.w] - f.u[k - f.w])))
	return s


func _run() -> void:
	# ───── 1부: 유체 해법 ─────
	var base = _plume(6.0)
	check("solver stays finite (6 s, noisy inflow)", base.all_finite())
	var div: Vector2 = base.divergence_stats()
	var speed: float = base.max_speed()
	# 투영 직후 평균 |∇·u| 가 대표 속도의 1% 미만이어야 한다(비압축성).
	check("projection keeps flow divergence-free", div.x < speed * 0.01, "mean|div|=%.4f max|div|=%.3f vmax=%.2f" % [div.x, div.y, speed])
	var c_early: Vector2 = _plume(1.0).density_centroid()
	var c_late: Vector2 = base.density_centroid()
	check("buoyant plume rises", c_late.y > c_early.y + 6.0 and c_late.y > 14.0, "centroid y 1s=%.1f 6s=%.1f" % [c_early.y, c_late.y])
	check("calm plume stays near the mouth column", absf(c_late.x - 15.5) < 3.0, "centroid x=%.2f (mouth 15.5)" % c_late.x)

	var right = _plume(6.0, 4.0)
	var left = _plume(6.0, -4.0)
	var cr: Vector2 = right.density_centroid()
	var cl: Vector2 = left.density_centroid()
	check("wind bends plume downwind (+)", cr.x > c_late.x + 2.0, "x=%.2f vs calm %.2f" % [cr.x, c_late.x])
	check("wind bends plume downwind (-)", cl.x < c_late.x - 2.0, "x=%.2f vs calm %.2f" % [cl.x, c_late.x])

	var big = _plume(10.0, 3.0, 1.6, 0.5)
	check("unconditionally stable at dt=0.5 (15x)", big.all_finite() and big.max_speed() < 200.0, "vmax=%.1f" % big.max_speed())

	var plain = _plume(5.0, 0.0, 0.0)
	var curly = _plume(5.0, 0.0, 1.6)
	var strong = _plume(5.0, 0.0, 4.0)
	var e0 := _curl_energy(plain)
	var e1 := _curl_energy(curly)
	var e2 := _curl_energy(strong)
	check("vorticity confinement adds swirl (monotonic)", e0 < e1 and e1 < e2, "Σ|ω| ε=0 %.1f, ε=1.6 %.1f, ε=4 %.1f" % [e0, e1, e2])

	var m10: float = _plume(10.0).total_density()
	var m16: float = _plume(16.0).total_density()
	check("open boundaries reach steady state (smoke leaves)", absf(m16 - m10) < m10 * 0.25, "mass 10s=%.1f 16s=%.1f" % [m10, m16])

	var closed = _plume(4.0)
	var before: float = closed.total_density()
	closed.set_inflow(0, 0, 0.0, 0.0, 0.0)
	for i in 150:
		closed.step(1.0 / 30.0)
	# 감쇠만으로는 e^(-0.11*5)≈0.58 배 — 그보다 더 줄어야 위로 빠져나간 것이다.
	check("closing the mouth lets smoke clear", closed.total_density() < before * 0.5, "%.1f → %.1f" % [before, closed.total_density()])

	# ───── 2부: 게임 연결 ─────
	root.size = Vector2i(1280, 720)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 20:
		await process_frame
	var world = game.world
	var smoke = world.get_node_or_null("ChimneySmoke")
	check("ChimneySmoke node uses Stable Fluids script", smoke != null and smoke.get_script() == ChimneySmoke)
	if smoke == null:
		_finish()
		return
	check("no particle emitter left for chimney", not (smoke is GPUParticles3D) and not (smoke is CPUParticles3D))
	check("smoke sits on the chimney top", smoke.position == Layout.CHIMNEY_TOP)
	var plume: MeshInstance3D = smoke.get_node_or_null("Plume")
	check("plume quad with smoke shader", plume != null and plume.material_override is ShaderMaterial \
		and plume.material_override.shader.resource_path.ends_with("chimney_smoke.gdshader"))
	check("wind source connected", smoke.weather == world.weather_vfx and world.weather_vfx != null)
	var s0: int = smoke.steps
	for i in 90:
		await process_frame
	await create_timer(0.5).timeout
	check("worker thread keeps simulating", smoke.steps > s0, "steps %d → %d" % [s0, smoke.steps])
	# 더미 렌더러는 GPU 텍스처 내용을 돌려주지 않으므로 마지막으로 올린 Image 를 본다.
	var img: Image = smoke._img_prev
	var maxd := 0.0
	for y in img.get_height():
		for x in img.get_width():
			maxd = maxf(maxd, img.get_pixel(x, y).r)
	check("density texture uploaded", img.get_format() == Image.FORMAT_RF and maxd > 0.2, "max density %.2f" % maxd)
	var cam: Camera3D = world.camera
	var back := cam.global_basis.z
	back.y = 0.0
	var facing := plume.global_basis.z.normalized().dot(back.normalized())
	check("plume faces camera (upright)", facing > 0.99 and absf(plume.global_basis.y.normalized().dot(Vector3.UP) - 1.0) < 1e-4, "dot=%.3f" % facing)
	var fade: float = smoke.material.get_shader_parameter("fade")
	check("smoke faded in after warm-up", fade > 0.5, "fade=%.2f" % fade)
	check("one solver step is cheap enough for a worker", smoke.last_step_usec < 20000, "%.2f ms/step" % (smoke.last_step_usec / 1000.0))
	check("wind projected onto plume plane", is_finite(smoke.wind_cells) and absf(smoke.wind_cells) < 40.0, "%.2f cells/s" % smoke.wind_cells)

	# ───── 3부: 굴뚝 연도 구멍 ─────
	var cottage: Node3D = world.lodge.visual.get_node_or_null("UserCottage")
	var meshes: Array = world.lodge.visual.find_children("*", "MeshInstance3D", true, false)
	check("cottage is still one mesh instance", meshes.size() == 1)
	var mi: MeshInstance3D = meshes[0]
	check("flue soot surface added", mi.mesh.get_surface_count() == 2 and mi.get_surface_override_material(1) is ShaderMaterial \
		and mi.get_surface_override_material(1).shader.resource_path.ends_with("chimney_flue.gdshader"))
	var flue: Dictionary = cottage.get_meta("flue", {})
	check("closed flue top face removed", flue.get("removed", 0) >= 2, "removed %d tris" % flue.get("removed", 0))
	var opening: Rect2 = flue.get("opening", Rect2())
	var cxz := Vector2(Layout.CHIMNEY_TOP.x, Layout.CHIMNEY_TOP.z)
	check("hole is centred on the chimney", opening.has_point(cxz) and opening.size.x > 0.18 and opening.size.y > 0.18,
		"opening %s" % opening)
	# 굴뚝 중심으로 위에서 내리꽂은 광선의 첫 충돌: 막힌 윗면(5.20)이 아니라 구멍 바닥이어야 한다.
	var xf := mi.global_transform
	var from := Vector3(cxz.x, 7.0, cxz.y)
	var first := -INF
	for s in mi.mesh.get_surface_count():
		var arr := mi.mesh.surface_get_arrays(s)
		var vv: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var ii = arr[Mesh.ARRAY_INDEX]
		var n: int = ii.size() if ii != null else vv.size()
		for t in range(0, n - 2, 3):
			var a := xf * vv[ii[t] if ii != null else t]
			var b := xf * vv[ii[t + 1] if ii != null else t + 1]
			var c := xf * vv[ii[t + 2] if ii != null else t + 2]
			var hit = Geometry3D.ray_intersects_triangle(from, Vector3.DOWN, a, b, c)
			if hit != null:
				first = maxf(first, hit.y)
	var floor_y: float = flue.get("floor", 0.0)
	check("looking down the chimney reaches the sooty floor", absf(first - floor_y) < 0.02, "first hit y=%.3f floor=%.3f" % [first, floor_y])
	# 연기는 구멍 안에서 시작해 구멍 폭으로 나온다.
	var plume_bottom: float = Layout.CHIMNEY_TOP.y - ChimneySmoke.MOUTH_SINK
	check("smoke starts inside the hole", plume_bottom > floor_y + 0.05 and plume_bottom < flue.get("top", 0.0) - 0.1,
		"plume bottom %.2f, floor %.2f, rim %.2f" % [plume_bottom, floor_y, flue.get("top", 0.0)])
	var mouth_w := float(ChimneySmoke.MOUTH.y - ChimneySmoke.MOUTH.x + 1) * ChimneySmoke.CELL
	check("smoke mouth matches hole width", absf(mouth_w - opening.size.x) < 0.05, "mouth %.2f m vs hole %.2f m" % [mouth_w, opening.size.x])
	var fl = smoke.fluid
	var leak := 0.0
	var inside := 0.0
	for j in range(1, 3):
		for i in range(1, ChimneySmoke.MOUTH.x - 1):
			leak += fl.dens[fl.idx(i, j)]
		for i in range(ChimneySmoke.MOUTH.x, ChimneySmoke.MOUTH.y + 1):
			inside += fl.dens[fl.idx(i, j)]
	check("flue walls keep smoke in the hole below the rim", fl.solid_cells.size() >= 4 and leak < inside * 0.05,
		"beside walls %.3f vs in hole %.3f" % [leak, inside])
	_finish()


func _finish() -> void:
	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
