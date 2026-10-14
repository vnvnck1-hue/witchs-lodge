extends Node3D
## 마녀의 단발 마법 투사체. 대상이 이미 죽었으면 피해 없이 사라진다(중복 피해 방지).
## 연출: 흰 심지의 보랏빛 혜성 머리 + 리본 꼬리 + 흩날리는 반짝이(표시 전용).

const Cfg := preload("res://scripts/config.gd")
const B := preload("res://scripts/visual/build.gd")
const Mats := preload("res://scripts/visual/mats.gd")
const Fx := preload("res://scripts/visual/fx.gd")
const Ribbon := preload("res://scripts/visual/vfx/ribbon_trail.gd")

var target = null
var damage := Cfg.BOLT_DAMAGE
var speed := Cfg.BOLT_SPEED
var _vel := Vector3.ZERO


func _ready() -> void:
	var core := B.sphere(self, 0.1, Vector3.ZERO, Mats.glow(Color(0.95, 0.8, 1.0), 7.0), Vector3.ONE, 8, 4)
	core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	B.omni(self, Vector3.ZERO, Color(0.8, 0.55, 1.0), 1.4, 2.8, false, 1.2)
	Ribbon.follow(get_parent(), self, Color(0.62, 0.3, 1.0), Color(1.0, 0.9, 1.0), 0.3, 0.3, 1.7)


func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target) or target.dead:
		Fx.poof(global_position, Color(0.75, 0.55, 1.0), 0.35)
		queue_free()
		return
	var aim: Vector3 = target.global_position + Vector3(0, 0.65, 0)
	var to := aim - global_position
	var step := speed * delta
	if to.length() <= step + 0.15:
		target.take_damage(damage)
		Fx.hit(aim, Fx.C_MAGIC)
		queue_free()
		return
	_vel = to.normalized() * speed
	global_position += _vel * delta
	Fx.comet_head(global_position, _vel, Fx.C_MAGIC, 1.5)
