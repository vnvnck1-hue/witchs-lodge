"""Editable, genuinely volumetric assets for the fixed-camera concept study.
Run with Blender --background --python this_file. Geometry is authored in Godot
coordinates and converted to Blender; glTF export returns Y-up, +Z front.
The atlas is newly generated diffuse artwork, not a projected cutout of the scene.
"""
import bpy, bmesh, math, random, json
from pathlib import Path
from mathutils import Vector, Matrix

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets' / 'painted'
OUT.mkdir(parents=True, exist_ok=True)
random.seed(241013)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
S = Matrix(((1,0,0),(0,0,-1),(0,1,0)))
ATLAS = bpy.data.images.load(str(OUT / 'material_atlas.png'))
ATLAS.pack()
MATS = {}
TILES = {}

def material(name, tile=None, tint=(1,1,1), emission=0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    p = m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value = (*tint,1)
    p.inputs['Roughness'].default_value = 1
    p.inputs['Specular IOR Level'].default_value = 0
    if tile is not None:
        t = m.node_tree.nodes.new('ShaderNodeTexImage')
        t.image = ATLAS
        m.node_tree.links.new(t.outputs['Color'], p.inputs['Base Color'])
        TILES[name] = tile
    if emission:
        p.inputs['Emission Color'].default_value = (*tint,1)
        p.inputs['Emission Strength'].default_value = emission
    MATS[name] = m
    return m

material('Paint_Wood',0)
material('Paint_Stone',1)
material('WallStone',1)
material('Paint_Snow',2)
material('Paint_Foliage',3)
material('Paint_Wool',4)
material('Paint_Hay',5)
material('DarkWood',None,(.13,.065,.036))
material('Iron',None,(.13,.12,.16))
material('WarmWindow',None,(1,.34,.055),1.2)
material('SheepFace',None,(.11,.09,.13))
material('PurpleCloth',None,(.16,.075,.32))
material('PurpleHat',None,(.22,.11,.43))
material('Gold',None,(.58,.33,.075))
material('Skin',None,(.75,.46,.29))
material('Hair',None,(.31,.23,.39))
material('BerryWood',None,(.27,.10,.075))
material('Berry',None,(.48,.14,.11))
material('RockCrease',None,(.025,.020,.035))

def gv(p): return S @ Vector(p)
def rot(o,r):
    if not any(r): return
    R = Matrix.Rotation(math.radians(r[2]),3,'Z') @ Matrix.Rotation(math.radians(r[1]),3,'Y') @ Matrix.Rotation(math.radians(r[0]),3,'X')
    o.rotation_euler = (S @ R @ S.transposed()).to_euler()

def finish(o, mat, bevel=0, smooth=False):
    o.data.materials.append(MATS[mat])
    if bevel:
        mod=o.modifiers.new('Rounded hand-carved edges','BEVEL')
        mod.width=bevel; mod.segments=2
        bpy.context.view_layer.objects.active=o
        bpy.ops.object.modifier_apply(modifier=mod.name)
    if smooth:
        for f in o.data.polygons: f.use_smooth=True
    elif bevel:
        mod=o.modifiers.new('Broad weighted planes','WEIGHTED_NORMAL')
        mod.keep_sharp=True; mod.weight=40
        bpy.context.view_layer.objects.active=o
        bpy.ops.object.modifier_apply(modifier=mod.name)
    if not o.data.uv_layers:
        uv=o.data.uv_layers.new()
        for f in o.data.polygons:
            n=f.normal; axis=max(range(3),key=lambda i:abs(n[i]))
            axes=[i for i in range(3) if i != axis]
            coords=[o.data.vertices[o.data.loops[l].vertex_index].co for l in f.loop_indices]
            mins=[min(c[a] for c in coords) for a in axes]
            spans=[max(c[a] for c in coords)-mins[i] for i,a in enumerate(axes)]
            for li,c in zip(f.loop_indices,coords):
                uv.data[li].uv=tuple((c[a]-mins[i])/max(spans[i],.001) for i,a in enumerate(axes))
    if mat in TILES:
        k=TILES[mat]; col=k%3; row=k//3
        # Blender UV origin bottom-left; atlas row 0 is at the image top.
        for uv in o.data.uv_layers.active.data:
            u,v=uv.uv
            if mat=='Paint_Stone':u=.40+u*.28;v=.38+v*.28
            uv.uv=((col+.04+u*.92)/3, (1-row)*.5+.02+v*.46)
    return o

def box(name, size, p, mat, bevel=.06, r=(0,0,0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=gv(p))
    o=bpy.context.object; o.name=name
    o.dimensions=(size[0],size[2],size[1])
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    rot(o,r)
    return finish(o,mat,min(bevel,min(size)*.3))

def sphere(name, size, p, mat, subdiv=2):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdiv,radius=1,location=gv(p))
    o=bpy.context.object; o.name=name
    o.scale=(size[0],size[2],size[1])
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    # Continuous planar UV over snow/wool avoids a fresh painted swatch per triangle.
    for layer in list(o.data.uv_layers): o.data.uv_layers.remove(layer)
    uv=o.data.uv_layers.new()
    for li,loop in enumerate(o.data.loops):
        c=o.data.vertices[loop.vertex_index].co
        uv.data[li].uv=(.5+c.x/max(size[0]*2,.001),.5+c.y/max(size[2]*2,.001))
    return finish(o,mat,smooth=True)

def mesh(name, verts, faces, mat, smooth=False, bevel=0):
    data=bpy.data.meshes.new(name)
    data.from_pydata([gv(p) for p in verts],[],faces)
    data.update()
    bm=bmesh.new(); bm.from_mesh(data)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    if bm.calc_volume(signed=True)<0:bmesh.ops.reverse_faces(bm,faces=list(bm.faces))
    bm.to_mesh(data); bm.free()
    o=bpy.data.objects.new(name,data); bpy.context.collection.objects.link(o)
    return finish(o,mat,bevel,smooth)

def lathe(name, rings, p, mat, seg=12, r=(0,0,0), smooth=False):
    verts=[]
    for y,rad in rings:
        for i in range(seg):
            a=math.tau*i/seg
            verts.append((math.cos(a)*rad,y,math.sin(a)*rad))
    faces=[tuple(range(seg-1,-1,-1))]
    for k in range(len(rings)-1):
        for i in range(seg):
            j=(i+1)%seg
            faces.append((k*seg+i,k*seg+j,(k+1)*seg+j,(k+1)*seg+i))
    faces.append(tuple((len(rings)-1)*seg+i for i in range(seg)))
    o=mesh(name,verts,faces,mat,smooth)
    o.location=gv(p); rot(o,r)
    return o

def beam(name,a,b,width,depth,mat):
    a,b=Vector(a),Vector(b); d=b-a
    o=box(name,(width,d.length,depth),(a+b)/2,mat,.035)
    o.rotation_euler=gv(d).to_track_quat('Z','Y').to_euler()
    return o

EVIDENCE=[]
def begin():
    bpy.ops.object.select_all(action='DESELECT')
    return set(bpy.data.objects)
def export(name, before):
    objs=[o for o in bpy.data.objects if o not in before and o.type=='MESH']
    collection=bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(collection)
    for o in objs:
        collection.objects.link(o)
        for previous in list(o.users_collection):
            if previous!=collection:previous.objects.unlink(o)
    for o in objs: o.select_set(True)
    # Export mesh data with genuine depth; no camera-facing scene image surfaces.
    bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True,export_apply=True,export_yup=True)
    EVIDENCE.append({'asset':name,'objects':len(objs),'polygons':sum(len(o.data.polygons) for o in objs)})
    for o in objs: o.hide_set(True); o.select_set(False)

