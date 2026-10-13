extends SceneTree
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/card_core_check.gd").new())
