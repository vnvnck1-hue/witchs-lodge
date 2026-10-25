"""Deterministic extraction. Writes only the two handoff-authorized asset folders.
Run from any directory with Python 3, Pillow and NumPy. No Godot import or export.
"""
from pathlib import Path
import hashlib, json, math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[4]
OUT = ROOT / 'art/lobby/layers-v01'
DRAFT = OUT / 'drafts'
GAME = ROOT / 'godot/assets/ui/lobby'
SOURCE = ROOT / 'art/concepts/lobby/races-closeup-distant-v02/03-races-closeup-distant.png'
W, H = 1920, 1080
S = np.asarray(Image.open(SOURCE).convert('RGB'), dtype=np.float32)
Y, X = np.mgrid[:H, :W]

def save_rgb(a, path):
    Image.fromarray(np.uint8(np.clip(np.rint(a), 0, 255))).save(path)

def save_l(a, path):
    Image.fromarray(np.uint8(np.clip(np.rint(a * 255), 0, 255))).save(path)

def blur(a, radius):
    if a.ndim == 3:
        return np.stack([blur(a[..., c], radius) for c in range(a.shape[2])], -1)
    # Three separable floating-point box passes approximate a Gaussian without
    # byte quantization artifacts in the normalized inpainting denominator.
    n=max(1,round(radius)); result=a.astype(np.float32)
    for _ in range(3):
        for axis in (0,1):
            pad=[(0,0)]*2;pad[axis]=(n,n)
            padded=np.pad(result,pad,mode='edge')
            cumulative=np.cumsum(padded,axis=axis,dtype=np.float64)
            zero=list(cumulative.shape);zero[axis]=1
            cumulative=np.concatenate([np.zeros(zero),cumulative],axis=axis)
            hi=[slice(None)]*2;lo=[slice(None)]*2
            hi[axis]=slice(2*n+1,None);lo[axis]=slice(None,-(2*n+1))
            result=((cumulative[tuple(hi)]-cumulative[tuple(lo)])/(2*n+1)).astype(np.float32)
    return result

def smooth(a, b, x):
    t = np.clip((x-a)/(b-a), 0, 1)
    return t*t*(3-2*t)

def poly(points, value=255, supersample=1):
    im = Image.new('L', (W*supersample,H*supersample))
    ImageDraw.Draw(im).polygon([(round(x*supersample), round(y*supersample)) for x,y in points],fill=value)
    if supersample > 1:
        im = im.resize((W,H),Image.Resampling.LANCZOS)
    return np.asarray(im)

def rect_mask(box):
    x0,y0,x1,y1=box
    return (X>=x0)&(X<x1)&(Y>=y0)&(Y<y1)

# The outer foreground edge is traced in original pixels; anchors are retained
# for review. Local contrast snapping keeps original fine ink/hair detail.
EDGE = [
 (0,1142),(5,1158),(10,1172),(18,1182),(27,1193),(34,1200),(43,1206),
 (56,1218),(68,1218),(78,1228),(91,1234),(101,1231),(110,1227),
 (120,1233),(135,1240),(145,1244),(156,1245),(167,1241),(180,1241),
 (194,1233),(202,1219),(211,1215),(221,1218),(229,1233),(239,1232),
 (251,1224),(261,1214),(270,1201),(284,1202),(297,1217),(306,1210),
 (316,1221),(326,1231),(336,1237),(346,1245),(356,1251),(366,1244),
 (377,1240),(386,1233),(397,1233),(409,1221),(421,1209),(430,1192),
 (439,1191),(445,1218),(454,1230),(464,1236),(475,1246),(487,1253),(500,1268),
 (514,1271),(522,1261),(534,1257),(540,1241),(548,1234),(554,1221),(560,1200),(578,1199),
 (591,1185),(601,1150),(612,1133),(626,1109),(640,1084),(654,1054),
 (667,1022),(680,988),(687,963),(697,943),(707,919),
 (714,1001),(707,1028),(692,1050),(689,1069),(696,1077),(682,1085),
 (674,1094),(678,1108),(689,1115),(699,1110),(704,1120),(709,1147),
 (718,1169),(731,1182),(742,1193),(753,1198),(768,1200),(778,1198),
 (785,1186),(799,1192),(813,1191),(827,1187),(842,1179),(853,1168),
 (862,1162),(874,1167),(883,1160),(894,1150),(902,1148),(911,1149),
 (922,1146),(936,1140),(947,1132),(958,1122),(968,1107),(973,1085),
 (975,1054),(983,1040),(993,1046),(1002,1084),(1015,1102),(1034,1113),
 (1048,1120),(1057,1127),(1062,1148),(1072,1167),(1079,1173)]

