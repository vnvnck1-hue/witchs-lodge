"""Place the user's six mossy rock props (assets/rocks/user_rock_*.glb) into forest_layout.json.

Idempotent: earlier user_rock_* parts are replaced. Low decor inside a new rock footprint is removed so
ferns/shrubs do not poke through the stone. Spots were searched for >=3.6m trail clearance plus the
collider, no overlap with tree/rock colliders, outside the lodge yard and the three hazard clearings,
and >=2.5m between user rocks. Each rock turns its sculpted front (+Z) toward the nearest lane.
Run after build_forest_layout.py (which rewrites the layout from scratch).
"""
import collections, json, math, pathlib
ROOT = pathlib.Path(__file__).resolve().parents[1]
LAYOUT = ROOT/'assets/environment/forest_layout.json'
SIZES = {r['id']: r['size_normalized'] for r in
         json.loads((ROOT/'art_sources/user_rocks/split-report.json').read_text(encoding='utf-8'))}
FOOTPRINT = .45   # collider radius / widest normalized side; leaves the grassy rim walkable-looking
# group, asset, x, z, uniform scale, yaw jitter, role
USER_ROCKS = [
    ('lodge_north',   'user_rock_spire',  1.40, -15.32, 11.1,  12, 'rock_anchor'),     # standing stone behind the lodge
    ('north_neck',    'user_rock_low',   -8.83, -17.06, 7.5, -20, 'rock_companion'),  # low stones along the north lane
    ('lodge_west',    'user_rock_ledge',-16.05, -1.07, 10.4,  -8, 'rock_anchor'),     # stepped block at the west lane
    ('west_inner',    'user_rock_slab', -24.10, -3.20, 10.4,  15, 'rock_anchor'),     # slab beside the logging site
    ('lodge_south',   'user_rock_low',  -12.62,  11.95, 7.0,  25, 'rock_companion'),  # south home lane
    ('home_neck',     'user_rock_pile', -17.53, 10.20, 9.1, -30, 'rock_companion'),
    ('west_mid',      'user_rock_spire',-20.50, 14.93, 10.4,   6, 'rock_anchor'),     # marker on the way to the camp
    ('south_inner',   'user_rock_ledge',  5.14, 22.48, 11.1, -12, 'rock_anchor'),     # south ridge facing the home path
    ('south_gate',    'user_rock_steps', 17.09,   3.65, 7.0,  18, 'rock_companion'),  # east gate past the pasture
    ('lodge_east',    'user_rock_pile',  21.77, 0.26, 9.8,  -5, 'rock_companion'),
    ('lookout_inner', 'user_rock_steps', 21.44, 7.55, 9.8,  30, 'rock_companion'),  # stone steps below the lookout
    ('east_neck',     'user_rock_slab',  14.59, -12.19, 10.4, -15, 'rock_anchor'),     # north-east bend
    ('north_inner',   'user_rock_spire', 14.27, -21.97, 11.7,  10, 'rock_anchor'),     # approach to the moon shrine
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
    g['parts'] = [p for p in g['parts'] if not p['asset'].startswith('user_rock')]
removed = 0
for gid, asset, x, z, s, jitter, role in USER_ROCKS:
    g = groups[gid]
    sx, sy, sz = SIZES[asset]
    r = round(max(sx, sz)*s*FOOTPRINT, 3)
    dist, px, pz = nearest_trail(x, z)
    assert dist >= 3.6+r, (gid, dist, r)
    yaw = round(math.degrees(math.atan2(px-x, pz-z))+jitter, 2)   # +Z front toward the lane
    before = len(g['parts'])
    g['parts'] = [p for p in g['parts'] if p['kind'] != 'decor'
                  or math.hypot(p['position'][0]-x, p['position'][1]-z) > r*1.05]
    removed += before-len(g['parts'])
    g['parts'].append(dict(kind='rock', asset=asset, position=[x, z], scale=[s, s, s], rotation=[0, yaw, 0],
                           role=role, collider_radius=r, height=round(sy*s, 3), canopy_radius=round(max(sx, sz)*s*.5, 3)))
gs = data['groups']
data['stats'].update(parts=sum(len(g['parts']) for g in gs),
                     kinds=dict(collections.Counter(p['kind'] for g in gs for p in g['parts'])),
                     asset_types=len({p['asset'] for g in gs for p in g['parts']}))
LAYOUT.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding='utf-8')
print('USER_ROCKS_PLACED', len(USER_ROCKS), 'decor_removed', removed, data['stats'])
