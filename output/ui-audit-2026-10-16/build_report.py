from pathlib import Path
from PIL import Image, ImageOps, ImageDraw, ImageFont
import json, html, hashlib, re

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
SHOTS = ROOT / 'godot/screenshots/ui-audit-2026-10-16'
OUT.mkdir(parents=True, exist_ok=True)
(OUT/'details').mkdir(exist_ok=True)
FONT = Path('C:/Windows/Fonts/malgun.ttf')
H = html.escape
evidence = json.loads((SHOTS/'runtime-evidence.json').read_text(encoding='utf-8'))
extra = json.loads((SHOTS/'extras-evidence.json').read_text(encoding='utf-8'))
shotmap = {s['id']:s for s in evidence['shots']+extra['shots']}
if (SHOTS/'world-evidence.json').exists():
    world_evidence=json.loads((SHOTS/'world-evidence.json').read_text(encoding='utf-8'))
    shotmap.update({s['id']:s for s in world_evidence['shots']})

def region(shot, index=0):
    regions = shotmap[shot]['regions']
    return regions[index] if len(regions)>index else [0,0,1774,887]

def src(file, needle):
    path=ROOT/'godot/scripts'/file
    lines=path.read_text(encoding='utf-8-sig').splitlines()
    line=next((i+1 for i,x in enumerate(lines) if needle in x),1)
    return {'path':str(path),'file':'godot/scripts/'+file,'line':line,'match':needle}

items=[]
def add(id,title,shot,description,code,needle,priority='P1',status='단색 UI',crop=None,subshots=(),asset='',group='player'):
    items.append(dict(id=id,title=title,shot=shot,description=description,source=src(code,needle),priority=priority,status=status,crop=crop or region(shot),subshots=list(subshots),asset=asset,group=group))

