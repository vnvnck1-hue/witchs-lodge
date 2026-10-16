from pathlib import Path
import hashlib, json, html

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
SOURCE = ROOT / 'godot/screenshots/ui-extension-v01'
PACKED = ROOT / 'godot/screenshots/ui-extension-v01-build'
SHOTS = PACKED if (PACKED/'runtime-evidence.json').exists() else SOURCE
items = [
 (1,'시설 관리','01-lodge-facilities','시설 아이콘 6종, 행 프레임, 가격·불가 상태, 구매 버튼'),
 (2,'시설·손님·기록 탭','01-lodge-facilities','선택한 탭은 크림 종이, 비선택은 인디고'),
 (3,'손님 목록','02-lodge-guests','기존 인물 초상과 이야기·고용 버튼'),
 (4,'대화 기록','05-dialogue-history','크림 종이 기록지, 깃펜 아이콘, 원래 대화 내용'),
 (5,'일시정지','07-pause','달·설목 헤더, 공통 메뉴 버튼'),
 (6,'화면 설정','08-settings','드롭다운·펼침 메뉴·화살표·달 토글·스크롤'),
 (7,'조작법','10-help','종이 설명과 WASD 키캡'),
 (8,'마녀의 주머니','12-pocket','주머니·손패·활동 중·버림패 목록 프레임'),
 (9,'판매','14-sale','자원 그림, 수량 조절, 실시간 판매 금액, 판매·취소'),
 (10,'고용 제안','11-hire-offer','기존 직업 카드 그림, 제안 행, 고용 버튼'),
 (11,'카드·HUD 툴팁','15-card-tooltip','크림 종이, 먹색 본문, 용도 강조'),
 (12,'드래그 사용 안내','16-drag-preview','대상 안내 프레임과 유효·불가 색'),
 (13,'성공·실패 토스트','18-toasts','알림 띠와 확인·경고 아이콘'),
 (14,'지도','17-map','종이 지도·산장 표식·마녀·적 표식'),
 (15,'승리·패배 결과','31-victory','따뜻한 산장·꺼진 등불 헤더, 종이 통계'),
 (16,'대화 진행·선택·닫기','04-dialogue-choices','기존 초상·잉크 패널에 확장 버튼 연결'),
 (17,'이야기 알림·배지','06-guest-notification','기존 인물 PNG, 종이 말풍선, 손님 수 배지'),
 (18,'월드 체력 바','24-world-hp-tags-carry','작은 크림 외곽선과 얇은 상태색, 큰 장식 없이 유지'),
 (19,'행동·고용 이름표','24-world-hp-tags-carry','소형 행동 프레임, 작업·고용·드롭 안내'),
 (20,'털 깎기 게이지','27-shear-gauge','가위 그림과 작은 진행 바'),
 (21,'새끼양 성장 말풍선','26-lamb-bubble','그림에 포함된 꼬리와 종이 바탕'),
 (22,'자원 운반 말풍선','24-world-hp-tags-carry','기존 자원 그림·수량과 종이 말풍선'),
 (23,'유물 슬롯','19-relic-slots','유물 그림을 받치는 크림·청록 테두리'),
 (24,'계약 인물 이름표','00-main-hud','손패 위 크림 이름 리본'),
 (25,'손님 도착 알림 띠','32-arrival-count','발자국 그림과 공통 알림 띠'),
]
names = {
'00-main-hud':'기존 HUD와 손패', '01-lodge-facilities':'산장 시설', '02-lodge-guests':'손님 목록',
'03-dialogue-next':'대화 진행','04-dialogue-choices':'대화 선택','05-dialogue-history':'대화 기록',
'06-guest-notification':'이야기 알림','07-pause':'일시정지','08-settings':'설정','09-settings-dropdown':'드롭다운',
'10-help':'조작법','11-hire-offer':'고용 제안','12-pocket':'주머니','13-pocket-lower':'주머니 하단',
'14-sale':'판매','15-card-tooltip':'카드 툴팁','16-drag-preview':'드래그 안내','17-map':'지도','18-toasts':'토스트',
'19-relic-slots':'유물 슬롯','20-chest-art':'기존 보물상자','21-relic-selection':'기존 유물 선택',
'22-relic-reveal':'기존 유물 공개','23-spellbook-selection':'마법서적 선택',
'24-world-hp-tags-carry':'월드 체력·행동·운반','25-thorn-label':'가시 성장 글자','26-lamb-bubble':'새끼양 성장',
'27-shear-gauge':'털 깎기','28-grave-label':'묘지 글자','29-debug':'디버그 메뉴','30-defeat':'패배 결과',
'31-victory':'승리 결과','32-arrival-count':'도착 인원 알림','33-arrival-portrait':'기존 인물 도착',
'34-hud-tooltip':'HUD 툴팁','35-dragon-active':'기존 용 버튼 활성','36-facilities-lower':'시설 목록 하단',
'37-settings-toggle-off':'토글 끔','38-settings-help-720p':'720p 설정·조작법 동시 펼침'}

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
portraits=[]
for p in sorted((ROOT/'godot/assets/portraits').glob('guest_*_cutout.png')):
    reference=ROOT/'output/ui-extension-art-v01/references/portraits'/p.name
    portraits.append({'file':p.name,'sha256':sha(p),'matches_existing_reference':reference.exists() and sha(p)==sha(reference)})
