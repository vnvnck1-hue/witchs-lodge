"""Record PNG dimensions/hashes and provenance; does not edit image pixels."""
from pathlib import Path
import hashlib
import json
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
IDS = ["axe_mercenary", "wool", "timber", "forest_monster", "card_back"]
TITLES = ["도끼 용병", "양털", "목재", "숲의 괴물", "공용 뒷면"]


def evidence(path):
    with Image.open(path) as image:
        data = {
            "path": path.relative_to(ROOT).as_posix(),
            "width": image.width,
            "height": image.height,
            "mode": image.mode,
            "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        }
        if image.mode == "RGBA":
            data["alpha_extrema"] = list(image.getchannel("A").getextrema())
            data["corner_alpha"] = [
                image.getpixel(p)[3] for p in (
                    (0, 0), (image.width - 1, 0),
                    (0, image.height - 1), (image.width - 1, image.height - 1),
                )
            ]
        return data


generation = json.loads((ROOT / "art/cards/generation.json").read_text(encoding="utf-8"))
generation_by_id = {entry["id"]: entry for entry in generation}
entries = []
for card_id, title in zip(IDS, TITLES):
    entries.append({
        "id": card_id,
        "title": title,
        "generation": generation_by_id[card_id],
        "source": evidence(ROOT / "art/cards/rounded" / f"{card_id}.png"),
        "full": evidence(ROOT / "godot/assets/cards" / f"{card_id}.png"),
        "hand": evidence(ROOT / "godot/assets/cards/hand" / f"{card_id}.png"),
    })

manifest = {
    "schema_version": 1,
    "date": "2026-10-13",
    "status": "production-deliverable",
    "generator": "built-in image_gen",
    "design_reference": "docs/kingdom-integration-design.md v0.3 §4",
    "format_reference": "art/concepts/cards/base-card-format-approved-v01.png",
    "prompt_set": "docs/prompts/cards/production-rounded-v02-prompts.md",
    "packaging": "Godot Image: trim transparent margin and resize, preserve generated alpha",
    "card_count": 4,
    "support_asset_count": 1,
    "shipping_png_count": 10,
    "catalog": "godot/assets/cards/catalog.json",
    "verification": "godot/assets/cards/verification.json",
    "export_verification": "art/cards/export-verification.json",
    "gallery": "godot/screenshots/cards/asset-gallery.png",
    "assets": entries,
}
target = ROOT / "art/cards/manifest.json"
target.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

global_path = ROOT / "art/manifest.json"
global_entries = json.loads(global_path.read_text(encoding="utf-8-sig"))
new_paths = {entry["source"]["path"] for entry in entries}
global_entries = [entry for entry in global_entries if entry["path"] not in new_paths]
for entry in entries:
    global_entries.append({
        **entry["source"], "title": entry["title"] + " · 라운드/투명 실사용 카드",
        "status": "production-deliverable",
        "source_filename": Path(entry["source"]["path"]).name,
        "provenance": "generated/edited with built-in image_gen; generated alpha preserved; see art/cards/manifest.json",
    })
global_path.write_text(json.dumps(global_entries, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Recorded {len(entries)} artwork sources and 10 shipping PNGs: {target}")
