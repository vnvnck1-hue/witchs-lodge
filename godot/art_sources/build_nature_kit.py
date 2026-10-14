"""Authored low-poly woodland kit. Blender 4.5 background; no external assets.
Real closed meshes, corner-painted colors, shared material, Y-up glTF exports.
Each named collection is an independent source asset with its ground pivot at 0.
"""
import bpy, bmesh, math, random, json, argparse, sys
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/nature'
REVIEW = ROOT.parent / 'output/nature-kit'
OUT.mkdir(parents=True, exist_ok=True)
REVIEW.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
for c in list(bpy.data.collections):
    if c.name != 'Collection': bpy.data.collections.remove(c)
random.seed(141026)
COL = None
CAT = []

def rgb(hexcode):
    v = [int(hexcode[i:i+2],16)/255 for i in (0,2,4)]
    return tuple(x/12.92 if x <= .04045 else ((x+.055)/1.055)**2.4 for x in v)

PALETTE = {k:rgb(v) for k,v in dict(
    needle='3B705B', needle_light='63846C', needle_dark='244D48',
    bark='88603F', bark_light='AF8150', bark_dark='503D32',
    heart='C39C64', core='312E30', stone='819391', stone_light='A3AEA1',
    stone_dark='536971', moss='7F9552', moss_light='A5B261',
    vine='567647', fern='508A65', berry='B64E72', snow='CDCFE5',
    snow_light='E7E5F1', cap='B96963', stem='D5BB8D').items()}

MAT=bpy.data.materials.new('Nature_VertexPaint')
MAT.use_nodes=True
p=MAT.node_tree.nodes.get('Principled BSDF')
p.inputs['Roughness'].default_value=1
p.inputs['Specular IOR Level'].default_value=0
c=MAT.node_tree.nodes.new('ShaderNodeVertexColor');c.layer_name='Col'
MAT.node_tree.links.new(c.outputs['Color'],p.inputs['Base Color'])

def gv(p): return Vector((p[0],-p[2],p[1]))
def begin(name,label,category):
    global COL
    COL=bpy.data.collections.new(name);bpy.context.scene.collection.children.link(COL)
    CAT.append(dict(id=name,label=label,category=category))

def mesh(name,verts,faces,color,bevel=0,variation=.08,smooth=False):
    m=bpy.data.meshes.new(name)
    m.from_pydata([gv(v) for v in verts],[],faces);m.update()
    o=bpy.data.objects.new(name,m);COL.objects.link(o)
    # Recalculate outward normals before bevel and GLB export.
    bm=bmesh.new();bm.from_mesh(m);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(m);bm.free()
    if bevel:
        bpy.context.view_layer.objects.active=o
        mod=o.modifiers.new('Broad softened edges','BEVEL');mod.width=bevel;mod.segments=1
        bpy.ops.object.modifier_apply(modifier=mod.name)
    m=o.data;m.materials.append(MAT)
    attr=m.color_attributes.new(name='Col',type='FLOAT_COLOR',domain='CORNER')
    base=PALETTE[color] if isinstance(color,str) else color
    for face in m.polygons:
        face.use_smooth=smooth
        # Color strokes follow planes rather than uniform random vertex noise.
        gain=1+random.uniform(-variation,variation)+max(face.normal.z,0)*.07
        fc=tuple(min(1,x*gain) for x in base)
        for li in face.loop_indices: attr.data[li].color=(*fc,1)
    return o

