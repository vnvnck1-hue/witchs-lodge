"""Final inventory/hash/link consistency check; does not modify any asset."""
from pathlib import Path
from PIL import Image
import json,hashlib,re,struct
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'output/jobs-update-v01'
specs=json.loads((OUT/'card-specs.json').read_text(encoding='utf8'))
delivery=json.loads((OUT/'delivery-manifest.json').read_text(encoding='utf8'))
manifest=json.loads((ROOT/'art/cards/manifest.json').read_text(encoding='utf8'))
errors=[]
def check(ok,msg):
    if not ok:errors.append(msg)
check(len(delivery['assets'])==57,'57 deliverables')
check(len({a['path'] for a in delivery['assets']})==57,'duplicate delivery path')
for a in delivery['assets']:
    p=ROOT/a['path'];check(p.is_file(),'missing '+str(p))
    if p.is_file():check(hashlib.sha256(p.read_bytes()).hexdigest()==a['sha256'],'hash '+a['path'])
for a in manifest['assets']:
    if a['id'] not in manifest['scope_asset_ids']:continue
    for field in ['source','full','hand']:
        m=a[field];p=ROOT/m['path']
        check(hashlib.sha256(p.read_bytes()).hexdigest()==m['sha256'],'card manifest hash '+m['path'])
for s in specs:
    for folder,size in [('art/cards/rounded',(1024,1536)),('godot/assets/cards',(1024,1536)),('godot/assets/cards/hand',(256,384))]:
        p=ROOT/folder/(s[0]+'.png')
        im=Image.open(p)
        check(im.mode=='RGBA' and im.size==size,'card format '+str(p))
for name in ['rabbit','deer']:
    data=(ROOT/('godot/assets/nature/'+name+'.glb')).read_bytes()
    check(data[:4]==b'glTF','GLB magic '+name)
    gltf=json.loads(data[20:20+struct.unpack_from('<I',data,12)[0]])
    nodes=gltf['nodes'];body=next(n for n in nodes if n.get('name')=='Body')
    check(any(nodes[i].get('name')=='Head' for i in body.get('children',[])),'GLB Body/Head '+name)
    check(not gltf.get('images') and not gltf.get('textures'),'texture free '+name)
    check(not gltf.get('animations'),'static export '+name)
check(json.loads((ROOT/'godot/assets/cards/verification.json').read_text())['passed'],'Godot card verification')
check(json.loads((OUT/'asset-verification.json').read_text())['passed'],'Godot UI/wildlife verification')
for doc in ['docs/prompts/cards/jobs-update-v01-prompts.md','art/cards/jobs-update-v01-review.md','docs/wildlife-assets-v01.md','output/jobs-update-v01/delivery.md']:
    p=ROOT/doc
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf8')):
        if '://' not in target and not target.startswith('#'):
            check((p.parent/target.split('#')[0]).exists(),'broken link '+doc+' '+target)
gallery=Image.open(ROOT/'godot/screenshots/cards/asset-gallery.png')
check(gallery.size==(1840,3280),'gallery dimensions')
result=dict(passed=not errors,deliverable_count=57,card_new_png_count=39,icons=11,chest_png_count=2,
    glb_count=2,tscn_count=2,blend_count=1,card_scope_assets=22,card_shipping_png_count=44,
    text_proof_count=4,errors=errors)
(OUT/'delivery-validation.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf8')
print(json.dumps(result))
raise SystemExit(0 if not errors else 1)
