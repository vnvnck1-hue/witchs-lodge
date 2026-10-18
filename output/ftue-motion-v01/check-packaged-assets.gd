extends SceneTree
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var workspace: String = OS.get_cmdline_user_args()[0].replace("\\", "/")
	var failures: Array = []
	var textures := 0
	var manifests: Array = []
	for n in range(1,5):
		var path := "assets/ui/ftue/motion/cut%d.json" % n
		var packed := FileAccess.get_file_as_string("res://"+path)
		var expected := FileAccess.get_file_as_string(workspace+"/godot/"+path)
		var same := packed == expected
		manifests.append({"cut":n,"matches_source":same})
		if not same:
			failures.append("Manifest differs: "+path)
		var manifest = JSON.parse_string(packed)
		if not manifest is Dictionary:
			failures.append("Invalid manifest: "+path)
			continue
		for layer in manifest.layers:
			var texture = load("res://assets/ui/ftue/motion/"+str(layer.file))
			if texture is Texture2D and texture.get_width() == int(layer.size[0]) and texture.get_height() == int(layer.size[1]):
				textures += 1
			else:
				failures.append("Texture missing or wrong size: "+str(layer.file))
	var frame = load("res://assets/ui/ftue/motion/panel_frame.png")
	if frame is Texture2D and frame.get_width() == 1920 and frame.get_height() == 1080:
		textures += 1
	else:
		failures.append("Panel frame missing or wrong size")
	var report := {"passed":failures.is_empty() and textures==44,"textures_loaded":textures,"manifests":manifests,"errors":failures}
	var out = FileAccess.open(workspace+"/output/ftue-motion-v01/packaged-assets-verification.json",FileAccess.WRITE)
	out.store_string(JSON.stringify(report,"  "))
	out.close()
	print("PACKAGED MOTION CHECK: textures=",textures," manifests=",manifests.size()," errors=",failures.size())
	quit(0 if report.passed else 1)
