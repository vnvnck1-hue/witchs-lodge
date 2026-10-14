"""Labeled native-render comparison plates; no painted screenshots or mockups."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT.parent/'output/painted-ground'
font=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',22)
small=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',18)
bold=ImageFont.truetype('C:/Windows/Fonts/malgunbd.ttf',34)

board=Image.new('RGB',(1600,1120),(20,26,38));d=ImageDraw.Draw(board)
d.text((26,17),'마녀산장 / 주변 바닥 핸드페인팅 적용',font=bold,fill=(231,235,245))
d.text((28,66),'Juggernaut Wars의 큰 붓질·불규칙한 돌판·이끼 색면을 설경에 반영',font=font,fill=(157,185,194))
for row,(site,label) in enumerate([('logging','서쪽 벌목터'),('south-path','남쪽 숲길')]):
    suffix='off' if site=='logging' else 'dramatic'
    y=112+row*498
    for col,(stage,title) in enumerate([('before','적용 전'),('after','적용 후')]):
        x=12+col*794
        d.text((x+10,y),label+' · '+title,font=font,fill=(216,222,236))
        im=Image.open(OUT/f'{stage}-{site}-{suffix}.png').convert('RGB')
        im=im.resize((780,439),Image.Resampling.LANCZOS)
        board.paste(im,(x,y+37))
board.save(OUT/'before-after.png')

gallery=Image.new('RGB',(1600,1060),(20,26,38));d=ImageDraw.Draw(gallery)
d.text((25,16),'산장 밖 4곳 / 실제 게임 화면',font=bold,fill=(231,235,245))
d.text((27,64),'눈밭 · 드러난 돌판 길 · 프랍 아래 이끼와 서리',font=font,fill=(157,185,194))
for i,(site,label) in enumerate([('logging','서쪽 벌목터'),('shrine','달빛 돌 제단'),('camp','숲속 야영지'),('lookout','설원 전망터')]):
    x=12+i%2*794;y=112+i//2*468
    d.text((x+10,y),label,font=font,fill=(216,222,236))
    im=Image.open(OUT/f'after-{site}-dramatic.png').convert('RGB').resize((780,439),Image.Resampling.LANCZOS)
    gallery.paste(im,(x,y+30))
gallery.save(OUT/'exterior-gallery.png')
print('GROUND_REVIEW_PLATES_READY')