def character_matte():
    global traced_brim_boundary
    # Use polygon rather than sorting anchors: the narrow background gap between
    # witch brim and goblin hair must remain an actual transparent cutout.
    edge=EDGE.copy()
    # Trace the actual concave opening between the orc scarf and witch brim.
    # A rightmost-pixel envelope would incorrectly include the tree in it.
    guide=np.array([(560,1158),(570,1150),(580,1140),(590,1125),(600,1114),
       (610,1103),(620,1088),(630,1071),(640,1054),(650,1036),(660,1015),
       (670,1004),(680,978),(690,950),(700,924),(708,905)])
    traced=[]
    for y in range(565,709):
        g=float(np.interp(y,guide[:,0],guide[:,1])); candidates=np.arange(round(g)-18,round(g)+19)
        contrast=(S[y,candidates+2,1]-S[y,candidates-2,1])*np.exp(-((candidates-g)/16)**2)
        traced.append((y,int(candidates[np.argmax(contrast)])))
    traced_brim_boundary=traced
    first=edge.index((591,1185));last=edge.index((714,1001))
    edge=edge[:first+1]+[(583,1171),(574,1160),(562,1156)]+traced+edge[last:]
    pts=[(0,0)]+[(x,y) for y,x in edge]+[(0,H-1)]
    a=poly(pts,supersample=4).astype(np.float32)/255
    # Background visible in extreme upper-left corner above the man's fur.
    a *= 1-poly([(0,0),(109,0),(78,16),(46,24),(26,30),(10,30),(0,22)],supersample=4)/255
    # Source ink/chroma resolves individual strands and the curved nose inside
    # a narrow search band around the hand-traced contour. Lavender forest has
    # much more blue than the foreground ink, olive skin and warm hair.
    hard=Image.fromarray(np.uint8(a>.5)*255)
    inner=np.asarray(hard.filter(ImageFilter.MinFilter(49)))>0
    search=np.asarray(hard.filter(ImageFilter.MaxFilter(29)))>0
    chroma=S[...,2]-(S[...,0]+S[...,1])*.5
    score=np.clip((194-S[...,1])/26,0,1)*np.clip((198-S[...,2])/32,0,1)*np.clip((22-chroma)/17,0,1)
    brim=rect_mask((900,570,1165,710))
    purple_ink=np.clip((128-S[...,1])/18,0,1)*np.clip((165-S[...,2])/25,0,1)
    score[brim]=np.maximum(score[brim],purple_ink[brim])
    refined=search*score
    refined[inner]=1
    # Orc's pale warm fur is the only light silhouette against a blue tree.
    fur=rect_mask((1180,420,1280,563))&search
    warm=np.clip((S[...,0]-S[...,2]-2)/18,0,1)
    refined[fur]=np.maximum(refined[fur],warm[fur])
    # The small cream opening below the brim is real negative space, not hair.
    gap=rect_mask((930,665,1125,718))&(S[...,1]>215)&(S[...,2]>200)
    refined[gap]=0
    refined[refined<.025]=0
    # Highlights inside a closed outer ink contour belong to the solid figure.
    # Flood only background connected to the canvas boundary, retaining real
    # open gaps between the brim and goblin hair.
    flood=Image.fromarray(np.uint8(refined>.7)*255).copy()
    for corner in [(0,0),(W-1,0),(0,H-1),(W-1,H-1)]:
        if flood.getpixel(corner)==0: ImageDraw.floodfill(flood,corner,128)
    holes=np.asarray(flood)==0
    refined[holes]=1
    # Remove isolated warm tree flecks in the exterior search band. All seven
    # visible figures form one connected ensemble in the approved painting.
    connected=Image.fromarray(np.uint8(refined>0)*255).copy()
    ImageDraw.floodfill(connected,(0,H-1),128)
    refined[np.asarray(connected)!=128]=0
    return np.clip(refined,0,1)

