extends SceneTree
const OUT := "res://../art/ui/hand-workbench-runtime-v04/"
const RECTS := [Rect2(54,300,296,222), Rect2(1136,282,296,240),
	Rect2(304,346,145,165), Rect2(438,430,145,88), Rect2(566,440,110,56),
	Rect2(990,382,105,125), Rect2(1075,430,68,82)]

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(2048,1024)
	var masked := "--masked" in OS.get_cmdline_user_args()
	root.transparent_bg = masked
	RenderingServer.set_default_clear_color(Color.TRANSPARENT if masked else Color.BLACK)
	var surface := SourceSheet.new()
	surface.masked = masked
	surface.size = Vector2(2048,1024)
	root.add_child(surface)
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + ("approved-props-alpha.png" if masked else "approved-props-source-grid.png"))
	quit()

class SourceSheet extends Control:
	const APPROVED := preload("res://assets/ui/hand_workbench/approved/layout-v04.png")
	const HIDDEN := preload("res://assets/ui/hand_workbench/approved/layout-v03.png")
	const EDGES := preload("res://assets/ui/hand_workbench/approved/edge_geometry.gd")
	var masked := false
	func _draw() -> void:
		if not masked:
			draw_rect(Rect2(Vector2.ZERO,size),Color.BLACK)
		for i in RECTS.size():
			var r: Rect2 = RECTS[i]
			var cell := Vector2((i%4)*512, floori(i/4.0)*512)
			var at := cell + ((Vector2(512,512)-r.size)*0.5).floor()
			var texture: Texture2D = HIDDEN if i in [3,4] else APPROVED
			if not masked:
				draw_texture_rect_region(texture, Rect2(at,r.size),r)
			else:
				var runs: Array = EDGES.PARTS[i].runs
				for j in range(0,runs.size(),3):
					var pixel := Rect2(runs[j],runs[j+1],runs[j+2],1)
					draw_texture_rect_region(texture,Rect2(at+pixel.position,pixel.size),Rect2(r.position+pixel.position,pixel.size))
