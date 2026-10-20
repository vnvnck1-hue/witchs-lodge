import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import numpy as np
from scipy import ndimage
FONT=r"C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/fonts/NotoSansKR-wght.ttf"
INK=(28,22,20)
# targets (1024x1536) measured on timber/wool/raw_meat
TITLE_H, TITLE_CY = 100, 150
CLASS_H, CLASS_CY = 45, 247
RULE_H, RULE_CY = 63, (1272, 1357)
MAXW = 800
CARDS={
 "fire_ale":("불꽃 에일","주점 · 싸움 술",["용병 한 명이 그 밤 더 세게 싸웁니다.","다음 날 숙취로 잠시 쉽니다."]),
 "golden_mead":("금빛 꿀술","주점 · 대접하는 술",["묵는 손님에게 대접합니다.","내일 선물을 들고 다시 찾아옵니다."]),
 "wisp_spirit":("도깨비불 독주","주점 · 도박하는 술",["손패 카드 한 장에 붓습니다.","반은 한 장 더, 반은 주머니로."]),
 "dew_of_forgetting":("망각의 이슬주","주점 · 잊게 하는 술",["주머니 카드 하나를 영원히 잊습니다.","다음 날 아침엔 머리가 멍합니다."]),
}
def font(px, wght):
    f=ImageFont.truetype(FONT, px); f.set_variation_by_axes([wght]); return f
def size_for(glyph_h, wght):
    # font px so that Hangul ink height ('한글다') equals glyph_h
    f=font(200,wght); b=f.getbbox("한글다릴"); return int(round(200*glyph_h/(b[3]-b[1])))
def draw_lines(img, lines, glyph_h, centers, wght, maxw=MAXW):
    S=3; W,H=img.size
    px=size_for(glyph_h,wght)
    while True:
        f=font(px*S,wght)
        widths=[f.getbbox(t)[2]-f.getbbox(t)[0] for t in lines]
        if max(widths)<=maxw*S or px<20: break
        px-=1
    layer=Image.new('L',(W*S,H*S),0); d=ImageDraw.Draw(layer)
    for t,cy in zip(lines,centers):
        b=f.getbbox("한글다릴"); ref_mid=(b[1]+b[3])/2
        bw=f.getbbox(t); w=bw[2]-bw[0]
        d.text((W*S/2-w/2-bw[0], cy*S-ref_mid), t, font=f, fill=255)
    layer=layer.resize((W,H),Image.LANCZOS).filter(ImageFilter.GaussianBlur(0.35))
    ink=Image.new('RGB',(W,H),INK); img.paste(ink,(0,0),layer)
    return px
LEAD=85
STROKE=1
def global_squeeze(px, wght=900, maxw=800):
    f=font(px,wght)
    worst=max(f.getbbox(t,stroke_width=STROKE)[2]-f.getbbox(t,stroke_width=STROKE)[0] for c in CARDS.values() for t in c[2])
    return min(1.0, maxw/worst)
def draw_rules(img, rules):
    wght=900; px=size_for(RULE_H,wght); sq=global_squeeze(px,wght)
    S=3; W,H=img.size; f=font(px*S,wght)
    b=f.getbbox("한글다릴"); ref_mid=(b[1]+b[3])/2
    for t,cy in zip(rules,RULE_CY):
        bw=f.getbbox(t,stroke_width=STROKE*S); w=bw[2]-bw[0]; h=int(px*S*2)
        lay=Image.new('L',(w+20,h),0); ImageDraw.Draw(lay).text((10-bw[0], h/2-ref_mid), t, font=f, fill=255, stroke_width=STROKE*S, stroke_fill=255)
        lay=lay.resize((max(1,round(lay.width*sq/S)),round(h/S)),Image.LANCZOS).filter(ImageFilter.GaussianBlur(0.35))
        img.paste(Image.new('RGB',lay.size,INK),(round(W/2-lay.width/2),round(cy-lay.height/2)),lay)
    return (px,round(sq,3))
