extends SceneTree
## Isolated visual experiments; does not change the normal game scene or materials.

var mode := "baseline"
var output := "res://screenshots/card-style-review/baseline.png"
var shader_cache: Dictionary = {}
var material_cache: Dictionary = {}
var changed_surfaces := 0

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--review="): mode = arg.trim_prefix("--review=")
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
	call_deferred("_run")

func _run() -> void:
	# Historical comparison starts from the pre-preset appearance.
	load("res://scripts/visual/screen_style.gd").current_id = "original"
	if mode not in ["baseline", "lighting", "soft_bands"]:
		push_error("Unknown review mode: " + mode)
		quit(1)
		return
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	game.hud.visible = false
	if mode != "baseline":
		game.world.env.ambient_light_energy = 0.42
		game.world.sun.light_energy = 0.88
		game.world.sun.shadow_opacity = 0.90
		game.world.sun.shadow_blur = 1.1
		game.world.sun.light_angular_distance = 1.4
		game.world.env.ssao_radius = 0.85
		game.world.env.ssao_intensity = 1.0
		game.world.env.ssao_power = 1.2
		game.world.env.glow_intensity = 0.22
	if mode == "soft_bands":
		_patch_materials(game)
	game.process_mode = Node.PROCESS_MODE_DISABLED
	_add_cards()
	await create_timer(1.5).timeout
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output.get_base_dir()))
	var result := root.get_texture().get_image().save_png(output)
	var metadata := {
		"mode": mode, "image": output, "engine": Engine.get_version_info(),
		"ambient_energy": game.world.env.ambient_light_energy,
		"moon_energy": game.world.sun.light_energy,
		"shadow_blur": game.world.sun.shadow_blur,
		"light_angular_distance": game.world.sun.light_angular_distance,
		"ssao_radius": game.world.env.ssao_radius,
		"ssao_intensity": game.world.env.ssao_intensity,
		"glow_intensity": game.world.env.glow_intensity,
		"changed_surfaces": changed_surfaces,
		"viewport": str(root.get_visible_rect().size), "save_error": result,
		"cards": "Noninteractive review-only CanvasLayer; not gameplay implementation"
	}
	var file := FileAccess.open(output.get_basename() + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(metadata, "\t"))
	print("CARD_STYLE_REVIEW ", JSON.stringify(metadata))
	quit(0 if result == OK else 1)

func _patch_materials(node: Node) -> void:
	if node is MeshInstance3D:
		for surface in node.mesh.get_surface_count():
			var source: Material = node.get_active_material(surface)
			if not source is ShaderMaterial: continue
			var path: String = source.shader.resource_path
			if path not in ["res://shaders/painted_prop.gdshader", "res://shaders/painted_snow.gdshader", "res://shaders/stylized.gdshader"]: continue
			var key := source.get_instance_id()
			if not material_cache.has(key):
				var material: ShaderMaterial = source.duplicate()
				if not shader_cache.has(path):
					var shader := Shader.new()
					var code: String = source.shader.code
					if path.ends_with("stylized.gdshader"):
						code = code.replace("float d = smoothstep(band_lo, band_hi, w);", "float continuous = smoothstep(band_lo, band_hi, w);\n\tfloat bands = .20 + .55 * smoothstep(.36,.44,w) + .25 * smoothstep(.70,.78,w);\n\tfloat d = LIGHT_IS_DIRECTIONAL ? mix(continuous,bands,.65) : continuous;")
					else:
						code = code.replace("float d = smoothstep(.06,.94,(dot(NORMAL,LIGHT)+.32)/1.32);", "float w = clamp((dot(NORMAL,LIGHT)+.08)/1.08,0.0,1.0);\n\tfloat continuous = smoothstep(.06,.94,w);\n\tfloat bands = .20 + .55 * smoothstep(.36,.44,w) + .25 * smoothstep(.70,.78,w);\n\tfloat d = LIGHT_IS_DIRECTIONAL ? mix(continuous,bands,.65) : continuous;")
					shader.code = code
					shader_cache[path] = shader
				material.shader = shader_cache[path]
				if not path.ends_with("stylized.gdshader"):
					material.set_shader_parameter("painted_fill", float(source.get_shader_parameter("painted_fill")) * .60)
				material_cache[key] = material
			node.set_surface_override_material(surface, material_cache[key])
			changed_surfaces += 1
	for child in node.get_children(): _patch_materials(child)

func _add_cards() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	root.add_child(layer)
	var size := root.get_visible_rect().size
	var scale_factor: float = size.x / 1774.0
	var card_size := Vector2(204, 306) * scale_factor
	var files := ["base-card-format-approved-v01.png", "wool-resource-v01.png", "forest-monster-summon-v01.png"]
	for i in 3:
		var image := Image.load_from_file(ProjectSettings.globalize_path("res://../art/concepts/cards/" + files[i]))
		var card := TextureRect.new()
		card.texture = ImageTexture.create_from_image(image)
		card.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card.size = card_size
		card.position = Vector2(size.x * .5 + (i - 1) * 220 * scale_factor - card_size.x * .5, size.y - card_size.y - 14 * scale_factor)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(card)
