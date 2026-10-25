"""Independent saved-file validation; never runs Godot or writes protected files."""
from pathlib import Path
import argparse, hashlib, json
import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[4]
OUT=ROOT/'art/lobby/layers-v01'; GAME=ROOT/'godot/assets/ui/lobby'
DRAFT=OUT/'drafts'; DOC=ROOT/'docs/handoff/codex-lobby-layers-v01.md'
SOURCE=ROOT/'art/concepts/lobby/races-closeup-distant-v02/03-races-closeup-distant.png'
ORDER=['lobby_characters.png','lobby_title.png','lobby_menu_continue.png','lobby_menu_new.png','lobby_menu_archive.png','lobby_menu_settings.png','lobby_menu_exit.png','lobby_menu_moon.png','lobby_menu_underline.png']

def verify(reviewed=False):
    report=json.loads((OUT/'verification.json').read_text(encoding='utf-8'))
    checks={}
    def check(name,value):
        checks[name]=bool(value)
        print(('PASS ' if value else 'FAIL ')+name)
    names=['lobby_bg.png','lobby_character_ids.png']+ORDER
    images={name:Image.open(GAME/name) for name in names}
    check('11 required PNG files',len(images)==11)
    check('all game PNGs 1920x1080',all(im.size==(1920,1080) for im in images.values()))
    check('background and IDs RGB',all(images[n].mode=='RGB' for n in names[:2]))
    check('9 foreground layers RGBA',all(images[n].mode=='RGBA' for n in ORDER))
    observed_imports=[p.name for p in sorted(GAME.glob('*.import'))]
    check('approved source hash',hashlib.sha256(SOURCE.read_bytes()).hexdigest()=='57f0b75bff33e4c85755a030172a3cb9942ede345b41e717efa528c5820afbdf')
    source=np.asarray(Image.open(SOURCE).convert('RGB'))
    layout=json.loads((GAME/'lobby_layout.json').read_text(encoding='utf-8'))['layers']
    for name in ORDER:
        im=images[name]; data=np.asarray(im); a=data[...,3]
        check(name+' transparent exterior',np.any(a==0) and np.all(data[a==0,:3]==0))
        box=im.getchannel('A').getbbox(); x,y,r,b=box
        check(name+' exact bbox',layout[name]=={'x':x,'y':y,'w':r-x,'h':b-y})
        check(name+' opaque source pixels unchanged',np.array_equal(data[a==255,:3],source[a==255]))
    ids=np.asarray(images['lobby_character_ids.png'])
    char_alpha=np.asarray(images[ORDER[0]])[...,3]
    values=np.unique(ids[...,0]).tolist()
    check('IDs grayscale and discrete',np.array_equal(ids[...,0],ids[...,1]) and np.array_equal(ids[...,0],ids[...,2]) and values==[0,20,40,60,80,100,120,160,180,200,220,240])
    check('IDs background equals alpha zero',np.array_equal(ids[...,0]==0,char_alpha==0))
    composed=images['lobby_bg.png'].convert('RGBA')
    for name in ORDER: composed=Image.alpha_composite(composed,images[name])
    difference=np.abs(np.asarray(composed.convert('RGB'),dtype=np.int16)-source.astype(np.int16))
    yy,xx=np.mgrid[:1080,:1920]
    excluded=((xx>=1140)&(xx<1381)&(yy>=50)&(yy<850))|((xx>=1140)&(yy>=50)&(yy<291))
    check('exclusion mask is exactly documented seam strips',np.array_equal(excluded,np.asarray(Image.open(DRAFT/'verification-exclusion-mask.png'))>0))
    maximum=difference.max(-1)[~excluded]
    within2=float(np.mean(maximum<=2)*100);over8=float(np.mean(maximum>8)*100)
    check('most pixels within 2 RGB levels',within2>50)
    check('over 8 RGB levels strictly below 0.5%',over8<.5)
    check('independent composite matches reported statistics',abs(report['comparison']['over_8_percent']-over8)<1e-10 and abs(report['comparison']['within_2_percent']-within2)<1e-10)
    # Real scene landmarks outside restored regions remain original pixels.
    bg=np.asarray(images['lobby_bg.png'])
    landmarks={'lodge':(1280,855,1460,935),'lower_right_snow':(1430,920,1720,1080),'upper_right_sky':(1450,0,1920,48)}
    for name,(x,y,r,b) in landmarks.items():
        check('original '+name+' pixels preserved',np.array_equal(bg[y:b,x:r],source[y:b,x:r]))
    before=json.loads((DRAFT/'protected-paths-before.json').read_text(encoding='utf-8'))
    changed=[];missing=[]
    for name,stat in before.items():
        if name=='docs/handoff/codex-lobby-layers-v01.md':continue
        p=ROOT/name
        if not p.exists(): missing.append(name);continue
        now=p.stat()
        if now.st_size!=stat['size'] or now.st_mtime_ns!=stat['mtime_ns']:changed.append(name)
    original_doc=(DRAFT/'handoff-original.bin').read_bytes()
    check('handoff original bytes preserved as prefix',DOC.read_bytes().startswith(original_doc))
    protection={'method':'size and mtime_ns snapshot; observations include independent ongoing work; no protected paths written by either script', 'files_compared':len(before)-1,'changed':changed,'missing':missing,'handoff_original_prefix_preserved':DOC.read_bytes().startswith(original_doc),
      'observed_import_sidecars_not_written_by_this_task':observed_imports,
      'direct_writer_output_roots':['godot/assets/ui/lobby/','art/lobby/layers-v01/'],
      'godot_invoked_by_this_task':False,'exe_exported_by_this_task':False,'git_commit_by_this_task':False}
    (DRAFT/'protected-paths-verification.json').write_text(json.dumps(protection,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    report['saved_file_checks']=checks
    report['all_saved_file_checks_pass']=all(checks.values())
    report['protected_paths']=protection
    report['visual_review']={'status':'reviewed' if reviewed else 'pending','shift_pixels':[-6,-4],
      'artifacts':['sheet.png','ids-overlay.png','drafts/shifted-minus6-minus4.png','drafts/characters-on-checker.png','drafts/ui-on-checker.png'],
      'notes':'Full background, six panels, ID overlay, title/menu and figure edges inspected at native resolution.' if reviewed else 'Visual review still required.'}
    report['assets']['lobby_layout.json']={'sha256':hashlib.sha256((GAME/'lobby_layout.json').read_bytes()).hexdigest()}
    report['assets']={name:item for name,item in report['assets'].items() if name in names+['lobby_layout.json']}
    report['other_lobby_files_not_written_by_this_task']=[p.name for p in sorted(GAME.iterdir()) if p.is_file() and p.name not in names+['lobby_layout.json']]
    report['reproduction_sha256']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [DRAFT/'build_layers.py',DRAFT/'verify_delivery.py',DRAFT/'01-background-imagegen.png',OUT/'prompts.md']}
    (OUT/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(f'RESULT {sum(checks.values())}/{len(checks)}; within2={within2:.6f}%; over8={over8:.6f}%')
    if not all(checks.values()):raise SystemExit(1)

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--reviewed',action='store_true');args=parser.parse_args();verify(args.reviewed)
