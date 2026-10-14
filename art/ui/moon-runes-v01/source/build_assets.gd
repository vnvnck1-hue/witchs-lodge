extends SceneTree
## Asset packaging only. Never attaches anything to the game's runtime HUD.
const GROUPS := [
	{"id":"player_status","rect":Rect2i(6,6,577,195),"slot":Rect2(18,16,312,108)},
	{"id":"objective","rect":Rect2i(5,197,398,148),"slot":Rect2(22,132,238,89)},
	{"id":"phase","rect":Rect2i(625,7,526,175),"slot":Rect2(640,16,320,100)},
	{"id":"resources","rect":Rect2i(1197,29,468,143),"slot":Rect2(1140,25,350,85)},
	{"id":"pause","rect":Rect2i(1668,34,105,116),"slot":Rect2(1510,30,64,72)},
	{"id":"hand","rect":Rect2i(460,539,856,340),"slot":Rect2(540,622,520,176)},
	{"id":"storage","rect":Rect2i(3,694,195,185),"slot":Rect2(24,681,106,109)},
	{"id":"actions","rect":Rect2i(1315,696,458,183),"slot":Rect2(1310,687,265,107)}
]
# Only these dynamic interiors may use imagegen clean pixels. Every other pixel
# remains bit-for-bit equal to the approved atlas, including fixed Korean titles.
const PATCHES := [
	{"id":"player_hp_value","rect":Rect2i(455,60,92,29)},
	{"id":"lodge_hp_value","rect":Rect2i(453,117,99,30)},
	{"id":"player_hp_fill","rect":Rect2i(311,67,137,17)},
	{"id":"lodge_hp_fill","rect":Rect2i(311,125,137,17)},
	{"id":"phase_title","rect":Rect2i(827,37,175,36)},
	{"id":"phase_timer","rect":Rect2i(828,80,168,27)},
	{"id":"phase_fill","rect":Rect2i(755,125,128,14)},
	{"id":"gold_value","rect":Rect2i(1290,72,51,39)},
	{"id":"timber_value","rect":Rect2i(1450,72,30,39)},
	{"id":"wool_value","rect":Rect2i(1596,72,32,39)},
	{"id":"objective_body","rect":Rect2i(128,267,217,30)},
	{"id":"wool_count","rect":Rect2i(829,760,46,35)},
	{"id":"timber_count","rect":Rect2i(1017,760,45,35)},
	{"id":"dragon_cost","rect":Rect2i(1662,808,66,34)}
]
var folder := ""
var records := []
var layout := []

func _initialize() -> void:
	folder = ProjectSettings.globalize_path("res://../art/ui/moon-runes-v01/")
	call_deferred("_build")

func _rect(r: Rect2i) -> Array: return [r.position.x,r.position.y,r.size.x,r.size.y]

func _save(image: Image,path: String,kind: String,source_rect := Rect2i(),notes := "",nine_slice := []) -> void:
	if image.save_png(folder+path) != OK: push_error("Asset save failed "+path); quit(1); return
	records.append({"file":path,"kind":kind,"width":image.get_width(),"height":image.get_height(),"format":"RGBA8","source_rect":_rect(source_rect),"notes":notes,"nine_slice":nine_slice})

func _state(image: Image,mode: String) -> Image:
	var out: Image = image.duplicate()
	for y in out.get_height():
		for x in out.get_width():
			var c := image.get_pixel(x,y)
			if c.a==0: continue
			var next := c
			if mode=="disabled":
				var l := c.r*.24+c.g*.45+c.b*.31
				next=Color(l*.70+.06,l*.61+.04,l*.84+.10,c.a)
			elif mode=="pressed": next=Color(c.r*.94,c.g*.94,c.b*.94,c.a)
			elif c.g>c.r*1.2 and c.b>c.r*1.2:
				next=c.lerp(Color(.24,.94,.82,c.a),.32 if mode=="hover" else .55)
			elif mode=="focus" and c.r>.65 and c.g>.55 and c.b>.35:
				next=c.lerp(Color(.73,1,.90,c.a),.16)
			out.set_pixel(x,y,next)
	return out

