"""Curved, closed volumetric lodge meshes following the new three-view design.

Called by build_painted_assets.py; keep the existing root/collision footprint.
No scene-image projection or building cards. Wood and snow have continuous UVs.
"""
import math, random
from mathutils import Vector, Matrix


def build(b):
    box,sphere,mesh,lathe,beam,begin,export=[b[k] for k in ['box','sphere','mesh','lathe','beam','begin','export']]
    rng=random.Random(60713)
    b['material']('LodgeWood',0)
    b['material']('LodgeStone',1)
    b['material']('LodgeMortar',None,(.22,.16,.12))
    before=begin()

    def uv(o,mat,axes,center,span):
        k=b['TILES'][mat];col=k%3;row=k//3
        for li,loop in enumerate(o.data.loops):
            c=o.data.vertices[loop.vertex_index].co
            u=.5+(c[axes[0]]-center[0])/span[0]
            v=.5+(c[axes[1]]-center[1])/span[1]
            o.data.uv_layers.active.data[li].uv=((col+.04+u*.92)/3,(1-row)*.5+.02+v*.46)
        return o

    def curved_timber(name,points,width=.40,depth=.32,mat='LodgeWood',variation=.12):
        pts=[Vector(p) for p in points];verts=[]
        cross=[(-.34,-.5),(.34,-.5),(.5,-.34),(.5,.34),(.34,.5),(-.34,.5),(-.5,.34),(-.5,-.34)]
        for i,p in enumerate(pts):
            t=(pts[min(i+1,len(pts)-1)]-pts[max(i-1,0)]).normalized()
            ref=Vector((0,0,1)) if abs(t.z)<.9 else Vector((1,0,0))
            side=ref.cross(t).normalized();thick=t.cross(side).normalized()
            swell=1+variation*math.sin(math.pi*i/(len(pts)-1))
            verts.extend(tuple(p+side*x*width*swell+thick*z*depth) for x,z in cross)
        faces=[tuple(range(7,-1,-1)),tuple((len(pts)-1)*8+j for j in range(8))]
        for i in range(len(pts)-1):
            for j in range(8):faces.append((i*8+j,i*8+(j+1)%8,(i+1)*8+(j+1)%8,(i+1)*8+j))
        o=mesh(name,verts,faces,mat,True)
        k=b['TILES'][mat];col=k%3;row=k//3
        for li,loop in enumerate(o.data.loops):
            vi=loop.vertex_index
            u=.28+.44*(vi%8)/7;v=.08+.84*(vi//8)/(len(pts)-1)
            o.data.uv_layers.active.data[li].uv=((col+.04+u*.92)/3,(1-row)*.5+.02+v*.46)
        return o

    def roof_y(x,z):
        t=min(abs(x)/3.15,1.0)
        # Steep upper gable, flattening and gently lifting at the outer eave.
        return 2.57+2.05*(1-t)**1.68+.055*t**10-.10*(1-(z/3.18)**2)

    # Lower, stout main mass and large irregular foundation blocks.
    box('Lodge interior closed mass',(4.48,2.08,5.40),(0,1.54,0),'LodgeMortar',.10)
    for row in range(2):
        y=.14+row*.29
        for side in [-1,1]:
            for j in range(6):
                x=-1.98+j*.79
                box('Large rounded foundation stone',(.80+rng.uniform(-.04,.04),.30,.48),(x,y,side*2.73),'LodgeStone',.085,r=(0,rng.uniform(-3,3),rng.uniform(-2,2)))
            for j in range(7):
                z=-2.38+j*.79
                box('Large side footing stone',(.48,.30,.80),(side*2.23,y,z),'LodgeStone',.085,r=(rng.uniform(-2,2),rng.uniform(-2,2),0))
    for side in [-1,1]:
        for row in range(5):
            y=.79+row*.38
            o=box('Broad front/back timber plank',(4.40,.38,.17),(0,y,side*2.76),'LodgeWood',.055,r=(0,0,rng.uniform(-.6,.6)))
            uv(o,'LodgeWood',(0,2),(0,0),(5.0,1.4))
            o=box('Broad side timber plank',(.17,.38,5.35),(side*2.24,y,0),'LodgeWood',.055,r=(rng.uniform(-.5,.5),0,0))
            uv(o,'LodgeWood',(1,2),(0,0),(6.0,1.4))
        # A few broad stone infills around the entrance and lower facade.
        for x in [-1.75,-.95,1.45,1.97]:
            for y in [.75,1.12]:box('Warm front infill stone',(.64,.35,.20),(x,y,side*2.84),'WallStone',.06)
    for x in [-2.23,2.23]:
        for z in [-2.74,2.74]:
            points=[(x+math.copysign(.075*math.sin(math.pi*i/8),x),.50+2.05*i/8,z+math.copysign(.035*math.sin(math.pi*i/8),z)) for i in range(9)]
            curved_timber('Bowed stout corner post',points,.43,.43,variation=.24)
            box('Large post foot joint',(.56,.24,.56),(x,.61,z),'LodgeWood',.065)
    for x in [-2.28,2.28]:
        for z in [-1.55,1.52]:
            points=[(x+.035*math.sin(math.pi*i/6),.54+1.95*i/6,z+.045*math.sin(math.pi*i/6)) for i in range(7)]
            curved_timber('Curved side structural post',points,.32,.32)
    for z in [-2.81,2.81]:
        curved_timber('Bowed facade header',[(x,2.51-.06*math.cos(x),z) for x in [-2.3,-1.5,-.7,0,.7,1.5,2.3]],.29,.29)
    for x in [-2.31,2.31]:
        curved_timber('Long side header',[(x,2.51-.05*math.cos(z),z) for z in [-2.8,-2,-1,0,1,2,2.8]],.28,.28)

    # Closed curved gable wall with broad horizontal boards clipped to its profile.
    gable=[(-2.25,2.52),(-2.25,roof_y(2.25,2.72)-.10)]
    gable += [(x,roof_y(x,2.72)-.10) for x in [-1.9,-1.5,-1.0,-.5,0,.5,1.0,1.5,1.9,2.25]]
    gable += [(2.25,2.52)]
    n=len(gable);verts=[(x,y,z) for z in [-2.72,2.72] for x,y in gable]
    faces=[tuple(range(n-1,-1,-1)),tuple(n+j for j in range(n))]+[(j,(j+1)%n,(j+1)%n+n,j+n) for j in range(n)]
    o=mesh('Closed curved gable infill',verts,faces,'LodgeWood')
    uv(o,'LodgeWood',(0,2),(0,3.4),(5.0,2.6))
    for z in [-2.77,2.77]:
        for row in range(5):
            y=2.73+row*.31
            x=3.15*(1-max(0,(y+.17-2.57)/2.05)**(1/1.68))
            o=box('Large gable timber course',(max(.30,x*2),.28,.13),(0,y,z),'LodgeWood',.045)
            uv(o,'LodgeWood',(0,2),(0,0),(5.0,1.5))

    # A closed roof shell follows the curved cross section rather than a flat box.
    nx=33;nz=9;verts=[]
    for underside in [False,True]:
        for ix in range(nx):
            x=-3.15+6.30*ix/(nx-1)
            for iz in range(nz):
                z=-3.18+6.36*iz/(nz-1)
                verts.append((x,roof_y(x,z)-(.17 if underside else 0),z))
    off=nx*nz;faces=[]
    for ix in range(nx-1):
        for iz in range(nz-1):
            a=ix*nz+iz;c=(ix+1)*nz+iz
            faces.extend([(a,a+1,c+1,c),(a+off,c+off,c+1+off,a+1+off)])
    for ix in range(nx-1):
        for iz in [0,nz-1]:
            a=ix*nz+iz;c=(ix+1)*nz+iz;faces.append((a,c,c+off,a+off))
    for ix in [0,nx-1]:
        for iz in range(nz-1):
            a=ix*nz+iz;faces.append((a,a+off,a+1+off,a+1))
    mesh('Closed swept curved roof shell',verts,faces,'DarkWood',True)
    for z in [-3.21,3.21]:
        for side in [-1,1]:
            points=[(side*3.19*i/16,roof_y(3.15*i/16,z)-.07,z) for i in range(17)]
            curved_timber('Curved massive bargeboard',points,.43,.36,variation=.07)
        for side in [-1,1]:
            curved_timber('Crossed ridge end timber',[(side*-.40,4.40,z),(0,4.75,z),(side*.39,5.10,z)],.36,.36)
        for x in [-2.94,-1.0,1.0,2.94]:
            y=roof_y(x,z)+.17
            box('Stout projecting roof joint',(.42,.45,.44),(x,y,z),'LodgeWood',.085,r=(0,0,-math.copysign(12,x)))
            sphere('Dark wooden joint peg',(.045,.045,.018),(x,y,z+math.copysign(.23,z)),'DarkWood',1)
    for x in [-3.10,3.10]:
        curved_timber('Sagged long eave timber',[(x,roof_y(x,z)-.06,z) for z in [-3.20,-2.4,-1.6,-.8,0,.8,1.6,2.4,3.20]],.38,.38)
        for z in [-2.3,2.3]:curved_timber('Stout eave knee brace',[(math.copysign(2.25,x),2.10,z),(math.copysign(2.62,x),2.38,z),(x,2.57,z)],.23,.23)

    # Large irregular rounded snow slabs, every vertex conforming to the curved roof.
    for side in [-1,1]:
        for row in range(4):
            for j in range(5):
                uc=(row+.5)/4;zc=-3.18+6.36*(j+.5)/5
                uw=.26+rng.uniform(.015,.045);zw=1.30+rng.uniform(-.05,.08)
                uc+=rng.uniform(-.015,.015);zc+=rng.uniform(-.065,.065)
                seg=24;verts=[]
                lobes=[rng.uniform(.93,1.06) for _ in range(6)]
                for rr,dy in [(.70,.17),(1.0,.11),(1.0,-.025),(.87,-.075)]:
                    for k in range(seg):
                        a=math.tau*k/seg
                        dx=math.copysign(abs(math.cos(a))**.55,math.cos(a))*uw*.5*rr
                        dz=math.copysign(abs(math.sin(a))**.55,math.sin(a))*zw*.5*rr
                        l=lobes[k//4]
                        u=min(1.027,max(-.02,uc+dx*l));z=max(-3.28,min(3.28,zc+dz*l))
                        x=side*u*3.15
                        y=roof_y(x,z)+.11+dy+.025*math.sin(a*3+j)
                        if row==3:y-=.04*max(0,math.sin(a*3))
                        verts.append((x,y,z))
                faces=[tuple(range(seg)),tuple(3*seg+k for k in range(seg-1,-1,-1))]
                for ring in range(3):
                    for k in range(seg):faces.append((ring*seg+k,ring*seg+(k+1)%seg,(ring+1)*seg+(k+1)%seg,(ring+1)*seg+k))
                o=mesh('Large irregular curved snow blanket',verts,faces,'Paint_Snow',True)
                uv(o,'Paint_Snow',(0,1),(0,0),(6.6,6.6))
    # Ridge blanket hides the join without making a thin straight snowy rod.
    for z in [-2.7,-1.6,-.5,.6,1.7,2.7]:
        sphere('Soft connected ridge snow',(.27,.15,.63),(0,roof_y(0,z)+.13,z),'Paint_Snow',2)

    # Chimney: shorter than the ridge ornaments, with open stone coping and snow.
    cx=1.55;cz=-1.55
    for row in range(7):
        y=3.05+row*.29
        for s in [-1,1]:box('Chunky chimney masonry',(.44,.28,.78),(cx+s*.21,y,cz),'LodgeStone',.06)
    box('Open chimney dark throat',(.64,.025,.64),(cx,5.04,cz),'DarkWood',.008)
    for s in [-1,1]:
        box('Thick open chimney coping',(.23,.24,1.06),(cx+s*.42,5.04,cz),'LodgeStone',.07)
        box('Snow on coping strip',(.25,.065,1.08),(cx+s*.42,5.19,cz),'Paint_Snow',.025)
    for s in [-1,1]:
        box('Thick cross coping',(.65,.24,.23),(cx,5.04,cz+s*.42),'LodgeStone',.06)
        box('Snow on coping cross',(.67,.065,.25),(cx,5.19,cz+s*.42),'Paint_Snow',.025)

    # Closed arch door and thick individual stone voussoirs.
    dx=.50;z=2.91
    outline=[(dx-.51,.50),(dx+.51,.50),(dx+.51,1.52)]
    outline += [(dx+math.cos(a)*.51,1.52+math.sin(a)*.51) for a in [math.pi*k/12 for k in range(1,13)]]
    n=len(outline);verts=[(x,y,zz) for zz in [z-.10,z+.04] for x,y in outline]
    faces=[tuple(range(n-1,-1,-1)),tuple(n+k for k in range(n))]+[(k,(k+1)%n,(k+1)%n+n,k+n) for k in range(n)]
    o=mesh('Closed squat arched door',verts,faces,'LodgeWood',False,.025)
    uv(o,'LodgeWood',(0,2),(dx,1.22),(1.25,1.75))
    for s in [-1,1]:
        for row in range(3):box('Large door jamb stone',(.28,.35,.31),(dx+s*.64,.69+row*.35,z+.02),'LodgeStone',.065)
    for k in range(7):
        a=math.pi*k/6
        box('Broad rounded arch voussoir',(.33,.28,.33),(dx+math.cos(a)*.64,1.52+math.sin(a)*.64,z+.02),'LodgeStone',.065,r=(0,0,math.degrees(a)-90))
    for x in [-.26,0,.26]:
        upper=1.52+math.sqrt(.51**2-x**2)
        beam('Sparse door plank joint',(dx+x,.56,z+.055),(dx+x,upper-.05,z+.055),.013,.014,'DarkWood')
    sphere('Door ring backing',(.065,.065,.02),(dx+.28,1.18,z+.07),'Iron',2)
    lathe('Door handle ring',[(0,.05),(.018,.05)],(dx+.28,1.18,z+.09),'Gold',12,r=(90,0,0))
    for width,y,zz in [(1.87,.09,3.76),(1.72,.27,3.45),(1.54,.45,3.14)]:
        box('Stout imperfect entrance step',(width,.21,.50),(dx,y,zz),'LodgeStone',.07,r=(0,rng.uniform(-1.8,1.8),0))

    def window(p,yaw,w,h):
        R=Matrix.Rotation(math.radians(yaw),3,'Y')
        def at(q):return Vector(p)+R@Vector(q)
        box('Inset warm window glass',(w,h,.08),at((0,0,.055)),'WarmWindow',.04,r=(0,yaw,0))
        for x in [-w/2-.08,w/2+.08]:box('Massive window upright',(.16,h+.24,.19),at((x,0,.08)),'LodgeWood',.045,r=(0,yaw,0))
        for y in [-h/2-.10,h/2+.10]:box('Stone window lintel sill',(w+.36,.19,.29),at((0,y,.10)),'LodgeStone',.06,r=(0,yaw,0))
        box('Large vertical window mullion',(.07,h,.12),at((0,0,.14)),'LodgeWood',.022,r=(0,yaw,0))
        box('Large horizontal window mullion',(w,.07,.12),at((0,0,.14)),'LodgeWood',.022,r=(0,yaw,0))
    window((-1.31,1.52,2.87),0,.72,.75)
    window((0,3.26,2.80),0,.43,.45)
    window((2.35,1.52,.28),90,1.01,.81)
    window((0,1.65,-2.83),180,.66,.62)
    window((-2.35,1.52,0),-90,.65,.68)
    # Attached lantern stays legible and uses existing warm-light wrappers.
    box('Lantern bracket',(.08,.27,.27),(-.37,1.83,2.98),'Iron',.025)
    box('Amber attached wall lantern',(.23,.32,.23),(-.37,1.62,3.08),'WarmWindow',.035)
    for y in [1.43,1.81]:box('Stout lantern metal cap',(.31,.065,.31),(-.37,y,3.08),'Iron',.025)
    for x in [-.13,.13]:beam('Lantern metal upright',(-.37+x,1.46,3.22),(-.37+x,1.78,3.22),.035,.035,'Iron')
    export('starter_lodge',before)