def soft_spray(a,b,width,height,color='needle',snow=False):
    """Closed, plump curved bough volume, with softly rounded blunt ends.
    The silhouette follows the existing game's broad sculpted branch masses.
    """
    a=Vector(a);b=Vector(b);d=b-a
    side=Vector((-d.z,0,d.x)).normalized()
    nx=11;nz=5;vs=[];fs=[]
    for underside in [False,True]:
        for ix in range(nx):
            t=ix/(nx-1)
            # Keep a broad shoulder, then a rounded terminal face with thickness.
            broad=.10+.90*math.sin(math.pi*(.08+.915*t))**.70
            for iz in range(nz):
                v=2*iz/(nz-1)-1
                center=a+d*t
                if ix==nx-1:center-=d*.075*abs(v)**2
                if ix==0:center+=d*.04*abs(v)**2
                scallop=1+.045*math.sin(t*math.pi*4+v*1.7)
                terminal=.38+.62*math.sin(t*math.pi)**.65
                shoulder=height*(.36+.70*math.sin(t*math.pi))*(1-v*v*.65)*terminal
                # Thick underside avoids razor edges and paper-like leaf cards.
                yoff=-height*.32*terminal if underside else shoulder
                vs.append(center+side*(width*broad*v*scallop)+Vector((0,yoff,0)))
    off=nx*nz
    for ix in range(nx-1):
        for iz in range(nz-1):
            q=ix*nz+iz;r=(ix+1)*nz+iz
            fs.extend([(q,q+1,r+1,r),(q+off,r+off,r+1+off,q+1+off)])
    for ix in range(nx-1):
        for iz in [0,nz-1]:
            q=ix*nz+iz;r=(ix+1)*nz+iz;fs.append((q,r,r+off,q+off))
    for ix in [0,nx-1]:
        for iz in range(nz-1):
            q=ix*nz+iz;fs.append((q,q+off,q+1+off,q+1))
    return mesh('Soft snow blanket' if snow else 'Rounded sculpted foliage mass',vs,fs,color,variation=.035,smooth=True)

def tube(name,points,radii,color='bark',sides=7,cap=True):
    vs=[];fs=[]
    points=[Vector(p) for p in points]
    for j,p in enumerate(points):
        tangent=(points[min(j+1,len(points)-1)]-points[max(0,j-1)]).normalized()
        ref=Vector((0,1,0)) if abs(tangent.y)<.94 else Vector((1,0,0))
        a=tangent.cross(ref).normalized();b=tangent.cross(a).normalized()
        for i in range(sides):
            t=i*math.tau/sides
            vs.append(p+(a*math.cos(t)+b*math.sin(t))*radii[j])
    for j in range(len(points)-1):
        for i in range(sides):
            a=j*sides+i;b=j*sides+(i+1)%sides
            fs.append((a,b,b+sides,a+sides))
    if cap:
        fs.extend([tuple(range(sides-1,-1,-1)),tuple((len(points)-1)*sides+i for i in range(sides))])
    return mesh(name,vs,fs,color,variation=.15)

def leaf(name,a,b,width,color='needle',bend=.10):
    a=Vector(a);b=Vector(b);d=b-a
    side=Vector((-d.z,0,d.x)).normalized()*width
    mid=a+d*.46;ridge=mid+Vector((0,bend,0))
    # Six-sided closed folded lance, including thickness on its underside.
    vs=[a,mid-side,b,mid+side,ridge,mid-Vector((0,.025,0))]
    fs=[(0,1,4),(1,2,4),(2,3,4),(3,0,4),(0,5,1),(1,5,2),(2,5,3),(3,5,0)]
    return mesh(name,vs,fs,color,variation=.13)

def pebble(p,s=.3,color='stone'):
    return rock_piece('Loose stone',p,(s,s*.65,s*.80),random.uniform(-.2,.2),color)