add('01','산장 관리 · 시설 구매/증축/회복','01-lodge-facilities','창 전체와 6개 시설 행, 가격/구매 버튼, 닫기 버튼이 단색 프레임입니다. 시설 전용 아이콘·장식·그림 버튼이 연결되지 않았습니다.','ui/hud.gd','func _build_lodge_panel',asset='modal_frame · row_background · button_*')
r=region('01-lodge-facilities').copy(); r[1]+=90; r[3]=82
add('02','산장 관리 · 시설/손님/대화 기록 탭','01-lodge-facilities','TabContainer/TabBar 전용 스타일이 테마에 정의되지 않아 회색 기본 탭을 그대로 사용합니다. 선택/비선택 탭 그래픽이 아트 폴더에 있습니다.','ui/hud.gd','lodge_tabs = TabContainer.new()',status='기본 위젯',crop=r,asset='tab_normal · tab_selected')
add('03','산장 관리 · 손님 목록','02-lodge-guests','손님 초상은 적용됐습니다. 목록 배경·상태 행·이야기 듣기/고용 버튼·닫기는 공통 단색 UI입니다.','ui/guest_interactions.gd','func _sync_hub',asset='modal_frame · row_background · button_*')
add('04','산장 관리 · 대화 기록','05-dialogue-history','기록은 단색 행과 일반 텍스트 목록으로 표시됩니다. 기록 페이지/카드 프레임, 탭, 닫기 버튼의 전용 그래픽이 없습니다.','ui/guest_interactions.gd','for record in game.guest_events.history',asset='modal_frame · row_background · tab_*')
add('05','일시정지 메뉴','07-pause','계속하기·지도 보기·설정·조작법·새 게임·종료가 같은 단색 버튼입니다. 메인 HUD의 그림형 일시정지 아이콘과 내부 메뉴의 표현 수준이 다릅니다.','ui/hud.gd','func _build_pause',asset='modal_frame · button_*')
add('06','화면 설정 · 토글/드롭다운','08-settings','전장의 안개 CheckButton은 전용 테마/아이콘 지정이 없습니다. OptionButton은 배경색만 바뀌고 화살표 아이콘은 기본값입니다. 펼친 메뉴도 단색 패널입니다.','ui/hud.gd','func _build_screen_styles',status='기본 위젯 + 단색',subshots=['09-settings-dropdown'],asset='button_* · scroll_* (토글/화살표 전용 상태는 별도 확인)')
add('07','조작법 펼침 영역','10-help','일시정지 창 안에 일반 라벨로 나열됩니다. 키캡·입력 아이콘·조작법 전용 패널 없이 텍스트로만 구성됩니다.','ui/hud.gd','pause_help = _label',priority='P2',asset='modal_frame · divider (키캡은 별도)')
add('08','마녀의 주머니 · 손패/활동/버림패 목록','12-pocket','카드 썸네일과 버림패 아이콘은 있습니다. 창·섹션·목록 행·닫기는 단순 UI이며 전용 덱/목록 프레임을 쓰지 않습니다. 아래 섹션까지 스크롤해서 확인했습니다.','ui/card_hand.gd','func _fill_pocket',subshots=['13-pocket-lower'],asset='modal_frame · row_background · scroll_* · button_*')
add('09','자원 판매 · 수량/합계/확인','14-sale','양털·생고기·토끼 가죽이 공유하는 판매창입니다. 자원 그림 없이 텍스트 정보, −/＋/전부, 판매/취소를 단색 버튼으로 표시합니다.','ui/card_hand.gd','func _build_sale',asset='modal_frame · button_* · 자원 icon_*')
add('10','화면 왼쪽 · 고용 제안','11-hire-offer','직업 카드 썸네일은 적용됐지만 제안 패널·남은 시간·고용 버튼은 단색 UI입니다.','ui/card_hand.gd','func _sync_offers',crop=[15,580,650,260],asset='row_background · button_*')
add('11','카드 설명과 HUD 툴팁','15-card-tooltip','카드 설명과 HUD 상태 설명은 보라색 단색 사각 패널입니다. 전용 tooltip_frame을 사용하지 않습니다. 카드 원화 자체는 적용됐습니다.','ui/card_hand.gd','func _build_tooltip',subshots=['34-hud-tooltip'],asset='tooltip_frame')
add('12','카드 드래그 · 사용 가능/불가 안내','16-drag-preview','드래그 대상 안내창은 단색 바탕과 녹색/적색 테두리로만 상태를 구분합니다. 캡처는 사용 불가 상태입니다.','ui/card_hand.gd','func _update_drag',priority='P2',asset='tooltip_frame (성공/실패 상태 별도)')
add('13','상단 토스트 · 성공/실패 알림','18-toasts','판매·골드 부족·수확 등 공통 알림이 단색 반투명 막대와 글자 색으로 표시됩니다. 제공된 toast_frame은 미사용입니다.','ui/hud.gd','func toast(',asset='toast_frame')
add('14','탐색 지도 · 창/닫기/지도 표식','17-map','지도 프레임과 닫기 버튼은 단색 UI입니다. 지도 내부도 길=선, 산장=사각형, 적/마녀=점으로 직접 그립니다. 지도 전용 프레임·표식 그림은 연결되지 않았습니다.','ui/exploration_map.gd','func _draw',priority='P2',asset='modal_frame · 지도 전용 표식은 별도')
add('15','게임 오버 / 시연 완료 결과창','30-defeat','패배와 승리 모두 같은 단색 모달+통계 텍스트+새 게임 버튼입니다. 승패별 타이틀/프레임/결과 장식 그래픽이 없습니다.','ui/hud.gd','func _build_end',subshots=['31-victory'],asset='modal_frame · button_* (승패별 장식 별도)')
add('16','손님 대화 · 다음/선택지/닫기 버튼','04-dialogue-choices','손님 초상과 잉크 패널 연출은 이미 적용됐습니다. 그 아래 대답하기·두 선택지·나중에 듣기 버튼만 일반 단색 버튼으로 남아 있습니다.','ui/guest_interactions.gd','next_button = Button.new()',subshots=['03-dialogue-next'],crop=[600,535,650,180],asset='button_*')
add('17','대화 준비 알림 · 말풍선/관리 배지','06-guest-notification','초상은 적용됐습니다. 옆 말풍선은 단색 둥근 패널+삼각형 꼬리이고, 관리 버튼의 인원/느낌표 배지도 단색 도형입니다.','ui/guest_interactions.gd','func _build_notification',crop=[10,215,500,220],priority='P2',asset='말풍선·알림 배지 전용 그래픽 별도')
add('18','월드 체력 바 · 적/마녀/산장/양/아군','24-world-hp-tags-carry','상단 HUD 체력판은 그래픽이 적용됐지만 월드 체력 바는 draw_rect로 그린 단색 막대입니다. 대상별 색과 길이만 달라집니다.','ui/hud.gd','class HpOverlay',crop=[430,280,870,340],priority='P2',asset='월드 체력 바 프레임·채움 별도')
add('19','월드 행동 이름표 · 임무/털 수확/고용/카드 드롭','24-world-hp-tags-carry','아군 이름+상태, 양 털 수확, 손님 고용 금액, 처치 시 카드가 직사각형 배경+기본 글자로 표시됩니다.','ui/hud.gd','func _tag(',crop=[430,280,870,340],priority='P2',asset='월드 이름표·상호작용 아이콘 별도')
add('20','양털 깎기 진행 게이지','27-shear-gauge','수확 진행은 단색 트랙/채움 사각형과 ✂ 문자로 직접 그립니다. 전용 진행 바·가위 아이콘은 사용하지 않습니다.','ui/hud.gd','func _draw_shear_gauge',crop=[650,220,700,390],priority='P2',asset='작업 게이지 · 가위 아이콘 별도')
add('21','새끼양 성장 안내 말풍선','26-lamb-bubble','성장일까지 남은 날은 분홍 단색 패널과 삼각형 꼬리로 표시합니다. 말풍선용 아트 프레임이 없습니다.','ui/lamb_bubble.gd','func _ready',priority='P2',asset='성장 안내 말풍선 별도')
add('22','용병 자원 소지 말풍선','24-world-hp-tags-carry','목재/생고기/가죽 아이콘은 적용됐습니다. 말풍선 바탕·꼬리·수량 표현은 단색 기본 패널/글자입니다.','ui/carry_bubble.gd','b.add_theme_stylebox_override',crop=[700,300,450,220],priority='P2',asset='자원 icon_* 있음 · 말풍선 프레임 별도')
add('23','획득 유물 슬롯','19-relic-slots','유물 아이콘은 적용됐습니다. 슬롯은 단색 보라 바탕과 금색 테두리의 작은 사각형이며 장식 슬롯 프레임은 없습니다.','ui/hud.gd','func _refresh_relic_tray',priority='P2',crop=[15,205,400,95],asset='유물 icon_* 있음 · 슬롯 프레임 별도')
add('24','용병 카드 · 계약 인물 이름표','15-card-tooltip','손패 카드 원화와 수량 배지는 그래픽이 적용됐습니다. 계약 인물 이름표만 단색 둥근 PanelContainer입니다.','ui/card_hand.gd','tag.add_theme_stylebox_override',priority='P2',crop=[620,620,600,265],asset='인물 이름표 프레임 별도')
add('25','손님 도착 · 인원 예고 띠','32-arrival-count','손님이 도착하기 직전의 “손님 n명이 산장을 찾아옵니다” 띠는 단색 패널입니다. 이어지는 초상/잉크 소개 화면은 이미 연출이 적용돼 있습니다.','ui/guest_arrival.gd','func _build_notice',crop=[630,480,520,190],priority='P2',asset='도착 알림 띠 전용 그래픽 별도')

