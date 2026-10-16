"""Resize image_gen masters only. Preserve alpha; do not repaint or mask."""
from pathlib import Path
from PIL import Image
import hashlib,json
ROOT=Path(__file__).resolve().parents[2]
source=ROOT/'art/ui/jobs-update-v01'
target=ROOT/'godot/assets/ui'
records=[]
for path in sorted(source.glob('*.png')):
    size=96 if path.stem.startswith('icon_') else 512
    dest=target/('icons' if size==96 else '')/path.name
    dest.parent.mkdir(parents=True,exist_ok=True)
    image=Image.open(path).convert('RGBA')
    image.resize((size,size),Image.Resampling.LANCZOS).save(dest)
    out=Image.open(dest)
    alpha=out.getchannel('A')
    records.append(dict(id=path.stem,source=path.relative_to(ROOT).as_posix(),
        path=dest.relative_to(ROOT).as_posix(),source_size=list(image.size),
        size=list(out.size),mode=out.mode,alpha_extrema=alpha.getextrema(),
        corner_alpha=[alpha.getpixel(p) for p in [(0,0),(size-1,0),(0,size-1),(size-1,size-1)]],
        sha256=hashlib.sha256(dest.read_bytes()).hexdigest()))
(ROOT/'output/jobs-update-v01/ui-packaging.json').write_text(json.dumps(records,indent=2),encoding='utf8')
print('JOBS_UI_PACKAGED',len(records))
