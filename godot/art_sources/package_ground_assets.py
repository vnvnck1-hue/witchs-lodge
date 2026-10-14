"""Final deliverables and completion evidence from current source and packed renders."""
from pathlib import Path
import json,hashlib,zipfile
from PIL import Image
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT.parent/'output/painted-ground'
source=json.loads((OUT/'verification.json').read_text(encoding='utf-8'))
packed=json.loads((OUT/'pack-verification.json').read_text(encoding='utf-8'))
assert source['failures']==[] and packed['failures']==[]
assert len(source['coverage'])==len(packed['coverage'])==10
assert len(source['presets'])==len(packed['presets'])==11
comparisons=[]
for site in source['coverage']:
    id=site['site']
    a=np.array(Image.open(OUT/f'ground-only-{id}.png')).astype(np.float32)/255
    b=np.array(Image.open(OUT/f'pack-ground-only-{id}.png')).astype(np.float32)/255
    error=float(np.abs(a-b).mean())
    assert error<.003,(id,error)
    comparisons.append({'site':id,'source_pack_mean_pixel_error':error})
files=[ROOT/p for p in ['assets/ground/painted_snow_v1.png','assets/ground/painted_trail_v1.png',
    'assets/ground/painted_forest_v1.png','assets/ground/prop_blend_mask.png',
    'shaders/painted_ground.gdshader','shaders/colored_air.gdshaderinc','art_sources/build_ground_masks.py',
    'tools/review_painted_ground.gd','tools/verify_painted_ground.gd']]
manifest={'requirements':{
    'reference_style':'Ice Peake + Magic Forest + Forest, built-in imagegen reference inputs',
    'world_coverage':'120 x 120 m plane; four landmarks, four map edges, two connecting trails rendered',
    'prop_coordination':'132 authored runtime props in a 2048-square placement mask',
    'source_validation':source,'pack_validation':packed,'source_pack_comparison':comparisons},'files':[]}
for p in files:
    manifest['files'].append({'file':str(p.relative_to(ROOT)).replace('\\','/'),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
for p in [ROOT.parent/'build/WitchsLodge.pck',ROOT.parent/'build/WitchsLodge-painted-ground.pck']:
    manifest['files'].append({'file':str(p.relative_to(ROOT.parent)).replace('\\','/'),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(OUT/'delivery-manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf-8')
with zipfile.ZipFile(OUT/'WitchsLodge-PaintedGround.zip','w',zipfile.ZIP_DEFLATED) as z:
    for p in files:z.write(p,'godot/'+str(p.relative_to(ROOT)).replace('\\','/'))
    z.write(ROOT.parent/'docs/painted-ground.md','README.md')
    z.write(ROOT.parent/'docs/prompts/painted-ground-v1.md','prompts.md')
    for filename in ['before-after.png','exterior-gallery.png','pack-start.png','asset-manifest.json','delivery-manifest.json']:
        z.write(OUT/filename,'review/'+filename)
print('GROUND_DELIVERY_READY source/pack matched at 10 sites')
