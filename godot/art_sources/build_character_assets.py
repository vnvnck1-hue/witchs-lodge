"""Rounded winter guests, leaf-coated forest enemy and articulated dragon.
Uses the environment builder's material/export rules and keeps animated parts
as separate volumetric GLBs. Does not alter combat or economy contracts.
"""
import bpy, math, random, runpy, json
from pathlib import Path
from mathutils import Vector
b=runpy.run_path(str(Path(__file__).with_name('build_painted_assets.py')))
material,box,sphere,mesh,lathe,beam,begin,export,gv,rot=[b[k] for k in ['material','box','sphere','mesh','lathe','beam','begin','export','gv','rot']]
random.seed(314015)
for name,color in {
    'WinterCoat':(.18,.29,.23),'WinterHood':(.15,.24,.19),'FurTrim':(.72,.61,.45),
    'PackLeather':(.27,.15,.085),'BootLeather':(.12,.09,.08),'FaceInk':(.035,.024,.04),
    'ForestHide':(.13,.085,.20),'ForestLeaf':(.18,.12,.25),'ForestLeafLight':(.23,.16,.29),
    'ForestHorn':(.26,.16,.19),'DragonHide':(.48,.095,.065),'DragonScaleA':(.53,.105,.070),
    'DragonScaleB':(.43,.072,.058),'DragonScaleC':(.59,.14,.085),'DragonDark':(.28,.052,.047),
    'DragonBelly':(.76,.41,.105),'DragonHorn':(.83,.66,.42),'WingLeather':(.39,.105,.08)
}.items():material(name,None,color)
material('MonsterEye_Glow',None,(.70,1,.02),2.0)
material('DragonEye_Glow',None,(1,.35,.015),2.0)
material('DragonMouth_Glow',None,(1,.23,.015),1.8)

atlas_path=b['OUT']/'character_atlas.png'
if atlas_path.exists():
    atlas=bpy.data.images.load(str(atlas_path));atlas.pack()
    cells={'DragonHide':0,'DragonScaleA':0,'DragonScaleB':0,'DragonScaleC':0,'WingLeather':1,'ForestLeaf':2,'ForestLeafLight':2,'DragonBelly':3,'PackLeather':3}
    for name in cells:
        mat=b['MATS'][name];shader=mat.node_tree.nodes.get('Principled BSDF')
        tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=atlas
        mat.node_tree.links.new(tex.outputs['Color'],shader.inputs['Base Color'])
    original_finish=b['finish']
    def textured_finish(o,mat,bevel=0,smooth=False):
        o=original_finish(o,mat,bevel,smooth)
        if mat in cells:
            k=cells[mat];col=k%2;row=k//2
            if mat=='WingLeather':
                for li,loop in enumerate(o.data.loops):
                    c=o.data.vertices[loop.vertex_index].co
                    o.data.uv_layers.active.data[li].uv=(c.x/5.6,c.y/3.6)
            for uv in o.data.uv_layers.active.data:
                u,v=uv.uv
                if mat in ['DragonScaleA','DragonScaleB','DragonScaleC']:u=.20+u*.40;v=.20+v*.40
                uv.uv=((col+.04+u*.92)/2,(1-row)*.5+.02+v*.46)
        return o
    b['mesh'].__globals__['finish']=textured_finish

def tube(name,points,radii,mat,seg=10):
    verts=[]
    for i,(p,r) in enumerate(zip(points,radii)):
        p=Vector(p)
        tangent=Vector(points[min(i+1,len(points)-1)])-Vector(points[max(i-1,0)])
        tangent.normalize()
        guide=Vector((0,0,1)) if abs(tangent.z)<.85 else Vector((0,1,0))
        axis=tangent.cross(guide).normalized();other=tangent.cross(axis).normalized()
        for j in range(seg):
            a=math.tau*j/seg;verts.append(p+r*(axis*math.cos(a)+other*math.sin(a)))
    faces=[tuple(range(seg-1,-1,-1)),tuple((len(points)-1)*seg+j for j in range(seg))]
    for i in range(len(points)-1):
        for j in range(seg):faces.append((i*seg+j,i*seg+(j+1)%seg,(i+1)*seg+(j+1)%seg,(i+1)*seg+j))
    return mesh(name,verts,faces,mat,True)

def leaf(p,w,h,yaw,mat):
    v=[(0,h,0),(-w*.52,h*.42,.10),(0,0,.16),(w*.52,h*.42,.10),(0,h*.48,.20),(0,h*.50,-.03)]
    faces=[(4,i,(i+1)%4) for i in range(4)]+[(5,(i+1)%4,i) for i in range(4)]
    o=mesh('Folded forest leaf',v,faces,mat,True)
    o.location=gv(p);rot(o,(0,yaw,0));return o