def bough(name,y,length,width,yaw,snow=False):
    # Closed folded branch volume with a drooping scalloped perimeter.
    verts=[]
    ring=[]
    for i in range(9):
        t=i/8
        x=length*t
        w=width*math.sin(math.pi*max(.03,t))**.7
        scallop=1 if i%2==0 else .74
        ring.append((x,y-.55*t*t,w*scallop))
    for i in range(8,-1,-1):
        t=i/8; x=length*t; w=width*math.sin(math.pi*max(.03,t))**.7
        ring.append((x,y-.55*t*t,-w*(1 if i%2==0 else .74)))
    verts=ring+[(length*.37,y+.22,0),(length*.37,y-.24,0)]
    faces=[]
    for i in range(len(ring)):
        j=(i+1)%len(ring); faces += [(18,i,j),(19,j,i)]
    o=mesh(name,verts,faces,'Paint_Snow' if snow else 'Paint_Foliage',True)
    rot(o,(0,yaw,0))
    return o

def foliage_tier(y,r,height,phase,snow=False):
    seg=32;verts=[]
    # Folded, scalloped continuous volumes, not cards or perfect primitive cones.
    rings=[(height,.03),(height*.54,.46),(height*.15,.80),(0,1.0),(-.11,.23)]
    if snow: rings=[(height+.045,.02),(height*.58,.43),(height*.30,.71),(height*.15,.84),(height*.13,.68)]
    for k,(dy,rr) in enumerate(rings):
        for i in range(seg):
            a=phase+math.tau*i/seg
            tooth=1.0 if i%4==0 else (.90 if i%2 else .96)
            sway=1+.055*math.sin(a*3+phase)
            drop=height*(.11 if i%4==0 else .02) if k>=2 else 0
            rad=r*rr*tooth*sway
            verts.append((math.cos(a)*rad,y+dy-drop+(.07 if snow else 0),math.sin(a)*rad))
    faces=[]
    for k in range(len(rings)-1):
        for i in range(seg):
            j=(i+1)%seg
            faces.append((k*seg+i,(k+1)*seg+i,(k+1)*seg+j,k*seg+j))
    faces.append(tuple((len(rings)-1)*seg+i for i in range(seg-1,-1,-1)))
    faces.append(tuple(range(seg)))
    o=mesh('Continuous snow shoulder' if snow else 'Layered scalloped bough mass',verts,faces,'Paint_Snow' if snow else 'Paint_Foliage',True)
    # One broad swatch shared continuously along each whole tier.
    k=2 if snow else 3; col=k%3;row=k//3
    for li,loop in enumerate(o.data.loops):
        c=o.data.vertices[loop.vertex_index].co
        u=.5+c.x/(r*2.5);v=.5+c.y/(r*2.5)
        o.data.uv_layers.active.data[li].uv=((col+.04+u*.92)/3,(1-row)*.5+.02+v*.46)
    return o