UI = {
 'lobby_title.png': (1285,185,1885,552),
 'lobby_menu_continue.png': (1502,566,1682,625),
 'lobby_menu_new.png': (1503,662,1725,718),
 'lobby_menu_archive.png': (1503,744,1698,798),
 'lobby_menu_settings.png': (1503,826,1588,880),
 'lobby_menu_exit.png': (1774,981,1868,1024),
 'lobby_menu_moon.png': (1441,569,1498,623),
 'lobby_menu_underline.png': (1505,625,1775,640),
}

def ui_mattes():
    result={}
    estimates={}
    removals={}
    for name,box in UI.items():
        region=rect_mask(box)
        # Separate original burgundy ink and gold brush from cream paper.
        if name in ['lobby_menu_moon.png','lobby_menu_underline.png']:
            seed=region & ((S[...,0]-S[...,1])>14) & ((S[...,0]-S[...,2])>30) & (S[...,1]<230)
        else:
            seed=region & (S[...,1]<172) & (S[...,0]<192)
        expanded=np.asarray(Image.fromarray(np.uint8(seed)*255).filter(ImageFilter.MaxFilter(9)))>0
        # Estimate only local background from pixels outside the ink footprint.
        known=(~expanded).astype(np.float32)
        den=np.maximum(blur(known,30),.003)
        est=blur(S*known[...,None],30)/den[...,None]
        near_den=blur(known,12)
        near_est=blur(S*known[...,None],12)/np.maximum(near_den[...,None],.00001)
        use_near=smooth(.002,.035,near_den)[...,None]
        est=est*(1-use_near)+near_est*use_near
        est=np.clip(est,0,255)
        # The normalized convolution is stable where valid paper surrounds ink.
        # Large logo strokes are opaque; the estimate matters at the thin edge.
        dist=np.linalg.norm(S-est,axis=-1)
        support=np.asarray(Image.fromarray(np.uint8(seed)*255).filter(ImageFilter.MaxFilter(5)))>0
        a=np.zeros((H,W),np.float32)
        # Obtain ink alpha from local edge color separation. Strong ink is exact
        # original RGB, fractional edges are unpremultiplied below.
        if name in ['lobby_menu_moon.png','lobby_menu_underline.png']:
            core=seed & ((S[...,0]-S[...,1])>50) & (S[...,1]<145)
            default_ink=np.array([169,94,30],np.float32)
        else:
            core=seed & (S[...,1]<90) & (S[...,0]<140)
            default_ink=np.array([64,32,54],np.float32)
        ink_weight=blur(core.astype(np.float32),5)
        ink=blur(S*core[...,None],5)/np.maximum(ink_weight[...,None],.0001)
        ink[ink_weight<.01]=default_ink
        vector=ink-est
        coverage=np.sum((S-est)*vector,-1)/np.maximum(np.sum(vector*vector,-1),1)
        a[region&support]=np.clip(coverage[region&support],0,1)
        # Genuine interior texture stays opaque; coverage is only recovered
        # along the outline, holes and fine brush ends.
        interior=np.asarray(Image.fromarray(np.uint8(seed)*255).filter(ImageFilter.MinFilter(5)))>0
        a[interior]=1
        a[core & (coverage>.94)]=1
        a[dist<2]=0
        a[a<1/255]=0
        result[name]=a
        estimates[name]=est
        fringe_band=np.asarray(Image.fromarray(np.uint8(seed)*255).filter(ImageFilter.MaxFilter(7)))>0
        bright_fringe=np.mean(S-est,axis=-1)>9
        removals[name]=(seed|(fringe_band&bright_fringe))&region
    return result,estimates,removals