before=begin()
for x in [-.09,.09]:sphere('Guest boot',(.08,.06,.12),(x,.06,.03),'BootLeather',2)
lathe('Winter coat with broad folds',[(.10,.24),(.19,.27),(.43,.17),(.55,.16)],(0,0,0),'WinterCoat',16,smooth=True)
lathe('Warm fur hem',[(0,.24),(.055,.25)],(0,.10,0),'FurTrim',16,smooth=True)
sphere('Rounded hood',(.235,.23,.205),(0,.76,-.035),'WinterHood',3)
sphere('Guest face',(.175,.18,.12),(0,.745,.11),'Skin',3)
for x in [-.055,.055]:sphere('Guest eye',(.015,.022,.010),(x,.765,.226),'FaceInk',2)
sphere('Guest nose',(.024,.023,.018),(0,.715,.235),'Skin',2)
bpy.ops.mesh.primitive_torus_add(major_segments=20,minor_segments=6,major_radius=.192,minor_radius=.029,location=gv((0,.76,.08)))
o=bpy.context.object;o.name='Soft fur hood opening';rot(o,(90,0,0));b['finish'](o,'FurTrim',smooth=True)
box('Beveled leather backpack',(.38,.42,.22),(0,.43,-.255),'PackLeather',.07)
box('Backpack flap',(.41,.12,.25),(0,.60,-.255),'PackLeather',.045)
for x in [-.12,.12]:beam('Backpack shoulder strap',(x,.55,.12),(x,.25,.14),.035,.025,'PackLeather')
lathe('Rolled travel blanket',[(0,.09),(.39,.09)],(-.195,.69,-.255),'FurTrim',12,r=(0,0,-90),smooth=True)
lathe('Walking staff',[(0,.024),(1.0,.020)],(.29,0,.10),'Paint_Wood',10)
for x in [-.23,.23]:sphere('Guest mitten',(.065,.075,.065),(x,.38,.075),'WinterCoat',2)
export('winter_traveler',before)

before=begin()
for x in [-.13,.13]:
    tube('Short forest leg',[(x,.04,.06),(x,.26,-.01),(x,.42,-.04)],[.085,.075,.10],'ForestHide',8)
    sphere('Rounded forest foot',(.095,.065,.13),(x,.065,.11),'ForestHide',2)
sphere('Small round forest body',(.31,.34,.27),(0,.57,-.04),'ForestHide',3)
for row in range(3):
    for j in range(8):
        a=math.tau*j/8+row*.30
        leaf((math.sin(a)*.21,.22+row*.19,math.cos(a)*.21),.25,.38,math.degrees(a),['ForestLeaf','ForestLeafLight'][j%2])
sphere('Forest creature head',(.24,.22,.23),(0,.88,.14),'ForestHide',3)
for s in [-1,1]:
    tube('Branchlike curled horn',[(s*.15,1.01,.08),(s*.25,1.18,-.02),(s*.23,1.24,-.16)],[.065,.046,.015],'ForestHorn',8)
    sphere('Yellow green forest eye',(.044,.046,.028),(s*.086,.90,.348),'MonsterEye_Glow',2)
    tube('Short curved forest arm',[(s*.27,.73,.01),(s*.38,.48,.06),(s*.37,.34,.12)],[.078,.067,.055],'ForestHide',8)
    sphere('Forest mitten claw',(.079,.067,.075),(s*.37,.32,.13),'ForestHide',2)
leaf((0,.65,.25),.21,.24,0,'ForestLeaf')
export('forest_monster',before)

before=begin()
sphere('Dragon powerful torso',(1.20,1.10,2.02),(0,1.18,-.30),'DragonHide',3)
sphere('Warm plated underside',(.93,.80,1.62),(0,.88,.20),'DragonBelly',3)
for row in range(7):
    z=-1.9+row*.48
    for j in range(7):
        a=-1.25+j*2.5/6
        x=math.sin(a)*1.12;y=1.18+math.cos(a)*1.05
        o=sphere('Broad hand-painted dorsal scale',(.24,.12,.30),(x,y,z),['DragonScaleA','DragonScaleB','DragonScaleC'][(j+row)%3],2)
        rot(o,(0,0,-math.degrees(a)))
for s in [-1,1]:
    for z in [.80,-1.15]:
        tube('Gripping bent dragon leg',[(s*.75,.86,z),(s*1.05,.24,z+.04),(s*1.16,-.40,z+.20)],[.34,.29,.19],'DragonHide',10)
        sphere('Dragon foot pad',(.30,.16,.39),(s*1.16,-.44,z+.28),'DragonDark',2)
        for dx in [-.15,0,.15]:tube('Curved ivory talon',[(s*1.16+dx,-.43,z+.52),(s*1.16+dx,-.53,z+.72),(s*1.16+dx,-.57,z+.81)],[.065,.038,.008],'DragonHorn',8)
