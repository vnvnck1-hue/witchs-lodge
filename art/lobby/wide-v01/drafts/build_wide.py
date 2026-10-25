"""Reproduce only the explicitly authorized wide PNGs and review images.
Never starts Godot or modifies an existing non-wide asset.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import numpy as np
import json

ROOT = Path(__file__).resolve().parents[4]
D = Path(__file__).resolve().parent
OUT = D.parent
A = ROOT / 'godot/assets/ui/lobby'
SIZE = (2640,1080)

def array(im): return np.array(im, dtype=np.float32)

def extend(gen_name, source_name, mode, boundary):
    src = Image.open(A / (source_name+'.png')).convert(mode)
    gen = Image.open(D / gen_name).convert(mode).resize(SIZE,Image.Resampling.LANCZOS)
    strip = gen.crop((0,0,boundary,1080)).resize((720,1080),Image.Resampling.LANCZOS)
    if mode == 'RGBA':
        repaired=Image.open(D/'03-wing-correction-imagegen.png').convert('RGBA').resize(SIZE,Image.Resampling.LANCZOS)
        repaired=repaired.crop((0,0,720,1080))
        mask=Image.new('L',(720,1080),0)
        ma=np.zeros((1080,720),dtype=np.uint8)
        for y in range(460,681):
            ma[y,:]=round(255*min(1,(y-460)/28,(680-y)/28))
        strip=Image.composite(repaired,strip,Image.fromarray(ma))
    arr = array(strip)
    # Narrow one-sided boundary correction; the protected source is never blended.
    residual = array(src)[:,0,:] - arr[:,-1,:]
    weight = np.exp(-(719-np.arange(720,dtype=np.float32))/9.0)
    arr += residual[:,None,:] * weight[None,:,None]
    strip = Image.fromarray(np.uint8(np.clip(np.rint(arr),0,255)))
    if mode == 'RGBA':
        arr=np.array(strip)
        # Generated solids arrive at alpha 250..253; restore opaque interiors,
        # retaining the generated silhouette and partial antialiasing boundary.
        arr[:,:,3][arr[:,:,3]>=250]=255
        # Finish the clipped original wing tip with its own sampled pigment.
        source=np.array(src)
        for x in range(699,720):
            frac=(x-699)/20
            lo=int(round(560-8*frac))
            hi=int(round(560+10*frac))
            if hi<=lo: continue
            ys=np.linspace(552,570,hi-lo+1).round().astype(int)
            arr[lo:hi+1,x,:]=source[ys,0,:]
        # Quiet the far-left margin as requested, fading out before the original.
        shade=np.clip((540-np.arange(720))/540,0,1).astype(np.float32)
        rgb=arr[:,:,:3].astype(np.float32)
        rgb*=1-shade[None,:,None]*np.array([.15,.18,.07],dtype=np.float32)
        rgb+=shade[None,:,None]*np.array([2,0,3],dtype=np.float32)
        arr[:,:,:3]=np.uint8(np.clip(np.rint(rgb),0,255))
        # Preserve the generated alpha silhouette; clear RGB only where alpha is zero.
        arr[arr[:,:,3]==0,:3]=0
        strip=Image.fromarray(arr)
    wide=Image.new(mode,SIZE)
    wide.paste(strip,(0,0))
    wide.paste(src,(720,0))
    wide.save(A/(source_name+'_wide.png'))
    return wide

def ui(comp):
    for name in ['title','menu_continue','menu_new','menu_archive','menu_settings','menu_exit','menu_moon','menu_underline']:
        layer=Image.new('RGBA',SIZE)
        layer.paste(Image.open(A/('lobby_'+name+'.png')),(720,0))
        comp=Image.alpha_composite(comp,layer)
    return comp

def ids(ch):
    m=Image.new('L',(720,1080),20)
    draw=ImageDraw.Draw(m)
    dwarf=[(0,748),(100,730),(200,709),(300,694),(400,675),(500,654),(600,646),(680,641),(719,640),(719,1079),(0,1079)]
    draw.polygon(dwarf,fill=160)
    for x in range(699,720):
        f=(x-699)/20
        lo=int(round(560-8*f)); hi=int(round(560+10*f))
        if hi>lo: draw.line((x,lo,x,hi),fill=220,width=1)
    arr=np.array(m)
    arr[np.array(ch)[:,:720,3]==0]=0
    result=Image.new('RGB',SIZE)
    result.paste(Image.fromarray(arr).convert('RGB'),(0,0))
    result.paste(Image.open(A/'lobby_character_ids.png'),(720,0))
    result.save(A/'lobby_character_ids_wide.png')
    (D/'id-contours.json').write_text(json.dumps({'human_and_nearest_fur':20,'dwarf':{'value':160,'polygon':dwarf},'wing_tip':{'value':220,'x_range':[699,719],'center_y':560,'top_at_seam':552,'bottom_at_seam':570}},indent=2),encoding='utf-8')
    return result

def overlay(comp, idmap):
    colors={20:(64,184,244),40:(214,169,244),60:(128,211,100),80:(241,136,223),100:(255,178,95),120:(158,113,240),160:(237,106,97),180:(192,208,75),200:(88,218,170),220:(97,221,234),240:(255,235,118),140:(130,130,255)}
    labels=np.array(idmap)[:,:,0]
    rgba=np.zeros((1080,2640,4),dtype=np.uint8)
    for k,color in colors.items(): rgba[labels==k]=[*color,128]
    return Image.alpha_composite(comp,Image.fromarray(rgba))

def sheet(comp,idpic):
    font_path='C:/Windows/Fonts/malgun.ttf'
    font=ImageFont.truetype(font_path,28)
    small=ImageFont.truetype(font_path,25)
    s=Image.new('RGB',(5280,2248),(29,26,38))
    draw=ImageDraw.Draw(s)
    labels=['1. 전체 재합성 · 2640×1080 · UI x+720','2. 이음매 x=600~840 · 2배 · 왼쪽: 상단 / 오른쪽: 하단','3. 21:9 · 오른쪽 기준 x=80~2639 · 2560×1080','4. 구역 지도 · 원화 위 50% 겹침']
    for i,label in enumerate(labels):
        x=(i%2)*2640; y=(i//2)*1124
        draw.text((x+20,y+5),label,font=font,fill=(237,228,213))
    s.paste(comp.convert('RGB'),(0,44))
    seam=comp.crop((600,0,840,1080))
    s.paste(seam.crop((0,0,240,540)).resize((480,1080)),(3400,44))
    s.paste(seam.crop((0,540,240,1080)).resize((480,1080)),(3904,44))
    draw.text((2690,100),'원본 시작: x=720\n\n세 파일 모두\nx≥720 차이 0픽셀\n\n인물: RGBA\n배경·지도: RGB\n\n원본 글자 레이어\nx+720 고정',font=small,fill=(214,208,222),spacing=16)
    s.paste(comp.crop((80,0,2640,1080)).convert('RGB'),(40,1168))
    s.paste(idpic.convert('RGB'),(2640,1168))
    s.save(OUT/'sheet.png')
    s.resize((2640,1124),Image.Resampling.LANCZOS).save(D/'sheet-preview.png')

def checker():
    yy,xx=np.mgrid[:1080,:2640]
    c=np.where(((xx//24+yy//24)%2)==0,92,119).astype(np.uint8)
    return Image.fromarray(np.dstack([c,c,c,np.full_like(c,255)]))

def main():
    bg=extend('02-background-imagegen.png','lobby_bg','RGB',720)
    ch=extend('01-characters-imagegen.png','lobby_characters','RGBA',714)
    idmap=ids(ch)
    comp=ui(Image.alpha_composite(bg.convert('RGBA'),ch))
    idpic=overlay(comp,idmap)
    idpic.save(D/'ids-overlay.png')
    sheet(comp,idpic)
    comp.save(D/'recomposite.png')
    comp.crop((80,0,2640,1080)).save(D/'crop-21x9.png')
    comp.crop((60,0,2640,1080)).save(D/'crop-3440x1440-equivalent.png')
    comp.crop((600,0,840,1080)).resize((480,2160)).save(D/'seam-2x.png')
    Image.alpha_composite(checker(),ch).save(D/'characters-checker.png')
    shifted=Image.new('RGBA',SIZE)
    shifted.paste(ch,(-6,-4))
    ui(Image.alpha_composite(bg.convert('RGBA'),shifted)).save(D/'shifted-minus6-minus4.png')

if __name__=='__main__': main()
