extends SceneTree

func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/occult_cards_check.gd").new())
