extends Node
## WaveDirector: 웨이브별 출현 예약과 두 숲길 출현 지점.
## 웨이브 종료 = 출현 예약이 모두 끝나고 살아 있는 적이 0명.

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")

var game
var active := false
var time := 0.0
var groups: Array = []
var next_group := 0
var targets: Array = []
var spawn_index := 0
var total := 0
var wave_hp := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	name = "WaveDirector"
	_rng.randomize()


func start_wave(n: int) -> void:
	var cfg: Dictionary = Cfg.WAVES[n - 1]
	groups = cfg["groups"]
	wave_hp = cfg["hp"]
	total = cfg["count"]
	var s: int = cfg["sheep"]
	# 양 목표를 출현 순서 전체에 고르게 흩어 두 길에 나눈다
	targets.clear()
	for i in total:
		targets.append(int(floor(float(i + 1) * s / total)) > int(floor(float(i) * s / total)))
	time = 0.0
	next_group = 0
	spawn_index = 0
	active = true
	_spawn_due()


func stop() -> void:
	active = false


func _process(delta: float) -> void:
	if not active:
		return
	time += delta
	_spawn_due()


func _spawn_due() -> void:
	while next_group < groups.size() and time >= float(groups[next_group][0]):
		var c: int = groups[next_group][1]
		for k in c:
			_spawn(k)
		next_group += 1


func _spawn(k: int) -> void:
	var on_b := spawn_index % 2 == 1
	var base: Vector3 = Layout.SPAWN_B if on_b else Layout.SPAWN_A
	var path: Array = Layout.PATH_B if on_b else Layout.PATH_A
	var prev: Vector2 = path[path.size() - 2]
	var back := (Vector2(base.x, base.z) - prev).normalized()
	var side := Vector2(-back.y, back.x)
	var off := back * (k * 0.9) + side * _rng.randf_range(-0.9, 0.9)
	var m := MonsterScript.new()
	m.setup(game, wave_hp, targets[spawn_index])
	m.position = base + Vector3(off.x, 0, off.y)
	game.actors.add_child(m)
	spawn_index += 1


func pending() -> int:
	return total - spawn_index if active else 0


func alive() -> int:
	return get_tree().get_nodes_in_group("enemies").size()


func is_wave_done() -> bool:
	return active and pending() == 0 and alive() == 0