def rock_piece(name,p,size,lean=.25,color='stone',snow=False,moss=False):
    n=7;vs=[];fs=[]
    profile=[(.0,.78),(.16,1.0),(.74,.89),(1,.57)]
    angles=[math.tau*i/n+random.uniform(-.10,.10) for i in range(n)]
    outline=[random.uniform(.87,1.1) for _ in range(n)]
    for j,(h,w) in enumerate(profile):
        for i,t in enumerate(angles):
            y=p[1]+size[1]*h+random.uniform(-.075,.075)*size[1]
            if j==3:y+=math.cos(t+.6)*.18*size[1]
            if j==0:y=p[1]
            shape=outline[i]*(1+.08*math.sin(t*3+j*1.7))
            vs.append((p[0]+math.cos(t)*size[0]*w*shape+h*lean,
                       y,p[2]+math.sin(t)*size[2]*w*shape+h*size[2]*.10))
    for j in range(3):
        for i in range(n):fs.append((j*n+i,j*n+(i+1)%n,(j+1)*n+(i+1)%n,(j+1)*n+i))
    fs.extend([tuple(range(n-1,-1,-1)),tuple(3*n+i for i in range(n))])
    o=mesh(name,vs,fs,color,bevel=.035*min(size),variation=.11)
    if snow or moss:
        top=[Vector(vs[3*n+i])+Vector((0,.018,0)) for i in range(n)]
        center=sum(top,Vector())/n
        patch=[]
        for i,v in enumerate(top):
            factor=1.13 if snow else (.43+.35*math.sin(i*1.8)**2)
            patch.append(center+(v-center)*factor+Vector((0,.07 if snow else .008,0)))
        # Beveled raised cap gives snow a thickness and avoids floating ground discs.
        capvs=patch+[v+Vector((0,.10 if snow else .009,0)) for v in patch]
        capfs=[tuple(range(n-1,-1,-1)),tuple(n+i for i in range(n))]
        capfs.extend((i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n))
        mesh('Snow shoulder' if snow else 'Moss shoulder',capvs,capfs,'snow' if snow else 'moss',.018 if snow else .003,variation=.06)
    return o

def roots(origin,radius=1):
    p=Vector(origin)
    for i in range(5):
        t=i*math.tau/5+random.uniform(-.20,.20);d=Vector((math.cos(t),0,math.sin(t)))
        tube('Flared root',[p+Vector((0,.5*radius,0)),p+d*.4*radius+Vector((0,.13*radius,0)),p+d*radius],
             [.17*radius,.15*radius,.018*radius],sides=6)

def pine(kind=0,snow=False,origin=(0,0,0),scale=1):
    origin=Vector(origin)
    height=[5.4,4.2,5.2,2.25][kind]*scale
    span=[1.55,1.70,1.20,.72][kind]*scale
    lean=[.66,-.26,.39,.20][kind]*scale
    def trunk(y):
        t=y/height
        return origin+Vector((lean*(t*t+.13*math.sin(t*math.tau)),y,.18*scale*math.sin(t*3.5)))
    points=[trunk(height*t) for t in [0,.1,.3,.5,.7,.86,1]]
    tube('Twisting trunk',points,[scale*x for x in [.22,.23,.16,.13,.095,.05,.008]],sides=8)
    roots(origin,.62*scale)
    # Bark strokes curve with the tree, each a narrow raised ridge.
    for i in range(5):
        angle=i*math.tau/5
        pts=[trunk(height*t)+Vector((math.cos(angle)*.15*scale,0,math.sin(angle)*.15*scale)) for t in [.04,.13,.25,.4]]
        tube('Bark ridge',pts,[.018*scale,.026*scale,.021*scale,.006*scale],'bark_light',4)
    levels=[.20,.35,.50,.65,.78,.88] if kind!=2 else [.22,.51,.76,.87]
    for level,yf in enumerate(levels):
        center=trunk(height*yf)
        count=7 if kind==1 else 6
        for k in range(count):
            t=k*math.tau/count+level*.67+random.uniform(-.19,.19)
            d=Vector((math.cos(t),0,math.sin(t)));side=Vector((-d.z,0,d.x))
            length=span*(1-yf)**.67*1.20*random.uniform(.82,1.15)
            tip=center+d*length+Vector((0,-height*.060,0))+side*.10*scale
            mid=center.lerp(tip,.55)+Vector((0,.055*scale,0))
            tube('Crooked bough',[center,mid,tip],[.055*scale,.040*scale,.008*scale],sides=5)
            width=.51*scale*(1-yf)**.45
            thickness=.27*scale*(1-yf)**.40
            soft_spray(center+Vector((0,.01*scale,0)),tip,width,thickness,
                       'needle_light' if level>=4 and k%3==0 else ('needle_dark' if k%4==0 else 'needle'))
            if snow and (k+level)%3!=0:
                soft_spray(center.lerp(tip,.09)+Vector((0,thickness*.89,0)),
                           center.lerp(tip,.76)+Vector((0,thickness*.86,0)),width*.78,thickness*.35,'snow',True)
    # Rounded tuft hides the sharp bare leader without a needle-pointed crown.
    for i in range(3):
        t=i*math.tau/3
        a=trunk(height*.91)
        b=trunk(height*.988)+Vector((math.cos(t)*.10*scale,-.05*scale,math.sin(t)*.10*scale))
        soft_spray(a,b,.16*scale,.095*scale,'needle')