def sculpt_branch(y,L,w,yaw,snow=False):
    verts=[];nx=21; nz=5
    widthcover=.86 if snow else 1.0
    for underside in [False,True]:
        for ix in range(nx):
            t=(ix/(nx-1))*(.76 if snow else 1.0)
            broad=math.sin(math.pi*max(.07,t))**.62
            # Several drooping tips per spray, rather than one smooth banana lobe.
            tooth=t*20
            tooth_i=int(tooth)
            tooth_t=tooth-tooth_i
            widths=[.80,1.03,.95,.74]
            edge=widths[tooth_i%4]*(1-tooth_t)+widths[(tooth_i+1)%4]*tooth_t
            if snow:edge=.95+.035*math.sin(t*10)
            if snow and ix>nx-4:edge*=max(.03,(nx-1-ix)/3)**.35
            for iz in range(nz):
                v=2*iz/(nz-1)-1
                z=w*broad*v*edge*widthcover
                yy=y+(L/1.95)**.55*(.64-.98*t)+.16*broad*(1-(v*widthcover)**2)
                if snow: yy+=.11
                if underside: yy-=.07 if snow else .22
                verts.append((L*t,yy,z))
    faces=[];off=nx*nz
    for ix in range(nx-1):
        for iz in range(nz-1):
            a=ix*nz+iz; b=(ix+1)*nz+iz
            faces.extend([(a,a+1,b+1,b),(a+off,b+off,b+1+off,a+1+off)])
    for ix in range(nx-1):
        for iz in [0,nz-1]:
            a=ix*nz+iz;b=(ix+1)*nz+iz
            faces.append((a,b,b+off,a+off))
    for ix in [0,nx-1]:
        for iz in range(nz-1):
            a=ix*nz+iz
            faces.append((a,a+off,a+1+off,a+1))
    mat='Paint_Snow' if snow else 'Paint_Foliage'
    o=mesh('Snow blanket on branch' if snow else 'Curved folded bough',verts,faces,mat,True)
    k=TILES[mat];col=k%3;row=k//3
    for li,loop in enumerate(o.data.loops):
        c=o.data.vertices[loop.vertex_index].co
        u=.15+.7*c.x/L;v=.5+c.y/(w*3)
        o.data.uv_layers.active.data[li].uv=((col+.04+u*.92)/3,(1-row)*.5+.02+v*.46)
    rot(o,(0,yaw,0))

