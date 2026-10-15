"""Author editable wildlife and export meter-scale, +Z-forward glTF.
Run with Blender --background --python this_file. No external art dependencies.
Godot coordinates are used in all authoring helpers (converted to Blender Z-up).
"""
import bpy, bmesh, math, random, json
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/nature'
REVIEW = ROOT.parent / 'output/jobs-update-v01'
OUT.mkdir(parents=True, exist_ok=True)
REVIEW.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
random.seed(151026)

def gv(p): return Vector((p[0], -p[2], p[1]))
def linear(h):
    a=[int(h[i:i+2],16)/255 for i in (0,2,4)]
    return tuple(v/12.92 if v <= .04045 else ((v+.055)/1.055)**2.4 for v in a)

COLORS={k:linear(h) for k,h in dict(
    rabbit='8E8175',rabbit_light='A99C8B',cream='E1D9C5',pink='BA928C',
    deer='A56E4A',deer_dark='77523E',deer_light='BA855A',ivory='DBCEAC',
    black='282A32',hoof='463B38').items()}
MAT=bpy.data.materials.new('Wildlife_vertex_palette')
MAT.use_nodes=True
p=MAT.node_tree.nodes.get('Principled BSDF')
p.inputs['Roughness'].default_value=1
p.inputs['Specular IOR Level'].default_value=0
c=MAT.node_tree.nodes.new('ShaderNodeVertexColor'); c.layer_name='Col'
MAT.node_tree.links.new(c.outputs['Color'],p.inputs['Base Color'])

def attach(o,parent):
    bpy.context.view_layer.update()
    m=o.matrix_world.copy();o.parent=parent;o.matrix_world=m
    return o

def empty(name,p=(0,0,0),parent=None):
    o=bpy.data.objects.new(name,None);COL.objects.link(o);o.location=gv(p)
    if parent: attach(o,parent)
    o.empty_display_size=.12
    return o

def finish(o,name,color,parent):
    o.name=name
    for collection in list(o.users_collection): collection.objects.unlink(o)
    COL.objects.link(o)
    bpy.context.view_layer.objects.active=o
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    m=o.data
    bm=bmesh.new();bm.from_mesh(m)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(m);bm.free()
    m.materials.append(MAT)
    attr=m.color_attributes.new(name='Col',type='FLOAT_COLOR',domain='CORNER')
    for face in m.polygons:
        face.use_smooth=False
        gain=1+random.uniform(-.025,.025)
        for i in face.loop_indices: attr.data[i].color=(*(v*gain for v in COLORS[color]),1)
    attach(o,parent)
    return o

def ell(name,p,s,color,parent,segments=12,rings=8):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments,ring_count=rings,radius=1,location=gv(p))
    o=bpy.context.object;o.scale=(s[0],s[2],s[1])
    return finish(o,name,color,parent)

def tube(name,points,radii,color,parent,sides=8):
    points=[Vector(p) for p in points];verts=[];faces=[]
    for j,p in enumerate(points):
        tangent=(points[min(j+1,len(points)-1)]-points[max(0,j-1)]).normalized()
        ref=Vector((0,1,0)) if abs(tangent.y)<.95 else Vector((1,0,0))
        a=tangent.cross(ref).normalized();b=tangent.cross(a).normalized()
        for i in range(sides):
            t=math.tau*i/sides
            verts.append(gv(p+(a*math.cos(t)+b*math.sin(t))*radii[j]))
    for j in range(len(points)-1):
        for i in range(sides):
            a=j*sides+i;b=j*sides+(i+1)%sides
            faces.append((a,b,b+sides,a+sides))
    faces.extend([tuple(range(sides-1,-1,-1)),tuple((len(points)-1)*sides+i for i in range(sides))])
    m=bpy.data.meshes.new(name);m.from_pydata(verts,[],faces);m.update()
    o=bpy.data.objects.new(name,m);COL.objects.link(o)
    return finish(o,name,color,parent)

def ear(name,base,tip,width,depth,color,parent):
    # Closed broad lance volume with a folded center, not a paper triangle.
    a=Vector(base);b=Vector(tip);mid=a.lerp(b,.53)
    vs=[a,mid+Vector((-width,0,0)),b,mid+Vector((width,0,0)),
        mid+Vector((0,0,depth)),mid-Vector((0,0,depth*.65))]
    fs=[(0,1,4),(1,2,4),(2,3,4),(3,0,4),(0,5,1),(1,5,2),(2,5,3),(3,5,0)]
    m=bpy.data.meshes.new(name);m.from_pydata([gv(v) for v in vs],[],fs);m.update()
    o=bpy.data.objects.new(name,m);COL.objects.link(o)
    return finish(o,name,color,parent)