def fern(p=(0,0,0),s=1):
    p=Vector(p)
    for i in range(8):
        t=i*math.tau/8+.15;d=Vector((math.cos(t),0,math.sin(t)));side=Vector((-d.z,0,d.x))
        end=p+d*random.uniform(.65,.94)*s+Vector((0,.25*s,0))
        stem=[p,p+d*.30*s+Vector((0,.38*s,0)),end]
        tube('Fern rachis',stem,[.018*s,.012*s,.003*s],'vine',4)
        for j in range(5):
            f=(j+1)/6;center=p.lerp(end,f)+Vector((0,math.sin(f*math.pi)*.23*s,0))
            w=(1-f)*.33*s
            for sign in [-1,1]:leaf('Fern leaflet',center,center+side*w*sign+d*.14*s-Vector((0,.04*s,0)),.055*s,'fern',.025*s)

def shrub(p=(0,0,0),s=1):
    p=Vector(p)
    for i in range(7):
        t=i*math.tau/7
        d=Vector((math.cos(t),0,math.sin(t)))
        end=p+d*.46*s+Vector((0,random.uniform(.48,.79)*s,0))
        tube('Berry branch',[p,p.lerp(end,.65),end],[.03*s,.018*s,.006*s],'bark_dark',5)
        for j in range(4):
            c=p.lerp(end,.38+j*.15)
            for sign in [-1,1]:
                side=Vector((-d.z,0,d.x))*sign
                leaf('Broad shrub leaf',c,c+side*.25*s+d*.12*s+Vector((0,.13*s,0)),.12*s,'moss' if j==3 else 'needle',.07*s)
        for j in range(3):
            q=end+Vector((.08*math.cos(j*2),-.05,.08*math.sin(j*2)))*s
            rock_piece('Berry',q,(.055*s,.075*s,.055*s),0,'berry')

def vine(points,s=.04):
    tube('Winding ivy',points,[s]*len(points),'vine',6)
    for i,p in enumerate(points[1::2]):
        p=Vector(p)
        direction=Vector((.15*(-1 if i%2 else 1),-.20,.14))
        leaf('Ivy leaf',p,p+direction,.11,'moss',.05)

def snag():
    pts=[(0,0,0),(.12,.6,0),(-.07,1.4,.02),(.28,2.25,.1),(.55,3.4,.13)]
    tube('Wind-worn snag',pts,[.38,.29,.22,.14,.055],sides=8);roots((0,0,0),1)
    for side,y in [(-1,1.15),(1,1.8),(-1,2.65),(1,2.95)]:
        tube('Broken antler branch',[(.08,y,.02),(.08+side*.5,y+.18,.04),(.08+side*.85,y+.6,.10)], [.12,.075,.015],sides=6)
    for t in [0,1.6,3.2,4.8]:
        tube('Split bark ribbon',[(.30*math.cos(t),.10,.30*math.sin(t)),(.12+.25*math.cos(t),.7,.25*math.sin(t)),(-.07+.19*math.cos(t),1.5,.19*math.sin(t))],[.04,.028,.01],'bark_light',4)

