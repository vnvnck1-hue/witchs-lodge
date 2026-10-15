extends SceneTree
## External runner: all game scripts, catalogue and textures resolve from the exported PCK.
func _initialize() -> void:
	var checker := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--occult-checker="):
			checker = arg.trim_prefix("--occult-checker=")
	if checker.is_empty():
		push_error("Missing external checker path")
		quit(1)
		return
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load(checker).new())
