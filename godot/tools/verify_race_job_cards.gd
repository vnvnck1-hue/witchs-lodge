extends SceneTree
## 종족별 직업 계약 카드 검증(docs/handoff/codex-race-job-cards-v01.md): 20장 파일 규격, 인물→종족 카드 선택,
## 인간·이름 풀 밖·미납품 대체, 실제 고용 → 손패·주머니 그림.
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_race_job_cards.gd
const Catalog := preload("res://scripts/ui/card_catalog.gd")
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const Races := preload("res://scripts/game/races.gd")

const RACES := ["dwarf", "fairy", "goblin", "beastfolk", "orc"]

var passed := 0
var total := 0

func check(ok: bool, label: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)

func frames(n := 3) -> void:
	for i in n: await process_frame

## 카드 앞면은 AtlasTexture(card_catalog._face)라 원본 그림 경로는 atlas 쪽에 있다.
func src(t: Texture2D) -> String:
	if t == null: return ""
	return t.atlas.resource_path if t is AtlasTexture else t.resource_path

func corner_clear(tex: Texture2D) -> bool:
	var img := tex.get_image()
	if img.is_compressed(): img.decompress()
	return img.get_pixel(0, 0).a < 0.05 and img.get_pixel(img.get_width() - 1, img.get_height() - 1).a < 0.05

func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): push_error("Race job card verification timeout"); quit(2))
	call_deferred("run")

func run() -> void:
	# 1. 20장 파일
	var delivered := 0
	var ok_size := true
	var ok_alpha := true
	for race in RACES:
		for job in Catalog.RACE_JOB_CARDS:
			var full := Catalog.race_texture_path(job, race, false)
			var hand := Catalog.race_texture_path(job, race, true)
			if not ResourceLoader.exists(full) or not ResourceLoader.exists(hand):
				print("INFO missing " + full)
				continue
			delivered += 1
			var tf: Texture2D = load(full)
			var th: Texture2D = load(hand)
			if tf.get_width() != 1024 or tf.get_height() != 1536 or th.get_width() != 256 or th.get_height() != 384: ok_size = false
			if not corner_clear(tf) or not corner_clear(th): ok_alpha = false
	print("INFO race job cards delivered: %d / 20" % delivered)
	check(delivered == 20, "files: all 20 race job cards exist (game + hand)")
	check(ok_size, "files: 1024x1536 game and 256x384 hand sizes")
	check(ok_alpha, "files: rounded corners are transparent")

	# 2. 인물 → 카드 선택
	var ok_pick := true
	for p in Profiles.all_profiles():
		if not p.hireable: continue
		var job: String = Profiles.job_of(p.person)
		var t: Texture2D = Catalog.texture_for(job, p.person, true)
		var want := Catalog.race_texture_path(job, p.race, true)
		if p.race == "human":
			if t != Catalog.texture(job, true): ok_pick = false
		elif ResourceLoader.exists(want) and (t == null or src(t) != want): ok_pick = false
	check(ok_pick, "pick: each hireable guest's contract card uses that guest's race art")
	check(Catalog.race_texture("warrior", "브람", true) == null, "fallback: human contracts keep the base card")
	check(Catalog.race_texture("warrior", "용병 7", true) == null, "fallback: names outside the roster keep the base card")
	check(Catalog.race_texture("wool", "가로크", true) == null and Catalog.race_texture("warrior", "", true) == null, "fallback: non-job cards and nameless cards are untouched")
	check(Catalog.race_texture_path("warrior", "orc", true) == "res://assets/cards/races/orc/hand/warrior.png", "path convention races/<race>/hand/<job>.png")

	# 3. 실제 게임: 고용한 오크·요정 계약 카드가 손패·주머니에서 종족 그림으로
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(6)
	game.cards.add("warrior", 1, "가로크")
	game.cards.add("hunter", 1, "틸리아", "pocket")
	game.cards.add("warrior", 1, "브람")
	await frames(4)
	var hand = game.hud.card_hand
	var orc_ok := false
	var human_ok := false
	for e in game.cards.hand():
		if not hand.views.has(e.uid): continue
		var tex: Texture2D = hand.views[e.uid].art.texture
		if e.person == "가로크":
			var want := Catalog.race_texture_path("warrior", "orc", true)
			orc_ok = (not ResourceLoader.exists(want)) or src(tex) == want
		if e.person == "브람":
			human_ok = tex != null and not src(tex).contains("/races/")
	check(orc_ok, "game: hired orc warrior shows the orc card in hand")
	check(human_ok, "game: human warrior still shows the base card")
	var pocket_entry: Dictionary = {}
	for e in game.cards.entries:
		if e.person == "틸리아": pocket_entry = e
	var ptex: Texture2D = hand._surface(pocket_entry.id, pocket_entry.person)
	var pwant := Catalog.race_texture_path("hunter", "fairy", true)
	check(not pocket_entry.is_empty() and ((not ResourceLoader.exists(pwant)) or src(ptex) == pwant), "game: fairy hunter in the pocket uses the fairy card")

	# 4. 길드 증서: 직업을 바꾸면 손패의 그 카드가 같은 종족의 새 직업 카드로 통째로 바뀐다
	var orc_e: Dictionary = {}
	var human_e: Dictionary = {}
	for e in game.cards.hand():
		if e.person == "가로크": orc_e = e
		if e.person == "브람": human_e = e
	var ok_writ: bool = game.race_cards.rewrite_job(orc_e.uid, "hunter")
	game.race_cards.rewrite_job(human_e.uid, "gatherer")
	game.race_cards.rewrite_job(pocket_entry.uid, "lumberjack")
	await frames(4)
	var ov = hand.views.get(orc_e.uid)
	var orc_hunter := Catalog.race_texture_path("hunter", "orc", true)
	check(ok_writ and ov != null and ov.card_id == "hunter", "writ: rewritten orc contract view now holds the hunter card")
	check(ov != null and src(ov.art.texture) == orc_hunter, "writ: orc warrior → orc hunter card art in hand")
	var hv = hand.views.get(human_e.uid)
	check(hv != null and hv.card_id == "gatherer" and not src(hv.art.texture).contains("/races/"), "writ: human warrior → base gatherer card")
	var p2: Texture2D = hand._surface(pocket_entry.id, pocket_entry.person)
	check(pocket_entry.id == "lumberjack" and src(p2) == Catalog.race_texture_path("lumberjack", "fairy", true), "writ: fairy hunter in pocket → fairy lumberjack card")
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
