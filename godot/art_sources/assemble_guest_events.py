"""Review GIF from real game captures. Capture timestamps preserve the actual reading time."""
from pathlib import Path
from PIL import Image

folder = Path(__file__).resolve().parents[2] / "output" / "guest-events-v4"
paths = sorted((folder / "frames").glob("*.png"))
if not paths:
    raise SystemExit("No captured frames")
frames = []
durations = []
for index, path in enumerate(paths):
    with Image.open(path) as source:
        preview = source.convert("RGB")
        preview.thumbnail((960, 523), Image.Resampling.LANCZOS)
        frames.append(preview.quantize(colors=128, method=Image.Quantize.MEDIANCUT))
    elapsed = paths[index + 1].stat().st_mtime - path.stat().st_mtime if index + 1 < len(paths) else 0.7
    durations.append(max(100, min(700, round(elapsed * 100) * 10)))
output = folder / "guest-events-preview.gif"
frames[0].save(output, save_all=True, append_images=frames[1:], duration=durations, loop=0, optimize=False)
print(f"PREVIEW {output} frames={len(frames)} duration={sum(durations)/1000:.2f}s bytes={output.stat().st_size}")
webp = folder / "guest-events-preview.webp"
frames[0].convert("RGB").save(webp, save_all=True, append_images=[frame.convert("RGB") for frame in frames[1:]], duration=durations, loop=0, quality=78, method=4)
print(f"WEBP {webp} bytes={webp.stat().st_size}")
