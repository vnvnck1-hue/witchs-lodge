"""Assemble actual rendered game frames into a review animation; never alters game portrait assets."""
from pathlib import Path
from PIL import Image

folder = Path(__file__).resolve().parents[2] / "output" / "guest-floating-v2"
paths = sorted((folder / "frames").glob("*.png"))
if not paths:
    raise SystemExit("No recorded frames")
frames = []
for path in paths:
    with Image.open(path) as source:
        preview = source.convert("RGB")
        preview.thumbnail((800, 437), Image.Resampling.LANCZOS)
        frames.append(preview.quantize(colors=96, method=Image.Quantize.MEDIANCUT))
output = folder / "floating-guests-preview.gif"
frames[0].save(output, save_all=True, append_images=frames[1:], duration=125, loop=0, optimize=False)
print(f"PREVIEW {output} frames={len(frames)} bytes={output.stat().st_size}")
