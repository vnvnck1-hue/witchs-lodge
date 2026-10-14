extends SceneTree
var folder := ""
var canvas: Control
var failures := []
var checks := []
var glyph_texture: ImageTexture
var glyph_map := {}

func _initialize() -> void:
	folder=ProjectSettings.globalize_path("res://../art/ui/moon-runes-v01/")
	call_deferred("_verify")

func _tex(path: String) -> ImageTexture:
	return ImageTexture.create_from_image(Image.load_from_file(folder+path))

func _image(texture: Texture2D,rect: Rect2) -> TextureRect:
	var control := TextureRect.new()
	control.texture=texture
	control.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	control.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	control.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	control.position=rect.position
	control.size=rect.size
	canvas.add_child(control)
	return control

func _text(text: String,rect: Rect2,size: int,numeric := false,color := Color(.94,.89,.75)) -> void:
	if numeric:
		var advance := 0.0
		for i in text.length():
			var code := text.unicode_at(i)
			advance+=float(glyph_map[code].xadvance) if glyph_map.has(code) else 28.0
		var scale := minf(size/64.0,rect.size.x/maxf(advance,1.0))
		var cursor := rect.position.x+(rect.size.x-advance*scale)*.5
		var top := rect.position.y+(rect.size.y-64.0*scale)*.5
		for i in text.length():
			var code := text.unicode_at(i)
			if not glyph_map.has(code): cursor+=28.0*scale; continue
			var g: Dictionary=glyph_map[code]
			var r: Array=g.rect
			var texture:=AtlasTexture.new()
			texture.atlas=glyph_texture
			texture.region=Rect2(r[0],r[1],r[2],r[3])
			texture.filter_clip=true
			_image(texture,Rect2(cursor,top+float(g.yoffset)*scale,float(r[2])*scale,float(r[3])*scale))
			cursor+=float(g.xadvance)*scale
		return
	var label := Label.new()
	label.text=text
	label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",color)
	label.clip_text=true
	label.position=rect.position
	label.size=rect.size
	canvas.add_child(label)

func _capture(path: String) -> Image:
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	image.save_png(folder+path)
	return image