tube('Curled volumetric dragon tail',[(0,.9,-2.0),(-.5,.7,-2.8),(-1.5,.36,-3.45),(-2.6,-.05,-3.20),(-2.8,-.27,-2.15),(-2.0,-.3,-1.25)],[.48,.43,.33,.22,.115,.025],'DragonHide',12)
for i in range(6):
    z=.8-i*.53
    tube('Swept dorsal spine',[(0,2.12,z),(0,2.63,z-.16),(0,2.79,z-.29)],[.18,.10,.01],'DragonDark',8)
export('dragon_body',before)

before=begin()
tube('Curved sculpted dragon neck',[(0,0,0),(0,.65,-.06),(0,1.45,.02),(0,2.42,.04)],[.62,.58,.46,.37],'DragonHide',14)
for i in range(7):box('Broad golden throat plate',(.70-i*.035,.25,.15),(0,.27+i*.29,.43-i*.01),'DragonBelly',.07)
for i in range(4):tube('Small neck crest',[(0,.4+i*.5,-.45),(0,.66+i*.5,-.66),(0,.75+i*.5,-.78)],[.11,.06,.01],'DragonDark',8)
export('dragon_neck',before)

before=begin()
sphere('Sculpted dragon skull',(.50,.43,.59),(0,.13,.10),'DragonHide',3)
box('Rounded long muzzle',(.79,.40,1.0),(0,-.025,.80),'DragonHide',.13)
box('Open dark mouth',(.63,.20,.94),(0,-.24,.94),'DragonDark',.07)
box('Rounded lower jaw',(.73,.18,1.07),(0,-.38,.87),'DragonHide',.07)
box('Warm mouth interior',(.49,.10,.59),(0,-.24,1.11),'DragonMouth_Glow',.04)
for s in [-1,1]:
    tube('Curled broad ivory horn',[(s*.32,.43,-.15),(s*.50,.88,-.39),(s*.47,1.10,-.68),(s*.34,1.16,-.91)],[.14,.12,.075,.012],'DragonHorn',10)
    sphere('Fiery almond dragon eye',(.065,.063,.105),(s*.415,.22,.55),'DragonEye_Glow',3)
    box('Strong dragon brow',(.16,.11,.43),(s*.415,.35,.48),'DragonDark',.04,r=(0,0,s*12))
    for z in [.72,1.10]:lathe('Ivory dragon fang',[(0,.05),(.18,0)],(s*.275,-.13,z),'DragonHorn',8,r=(0,0,180))
    sphere('Dragon nostril',(.045,.035,.06),(s*.23,.15,1.25),'DragonDark',2)
    tube('Swept jaw frill',[(s*.38,.05,-.13),(s*.67,.14,-.51),(s*.78,.15,-.71)],[.11,.075,.01],'DragonHide',8)
export('dragon_head',before)

before=begin()
outline=[(0,0,0),(2.7,.35,.0),(5.3,.05,-.65),(4.35,-.3,-2.95),(3.8,-.45,-3.35),(3.14,-.25,-2.45),(2.10,-.50,-3.15),(1.50,-.31,-2.15),(.50,-.55,-2.05),(0,-.45,-.65)]
verts=outline+[(x,y-.07,z) for x,y,z in outline]+[(2.45,.04,-1.40),(2.45,-.03,-1.40)]
n=len(outline)
faces=[]
for j in range(n):
    faces.extend([(2*n,j,(j+1)%n),(2*n+1,n+(j+1)%n,n+j),(j,n+j,n+(j+1)%n,(j+1)%n)])
mesh('Curved scalloped wing membrane',verts,faces,'WingLeather',True)
tube('Bent leading wing bone',[(0,0,0),(2.7,.35,0),(5.3,.05,-.65)],[.19,.13,.04],'DragonHide',12)
for end in [(4.35,-.3,-2.95),(2.10,-.5,-3.15),(.50,-.55,-2.05)]:
    mid=Vector((2.7,.35,0)).lerp(Vector(end),.5);mid.y+=.04
    tube('Curved membrane finger',[(2.7,.35,0),mid,end],[.08,.065,.026],'DragonHide',10)
tube('Hooked wing claw',[(5.3,.05,-.65),(5.55,-.05,-.80),(5.56,-.22,-.87)],[.055,.041,.008],'DragonHorn',8)
export('dragon_wing',before)

for collection in bpy.data.collections:
    for o in collection.objects:o.hide_set(collection.name!='starter_lodge')
bpy.ops.wm.save_as_mainfile(filepath=str(b['ROOT']/'art_sources/painted_assets.blend'))
(b['ROOT']/'art_sources/asset_evidence.json').write_text(json.dumps(b['EVIDENCE'],indent=2))
print('CHARACTER_ASSETS_BUILT',json.dumps(b['EVIDENCE'][-6:]))
