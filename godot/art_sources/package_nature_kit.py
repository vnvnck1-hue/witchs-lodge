"""Portable delivery bundle and machine-readable evidence with source SHA256."""
import hashlib,json,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT.parent/'output/nature-kit'
assets=json.loads((ROOT/'assets/nature/catalog.json').read_text(encoding='utf-8'))['assets']
verification=json.loads((OUT/'verification.json').read_text(encoding='utf-8'))
assert verification['count']==26 and verification['failures']==[]
assert all(e['non_manifold_edges']==0 for e in assets)
files=[]
for folder in ['assets/nature','scenes/props/nature']:
    files += [p for p in (ROOT/folder).rglob('*') if p.is_file() and p.suffix in ['.glb','.json','.tscn','.tres']]
files += [ROOT/p for p in ['art_sources/nature_kit.blend','art_sources/build_nature_kit.py',
    'scripts/visual/nature_models.gd','shaders/nature_prop.gdshader','shaders/card_style.gdshaderinc',
    'tools/build_nature_prefabs.gd','tools/verify_nature_kit.gd']]
entries=[{'file':str(p.relative_to(ROOT)).replace('\\','/'),'bytes':p.stat().st_size,
          'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in files]
# A/B card smoke ran with current gameplay in isolation and original visual models.
base=json.loads((OUT/'baseline-project/art_sources/card-core-verify.json').read_text(encoding='utf-8'))
current=json.loads((ROOT/'art_sources/card-core-verify.json').read_text(encoding='utf-8'))
bf=[e['check'] for e in base['results'] if not e['ok']]
cf=[e['check'] for e in current['results'] if not e['ok']]
assert bf==cf, 'Visual swap changed existing card smoke failures'
report={'assets':21,'prefabs':26,'triangles_total':sum(e['triangles'] for e in assets),
        'non_manifold_edges':0,'prefab_failures':verification['failures'],
        'tree_revision':'soft sculpted boughs, rounded ends and smooth normals',
        'card_smoke_comparison':{'checks':current['checks'],'baseline_failures':bf,'nature_failures':cf,
                                 'same_failures_with_original_visuals':True},'files':entries}
(OUT/'delivery-manifest.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf-8')
with zipfile.ZipFile(OUT/'WitchsLodge-NatureKit.zip','w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for p in files:z.write(p,'godot/'+str(p.relative_to(ROOT)).replace('\\','/'))
    z.write(ROOT.parent/'docs/nature-prop-kit.md','README.md')
    for f in ['nature-kit-contact-sheet.png','nature-kit-clusters.png','in-game.png','verification.json','delivery-manifest.json']:
        z.write(OUT/f,'preview/'+f)
print('NATURE_DELIVERY_READY',len(files),'files',len(bf),'pre-existing card check failures unchanged')
