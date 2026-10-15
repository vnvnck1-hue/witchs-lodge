"""Place the user's two vine/root props (assets/vines/*.glb) into forest_layout.json.

Idempotent: earlier parts of these assets are replaced; low decor inside a new footprint is removed.
Gnarled roots gather on the rims of the three corrupted zones (venom hollow, wing nest, blighted roots)
plus one behind the lodge and one on the far west lane. Spots keep >=3.6m trail clearance plus the
collider, stay outside the hazard clearings, clear tree trunks and only nestle lightly against rocks.
Each prop turns its front (+Z) toward the nearest lane. Run after build_forest_layout.py.
"""
import collections, json, math, pathlib
ROOT = pathlib.Path(__file__).resolve().parents[1]
LAYOUT = ROOT/'assets/environment/forest_layout.json'
# normalized Tripo bounds (x, y, z), pivot at ground; collider = FOOTPRINT[id] * scale
SIZES = {'user_vine_coils': (1.0, .345, .986), 'user_tangled_roots': (1.0, .469, .641)}
FOOTPRINT = {'user_vine_coils': .42, 'user_tangled_roots': .36}   # arch interior / long thin root tips stay open
# group, asset, x, z, uniform scale, yaw jitter, role
USER_VINES = [
    ('northwest_rim',   'user_tangled_roots', -29.04, -18.01, 5.0,  15, 'root_anchor'),  # venom hollow, west rim
    ('northwest_inner', 'user_vine_coils',    -12.56, -11.47, 4.5, -10, 'root_anchor'),  # venom hollow, east rim
    ('southwest_rim',   'user_tangled_roots',  -9.27,  34.26, 5.0, -20, 'root_anchor'),  # blighted roots, south rim
    ('south_rim',       'user_vine_coils',      8.59,  33.80, 4.5,  20, 'root_anchor'),  # blighted roots, east side
    ('northeast_inner', 'user_vine_coils',     20.80,  -3.99, 4.5,   8, 'root_anchor'),  # wing nest, south rim
    ('east_neck',       'user_tangled_roots',  21.43, -16.84, 5.0, -12, 'root_anchor'),  # wing nest, north rim
    ('lodge_north',     'user_tangled_roots',   2.79,  -9.51, 4.6,  25, 'root_anchor'),  # old roots behind the lodge
    ('west_rim',        'user_vine_coils',    -34.94,   3.33, 4.5, -15, 'root_anchor'),  # far west lane past the logging site
]

data = json.loads(LAYOUT.read_text(encoding='utf-8'))
paths = data['paths']
def nearest_trail(x, z):
    best = (1e9, x, z)
    for path in paths:
        for (ax, az), (bx, bz) in zip(path, path[1:]):
            dx, dz = bx-ax, bz-az
            t = max(0, min(1, ((x-ax)*dx+(z-az)*dz)/(dx*dx+dz*dz)))
            px, pz = ax+t*dx, az+t*dz
            best = min(best, (math.hypot(x-px, z-pz), px, pz))
    return best
groups = {g['id']: g for g in data['groups']}
for g in data['groups']:
    g['parts'] = [p for p in g['parts'] if p['asset'] not in SIZES]
removed = 0
for gid, asset, x, z, s, jitter, role in USER_VINES:
    g = groups[gid]
    sx, sy, sz = SIZES[asset]
    r = round(FOOTPRINT[asset]*s, 3)
    dist, px, pz = nearest_trail(x, z)
    assert dist >= 3.6+r, (gid, dist, r)
    yaw = round(math.degrees(math.atan2(px-x, pz-z))+jitter, 2)
    before = len(g['parts'])
    g['parts'] = [p for p in g['parts'] if p['kind'] != 'decor'
                  or math.hypot(p['position'][0]-x, p['position'][1]-z) > r*1.05]
    removed += before-len(g['parts'])
    # kind "rock" = static obstacle body in forest_composition.gd (blocks walking, joins the nav bake)
    g['parts'].append(dict(kind='rock', asset=asset, position=[x, z], scale=[s, s, s], rotation=[0, yaw, 0],
                           role=role, collider_radius=r, height=round(sy*s, 3), canopy_radius=round(max(sx, sz)*s*.5, 3)))
gs = data['groups']
data['stats'].update(parts=sum(len(g['parts']) for g in gs),
                     kinds=dict(collections.Counter(p['kind'] for g in gs for p in g['parts'])),
                     asset_types=len({p['asset'] for g in gs for p in g['parts']}))
LAYOUT.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding='utf-8')
print('USER_VINES_PLACED', len(USER_VINES), 'decor_removed', removed, data['stats'])