def hollow_log(stump=False,snow=False):
    n=11;vs=[];fs=[]
    length=1.1 if stump else 3.4
    def point(t,r,y):
        if stump:return (r*math.cos(t)+y*.07,y,r*math.sin(t))
        return (-length/2+y,.48+r*math.sin(t)+.06*math.sin(y*1.4),r*math.cos(t))
    # Outer profile / inner bore connected by real annuli at both cut ends.
    jag=[random.uniform(-.09,.11) for _ in range(n)]
    for j,(y,r) in enumerate([(0,.54),(length*.20,.62),(length*.76,.51),(length,.43),(0,.34),(length,.27)]):
        for i in range(n):vs.append(point(i*math.tau/n,r*(1+random.uniform(-.05,.05)),y+(jag[i] if j in [0,3,4,5] else 0)))
    for j in range(3):
        for i in range(n):fs.append((j*n+i,j*n+(i+1)%n,(j+1)*n+(i+1)%n,(j+1)*n+i))
    for i in range(n):
        q=(i+1)%n
        fs.extend([(i,4*n+i,4*n+q,q),(3*n+i,3*n+q,5*n+q,5*n+i),(4*n+i,5*n+i,5*n+q,4*n+q)])
    o=mesh('Hollow split stump' if stump else 'Hollow fallen trunk',vs,fs,'bark',variation=.18)
    colors=o.data.color_attributes['Col']
    # Painted annuli separate heartwood from the dark actual hollow interior.
    for face in o.data.polygons:
        if face.index>=3*n:
            c=PALETTE['core' if (face.index-3*n)%3==2 else 'heart']
            for li in face.loop_indices:colors.data[li].color=(*c,1)
    for i in range(7):
        t=i*math.tau/7
        pts=[point(t,.57,y) for y in [0,length*.18,length*.5,length*.80]]
        tube('Long bark fissure',pts,[.028,.036,.022,.012],'bark_dark',4)
        tube('Raised bark plane',[Vector(p)+Vector((0,.018,0)) for p in pts],[.012,.028,.015,.003],'bark_light',4)
    if stump:
        roots((0,0,0),1.0)
        tube('Snapped stump branch',[(.2,.45,.12),(.7,.95,.2),(.86,1.15,.12)],[.19,.09,.015],sides=6)
        vine([(.59*math.cos(t),.1+t*.085,.59*math.sin(t)) for t in [i*.40 for i in range(22)]])
        fern((-.58,0,.36),.6)
    else:
        for x,sign in [(-.8,-1),(.75,1)]:
            tube('Splintered fork',[(x,.6,0),(x+.24,1.08,.4*sign),(x+.12,1.44,.50*sign)],[.18,.10,.02],sides=6)
        vine([(x,.52+math.sin(x*3)*.60,math.cos(x*3)*.55) for x in [-1.4+i*.10 for i in range(29)]],.045)
        fern((-.65,0,.68),.67);shrub((.9,0,-.62),.64)
        if snow:
            leaf('Log snow shelf',(-1.25,1.04,0),(1.22,1.02,.05),.44,'snow',.09)

def rocks(kind,snow=False):
    if kind==0:
        # Staggered strata and a narrow off-center summit; prominent negative seams.
        for p,size,lean in [((0,0,0),(1.05,1.10,.90),.20),((.12,1.00,.07),(.87,1.02,.77),.35),((.47,1.91,.13),(.56,1.05,.53),.39)]:
            rock_piece('Tilted spire stratum',p,size,lean,'stone',snow=snow,moss=not snow)
        rock_piece('Companion shard',(-.93,0,.13),(.42,1.12,.55),-.2,'stone_dark',moss=not snow)
    elif kind==1:
        rock_piece('Overhanging ledge',(-.2,.63,0),(1.95,.90,.94),.52,'stone',snow=snow,moss=not snow)
        rock_piece('Ledge support',(-.65,0,.03),(1.10,.72,.74),.20,'stone_dark')
        rock_piece('Slanted broken slab',(1.07,0,.25),(.77,.62,.68),.38,'stone',snow=snow,moss=not snow)
    elif kind==2:
        rock_piece('Broad rounded angular boulder',(0,0,0),(1.10,1.35,.97),-.12,'stone',snow=snow,moss=not snow)
        rock_piece('Small shoulder',(.85,0,-.12),(.48,.74,.62),.20,'stone_dark',snow=snow,moss=not snow)
    else:
        for p,size,lean in [((0,0,0),(.46,1.80,.46),.18),((.62,0,-.13),(.4,1.10,.44),-.12),((-.44,0,.17),(.33,.68,.39),.05)]:
            rock_piece('Angular shard',p,size,lean,'stone',moss=True)
    for i in range(4):
        t=i*math.tau/4+.2
        pebble((math.cos(t)*1.25,0,math.sin(t)*.95),random.uniform(.13,.25))
    if not snow:
        fern((-.7,0,.85),.6)
        if kind==0:vine([(.53+math.sin(i*.4)*.15,.35+i*.09,.77-i*.015) for i in range(19)])

