extends SceneTree
## 배경음악 믹싱 검증: 전투 전환 시간·속도, 새벽 전환, 동등 전력(총 음량 유지), 곡 끝→처음 겹침, 낮 곡 무작위, 곡별 음량 보정.
## 실행: godot --headless --path . --script res://tools/verify_bgm_mix.gd
const DT := 1.0 / 60.0
var bank
var game
var results: Array = []

func _initialize() -> void:
	call_deferred("run")

func check(label: String, ok: bool, detail := "") -> void:
	results.append(ok)
	print(("PASS " if ok else "FAIL ") + label + ("  — " + detail if detail != "" else ""))

func frames(n: int) -> void:
	for i in n: await process_frame

func w(ev: String) -> float:
	var d: Dictionary = bank._decks.get(ev, {})
	if d.is_empty(): return 0.0
	var tot := 0.0
	for k in ["a", "b"]:
		var p: AudioStreamPlayer = d[k]
		tot += db_to_linear(p.volume_db - bank.gains[ev] - float((d["stream"] as AudioStream).get_meta("trim_db", 0.0)))
	return tot

## 고정 간격으로 n초 동안 믹서를 돌리며 각 음악 무게를 기록
func run_mix(seconds: float, progress: float) -> Array:
	var rows: Array = []
	for i in int(seconds / DT):
		bank.update_background(progress, DT)
		rows.append({"f": w("bgm_field"), "e": w("bgm_evening"), "c": w("bgm_combat")})
	return rows

func trims_of(ev: String) -> Array:
	var out: Array = []
	for s in bank.streams.get(ev, []): out.append(float(s.get_meta("trim_db", 0.0)))
	out.sort()
	return out

func trims_match(ev: String, expected: Array) -> bool:
	var got := trims_of(ev)
	if got.size() != expected.size(): return false
	for i in got.size():
		if absf(got[i] - expected[i]) > 0.01: return false
	return true

func max_rate(rows: Array, key: String) -> float:
	var m := 0.0
	for i in range(1, rows.size()): m = maxf(m, absf(rows[i][key] - rows[i - 1][key]) / DT)
	return m

