"""Actual Blender orthographic elevations of the redesigned source mesh."""
import bpy, json
from pathlib import Path
from mathutils import Vector

root=Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(root/'art_sources/painted_assets.blend'))
scene=bpy.context.scene
for col in bpy.data.collections:
    for o in col.objects:
        o.hide_set(col.name!='starter_lodge')
        o.hide_render=col.name!='starter_lodge'
for o in list(bpy.data.objects):
    if o.type in ['LIGHT','CAMERA']:bpy.data.objects.remove(o,do_unlink=True)
def gv(p):return Vector((p[0],-p[2],p[1]))
world=bpy.data.worlds.new('Neutral modeling studio')
world.use_nodes=True
world.node_tree.nodes['Background'].inputs[0].default_value=(.50,.50,.55,1)
world.node_tree.nodes['Background'].inputs[1].default_value=.7
scene.world=world
for i,(pos,energy,size) in enumerate([((5,8,8),1500,7),((-5,6,1),1000,7),((0,8,-8),1200,8)]):
    data=bpy.data.lights.new('Studio area '+str(i),'AREA');data.energy=energy;data.shape='DISK';data.size=size
    o=bpy.data.objects.new(data.name,data);scene.collection.objects.link(o)
    o.location=gv(pos);o.rotation_euler=(gv((0,2,0))-o.location).to_track_quat('-Z','Y').to_euler()
data=bpy.data.cameras.new('Orthographic elevation');data.type='ORTHO';data.ortho_scale=7.25
cam=bpy.data.objects.new('Orthographic elevation',data);scene.collection.objects.link(cam);scene.camera=cam
scene.render.engine='BLENDER_EEVEE_NEXT'
scene.render.resolution_x=1000;scene.render.resolution_y=1000;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG';scene.render.film_transparent=False
scene.view_settings.view_transform='Standard';scene.view_settings.look='None';scene.view_settings.exposure=0;scene.view_settings.gamma=1
out=root/'screenshots'/'lodge-redesign';out.mkdir(parents=True,exist_ok=True)
for name,pos in [('front',(0,2.75,18)),('right',(18,2.75,0)),('back',(0,2.75,-18))]:
    cam.location=gv(pos);cam.rotation_euler=(gv((0,2.75,0))-cam.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=str(out/('v24-blender-'+name+'.png'))
    bpy.ops.render.render(write_still=True)
report=[]
for o in bpy.data.collections['starter_lodge'].objects:
    if o.type!='MESH':continue
    import bmesh
    bm=bmesh.new();bm.from_mesh(o.data)
    report.append(dict(name=o.name,vertices=len(bm.verts),polygons=len(bm.faces),non_manifold_edges=sum(not e.is_manifold for e in bm.edges)))
    bm.free()
(root/'art_sources/lodge-topology-v24.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('ORTHOGRAPHIC_VIEWS_SAVED',out,'meshes',len(report),'non_manifold_edges',sum(r['non_manifold_edges'] for r in report))
