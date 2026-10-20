extends SceneTree
## 카드 질감 프리셋(F9, scripts/ui/card_feel.gd) 헤드리스 검증: 기존 값이 그대로인지, 단단한 두 프리셋이 차례로 덜 일렁이는지.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_card_feel.gd

const Catalog := preload("res://scripts/ui/card_catalog.gd")
const CardView := preload("res://scripts/ui/card_view.gd")
const CardFeel := preload("res://scripts/ui/card_feel.gd")

var passed := 0
var total := 0


func _check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print("%s %s%s" % ["PASS" if ok else "FAIL", label, ("  — " + detail) if detail != "" else ""])


## 한 프리셋에서 카드를 둥실 띄운 채 좌우로 크게 끌어 보고, 휨·비틀림·물결·넘침의 최대치를 잰다.
func _measure(id: String) -> Dictionary:
	CardFeel.apply(id)
	var v := CardView.new()
	root.add_child(v)
	v.setup("timber", Catalog.texture("timber"))
	v.resize(Vector2(160, 240))
	v.snap(Vector2(400, 600))
	v._seed = 1.0
	v.t_float = 1.0
	var m := {"bend": 0.0, "twist": 0.0, "flutter": 0.0, "idle_yaw": 0.0, "overshoot": 0.0}
	# 가만히 둥실 떠 있을 때(2초)
	for i in 120:
		v.step(1.0 / 60.0)
		m["idle_yaw"] = maxf(m["idle_yaw"], absf(v.warp["yaw"]))
	# 오른쪽으로 600px 휙 옮겼다가 멈출 때(2초): 위치가 목표를 넘는 정도도 잰다
	v.t_pos = Vector2(1000, 600)
	for i in 120:
		v.step(1.0 / 60.0)
		m["bend"] = maxf(m["bend"], absf(v.warp["bend"].x) + absf(v.warp["bend"].y))
		m["twist"] = maxf(m["twist"], absf(v.warp["twist"]))
		m["flutter"] = maxf(m["flutter"], v.warp["flutter"])
		m["overshoot"] = maxf(m["overshoot"], v.pos.x - 1000.0)
	v.queue_free()
	return m


func _initialize() -> void:
	_check(CardFeel.IDS == ["magic", "firm", "solid"] and CardFeel.DEFAULT_ID == "magic", "프리셋 3개, 기본은 기존(magic)")
	var mg: Dictionary = CardFeel.PROFILES["magic"]
	var same := float(mg["warp_z"]) == CardView.WARP_Z and float(mg["spring"]) == 0.0
	for k in ["motion", "bend", "float", "flutter", "magic"]:
		same = same and float(mg[k]) == 1.0
	_check(same, "기존 프리셋은 원래 값 그대로(배율 1, 휨 감쇠 = WARP_Z, 스프링 그대로)")
	var r := {}
	for id in CardFeel.IDS:
		r[id] = _measure(id)
		print("  %s: %s" % [id, str(r[id])])
	for k in ["bend", "twist", "flutter", "idle_yaw", "overshoot"]:
		var a: float = r["magic"][k]
		var b: float = r["firm"][k]
		var c: float = r["solid"][k]
		_check(a > b and b > c, "%s 이 기존 > 단단하게 > 아주 단단하게" % k, "%.4f > %.4f > %.4f" % [a, b, c])
	_check(r["solid"]["bend"] < r["magic"]["bend"] * 0.6, "아주 단단하게는 휨이 기존의 60% 미만")
	# 뽑기 연출의 핑그르 회전(yaw)은 모든 프리셋에서 같다(판처럼 도는 동작은 남긴다)
	var spins := []
	for id in CardFeel.IDS:
		CardFeel.apply(id)
		var v := CardView.new()
		root.add_child(v)
		v.setup("timber", Catalog.texture("timber"))
		v.resize(Vector2(160, 240))
		v.snap(Vector2(400, 600))
		v.flourish("draw")
		for i in 20:
			v.step(1.0 / 60.0)
		spins.append(v.warp["yaw"])
		v.queue_free()
	_check(absf(spins[0] - spins[2]) < 0.05, "뽑기 연출 회전은 프리셋과 무관하게 유지", str(spins))
	# 저장·불러오기(검증용 별도 파일)
	var node := CardFeel.new()
	node.settings_path = "user://verify_card_feel.cfg"
	root.add_child(node)
	CardFeel.apply("magic")
	_check(node.cycle() == "firm" and node.cycle() == "solid" and node.cycle() == "magic", "F9 순환: 기존 → 단단하게 → 아주 단단하게 → 기존")
	node.set_feel("solid")
	var cfg := ConfigFile.new()
	_check(cfg.load(node.settings_path) == OK and cfg.get_value("cards", "feel", "") == "solid", "선택이 settings [cards] feel 에 저장됨")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(node.settings_path))
	CardFeel.apply("magic")
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