add('D1','개발용 F1 디버그 메뉴','29-debug','디버그 창/9개 버튼이 단색 기본 UI입니다. 개발 도구이므로 플레이어용 화면과 분리해 낮은 우선순위로 두었습니다.','ui/hud.gd','func _build_debug',priority='개발용',group='dev',asset='tooltip_frame · button_*')
add('R1','가시 씨앗 성장/강화 이름표','25-thorn-label','Label3D로 성장 초수·가시 방책·강화 상태를 표시합니다. 의도적인 월드 라벨일 수 있어 미완료로 단정하지 않고 디자인 검토 항목으로 둡니다.','actors/thorn_seed.gd','_label = Label3D.new()',priority='검토',status='일반 텍스트',crop=[800,390,650,340],group='review')
add('R2','묘지 · 이름/사망 일차 라벨','28-grave-label','비석은 3D 모델이고 이름/일차는 Label3D입니다. UI 그래픽 누락인지, 월드 가독성용 텍스트인지 결정이 필요합니다.','world/graveyard.gd','var label := Label3D.new()',priority='검토',status='일반 텍스트',crop=[500,200,800,400],group='review')
add('R3','보물상자/마법서 · 선택 화면의 제목/안내','23-spellbook-selection','상자 원화·물음표 카드·공개 유물·마법서 후보 카드에는 그래픽이 적용됐습니다. 상하단 제목/설명만 일반 텍스트+어두운 배경입니다. 장식 프레임의 필요 여부를 검토할 수 있습니다.','ui/spellbook_picker.gd','title = Label.new()',priority='검토',status='카드 그래픽 적용',subshots=['20-chest-art','21-relic-selection','22-relic-reveal'],crop=[430,95,900,700],group='review')
add('R4','떠오르는 피해 숫자/골드/획득 텍스트','35-dragon-active','피해/골드는 Label3D, 카드 획득 수량은 일반 Label을 사용합니다. 팝/상승/페이드 연출은 있습니다. 글자라는 이유만으로 그래픽 미적용으로 판정하지 않았습니다.','visual/fx.gd','static func damage_number',priority='검토',status='글자 연출 적용',crop=[700,200,420,200],group='review')

