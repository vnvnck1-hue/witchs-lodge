extends SceneTree

func _initialize() -> void:
	var names := ["prologue_01", "prologue_02", "prologue_03", "prologue_04", "title_bg", "witch_portrait", "witch_locked"]
	var assets: Array = []
	var passed := true
	for asset_name in names:
		var path: String = "res://assets/ui/ftue/%s.png" % asset_name
		var texture := load(path) as Texture2D
		var expected := Vector2i(512, 768) if str(asset_name).begins_with("witch_") else Vector2i(1920, 1080)
		var item_passed := texture != null
		var size := Vector2i.ZERO
		if texture != null:
			size = Vector2i(texture.get_width(), texture.get_height())
			item_passed = size == expected and texture.get_image() != null
		assets.append({"path": path, "width": size.x, "height": size.y, "passed": item_passed})
		passed = passed and item_passed
	var result := {"engine": Engine.get_version_info().string, "scope": "Seven imported textures in the isolated FTUE project", "assets": assets, "passed": passed}
	var target := ProjectSettings.globalize_path("res://../../texture-load-verification.json")
	var output := FileAccess.open(target, FileAccess.WRITE)
	if output == null:
		push_error("Cannot write texture verification result: " + target)
		quit(1)
		return
	output.store_string(JSON.stringify(result, "  "))
	output.close()
	print(JSON.stringify(result))
	quit(0 if passed else 1)