def canopy_snow_patch(y,r,height,yaw):
    # A connected snow deposit follows the underlying canopy's broad planes.
    # Three interrupted sectors avoid both a full white ring and isolated beads.
    seg=12;rows=5;verts=[]
    for underside in [False,True]:
        for row in range(rows):
            rr=[.04,.22,.42,.58,.73][row]
            for j in range(seg+1):
                q=j/seg
                a=math.radians(yaw-45+q*90)
                radius=rr*(.91+.09*math.sin(math.pi*q))
                if radius<=.46:dy=1-radius
                elif radius<=.80:dy=.54-(radius-.46)*(.39/.34)
                else:dy=.15-(radius-.80)*.75
                yy=y+dy*height+.065-(.045 if underside else 0)
                verts.append((math.cos(a)*radius*r,yy,math.sin(a)*radius*r))
    width=seg+1;off=rows*width;faces=[]
    for row in range(rows-1):
        for j in range(seg):
            a=row*width+j;c=(row+1)*width+j
            faces.extend([(a,a+1,c+1,c),(a+off,c+off,c+1+off,a+1+off)])
    for row in range(rows-1):
        for j in [0,seg]:
            a=row*width+j;c=(row+1)*width+j;faces.append((a,c,c+off,a+off))
    for row in [0,rows-1]:
        for j in range(seg):
            a=row*width+j;faces.append((a,a+off,a+1+off,a+1))
    o=mesh('Broad connected canopy snow',verts,faces,'Paint_Snow',True)
    for li,loop in enumerate(o.data.loops):
        c=o.data.vertices[loop.vertex_index].co
        u=.5+c.x/(r*2.2);v=.5+c.y/(r*2.2)
        o.data.uv_layers.active.data[li].uv=((2.04+u*.92)/3,.52+v*.46)

def fir_layer(y,r,h,phase,snow=False):
    # Broad closed canopy layers. Snow is outside the foliage surface and extends
    # onto its shoulder, so the next foliage spray cannot bury the whole deposit.
    seg=48;verts=[]
    rings=[(1.0,.025),(.54,.44),(.18,.78),(-.11,1.0),(-.23,.72),(-.12,.015)]
    if snow:rings=[(1.09,.02),(.63,.40),(.31,.67),(.15,.81),(.09,.82),(.15,.69),(.23,.015)]
    for row,(dy,rr) in enumerate(rings):
        for j in range(seg):
            a=math.tau*j/seg+phase
            lobe=.5+.5*math.cos(a*8+phase)
            rad=rr*r*(.91+.09*lobe+.025*math.sin(a*3))
            drop=(.13 if snow else .16)*lobe if 2<=row<=4 else 0
            verts.append((math.cos(a)*rad,y+h*(dy-drop),math.sin(a)*rad))
    faces=[tuple(range(seg-1,-1,-1)),tuple((len(rings)-1)*seg+j for j in range(seg))]
    for row in range(len(rings)-1):
        for j in range(seg):faces.append((row*seg+j,row*seg+(j+1)%seg,(row+1)*seg+(j+1)%seg,(row+1)*seg+j))
    mat='Paint_Snow' if snow else 'Paint_Foliage'
    o=mesh('Soft lobed snow shoulder' if snow else 'Broad pointed fir canopy',verts,faces,mat,True)
    k=TILES[mat];col=k%3;row=k//3
    for li,loop in enumerate(o.data.loops):
        c=o.data.vertices[loop.vertex_index].co
        u=.5+c.x/(r*2.4);v=.5+c.y/(r*2.4)
        o.data.uv_layers.active.data[li].uv=((col+.04+u*.92)/3,(1-row)*.5+.02+v*.46)

def connected_fir_canopy(y,r,h,phase,level,snow=False):
    seg=64;verts=[]
    profile=[(.015,1.0),(.20,.70),(.45,.34),(.72,.05),(.97,-.16),(.79,-.26),(.025,-.12)]
    def height_at(rad):
        for (a,ha),(b,hb) in zip(profile[:5],profile[1:5]):
            if rad<=b:return ha+(hb-ha)*(rad-a)/(b-a)
        return -.16
    rings=[(.015,1.0),(.20,.70),(.45,.34),(.72,.05),(.97,-.16),(.79,-.26),(.025,-.12)]
    if snow:rings=[(.01,0),(.27,0),(.60,0),(.90,0),(1.0,0),(.91,0),(.01,0)]
    for row,(rr,dy) in enumerate(rings):
        for j in range(seg):
            a=math.tau*j/seg+phase
            lobe=.5+.5*math.cos(a*7+phase)
            tooth=[1.0,.92,.84,.93][j%4]
            outline=(.92+.08*lobe)*tooth if not snow else (.97+.03*math.cos(a*7+phase))
            radius=rr
            yy=dy*h
            if snow:
                # Snow grows from a shared summit into several broad shoulders.
                # The same radial height profile keeps it above the foliage.
                coverage=.20+.59*max(0,math.sin(a*2+phase))**.45
                if level>=3:coverage=.91+.045*math.sin(a*3+phase)
                radius=rr*coverage
                yy=height_at(radius)*h+.09
                if row>=4:yy-=.075*(1+lobe)
                if row==6:yy-=.10
            else:
                yy-=.11*h*lobe if 3<=row<=5 else 0
            rad=radius*r*outline
            verts.append((math.cos(a)*rad,y+yy,math.sin(a)*rad))
    faces=[tuple(range(seg-1,-1,-1)),tuple(6*seg+j for j in range(seg))]
    for row in range(6):
        for j in range(seg):faces.append((row*seg+j,row*seg+(j+1)%seg,(row+1)*seg+(j+1)%seg,(row+1)*seg+j))
    mat='Paint_Snow' if snow else 'Paint_Foliage'
    o=mesh('Connected irregular fir snow' if snow else 'Solid drooping fir sprays',verts,faces,mat,True)
    k=TILES[mat];col=k%3;atlasrow=k//3
    for li,loop in enumerate(o.data.loops):
        c=o.data.vertices[loop.vertex_index].co
        u=.5+c.x/(r*2.4);v=.5+c.y/(r*2.4)
        o.data.uv_layers.active.data[li].uv=((col+.04+u*.92)/3,(1-atlasrow)*.5+.02+v*.46)

