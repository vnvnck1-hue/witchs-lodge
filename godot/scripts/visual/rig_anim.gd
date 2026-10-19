extends Node
## 파츠 묶음 캐릭터(Tripo Segment → tools/tripo_character_ingest.gd)의 절차적 애니메이션.
## 묶음 피벗(meta part_group: torso·head·arm_r·arm_l·leg_r·leg_l·backpack·cape·lantern)을 돌려 움직인다.
## 상태: walk(걷기) · idle(서 있기) · greet(문 앞 인사) · wave(떠나며 손 흔들기)
##       windup(지팡이 공격 준비, amount 0→1) · cast(마법 발사) · work(양털 깎기) · hurt(괴로워 움츠림).
## 수치는 style 사전(character_models.gd)에서 캐릭터 성격에 맞게 고친다. 게임 판정·이동에는 관여하지 않는다.

var state := "idle"
var amount := 0.0               # windup 진행도 등 상태별 입력(0~1)
var style: Dictionary = {}
var pivots: Dictionary = {}     # 묶음 → Node3D
var _rest: Dictionary = {}      # 묶음 → 기본 위치
var _t := 0.0                   # 상태 안 경과 시간
var _phase := 0.0               # 걸음 위상
var _swing := 0.0               # 등불·망토의 출렁임(걷기 속도를 따라 천천히 오르내림)


func setup(root: Node3D, style_: Dictionary) -> void:
	style = style_
	for n in root.find_children("*", "Node3D", true, false):
		if n.has_meta("part_group"):
			pivots[str(n.get_meta("part_group"))] = n
			_rest[str(n.get_meta("part_group"))] = (n as Node3D).position


func play(next: String) -> void:
	if next == state: return
	state = next
	_t = 0.0


func _s(key: String, fallback: float) -> float:
	return float(style.get(key, fallback))


func _rot(group: String, deg: Vector3) -> void:
	if pivots.has(group): pivots[group].rotation_degrees = deg


func _lift(group: String, y: float) -> void:
	if pivots.has(group): pivots[group].position = _rest[group] + Vector3(0, y, 0)


func _process(delta: float) -> void:
	_t += delta
	_swing = move_toward(_swing, 1.0 if state in ["walk", "wave"] else 0.0, delta * 2.5)
	match state:
		"walk": _walk(delta)
		"greet": _greet()
		"wave": _walk(delta); _wave_arm()
		"windup": _windup()
		"cast": _cast()
		"work": _work()
		"hurt": _hurt()
		_: _idle()
	_secondary(delta)


func _walk(delta: float) -> void:
	_phase += delta * _s("walk_freq", 9.0)
	var s := sin(_phase)
	var hop := absf(s)
	var leg := _s("leg_swing", 30.0)
	var arm := _s("arm_swing", 24.0)
	var staff_arm := _s("staff_arm_swing", arm)   # 지팡이를 쥔 왼팔은 덜 흔든다
	_lift("torso", hop * _s("walk_bounce", 0.045))
	_rot("torso", Vector3(_s("walk_lean", 6.0), 0, s * _s("walk_roll", 4.0)))
	_rot("leg_r", Vector3(s * leg, 0, 0))
	_rot("leg_l", Vector3(-s * leg, 0, 0))
	_rot("arm_r", Vector3(-s * arm, 0, -8))
	_rot("arm_l", Vector3(s * staff_arm + _s("staff_arm_x", 0.0), 0, 8))
	_rot("head", Vector3(-hop * _s("head_bob", 5.0), sin(_phase * 0.5) * _s("head_look", 6.0), -s * 3.0))
	# 무거운 등짐은 반 박자 늦게 출렁인다.
	_rot("backpack", Vector3(sin(_phase - 1.2) * _s("pack_sway", 7.0), 0, sin(_phase * 0.5 - 1.0) * 3.0))


func _idle() -> void:
	var b := sin(_t * 2.2)
	_lift("torso", 0.0)
	_rot("torso", Vector3(b * 1.5, 0, 0))
	_rot("leg_r", Vector3.ZERO)
	_rot("leg_l", Vector3.ZERO)
	_rot("arm_r", Vector3(0, 0, -6 - b * 2.0))
	_rot("arm_l", Vector3(_s("staff_arm_x", 0.0), 0, 6 + b * 2.0))
	# 고개 돌리기: 니브는 두리번(넓고 잦게), 마녀는 가끔 천천히 주변을 살핀다.
	var look := sin(_t * _s("idle_look_freq", 0.7))
	_rot("head", Vector3(-b * 2.0, look * _s("idle_look", 18.0), 0))
	_rot("backpack", Vector3(b * 1.5, 0, 0))


