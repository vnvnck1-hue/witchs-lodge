extends Node3D
## 용의 숨결(주점 카드 dragon_breath): 던진 자리에 불바다 장판이 TIME초 동안 번져, 반경 안의 적에게 TICK 간격으로 피해를 준다.
## 수치는 tavern_cards 가 넘긴다. 판정만 여기서 하고 모양은 TavernVfx 가 만든다.

const TavernVfx := preload("res://scripts/visual/vfx/tavern_drink_vfx.gd")
const Sfx := preload("res://scripts/audio/sfx.gd")

const TICK := 0.5

var game
var radius := 3.0
var dps := 8.0
var time_left := 6.0
var hits := 0
var _tick := 0.0
var _look: Dictionary = {}


func _ready() -> void:
	add_to_group("dragon_breath_fires")
	_look = TavernVfx.fire_pool(self, radius)
	Sfx.play(self, "dragon_fire")


func _process(delta: float) -> void:
	time_left -= delta
	_tick -= delta
	if _tick <= 0.0 and time_left > 0.0:
		_tick += TICK
		for e in get_tree().get_nodes_in_group("enemies"):
			if e.dead:
				continue
			if Vector2(e.global_position.x - global_position.x, e.global_position.z - global_position.z).length() <= radius:
				e.take_damage(dps * TICK)
				hits += 1
	TavernVfx.tick_fire_pool(_look, delta, time_left)
	if time_left <= 0.0:
		queue_free()
