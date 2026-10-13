extends Node3D
## 마녀의 단발 마법 투사체. 대상이 이미 죽었으면 피해 없이 사라진다(중복 피해 방지).

const Cfg := preload("res://scripts/config.gd")
const B := preload("res://scripts/visual/build.gd")
const Mats := preload("res://scripts/visual/mats.gd")
const Fx := preload("res://scripts/visual/fx.gd")

var target = null
var damage := Cfg.BOLT_DAMAGE
var speed := Cfg.BOLT_SPEED


func _ready() -> void:
	var core := B.sphere(self, 0.11, Vector3.ZERO, Mats.glow(Color(0.85, 0.6, 1.0), 6.0), Vector3.ONE, 8, 4)
	core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	B.omni(self, Vector3.ZERO, Color(0.8, 0.55, 1.0), 1.2, 2.5, false, 1.2)


func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target) or target.dead:
		queue_free()
		return
	var aim: Vector3 = target.global_position + Vector3(0, 0.65, 0)
	var to := aim - global_position
	var step := speed * delta
	if to.length() <= step + 0.15:
		target.take_damage(damage)
		Fx.burst(get_parent(), aim, Color(0.85, 0.6, 1.0), 10, 2.5, 0.16, 0.4, true, -2.0)
		queue_free()
		return
	global_position += to.normalized() * step