## 흥정꾼 인사: 한 손을 내밀어 손가락을 비비고(값 얘기), 고개를 갸웃하며 깡충 뛴다.
func _greet() -> void:
	var t := _t
	var rub := sin(t * 22.0)
	var hop := maxf(0.0, sin(t * 7.0))
	var up := clampf(t / 0.25, 0.0, 1.0)
	_lift("torso", hop * 0.035)
	_rot("torso", Vector3(-4.0 * up, 0, 0))
	_rot("arm_r", Vector3(-75.0 * up + rub * 6.0, 0, -18.0 + rub * 5.0))
	_rot("arm_l", Vector3(-20.0 * up, 0, 30.0 * up))
	_rot("head", Vector3(-6.0 * up, 12.0 * up, 14.0 * up + sin(t * 5.0) * 4.0))
	_rot("leg_r", Vector3(-hop * 10.0, 0, 0))
	_rot("leg_l", Vector3(hop * 6.0, 0, 0))
	_rot("backpack", Vector3(hop * 6.0, 0, 0))


## 떠나며 뒤돌아 손 흔들기(걷기와 겹친다).
func _wave_arm() -> void:
	# 큰 귀·머리에 가리지 않도록 머리 위가 아니라 바깥 비스듬히 앞으로 들어 흔든다.
	_rot("arm_l", Vector3(-35, 0, 95 + sin(_t * 14.0) * 22.0))
	_rot("head", Vector3(0, -20, 8))


## 공격 준비: 지팡이 팔을 앞으로 들어 올리고 대상을 똑바로 본다(침착하게, 몸은 거의 그대로).
func _windup() -> void:
	var k := clampf(amount, 0.0, 1.0)
	_lift("torso", 0.0)
	_rot("torso", Vector3(-4.0 * k, 0, 0))
	_rot("leg_r", Vector3(-6.0 * k, 0, 0))
	_rot("leg_l", Vector3(6.0 * k, 0, 0))
	_rot("arm_l", Vector3(_s("staff_arm_x", 0.0) - 55.0 * k, 0, 10.0 + 10.0 * k))
	_rot("arm_r", Vector3(-10.0 * k, 0, -14.0 - 10.0 * k))
	_rot("head", Vector3(6.0 * k, 0, 0))


## 발사: 지팡이 팔을 짧게 앞으로 내지르고 돌아온다(0.3초).
func _cast() -> void:
	var p := sin(clampf(_t / 0.3, 0.0, 1.0) * PI)
	_rot("torso", Vector3(5.0 * p, 0, 0))
	_rot("arm_l", Vector3(_s("staff_arm_x", 0.0) - 55.0 - 30.0 * p, 0, 18.0))
	_rot("arm_r", Vector3(0, 0, -20.0 - 10.0 * p))
	_rot("head", Vector3(4.0 * p, 0, 0))
	_rot("cape", Vector3(-18.0 * p, 0, 0))


## 양털 깎기: 오른손(가위)을 앞으로 내밀어 빠르게 여닫고, 고개를 숙여 손끝을 본다.
func _work() -> void:
	var snip := sin(_t * 18.0)
	_rot("arm_r", Vector3(-60.0 + snip * 6.0, 0, -12.0))
	_rot("arm_l", Vector3(-15.0, 0, 18.0))
	_rot("head", Vector3(16.0, -8.0, 0))
	_rot("leg_r", Vector3(-8.0, 0, 0))
	_rot("leg_l", Vector3(8.0, 0, 0))


## 괴로움(늑대의 피 등): 두 팔로 몸을 감싸고 고개를 숙이며 떤다. 몸 전체 흔들림은 플레이어 쪽이 맡는다.
func _hurt() -> void:
	var shake := sin(_t * 40.0) * 4.0
	_rot("arm_r", Vector3(-40.0 + shake, 25.0, -5.0))
	_rot("arm_l", Vector3(-40.0 - shake, -25.0, 5.0))
	_rot("head", Vector3(22.0, shake, 0))


## 등불·망토: 걸을 때 반 박자 늦게 흔들리고, 서 있으면 천천히 잦아든다(모든 상태에 겹친다).
func _secondary(_delta: float) -> void:
	if state == "cast": return
	var sway := sin(_phase - 1.4) * _swing
	_rot("lantern", Vector3(sway * _s("lantern_sway", 14.0) + sin(_t * 1.6) * 2.0, 0, sin(_phase * 0.5 - 0.8) * _swing * 6.0))
	_rot("cape", Vector3(-_swing * _s("cape_flutter", 10.0) + sin(_phase * 2.0) * _swing * 3.0 + sin(_t * 1.3) * 1.0, 0, 0))
