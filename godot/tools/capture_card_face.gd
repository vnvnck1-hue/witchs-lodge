extends SceneTree
## 카드 앞면 실제 텍스트(CardFace) 렌더 캡처. 폰트 외형·자간·배치는 화면에서만 판단할 수 있어 창을 띄운다.
## 카탈로그 전체 카드(+ 술주정 그림 변형, 종족별 계약 카드)를 원본 크기 1024×1536 과 손패 크기 256×384 로 굽고
## 칸마다 실제로 쓴 글자 크기를 fit.json 에 남긴다(기준보다 줄었으면 문구가 칸보다 길다는 뜻).
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_card_face.gd -- --out=../output/card-text-strip-v01/faces
##   한 장만: ... -- --card=lumberjack --out=res://screenshots/card-face

const CardFaceScript := preload("res://scripts/ui/card_face.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")
const Races := preload("res://scripts/game/races.gd")
const BATCH := 6   # 한 번에 굽는 장수(1024×1536 SubViewport VRAM 제한)

var only := ""
var out := "../output/card-text-strip-v01/faces/"
var fit_log := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--card="): only = a.trim_prefix("--card=")
		if a.begins_with("--out="): out = a.trim_prefix("--out=").trim_suffix("/") + "/"
	create_timer(600.0, true, false, true).timeout.connect(func() -> void:
		print("FAIL 시간 초과")
		quit(2))
	call_deferred("_run")


## 구울 목록: [출력 상대경로(확장자 없음), 카탈로그 항목, 그림 경로, 이름표]
func _jobs() -> Array:
	var jobs: Array = []
	for d in Catalog.read().get("cards", []):
		var id: String = d["id"]
		if only != "" and id != only:
			continue
		if id == "card_back" or not d.has("texture"):
			continue
		var badge := String(d.get("badge", ""))
		jobs.append([id, d, String(d["texture"]), badge])
		for v in d.get("art_variants", []):
			if String(v) != id:
				jobs.append([String(v), d, "res://assets/cards/%s.png" % v, badge])
		if id in Catalog.RACE_JOB_CARDS:
			for race in Races.ALL:
				var p := Catalog.race_texture_path(id, race)
				if p != "" and ResourceLoader.exists(p):
					jobs.append(["races/%s/%s" % [race, id], d, p, Races.name_of(race)])
	return jobs


func _run() -> void:
	var jobs := _jobs()
	for sub in ["full", "hand", "full/races", "hand/races"]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out + sub))
	for race in Races.ALL:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out + "full/races/" + race))
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out + "hand/races/" + race))
	var done := 0
	var i := 0
	while i < jobs.size():
		var batch: Array = jobs.slice(i, i + BATCH)
		var vps: Array = []
		for job in batch:
			var art: Texture2D = load(job[2])
			for sz in [Vector2i(1024, 1536), Vector2i(256, 384)]:
				var vp := SubViewport.new()
				vp.size = sz
				vp.transparent_bg = true
				vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
				var f: Control = CardFaceScript.new()
				f.size = Vector2(sz)
				vp.add_child(f)
				root.add_child(vp)
				f.setup(job[1], art, job[3], job[2])
				vps.append([vp, f, job[0], "full" if sz.x == 1024 else "hand"])
		for n in 3:
			await process_frame
		await RenderingServer.frame_post_draw
		for v in vps:
			var path := ProjectSettings.globalize_path(out + "%s/%s.png" % [v[3], v[2]])
			v[0].get_texture().get_image().save_png(path)
			if v[3] == "full":
				fit_log[v[2]] = v[1].fit
			v[0].queue_free()
		done += batch.size()
		print("baked %d/%d" % [done, jobs.size()])
		i += BATCH
		await process_frame
	var f := FileAccess.open(out + "fit.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(fit_log, "\t"))
	f.close()
	print("DONE %d faces → %s" % [done, ProjectSettings.globalize_path(out)])
	quit(0)
