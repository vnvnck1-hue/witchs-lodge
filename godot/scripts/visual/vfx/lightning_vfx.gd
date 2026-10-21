extends Node3D
## 마녀 Q 번개 일격(Lightning Lance) 연출(표시 전용 — 피해·감전 판정은 actors/player.gd 가 한다).
## 면은 모두 shaders/vfx/lightning/ 의 VisualShader(tools/build_lightning_shaders.gd 로 재생성)로 그리고,
## 입자는 공용 VfxPool, 화면 흔들림은 World.shake 를 쓴다.
##
##   lance   시전점 → 끝점: 번개 줄기 두 겹이 0.05초에 뻗고 0.035초마다 모양이 튀며 지직거린 뒤(0.17) 꼬리부터 끊겨 사라짐(0.42)
##           + 지팡이 끝 섬광 구체 + 끝점 구체·지면 방전 자국 + 맞은 적마다 작은 구체·불꽃 + 줄기를 따라 튀는 불티 + 순간광

const Fx := preload("res://scripts/visual/fx.gd")
const Pool := preload("res://scripts/visual/vfx/vfx_pool.gd")
const SH_BOLT := preload("res://shaders/vfx/lightning/lt_bolt.tres")
const SH_ORB := preload("res://shaders/vfx/lightning/lt_orb.tres")
const SH_SCORCH := preload("res://shaders/vfx/lightning/lt_scorch.tres")

const C_CORE := Color(0.9, 1.0, 1.0)
const C_ELEC := Color(0.3, 0.85, 1.0)
const C_DEEP := Color(0.15, 0.45, 1.0)

const REACH_T := 0.05        # 줄기가 끝까지 뻗는 시간
const HOLD_T := 0.17         # 이때까지 지직거리며 밝게 버팀
const FLICKER_T := 0.035     # 모양이 새로 튀는 간격
const BOLT_LIFE := 0.42

enum Kind { BOLT, ORB, SCORCH }

var kind := Kind.BOLT
var t := 0.0
var life := 0.5
var size_k := 1.0
var _mi: MeshInstance3D
var _mat: ShaderMaterial
var _light: OmniLight3D
var _from := Vector3.ZERO
var _to := Vector3.ZERO
var _flick := 0.0
var _delay := 0.0             # ORB: 줄기 머리가 닿은 뒤에 터진다


# ---------------------------------------------------------------- 공개 함수

