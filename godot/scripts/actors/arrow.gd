extends Node3D
## 사냥꾼의 화살: 대상(적 또는 야생 동물)을 향해 날아가 맞힌다. 대상이 이미 죽었으면 땅에 떨어진다.
## 동물을 맞히기 전에 last_hunter를 남겨, 쓰러진 동물의 전리품이 쏜 사냥꾼에게 간다.

const Cfg := preload("res://scripts/config.gd")
const B := preload("res://scripts/visual/build.gd")
const Mats := preload("res://scripts/visual/mats.gd")
const Fx := preload("res://scripts/visual/fx.gd")
const Sfx := preload("res://scripts/audio/sfx.gd")

var target = null
var shooter = null
var damage := Cfg.HUNTER_DAMAGE
var speed := Cfg.ARROW_SPEED
var _vel := Vector3.ZERO
var _shaft: Node3D


func _ready() -> void:
	_shaft = B.node(self, Vector3.ZERO, Vector3.ZERO, "Shaft")
	B.cyl(_shaft, 0.012, 0.012, 0.55, Vector3(0, 0, 0), Mats.solid(Color("d8d2c0")), 5, Vector3(90, 0, 0))
	B.cyl(_shaft, 0.0, 0.03, 0.08, Vector3(0, 0, 0.3), Mats.solid(Color("aeb4c4")), 5, Vector3(90, 0, 0))
	B.box(_shaft, Vector3(0.06, 0.012, 0.08), Vector3(0, 0, -0.25), Mats.solid(Color("c9565a")))
	for c in _shaft.get_children():
		if c is GeometryInstance3D:
			c.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target) or target.dead:
		Fx.poof(global_position, Color(0.8, 0.75, 0.6), 0.25)
		queue_free()
		return
	var aim: Vector3 = target.global_position + Vector3(0, float(target.get("hp_offset")) * 0.45 if target.get("hp_offset") != null else 0.6, 0)
	var to := aim - global_position
	var step := speed * delta
	if to.length() <= step + 0.15:
		if target.is_in_group("animals") and shooter != null:
			target.last_hunter = shooter
		target.take_damage(damage)
		Fx.hit(aim, Color(1.0, 0.9, 0.7))
		Sfx.play_or(self, "arrow_hit", "bolt_hit")
		queue_free()
		return
	_vel = to.normalized() * speed
	global_position += _vel * delta
	if _vel.length() > 0.01:
		look_at(global_position + _vel, Vector3.UP)