func run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await frames(30)
	game = current_scene
	bank = game.sounds
	bank.set_process(false)                 # 믹서는 검증이 직접 고정 간격으로 돌린다
	game.session.process_mode = Node.PROCESS_MODE_DISABLED  # 상태는 검증이 정한다
	paused = false
	check("낮 곡 파일 2개 로드", bank.streams.has("bgm_field") and bank.streams["bgm_field"].size() == 2, str(bank.streams.get("bgm_field", []).size()))
	check("낮 곡 음량 보정(-6.3/-4.7dB, RandomMind CC0) 적용", trims_match("bgm_field", [-6.3, -4.7]), str(trims_of("bgm_field")))
	check("전투 곡 파일 2개 로드", bank.streams.has("bgm_combat") and bank.streams["bgm_combat"].size() == 2, str(bank.streams.get("bgm_combat", []).size()))
	check("전투 곡 음량 보정(-2.7/-1.7dB) 적용", trims_match("bgm_combat", [-2.7, -1.7]), str(trims_of("bgm_combat")))

	# 낮에서 시작
	game.session.state = 0
	var rows := run_mix(2.0, 0.1)
	check("낮: 낮 곡만 들림", rows[-1]["f"] > 0.95 and rows[-1]["c"] < 0.02 and rows[-1]["e"] < 0.02, str(rows[-1]))
	# 저녁으로(진행도에 따라)
	rows = run_mix(12.0, 0.9)
	check("저녁: 저녁 곡으로 넘어감", rows[-1]["e"] > 0.95 and rows[-1]["f"] < 0.05, str(rows[-1]))
	check("낮→저녁 전환 속도 완만(초당 0.25 이하)", max_rate(rows, "e") <= 0.25, "%.3f/s" % max_rate(rows, "e"))
	# 밤 웨이브 시작
	game.session.state = 1
	rows = run_mix(10.0, 0.95)
	var reach := -1.0
	for i in rows.size():
		if rows[i]["c"] >= 0.99: reach = i * DT; break
	check("전투 곡으로 6초 안팎에 걸쳐 넘어감(5~7초)", reach >= 5.0 and reach <= 7.0, "%.2fs" % reach)
	check("전투 진입 속도 완만(초당 0.3 이하)", max_rate(rows, "c") <= 0.3, "%.3f/s" % max_rate(rows, "c"))
	var power_ok := true
	var worst := 1.0
	for r in rows:
		var pw: float = r["f"] * r["f"] + r["e"] * r["e"] + r["c"] * r["c"]
		worst = minf(worst, pw)
		if absf(pw - 1.0) > 0.06: power_ok = false
	check("전환 중 총 음량 유지(동등 전력 ±6%)", power_ok, "최소 %.3f" % worst)
	check("전투 곡은 시작할 때 처음부터", bank._decks["bgm_combat"]["xf"] == 0.0)
	# 웨이브 끝 → 새벽(진행도 0으로 되돌아감)
	game.session.state = 0
	rows = run_mix(14.0, 0.02)
	var reach_out := -1.0
	for i in rows.size():
		if rows[i]["c"] <= 0.01: reach_out = i * DT; break
	check("전투 곡이 10초 안팎에 걸쳐 물러남(8~12초)", reach_out >= 8.0 and reach_out <= 12.0, "%.2fs" % reach_out)
	check("새벽: 저녁 곡이 한 번에 끊기지 않음(초당 0.25 이하)", max_rate(rows, "e") <= 0.25, "%.3f/s" % max_rate(rows, "e"))
	check("새벽 뒤 낮 곡으로 돌아옴", rows[-1]["f"] > 0.9, str(rows[-1]))
	# 곡 끝→처음 겹침: 다음 회차를 강제로 시작한 상태에서 4초 동안 넘어감
	var d: Dictionary = bank._decks["bgm_field"]
	var before: String = d["cur"]
	d[("b" if before == "a" else "a")].play(0.0)
	d["xf"] = 0.0001
	var mid := {}
	for i in int(4.5 / DT):
		bank.update_background(0.02, DT)
		if i == int(2.0 / DT):
			var a: AudioStreamPlayer = d["a"]
			var b: AudioStreamPlayer = d["b"]
			mid = {"a": db_to_linear(a.volume_db - bank.gains["bgm_field"]), "b": db_to_linear(b.volume_db - bank.gains["bgm_field"])}
	check("곡 끝→처음 4초 겹친 뒤 다음 회차로 넘어감", d["cur"] != before and d["xf"] == 0.0, "cur=%s" % d["cur"])
	var trim: float = db_to_linear(float((d["stream"] as AudioStream).get_meta("trim_db", 0.0)))
	var pa: float = mid.get("a", 0.0) / trim
	var pb: float = mid.get("b", 0.0) / trim
	check("겹치는 중간에 두 회차가 함께 들림(총 음량 유지)", absf(pa * pa + pb * pb - 1.0) < 0.08 and pa > 0.3 and pb > 0.3, "a=%.2f b=%.2f" % [pa, pb])
	# 낮 곡 무작위: 날이 바뀔 때마다(낮 곡이 들리지 않는 밤에) 고른다
	var seen := {}
	for i in 40:
		bank._field_day = -100 - i
		bank.combat_mix = 1.0
		bank.update_background(0.95, 0.0)
		seen[bank._decks["bgm_field"]["stream"]] = true
	check("낮 곡 두 곡 모두 무작위로 골림(40번)", seen.size() == 2, "%d가지" % seen.size())
	# 전투 곡 무작위: 전투가 시작될 때마다 직전과 다른 곡을 골라 처음부터
	var combat_seen := {}
	var repeated := false
	var from_start := true
	var prev: AudioStream = null
	for i in 40:
		bank.combat_mix = 0.0
		game.session.state = 1
		bank.update_background(0.95, DT)
		var d2: Dictionary = bank._decks["bgm_combat"]
		combat_seen[d2["stream"]] = true
		if prev != null and d2["stream"] == prev: repeated = true
		if d2["xf"] != 0.0 or d2["cur"] != "a": from_start = false
		prev = d2["stream"]
	game.session.state = 0
	check("전투 곡 두 곡 모두 무작위로 골림(40번)", combat_seen.size() == 2, "%d가지" % combat_seen.size())
	check("전투 곡은 직전과 다른 곡으로 바뀜", not repeated)
	check("전투 곡은 매번 처음부터", from_start)
	var passed := results.count(true)
	print("RESULT %d/%d" % [passed, results.size()])
	quit(0 if passed == results.size() else 1)