func _verify() -> void:
	root.size=Vector2i(1600,800)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
	canvas=Control.new()
	root.add_child(canvas)
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(folder+"asset-catalog.json"))
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(folder+"layout.json"))
	var atlas := Image.load_from_file(folder+"approved/atlas.png")
	var asset_sizes := {}
	for asset in catalog.assets:
		var image := Image.load_from_file(folder+asset.file)
		if image==null or image.get_width()!=int(asset.width) or image.get_height()!=int(asset.height): failures.append("Bad asset "+asset.file)
		asset_sizes[asset.file]=[image.get_width(),image.get_height()]
	var exact_groups := []
	for g in layout.groups:
		var r: Array = g.atlas_rect
		var crop := atlas.get_region(Rect2i(r[0],r[1],r[2],r[3]))
		var saved := Image.load_from_file(folder+g.approved_texture)
		var exact := crop.get_data()==saved.get_data()
		if not exact: failures.append("Approved crop changed "+g.id)
		exact_groups.append({"id":g.id,"exact_original_pixels":exact})
	var state_checks := []
	for base in ["runtime/pause","runtime/storage","runtime/lodge_button","runtime/dragon_normal","common/button_normal"]:
		var normal := Image.load_from_file(folder+base+".png")
		for mode in ["hover","pressed","focus"]:
			var path: String = ("common/button_"+mode if base.begins_with("common") else base+"_"+mode)+".png"
			var variant := Image.load_from_file(folder+path)
			var changed := 0
			for y in normal.get_height():
				for x in normal.get_width():
					if normal.get_pixel(x,y).a!=variant.get_pixel(x,y).a: changed+=1
			state_checks.append({"normal":base,"state":mode,"changed_alpha_pixels":changed})
			if changed>0: failures.append("State changed silhouette "+path)
	_image(_tex("approved/game-background.png"),Rect2(0,0,1600,800))
	var atlas_texture := ImageTexture.create_from_image(atlas)
	for g in layout.groups:
		var r: Array = g.atlas_rect
		var slot: Array = g.slot
		var sub := AtlasTexture.new()
		sub.atlas=atlas_texture
		sub.region=Rect2(r[0],r[1],r[2],r[3])
		sub.filter_clip=true
		_image(sub,Rect2(slot[0],slot[1],slot[2],slot[3]))
	var reassembled: Image = await _capture("verification/approved-reassembled.png")
	var reference := Image.load_from_file(folder+"approved/mockup.png")
	var changed := 0
	var largest_error := 0.0
	for y in reference.get_height():
		for x in reference.get_width():
			var a := reassembled.get_pixel(x,y)
			var b := reference.get_pixel(x,y)
			if a!=b: changed+=1
			largest_error=maxf(largest_error,maxf(absf(a.r-b.r),maxf(absf(a.g-b.g),absf(a.b-b.b))))
	if changed!=0: failures.append("Reassembly differs from approved screenshot: "+str(changed))
	# Authoring preview only. Does not instantiate or edit the game's HUD.
	for child in canvas.get_children(): child.queue_free()
	await process_frame
	_image(_tex("approved/game-background.png"),Rect2(0,0,1600,800))
	glyph_texture=_tex("fonts/numbers.png")
	var glyph_data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(folder+"fonts/glyphs.json"))
	for g in glyph_data.glyphs: glyph_map[int(g.code)]=g
	for g in layout.groups:
		var slot: Array = g.slot
		if g.id=="hand": continue
		_image(_tex(g.runtime_texture),Rect2(slot[0],slot[1],slot[2],slot[3]))
		for field in g.dynamic_fields:
			if "fill" in field.id:
				var fill_name := "phase" if field.id=="phase_fill" else ("player_hp" if field.id=="player_hp_fill" else "lodge_hp")
				var ratio := .61 if fill_name=="phase" else (.73 if fill_name=="player_hp" else .82)
				var fill_rect: Array = field.screen_rect
				var progress := TextureRect.new()
				progress.texture=_tex("runtime/"+fill_name+"_fill.png")
				progress.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
				progress.position=Vector2(fill_rect[0],fill_rect[1])
				progress.size=Vector2(fill_rect[2]*ratio,fill_rect[3])
				canvas.add_child(progress)
				continue
			var text := ""
			var font_size := 17
			var numerical := true
			match field.id:
				"player_hp_value": text="73/100"; font_size=12
				"lodge_hp_value": text="245/300"; font_size=12
				"gold_value": text="87"; font_size=18
				"timber_value": text="9"; font_size=18
				"wool_value": text="4"; font_size=18
				"phase_title": text="1일차 · 낮"; numerical=false; font_size=19
				"phase_timer": text="00:35"; font_size=12
				"objective_body": text="손님을 맞이하세요"; numerical=false; font_size=13
				"dragon_cost": text="120G"; font_size=12
			var r: Array=field.screen_rect
			if field.id=="phase_timer":
				var display: Array=g.display_rect
				var scale: float=g.texture_scale
				_image(_tex("runtime/phase_timer_prefix.png"),Rect2(display[0]+205*scale,display[1]+75*scale,56*scale,25*scale))
				r=[display[0]+262*scale,r[1],80*scale,r[3]]
			_text(text,Rect2(r[0],r[1],r[2],r[3]),font_size,numerical,Color(.07,.05,.15) if field.id=="objective_body" else Color.WHITE)
	var hand: Dictionary=layout.groups[5]
	var dr: Array=hand.display_rect
	var scale: float=hand.texture_scale
	var ids := ["axe_mercenary","wool","timber","forest_monster"]
	var rects := [Rect2(29,16,204,263),Rect2(233,16,198,263),Rect2(431,16,198,263),Rect2(629,16,212,263)]
	for i in 4:
		var r: Rect2=rects[i]
		_image(_tex("cards/"+ids[i]+".png"),Rect2(Vector2(dr[0],dr[1])+r.position*scale,r.size*scale))
	_image(_tex("runtime/hand_tray.png"),Rect2(dr[0],dr[1]+217*scale,856*scale,123*scale))
	for entry in [[Vector2(369,221),"×4"],[Vector2(557,221),"×9"]]:
		_text(entry[1],Rect2(Vector2(dr[0],dr[1])+entry[0]*scale,Vector2(46,35)*scale),12,true,Color.WHITE)
	var runtime_render: Image = await _capture("verification/runtime-authoring-preview.png")
	var numeric_visible_pixels := 0
	for y in range(43,66):
		for x in range(257,315):
			var c := runtime_render.get_pixel(x,y)
			if c.r>.7 and c.g>.65 and c.b>.45: numeric_visible_pixels+=1
	if numeric_visible_pixels<12: failures.append("Numeric glyphs did not render in the authoring preview")
	# Asset sheet proves both dark and cream popup materials at working sizes.
	for child in canvas.get_children(): child.queue_free()
	await process_frame
	var background := ColorRect.new()
	background.color=Color(.08,.07,.13)
	background.size=Vector2(1600,800)
	canvas.add_child(background)
	var gallery := [
		["runtime/player_status.png",Rect2(20,20,370,140)],
		["runtime/phase.png",Rect2(430,20,370,140)],
		["runtime/resources.png",Rect2(850,20,400,140)],
		["runtime/hand_tray.png",Rect2(20,180,620,100)],
		["runtime/storage.png",Rect2(1280,10,100,150)],
		["runtime/lodge_button.png",Rect2(1410,10,150,150)],
		["runtime/dragon_disabled.png",Rect2(1280,180,130,120)],
		["runtime/dragon_normal.png",Rect2(1430,180,130,120)],
		["common/modal_frame.png",Rect2(20,320,610,210)],
		["common/tooltip_frame.png",Rect2(660,320,580,210)],
		["common/button_normal.png",Rect2(20,555,280,80)],
		["common/button_hover.png",Rect2(320,555,280,80)],
		["common/button_disabled.png",Rect2(620,555,280,80)],
		["common/toast_frame.png",Rect2(20,655,880,70)],
		["fonts/numbers.png",Rect2(930,555,640,170)]
	]
	for entry in gallery: _image(_tex(entry[0]),entry[1])
	for i in 6:
		var names := ["close","plus","minus","check","warning","arrow"]
		_image(_tex("icons/"+names[i]+".png"),Rect2(650+i*100,185,90,90))
	await _capture("verification/asset-gallery.png")
	var report := {"passed":failures.is_empty(),"failures":failures,"approved_group_checks":exact_groups,"approved_screenshot_changed_pixels":changed,"approved_screenshot_max_channel_error":largest_error,"state_checks":state_checks,"numeric_visible_pixels":numeric_visible_pixels,"numeric_font_format":"bitmap_glyph_atlas","catalog_asset_count":catalog.assets.size(),"asset_sizes":asset_sizes,"scope":"Asset integrity + same-pixel static reassembly + authoring previews only; does not claim completed runtime HUD implementation"}
	var file:=FileAccess.open(folder+"verification/package-verification.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	print("PACKAGE_VERIFY passed=",report.passed," changed_pixels=",changed," failures=",failures)
	quit(0 if failures.is_empty() else 1)
