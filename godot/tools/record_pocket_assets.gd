extends SceneTree
## Asset metadata, UI downsample and 1:1 QA sheets only; never paint content.
const Package = preload("res://tools/package_card_assets.gd")
const Verify = preload("res://tools/verify_card_assets.gd")
const OUT := "res://../output/pocket-cards-v01/"
var failures: Array[String] = []

func _initialize() -> void:
	if OS.get_cmdline_user_args().has("prepare"):
		var icon := Image.load_from_file(ProjectSettings.globalize_path("res://../art/ui/pocket-cards-v01/icon_discard.png"))
		if icon == null:
			quit(1)
			return
		icon.convert(Image.FORMAT_RGBA8)
		icon.resize(96,96,Image.INTERPOLATE_LANCZOS)
		var error := icon.save_png("res://assets/ui/icons/icon_discard.png")
		print("POCKET_ICON_PACKAGED ",error)
		quit(0 if error == OK else 1)
		return
	var manifest_path := "res://../art/cards/manifest.json"
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var existing := {}
	for entry in manifest.assets:
		existing[entry.id] = entry
	var generation: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(OUT + "generation-record.json"))
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cards/catalog.json"))
	var titles := {}
	for entry in catalog.cards:
		titles[entry.id] = entry.name
	var assets: Array = []
	var deliverables: Array = []
	for id in Package.IDS:
		var entry: Dictionary = existing.get(id, {"id":id,"title":titles.get(id,id)})
		for field in ["source","full","hand"]:
			var folder := "art/cards/rounded" if field == "source" else ("godot/assets/cards" if field == "full" else "godot/assets/cards/hand")
			entry[field] = _metadata(folder + "/" + id + ".png")
			if Verify.POCKET_CARD_TEXT.has(id):
				deliverables.append(entry[field])
				var expected := Vector2i(256,384) if field == "hand" else Vector2i(1024,1536)
				var meta: Dictionary = entry[field]
				if meta.width != expected.x or meta.height != expected.y or meta.mode != "RGBA" or meta.alpha_extrema[0] != 0 or meta.alpha_extrema[1] < 243:
					failures.append("Invalid card source/export metadata: " + meta.path)
				for alpha in meta.corner_alpha:
					if alpha >= 6:
						failures.append("Opaque card source/export corner: " + meta.path)
		if Verify.POCKET_CARD_TEXT.has(id):
			var spec: Array = Verify.POCKET_CARD_TEXT[id]
			entry.title = spec[0]
			entry.printed_text = {"title":spec[0],"category":spec[1],"rules":spec[2]}
			entry.generation = {"id":id,"generated_file":generation[id].generated_file,"project_source":"art/cards/rounded/" + id + ".png","prompt_id":id + ("-alpha-final" if generation[id].has("alpha_final_prompt") else ""),"generator":"built-in image_gen","prompt_set":"docs/prompts/cards/pocket-cards-v01-prompts.md"}
		assets.append(entry)
	manifest.assets = assets
	manifest.date = "2026-10-16"
	manifest.card_count = 26
	manifest.support_asset_count = 1
	manifest.source_png_count = 27
	manifest.shipping_png_count = 54
	manifest.scope_asset_ids = Package.IDS
	manifest.count_note = "Previous 22 assets + 3 existing forest assets + 2 pocket cards = 27 including shared back."
	manifest.handoff = "docs/handoff/codex-pocket-cards-v01.md"
	manifest.visual_review = "art/cards/pocket-cards-v01-review.md"
	manifest.text_proof = "godot/screenshots/cards/pocket-cards-v01-text-proof.png"
	manifest.text_proofs = [manifest.text_proof]
	manifest.latest_prompt_set = "docs/prompts/cards/pocket-cards-v01-prompts.md"
	if not manifest.prompt_sets.has(manifest.latest_prompt_set):
		manifest.prompt_sets.append(manifest.latest_prompt_set)
	_write(manifest_path,manifest)
	var icon := _metadata("godot/assets/ui/icons/icon_discard.png")
	deliverables.append(icon)
	var icon_master := _metadata("art/ui/pocket-cards-v01/icon_discard.png")
	if icon.width != 96 or icon.height != 96 or icon.mode != "RGBA" or icon.alpha_extrema != [0,255] or icon.corner_alpha != [0,0,0,0]:
		failures.append("Invalid discard icon dimensions, mode or alpha")
	if not load("res://assets/ui/icons/icon_discard.png") is Texture2D:
		failures.append("Discard icon import failed")
	# Unscaled pixel crops for direct title/category/body text comparison.
	var proof := Image.create(2048,780,false,Image.FORMAT_RGBA8)
	proof.fill(Color("514861"))
	var card_index := 0
	for id in Verify.POCKET_CARD_TEXT:
		var png := Image.load_from_file(ProjectSettings.globalize_path("res://assets/cards/" + id + ".png"))
		proof.blit_rect(png,Rect2i(0,0,1024,320),Vector2i(card_index*1024,0))
		proof.blit_rect(png,Rect2i(0,1100,1024,436),Vector2i(card_index*1024,330))
		card_index += 1
	if proof.save_png("res://screenshots/cards/pocket-cards-v01-text-proof.png") != OK:
		failures.append("Cannot save text proof")
	var icon_proof := Image.create(576,288,false,Image.FORMAT_RGBA8)
	icon_proof.fill(Color("ddd7e4"))
	var dark := Image.create(288,288,false,Image.FORMAT_RGBA8)
	dark.fill(Color("302a3a"))
	icon_proof.blit_rect(dark,Rect2i(0,0,288,288),Vector2i(288,0))
	var icon_png := Image.load_from_file(ProjectSettings.globalize_path("res://assets/ui/icons/icon_discard.png"))
	icon_proof.blend_rect(icon_png,Rect2i(0,0,96,96),Vector2i(16,96))
	icon_proof.blend_rect(icon_png,Rect2i(0,0,96,96),Vector2i(304,96))
	icon_png.resize(144,144,Image.INTERPOLATE_NEAREST)
	icon_proof.blend_rect(icon_png,Rect2i(0,0,144,144),Vector2i(128,72))
	icon_proof.blend_rect(icon_png,Rect2i(0,0,144,144),Vector2i(416,72))
	if icon_proof.save_png(OUT + "icon-proof.png") != OK:
		failures.append("Cannot save icon proof")
	_write(OUT + "delivery-manifest.json",{"date":"2026-10-16","deliverable_count":7,"assets":deliverables,"additional_icon_master":icon_master})
	_write(OUT + "asset-verification.json",{"passed":failures.is_empty(),"card_count":2,"card_png_count":6,"icon_count":1,"icon":icon,"icon_master":icon_master,"proof":"godot/screenshots/cards/pocket-cards-v01-text-proof.png","failures":failures})
	print("POCKET_ASSET_RECORD ",JSON.stringify({"passed":failures.is_empty(),"card_assets":27,"shipping_pngs":54,"new_deliverables":7,"failures":failures}))
	quit(0 if failures.is_empty() else 1)

func _write(file_path:String,value:Variant) -> void:
	var file := FileAccess.open(file_path,FileAccess.WRITE)
	file.store_string(JSON.stringify(value,"  ",false) + "\n")
	file.close()

func _metadata(relative:String) -> Dictionary:
	var file_path := "res://../" + relative
	var png := Image.load_from_file(ProjectSettings.globalize_path(file_path))
	if png == null:
		failures.append("Missing image: " + relative)
		return {}
	var w := png.get_width()
	var h := png.get_height()
	var amin := 255
	var amax := 0
	var data := png.get_data()
	for i in range(3,data.size(),4):
		amin = mini(amin,data[i])
		amax = maxi(amax,data[i])
	var corners: Array = []
	for pos in [Vector2i.ZERO,Vector2i(w-1,0),Vector2i(0,h-1),Vector2i(w-1,h-1)]:
		corners.append(roundi(png.get_pixelv(pos).a*255))
	return {"path":relative,"width":w,"height":h,"mode":"RGBA" if png.get_format()==Image.FORMAT_RGBA8 else str(png.get_format()),"bytes":FileAccess.get_file_as_bytes(file_path).size(),"sha256":FileAccess.get_sha256(file_path),"alpha_extrema":[amin,amax],"corner_alpha":corners}
