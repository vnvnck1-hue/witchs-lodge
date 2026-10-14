"""Contact sheet from real Blender renders, with asset IDs for placement."""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT.parent/'output/nature-kit'
CAT=json.loads((ROOT/'assets/nature/catalog.json').read_text(encoding='utf-8'))['assets']
regular=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',18)
small=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',14)
bold=ImageFont.truetype('C:/Windows/Fonts/malgunbd.ttf',32)
title=ImageFont.truetype('C:/Windows/Fonts/malgunbd.ttf',20)
W=1960;CW=268;CH=338;GAP=10;LEFT=12;TOP=122
board=Image.new('RGB',(W,TOP+CH*3+GAP*2+62),(19,27,37))
d=ImageDraw.Draw(board)
d.text((26,18),'마녀산장  /  자연물 프랍 라이브러리',font=bold,fill=(233,239,224))
d.text((28,66),'Blender 실물 렌더 · 단품 21종 + 조합 프리팹 5종 · 설경 변형 포함',font=regular,fill=(164,190,179))
d.line((26,104,W-26,104),fill=(70,96,91),width=2)
for i,e in enumerate(CAT):
    x=LEFT+(i%7)*(CW+GAP);y=TOP+(i//7)*(CH+GAP)
    d.rounded_rectangle((x,y,x+CW,y+CH),radius=10,fill=(31,43,52),outline=(49,66,73))
    im=Image.open(OUT/(e['id']+'.png')).convert('RGBA')
    im.thumbnail((CW-16,CH-80),Image.Resampling.LANCZOS)
    board.paste(im,(x+(CW-im.width)//2,y+3+(CH-80-im.height)//2),im)
    d.text((x+13,y+CH-76),e['label'],font=regular,fill=(228,233,219))
    d.text((x+13,y+CH-48),e['id'],font=small,fill=(167,193,193))
    d.text((x+13,y+CH-25),f"{e['triangles']:,} tris  ·  {e['size'][1]:.2f} m",font=small,fill=(115,147,153))
d.text((28,board.height-37),'지면 피벗 / +Y Up / 공유 재질 / Blender 버텍스 페인팅 / 실제 3D 메시',font=regular,fill=(159,180,180))
board.save(OUT/'nature-kit-contact-sheet.png')
# Tight, labeled overview of actual in-engine clusters; native render only.
im=Image.open(OUT/'showcase-soft.png').convert('RGB')
box=(280,200,1475,765)
im=im.crop(box).resize((1600,756),Image.Resampling.LANCZOS)
plate=Image.new('RGB',(1600,880),(19,27,37));plate.paste(im,(0,100))
d=ImageDraw.Draw(plate)
d.text((28,18),'바위 · 침엽수 · 고목  /  조합 프리팹 5종',font=bold,fill=(233,239,224))
d.text((30,66),'위: 이끼 첨탑 숲 / 바위 선반 숲 / 고목 군락     아래: 설경 첨탑 / 설경 선반',font=regular,fill=(166,192,185))
plate.save(OUT/'nature-kit-clusters.png')
print('NATURE_REVIEW_READY',OUT)