## 번개 일격 한 번. from = 지팡이 끝, to = 줄기 끝(사거리 끝 또는 마지막 적), hits = 맞은 적의 가슴 높이 점들.
static func lance(parent: Node, from: Vector3, to: Vector3, hits: Array = []) -> void:
	if parent == null or not is_instance_valid(parent) or not parent.is_inside_tree():
		return
	var length := from.distance_to(to)
	if length < 0.2:
		return
	# 줄기 두 겹: 굵은 칼날 + 가늘고 크게 꺾이는 곁줄기
	var main := _spawn(parent, Kind.BOLT, BOLT_LIFE)
	main._bolt(from, to, 2.6, 1.0, 1.0)
	var side := _spawn(parent, Kind.BOLT, BOLT_LIFE * 0.85)
	side._bolt(from, to, 3.4, 0.35, 0.7)
	main._light_at((to - from) * 0.5, C_ELEC, 5.0, maxf(length * 0.75, 4.0))
	# 지팡이 끝 섬광 구체
	var muzzle := _spawn(parent, Kind.ORB, 0.2)
	muzzle._orb(from, 1.1)
	# 끝점 구체 + 지면 방전 자국(줄기 머리가 닿는 순간)
	var end := _spawn(parent, Kind.ORB, 0.42)
	end._orb(to, 2.4)
	end._delay = REACH_T * 0.8
	end._light_at(Vector3.ZERO, C_ELEC, 8.0, 5.5)
	var scorch := _spawn(parent, Kind.SCORCH, 1.6)
	scorch._ground(Vector3(to.x, 0.045, to.z), 3.0)
	# 맞은 적마다 작은 구체와 불꽃
	for h in hits:
		var o := _spawn(parent, Kind.ORB, 0.3)
		o._orb(h, 1.5)
		o._delay = REACH_T * clampf(from.distance_to(h) / length, 0.0, 1.0)
		Fx.hit(h, C_ELEC, true)
	var P = Fx._p()
	if P != null:
		var dir := (to - from) / length
		# 줄기를 따라 튀는 불티(줄기 방향으로 빠르게 끌린다)
		for i in int(clampf(length * 2.2, 8.0, 26.0)):
			var at := from.lerp(to, randf())
			var vel := dir * randf_range(4.0, 9.0) + Fx._rv(randf_range(1.5, 4.0)) + Vector3(0, 1.2, 0)
			P.emit(Pool.STREAK, at, vel, randf_range(0.14, 0.3), randf_range(0.12, 0.22), C_CORE if i % 3 == 0 else C_ELEC,
				{"gravity": -7.0, "align": true, "aspect": 0.25, "additive": true, "drag": 2.0})
		# 끝점: 충격파 + 하얀 고리 + 사방 불꽃
		P.emit(Pool.SHOCK, to, Vector3.ZERO, 0.22, 2.2, C_ELEC, {"pop": true, "grow": 1.5, "additive": true})
		P.emit(Pool.RING, to, Vector3.ZERO, 0.3, 0.5, Color(0.85, 1.0, 1.0, 0.95), {"additive": true, "grow": 5.0})
		P.emit(Pool.RING, Vector3(to.x, 0.06, to.z), Vector3.ZERO, 0.4, 1.0, Color(0.5, 0.9, 1.0, 0.85), {"ground": true, "additive": true, "grow": 3.2})
		for i in 14:
			var v := Fx._rv(randf_range(3.0, 7.5))
			v.y = absf(v.y) + 1.5
			P.emit(Pool.STREAK, to, v, randf_range(0.2, 0.42), randf_range(0.14, 0.26), C_CORE if i % 2 else C_ELEC,
				{"gravity": -12.0, "align": true, "aspect": 0.25, "additive": true, "land": true})
		# 시전자 발밑 반동 고리
		P.emit(Pool.RING, Vector3(from.x, 0.05, from.z), Vector3.ZERO, 0.3, 0.6, Color(0.5, 0.9, 1.0, 0.7), {"ground": true, "additive": true, "grow": 2.4})


## 타격 순간 화면 흔들림(World.shake). game 이 없으면(검증 장면) 무시.
static func shake(game: Node, amount: float, duration: float) -> void:
	if game != null and is_instance_valid(game) and game.get("world") != null and game.world.has_method("shake"):
		game.world.shake(amount, duration)


# ---------------------------------------------------------------- 내부

static func _spawn(parent: Node, k: Kind, lifetime: float) -> Node3D:
	var v = load("res://scripts/visual/vfx/lightning_vfx.gd").new()
	v.kind = k
	v.life = lifetime
	v.name = "LightningVfx_" + Kind.keys()[k]
	parent.add_child(v, true)
	return v


func _quad(size: Vector2, sh: Shader, priority: int) -> void:
	_mi = MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = size
	_mi.mesh = pm
	_mat = ShaderMaterial.new()
	_mat.shader = sh
	_mat.render_priority = priority
	_mi.material_override = _mat
	_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_mi)


## 줄기 판: uv.x = from → to. 판은 줄기 축을 중심으로 돌려 카메라 쪽을 향하게 세운다(위에서 내려다봐도 납작해지지 않음).
func _bolt(from: Vector3, to: Vector3, width: float, thickness: float, intensity: float) -> void:
	_from = from
	_to = to
	_quad(Vector2(from.distance_to(to), width), SH_BOLT, 5)
	_mat.set_shader_parameter("thickness", thickness)
	_mat.set_shader_parameter("intensity", intensity)
	_mat.set_shader_parameter("seed", randf() * 50.0)
	_mat.set_shader_parameter("reach", 0.0)
	set_meta("base_intensity", intensity)
	global_position = (from + to) * 0.5
	_face_along()


func _orb(at: Vector3, diameter: float) -> void:
	_quad(Vector2(diameter, diameter), SH_ORB, 6)
	_mat.set_shader_parameter("seed", randf() * 50.0)
	_mat.set_shader_parameter("pulse", 0.0)
	_mat.set_shader_parameter("arcs", 0.0)
	_mat.set_shader_parameter("fade", 0.0)
	global_position = at
	_face_camera()


