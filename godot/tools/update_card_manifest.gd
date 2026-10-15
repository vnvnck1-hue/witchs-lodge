extends SceneTree
## Refresh provenance and checksums without modifying any image or gameplay data.
const NEW_CARDS := {
 "frost_rune": ["서리 룬", "exec-86b137e8-b710-418c-9125-63b540ded247.png", "frost_rune-corners-final"],
 "ward_lantern": ["수호 등불", "exec-9afdd235-98ea-470e-bd56-4eded27413fd.png", "ward_lantern"],
 "guest_invitation": ["숙박 초대장", "exec-8cb8b466-faa3-4d50-b9b7-9b54a94affcc.png", "guest_invitation"],
 "lamb": ["새끼양", "exec-82b982bc-1b78-4976-8bab-b1f5a65472f6.png", "lamb-template-final"]
}

func _initialize() -> void:
 var path := ProjectSettings.globalize_path("res://../art/cards/manifest.json")
 var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
 var assets: Array = manifest.assets
 for id in NEW_CARDS:
  var existing := false
  for entry in assets:
   if entry.id == id:
    existing = true
  if not existing:
   assets.insert(assets.size() - 1, {"id": id, "title": NEW_CARDS[id][0]})
 for entry in assets:
  var id: String = entry.id
  if NEW_CARDS.has(id):
   entry.generation = {
    "id": id, "generated_file": NEW_CARDS[id][1],
    "project_source": "art/cards/rounded/" + id + ".png",
    "prompt_id": NEW_CARDS[id][2], "generator": "built-in image_gen",
    "prompt_set": "docs/prompts/cards/new-cards-v01-prompts.md"
   }
  entry.source = _metadata("art/cards/rounded/" + id + ".png")
  entry.full = _metadata("godot/assets/cards/" + id + ".png")
  entry.hand = _metadata("godot/assets/cards/hand/" + id + ".png")
 manifest.date = "2026-10-15"
 manifest.schema_version = 1
 manifest.card_count = 8
 manifest.support_asset_count = 1
 manifest.shipping_png_count = 18
 manifest.source_png_count = 9
 manifest.prompt_sets = ["docs/prompts/cards/production-rounded-v02-prompts.md", "docs/prompts/cards/new-cards-v01-prompts.md"]
 manifest.handoff = "docs/handoff/codex-new-cards-v01.md"
 manifest.export_verification_scope = "Historical 2026-10-13 result: original 4 cards and back only; not rerun for new cards."
 manifest.visual_review = "art/cards/new-cards-v01-review.md"
 manifest.text_proof = "godot/screenshots/cards/new-cards-v01-text-proof.png"
 var file := FileAccess.open(path, FileAccess.WRITE)
 file.store_string(JSON.stringify(manifest, "  ", false) + "\n")
 print("CARD_MANIFEST_UPDATED ", assets.size(), " sources, 18 shipping PNGs")
 quit()

func _metadata(relative: String) -> Dictionary:
 var path := ProjectSettings.globalize_path("res://../" + relative)
 var img := Image.load_from_file(path)
 if img == null:
  push_error("Missing image: " + relative)
  quit(1)
  return {}
 var rgba := img.get_format() == Image.FORMAT_RGBA8
 var data := img.get_data()
 var amin := 255
 var amax := 0
 for i in range(3, data.size(), 4):
  amin = mini(amin, data[i])
  amax = maxi(amax, data[i])
 var w := img.get_width()
 var h := img.get_height()
 var corners: Array = []
 for pos in [Vector2i.ZERO, Vector2i(w - 1, 0), Vector2i(0, h - 1), Vector2i(w - 1, h - 1)]:
  corners.append(roundi(img.get_pixelv(pos).a * 255))
 print(relative, " center_alpha=", img.get_pixel(w / 2, h / 2).a, " corners=", corners)
 return {
  "path": relative, "width": w, "height": h,
  "mode": "RGBA" if rgba else str(img.get_format()),
  "bytes": FileAccess.get_file_as_bytes(path).size(),
  "sha256": FileAccess.get_sha256(path),
  "alpha_extrema": [amin, amax], "corner_alpha": corners
 }