def _unused(img, rules):
    wght=800; px=size_for(RULE_H,wght); f=font(px,wght)
    out=[]
    for sent in rules:
        cur=""
        for w in sent.split(" "):
            t=(cur+" "+w).strip()
            if f.getbbox(t)[2]-f.getbbox(t)[0] <= MAXW or cur=="": cur=t
            else: out.append(cur); cur=w
        out.append(cur)
    mid=(RULE_CY[0]+RULE_CY[1])/2
    centers=[mid+(i-(len(out)-1)/2)*LEAD for i in range(len(out))]
    draw_lines(img,out,RULE_H,centers,wght,maxw=10000)
    return (px,len(out))

def build(cid, tpl_path, out):
    title,cls,rules=CARDS[cid]
    t=np.asarray(Image.open('base_blank.png').convert('RGB').resize((1024,1536))).astype(np.float32)
    r,g,b=t[...,0],t[...,1],t[...,2]
    k=np.clip(((g-np.maximum(r,b))-60)/(160-60),0,1)
    lab,n=ndimage.label(k>0.5); sizes=ndimage.sum(np.ones_like(k),lab,range(1,n+1)); order=np.argsort(sizes)[::-1]+1
    win=lab==order[0]; tok=lab==order[1]
    out_img=t.copy()
    cream=np.median(t[1250:1300,150:300].reshape(-1,3),axis=0)
    # window art (cover fit)
    ys,xs=np.where(win); x0,x1,y0,y1=xs.min(),xs.max(),ys.min(),ys.max(); W,H=x1-x0+1,y1-y0+1
    art=Image.open(f'art_{cid}.png').convert('RGB'); s=max(W/art.width,H/art.height)*1.02
    art=art.resize((round(art.width*s),round(art.height*s)),Image.LANCZOS); ox=(art.width-W)//2; oy=(art.height-H)//2
    full=np.zeros_like(t); full[y0:y1+1,x0:x1+1]=np.asarray(art.crop((ox,oy,ox+W,oy+H))).astype(np.float32)
    # token: cream fill + icon cropped from the previous card's token
    ic=np.asarray(Image.open(f'icon_{cid}.png').convert('RGB')).astype(np.float32)
    bg=np.median(np.concatenate([ic[:20].reshape(-1,3),ic[-20:].reshape(-1,3)]),axis=0)
    im_=np.clip((np.sqrt(((ic-bg)**2).sum(axis=2))-18)/30,0,1)
    yy,xx=np.where(im_>0.5); icon=Image.fromarray(ic[yy.min():yy.max()+1,xx.min():xx.max()+1].astype(np.uint8))
    imask=Image.fromarray((im_[yy.min():yy.max()+1,xx.min():xx.max()+1]*255).astype(np.uint8))
    ty,tx=np.where(tok); tx0,tx1,ty0,ty1=tx.min(),tx.max(),ty.min(),ty.max(); tw,th=tx1-tx0+1,ty1-ty0+1
    sc=min(tw*0.92/icon.width, th*1.0/icon.height)
    icon=icon.resize((round(icon.width*sc),round(icon.height*sc)),Image.LANCZOS); imask=imask.resize(icon.size,Image.LANCZOS)
    tokimg=Image.new('RGB',(1024,1536),tuple(int(v) for v in cream)); tokimg.paste(icon,(tx0+(tw-icon.width)//2, ty0+(th-icon.height)//2),imask)
    full=np.where(tok[...,None], np.asarray(tokimg).astype(np.float32), full)
    m=Image.fromarray((k*255).astype(np.uint8)).filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(0.8))
    m=np.asarray(m).astype(np.float32)[...,None]/255
    o=t*(1-m)+full*m
    gg=o[...,1]; lim=np.maximum(o[...,0],o[...,2]); o[...,1]=np.where((gg>lim+25)&(m[...,0]<0.98),lim,gg)
    img=Image.fromarray(o.clip(0,255).astype(np.uint8))
    p1=draw_lines(img,[title],TITLE_H,[TITLE_CY],900)
    p2=draw_lines(img,[cls],CLASS_H,[CLASS_CY],900)
    p3=draw_rules(img,rules)
    img.save(out); print(cid,'font px title/class/rules',p1,p2,p3)
for cid in sys.argv[1:]:
    build(cid,f'tpl_{cid}.png',f'final_{cid}.png')