def crop_image(item):
    im=Image.open(SHOTS/(item['shot']+'.png')).convert('RGB')
    x,y,w,h=item['crop']; pad=16
    box=(max(0,int(x-pad)),max(0,int(y-pad)),min(im.width,int(x+w+pad)),min(im.height,int(y+h+pad)))
    if box[2]<=box[0] or box[3]<=box[1]: box=(0,0,im.width,im.height)
    cut=im.crop(box)
    cut.thumbnail((1000,620),Image.Resampling.LANCZOS)
    cut.save(OUT/'details'/(item['id']+'.png'))
    item['detail']='details/'+item['id']+'.png'
    item['actual_crop']=list(box)
    return cut

for item in items:
    if item['id'] in ['20','21','R2']:
        item['crop']=region(item['shot'])
    if item['id']=='R2':
        item['description'] += ' 라벨 가독성을 확인하기 위해 감사 실행에서만 근접 카메라로 촬영했습니다.'
    crop_image(item)

# A compact, readable sheet of six frequent player-facing gaps.
hero_ids=['01','06','08','09','16','15']
cw,ch=720,440
hero=Image.new('RGB',(cw*3,ch*2+88),'#171320')
draw=ImageDraw.Draw(hero)
font=ImageFont.truetype(str(FONT),23); small=ImageFont.truetype(str(FONT),18)
draw.text((25,17),'마녀산장 · 기본/단색 UI 잔여 현황',font=ImageFont.truetype(str(FONT),34),fill='#f5e3b1')
draw.text((26,62),'2026.10.16 | 현재 배포 PCK 실제 렌더 캡처 | 전체 25개 점검 항목 중 대표 6개',font=small,fill='#c1b6d0')
for i,id in enumerate(hero_ids):
    item=next(x for x in items if x['id']==id)
    image=Image.open(OUT/item['detail']).convert('RGB')
    image=ImageOps.contain(image,(cw-28,ch-60),Image.Resampling.LANCZOS)
    x=(i%3)*cw; y=(i//3)*ch+88
    hero.paste(image,(x+(cw-image.width)//2,y+(ch-60-image.height)//2))
    draw.text((x+18,y+ch-45),id+'  '+item['title'],font=font,fill='#f5e3b1')
hero.save(OUT/'overview.jpg',quality=92)

# Proof of provided art assets, without modifying their source files.
asset_names=['modal_frame','tooltip_frame','toast_frame','button_normal','tab_selected','tab_normal']
asset_sheet=Image.new('RGB',(1500,640),'#211a2e'); ad=ImageDraw.Draw(asset_sheet)
for i,name in enumerate(asset_names):
    im=Image.open(ROOT/'art/ui/moon-runes-v01/common'/(name+'.png')).convert('RGBA')
    im.thumbnail((470,255),Image.Resampling.LANCZOS)
    x=(i%3)*500; y=(i//3)*320
    asset_sheet.paste(im,(x+(500-im.width)//2,y+(270-im.height)//2),im)
    ad.text((x+20,y+280),name+'.png',font=font,fill='#f5e3b1')
asset_sheet.save(OUT/'provided-assets.jpg',quality=90)

def shot_url(id): return '../../godot/screenshots/ui-audit-2026-10-16/'+id+'.png'

def card(item):
    s=item['source']; links=''.join(f'<button class="shot" data-src="{shot_url(x)}">{H(x)}</button>' for x in [item['shot']]+item['subshots'])
    return f'''<article class="item" id="item-{item['id']}" data-priority="{item['priority']}" data-group="{item['group']}">
    <div class="item-text"><div class="badges"><span>{item['id']}</span><span class="{('stock' if '기본' in item['status'] else '')}">{H(item['status'])}</span><span>{item['priority']}</span></div>
    <h3>{H(item['title'])}</h3><p>{H(item['description'])}</p>
    {('<p class="muted">연결 후보/추가 아트: '+H(item['asset'])+'</p>') if item['asset'] else ''}
    <p class="source">코드 근거: {H(s['file'])}:{s['line']}<br><code>{H(s['match'])}</code></p><div class="shotlinks">{links}</div></div>
    <button class="detail shot" data-src="{shot_url(item['shot'])}" title="전체 원본 캡처 열기"><img loading="lazy" src="{item['detail']}" alt="{H(item['title'])} 확대 캡처"></button></article>'''

core=[x for x in items if x['group']=='player']
dev=[x for x in items if x['group']=='dev']
reviews=[x for x in items if x['group']=='review']
table=''.join(f'<tr><td>{x["id"]}</td><td><a href="#item-{x["id"]}">{H(x["title"])}</a></td><td>{H(x["status"])}</td><td>{x["priority"]}</td></tr>' for x in core)
assetroot=ROOT/'art/ui/moon-runes-v01'
common_assets=[dict(file=str(p.relative_to(ROOT)),size=p.stat().st_size,dimensions=list(Image.open(p).size)) for p in sorted((assetroot/'common').glob('*.png'))]
pack=ROOT/'build/WitchsLodge.pck'
summary={'date':'2026-10-16','project':'마녀산장','capture_scope':'current build/WitchsLodge.pck','pack_size':pack.stat().st_size,'capture_count':len(shotmap),'player_items':len(core),'developer_items':len(dev),'design_review_items':len(reviews),'items':items,'provided_common_assets':common_assets,'runtime_evidence':'../../godot/screenshots/ui-audit-2026-10-16/runtime-evidence.json','extras_evidence':'../../godot/screenshots/ui-audit-2026-10-16/extras-evidence.json'}
summary['world_evidence']='../../godot/screenshots/ui-audit-2026-10-16/world-evidence.json'
(OUT/'audit.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')

css='''*{box-sizing:border-box}html{scroll-behavior:smooth;scroll-padding-top:72px}body{margin:0;background:#100e16;color:#e7e1ee;font:16px/1.7 "Malgun Gothic",system-ui,sans-serif}a{color:#b3dce0;text-decoration:none}a:hover{text-decoration:underline}button{font:inherit;cursor:pointer}header,main{max-width:1400px;margin:auto;padding:36px}header{padding-top:60px;padding-bottom:22px}.eyebrow{color:#b9a4dd;letter-spacing:.13em;font-size:13px}h1{font-size:38px;line-height:1.35;margin:12px 0 20px;color:#f5e3b1}h2{font-size:26px;line-height:1.4;margin:54px 0 16px;color:#f5e3b1}h3{font-size:20px;line-height:1.5;margin:12px 0}p{margin:10px 0}.lead{font-size:19px;max-width:1050px}.muted{color:#aaa0b9;font-size:14px}.hero{width:100%;border-radius:18px;border:1px solid #40334d}.stats{display:flex;flex-wrap:wrap;gap:12px;margin:28px 0}.stat{padding:16px 24px;background:#211a2d;border:1px solid #433351;border-radius:12px;min-width:190px}.stat strong{font-size:27px;color:#f5e3b1;display:block}.note{padding:20px 24px;background:#211a2d;border-left:3px solid #b69bd2;border-radius:4px;margin:20px 0}.callout{border-left-color:#70bbc2}.item{display:grid;grid-template-columns:1fr 1.15fr;gap:28px;padding:28px 0;border-top:1px solid #352a40;align-items:center}.badges{display:flex;gap:7px;flex-wrap:wrap}.badges span{border:1px solid #584368;border-radius:5px;background:#2c203b;padding:1px 8px;font-size:12px;color:#cdbade}.badges .stock{border-color:#c78864;color:#ffd2aa}.detail{display:block;border:0;background:#1a1522;border-radius:12px;padding:12px;min-height:120px;width:100%}.detail img{display:block;max-width:100%;max-height:470px;margin:auto;image-rendering:auto}.source{font-size:12px;color:#9a8fa9;overflow-wrap:anywhere}code{font-family:Consolas,monospace}.shotlinks{display:flex;flex-wrap:wrap;gap:6px}.shotlinks button,.filters button{color:#c5e2e4;background:#241d31;border:1px solid #51415d;border-radius:6px;padding:5px 10px;font-size:12px}.filters{position:sticky;top:0;z-index:3;background:#100e16ef;padding:12px;display:flex;gap:8px;flex-wrap:wrap;backdrop-filter:blur(8px);border-bottom:1px solid #40334d}.filters button[aria-pressed=true]{background:#614274;border-color:#bfa2d0;color:white}table{width:100%;border-collapse:collapse;font-size:14px}th,td{border-bottom:1px solid #34293d;text-align:left;padding:10px}th{color:#baadd0}.integration{display:grid;grid-template-columns:1fr 1fr;gap:24px}.integration .note{margin:0}.proof{max-width:100%;border-radius:12px;background:#211a2d}details{background:#1b1525;border-radius:10px;padding:14px 20px;margin-top:18px}summary{cursor:pointer;color:#c6b3db}ul{padding-left:22px}li{margin:7px 0}dialog{background:#100e16;color:white;border:1px solid #796184;border-radius:10px;padding:15px;max-width:96vw;max-height:96vh}dialog::backdrop{background:#000d}dialog img{max-width:92vw;max-height:80vh;display:block}dialog button{float:right;background:#392645;border:1px solid #8b7697;color:white;border-radius:5px;padding:5px 15px;margin-bottom:8px}.empty{display:none}footer{padding:30px 0 60px;color:#9689a5;font-size:13px}@media(max-width:850px){header,main{padding:22px}h1{font-size:29px}.item,.integration{grid-template-columns:1fr}.item{gap:12px}.stats{gap:8px}.stat{min-width:140px;padding:12px 16px}.stat strong{font-size:23px}table{font-size:12px}td,th{padding:7px}.filters{position:static}}'''
page=f'''<!doctype html><html lang="ko"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>마녀산장 UI 그래픽 미적용 점검 · 2026.10.16</title><style>{css}</style></head><body>
<header><div class="eyebrow">WITCH’S LODGE · UI VISUAL AUDIT · 2026.10.16</div><h1>기본 UI가 남아 있는 곳을<br>현재 배포판 화면으로 확인했습니다.</h1><p class="lead">플레이어용 UI <b>25개 점검 항목</b>에서 기본 위젯 또는 전용 그래픽 없는 단색 표현을 확인했습니다. 같은 창 안의 탭·행·버튼을 따로 세었으므로 25개가 각각 별도 화면이라는 뜻은 아닙니다.</p><div class="stats"><div class="stat"><strong>25개</strong>플레이어용 점검 항목</div><div class="stat"><strong>36장</strong>실제 배포 PCK 캡처</div><div class="stat"><strong>14개</strong>미연결 공통 PNG 파일</div><div class="stat"><strong>1 + 4개</strong>개발용 / 디자인 검토 항목</div></div><img class="hero" src="overview.jpg" alt="산장 시설, 설정, 주머니, 판매, 대화 선택지, 결과창 확대 캡처"><div class="note callout"><b>우선 확인할 원인:</b> <code>art/ui/moon-runes-v01/common/</code>의 모달·툴팁·토스트·버튼·탭·스크롤 PNG는 존재하지만, 게임의 공통 테마는 <code>StyleBoxFlat</code>을 사용합니다. 현재 <code>godot/assets/ui/moon_runes/</code>에는 <code>approved/</code>와 <code>interim/</code>만 있고 최종 <code>runtime/</code> 및 <code>common/</code>이 설치되지 않았습니다.</div></header>
<main><div class="filters"><button data-filter="all" aria-pressed="true">모든 상세 항목</button><button data-filter="P1" aria-pressed="false">우선 P1</button><button data-filter="P2" aria-pressed="false">보조 P2</button><button data-filter="dev" aria-pressed="false">개발용</button><button data-filter="review" aria-pressed="false">디자인 검토</button><a href="audit.json">구조화 목록 JSON</a></div>
<h2>판정 기준과 점검 범위</h2><p><b>기본 위젯:</b> 탭·토글·화살표처럼 엔진 기본 모양이 남은 곳. <b>단색 UI:</b> 프로젝트 색·글꼴은 적용됐지만 전용 그림 프레임/버튼 대신 사각형·둥근 패널을 그리는 곳. 단색 표현 자체를 버그라고 단정하지는 않습니다.</p><p>현재 <code>build/WitchsLodge.pck</code>를 Godot 4.7.2의 실제 Vulkan Forward+ 렌더러로 실행해 1774×887 화면을 캡처했습니다. 화면 전환은 별도 감사 스크립트가 기존 게임 함수를 호출해 재현했습니다. 자원/손패/체력/승패 등은 캡처용 임시 실행 상태이며 실제 플레이 저장 상태를 읽거나 바꾼 것이 아닙니다. 코드 근거는 현재 작업트리의 파일/행입니다.</p><p class="muted">메인 HUD 8개 그룹, 시설·손님·기록, 일시정지·설정·조작법, 주머니 4개 구역, 판매·고용·카드 설명/드래그, 지도·알림, 대화와 선택지, 체력/작업/말풍선, 유물·상자·마법서, 묘지/가시 이름표, 승패 및 개발 메뉴를 점검했습니다. 게임 UI/로직 및 배포 PCK는 수정하지 않았습니다.</p>
<h2>전체 목록 · 플레이어용 25개</h2><table><thead><tr><th>번호</th><th>위치</th><th>현재 표현</th><th>우선순위</th></tr></thead><tbody>{table}</tbody></table><p class="muted">P1은 주요 화면/공통 부품의 그래픽 연결, P2는 보조 정보/월드 UI의 표현 정리 우선순위입니다. 아래 이미지는 문제 영역을 확대한 실제 캡처이며, 누르면 전체 원본을 볼 수 있습니다.</p>
<div id="items">{''.join(card(x) for x in core)}
<h2>개발용 · 1개</h2>{''.join(card(x) for x in dev)}
<h2>그래픽 누락으로 단정하지 않은 항목 · 4개</h2><p>일반 텍스트를 쓰지만 표시 목적에 맞을 수 있는 곳입니다. 확정 미적용 목록 25개에는 포함하지 않았습니다.</p>{''.join(card(x) for x in reviews)}</div>
<h2>이미 그래픽이 적용된 부분 / 최종 연결이 남은 부분</h2><div class="integration"><div class="note"><b>그래픽 적용 확인</b><p>상단 상태/자원/낮밤/목표판, 하단 트레이·창고·관리·일시정지·용 실루엣, 손패 카드 원화와 수량 배지, 손님 초상·잉크 소개, 상자 열림/닫힘, 물음표 카드·유물·마법서 후보 카드, 자원/유물 아이콘은 실제 그림을 사용합니다.</p><p>보물상자의 코드상 사각형 스케치 fallback과 물음표 문자 fallback은 현재 아트 파일이 존재해 사용되지 않습니다.</p></div><div class="note"><b>그래픽 적용 ≠ 최종 에셋 연결 완료</b><p>HUD의 실제 텍스처 경로는 <code>moon_runes/interim/</code>입니다. 최종 <code>art/ui/moon-runes-v01/runtime/</code> 납품본은 게임의 검색 경로에 설치되지 않았습니다.</p><p>용 활성 버튼은 코드가 <code>dragon_active</code>를 찾지만 현재 없어서 <code>dragon_disabled</code>를 착색합니다. 납품본은 <code>dragon_normal.png</code> 이름이므로 ID 연결 확인이 필요합니다.</p><p>숫자 glyph atlas/metrics는 아트 폴더에 있으나 게임은 시스템 글꼴을 사용합니다. 이는 전체 UI의 글꼴 통일 검토 사항입니다.</p></div></div><p><button class="shot" data-src="{shot_url('35-dragon-active')}">용 공물 활성 상태 원본 보기</button> <button class="shot" data-src="{shot_url('00-main-hud')}">메인 HUD 원본 보기</button> <button class="shot" data-src="{shot_url('33-arrival-portrait')}">손님 초상/잉크 소개 원본 보기</button></p>
<h2>아트 폴더에 있으나 미연결인 공통 그래픽</h2><img class="proof" src="provided-assets.jpg" alt="기존 제공 모달, 툴팁, 토스트, 버튼, 탭 PNG"><p class="muted">파일이 있다는 사실을 확인한 것입니다. 실제 연결 시 크기·9-slice 여백·상태별 가독성 검토는 별도이며, 이 보고서에서는 에셋을 설치하거나 바꾸지 않았습니다.</p><p><code>{H(' · '.join(p['file'].split('/')[-1] for p in common_assets))}</code></p>
<details><summary>재현·검증 기록과 제한</summary><ul><li>먼저 헤드리스로 UI 노드/테마 구성을 확인했고, 색·텍스처·기본 위젯의 실제 모양은 더미 렌더러로 확인할 수 없어 실제 렌더 캡처를 사용했습니다.</li><li>소스 실행 32장 확인 후, 현재 배포 PCK로 동일 32장+보조 4장을 캡처했습니다. 보고서의 최종 원본은 배포 PCK 캡처입니다.</li><li>배포 PCK 실행은 캡처 32/32 및 4/4 완료 메시지와 종료코드 0을 확인했습니다. 첫 배포 캡처 종료 때 ObjectDB 14개/리소스 7개 해제 관련 경고가 로그에 남았습니다. 별도의 게임 버그 조사나 수정은 수행하지 않았습니다.</li><li>“그래픽 없음”은 전용 그림 자산 미사용을 의미합니다. 텍스트·도형 자체가 기획 의도일 수 있으므로 별도 검토 항목을 구분했습니다.</li><li>감사 도구: <code>godot/tools/capture_ui_audit.gd</code>. 원본 36장과 JSON/로그: <code>godot/screenshots/ui-audit-2026-10-16/</code>.</li></ul><p><a href="../../godot/screenshots/ui-audit-2026-10-16/runtime-evidence.json">런타임 노드/테마 증거 JSON</a> · <a href="../../godot/screenshots/ui-audit-2026-10-16/extras-evidence.json">보조 캡처 증거 JSON</a> · <a href="../../godot/screenshots/ui-audit-2026-10-16/build-capture.stdout.log">배포 캡처 로그</a></p></details>
<footer>2026.10.16 · 마녀산장 UI 점검 · 게임 구현 변경 없음 · 확대 캡처와 전체 원본 36장 포함</footer></main><dialog id="viewer"><button id="close">닫기</button><div style="clear:both"></div><img id="full" alt="전체 원본 게임 캡처"><p id="caption"></p></dialog><script>const viewer=document.querySelector('#viewer');document.querySelectorAll('.shot').forEach(b=>b.addEventListener('click',()=>{{document.querySelector('#full').src=b.dataset.src;document.querySelector('#caption').textContent=b.dataset.src.split('/').pop();viewer.showModal();}}));document.querySelector('#close').onclick=()=>viewer.close();viewer.addEventListener('click',e=>{{if(e.target===viewer)viewer.close()}});document.querySelectorAll('[data-filter]').forEach(b=>b.onclick=()=>{{let f=b.dataset.filter;document.querySelectorAll('[data-filter]').forEach(x=>x.setAttribute('aria-pressed',x===b));document.querySelectorAll('.item').forEach(x=>x.hidden=!(f==='all'||x.dataset.priority===f||x.dataset.group===f));}});</script></body></html>'''
(OUT/'report.html').write_text(page.replace('</style>', '.item[hidden]{display:none!important}.shot{border-radius:6px}</style>'),encoding='utf-8')

md=['# 마녀산장 UI 그래픽 미적용 점검','', '2026-10-16 · 현재 배포 `build/WitchsLodge.pck` 실제 렌더 · 원본 36장', '', '플레이어용 25개 점검 항목, 개발용 1개, 디자인 검토 4개. 같은 창 안의 하위 요소를 나누어 센 수치입니다.', '', '![대표 6곳](overview.jpg)', '', '| 번호 | 위치 | 현재 표현 | 우선순위 | 캡처 |', '|---|---|---|---|---|']
for x in items: md.append(f'| {x["id"]} | {x["title"]} | {x["status"]} | {x["priority"]} | [원본]({shot_url(x["shot"])}) |')
md+=['','## 근본 연결 상태','','공통 그래픽 14개 PNG는 art/ui/moon-runes-v01/common/에 존재하지만 게임은 StyleBoxFlat을 사용한다. HUD는 interim 텍스처를 사용하고 최종 runtime/common 미설치. 용 활성은 dragon_active 부재로 disabled 착색, 납품은 dragon_normal 이름. 숫자 glyph atlas 미연결.','','## 상세 근거','']
for x in items: md += [f'### {x["id"]}. {x["title"]}', '', x['description'], '',f'코드: `{x["source"]["file"]}:{x["source"]["line"]}`', '',f'![확대]({x["detail"]})','']
(OUT/'report.md').write_text('\n'.join(md),encoding='utf-8')
print(json.dumps({'player_items':len(core),'dev_items':len(dev),'review_items':len(reviews),'screenshots':len(shotmap),'common_pngs':len(common_assets),'report':str(OUT/'report.html')},ensure_ascii=False))
