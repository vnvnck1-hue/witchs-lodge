"""Path-led forest art direction: authored islands, hierarchical motifs and clear lanes.
JSON is the editable placement source; deterministic small variation stays inside each motif.
No map-wide random grid/scatter. All positions, orientations and scales are delivered explicitly.
"""
from pathlib import Path
import math,random,json,re,collections
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/environment';OUT.mkdir(parents=True,exist_ok=True)
REVIEW=ROOT.parent/'output/forest-composition'
CAT={e['id']:e for e in json.loads((ROOT/'assets/nature/catalog.json').read_text(encoding='utf-8'))['assets']}
source=(ROOT/'scripts/world/layout.gd').read_text(encoding='utf-8')
paths=[]
for name in ['PATH_A','PATH_B','PATH_WEST','PATH_NORTH','PATH_SOUTH','PATH_HOME']:
    text=re.search(r'const '+name+r' := \[(.*?)\]',source,re.S).group(1)
    paths.append([[float(x),float(z)] for x,z in re.findall(r'Vector2\(([-.\d]+),\s*([-.\d]+)\)',text)])
segments=[(a,b) for path in paths for a,b in zip(path,path[1:])]
assert len(segments)<=64
landmarks=[[-24,5],[8,-26],[-20,23],[23,18]]
harvest=[[-7.9,-1.5],[-1.9,-9.6],[-3.4,11.8]]
spawns=[[-21.5,2.7],[6.3,-22.5]]

def distance(a,b):return math.hypot(a[0]-b[0],a[1]-b[1])
def segdist(p,a,b):
    dx=b[0]-a[0];dz=b[1]-a[1]
    t=max(0,min(1,((p[0]-a[0])*dx+(p[1]-a[1])*dz)/max(.001,dx*dx+dz*dz)))
    return distance(p,(a[0]+dx*t,a[1]+dz*t))
def traildist(p):return min(segdist(p,a,b) for a,b in segments)