def ids_for(alpha):
    ids=np.zeros((H,W),np.uint8)
    ids[alpha>0]=20
    def p(value,points):
        ids[(poly(points)>0)&(alpha>0)]=value
    # Back to front, following the visible ink divisions of the approved art.
    p(40,[(413,0),(835,0),(834,48),(866,104),(862,135),(918,160),(956,184),(964,212),(944,235),(906,261),(891,282),(953,338),(965,440),(829,435),(784,381),(699,307),(589,259),(492,190),(399,169),(430,109),(449,63)])
    p(60,[(795,0),(1240,0),(1265,260),(1270,410),(1203,445),(1220,603),(1155,611),(1099,526),(943,464),(898,376),(868,299),(897,267),(951,236),(966,207),(953,182),(913,163),(858,143),(863,116),(846,72),(813,61)])
    p(60,[(1170,395),(1254,408),(1280,455),(1280,566),(1215,605),(1170,599),(1150,515)])
    # Witch body and white hair are under the brim and the lower foreground.
    p(100,[(450,530),(655,506),(791,475),(889,485),(926,539),(927,575),(961,640),(970,675),(944,708),(921,728),(894,741),(883,767),(826,806),(770,838),(719,941),(697,1080),(484,1080),(445,791),(461,713),(444,634)])
    p(120,[(374,180),(403,166),(435,171),(480,196),(535,213),(583,237),(626,274),(662,293),(709,329),(775,365),(817,398),(858,416),(909,435),(974,448),(1048,456),(1113,474),(1156,502),(1170,532),(1158,568),(1125,604),(1080,640),(1024,668),(971,690),(921,706),(950,670),(949,646),(924,607),(910,568),(895,522),(875,493),(824,489),(766,516),(713,546),(657,568),(572,583),(473,576),(402,550),(358,531),(336,478),(351,396),(367,324),(382,265)])
    # White hair and face sit in front of the inner brim. This follows the
    # curved hair/hat border rather than assigning a bounding rectangle.
    p(100,[(460,579),(520,583),(583,578),(644,570),(700,551),(745,531),(787,505),(823,491),(857,489),(879,498),(892,519),(904,550),(914,580),(934,613),(952,640),(966,660),(966,684),(957,703),(938,722),(913,740),(888,746),(872,767),(838,790),(797,810),(757,823),(729,869),(709,943),(690,1015),(486,917),(465,752),(444,634)])
    # Fairy wings visible to the left, above the dwarf and behind fairy.
    p(220,[(0,552),(79,531),(143,512),(232,493),(284,486),(292,476),(256,466),(216,451),(180,434),(163,420),(187,414),(220,422),(249,438),(277,455),(303,480),(325,500),(310,539),(250,574),(165,590),(96,590),(40,584),(0,570)])
    p(80,[(267,375),(318,394),(348,380),(385,369),(419,369),(456,375),(486,387),(502,412),(519,434),(515,461),(494,484),(484,509),(472,529),(458,554),(463,582),(480,604),(475,628),(463,640),(446,629),(425,616),(395,606),(374,588),(340,582),(297,575),(255,580),(268,548),(288,518),(282,475),(291,443),(286,412)])
    # Fairy antennae have narrow curves and rounded tips; don't label the
    # intervening hat as antenna. Supersampling is unnecessary for ID labels.
    antenna=Image.new('L',(W,H)); d=ImageDraw.Draw(antenna)
    d.line([(461,386),(479,365),(488,341),(483,317),(470,297),(450,286),(433,285)],fill=240,width=8)
    d.ellipse((420,278,447,302),fill=240)
    d.line([(491,397),(519,375),(543,356),(564,346),(586,346),(603,354),(607,365)],fill=240,width=8)
    d.ellipse((595,350,621,378),fill=240)
    ar=np.asarray(antenna); ids[(ar>0)&(alpha>0)]=240
    p(160,[(0,640),(41,617),(86,598),(144,587),(202,578),(276,576),(352,580),(411,600),(454,628),(484,661),(493,696),(505,716),(511,744),(521,760),(512,779),(493,789),(509,818),(532,842),(577,876),(609,923),(656,960),(694,1020),(723,1080),(0,1080)])
    # Dwarf's shoulder armor occupies the far lower-left.
    p(180,[(682,1080),(690,1004),(706,968),(735,929),(770,906),(773,870),(793,824),(832,787),(871,756),(914,730),(954,714),(1000,701),(1027,699),(1048,687),(1068,686),(1084,697),(1089,674),(1106,681),(1117,699),(1161,709),(1199,743),(1201,791),(1194,827),(1172,857),(1168,877),(1150,903),(1150,930),(1136,951),(1110,970),(1058,975),(1040,992),(1069,1003),(1102,1015),(1121,1056),(1175,1080)])
    p(200,[(679,845),(710,831),(754,824),(807,821),(857,823),(907,827),(945,837),(966,858),(977,887),(976,910),(962,926),(938,932),(920,918),(891,917),(861,916),(821,906),(775,892),(739,875),(701,862)])
    p(200,[(854,902),(873,901),(881,913),(877,927),(891,934),(901,949),(900,966),(890,977),(874,982),(856,976),(846,965),(846,947),(854,935),(861,924),(858,916)])
    return ids

