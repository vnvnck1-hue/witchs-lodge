"""Assemble unchanged reference/render images and update their evidence index."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json, hashlib
root=Path(__file__).resolve().parents[2]
shots=root/'godot/screenshots/art-refinement'
font=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',28)
board=Image.new('RGB',(2400,650),'#191e31')
draw=ImageDraw.Draw(board)
for index,(file,label) in enumerate([
    (root/'art/concepts/environment/06-chromatic-forest-fog.png','목표 원화 · 유색 숲의 어둠'),
    (shots/'v12-pack-clean.png','실제 게임 렌더 · 수정 진행 중')]):
    img=Image.open(file).convert('RGB')
    img.thumbnail((1200,600),Image.Resampling.LANCZOS)
    board.paste(img,(index*1200,50))
    draw.text((index*1200+18,7),label,font=font,fill='#edf0fa')
board.save(shots/'comparison-v12.png')
manifest=root/'art/manifest.json'
data=json.loads(manifest.read_text(encoding='utf-8-sig'))
rel='art/concepts/environment/06-chromatic-forest-fog.png'
file=root/rel
if not any(x['path']==rel for x in data):
    width,height=Image.open(file).size
    data.append(dict(path=rel,title='숲의 유색 어둠: 보라·인디고·청록 배경',status='follow-up-atmosphere-reference',source_filename='06-chromatic-forest-fog.png',provenance='edited with built-in image_gen following user feedback; retained as atmosphere reference',width=width,height=height,bytes=file.stat().st_size,sha256=hashlib.sha256(file.read_bytes()).hexdigest()))
manifest.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

readme=root/'godot/README.md'
text=readme.read_text(encoding='utf-8-sig')
text=text.replace('모든 모델은 기본 도형 블록아웃이며, GLB가 나오면 `scripts/visual/models.gd`의 반환 노드만 교체하면 된다.','본채·증축·환경 프랍·양·마녀는 13개 GLB로 교체했다. [원화와 실제 렌더 비교 및 남은 차이](../docs/art-refinement-progress.md)를 확인한다. 원화에 맞추는 작업은 진행 중이다.')
text=text.replace('![원화(위)와 실제 렌더(아래)](screenshots/lighting-compare.png)','![원화와 실제 렌더 비교](screenshots/art-refinement/comparison-v12.png)')
text=text.replace('창 크기 1600×900.','창 크기 1600×800, 기준 뷰포트 1774×887.')
start=text.index('## 라이팅 — 원화 맞춤 방법')
end=text.index('## 구조(문서 11절 대응)',start)
text=text[:start]+'''## 라이팅 — 현재 방식

프랍·밀도는 승인 원화 04, 숲의 어둠은 후속 수정본 06을 비교 기준으로 삼는다. 지면은 기준 카메라로 투영한 클린 플레이트이며 앰버색 공간 마스크를 실제 국소광과 혼합한다. 무광 프랍에는 디퓨즈 아틀라스·실제 조명·약한 보조광을 사용한다. 얇은 눈은 셀프 섀도 얼룩을 줄이기 위해 그림자를 받지 않는다. [방식과 제한](../docs/art-refinement-progress.md)에 자세히 기록했다.

- `shaders/painted_prop.gdshader`, `painted_snow.gdshader`: 무광 페인터리 디퓨즈, 넓은 확산광, GLB 양면 표시 유지.
- `shaders/painted_ground.gdshader`: 두 숲길·보라/청록 어둠의 지면 이미지와 따뜻한 공간 색 마스크.
- `scripts/visual/painted_models.gd`: GLB 연결과 재질 설정, 산장 주변 실제 국소광.
- `scripts/world/world.gd`: 달빛·주변광·그림자·성긴 눈·연기.
- `shaders/post_grade.gdshader`: 약한 가장자리 색 보정.

'''+text[end:]
text=text.replace('| 블록아웃 모델·재질·효과 |','| GLB 모델·재질·효과 |')
text=text.replace('직교, 수평 45°, size 19','직교, 수평 35°, size 21')
text=text.replace('나무·바위·산장·캐릭터는 기본 도형이다. 표면 밀도는 원화의 단순화 기준을 따르지만 실루엣의 섬세함(가지 끝, 돌 쌓임)은 GLB 교체 단계의 몫이다.','환경·본채·증축·마녀·양은 실제 GLB다. 여행자·몬스터·용의 블록아웃 교체와 환경의 실루엣·표면 조정이 남아 있다.')
readme.write_text(text,encoding='utf-8')

art_readme=root/'art/README.md'
text=art_readme.read_text(encoding='utf-8-sig').replace('33장의 PNG','34장의 PNG')
marker='## 기존 시작 장면과 모델링 시트'
if '## 후속 숲 분위기' not in text:
    text=text.replace(marker,'## 후속 숲 분위기 · 1장\n\n![보라·인디고·청록의 유색 어둠](concepts/environment/06-chromatic-forest-fog.png)\n\n검정색으로 단순하게 덮지 않고 배경 컬러를 접목하라는 후속 요청의 수정본이다. [프롬프트](../docs/prompts/chromatic-forest-fog.md), [현재 실제 3D 비교](../docs/art-refinement-progress.md)를 함께 본다.\n\n'+marker)
art_readme.write_text(text,encoding='utf-8')
main_readme=root/'README.md'
text=main_readme.read_text(encoding='utf-8-sig').replace('PNG 33장: 기존 자료 32장 + 최신 프로토타입 승인 기준 1장.','PNG 34장: 기존 자료 32장 + 승인 기준 1장 + 후속 숲 분위기 1장.')
main_readme.write_text(text,encoding='utf-8')
prompts=root/'docs/prompts/README.md'
text=prompts.read_text(encoding='utf-8-sig')
if 'chromatic-forest-fog.md' not in text:text=text.replace('- [프로토타입 승인 기준:', '- [유색 숲 어둠 · 후속 분위기 수정](chromatic-forest-fog.md)\n- [프로토타입 승인 기준:')
prompts.write_text(text,encoding='utf-8')
evidence={'version':'v12','status':'in-progress','engine':'Godot 4.7.2 Forward+','target':rel,'assets':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((root/'godot/assets/painted').glob('*.glb'))},'renders':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(shots.glob('v12-pack-*.png'))},'pck_sha256':hashlib.sha256((root/'build/WitchsLodge.pck').read_bytes()).hexdigest()}
(root/'godot/art_sources/refinement_evidence.json').write_text(json.dumps(evidence,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('REVIEW_SAVED',shots/'comparison-v12.png','manifest_images',len(data),'assets',len(evidence['assets']))