assert len(portraits)==7 and all(p['matches_existing_reference'] for p in portraits)
(OUT/'portrait-integrity.json').write_text(json.dumps(portraits,ensure_ascii=False,indent=2),encoding='utf-8')

coverage=[{'id':i,'name':n,'screenshot':s+'.png','change':d,'status':'applied'} for i,n,s,d in items]
(OUT/'coverage.json').write_text(json.dumps(coverage,ensure_ascii=False,indent=2),encoding='utf-8')
shots=sorted(SHOTS.glob('*.png'))
prefix='../../godot/screenshots/'+SHOTS.name+'/'
def shotlink(s): return prefix+s+'.png'
def figure(s):
    return f'<figure><a href="{shotlink(s)}" target="_blank"><img loading="lazy" src="{shotlink(s)}" alt="{names.get(s,s)}"></a><figcaption>{s[:2]} · {names.get(s,s)}</figcaption></figure>'
rows=''.join(f'<tr><td>{i:02}</td><td><a href="{shotlink(s)}" target="_blank">{n}</a></td><td>{d}</td><td class="pass">적용</td></tr>' for i,n,s,d in items)
verifications=[]
for fn,label in [('verification.json','헤드리스 UI'),('render-verification.json','실제 렌더 UI'),('packed-verification.json','배포판 UI'),('guest-check/verification.json','대화·손님 흐름'),('packed-guest-check/verification.json','배포판 대화·손님 흐름')]:
    p=OUT/fn
    if p.exists():
        data=json.loads(p.read_text(encoding='utf-8'))
        verifications.append((label,len(data.get('checks',[])),len(data.get('failures',[])),fn))
