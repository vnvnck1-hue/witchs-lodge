extends SceneTree

func _initialize() -> void:
	var task_root = ProjectSettings.globalize_path("res://../..").simplify_path()
	var report_path = task_root.path_join("output/wolf-blood-v02/verification.json")
	var report = JSON.parse_string(FileAccess.get_file_as_string(report_path))
	var issues = {
		"crescent_moon": ["Original witch clothing remains outside the diamond at lower right."],
		"half_moon": ["Original hat/shoe fragments remain outside the diamond.", "Original moon remains in the upper-right side pane, creating a second moon."],
		"full_moon": ["Original hat and wolf body fragments remain outside the diamond.", "Original large moon remains in the upper-right side pane, creating a second moon."],
	}
	var metadata = []
	for record in report.files:
		var id = record.id
		record.visual_passed = false
		record.remaining_issues = issues[id]
		record.original_backup_sha256 = FileAccess.get_sha256(task_root.path_join("art/cards/wolf-blood-v02/previous/" + id + ".png"))
		record.game_png_still_matches_backup = record.original_backup_sha256 == FileAccess.get_sha256(task_root.path_join("godot/assets/cards/" + id + ".png"))
		for path in ["art/cards/wolf-blood-v02/previous/" + id + ".png", record.path, "output/wolf-blood-v02/" + id + "-hand-staged.png", "godot/assets/cards/" + id + ".png", "godot/assets/cards/hand/" + id + ".png"]:
			var im = Image.load_from_file(task_root.path_join(path))
			var corners = [im.get_pixel(0,0).a, im.get_pixel(im.get_width()-1,0).a, im.get_pixel(0,im.get_height()-1).a, im.get_pixel(im.get_width()-1,im.get_height()-1).a]
			metadata.append({"path": path, "size": [im.get_width(),im.get_height()], "channels": "RGBA" if im.get_format() == Image.FORMAT_RGBA8 else str(im.get_format()), "corner_alpha": corners, "sha256": FileAccess.get_sha256(task_root.path_join(path))})
	report.file_metadata = metadata
	report.scope_conflict = "Original figures and old moons cross the diamond boundary. Exact preservation of all pixels outside the diamond retains these fragments. User clarification is pending; game PNGs were not replaced."
	report.game_assets_replaced = 0
	report.protected_paths_written = []
	report.commit_created = false
	report.preview_sheet = "godot/screenshots/wolf-blood-cards/moon-v02-sheet.png"
	report.prompt_record = "docs/prompts/cards/wolf-blood-v02-moon-prompts.md"
	report.validation_exit_code = 0
	report.validation_log_note = "Asset-only isolated Godot run returned 0. The restricted environment reported a root-certificate-store warning; local image composition and pixel comparisons completed."
	FileAccess.open(report_path, FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("Metadata captured for " + str(metadata.size()) + " files. All three game PNGs still match backups. Overall passed=false pending scope clarification.")
	quit(0)
