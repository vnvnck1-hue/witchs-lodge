"""Actual-render comparisons and a route overlay for auditing forest composition."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT.parent/'output/forest-composition'
font=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',22)
bold=ImageFont.truetype('C:/Windows/Fonts/malgunbd.ttf',34)
small=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',17)
layout=json.loads((ROOT/'assets/environment/forest_layout.json').read_text(encoding='utf-8'))

board=Image.new('RGB',(1800,1130),(20,27,38));d=ImageDraw.Draw(board)
d.text((24,15),'마녀산장 / 길을 따라 형성되는 숲 군집',font=bold,fill=(233,240,231))
d.text((26,63),'격자 배치에서 곡선 길 · 바위 중심 군집 · 낮은 수관 연결 · 넓고 좁은 여백으로',font=font,fill=(151,190,181))
for i,stage in enumerate(['before','after']):
    x=12+i*895
    d.text((x+12,112),'이전 배치' if i==0 else '새 배치',font=font,fill=(229,235,228))
    im=Image.open(OUT/f'{stage}-map.png').convert('RGB').resize((880,880),Image.Resampling.LANCZOS)
    board.paste(im,(x,150))
d.text((26,1050),'새 배치: 40개 구성 군집 / 15종 프랍 / 507개 배치 요소 + 기존 자원 나무 / 연결된 6개 길',font=font,fill=(178,204,196))
board.save(OUT/'before-after-map.png')

gallery=Image.new('RGB',(1600,1080),(20,27,38));d=ImageDraw.Draw(gallery)
d.text((24,15),'높은 중심 · 낮은 가장자리 · 길을 따라 이어지는 실루엣',font=bold,fill=(233,240,231))
for i,(site,label) in enumerate([('home','산장 주변'),('north-bend','북쪽 갈림길'),('east-bend','동쪽 굽은 길'),('west-bend','서쪽 바위와 고목 군집')]):
    x=12+i%2*794;y=92+i//2*484
    d.text((x+10,y),label,font=font,fill=(229,235,228))
    im=Image.open(OUT/f'after-{site}.png').convert('RGB').resize((780,439),Image.Resampling.LANCZOS)
    gallery.paste(im,(x,y+32))
gallery.save(OUT/'composition-gallery.png')

# Transparent route lines above the native top-down image, explicitly a guide
# overlay. Native screenshot is kept unchanged in after-map.png.
im=Image.open(OUT/'after-map.png').convert('RGBA')
overlay=Image.new('RGBA',im.size,(0,0,0,0));d=ImageDraw.Draw(overlay)
def point(p):return ((p[0]+50)/100*im.width,(p[1]+50)/100*im.height)
colors=[(255,217,152,180),(172,224,255,180),(236,187,242,180),(172,236,225,180),(255,224,180,180),(206,225,151,180)]
for i,path in enumerate(layout['paths']):d.line([point(p) for p in path],fill=colors[i],width=7,joint='curve')
for label,p in [('산장',[1,1.3]),('벌목터',[-24,5]),('돌 제단',[8,-26]),('야영지',[-20,23]),('전망터',[23,18])]:
    x,y=point(p);d.ellipse((x-8,y-8,x+8,y+8),fill=(250,238,202,230))
    d.text((x+12,y-10),label,font=font,fill=(250,250,235,255),stroke_width=3,stroke_fill=(20,27,38,230))
im=Image.alpha_composite(im,overlay)
plate=Image.new('RGB',(1600,1700),(20,27,38));plate.paste(im.convert('RGB'),(0,100))
d=ImageDraw.Draw(plate)
d.text((26,18),'길과 숲 덩어리의 관계 / 배치 구조 안내',font=bold,fill=(233,240,231))
d.text((28,66),'색선은 길 중심을 보여 주는 안내 오버레이이며 게임 화면에는 표시되지 않습니다.',font=font,fill=(164,192,186))
plate.save(OUT/'route-guide.png')
print('FOREST_REVIEW_PLATES_READY')