def mushrooms():
    for p,s in [((0,0,0),1),((.32,0,.22),.65),((-.23,0,.26),.48)]:
        tube('Bent mushroom stalk',[p,(p[0]-.035,.18*s,p[2]),(p[0]+.04,.36*s,p[2])],[.05*s,.035*s,.045*s],'stem',7)
        n=9;vs=[];fs=[]
        for h,r in [(.29,.28),(.39,.22),(.46,.06)]:
            for i in range(n):
                a=i*math.tau/n;vs.append((p[0]+math.cos(a)*r*s,.01+h*s,p[2]+math.sin(a)*r*s))
        for j in range(2):
            for i in range(n):fs.append((j*n+i,j*n+(i+1)%n,(j+1)*n+(i+1)%n,(j+1)*n+i))
        fs.extend([tuple(range(n-1,-1,-1)),tuple(n*2+i for i in range(n))])
        mesh('Asymmetric red cap',vs,fs,'cap',.006)
        for i in range(3):
            a=i*2.1;rock_piece('Ivory cap fleck',(p[0]+math.cos(a)*.15*s,.40*s,p[2]+math.sin(a)*.15*s),(.028*s,.023*s,.024*s),0,'stem')

# 21 individually placeable models, including six winter variants.
for i,label in enumerate(['바람결 침엽수','넓은 침엽수','성긴 침엽수','어린 침엽수']):
    for snow in [False,True]:
        begin(['pine_swept','pine_broad','pine_sparse','pine_sapling'][i]+('_snow' if snow else ''),label+(' · 눈' if snow else ''),'tree')
        pine(i,snow)
begin('dead_snag','갈라진 고사목','wood');snag()
begin('hollow_stump','덩굴 속빈 그루터기','wood');hollow_log(True)
begin('fallen_log','덩굴 쓰러진 고목','wood');hollow_log()
for i,label in enumerate(['층진 바위 첨탑','기울어진 바위 선반','둥근 어깨 바위','세 갈래 바위 조각']):
    for snow in ([False,True] if i<3 else [False]):
        begin(['rock_spire','rock_ledge','rock_boulder','rock_shards'][i]+('_snow' if snow else ''),label+(' · 눈' if snow else ''),'rock')
        rocks(i,snow)
begin('fern_clump','펼쳐진 고사리','undergrowth');fern(s=1.1)
begin('berry_shrub','숲 베리 관목','undergrowth');shrub(s=1.15)
begin('mushroom_cluster','작은 붉은 버섯 무리','undergrowth');mushrooms()

# Consolidate to one mesh / one material / one draw surface per asset, keeping
# component groups in the authoring file below as well as optimized exports.
SOURCE = {}
for entry in CAT:
    col=bpy.data.collections[entry['id']]
    SOURCE[entry['id']]=list(col.objects)
    entry['parts']=len(col.objects)