before=begin()
lathe('Irregular trunk',[(0,.22),(1.7,.13),(5.9,.025)],(0,0,0),'Paint_Wood',9)
for level in range(5):
    t=level/4;y=.83+level*1.06;L=1.95*(1-t*.81)
    h=1.64-level*.19;phase=level*.38
    connected_fir_canopy(y,L,h,phase,level)
    connected_fir_canopy(y,L,h,phase,level,True)
export('snow_pine',before)

before=begin()
for k,(p,size) in enumerate([((-.42,1.10,-.08),(2.12,2.20,2.18)),((.95,.63,.22),(1.42,1.26,1.74)),((1.42,.34,.88),(.91,.68,.96)),((-.99,.27,.95),(.73,.54,.75))]):
    seg=9; outline=[]
    for x,z in [(-1,-.75),(-.50,-1),(.50,-.90),(.95,-.55),(1,.35),(.55,.95),(-.50,.90),(-1,.40),(-1.08,-.15)]:
        outline.append((x*random.uniform(.92,1.04),z*random.uniform(.92,1.04)))
    verts=[]
    for row,(y,scale) in enumerate([(-.5,1.0),(.43,.76)]):
        for j,(x,z) in enumerate(outline):
            dent=.86 if row==1 and j==5 else 1.0
            skew=-.11 if row>0 else 0
            verts.append((p[0]+x*size[0]*.5*scale*dent+skew,p[1]+(y+.035*math.sin(j*2.0+k)-x*.06)*size[1],p[2]+z*size[2]*.5*scale*dent))
    faces=[tuple(range(seg-1,-1,-1)),tuple(seg+j for j in range(seg))]
    for row in range(1):
        for j in range(seg):faces.append((row*seg+j,row*seg+(j+1)%seg,(row+1)*seg+(j+1)%seg,(row+1)*seg+j))
    rock=mesh('Sloping broad boulder planes',verts,faces,'Paint_Stone',False,.085)
    for li,loop in enumerate(rock.data.loops):
        c=rock.data.vertices[loop.vertex_index].co
        u=.5+(c.x-p[0])/(size[0]*1.4);v=.5+(c.z-p[1])/(size[1]*1.2)
        rock.data.uv_layers.active.data[li].uv=((1.04+(.20+u*.60)*.92)/3,.52+(.16+v*.68)*.46)
    # Sparse interrupted cracks follow the actual sloped side planes.
    for j in range(seg):
        a,b,c,d=[Vector(verts[q]) for q in [j,(j+1)%seg,seg+j,seg+(j+1)%seg]]
        outward=Vector(((a+b).x*.5-p[0],0,(a+b).z*.5-p[2])).normalized()*.018
        def surface(u,v):return (a*(1-u)+b*u)*(1-v)+(c*(1-u)+d*u)*v+outward
        for row in range(2):
            if (j+row+k)%3==0:continue
            v=.29+row*.34+.06*math.sin(j*2+k)
            points=[surface(0,v),surface(.47,v-.045),surface(1,v+.025)]
            for start,end in zip(points,points[1:]):beam('Interrupted rock fissure',start,end,.018,.018,'RockCrease')
        if j%2==0:
            points=[surface(.43,.18),surface(.38,.45),surface(.46,.78)]
            for start,end in zip(points,points[1:]):beam('Angular vertical rock fissure',start,end,.018,.018,'RockCrease')
    # Smooth closed snow cap; its irregular lip hangs over the sloping summit.
    perimeter=[]
    for j in range(seg):
        a,b,c,d=[Vector(outline[(j+q)%seg]) for q in [-1,0,1,2]]
        for step in range(4):
            t=step/4
            perimeter.append(.5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t))
    sn=len(perimeter);verts=[]
    for row,scale in enumerate([.025,.42,.74,.90,.95,.84]):
        for j,(x,z) in enumerate(perimeter):
            angle=math.tau*j/sn
            lobe=max(0,math.sin(angle*3+k))**4
            y=[.61,.59,.52,.435-.11*lobe,.39-.11*lobe,.40-.09*lobe][row]
            rim=1+.045*math.sin(angle*3+k) if row>=2 else 1
            verts.append((p[0]+x*size[0]*.5*scale*rim-.11,p[1]+y*size[1]-x*size[1]*.06,p[2]+z*size[2]*.5*scale*rim))
    faces=[tuple(range(sn)),tuple(5*sn+j for j in range(sn-1,-1,-1))]
    for row in range(5):
        for j in range(sn):faces.append((row*sn+j,row*sn+(j+1)%sn,(row+1)*sn+(j+1)%sn,(row+1)*sn+j))
    snow=mesh('Rounded hanging boulder snow',verts,faces,'Paint_Snow',True)
    for li,loop in enumerate(snow.data.loops):
        c=snow.data.vertices[loop.vertex_index].co
        u=.5+(c.x-p[0])/size[0];v=.5+(c.y+p[2])/size[2]
        snow.data.uv_layers.active.data[li].uv=((2.04+u*.92)/3,.52+v*.46)
