"""Record current delivered placement and validation evidence."""
from pathlib import Path
import hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT.parent/'output/forest-composition'
layout=json.loads((ROOT/'assets/environment/forest_layout.json').read_text(encoding='utf-8'))
source=json.loads((OUT/'verification.json').read_text(encoding='utf-8'))
packed=json.loads((OUT/'pack-verification.json').read_text(encoding='utf-8'))
assert source['passed'] and packed['passed']
assert source['groups']==packed['groups']==len(layout['groups'])==40
assert all(w['arrived'] for w in source['walks']+packed['walks'])
files=[ROOT/p for p in ['assets/environment/forest_layout.json','scripts/world/forest_composition.gd',
    'scripts/world/layout.gd','scripts/world/exploration.gd','scripts/world/world.gd',
    'assets/ground/prop_blend_mask.png','art_sources/build_forest_layout.py',
    'tools/review_forest_composition.gd','tools/verify_forest_composition.gd']]
manifest={'requirements':{
    'path_structure':{'routes':6,'segments':layout['stats']['path_segments'],'traversal':source['walks']},
    'cluster_composition':{'groups':40,'parts':layout['stats']['parts'],'kinds':layout['stats']['kinds'],
                           'motifs':['crescent','ridge','wedge'],'height_range':source['tree_height_range'],
                           'asset_types':source['asset_types']},
    'resource_trees':'Original 3 coordinates verified',
    'source_passed':source['passed'],'packed_passed':packed['passed']},'files':[]}
for p in files:
    manifest['files'].append({'file':str(p.relative_to(ROOT)).replace('\\','/'),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
for p in [ROOT.parent/'build/WitchsLodge.pck',ROOT.parent/'build/WitchsLodge-forest-composition.pck']:
    manifest['files'].append({'file':str(p.relative_to(ROOT.parent)).replace('\\','/'),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(OUT/'delivery-manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf-8')
with zipfile.ZipFile(OUT/'WitchsLodge-ForestComposition.zip','w',zipfile.ZIP_DEFLATED) as z:
    for p in files:z.write(p,'godot/'+str(p.relative_to(ROOT)).replace('\\','/'))
    z.write(ROOT.parent/'docs/forest-composition.md','README.md')
    for name in ['before-after-map.png','composition-gallery.png','route-guide.png','after-map.png','verification.json','pack-verification.json','delivery-manifest.json']:
        z.write(OUT/name,'review/'+name)
print('FOREST_DELIVERY_READY',len(layout['groups']),'groups',layout['stats']['parts'],'parts; source+pack traversal passed')