func _build() -> void:
	var original := Image.load_from_file(folder+"approved/atlas.png")
	original.convert(Image.FORMAT_RGBA8)
	var generated := Image.load_from_file(folder+"source/dynamic-atlas.png")
	generated.convert(Image.FORMAT_RGBA8)
	if generated.get_size() != original.get_size(): generated.resize(original.get_width(),original.get_height(),Image.INTERPOLATE_LANCZOS)
	var runtime: Image = original.duplicate()
	for p in PATCHES: runtime.blit_rect(generated,p.rect,p.rect.position)
	# The first clean generation widened HP tracks into the old number slots.
	# Reuse the approved clean surface directly above each number instead; no
	# regenerated borders or extra tracks may enter the dynamic base.
	for strip in [[Rect2i(455,60,92,29),54],[Rect2i(453,117,99,30),113]]:
		var r: Rect2i = strip[0]
		var surface := original.get_pixel(500,90 if strip[1]==54 else 112)
		for y in range(r.position.y,r.end.y):
			for x in range(r.position.x,r.end.x): runtime.set_pixel(x,y,surface)
	var track_color := original.get_pixel(966,133)
	for bar in [[Rect2i(311,67,137,17),"red"],[Rect2i(311,125,137,17),"cyan"],[Rect2i(755,125,128,14),"amber"]]:
		var r: Rect2i = bar[0]
		# Restore every original rim pixel, then clear only saturated fill pixels.
		runtime.blit_rect(original,r,r.position)
		for y in range(r.position.y,r.end.y):
			for x in range(r.position.x,r.end.x):
				var c := original.get_pixel(x,y)
				var filled: bool = (c.r>c.g*1.25 and c.r>c.b*1.25) if bar[1]=="red" else ((c.g>c.r*1.25 and c.b>c.r*1.25) if bar[1]=="cyan" else (c.r>c.b*1.8 and c.g>c.b*1.8))
				if filled: runtime.set_pixel(x,y,track_color)
	_save(runtime,"runtime/atlas.png","dynamic_base",Rect2i(),"Approved pixels outside declared dynamic patches; clean generated interior pixels only")
	var changed_outside := 0
	for y in original.get_height():
		for x in original.get_width():
			if runtime.get_pixel(x,y) == original.get_pixel(x,y): continue
			var declared := false
			for p in PATCHES:
				if p.rect.has_point(Vector2i(x,y)): declared = true; break
			if not declared: changed_outside += 1
	for g in GROUPS:
		_save(original.get_region(g.rect),"approved/"+g.id+".png","approved_exact",g.rect)
		_save(runtime.get_region(g.rect),"runtime/"+g.id+".png","dynamic_base",g.rect,"hand/actions groups are layout references; use individual runtime pieces for interactions")
		var scale := minf(g.slot.size.x/g.rect.size.x,g.slot.size.y/g.rect.size.y)
		var displayed: Vector2 = Vector2(g.rect.size)*scale
		var pos: Vector2 = g.slot.position+(g.slot.size-displayed)*.5
		var fields := []
		for p in PATCHES:
			if g.rect.encloses(p.rect):
				var relative: Rect2i = Rect2i(p.rect.position-g.rect.position,p.rect.size)
				fields.append({"id":p.id,"native_rect":_rect(relative),"screen_rect":[pos.x+relative.position.x*scale,pos.y+relative.position.y*scale,relative.size.x*scale,relative.size.y*scale]})
		layout.append({"id":g.id,"approved_texture":"approved/"+g.id+".png","runtime_texture":"runtime/"+g.id+".png","atlas_rect":_rect(g.rect),"slot":[g.slot.position.x,g.slot.position.y,g.slot.size.x,g.slot.size.y],"display_rect":[pos.x,pos.y,displayed.x,displayed.y],"texture_scale":scale,"fit":"KEEP_ASPECT_CENTERED","dynamic_fields":fields})
	var pieces := [
		["runtime/portrait.png",Rect2i(6,6,207,189)],
		["runtime/counter_gold.png",Rect2i(1202,42,164,100)],
		["runtime/counter_timber.png",Rect2i(1366,42,140,100)],
		["runtime/counter_wool.png",Rect2i(1506,42,154,100)],
		["runtime/dragon_disabled.png",Rect2i(1547,696,226,183)],
		["runtime/lodge_button.png",Rect2i(1315,696,232,183)],
		["runtime/player_hp_fill.png",Rect2i(317,71,125,10)],
		["runtime/lodge_hp_fill.png",Rect2i(317,128,125,10)],
		["runtime/phase_fill.png",Rect2i(761,128,83,9)],
		["runtime/player_hp_track.png",Rect2i(307,64,143,23)],
		["runtime/lodge_hp_track.png",Rect2i(307,121,143,23)],
		["runtime/phase_track.png",Rect2i(752,121,274,25)],
		["runtime/phase_timer_prefix.png",Rect2i(830,82,56,25)],
		["runtime/stack_badge.png",Rect2i(805,739,85,85)],
		["cards/axe_mercenary.png",Rect2i(489,555,204,263)],
		["cards/wool.png",Rect2i(693,555,198,263)],
		["cards/timber.png",Rect2i(891,555,198,263)],
		["cards/forest_monster.png",Rect2i(1089,555,212,263)]
	]
	for piece in pieces:
		var source := original if "_fill.png" in piece[0] or "_prefix.png" in piece[0] else runtime
		var part := source.get_region(piece[1])
		if piece[0]=="runtime/stack_badge.png":
			var seed := Vector2i(41,40)
			var surface := part.get_pixelv(seed)
			var visited := PackedByteArray()
			visited.resize(85*85)
			var queue: Array[Vector2i]=[seed]
			visited[seed.y*85+seed.x]=1
			var head := 0
			while head<queue.size():
				var at: Vector2i=queue[head]
				head+=1
				for offset in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
					var next: Vector2i=at+offset
					if next.x<0 or next.x>=85 or next.y<0 or next.y>=85: continue
					var index := next.y*85+next.x
					if visited[index]: continue
					visited[index]=1
					var c := part.get_pixelv(next)
					if absf(c.r-surface.r)<.09 and absf(c.g-surface.g)<.09 and absf(c.b-surface.b)<.09: queue.append(next)
			var isolated := Image.create(85,85,false,Image.FORMAT_RGBA8)
			for at in queue:
				for dy in range(-3,4):
					for dx in range(-3,4):
						var next: Vector2i=at+Vector2i(dx,dy)
						if next.x>=0 and next.x<85 and next.y>=0 and next.y<85: isolated.set_pixelv(next,part.get_pixelv(next))
			var used := isolated.get_used_rect()
			part=isolated.get_region(used)
			piece[1]=Rect2i(piece[1].position+used.position,used.size)
		_save(part,piece[0],"runtime_piece",piece[1])
	var symbols := [
		["heart",Rect2i(212,52,40,45)],["lodge",Rect2i(212,112,40,42)],
		["sun",Rect2i(711,108,38,37)],["moon",Rect2i(1028,105,37,39)],
		["gold",Rect2i(1221,49,55,66)],["timber",Rect2i(1374,48,63,69)],["wool",Rect2i(1522,52,65,60)]
	]
	for symbol in symbols: _save(original.get_region(symbol[1]),"icons/"+symbol[0]+"_original_inset.png","approved_inset",symbol[1],"Includes original dark panel behind the glyph; use same-position inset, not as a free-floating transparent icon")
	var extension := Image.load_from_file(folder+"source/extension-sheet.png")
	var common_pieces := [
		["modal_frame",Rect2i(80,10,790,283),[110,75,110,65]],
		["tooltip_frame",Rect2i(947,22,731,265),[90,65,90,65]],
		["toast_frame",Rect2i(85,309,779,155),[100,48,100,48]],
		["button_normal",Rect2i(940,302,743,165),[100,50,100,50]],
		["scroll_track",Rect2i(136,708,678,62),[38,25,38,25]],
		["scroll_thumb",Rect2i(301,775,350,77),[45,28,45,28]],
		["divider",Rect2i(941,725,730,89),[]]
	]
	for piece in common_pieces: _save(extension.get_region(piece[1]),"common/"+piece[0]+".png","extension_generated",piece[1],"Generated extension for hidden popups; not an approved persistent HUD replacement",piece[2])
	var generic_button := extension.get_region(Rect2i(940,302,743,165))
	for mode in ["hover","pressed","focus","disabled"]:
		_save(_state(generic_button,mode),"common/button_"+mode+".png","same_silhouette_state",Rect2i(),"Same alpha/silhouette as normal; state tint only",[100,50,100,50])
	_save(generic_button,"common/tab_normal.png","common_reuse",Rect2i(),"Same themed primitive for popup tabs",[100,50,100,50])
	_save(_state(generic_button,"focus"),"common/tab_selected.png","same_silhouette_state",Rect2i(),"Selected popup tab",[100,50,100,50])
	_save(_state(generic_button,"pressed"),"common/row_background.png","common_reuse",Rect2i(),"Popup list/offer/storage row background",[100,50,100,50])
	var empty_hand := Image.load_from_file(folder+"source/empty-hand.png")
	if empty_hand.get_size() != original.get_size(): empty_hand.resize(1774,887,Image.INTERPOLATE_LANCZOS)
	var tray := empty_hand.get_region(Rect2i(460,756,856,123))
	_save(tray,"runtime/hand_tray.png","runtime_generated_completion",Rect2i(460,756,856,123),"Approved tray with card-covered edges reconstructed; no fixed cards. Position native y=217 inside the hand group")
	for section in [["left",Rect2i(0,0,140,123)],["center",Rect2i(346,0,164,123)],["right",Rect2i(716,0,140,123)],["rail_left",Rect2i(160,0,40,123)],["rail_right",Rect2i(620,0,40,123)]]:
		_save(tray.get_region(section[1]),"runtime/hand_tray_"+section[0]+".png","adaptive_hand_extension",section[1],"For 1-8 card adaptation only. Fixed 4-card reference uses the whole hand_tray unchanged; never stretch the center crescent")
	var active := Image.load_from_file(folder+"source/dragon-enabled-v02.png")
	var active_tight := active.get_region(active.get_used_rect())
	var disabled := runtime.get_region(Rect2i(1547,696,226,183))
	var bounds := disabled.get_used_rect()
	active_tight.resize(bounds.size.x,bounds.size.y,Image.INTERPOLATE_LANCZOS)
	var enabled := Image.create(226,183,false,Image.FORMAT_RGBA8)
	enabled.blit_rect(active_tight,Rect2i(Vector2i.ZERO,active_tight.get_size()),bounds.position)
	for y in enabled.get_height():
		for x in enabled.get_width():
			var c := enabled.get_pixel(x,y)
			c.a=disabled.get_pixel(x,y).a
			enabled.set_pixel(x,y,c)
	# Preserve the approved fixed label; only the active artwork/color is new.
	enabled.blit_rect(disabled,Rect2i(35,112,80,34),Vector2i(35,112))
	_save(enabled,"runtime/dragon_normal.png","runtime_generated_state",Rect2i(),"Enabled recolor, original disabled pose used as reference. Disabled sample remains exact")
	for button in ["pause","storage","lodge_button","dragon_normal"]:
		var button_image := Image.load_from_file(folder+"runtime/"+button+".png")
		for mode in ["hover","pressed","focus"]:
			_save(_state(button_image,mode),"runtime/"+button+"_"+mode+".png","same_silhouette_state",Rect2i(),"Keep normal position/scale; pressed offset is handled by UI")
		if button!="dragon_normal": _save(_state(button_image,"disabled"),"runtime/"+button+"_disabled.png","same_silhouette_state")
	var utility := Image.load_from_file(folder+"source/utility-icons.png")
	for i in 6:
		var names := ["close","plus","minus","check","warning","arrow"]
		var cell := Rect2i((i%3)*591,(i/3)*443,591,443)
		var piece := utility.get_region(cell)
		var tight := piece.get_used_rect().grow(6).intersection(Rect2i(Vector2i.ZERO,piece.get_size()))
		_save(piece.get_region(tight),"icons/"+names[i]+".png","extension_generated",cell)
	var patches := []
	for p in PATCHES: patches.append({"id":p.id,"rect":_rect(p.rect)})
	var data := {"canvas":[1600,800],"atlas_size":[1774,887],"groups":layout,"dynamic_patches":patches,"states":{"hover":"use supplied common button_hover or subtle cyan focus overlay without resizing","pressed":"offset y +1px, tint RGB .94","focus":"cyan thin boundary","disabled":"use exact dragon_disabled / common button_disabled"},"import":{"filter":"linear","mipmaps":false,"compression":"lossless"}}
	var file := FileAccess.open(folder+"layout.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(data,"\t"))
	file = FileAccess.open(folder+"asset-catalog.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"assets":records},"\t"))
	file = FileAccess.open(folder+"verification/static-preservation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"approved_size":[1774,887],"changed_outside_dynamic_rectangles":changed_outside,"passed":changed_outside==0},"\t"))
	print("ASSET_EXPORT ",records.size()," static_changed_outside=",changed_outside)
	quit(0 if changed_outside==0 else 1)
