from pathlib import Path
import json, hashlib
from PIL import Image

root=Path(__file__).resolve().parent.parent
replace={
 '01-lodge-management.png':'01-lodge-management-existing-portraits.png',
 '04-map-dialogue-results.png':'04-map-dialogue-results-existing-portraits.png',
 '손님 초상은 시안의 배치 예시입니다. 실제 구현에서는 현재 게임의 브람·미라 등 기존 초상을 그대로 사용합니다.':'사용자 확정에 따라 이 시안부터 브람·미라·토르빈의 기존 PNG를 직접 사용합니다. 얼굴·의상·채색·화풍을 다시 그리지 않고 크기와 표시 영역만 조절했습니다.',
 '대화창의 초상 빈자리와 종이 면은 구성 참고이며,':'대화창에는 기존 브람 PNG를 직접 배치했습니다. 종이 면은 구성 참고이며,',
}
for name in ['index.html','contact-sheet.html']:
 path=root/'review'/name
 text=path.read_text(encoding='utf-8')
 for before,after in replace.items(): text=text.replace(before,after)
 path.write_text(text,encoding='utf-8')
brief=root/'art-brief.md'
text=brief.read_text(encoding='utf-8')
for before,after in list(replace.items())[:2]:text=text.replace('`'+before+'`','`'+after+'`')
brief.write_text(text,encoding='utf-8')
manifest_path=root/'manifest.json'
manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
previous=manifest.get('assets',[])
superseded=[]
for asset in previous:
 if asset['file'] in list(replace)[:2]:
  superseded.append({**asset,'status':'superseded: invented portraits removed from current review'})
 else:continue
manifest['superseded_assets']=superseded
current=[]
for file in ['01-lodge-management-existing-portraits.png','02-menus-pocket-trade.png','03-feedback-world-ui.png','04-map-dialogue-results-existing-portraits.png','05-management-frame-transparent.png']:
 p=root/file;im=Image.open(p)
 current.append({'file':file,'size':list(im.size),'mode':im.mode,'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
manifest['assets']=current
verification=json.loads((root/'review/existing-portrait-verification.json').read_text(encoding='utf-8'))
manifest['portrait_policy']={'user_decision':'Use only existing game portrait PNGs, including concept art previews. No new person generation, repainting, facial/clothing changes, recoloring or style transfer. Scale and clipping only.','verified_original_files':verification['bindings'],'proof':'review/existing-portrait-verification.json','composition':'Existing portraits rendered directly as separate image layers in HTML. Image generation only removed the earlier invented portraits from the UI frame artwork.'}
manifest['prompts']=sorted(str(p.relative_to(root)).replace('\\','/') for p in (root/'source').glob('*-prompt.txt'))
manifest_path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
print('REVIEW_UPDATED existing portrait PNGs; 7 originals match, 2 boards revised')