# Explicit art-directed island centers, two radii and orientation. Adjacent islands
# form crescent walls / staggered ridges, separated by deliberately open bays.
SPECS=[
 ('lodge_west','산장 서쪽 뿌리숲',(-12,-3),4.7,3.3,-22,'crescent',7.4,harvest[0]),
 ('lodge_north','산장 뒤 첨탑숲',(-2,-12.8),5.0,3.4,12,'ridge',8.0,harvest[1]),
 ('lodge_south','벌목 나무 작은 숲',(-8,12),4.2,2.7,-12,'wedge',6.8,harvest[2]),
 ('lodge_east','동쪽 바위 병풍',(18,1),4.0,4.0,18,'ridge',7.6,None),
 ('south_gate','남동 길목 작은 무리',(17,7.4),2.8,2.7,-35,'wedge',5.8,None),
 ('west_inner','벌목터 뒤 고목숲',(-22,-5.8),5.1,4.3,32,'crescent',7.9,None),
 ('northwest_inner','북서쪽 층진 바위숲',(-13.5,-15),4.4,4.8,-38,'ridge',7.5,None),
 ('northwest_rim','북서 바깥 뾰족바위',(-31,-16),4.1,3.6,38,'wedge',7.0,None),
 ('west_rim','서쪽 긴 숲 가장자리',(-37,-2.8),3.2,6.0,6,'ridge',8.0,None),
 ('west_mid','서쪽 안쪽 낮은 능선',(-18.5,12),3.3,3.4,14,'wedge',6.2,None),
 ('camp_rim','야영지 바깥 수관',(-33,18),4.1,4.5,-18,'crescent',7.6,None),
 ('southwest_inner','남서 길 사이 낮은 무리',(-10.8,22.2),3.0,2.5,-15,'wedge',5.8,None),
 ('south_inner','남쪽 긴 고목 능선',(2,22.1),6.0,3.8,12,'ridge',8.2,None),
 ('southwest_rim','남서 외곽 수관',(-14,34),4.0,4.1,22,'crescent',7.1,None),
 ('south_rim','남쪽 큰 소나무 병풍',(8.5,36.5),5.0,3.8,-8,'ridge',8.2,None),
 ('southeast_rim','전망터 뒤 바위숲',(29,28),4.8,4.3,-38,'wedge',7.5,None),
 ('east_rim','동쪽 외곽 초승달 숲',(37,12),3.8,5.8,8,'crescent',8.1,None),
 ('northeast_inner','동북 긴 바위 능선',(19,-6.5),5.6,5.9,22,'ridge',8.0,None),
 ('north_inner','북쪽 길 사이 첨탑',(17,-18),3.9,3.8,-28,'wedge',7.3,None),
 ('north_rim','제단 뒤 얼음 수관',(3,-35.3),5.0,3.6,-10,'crescent',7.7,None),
 ('northeast_rim','북동 외곽 비스듬한 능선',(24,-33),4.1,3.0,35,'ridge',7.0,None),
 ('lookout_inner','전망터 입구 작은 숲',(21.3,10.8),2.6,2.4,-12,'wedge',5.7,None),
 ('northwest_far','북서 외곽 긴 고사목',(-18,-31.5),5.0,3.6,28,'ridge',7.8,None),
 ('southwest_far','서남 외곽 숲 병풍',(-30,29),4.0,3.5,42,'crescent',7.1,None),
 ('west_far','벌목터 너머 외곽 숲',(-41,7),3.2,4.4,-4,'wedge',7.9,None),
 ('east_far','동쪽 뒷 숲',(43,-3),3.0,5.6,10,'ridge',7.8,None),
 ('northeast_gate','동북 꺾이는 길 병풍',(36,-18),3.1,5.1,35,'crescent',7.5,None),
 # Low connectors turn neighboring focal groups into larger irregular forest
 # landforms. Height dips between peaks establish rhythm instead of beaded islands.
 ('west_neck','서쪽 고목숲 연결',(-16.8,-5.5),3.7,2.9,18,'wedge',5.8,None),
 ('northwest_neck','북서 바위숲 연결',(-18,-10.6),4.0,3.5,-34,'wedge',6.2,None),
 ('north_neck','산장 뒤 낮은 수관',(-7.6,-15.2),3.4,2.8,12,'wedge',5.6,None),
 ('east_neck','동북 바위숲 연결',(18.5,-12.5),3.5,4.0,12,'wedge',6.0,None),
 ('south_neck','남쪽 고목숲 연결',(-4.5,22.9),3.7,2.5,0,'wedge',5.8,None),
 ('home_neck','산장 앞 숲 연결',(-13.5,12),3.1,2.5,-8,'wedge',5.2,None),
 ('north_outer_neck','북쪽 바깥 낮은 수관',(-7.5,-35.5),4.8,2.7,10,'ridge',6.0,None),
 ('west_outer_neck','서쪽 바깥 긴 수관',(-36.5,-10),3.4,4.5,-14,'wedge',6.1,None),
 ('camp_outer_neck','야영지 바깥 숲 연결',(-38.5,12.9),3.2,3.5,-22,'wedge',5.5,None),
 ('southwest_outer_neck','서남 외곽 낮은 수관',(-22.5,34),4.0,2.8,20,'ridge',5.8,None),
 ('southeast_outer_neck','남동 외곽 낮은 수관',(20,35),4.4,3.0,-25,'wedge',5.8,None),
 ('northeast_outer_neck','북동 외곽 숲 연결',(32.5,-27),3.6,4.1,28,'wedge',6.0,None),
 ('east_outer_neck','동쪽 바깥 낮은 수관',(41,4.7),2.8,3.7,0,'wedge',6.0,None),
]
TEMPLATES={
 'crescent':[(.12,-.63,1),(-.55,-.30,.83),(.62,-.25,.72),(-.85,.12,.57),(.78,.38,.47),(-.55,.55,.34),(.33,.66,.37)],
 'ridge':[(-.25,-.42,1),(.40,-.25,.82),(-.76,-.13,.75),(.81,.10,.57),(-.44,.35,.54),(.12,.54,.38),(-.83,.60,.32)],
 'wedge':[(.0,-.52,1),(-.55,-.04,.79),(.59,.04,.63),(-.32,.49,.46),(.36,.62,.32)]
}
PINES=['pine_swept_snow','pine_broad_snow','pine_sparse_snow']
groups=[];placed=[];rejected=collections.Counter()

def valid(p,radius,kind):
    if distance(p,(1,1.3))>48:rejected['outer_limit']+=1;return False
    if -6.6-radius<p[0]<8.0+radius and -5.7-radius<p[1]<8.5+radius:
        rejected['lodge_clear']+=1;return False
    lane=3.6+radius if kind!='decor' else 2.85+radius
    if traildist(p)<lane:rejected['trail']+=1;return False
    if any(distance(p,c)<4.75+radius for c in landmarks):rejected['clearing']+=1;return False
    if any(distance(p,c)<2.1+radius for c in spawns):rejected['spawn']+=1;return False
    if kind=='tree' and any(distance(p,c)<1.55 for c in harvest):return False
    if kind in ['tree','rock']:
        for o in placed:
            if o['kind'] not in ['tree','rock']:continue
            # Canopies are allowed to overlap; rock/trunk collider centers are not.
            if distance(p,o['position'])<radius+o['collider_radius']+.22:return False
    return True

def part(group,kind,asset,pos,scale,rot,role,height=0):
    bounds=CAT[asset]['size']
    radius=.4 if kind=='tree' else max(bounds[0]*scale[0],bounds[2]*scale[2])*.48 if kind=='rock' else .13
    if not valid(pos,radius,kind):return
    item=dict(kind=kind,asset=asset,position=[round(v,3) for v in pos],scale=[round(v,3) for v in scale],
              rotation=[round(v,2) for v in rot],role=role,collider_radius=round(radius,3),
              height=round(height if height else bounds[1]*scale[1],3),
              canopy_radius=round(max(bounds[0]*scale[0],bounds[2]*scale[2])*.52,3))
    group['parts'].append(item);placed.append(item)

