extends SceneTree
## 캐릭터끼리 부드러운 밀어내기(scripts/actors/soft_separation.gd) 헤드리스 검증:
## 겹치면 순간이동 없이 천천히 떨어지는지, 속도 상한, 같은 자리 겹침, 무게 비율, 비활성 제외, 무리 퍼짐,
## 모든 액터 스크립트가 등록·적용하는지.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_soft_separation.gd

const SoftSep := preload("res://scripts/actors/soft_separation.gd")
const DT := 1.0 / 60.0

var passed := 0
var total := 0


func _initialize() -> void:
	call_deferred("_run")


func check(label: String, ok: bool, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print(("PASS " if ok else "FAIL ") + label + ("  — " + detail if detail != "" else ""))


func _body(pos: Vector3, r := 0.3, w := 1.0) -> Node3D:
	var n := Node3D.new()
	root.add_child(n)
	n.global_position = pos
	SoftSep.register(n, r, w)
	return n


func _clear() -> void:
	for n in root.get_children():
		n.free()


## 모든 등록 액터를 동시에 한 틱 민다(각자 move_and_slide 하는 것과 같은 순서 독립 갱신). 최대 속도를 돌려준다.
func _step(nodes: Array) -> float:
	var vels := []
	var top := 0.0
	for n: Node3D in nodes:
		var v := SoftSep.push(n)
		top = maxf(top, v.length())
		vels.append(v)
	for i in nodes.size():
		nodes[i].global_position += vels[i] * DT
	return top


func _run() -> void:
	# 1) 같은 무게 두 캐릭터가 깊게 겹침 → 바로 튕기지 않고 천천히, 결국 떨어진다
	var a := _body(Vector3(0, 0, 0))
	var b := _body(Vector3(0.1, 0, 0))
	var top := 0.0
	for i in 6:   # 0.1초
		top = maxf(top, _step([a, b]))
	var d01 := a.global_position.distance_to(b.global_position)
	check("0.1초 뒤에도 아직 겹쳐 있다(순간 분리 아님)", d01 < 0.5, "d=%.3f" % d01)
	for i in 180:   # +3초
		top = maxf(top, _step([a, b]))
	var d3 := a.global_position.distance_to(b.global_position)
	check("3초 뒤 개인 영역 거의 회복(≥0.6-여유)", d3 >= 0.6 - SoftSep.SLACK - 0.03, "d=%.3f" % d3)
	check("밀어내기 속도는 상한(%.1fm/s) 이하" % SoftSep.MAX_SPEED, top <= SoftSep.MAX_SPEED + 0.0001, "max=%.3f" % top)
	check("같은 무게는 대칭으로 비켜 난다", absf(a.global_position.x + b.global_position.x - 0.1) < 0.01,
		"a=%.3f b=%.3f" % [a.global_position.x, b.global_position.x])
	check("떨어진 뒤엔 더 밀지 않는다(멈춰서 떨지 않음)", SoftSep.push(a).length() < 0.001)
	_clear()

	# 2) 정확히 같은 자리 → 서로 반대 방향으로 갈라진다
	a = _body(Vector3(1, 0, 1))
	b = _body(Vector3(1, 0, 1))
	var pa := SoftSep.push(a)
	var pb := SoftSep.push(b)
	check("같은 자리 겹침: 두 방향이 반대·0 아님", pa.length() > 0.1 and pa.dot(pb) < -0.99 * pa.length() * pb.length())
	_clear()

	# 3) 무게: 마녀(4) vs 용병(1) → 용병이 4배 더 비켜 난다, 손님(1000)은 거의 상대만 민다
	var witch := _body(Vector3.ZERO, 0.3, 4.0)
	var merc := _body(Vector3(0.5, 0, 0), 0.32, 1.0)   # 얕게 겹쳐 속도 상한에 안 걸리게
	var vw := SoftSep.push(witch).length()
	var vm := SoftSep.push(merc).length()
	check("무거운 마녀는 덜 밀리고 용병이 비켜 난다(비율≈4)", absf(vm / vw - 4.0) < 0.05, "witch=%.3f merc=%.3f" % [vw, vm])
	_body(Vector3(-0.3, 0, 0), 0.3, 1000.0)   # 손님
	check("손님 곁의 마녀는 거의 전부 비켜 난다", SoftSep.push(witch).x > 0.0)
	_clear()

	# 4) 비활성(죽음·산장 안·탑 위·숨김)은 밀지도 밀리지도 않는다
	a = _body(Vector3.ZERO)
	for flag in ["dead", "hidden", "on_tower", "invisible"]:
		var o := _body(Vector3(0.2, 0, 0))
		if flag == "invisible":
			o.visible = false
		else:
			o.set_script(_flag_script(flag))
			SoftSep.register(o, 0.3)
		check("비활성(%s) 상대는 무시" % flag, SoftSep.push(a).length() < 0.0001)
		o.free()
	_clear()

	# 5) 무리: 10명이 한 점에 몰려 있다가 5초 뒤 서로 거의 겹치지 않게 퍼진다(NaN·폭주 없음)
	var crowd := []
	for i in 10:
		crowd.append(_body(Vector3(randf_range(-0.05, 0.05), 0, randf_range(-0.05, 0.05))))
	top = 0.0
	for i in 300:
		top = maxf(top, _step(crowd))
	var worst := 99.0
	var spread := 0.0
	var finite := true
	for i in crowd.size():
		finite = finite and crowd[i].global_position.is_finite()
		spread = maxf(spread, crowd[i].global_position.length())
		for j in range(i + 1, crowd.size()):
			worst = minf(worst, crowd[i].global_position.distance_to(crowd[j].global_position))
	check("무리 퍼짐: 5초 뒤 가장 가까운 쌍 ≥0.45m(살짝 겹침 허용)", worst >= 0.45, "min=%.3f" % worst)
	check("무리 퍼짐: 값 정상·튕겨 나가지 않음(반경<2m)", finite and spread < 2.0 and top <= SoftSep.MAX_SPEED + 0.0001,
		"spread=%.2f max=%.2f" % [spread, top])
	_clear()

	# 6) 액터 스크립트 연결: 모든 캐릭터가 등록하고 이동 틱에 push 를 쓴다
	var actors := ["player", "ally", "monster", "venom_insect", "wild_animal", "goblin_minion", "night_summon", "sheep", "traveler"]
	var missing := []
	for nm in actors:
		var path := "res://scripts/actors/%s.gd" % nm
		var src := FileAccess.get_file_as_string(path)
		var ok: bool = load(path) != null and src.contains("SoftSep.register(")
		if nm != "traveler":   # 손님은 정해진 길을 걷는다: 등록만(남이 비켜 감)
			ok = ok and src.contains("SoftSep.push(self)")
		if not ok:
			missing.append(nm)
	check("액터 9종 모두 스크립트 로드·등록·적용", missing.is_empty(), ", ".join(missing))
	var old := []
	for nm in ["ally", "monster"]:
		if FileAccess.get_file_as_string("res://scripts/actors/%s.gd" % nm).contains("func _separation"):
			old.append(nm)
	check("예전 같은 편끼리만의 밀어내기 제거(이중 적용 없음)", old.is_empty(), ", ".join(old))

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)


func _flag_script(flag: String) -> GDScript:
	var s := GDScript.new()
	s.source_code = "extends Node3D\nvar %s := true\n" % flag
	s.reload()
	return s
