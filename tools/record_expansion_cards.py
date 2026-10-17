"""Expansion card backup and deterministic delivery evidence (no artwork painting)."""
from pathlib import Path
import hashlib, json, shutil, sys
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'output/expansion-cards-v01'
PLAN = json.loads((OUT / 'generation-plan.json').read_text(encoding='utf-8'))
ENTRIES = PLAN['entries']
IDS = {e['id'] for e in ENTRIES}

def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def write(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')

def protected():
    paths = []
    for folder in ['godot/scripts', 'godot/scenes', 'godot/shaders', 'build', 'art/concepts/cards/roles-individual-v02']:
        paths.extend(p for p in (ROOT/folder).rglob('*') if p.is_file())
    paths.append(ROOT/'godot/assets/cards/catalog.json')
    for folder in ['art/cards/role-format-v02', 'art/cards/rounded', 'godot/assets/cards', 'godot/assets/cards/hand']:
        paths.extend(p for p in (ROOT/folder).glob('*.png') if p.stem not in IDS)
    return {p.relative_to(ROOT).as_posix():digest(p) for p in paths}

def backup():
    if (OUT/'baseline.json').exists():
        raise RuntimeError('Backup exists; do not replace baseline')
    paths=[]
    for e in ENTRIES:
        for folder in ['art/cards/role-format-v02', 'art/cards/rounded', 'godot/assets/cards', 'godot/assets/cards/hand']:
            p=ROOT/folder/(e['id']+'.png')
            if p.exists(): paths.append(p)
    paths += [ROOT/p for p in ['art/cards/README.md', 'art/cards/manifest.json', 'godot/tools/package_card_assets.gd', 'godot/tools/verify_card_assets.gd', 'godot/assets/cards/verification.json', 'godot/assets/cards/packaging.json', 'godot/screenshots/cards/asset-gallery.png'] if (ROOT/p).exists()]
    records=[]
    for p in paths:
        target=OUT/'before'/p.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(p,target)
        records.append({'path':p.relative_to(ROOT).as_posix(), 'sha256':digest(p)})
    write(OUT/'baseline.json', {'protected':protected(), 'backup':records})
    print('BACKUP',len(records),'protected',len(protected()))

def metadata(p):
    with Image.open(p) as im:
        w,h=im.size
        a=im.getchannel('A') if im.mode=='RGBA' else None
        return {'path':p.relative_to(ROOT).as_posix(),'width':w,'height':h,'mode':im.mode,'bytes':p.stat().st_size,'sha256':digest(p),'pixel_sha256':hashlib.sha256(im.tobytes()).hexdigest(),'corner_alpha':[a.getpixel(pt) for pt in [(0,0),(w-1,0),(0,h-1),(w-1,h-1)]] if a else [],'alpha_extrema':a.getextrema() if a else []}

def proofs():
    folder=OUT/'text-proof'
    folder.mkdir(exist_ok=True)
    for e in ENTRIES:
        # Native-pixel crops for visual inspection; shipping artwork is never painted.
        with Image.open(ROOT/'godot/assets/cards'/(e['id']+'.png')) as im:
            proof=Image.new('RGBA',(1024,786),(40,36,48,255))
            proof.paste(im.crop((0,0,1024,350)),(0,0))
            proof.paste(im.crop((0,1100,1024,1536)),(0,350))
            proof.save(folder/(e['id']+'.png'))
    print('TEXT_PROOFS',len(ENTRIES))

def finalize():
    results=json.loads((OUT/'generation-results.json').read_text(encoding='utf-8'))
    by_id={x['id']:x for x in results}
    baseline=json.loads((OUT/'baseline.json').read_text(encoding='utf-8'))
    assets=[]
    errors=[]
    for e in ENTRIES:
        records={}
        for key,folder,size in [('master','art/cards/role-format-v02',(1024,1536)),('source','art/cards/rounded',(1024,1536)),('full','godot/assets/cards',(1024,1536)),('hand','godot/assets/cards/hand',(256,384))]:
            p=ROOT/folder/(e['id']+'.png')
            info=metadata(p)
            with Image.open(p) as im:
                w,h=im.size
                inset=max(3,w//64)
                points=[(w//2,h//2),(w//2,inset),(inset,h//2),(w-1-inset,h//2),(w//2,h-1-inset)]
                alphas=[im.getpixel(pt)[3] for pt in points] if im.mode=='RGBA' else []
            info['centre_and_edge_alpha']=alphas
            if (info['width'],info['height'])!=size or info['mode']!='RGBA' or max(info['corner_alpha'],default=255)>=5.1 or min(alphas,default=0)<=242.25:
                errors.append(info['path'])
            records[key]=info
        if records['master']['sha256']!=records['source']['sha256']:
            errors.append('master/rounded mismatch '+e['id'])
        for prev in baseline['backup']:
            if prev['path']==records['full']['path'] and prev['sha256']==records['full']['sha256']:
                errors.append('placeholder unchanged '+e['id'])
        assets.append({'id':e['id'],'title':e['name'],'visual_role':e['role'],'category':e['category'],'printed_rules':e['printed_rules'],
            'generation':{'generator':'built-in image_gen','generated_file':by_id[e['id']]['generated_file'],'project_source':records['master']['path'],'prompt_set':'docs/prompts/cards/expansion-cards-v01-prompts.md','prompt_id':e['id'],'reference':e['reference'],'style_reference':e['style_reference'],'history':by_id[e['id']].get('history',[])},
            **records,'visual_review':'art/cards/expansion-cards-v01-review.md'})
    preserved={}
    concurrent=[]
    for rel,sha in baseline['protected'].items():
        p=ROOT/rel
        same=p.exists() and digest(p)==sha
        if rel.startswith('art/') or (rel.startswith('godot/assets/cards/') and rel.endswith('.png')):
            preserved[rel]=same
            if not same: errors.append('protected PNG changed '+rel)
        elif not same: concurrent.append(rel)
    verify=json.loads((ROOT/'godot/assets/cards/verification.json').read_text(encoding='utf-8'))
    if not verify.get('passed') or verify.get('asset_count')!=39: errors.append('Godot verification')
    report={'passed':not errors,'failures':errors,'new_card_count':12,'required_png_count':36,'rounded_mirror_png_count':12,'inspected_png_count':48,'godot_asset_count':39,'godot_texture_count':78,'protected_art_and_existing_pngs':preserved,'protected_art_and_existing_pngs_unchanged':all(preserved.values()),'concurrent_changes_observed_in_forbidden_paths':concurrent,'catalog_sha256_at_delivery':digest(ROOT/'godot/assets/cards/catalog.json'),'catalog_baseline_sha256':baseline['protected']['godot/assets/cards/catalog.json'],'commit_created':False,'assets':assets}
    write(OUT/'delivery-manifest.json',report)
    if errors:
        print('FAIL',json.dumps(errors,ensure_ascii=False)); sys.exit(1)
    manifest_path=ROOT/'art/cards/manifest.json'
    manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
    remaining=[a for a in manifest['assets'] if a['id'] not in IDS]
    manifest.update(date='2026-10-17',card_count=38,source_png_count=39,shipping_png_count=78,visual_review='art/cards/expansion-cards-v01-review.md',catalog_sha256=report['catalog_sha256_at_delivery'])
    manifest['assets']=remaining+assets
    manifest['expansion_prompt_set']='docs/prompts/cards/expansion-cards-v01-prompts.md'
    manifest['expansion_delivery_manifest']='output/expansion-cards-v01/delivery-manifest.json'
    manifest['expansion_export_status']='Not exported here; catalog placeholder flags, gameplay and PCK belong to Claude. Existing export_pack/export_verification describe the prior 27-asset delivery.'
    write(manifest_path,manifest)
    print('DELIVERY PASS: 12 cards; 36 required PNGs + 12 rounded mirrors; existing art preserved')

if __name__=='__main__':
    if sys.argv[1]=='backup': backup()
    elif sys.argv[1]=='proofs': proofs()
    elif sys.argv[1]=='finalize': finalize()
