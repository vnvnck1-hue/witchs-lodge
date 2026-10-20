extends SceneTree
const Catalog = preload("res://scripts/ui/card_catalog.gd")
func _initialize() -> void:
	var passed := true
	for hand in [false, true]:
		var expected := "res://assets/cards/races/beastfolk/" + ("hand/" if hand else "") + "gatherer.png"
		var texture: Texture2D = Catalog.texture_for("gatherer", "모미", hand)
		# Current CardFace wraps the source in an AtlasTexture, whose resource_path is empty.
		var source: Texture2D = texture.atlas if texture is AtlasTexture else texture
		var size := Vector2i(256,384) if hand else Vector2i(1024,1536)
		var ok := source != null and source.resource_path == expected and Vector2i(source.get_width(),source.get_height()) == size
		passed = passed and ok
		print(("PASS " if ok else "FAIL ") + "Momi " + ("hand" if hand else "full") + " source=" + source.resource_path)
	print("MOMI_RESULT=" + str(passed))
	quit(0 if passed else 1)
