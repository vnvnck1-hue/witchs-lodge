"""Independent disk validation. Writes only within art/lobby/wide-v01/."""
from pathlib import Path
from PIL import Image
import numpy as np
import json,hashlib,sys
from datetime import datetime,timezone

ROOT=Path(__file__).resolve().parents[4]
D=Path(__file__).resolve().parent
OUT=D.parent
A=ROOT/'godot/assets/ui/lobby'
DOC='docs/handoff/codex-lobby-wide-v01.md'
NAMES={'lobby_bg':'RGB','lobby_characters':'RGBA','lobby_character_ids':'RGB'}

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    checks=[]; files={}; preservation={}
    baseline=json.loads((D/'protected-before.json').read_text(encoding='utf-8'))
    def check(name,passed,**details):
        checks.append({'check':name,'passed':bool(passed),**details})
    for name,mode in NAMES.items():
        p=A/(name+'_wide.png'); src=A/(name+'.png')
        im=Image.open(p); original=Image.open(src)
        arr=np.array(im); old=np.array(original)
        check(name+' dimensions',im.size==(2640,1080))
        check(name+' mode',im.mode==mode)
        delta=np.abs(arr[:,720:].astype(np.int16)-old.astype(np.int16))
        changed=int(np.count_nonzero(np.any(delta!=0,axis=2)))
        preservation[name]={'compared_pixels':1920*1080,'different_pixels':changed,'max_channel_difference':int(delta.max()),'compared_channels':len(mode),'source_sha256':sha(src),'wide_sha256':sha(p)}
        check(name+' protected pixels exact',changed==0)
        check(name+' source pixels equal prework snapshot',np.array_equal(old,np.array(Image.open(D/(name+'-source.png')))))
        check(name+' source file hash unchanged',sha(src)==baseline[src.relative_to(ROOT).as_posix()]['sha256'])
        files[p.relative_to(ROOT).as_posix()]={'width':im.width,'height':im.height,'mode':im.mode,'sha256':sha(p),'bytes':p.stat().st_size}
    chars=np.array(Image.open(A/'lobby_characters_wide.png'))
    idarr=np.array(Image.open(A/'lobby_character_ids_wide.png'))
    gray=idarr[:,:,0]; alpha=chars[:,:,3]
    check('ID channels equal',np.all(idarr==gray[:,:,None]))
    values=[int(v) for v in np.unique(gray)]
    check('IDs use only specified integers',set(values)<={0,20,40,60,80,100,120,140,160,180,200,220,240},values=values)
    check('background ID iff alpha zero',np.array_equal(gray==0,alpha==0))
    check('extension IDs 20 160 220 only',set(np.unique(gray[:,:720]))=={0,20,160,220})
    check('new transparent RGB zero',np.all(chars[:,:720,:3][alpha[:,:720]==0]==0))
    check('new extension has real transparency',np.count_nonzero(alpha[:,:720]==0)>0)
    check('new extension has opaque figures',np.count_nonzero(alpha[:,:720]==255)>500000)
    check('full height for 21x9',Image.open(D/'crop-21x9.png').size==(2560,1080))
    check('3440x1440 coverage full height',Image.open(D/'crop-3440x1440-equivalent.png').size==(2580,1080))
    check('sheet present and full resolution',Image.open(OUT/'sheet.png').size==(5280,2248))
    for name in ['01-characters-imagegen.png','02-background-imagegen.png','03-wing-correction-imagegen.png','03-wing-correction-input.png','seam-2x.png','characters-checker.png','ids-overlay.png','shifted-minus6-minus4.png']:
        check('review/source '+name,(D/name).is_file())
    original=(D/'handoff-original.bin').read_bytes()
    current=(ROOT/DOC).read_bytes()
    check('handoff original bytes preserved as prefix',current.startswith(original))
    report={'date':'2026-10-24','checked_at_utc':datetime.now(timezone.utc).isoformat(),'dimensions':[2640,1080],'source_offset':[720,0],'original_region_preservation':preservation,'files':files,'checks':checks,'summary':{'passed':sum(c['passed'] for c in checks),'total':len(checks)},'crop_rules':{'21x9':{'source_box':[80,0,2640,1080],'pixels':[2560,1080]},'3440x1440':{'source_box':[60,0,2640,1080],'pixels':[2580,1080]}},'visual_review':{'completed':'--reviewed' in sys.argv,'items':['full composite','2x seam upper and lower','21:9 right anchored crop','3440:1440 equivalent crop','IDs 50 percent overlay','checkerboard foreground silhouette','opaque background plate','characters shifted (-6,-4)']},'generation':{'tool':'built-in image_gen','calls':3,'cli_used':False}}
    protected=D/'protected-verification.json'
    if protected.exists(): report['protected_path_observations']=json.loads(protected.read_text(encoding='utf-8'))
    (OUT/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps(report['summary']))
    if not all(c['passed'] for c in checks):
        print(json.dumps([c for c in checks if not c['passed']],ensure_ascii=False))
        raise SystemExit(1)

if __name__=='__main__': main()