def alpha_layer(original, alpha, background):
    # Straight alpha, never premultiplied; transparent RGB is zero. Keep all
    # opaque interior source pixels unchanged and recover edge color using the
    # actual underlying clean plate so recomposition survives integer rounding.
    # Ensure recovered edge RGB is representable in byte straight-alpha PNG.
    bg=background.astype(np.float32)
    up=np.maximum(original-bg,0)/np.maximum(255-bg,1)
    down=np.maximum(bg-original,0)/np.maximum(bg,1)
    required=np.maximum(up,down).max(-1)
    a=np.where(alpha>0,np.maximum(alpha,required),0)
    a=np.ceil(np.clip(a,0,1)*255)/255
    rgb=np.zeros_like(original)
    support=a>0
    rgb[support]=(original[support]-background[support]*(1-a[support,None]))/a[support,None]
    rgb=np.clip(np.rint(rgb),0,255).astype(np.uint8)
    return Image.fromarray(np.dstack([rgb,np.uint8(np.rint(a*255))]),'RGBA')

def build():
    GAME.mkdir(parents=True,exist_ok=True)
    generated=np.asarray(Image.open(DRAFT/'01-background-imagegen.png').convert('RGB').resize((W,H),Image.Resampling.LANCZOS),dtype=np.float32)
    ca=character_matte()
    ui,estimates,removals=ui_mattes()
    # Original background, with only ink pixels restored from adjacent paper.
    bg=S.copy()
    for name,a in ui.items():
        region=rect_mask(UI[name])
        # Continue paper across the whole lettering footprint, including its
        # counters. Limit correction on genuine paper to six byte levels so
        # grain survives and no letter-shaped restoration patch is visible.
        paper=np.clip(estimates[name],S-6,S+6)
        weak_white_fringe=(a==0)&(np.mean(S-estimates[name],axis=-1)>0)
        paper[weak_white_fringe]=np.clip(estimates[name],S-8,S+8)[weak_white_fringe]
        x0,y0,x1,y1=UI[name]
        edge_distance=np.minimum.reduce([X-x0,x1-1-X,Y-y0,y1-1-Y])
        paper_weight=smooth(0,10,edge_distance)[...,None]
        paper=S*(1-paper_weight)+paper*paper_weight
        bg[region]=paper[region]
        bg[removals[name]]=estimates[name][removals[name]]
        bg[a>0]=estimates[name][a>0]
        if name=='lobby_menu_underline.png':
            bg[region]=estimates[name][region]
    clean_source_background=bg.copy()
    # Hidden background restoration is localized to character support and
    # permitted seam cleanup, plus tiny original fringe/negative-space marks.
    # Extend the local color/atmosphere into a genuinely painted clean forest.
    # Do not mirror source pixels: a reflected wisp or letter would make a
    # recognizable ghost. The broad correction bridges the 80px safety band.
    silhouette=Image.fromarray(np.uint8(ca>0)*255)
    expanded=np.asarray(silhouette.filter(ImageFilter.MaxFilter(9)))>0
    known=(~expanded).astype(np.float32)
    den=blur(known,48)
    delta=blur((clean_source_background-generated)*known[...,None],48)/np.maximum(den[...,None],.003)
    strength=np.clip(den*16,0,1)
    restored=np.clip(generated+np.clip(delta,-90,90)*strength[...,None],0,255)
    # Include the upper-left uncovered corner in the same clean extension.
    cm=ca>0
    permitted=((X>=1140)&(X<1381)&(Y>=50)&(Y<850))|((X>=1140)&(Y>=50)&(Y<291))
    cm|=(np.asarray(silhouette.filter(ImageFilter.MaxFilter(31)))>0)&permitted
    cm|=rect_mask((930,665,1125,718))&(S[...,1]>215)&(S[...,2]>200)&(ca==0)
    cm|=rect_mask((1145,0,1205,12))&(ca==0)
    cm|=rect_mask((1145,0,1205,32))&(ca==0)&(S[...,0]>S[...,2]+15)&(S[...,1]>195)
    brim_cleanup=Image.new('L',(W,H))
    ImageDraw.Draw(brim_cleanup).line([(x,y) for y,x in traced_brim_boundary],fill=255,width=3)
    cm|=(np.asarray(brim_cleanup)>0)&(ca==0)
    # Match visible scenery in a narrow transition without washing out the
    # painted forest. Exclude a small guard band from exterior samples and
    # limit the correction so stray source highlights cannot be propagated.
    exterior_mask=np.asarray(Image.fromarray(np.uint8(cm)*255).filter(ImageFilter.MaxFilter(5)))==0
    exterior=exterior_mask.astype(np.float32)
    forest_anchor=restored.copy()
    for radius in [12,6,3]:
        support=blur(exterior,radius)
        extension=blur(clean_source_background*exterior[...,None],radius)/np.maximum(support[...,None],.0001)
        extension=np.clip(extension,forest_anchor-12,forest_anchor+12)
        confidence=smooth(.015,.16,support)[...,None]
        restored=restored*(1-confidence)+extension*confidence
    bg[cm]=restored[cm]
    # Fix just the explicitly permitted box boundary. The weight is compactly
    # supported in the +/-120px seam strips, with 100+px organic feathering.
    seam_vertical=rect_mask((1140,50,1381,850))
    seam_horizontal=rect_mask((1140,50,1920,291))
    exclude=seam_vertical|seam_horizontal
    organic=1260+17*np.sin(Y/89)+11*np.sin(Y/33)
    edge_weight=np.exp(-((X-organic)/71)**2)*.75
    top_weight=np.exp(-((Y-(170+14*np.sin(X/107)))/66)**2)*.7
    weight=np.maximum(edge_weight,top_weight)*exclude*(1-ca)
    # Compact edge falloff eliminates any replacement boundary at strip ends.
    vertical_taper=(1-smooth(90,120,abs(X-1260)))*(1-smooth(750,850,Y))*smooth(50,80,Y)
    horizontal_taper=(1-smooth(90,120,abs(Y-170)))*smooth(1140,1170,X)
    weight*=np.maximum(vertical_taper,horizontal_taper)
    # Use generated organic mist after matching it to original cream brightness.
    mist=blur(bg,48)
    vertical_taper=(1-smooth(22,120,abs(X-organic)))*(1-smooth(750,850,Y))*smooth(50,80,Y)
    horizontal_taper=(1-smooth(22,120,abs(Y-(170+14*np.sin(X/107)))))*smooth(1140,1170,X)
    weight=np.maximum(vertical_taper,horizontal_taper)*exclude*(1-ca)
    bg=bg*(1-weight[...,None])+mist*weight[...,None]
    bg=np.clip(np.rint(bg),0,255).astype(np.uint8)
    save_rgb(bg,GAME/'lobby_bg.png')
    layers={}
    layers['lobby_characters.png']=alpha_layer(S,ca,bg)
    for name,a in ui.items(): layers[name]=alpha_layer(S,a,bg)
    for name,im in layers.items(): im.save(GAME/name)
    ids=ids_for(np.asarray(layers['lobby_characters.png'])[...,3])
    save_rgb(np.repeat(ids[...,None],3,-1),GAME/'lobby_character_ids.png')
    save_l(ca,DRAFT/'character-alpha.png')
    save_l(exclude.astype(float),DRAFT/'verification-exclusion-mask.png')
    save_l(weight,DRAFT/'cream-seam-edit-mask.png')
    save_rgb(restored,DRAFT/'background-restoration-before-composite.png')
    (DRAFT/'contour-anchors.json').write_text(json.dumps({'edge_y_x':EDGE,'ui_search_boxes':UI},indent=2),encoding='utf-8')
    layout={'canvas':{'width':W,'height':H},'alpha':'straight','coordinates':'original top-left pixels','layers':{}}
    for name,im in layers.items():
        box=im.getchannel('A').getbbox()
        layout['layers'][name]={'x':box[0],'y':box[1],'w':box[2]-box[0],'h':box[3]-box[1]}
    (GAME/'lobby_layout.json').write_text(json.dumps(layout,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    composite=Image.fromarray(bg).convert('RGBA')
    for im in layers.values(): composite=Image.alpha_composite(composite,im)
    composite.convert('RGB').save(DRAFT/'recomposite.png')
    # Meaningful image checks use actual saved-and-reloaded PNGs.
    recon=np.asarray(composite.convert('RGB'),dtype=np.int16)
    difference=np.abs(recon-S.astype(np.int16)); maximum=difference.max(-1)
    valid=~exclude
    tested=maximum[valid]
    check_ids=set(int(v) for v in np.unique(ids))
    stat={
      'source':str(SOURCE.relative_to(ROOT)).replace('\\','/'),
      'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
      'canvas':[W,H], 'composite_order':['lobby_bg.png']+list(layers),
      'comparison':{'metric':'max absolute RGB channel difference per pixel; integer straight-alpha over',
       'included_pixels':int(valid.sum()),'excluded_pixels':int(exclude.sum()),
       'exact_pixels_percent':float(np.mean(tested==0)*100),
       'within_2_percent':float(np.mean(tested<=2)*100),
       'over_8_pixels':int(np.sum(tested>8)), 'over_8_percent':float(np.mean(tested>8)*100),
       'max_channel_difference':int(tested.max()),'mean_absolute_channel_difference':float(difference[valid].mean()),
       'pass':bool(np.mean(tested<=2)>.5 and np.mean(tested>8)<.005)},
      'excluded_regions':{'reason':'handoff permitted cream box boundary +/-120px; no other exclusions',
       'rectangles_xywh':[[1140,50,241,800],[1140,50,780,241]],
       'mask':'drafts/verification-exclusion-mask.png'},
      'ids':{'values':sorted(check_ids),'grayscale':True,'antialias':False,
        'zero_exactly_matches_transparent':bool(np.array_equal(ids==0,np.asarray(layers['lobby_characters.png'])[...,3]==0)),
        'wolf_ears_140':'omitted: cropped above frame'},
      'assets':{},
      'visual_review':{'status':'pending','shift_pixels':[-6,-4]},
    }
    for path in sorted([GAME/n for n in ['lobby_bg.png','lobby_character_ids.png']+list(layers)]):
        if path.suffix=='.png':
            im=Image.open(path)
            item={'size':list(im.size),'mode':im.mode,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
            if im.mode=='RGBA':
                a=np.asarray(im)[...,3]; item.update({'transparent_pixels':int(np.sum(a==0)),'partial_alpha_pixels':int(np.sum((a>0)&(a<255)))})
            stat['assets'][path.name]=item
    (OUT/'verification.json').write_text(json.dumps(stat,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    palette={20:(218,127,76),40:(116,154,205),60:(141,173,81),80:(215,149,224),100:(66,199,206),120:(145,91,190),160:(232,181,78),180:(231,105,114),200:(150,224,113),220:(103,135,238),240:(248,83,211)}
    color=np.zeros((H,W,3),np.uint8)
    for value,rgb in palette.items(): color[ids==value]=rgb
    overlay=S.copy(); sel=ids>0; overlay[sel]=S[sel]*.5+color[sel]*.5
    save_rgb(overlay,OUT/'ids-overlay.png')
    # A full-resolution diagnostic plus the required six-up QA sheet.
    yy,xx=np.mgrid[:H,:W]; checker=np.where(((xx//24+yy//24)%2)[...,None],np.array([178,181,191]),np.array([224,225,231])).astype(np.uint8)
    charcheck=Image.alpha_composite(Image.fromarray(checker).convert('RGBA'),layers['lobby_characters.png'])
    uicheck=Image.fromarray(checker).convert('RGBA')
    for name,im in layers.items():
        if name!='lobby_characters.png': uicheck=Image.alpha_composite(uicheck,im)
    shifted=Image.new('RGBA',(W,H)); shifted.paste(layers['lobby_characters.png'],(-6,-4))
    shiftcomp=Image.alpha_composite(Image.fromarray(bg).convert('RGBA'),shifted)
    for name,im in layers.items():
        if name!='lobby_characters.png':shiftcomp=Image.alpha_composite(shiftcomp,im)
    shiftcomp.convert('RGB').save(DRAFT/'shifted-minus6-minus4.png')
    charcheck.save(DRAFT/'characters-on-checker.png');uicheck.save(DRAFT/'ui-on-checker.png')
    panels=[Image.fromarray(S.astype(np.uint8)),composite,Image.fromarray(bg),charcheck,uicheck,shiftcomp]
    labels=['1 ORIGINAL / 1920 x 1080','2 RECOMPOSITED LAYERS','3 CLEAN BACKGROUND','4 CHARACTERS / CHECKER','5 TITLE + MENU / CHECKER','6 CHARACTERS OFFSET -6, -4']
    sheet=Image.new('RGB',(1920*3,1128*2),(27,27,39)); d=ImageDraw.Draw(sheet)
    font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',25)
    for i,(panel,label) in enumerate(zip(panels,labels)):
        px=(i%3)*W; py=(i//3)*1128
        sheet.paste(panel.convert('RGB'),(px,py+48)); d.text((px+18,py+11),label,font=font,fill='white')
    sheet.save(OUT/'sheet.png')
    sheet.resize((1920,752),Image.Resampling.LANCZOS).save(DRAFT/'sheet-preview.png')
    print(json.dumps(stat['comparison'],indent=2))
    print('ID values',sorted(check_ids))

if __name__=='__main__': build()
