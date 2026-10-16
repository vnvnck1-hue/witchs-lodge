extends SceneTree
## 직업 분화 v1 자동 검증 실행기. 실행: godot --headless --path . --script res://tools/verify_jobs.gd
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/jobs_check.gd").new())
