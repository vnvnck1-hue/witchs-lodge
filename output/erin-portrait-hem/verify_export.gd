extends SceneTree
func _initialize():
    var original: Texture2D = load("res://assets/portraits/guest_erin_cutout.png")
    var original_data = original.get_image().get_data()
    var packed = ProjectSettings.load_resource_pack(ProjectSettings.globalize_path("res://../WitchsLodge.exe"), true)
    var profiles = ResourceLoader.load("res://scripts/ui/guest_profiles.gd", "", ResourceLoader.CACHE_MODE_IGNORE)
    var erin = profiles.guest_profile("erin")
    var shader = ResourceLoader.load("res://shaders/guest_portrait_motion.gdshader", "", ResourceLoader.CACHE_MODE_IGNORE)
    var portrait = ResourceLoader.load("res://assets/portraits/guest_erin_cutout.png", "", ResourceLoader.CACHE_MODE_IGNORE)
    var pixels_match = portrait.get_image().get_data() == original_data
    var ok = packed and erin.get("dialogue_portrait_scale") == 1.06 and erin.get("dialogue_portrait_rounded_hem", false) and shader.code.contains("if (rounded_hem)") and pixels_match
    print("PACKED EXE: mounted=", packed, ", scale=", erin.get("dialogue_portrait_scale"), ", hem=", erin.get("dialogue_portrait_rounded_hem"), ", texture pixels identical=", pixels_match)
    print("RESULT ", "PASS" if ok else "FAIL")
    quit(0 if ok else 1)