for index,(id,label,center,rx,rz,yaw,motif,H,linked) in enumerate(SPECS):
    rng=random.Random(87014+index*571)
    angle=math.radians(yaw)
    def position(x,z):
        x*=rx;z*=rz
        return center[0]+x*math.cos(angle)-z*math.sin(angle),center[1]+x*math.sin(angle)+z*math.cos(angle)
    group=dict(id=id,label=label,center=list(center),radii=[rx,rz],yaw=yaw,motif=motif,linked_harvest=linked,parts=[])
    trees=[]
    for j,(x,z,ratio) in enumerate(TEMPLATES[motif]):
        height=H*ratio*rng.uniform(.94,1.04)
        asset=PINES[(index+j)%3] if height>=4 else 'pine_sapling_snow'
        # Sparse silhouettes at ridge ends open views; a few shaded saplings stay green.
        if j==len(TEMPLATES[motif])-1 and index%4==2:asset='pine_sparse'
        s=height/CAT[asset]['size'][1]
        trees.append((group,'tree',asset,position(x,z),[s*rng.uniform(.94,1.08),s,s*rng.uniform(.93,1.08)],
             [rng.uniform(-1.6,1.6),yaw+j*41+rng.uniform(-20,20),rng.uniform(-1.5,1.5)],
             'dominant' if j==0 else 'support' if j<3 else 'edge_sapling',height))
    # Back-to-front massing: large angular rock, then low companions facing the road.
    rock_assets=['rock_ledge_snow','rock_spire_snow','rock_shards','rock_boulder_snow']
    for j,(x,z,size) in enumerate([(-.13,.08,1.18),(-.78,.42,.67),(.66,.61,.51)]):
        asset=rock_assets[(index+j)%4]
        if motif=='wedge' and j==2:continue
        sx=size*(1.32 if asset=='rock_ledge_snow' else 1.0)
        sy=size*(.80 if asset=='rock_ledge_snow' else 1.0)
        part(group,'rock',asset,position(x,z),[sx,sy,size*rng.uniform(.85,1.1)],
             [0,yaw+30+j*53+rng.uniform(-15,15),0],'rock_anchor' if j==0 else 'rock_companion')
    for candidate in trees:part(*candidate)
    # Where the leading rock replaces a tree slot, grow support behind the mass.
    for j,(x,z) in enumerate([(-.75,-.63),(.61,-.67),(.05,-.91)]):
        if sum(p['kind']=='tree' for p in group['parts'])>=4:break
        asset=PINES[(index+j+1)%3];height=H*(.69+j*.08);s=height/CAT[asset]['size'][1]
        part(group,'tree',asset,position(x,z),[s,s,s],[0,yaw+65+j*57,0],'back_support',height)
    if index%3!=1:
        asset='fallen_log' if index%2==0 else 'hollow_stump'
        s=rng.uniform(.65,.90)
        part(group,'decor',asset,position(.16,.69),[s,s,s],
             [0,yaw+(-45 if motif=='ridge' else 35)+rng.uniform(-12,12),0],'root_story')
    if index%5==0:
        s=.57
        part(group,'decor','dead_snag',position(-.6,-.58),[s,s,s],[0,yaw-20,2],'broken_silhouette')
    # Nested undergrowth follows the front lip / pockets around trunks and stones.
    for j,(x,z) in enumerate([(-.88,.28),(-.53,.68),(-.17,.75),(.35,.73),(.83,.47),(.78,-.05),(-.46,-.34)]):
        asset=['fern_clump','berry_shrub','fern_clump','mushroom_cluster'][j%4]
        s=rng.uniform(.62,1.15)
        part(group,'decor',asset,position(x,z),[s,s*rng.uniform(.85,1.05),s],
             [0,yaw+j*63+rng.uniform(-30,30),0],'undergrowth')
    if len(group['parts'])>=4:groups.append(group)

stats=dict(groups=len(groups),parts=sum(len(g['parts']) for g in groups),kinds=dict(collections.Counter(p['kind'] for g in groups for p in g['parts'])),
           asset_types=len(set(p['asset'] for g in groups for p in g['parts'])),path_segments=len(segments),rejected_candidates=dict(rejected))
data=dict(version=1,design='Path-led crescent / ridge / wedge islands; dominant-support-edge hierarchy',
          reference='user image-1, forest pockets around winding lanes',paths=paths,groups=groups,stats=stats)
(OUT/'forest_layout.json').write_text(json.dumps(data,indent=2,ensure_ascii=False),encoding='utf-8')
(REVIEW/'authored-layout.json').write_text(json.dumps(data,indent=2,ensure_ascii=False),encoding='utf-8')
print('FOREST_LAYOUT_READY',stats)
