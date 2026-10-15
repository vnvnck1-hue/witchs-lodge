"""Split the user's Tripo rock sheet (3x2 clusters in one mesh) into six ground-pivoted GLBs.

Each output keeps the original UVs and points at one shared texture (assets/rocks/user_rock_paint.jpg),
so the painted art is not resampled. Components (rocks, moss and grass tufts) are assigned to a sheet
cell by centroid; each cell is recentered on its XZ bounds with y=0 kept as the ground.
"""
import json, pathlib, struct, sys
import numpy as np
HERE = pathlib.Path(__file__).resolve().parent
SRC = HERE/'rock_formation_source.glb'
OUT = HERE.parents[1]/'assets/rocks'
# sheet cells: (id, label) by row (back z<0, front z>0) and column (x < -.175, middle, > .175)
CELLS = {('back', 0): ('user_rock_ledge', '이끼 바위 · 층진 덩어리'),
         ('back', 1): ('user_rock_slab', '이끼 바위 · 계단 판석'),
         ('back', 2): ('user_rock_spire', '이끼 바위 · 선돌'),
         ('front', 0): ('user_rock_pile', '이끼 바위 · 둥근 무더기'),
         ('front', 1): ('user_rock_low', '이끼 바위 · 낮은 돌무리'),
         ('front', 2): ('user_rock_steps', '이끼 바위 · 비탈 돌계단')}

d = SRC.read_bytes()
ln = struct.unpack('<I', d[12:16])[0]; j = json.loads(d[20:20+ln]); b0 = 20+ln+8
def acc(i):
    a = j['accessors'][i]; bv = j['bufferViews'][a['bufferView']]
    n = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3}[a['type']]
    dt = {5126: np.float32, 5125: np.uint32, 5123: np.uint16}[a['componentType']]
    arr = np.frombuffer(d, dtype=dt, count=a['count']*n, offset=b0+bv.get('byteOffset', 0)+a.get('byteOffset', 0))
    return arr.reshape(-1, n) if n > 1 else arr
prim = j['meshes'][0]['primitives'][0]
P = acc(prim['attributes']['POSITION']); N = acc(prim['attributes']['NORMAL'])
UV = acc(prim['attributes']['TEXCOORD_0']); I = acc(prim['indices']).astype(np.int64).reshape(-1, 3)

# connected components over position-welded vertices
key = np.round(P*2000).astype(np.int64)
_, weld = np.unique(key, axis=0, return_inverse=True); weld = weld.ravel()
parent = np.arange(weld.max()+1)
def find(x):
    while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
    return x
for t in I:
    a, b, c = find(weld[t[0]]), find(weld[t[1]]), find(weld[t[2]])
    parent[b] = a; parent[c] = a
vcomp = np.array([find(w) for w in weld])
cell_of_comp = {}
for cid in np.unique(vcomp):
    q = P[vcomp == cid].mean(0)
    col = 0 if q[0] < -.175 else 2 if q[0] > .175 else 1
    cell_of_comp[cid] = ('back' if q[2] < 0 else 'front', col)
tri_cell = [cell_of_comp[vcomp[t[0]]] for t in I]

def pad(b, fill=b'\0'): return b + fill*((4-len(b) % 4) % 4)
report = []
for cell, (name, label) in CELLS.items():
    tris = I[[k for k, c in enumerate(tri_cell) if c == cell]]
    used, inv = np.unique(tris.ravel(), return_inverse=True)
    pos = P[used].copy(); nrm = N[used].astype(np.float32); uv = UV[used].astype(np.float32)
    idx = inv.astype(np.uint32)
    center = (pos.min(0)+pos.max(0))/2; pos[:, 0] -= center[0]; pos[:, 2] -= center[2]; pos[:, 1] -= pos[:, 1].min()
    pos = pos.astype(np.float32)
    blobs = [pos.tobytes(), nrm.tobytes(), uv.tobytes(), idx.tobytes()]
    views, off, binary = [], 0, b''
    for k, blob in enumerate(blobs):
        views.append({'buffer': 0, 'byteOffset': off, 'byteLength': len(blob), 'target': 34963 if k == 3 else 34962})
        binary += pad(blob); off = len(binary)
    gl = {'asset': {'version': '2.0', 'generator': 'witchs-lodge split_rock_sheet.py (source: Tripo)'},
          'scene': 0, 'scenes': [{'nodes': [0]}], 'nodes': [{'mesh': 0, 'name': name}],
          'meshes': [{'name': name, 'primitives': [{'attributes': {'POSITION': 0, 'NORMAL': 1, 'TEXCOORD_0': 2}, 'indices': 3, 'material': 0}]}],
          'materials': [{'name': 'user_rock_paint', 'doubleSided': True,
                         'pbrMetallicRoughness': {'baseColorTexture': {'index': 0}, 'metallicFactor': 0, 'roughnessFactor': .9}}],
          'textures': [{'source': 0}], 'images': [{'uri': 'user_rock_paint.jpg'}],
          'accessors': [{'bufferView': 0, 'componentType': 5126, 'count': len(pos), 'type': 'VEC3', 'min': pos.min(0).tolist(), 'max': pos.max(0).tolist()},
                        {'bufferView': 1, 'componentType': 5126, 'count': len(pos), 'type': 'VEC3'},
                        {'bufferView': 2, 'componentType': 5126, 'count': len(pos), 'type': 'VEC2'},
                        {'bufferView': 3, 'componentType': 5125, 'count': len(idx), 'type': 'SCALAR'}],
          'bufferViews': views, 'buffers': [{'byteLength': len(binary)}]}
    js = pad(json.dumps(gl, separators=(',', ':')).encode(), b' ')
    glb = struct.pack('<III', 0x46546C67, 2, 12+8+len(js)+8+len(binary)) + struct.pack('<II', len(js), 0x4E4F534A) + js + struct.pack('<II', len(binary), 0x004E4942) + binary
    (OUT/f'{name}.glb').write_bytes(glb)
    size = (pos.max(0)-pos.min(0)).round(3).tolist()
    report.append({'id': name, 'label': label, 'cell': list(cell), 'triangles': len(tris), 'vertices': len(pos), 'size_normalized': size})
(HERE/'split-report.json').write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding='utf-8')
for r in report: print(r)