ASSETS=[]
for kind in ['rabbit','deer']:
    COL=bpy.data.collections.new(kind);bpy.context.scene.collection.children.link(COL)
    root=empty(kind.title());body=empty('Body',parent=root)
    if kind=='rabbit':
        head=empty('Head',(0,.17,.115),body)
        ell('Rounded torso',(0,.135,-.035),(.105,.105,.168),'rabbit',body)
        ell('White belly',(0,.09,-.015),(.083,.063,.135),'cream',body)
        for side in [-1,1]:
            ell('Powerful haunch',(side*.073,.10,-.115),(.065,.085,.083),'rabbit_light',body)
            ell('Hind paw',(side*.077,.026,-.075),(.041,.026,.082),'rabbit_light',body)
            ell('Front leg',(side*.054,.065,.095),(.025,.058,.026),'rabbit',body)
            ell('Front paw',(side*.054,.019,.122),(.029,.019,.045),'cream',body)
        ell('Cotton tail',(0,.14,-.198),(.036,.036,.027),'cream',body)
        ell('Head volume',(0,.199,.141),(.067,.062,.069),'rabbit_light',head)
        ell('Muzzle',(0,.18,.198),(.043,.032,.027),'cream',head)
        ell('Nose',(0,.194,.222),(.014,.010,.008),'pink',head,8,6)
        for side in [-1,1]:
            ear('Long ear',(side*.031,.235,.12),(side*.057,.35,.094),.021,.012,'rabbit',head)
            ear('Inner ear',(side*.032,.25,.13),(side*.055,.335,.109),.011,.003,'pink',head)
            ell('Dark eye',(side*.057,.216,.169),(.010,.013,.012),'black',head,8,6)
            ell('Eye glint',(side*.063,.221,.175),(.003,.004,.003),'cream',head,6,4)
    else:
        head=empty('Head',(0,1.03,.39),body)
        ell('Torso',(0,.83,-.12),(.235,.27,.59),'deer',body)
        ell('White belly',(0,.675,-.11),(.185,.13,.46),'cream',body)
        ell('Shoulders',(0,.86,.28),(.215,.24,.23),'deer_light',body)
        ell('Rump',(0,.84,-.48),(.24,.24,.24),'deer',body)
        tube('Neck',[(0,.83,.29),(0,1.04,.43),(0,1.18,.52)],[.18,.14,.105],'deer',head)
        ell('Throat bib',(0,.995,.48),(.09,.185,.07),'cream',head)
        ell('Head volume',(0,1.23,.56),(.125,.13,.155),'deer_light',head)
        ell('Long muzzle',(0,1.183,.70),(.087,.075,.105),'deer',head)
        ell('Dark nose',(0,1.18,.792),(.066,.047,.028),'black',head)
        ell('White tail',(0,.91,-.72),(.064,.112,.06),'cream',body)
        for side in [-1,1]:
            x=side*.158
            tube('Foreleg',[(x,.88,.29),(x,.43,.32),(x,.10,.35)],[.075,.043,.031],'deer',body)
            tube('Hind leg',[(x,.87,-.49),(x,.49,-.38),(x,.28,-.54),(x,.09,-.50)],[.11,.058,.039,.03],'deer_dark',body)
            for z in [.355,-.505]:
                ell('Hoof',(x,.045,z),(.047,.045,.071),'hoof',body,8,6)
            ell('Dark eye',(side*.111,1.254,.623),(.017,.022,.022),'black',head,8,6)
            ell('Eye glint',(side*.124,1.262,.634),(.004,.006,.005),'cream',head,6,4)
            ear('Broad ear',(side*.08,1.30,.52),(side*.30,1.37,.48),.057,.029,'deer',head)
            ear('Ear pale inset',(side*.12,1.319,.545),(side*.28,1.366,.506),.029,.008,'cream',head)
            pts=[(side*.073,1.33,.52),(side*.13,1.44,.48),(side*.23,1.53,.40),(side*.29,1.594,.32)]
            tube('Ivory antler beam',pts,[.026,.021,.016,.006],'ivory',head,7)
            tube('Antler front tine',[pts[1],(side*.125,1.54,.57)],[.016,.004],'ivory',head,7)
            tube('Antler upper tine',[pts[2],(side*.31,1.59,.47)],[.012,.004],'ivory',head,7)
    # Preserve names Body and Head in separate files, allowing both in one .blend.
    body.name='Body' if kind=='rabbit' else 'Body_deer'
    head.name='Head' if kind=='rabbit' else 'Head_deer'
    bpy.context.view_layer.update()
    meshes=[o for o in COL.objects if o.type=='MESH']
    # Normalize total nose-to-tail length and highest point while retaining foot plane.
    coords=[o.matrix_world @ v.co for o in meshes for v in o.data.vertices]
    ylo=min(v.y for v in coords);yhi=max(v.y for v in coords)
    zhi=max(v.z for v in coords)
    length=.45 if kind=='rabbit' else 1.5
    height=.35 if kind=='rabbit' else 1.6
    # Geometry only; root transform stays identity. Center footprint along front axis.
    for o in list(COL.objects):
        if o.type!='MESH':continue
        inv=o.matrix_world.inverted()
        for v in o.data.vertices:
            p=o.matrix_world @ v.co
            p.y=(p.y-(ylo+yhi)/2)*length/(yhi-ylo)
            p.z*=height/zhi
            v.co=inv @ p
    bpy.context.view_layer.update()
    # Two draw meshes per animal; preserve Body/Head pivots and vertex palettes.
    for pivot,suffix in [(body,'body_mesh'),(head,'head_mesh')]:
        group=[o for o in COL.objects if o.type=='MESH' and o.parent==pivot]
        bpy.ops.object.select_all(action='DESELECT')
        for o in group:o.select_set(True)
        bpy.context.view_layer.objects.active=group[0]
        bpy.ops.object.join()
        bpy.context.object.name=kind+'_'+suffix
    meshes=[o for o in COL.objects if o.type=='MESH']
    bad=0;degenerate=0;tris=0
    for o in meshes:
        bm=bmesh.new();bm.from_mesh(o.data)
        bad+=sum(not e.is_manifold for e in bm.edges)
        degenerate+=sum(f.calc_area()<1e-12 for f in bm.faces)
        bm.free();o.data.calc_loop_triangles();tris+=len(o.data.loop_triangles)
    assert bad==0 and degenerate==0,(kind,bad,degenerate)
    # Export names through temporary renames (Blender global names must be unique).
    old_body=body.name;old_head=head.name
    conflicts=[]
    for desired,obj in [('Body',body),('Head',head)]:
        other=bpy.data.objects.get(desired)
        if other and other!=obj:conflicts.append((other,other.name));other.name=desired+'_stored'
        obj.name=desired
    bpy.ops.object.select_all(action='DESELECT')
    # The Godot scene importer adds the asset root itself; export Body directly.
    # Avoid an extra Rabbit/Deer level that would break get_node("Body/Head").
    body.parent=None
    for o in COL.objects:
        if o != root:o.select_set(True)
    bpy.context.view_layer.objects.active=body
    bpy.ops.export_scene.gltf(filepath=str(OUT/(kind+'.glb')),export_format='GLB',use_selection=True,
        export_yup=True,export_apply=True,export_extras=True,export_animations=False,
        export_materials='EXPORT',export_attributes=True)
    attach(body,root)
    body.name=old_body;head.name=old_head
    for obj,name in conflicts:obj.name=name
    coords=[o.matrix_world @ v.co for o in meshes for v in o.data.vertices]
    lo=[min(v[i] for v in coords) for i in range(3)]
    hi=[max(v[i] for v in coords) for i in range(3)]
    ASSETS.append(dict(id=kind,triangles=tris,mesh_count=len(meshes),non_manifold_edges=bad,
        degenerate_faces=degenerate,size_godot=[hi[0]-lo[0],hi[2]-lo[2],hi[1]-lo[1]],
        bounds_godot_min=[lo[0],lo[2],-hi[1]],bounds_godot_max=[hi[0],hi[2],-lo[1]],
        front='+Z',up='+Y',unit='meter',nodes=['Body','Body/Head'],textures=0))
    root['wildlife_id']=kind
    # Offset source collections for convenient side-by-side editing after export.
    if kind=='deer':root.location.x=1.5