def export_collection(entry):
    col=bpy.data.collections[entry['id']]
    bpy.ops.object.select_all(action='DESELECT')
    duplicates=[]
    for src in list(col.objects):
        o=src.copy();o.data=src.data.copy();bpy.context.scene.collection.objects.link(o)
        o.select_set(True);duplicates.append(o)
    bpy.context.view_layer.objects.active=duplicates[0]
    bpy.ops.object.join()
    o=bpy.context.object;o.name=entry['id'];o.data.name=entry['id']+'_Mesh'
    # Triangulate explicitly for stable vertex colors and predictable budgets.
    mod=o.modifiers.new('Stable triangles','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=mod.name)
    # Planar UVs are supplied for future hand-painted texture authoring.
    uv=o.data.uv_layers.new(name='PlanarUV')
    for poly in o.data.polygons:
        axes=sorted(range(3),key=lambda a:abs(poly.normal[a]))[:2]
        for li in poly.loop_indices:
            co=o.data.vertices[o.data.loops[li].vertex_index].co;uv.data[li].uv=(co[axes[0]]*.2,co[axes[1]]*.2)
    bpy.ops.export_scene.gltf(filepath=str(OUT/(entry['id']+'.glb')),export_format='GLB',use_selection=True,
        export_yup=True,export_materials='EXPORT',export_all_vertex_colors=True)
    verts=[v.co for v in o.data.vertices]
    lo=Vector(tuple(min(v[a] for v in verts) for a in range(3)))
    hi=Vector(tuple(max(v[a] for v in verts) for a in range(3)))
    entry.update(triangles=len(o.data.polygons),vertices=len(verts),size=[round(hi.x-lo.x,3),round(hi.z-lo.z,3),round(hi.y-lo.y,3)],
                 bounds_min=[round(lo.x,4),round(lo.z,4),round(-hi.y,4)],bounds_max=[round(hi.x,4),round(hi.z,4),round(-lo.y,4)])
    bm=bmesh.new();bm.from_mesh(o.data)
    entry['non_manifold_edges']=sum(not e.is_manifold for e in bm.edges);bm.free()
    bpy.data.objects.remove(o,do_unlink=True)

for entry in CAT:export_collection(entry)
(OUT/'catalog.json').write_text(json.dumps(dict(version=1,units='meters',up='Y',pivot='ground',assets=CAT),indent=2,ensure_ascii=False),encoding='utf-8')

# Dedicated source only: source collections arranged as a readable library.
scene=bpy.context.scene
scene.render.engine='BLENDER_EEVEE_NEXT'
scene.render.resolution_x=800;scene.render.resolution_y=800;scene.render.resolution_percentage=100
scene.world.color=(.12,.15,.20)

# Render actual geometry under a neutral studio rig; source .blend is saved
# before creating preview-only stage/camera/light objects.
scene.world.use_nodes=True
bg=scene.world.node_tree.nodes['Background'];bg.inputs[0].default_value=(.14,.18,.23,1);bg.inputs[1].default_value=.6
scene.view_settings.view_transform='Standard';scene.view_settings.look='None'
data=bpy.data.cameras.new('Preview');data.type='ORTHO'
cam=bpy.data.objects.new('Preview',data);scene.collection.objects.link(cam);scene.camera=cam
for pos,energy,size in [((5,8,6),1050,7),((-5,5,2),650,6),((0,6,-6),900,5)]:
    d=bpy.data.lights.new('Studio','AREA');d.energy=energy;d.size=size
    o=bpy.data.objects.new('Studio',d);scene.collection.objects.link(o);o.location=gv(pos)
    o.rotation_euler=(gv((0,1,0))-o.location).to_track_quat('-Z','Y').to_euler()
for entry in CAT:
    for col in bpy.data.collections:
        for o in col.objects:o.hide_render=col.name!=entry['id']
    size=entry['size'];height=size[1]
    center=Vector(((entry['bounds_min'][0]+entry['bounds_max'][0])*.5,height*.47,(entry['bounds_min'][2]+entry['bounds_max'][2])*.5))
    cam.location=gv(center+Vector((8,6,10)))
    cam.rotation_euler=(gv(center)-cam.location).to_track_quat('-Z','Y').to_euler()
    data.ortho_scale=max(height*1.21,size[0]*1.28,size[2]*1.4,1.15)
    scene.render.film_transparent=True
    scene.render.filepath=str(REVIEW/(entry['id']+'.png'))
    bpy.ops.render.render(write_still=True)
# Lay out an editable source library around explicit local-origin empties.
for o in list(bpy.data.objects):
    if o.type in ['LIGHT','CAMERA']:bpy.data.objects.remove(o,do_unlink=True)
for index,entry in enumerate(CAT):
    col=bpy.data.collections[entry['id']]
    pivot=bpy.data.objects.new(entry['id']+'_GroundPivot',None);col.objects.link(pivot)
    pivot.empty_display_type='PLAIN_AXES';pivot.empty_display_size=.4
    pivot.location=(index%7*6,index//7*7,0)
    for o in SOURCE[entry['id']]:
        o.hide_render=False;o.parent=pivot
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art_sources/nature_kit.blend'))
print('NATURE_KIT_COMPLETE',len(CAT),'assets',sum(e['triangles'] for e in CAT),'triangles; non-manifold',sum(e['non_manifold_edges'] for e in CAT))