export('snow_rocks',before)

before=begin()
lathe('Bulged carved staves',[(0,.32),(.13,.36),(.42,.41),(.75,.36),(.87,.32)],(0,0,0),'Paint_Wood',14)
for y in [.14,.71]: lathe('Iron hoop',[(0,.37),(.065,.37)],(0,y,0),'Iron',14)
lathe('Wood lid',[(0,.30),(.035,.30)],(0,.88,0),'Paint_Wood',14)
export('barrel',before)

before=begin()
lathe('Fallen log',[(0,.31),(.8,.35),(1.5,.30),(2.4,.28)],(-1.2,.36,0),'Paint_Wood',12,r=(0,0,-90))
for x in [-1.21,1.21]: lathe('Cut wood end',[(0,.27),(.035,.27)],(x,.36,0),'Paint_Hay',12,r=(0,0,-90))
sphere('Snow along log',(1.05,.13,.26),(0,.67,0),'Paint_Snow',2)
export('fallen_log',before)

before=begin()
for row,zs in enumerate([[-.24,0,.24],[-.12,.12]]):
    for z in zs:
        y=.14+row*.23
        lathe('Split firewood',[(0,.13),(.95,.11)],(-.48,y,z),'Paint_Wood',6,r=(0,0,-90))
        lathe('Golden cut end',[(0,.115),(.02,.115)],(.48,y,z),'Paint_Hay',6,r=(0,0,-90))
export('firewood',before)

before=begin()
lathe('Rolled hay bundle',[(0,.36),(.09,.41),(.93,.41),(1.02,.36)],(0,.43,-.51),'Paint_Hay',16,r=(90,0,0),smooth=True)
for z in [-.28,.28]:lathe('Bound hay strap',[(0,.423),(.045,.423)],(0,.43,z),'DarkWood',16,r=(90,0,0))
export('hay_bale',before)

before=begin()
for i in range(6):
    a=i*math.tau/6
    end=(math.cos(a)*.88,.85+random.random()*.34,math.sin(a)*.88)
    beam('Bare bush limb',(0,.05,0),end,.065,.065,'BerryWood')
    for j in [-1,1]:
        fork=(end[0]+j*.25,end[1]+.22,end[2]+j*.20)
        beam('Simple fork',(end[0]*.72,end[1]*.72,end[2]*.72),fork,.04,.04,'BerryWood')
        sphere('Sparse berry',(.065,.07,.065),fork,'Berry',1)
        for side in [-1,1]:
            tip=(fork[0]+side*.14,fork[1]+.14,fork[2]+side*.12)
            beam('Fine berry twig',fork,tip,.025,.025,'BerryWood')
            sphere('Small terminal berry',(.045,.05,.045),tip,'Berry',1)
export('shrub',before)

before=begin()
outline=[(-.48,-.23),(-.31,-.40),(.29,-.39),(.48,-.16),(.43,.28),(.16,.42),(-.35,.36),(-.50,.10)]
verts=[(x,y,z) for y in [0,.13] for x,z in outline]
faces=[tuple(range(8)),tuple(range(15,7,-1))]+[(j,(j+1)%8,(j+1)%8+8,j+8) for j in range(8)]
mesh('Chipped flat stepping slab',verts,faces,'Paint_Stone',False,.035)
export('step_stone',before)