(REVIEW/'wildlife-blender-verification.json').write_text(json.dumps(ASSETS,indent=2),encoding='utf8')
bpy.context.scene.unit_settings.system='METRIC'
bpy.context.scene.unit_settings.scale_length=1
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art_sources/wildlife.blend'))

# Reproducible actual geometry previews, not concept images.
scene=bpy.context.scene
scene.render.engine='CYCLES';scene.cycles.samples=24
scene.render.resolution_x=1000;scene.render.resolution_y=850;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG';scene.render.film_transparent=True
scene.world.color=(.22,.22,.22)
scene.view_settings.view_transform='Standard'
for name,loc,power,size in [('Key',(3,-4,6),650,4),('Fill',(-4,-2,3),450,5),('Rim',(1,3,5),650,3)]:
    data=bpy.data.lights.new(name,'AREA');data.energy=power;data.shape='DISK';data.size=size
    obj=bpy.data.objects.new(name,data);scene.collection.objects.link(obj);obj.location=loc
    obj.rotation_euler=(Vector((.6,0,.7))-obj.location).to_track_quat('-Z','Y').to_euler()
camera_data=bpy.data.cameras.new('Review camera');camera=bpy.data.objects.new('Review camera',camera_data)
scene.collection.objects.link(camera);scene.camera=camera;camera_data.type='ORTHO'
for asset in ASSETS:
    for name in ['rabbit','deer']:bpy.data.collections[name].hide_render=name!=asset['id']
    center=Vector((0,0,.17)) if asset['id']=='rabbit' else Vector((1.5,0,.79))
    distance=.8 if asset['id']=='rabbit' else 3
    camera_data.ortho_scale=.70 if asset['id']=='rabbit' else 2.65
    for view,offset in [('front',(1,-1.7,.75)),('side',(2,.08,.45)),('rear',(-1,1.7,.8))]:
        camera.location=center+Vector(offset)*distance
        camera.rotation_euler=(center-camera.location).to_track_quat('-Z','Y').to_euler()
        scene.render.filepath=str(REVIEW/(asset['id']+'-'+view+'.png'))
        bpy.ops.render.render(write_still=True)
print('WILDLIFE_COMPLETE',json.dumps(ASSETS))
