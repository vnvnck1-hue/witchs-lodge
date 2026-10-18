extends SceneTree
const Prologue = preload("res://scripts/ui/prologue.gd")
const SHOTS = [[0, [2.6, 8.4]], [1, [4.0, 5.6]], [3, [3.4, 6.4]]]
var player
func _initialize() -> void:
	_run.call_deferred()
func _frames(n: int) -> void:
	for i in n:
		await process_frame
func _run() -> void:
	player = Prologue.new()
	root.add_child(player)
	await _frames(3)
	player.play()
	await _frames(3)
	player.set_process(false)
	for entry in SHOTS:
		var index: int = entry[0]
		if player.index != index:
			player._start_cut(index)
			if player.outgoing != null:
				player.outgoing.queue_free()
				player.outgoing = null
			await _frames(2)
		for at in entry[1]:
			player.current.evaluate(float(at))
			player.caption_panel.modulate.a = 1.0
			player._update_caption(float(at))
			await _frames(3)
			var target = "res://screenshots/ftue/motion/review-cut%d-%04.1f.png" % [index+1,at]
			root.get_viewport().get_texture().get_image().save_png(target)
			print("SHOT ", target, " motion=", player.motion_used)
	print("CAPTURE REVIEW DONE (cuts 1,2,4 only)")
	quit(0)