def snow_tile(size,p,r):
    verts=[];seg=16
    for dy,rad in [(.085,.72),(.04,1.0),(-.065,1.0),(-.085,.93)]:
        for i in range(seg):
            a=math.tau*i/seg
            x=math.copysign(abs(math.cos(a))**.5,math.cos(a))*size[0]*.5*rad
            z=math.copysign(abs(math.sin(a))**.5,math.sin(a))*size[1]*.5*rad
            verts.append((x,dy,z))
    faces=[tuple(range(seg)),tuple(3*seg+i for i in range(seg-1,-1,-1))]
    for row in range(3):
        for i in range(seg):faces.append((row*seg+i,row*seg+(i+1)%seg,(row+1)*seg+(i+1)%seg,(row+1)*seg+i))
    o=mesh('Soft sculpted overlapping snow tile',verts,faces,'Paint_Snow',True)
    o.location=gv(p);rot(o,r)
    for li,loop in enumerate(o.data.loops):
        c=o.data.vertices[loop.vertex_index].co
        o.data.uv_layers.active.data[li].uv=((2.04+(.5+c.x/size[0])*.92)/3,.52+(.5+c.y/size[1])*.46)
    return o

def roof(run,rise,length,base):
    a=math.atan2(rise,run); over=.44; L=math.hypot(run,rise)+over
    depth=length+.64
    for s in [-1,1]:
        down=Vector((s*math.cos(a),-math.sin(a),0)); normal=Vector((s*math.sin(a),math.cos(a),0))
        for row in range(5):
            tw=depth/6
            for j in range(6):
                z=-depth/2+tw*(j+.5)
                p=Vector((0,base+rise,0))+down*(L/5*(row+.5))+normal*(.17+.016*(4-row))
                p.z=z
                o=snow_tile((L/5+.13,tw+.03),p,(0,0,-s*math.degrees(a)+s*2))
                # Slightly asymmetric eave silhouette, not perfect tile rectangles.
                o.location.z+=random.uniform(-.017,.017)
        mid=Vector((0,base+rise,0))+down*(L*.5)
        box('Dark roof underside',(L,.16,depth),mid,'DarkWood',.05,r=(0,0,-s*math.degrees(a)))
        for z in [-depth*.5,depth*.5]:
            p=mid.copy();p.z=z;p.y-=.09
            box('Carved bargeboard',(L+.15,.40,.30),p,'Paint_Wood',.09,r=(0,0,-s*math.degrees(a)))
    for z in [-depth*.5,depth*.5]:
        for s in [-1,1]:
            box('Crossed stout roof ornament',(.34,.94,.34),(s*.12,base+rise+.23,z),'Paint_Wood',.07,r=(0,0,s*31))
        for x in [-.92,.92]:
            yy=base+rise-abs(x)*rise/run+.33
            box('Roof shoulder peg',(.40,.43,.40),(x,yy,z),'Paint_Wood',.08,r=(0,0,-math.copysign(8,x)))
            box('Carved peg inset',(.075,.075,.018),(x,yy+.08,z+.21),'DarkWood',.009)
    lathe('Soft snowy ridge',[(0,.21),(depth,.21)],(0,base+rise+.25,-depth/2),'Paint_Snow',10,r=(90,0,0))

def window(p,yaw,w=.9,h=.84):
    x,y,z=p
    pieces=[('Thick window frame',(w+.20,h+.20,.18),(0,0,0),'Paint_Wood'),('Amber window',(w,h,.08),(0,0,.11),'WarmWindow'),('Vertical mullion',(.07,h,.10),(0,0,.17),'DarkWood'),('Horizontal mullion',(w,.07,.10),(0,0,.17),'DarkWood'),('Window sill',(w+.3,.12,.26),(0,-h/2-.15,.08),'Paint_Wood')]
    R=Matrix.Rotation(math.radians(yaw),3,'Y')
    for name,size,q,mat in pieces:
        pos=Vector(p)+R@Vector(q)
        box(name,size,pos,mat,.045,r=(0,yaw,0))

import runpy
runpy.run_path(str(ROOT/'art_sources'/'build_lodge_redesign.py'))['build'](globals())

