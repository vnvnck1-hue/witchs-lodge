extends SceneTree
const EDGES := preload("res://assets/ui/hand_workbench/approved/edge_geometry.gd")
const APPROVED := preload("res://assets/ui/hand_workbench/approved/layout-v04.png")
const HIDDEN := preload("res://assets/ui/hand_workbench/approved/layout-v03.png")

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1600,1000)
	var canvas := Preview.new()
	canvas.size = Vector2(1600,1000)
	root.add_child(canvas)
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../output/hand-workbench-runtime-v04/edge-review.png")
	quit()

class Preview extends Control:
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO,size),Color8(230,190,175))
		for i in EDGES.PARTS.size():
			var p: Dictionary = EDGES.PARTS[i]
			var r: Rect2 = p.rect
			var at := Vector2(20+(i%4)*395,40+floori(i/4.0)*480)
			var k := minf(370/r.size.x,400/r.size.y)
			var texture: Texture2D = HIDDEN if p.hidden else APPROVED
			var runs: Array = p.runs
			for j in range(0,runs.size(),3):
				var pixel := Rect2(runs[j],runs[j+1],runs[j+2],1)
				draw_texture_rect_region(texture,Rect2(at+pixel.position*k,pixel.size*k),Rect2(r.position+pixel.position,pixel.size))
