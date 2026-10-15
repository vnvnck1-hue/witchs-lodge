"""Refresh the handoff's hashes, preserve existing provenance, build QA crops."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'output/jobs-update-v01'
specs=json.loads((OUT/'card-specs.json').read_text(encoding='utf8'))
generation=json.loads((OUT/'generation-record.json').read_text(encoding='utf8'))
gen={a['id']:a for a in generation['assets']}
ids=['axe_mercenary','wool','timber','forest_monster','frost_rune','ward_lantern','guest_invitation','lamb']+[s[0] for s in specs]+['card_back']
def metadata(relative):
    p=ROOT/relative
    data=dict(path=relative,bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
    if p.suffix=='.png':
        im=Image.open(p);alpha=im.getchannel('A');w,h=im.size
        data.update(width=w,height=h,mode=im.mode,alpha_extrema=alpha.getextrema(),
            corner_alpha=[alpha.getpixel(t) for t in [(0,0),(w-1,0),(0,h-1),(w-1,h-1)]])
    return data
manifest_path=ROOT/'art/cards/manifest.json'
manifest=json.loads(manifest_path.read_text(encoding='utf8'))
assets={a['id']:a for a in manifest['assets']}
for id in ids:
    entry=assets.setdefault(id,dict(id=id,title=next((s[1] for s in specs if s[0]==id),id)))
    for field,folder in [('source','art/cards/rounded'),('full','godot/assets/cards'),('hand','godot/assets/cards/hand')]:
        entry[field]=metadata(folder+'/'+id+'.png')
    if id in gen:
        g=gen[id]
        entry['generation']=dict(id=id,generated_file=re.search(r'as (.+?\.png) by default',g['output_hint'])[1].split('\\')[-1],
            project_source='art/cards/rounded/'+id+'.png',prompt_id=id+('-alpha-final' if g.get('alpha_final_prompt') else ''),
            generator='built-in image_gen',prompt_set='docs/prompts/cards/jobs-update-v01-prompts.md')
        entry['printed_text']=dict(title=next(s[1] for s in specs if s[0]==id),category=next(s[2] for s in specs if s[0]==id),rules=next(s[3] for s in specs if s[0]==id))
manifest['assets']=[assets[id] for id in ids]+[v for k,v in assets.items() if k not in ids]
manifest.update(date='2026-10-15',card_count=21,support_asset_count=1,shipping_png_count=44,source_png_count=22,
    handoff='docs/handoff/codex-jobs-update-v01.md',visual_review='art/cards/jobs-update-v01-review.md',
    text_proof='godot/screenshots/cards/jobs-update-v01-text-proof-01.png',
    text_proofs=['godot/screenshots/cards/jobs-update-v01-text-proof-%02d.png'%i for i in range(1,5)],
    scope_asset_ids=ids,count_note='Existing nine include shared back; nine plus thirteen = 22 total assets.',
    latest_prompt_set='docs/prompts/cards/jobs-update-v01-prompts.md')
manifest['prompt_sets']=list(dict.fromkeys(manifest.get('prompt_sets',[])+['docs/prompts/cards/jobs-update-v01-prompts.md']))
manifest_path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
deliverables=[]
for s in specs:
    for folder in ['art/cards/rounded','godot/assets/cards','godot/assets/cards/hand']:
        deliverables.append(metadata(folder+'/'+s[0]+'.png'))
for id in ['icon_timber','icon_raw_meat','icon_rabbit_pelt','icon_treasure_chest','icon_relic_unknown','icon_moonlit_charm','icon_hearth_ember','icon_old_tree_heart','icon_wolf_fang_pendant','icon_frost_queen_tear','icon_arrow']:
    deliverables.append(metadata('godot/assets/ui/icons/'+id+'.png'))
for id in ['chest_closed','chest_open']:deliverables.append(metadata('godot/assets/ui/'+id+'.png'))
for id in ['rabbit','deer']:
    deliverables.append(metadata('godot/assets/nature/'+id+'.glb'))
    deliverables.append(metadata('godot/scenes/props/nature/'+id+'.tscn'))
deliverables.append(metadata('godot/art_sources/wildlife.blend'))
assert len(deliverables)==57
(OUT/'delivery-manifest.json').write_text(json.dumps(dict(date='2026-10-15',deliverable_count=57,assets=deliverables),ensure_ascii=False,indent=2)+'\n',encoding='utf8')
# QA only: final shipping pixels, no resampling of text; four cards per proof.
proof_paths=[]
for batch in range(4):
    subset=specs[batch*4:batch*4+4]
    sheet=Image.new('RGBA',(2048,780*((len(subset)+1)//2)),'#514861')
    for i,s in enumerate(subset):
        im=Image.open(ROOT/('godot/assets/cards/'+s[0]+'.png'))
        x=(i%2)*1024;y=(i//2)*780
        sheet.alpha_composite(im.crop((0,0,1024,320)),(x,y))
        sheet.alpha_composite(im.crop((0,1100,1024,1536)),(x,y+330))
    relative='godot/screenshots/cards/jobs-update-v01-text-proof-%02d.png'%(batch+1)
    sheet.save(ROOT/relative);proof_paths.append(relative)
(OUT/'text-proof-index.json').write_text(json.dumps(dict(source='final shipping PNGs, 1:1 pixel crops',proofs=proof_paths),indent=2),encoding='utf8')
print('JOBS_MANIFEST',len(ids),'card assets;',len(deliverables),'new deliverables;',len(proof_paths),'text proofs')
