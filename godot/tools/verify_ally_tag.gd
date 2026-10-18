extends SceneTree
## 용병 머리 위 문구가 '이름 · 짧은 상태'로 간결한지 검증한다(직업 이름·긴 설명 없음).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_ally_tag.gd

const Cfg := preload("res://scripts/config.gd")
const AllyScript := preload("res://scripts/actors/ally.gd")
const HudScript := preload("res://scripts/ui/hud.gd")

var failures := 0
var total := 0


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func _initialize() -> void:
	var a = AllyScript.new()
	a.kind = "merc"
	a.person = "한스"
	a.job = "lumberjack"
	a.state = AllyScript.State.IDLE
	a.carry = {"timber": Cfg.LUMBERJACK_CARRY}
	var tag: String = HudScript.HpOverlay.ally_tag_text(a)
	check("목재 가득: 이름 · 짧은 상태", tag == "한스 · 목재 가득", tag)
	check("직업 이름(괄호) 없음", not tag.contains("("), tag)
	check("긴 설명은 명부용 status_text에만", a.status_text().length() > a.short_status().length(), a.status_text())

	a.job = "gatherer"
	a.carry = {"herb": 2}
	a.state = AllyScript.State.GATHER_OUT
	a.gather_index = 0
	a.gather_stops = [Vector3.ZERO, Vector3.ONE, Vector3.ONE * 2.0]
	tag = HudScript.HpOverlay.ally_tag_text(a)
	check("채집: 진행·짐 수 짧게", tag == "한스 · 채집 1/3 · 짐2", tag)

	a.carry = {}
	a.state = AllyScript.State.ENGAGE
	tag = HudScript.HpOverlay.ally_tag_text(a)
	check("전투: 한 단어", tag == "한스 · 전투", tag)

	var longest := 0
	for s in [AllyScript.State.GO_WORK, AllyScript.State.PATROL, AllyScript.State.HUNT, AllyScript.State.GATHER_PICK,
			AllyScript.State.GATHER_RETURN, AllyScript.State.TOWER_GO, AllyScript.State.TOWER_POST, AllyScript.State.GO_HIDE]:
		a.state = s
		longest = maxi(longest, a.short_status().length())
	check("짧은 상태는 모두 4자 이내", longest <= 4, str(longest))

	a.kind = "minion"
	a.person = ""
	a.state = AllyScript.State.ENGAGE
	tag = HudScript.HpOverlay.ally_tag_text(a)
	check("숲의 괴물 하수인은 종류 이름", tag == "숲의 괴물 · 전투", tag)
	a.free()

	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