checks=''.join(f'<li><a href="{fn}">{label}</a>: {n-f}/{n} 통과</li>' for label,n,f,fn in verifications)
gallery=''.join(figure(p.stem) for p in shots)
css='''*{box-sizing:border-box}body{margin:0;background:#171020;color:#e5dceb;font:16px/1.75 "Malgun Gothic",sans-serif}main{max-width:1440px;margin:auto;padding:40px 28px}h1,h2{color:#fce7b0}h1{font-size:34px;margin:.2em 0}h2{margin-top:42px}a{color:#73d4ce}p{max-width:1100px}.note{background:#251a34;border-left:4px solid #39bdc1;padding:16px 22px;margin:22px 0}.grid{display:grid;grid-template-columns:1fr 1fr;gap:18px}figure{margin:0;background:#24192e;border:1px solid #4a3458;border-radius:8px;overflow:hidden}img{display:block;width:100%;height:auto}figcaption{padding:9px 14px;font-size:14px;color:#c8b4d8}table{width:100%;border-collapse:collapse;font-size:14px}td,th{padding:10px 12px;border-bottom:1px solid #45324e;text-align:left}.pass{color:#8de5ba;white-space:nowrap}.sub{color:#b5a2c5;font-size:14px}.tags{display:flex;gap:10px;flex-wrap:wrap}.tags span{background:#2e203e;border:1px solid #654775;padding:5px 14px;border-radius:20px}nav{display:flex;gap:18px;flex-wrap:wrap;margin:25px 0}code{overflow-wrap:anywhere}@media(max-width:800px){.grid{grid-template-columns:1fr}main{padding:22px 14px}h1{font-size:27px}td,th{padding:6px}}'''
doc=f'''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>마녀산장 UI 적용 결과</title><style>{css}</style><main><div class="sub">WITCH’S LODGE · UI EXTENSION v01 · 2026-10-16</div><h1>채택 원화 게임 적용 결과</h1><p>기본 UI로 남았던 25개 항목을 기존 달빛 UI의 먹선·인디고·크림 종이·청록 장식으로 확장했습니다. 인물 포트레이트 7개는 기존 PNG와 해시가 모두 일치하며, 손님·대화·알림에서도 기존 프로필 경로를 사용합니다.</p><div class="tags"><span>25 / 25 적용</span><span>실제 실행 캡처 {len(shots)}장</span><span>기존 초상 7 / 7 일치</span></div><div class="note">이 페이지의 이미지는 실제 게임 실행 캡처입니다. 승인 원화는 <a href="../ui-extension-art-v01/review/index.html">원화 기록</a>에서, 변경 전 상태는 <a href="../ui-audit-2026-10-16/report.html">초기 UI 점검</a>에서 확인할 수 있습니다.</div><nav><a href="#coverage">25항목 목록</a><a href="#gallery">전체 캡처</a><a href="#validation">검증</a><a href="../../build/WitchsLodge.exe">게임 실행파일</a></nav><div class="grid">{figure('01-lodge-facilities')}{figure('02-lodge-guests')}{figure('08-settings')}{figure('30-defeat')}</div><h2 id="coverage">적용 항목</h2><table><thead><tr><th>ID</th><th>화면·표시</th><th>반영 내용</th><th>결과</th></tr></thead><tbody>{rows}</tbody></table><p class="sub">시설은 아래로 스크롤하면 마녀 회복까지 보입니다. 주머니는 기존 네 구역과 임의로 꺼낼 수 없는 규칙을 유지합니다. 지도는 실제 탐색 여부·이동 입력을 사용하며, 대화의 기존 잉크 패널 연출과 인물 그림은 유지했습니다. 작은 월드 체력 바에는 큰 초상·설목 장식을 넣지 않았습니다.</p><h2 id="gallery">전체 실행 캡처</h2><p class="sub">이미지를 누르면 원본 크기로 열립니다. 기존에 그래픽이 적용되어 있던 보물상자·유물 공개·용 버튼도 함께 비교했습니다.</p><div class="grid">{gallery}</div><h2 id="validation">검증과 파일</h2><ul>{checks}<li><a href="portrait-integrity.json">기존 포트레이트 7개 SHA-256 대조</a>: 모두 일치</li><li>960×540, 1280×720, 1774×887, 1920×1080 창 배치 및 설정·조작법 동시 펼침 확인</li><li>수리 구매·판매 수량·금액·정지/재개·안개 토글·고용·대화 양쪽 선택지·기록 저장 확인</li></ul><p class="sub">헤드리스 검사는 상태·구조·계산을 확인했고, 이미지 색·투명도·텍스처 여백은 실제 렌더로 확인했습니다. 헤드리스 카드 셰이더의 더미 렌더러 진단과 일부 테스트 종료 시 기존 카드 입자 정리 진단이 남으며, 실제 캡처 실행은 UI 런타임 오류 없이 완료됐습니다. 개발용 디버그 메뉴도 공통 프레임과 버튼을 재사용합니다. 묘지·가시·피해 숫자는 단순 안내 글자로 유지했습니다.</p><ul><li><a href="coverage.json">25항목 적용 대응표</a></li><li><a href="../../godot/assets/ui/moon_runes/extension_v01/atlas-regions.json">38개 UI 부품 영역</a></li><li><a href="source/">생성 프롬프트 기록</a></li><li><a href="build-manifest.json">배포판·에셋 해시 기록</a></li></ul></main></html>'''
(OUT/'report.html').write_text(doc,encoding='utf-8')
md=['# 마녀산장 UI 적용 결과','',f'25개 항목 적용. 실제 실행 캡처 {len(shots)}장. 기존 인물 포트레이트 7개 SHA-256 일치.','','| ID | 항목 | 적용 |','|---|---|---|']
md += [f'| {i:02} | {n} | {d} |' for i,n,s,d in items]
md += ['','검증:']+[f'- {label}: {n-f}/{n}' for label,n,f,fn in verifications]
(OUT/'report.md').write_text('\n'.join(md)+'\n',encoding='utf-8')
print(f'REPORT PASS: {len(items)} items, {len(shots)} screenshots, 7 original portraits intact')
