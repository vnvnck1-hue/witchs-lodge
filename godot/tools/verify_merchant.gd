extends SceneTree
## 떠돌이 행상 브로크·상점 자동 검증(docs/merchant-shop-v01.md).
## 실행: godot --headless --path . --script res://tools/verify_merchant.gd
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/merchant_check.gd").new())