func _ground(at: Vector3, diameter: float) -> void:
	_quad(Vector2(diameter, diameter), SH_SCORCH, 1)
	_mat.set_shader_parameter("seed", randf() * 50.0)
	_mat.set_shader_parameter("wave", 0.0)
	_mat.set_shader_parameter("spread", 0.0)
	global_position = at
	rotation.y = randf() * TAU


func _light_at(local: Vector3, color: Color, energy: float, rng: float) -> void:
	_light = OmniLight3D.new()
	_light.light_color = color
	_light.omni_range = rng
	_light.light_energy = energy
	_light.position = local
	_light.set_meta("peak", energy)
	add_child(_light)


func _cam() -> Camera3D:
	return get_viewport().get_camera_3d() if is_inside_tree() else null


## PlaneMesh 앞면은 +Y, 크기 x 는 로컬 X 축. X = 줄기 방향, Y = 줄기에 수직인 카메라 쪽.
func _face_along() -> void:
	var x := (_to - _from).normalized()
	var to_cam := Vector3.UP
	var cam := _cam()
	if cam != null:
		to_cam = (cam.global_position - global_position).normalized()
	var n := to_cam - x * to_cam.dot(x)
	if n.length() < 0.01:
		n = Vector3.UP - x * x.y
	n = n.normalized()
	_mi.global_basis = Basis(x, n, x.cross(n)).orthonormalized()


func _face_camera() -> void:
	var cam := _cam()
	if cam == null:
		_mi.global_basis = Basis(Vector3.RIGHT, Vector3.BACK, Vector3.DOWN)
		return
	var to_cam := (cam.global_position - global_position).normalized()
	var x := cam.global_basis.y.cross(to_cam).normalized()
	_mi.global_basis = Basis(x, to_cam, x.cross(to_cam)).orthonormalized()


func _process(delta: float) -> void:
	t += delta
	_step()
	if t >= life:
		queue_free()


func _step() -> void:
	if _light != null:
		_light.light_energy = float(_light.get_meta("peak")) * exp(-t * 11.0) * (0.75 + 0.5 * randf())
	match kind:
		Kind.BOLT:
			_mat.set_shader_parameter("reach", _ease_out(clampf(t / REACH_T, 0.0, 1.0)))
			_mat.set_shader_parameter("dissolve", clampf((t - HOLD_T) / (life - HOLD_T), 0.0, 1.0))
			# 지직거림: 버티는 동안 일정 간격으로 모양을 새로 뽑고 밝기를 튀긴다
			_flick -= get_process_delta_time()
			if _flick <= 0.0 and t < HOLD_T + 0.08:
				_flick = FLICKER_T
				_mat.set_shader_parameter("seed", randf() * 50.0)
			var base: float = get_meta("base_intensity", 1.0)
			var pop := 1.1 * exp(-t * 16.0) + (0.3 * randf() if t < HOLD_T else 0.0)
			_mat.set_shader_parameter("intensity", base * (1.0 + pop))
			_mi.scale = Vector3(1.0, 1.0, 1.0 + 0.35 * exp(-t * 20.0))
			_face_along()
		Kind.ORB:
			var k := t - _delay
			if k < 0.0:
				_mat.set_shader_parameter("fade", 0.0)
				return
			var span := life - _delay
			_mat.set_shader_parameter("pulse", exp(-k * 9.0))
			_mat.set_shader_parameter("arcs", _ease_out(clampf(k / (span * 0.6), 0.0, 1.0)))
			_mat.set_shader_parameter("fade", (1.0 - smoothstep(span * 0.45, span, k)) * minf(1.0, k / 0.02 + 0.3))
			if fmod(k, 0.05) < get_process_delta_time():
				_mat.set_shader_parameter("seed", randf() * 50.0)
			_mi.scale = Vector3.ONE * (0.6 + 0.6 * _ease_out(clampf(k / 0.08, 0.0, 1.0)))
			_face_camera()
		Kind.SCORCH:
			_mat.set_shader_parameter("wave", _ease_out(clampf(t / 0.22, 0.0, 1.0)) * 0.95)
			_mat.set_shader_parameter("spread", _ease_out(clampf(t / 0.08, 0.0, 1.0)))
			_mat.set_shader_parameter("cool", clampf((t - 0.12) / 0.6, 0.0, 1.0))
			_mat.set_shader_parameter("fade", 1.0 - smoothstep(life * 0.6, life, t))


static func _ease_out(x: float) -> float:
	return 1.0 - pow(1.0 - x, 3.0)
