from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
folder=Path('C:/Users/Loadcomplete/.codex/generated_images/01a15367-76f3-7812-8c12-57c14513e9b1')
paths=sorted(folder.glob('*.png'))
board=Image.new('RGB',(1800,500*((len(paths)+5)//6)),'#231d30')
d=ImageDraw.Draw(board); font=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',17)
for i,p in enumerate(paths):
    im=Image.open(p).convert('RGBA'); im.thumbnail((288,432))
    x=10+(i%6)*300; y=10+(i//6)*500
    d.text((x,y),p.stem[:18],font=font,fill='#ffedcb')
    board.paste(im,(x,y+35),im)
board.save('output/goblin-cards-v01/source-sheet.png')
print(len(paths))
