extends SceneTree
## Packages generated numeric glyphs as a PNG+metrics atlas; no game UI changes.
var folder := ""
const CODES := [48,49,50,51,52,53,54,55,56,57,58,47,215,71,43,8722]

func _initialize() -> void:
	folder = ProjectSettings.globalize_path("res://../art/ui/moon-runes-v01/")
	call_deferred("_build")

func _clean_cell(cell: Image) -> Image:
	# Remove disconnected generation speckles. Retain both colon dots and every
	# main glyph component, then preserve a one-pixel antialias halo.
	var w := cell.get_width()
	var h := cell.get_height()
	var visited := PackedByteArray()
	visited.resize(w*h)
	var components := []
	var biggest := 0
	for y in h:
		for x in w:
			var at := y*w+x
			if visited[at]: continue
			visited[at]=1
			var c := cell.get_pixel(x,y)
			if c.a<.40 or c.b<.45: continue
			var queue := PackedInt32Array([at])
			var head := 0
			while head<queue.size():
				var p := queue[head]
				head+=1
				var px := p%w
				var py := p/w
				for d in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
					var nx: int = px+d.x
					var ny: int = py+d.y
					if nx<0 or nx>=w or ny<0 or ny>=h: continue
					var n := ny*w+nx
					if visited[n]: continue
					visited[n]=1
					var nc := cell.get_pixel(nx,ny)
					if nc.a>=.40 and nc.b>=.45: queue.append(n)
			components.append(queue)
			biggest=maxi(biggest,queue.size())
	var mask := PackedByteArray()
	mask.resize(w*h)
	for component in components:
		if component.size()<maxi(100,biggest/10): continue
		for p in component:
			var px: int = p%w
			var py: int = p/w
			for dy in range(-1,2):
				for dx in range(-1,2):
					var nx: int = px+dx
					var ny: int = py+dy
					if nx>=0 and nx<w and ny>=0 and ny<h: mask[ny*w+nx]=1
	var clean := Image.create(w,h,false,Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			if mask[y*w+x]: clean.set_pixel(x,y,cell.get_pixel(x,y))
	return clean.get_region(clean.get_used_rect())

func _build() -> void:
	var input := Image.load_from_file(folder+"source/numeric-glyphs.png")
	var page := Image.create(1024,256,false,Image.FORMAT_RGBA8)
	var chars := []
	var reference_scale := 64.0/164.0
	for i in CODES.size():
		var left := int(round((i%4)*input.get_width()/4.0))
		var top := int(round((i/4)*input.get_height()/4.0))
		var right := int(round(((i%4)+1)*input.get_width()/4.0))
		var bottom := int(round(((i/4)+1)*input.get_height()/4.0))
		var glyph := _clean_cell(input.get_region(Rect2i(left,top,right-left,bottom-top)))
		if glyph.is_empty(): push_error("Missing numeric glyph "+str(CODES[i])); quit(1); return
		var scale := 64.0/glyph.get_height() if i<10 else reference_scale
		var gw := maxi(1,int(round(glyph.get_width()*scale*.70)))
		var gh := maxi(1,int(round(glyph.get_height()*scale)))
		glyph.resize(gw,gh,Image.INTERPOLATE_LANCZOS)
		var cell := Vector2i((i%8)*128,(i/8)*128)
		var origin := cell+Vector2i(8,8)
		page.blit_rect(glyph,Rect2i(Vector2i.ZERO,glyph.get_size()),origin)
		var advance := gw+4
		var offset_y := 0 if gh>=58 else 64-gh
		if CODES[i]==58: offset_y=int((64-gh)*.5)
		chars.append({"code":CODES[i],"char":String.chr(CODES[i]),"rect":[origin.x,origin.y,gw,gh],"xadvance":advance,"yoffset":offset_y})
	page.save_png(folder+"fonts/numbers.png")
	var fnt := "info face=\"MoonRunesNumbers\" size=64 bold=1 italic=0 charset=\"\" unicode=1 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=0,0\ncommon lineHeight=76 base=64 scaleW=1024 scaleH=256 pages=1 packed=0\npage id=0 file=\"numbers.png\"\nchars count=17\nchar id=32 x=0 y=0 width=0 height=0 xoffset=0 yoffset=0 xadvance=28 page=0 chnl=15\n"
	for c in chars:
		fnt+="char id=%d x=%d y=%d width=%d height=%d xoffset=0 yoffset=%d xadvance=%d page=0 chnl=15\n" % [c.code,c.rect[0],c.rect[1],c.rect[2],c.rect[3],c.yoffset,c.xadvance]
	var file := FileAccess.open(folder+"source/numbers-format.fnt",FileAccess.WRITE)
	file.store_string(fnt)
	var passed := true
	var glyph_checks := []
	for c in chars:
		var rect := Rect2i(c.rect[0],c.rect[1],c.rect[2],c.rect[3])
		var visible := 0
		for y in range(rect.position.y,rect.end.y):
			for x in range(rect.position.x,rect.end.x):
				if page.get_pixel(x,y).a>.25: visible+=1
		passed=passed and visible>10 and Rect2i(0,0,1024,256).encloses(rect)
		glyph_checks.append({"char":c.char,"visible_pixels":visible})
	file=FileAccess.open(folder+"fonts/glyphs.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"format":"bitmap_glyph_atlas","glyphs":chars,"base_size":64,"line_height":76,"space_advance":28,"texture":"numbers.png","recommended_render":"AtlasTexture glyphs with per-glyph xadvance/yoffset, scale=font_size/64; fixed Korean labels stay in approved artwork"},"\t"))
	file=FileAccess.open(folder+"verification/numeric-font.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed":passed,"format":"bitmap_glyph_atlas","glyph_count":16,"glyph_checks":glyph_checks,"sample":"100/100 300/300 00:35 120G ×2","runtime_render_verified_in":"package-verification.json"},"\t"))
	print("NUMERIC_GLYPH_ATLAS ",passed," glyphs=",chars.size())
	quit(0 if passed else 1)
