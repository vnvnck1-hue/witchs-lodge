extends SceneTree
## 카드 도감(output/card-gallery.html)용 데이터 추출: 카탈로그 전체 카드마다 게임 툴팁과 같은 낮(준비)·밤(전투) 사용 안내를 뽑는다.
## 게임을 헤드리스로 띄워 CardHand._usage_text 를 그대로 부르므로 문구가 게임과 어긋나지 않는다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/export_card_gallery.gd -- --out=output/card-gallery-data.json
## 이어서: python tools/build_card_gallery.py

const Cfg := preload("res://scripts/config.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")

var out_path := "../output/card-gallery-data.json"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_path = "../" + a.trim_prefix("--out=")
	create_timer(90.0, true, false, true).timeout.connect(func():
		print("FAIL 시간 초과")
		quit(1))
	change_scene_to_file("res://scenes/main.tscn")
	call_deferred("_run")


func _run() -> void:
	while current_scene == null or current_scene.get("cards") == null or current_scene.get("hud") == null:
		await process_frame
	var game = current_scene
	for i in 10:
		await process_frame
	var hand = game.hud.card_hand
	# 마법서·독버섯은 주머니가 비어 있으면 '쓸 수 없음'이 나오므로 주머니에 한 장 넣어 둔다.
	game.cards.add("timber", 1, "", "pocket")
	var cards: Array = []
	for d in Catalog.read().get("cards", []):
		var id: String = d["id"]
		var e := {"id": id, "count": 1}
		game.session.state = SessionScript.State.PREP
		var prep: String = hand._usage_text(e)
		game.session.state = SessionScript.State.COMBAT
		var combat: String = hand._usage_text(e)
		var item: Dictionary = d.duplicate(true)
		item["prep"] = prep
		item["combat"] = combat
		item["relic"] = Cfg.RELIC_DESC.get(id, "")
		cards.append(item)
	game.session.state = SessionScript.State.PREP
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	f.store_string(JSON.stringify({"cards": cards}, "\t"))
	f.close()
	print("WROTE %d cards → %s" % [cards.size(), out_path])
	quit(0)
