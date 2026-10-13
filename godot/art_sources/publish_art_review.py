"""Record an exported build and assemble untouched concept/game captures."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import argparse, hashlib, json

args=argparse.ArgumentParser()
args.add_argument('--version',required=True)
args.add_argument('--target',default='art/concepts/environment/07-colored-forest-darkness.png')
opts=args.parse_args()
root=Path(__file__).resolve().parents[2]
shots=root/'godot/screenshots/art-refinement'
version=opts.version
target=root/opts.target
board=Image.new('RGB',(2400,650),'#191e31')
draw=ImageDraw.Draw(board)
font=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',28)
for index,(file,label) in enumerate([
    (target,'목표 원화 · 배경색을 머금은 숲의 어둠'),
    (shots/f'{version}-pack-clean.png',f'실제 게임 렌더 · {version} · 수정 진행 중')]):
    img=Image.open(file).convert('RGB')
    img.thumbnail((1200,600),Image.Resampling.LANCZOS)
    board.paste(img,(index*1200,50))
    draw.text((index*1200+18,7),label,font=font,fill='#edf0fa')
board.save(shots/f'comparison-{version}.png')

def sha(file):return hashlib.sha256(file.read_bytes()).hexdigest()
manifest=root/'art/manifest.json'
data=json.loads(manifest.read_text(encoding='utf-8-sig'))
if not any(item['path']==opts.target for item in data):
    w,h=Image.open(target).size
    data.append(dict(path=opts.target,title='배경색을 접목한 숲의 어둠',status='follow-up-atmosphere-reference',
        source_filename=target.name,provenance='edited with built-in image_gen following user feedback; atmosphere study',
        width=w,height=h,bytes=target.stat().st_size,sha256=sha(target)))
manifest.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
evidence=dict(version=version,status='in-progress',engine='Godot 4.7.2 Forward+',target=opts.target,
    assets={p.name:sha(p) for p in sorted((root/'godot/assets/painted').glob('*.glb'))},
    renders={p.name:sha(p) for p in sorted(shots.glob(f'{version}-pack-*.png'))},
    pck_sha256=sha(root/'build/WitchsLodge.pck'))
out=root/'godot/art_sources'
(out/'refinement_evidence.json').write_text(json.dumps(evidence,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(out/f'refinement_evidence-{version}.json').write_text(json.dumps(evidence,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('REVIEW_SAVED',shots/f'comparison-{version}.png','manifest_images',len(data),'assets',len(evidence['assets']))