before=begin()
box('Extension interior',(3.0,1.70,3.2),(0,1.20,0),'DarkWood',.08)
for side in [-1,1]:
    for row in range(2):
        for j in range(4):
            box('Extension stone footing',(.79,.24,.38),(-1.2+j*.8,.13+row*.22,side*1.65),'Paint_Stone',.07)
            box('Extension side footing',(.38,.24,.79),(side*1.53,.13+row*.22,-1.2+j*.8),'Paint_Stone',.07)
    for row in range(5):
        box('Extension timber wall',(3.0,.30,.17),(0,.66+row*.30,side*1.61),'Paint_Wood',.045)
        box('Extension side timber',(.17,.30,3.2),(side*1.51,.66+row*.30,0),'Paint_Wood',.045)
for x in [-1.50,1.50]:
    for z in [-1.60,1.60]:box('Extension stout upright',(.28,1.8,.28),(x,1.25,z),'Paint_Wood',.065)
verts=[(-1.6,2.05,-1.6),(1.6,2.05,-1.6),(0,3.3,-1.6),(-1.6,2.05,1.6),(1.6,2.05,1.6),(0,3.3,1.6)]
mesh('Extension closed gables',verts,[(0,2,1),(3,4,5),(0,3,5,2),(2,5,4,1),(0,1,4,3)],'Paint_Wood')
roof(1.6,1.25,3.4,2.05)
window((-.3,1.2,1.65),0,.70,.70)
window((-1.56,1.2,0),-90,.60,.60)
export('extension_lodge',before)

before=begin()
for x in [-.12,.12]:
    for z in [-.21,.21]:lathe('Short dark sheep leg',[(0,.052),(.30,.048)],(x,0,z),'SheepFace',8)
sphere('Wool body',(.34,.28,.44),(0,.46,0),'Paint_Wool',2)
for p,s in [((-.15,.56,-.17),(.22,.22,.24)),((.13,.58,-.03),(.24,.20,.25)),((-.10,.54,.20),(.20,.21,.22))]:sphere('Broad wool tuft',s,p,'Paint_Wool',2)
sphere('Dark face',(.135,.16,.18),(0,.47,.47),'SheepFace',2)
sphere('Forehead wool',(.16,.09,.13),(0,.62,.41),'Paint_Wool',2)
for x in [-.14,.14]:sphere('Small sheep ear',(.09,.045,.055),(x,.55,.44),'SheepFace',1)
export('sheep',before)

before=begin()
for x in [-.09,.09]:sphere('Boot',(.08,.06,.12),(x,.06,.045),'SheepFace',2)
lathe('Flowing simple robe',[(.09,.27),(.20,.28),(.45,.16),(.52,.15)],(0,0,0),'PurpleCloth',12,smooth=True)
sphere('Hair mass',(.23,.22,.19),(0,.68,-.04),'Hair',2)
sphere('Face',(.18,.19,.13),(0,.68,.08),'Skin',2)
lathe('Broad hat brim',[(0,.36),(.06,.38),(.09,.34)],(0,.82,0),'PurpleHat',20,smooth=True)
lathe('Hat gold band',[(0,.205),(.065,.19)],(0,.91,0),'Gold',16)
# Bent hat tip rather than rigid cone.
verts=[]; faces=[]; seg=16
for y,rad,cx,cz in [(.91,.205,0,0),(1.14,.14,.02,-.01),(1.32,.10,.065,-.03),(1.40,.05,.16,-.03),(1.34,.012,.24,-.01)]:
    for i in range(seg):
        a=i*math.tau/seg;verts.append((cx+rad*math.cos(a),y,cz+rad*math.sin(a)))
for j in range(4):
    for i in range(seg):faces.append((j*seg+i,j*seg+(i+1)%seg,(j+1)*seg+(i+1)%seg,(j+1)*seg+i))
faces.extend([tuple(range(seg-1,-1,-1)),tuple(4*seg+i for i in range(seg))])
mesh('Crooked soft hat crown',verts,faces,'PurpleHat',True)
for x in [-.24,.24]:sphere('Mitten',(.067,.065,.07),(x,.36,.075),'PurpleCloth',2)
export('witch_body',before)

before=begin()
lathe('Simple wooden staff',[(0,.026),(1.06,.024)],(0,0,0),'Paint_Wood',9)
points=[]
for i in range(10):
    a=math.pi*1.65*i/9
    points.append((.095*math.sin(a),1.05+.095*math.cos(a),0))
for a,b in zip(points[:-1],points[1:]):beam('Carved crooked handle',a,b,.033,.033,'Paint_Wood')
export('witch_staff',before)

for collection in bpy.data.collections:
    for o in collection.objects:o.hide_set(collection.name!='starter_lodge')
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art_sources'/'painted_assets.blend'))
(ROOT/'art_sources'/'asset_evidence.json').write_text(json.dumps(EVIDENCE,indent=2))
print('PAINTED_ASSETS_BUILT',json.dumps(EVIDENCE))
