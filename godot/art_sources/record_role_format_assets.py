"""Record the complete v02 delivery; inspect pixels without modifying images."""
from pathlib import Path
import hashlib
import json
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'output/role-format-v02'
ART = ROOT / 'art/cards/role-format-v02'

def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))

def write(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

def opaque_hash(im):
    # Godot's alpha-border import repairs hidden RGB. Compare visible pixels;
    # the separate asset verifier checks alpha and rounded edges directly.
    pixels = bytearray(im.convert('RGBA').tobytes())
    for offset in range(0, len(pixels), 4):
        if pixels[offset + 3] < 244:
            pixels[offset:offset+4] = b'\0\0\0\0'
    return hashlib.sha256(pixels).hexdigest()

def metadata(path):
    with Image.open(path) as im:
        return dict(path=path.relative_to(ROOT).as_posix(), width=im.width, height=im.height,
                    mode=im.mode, bytes=path.stat().st_size,
                    sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                    pixel_sha256=hashlib.sha256(im.convert('RGBA').tobytes()).hexdigest(),
                    opaque_pixel_sha256=opaque_hash(im),
                    corner_alpha=[im.getpixel(p)[3] for p in [(0,0),(im.width-1,0),(0,im.height-1),(im.width-1,im.height-1)]],
                    alpha_extrema=list(im.getchannel('A').getextrema()))

plan = read(ART / 'generation-plan.json')
results = {e['id']: e for e in read(ART / 'generation-results.json')}
expected = {e['id'] for e in plan['entries']}
assert len(expected) == 27 and set(results) == expected, 'Incomplete generation inventory'
catalog = ROOT / 'godot/assets/cards/catalog.json'
assert catalog.read_bytes() == (OUT / 'before/catalog.json').read_bytes(), 'Catalog changed during art update'
entries = []
for card in plan['entries']:
    cid = card['id']
    source = metadata(ROOT / 'art/cards/rounded' / (cid + '.png'))
    assert source['sha256'] == metadata(ART / (cid + '.png'))['sha256'], cid + ': staged source differs'
    assert source['sha256'] != metadata(OUT / 'before/rounded' / (cid + '.png'))['sha256'], cid + ': old format remains'
    full = metadata(ROOT / 'godot/assets/cards' / (cid + '.png'))
    hand = metadata(ROOT / 'godot/assets/cards/hand' / (cid + '.png'))
    assert [full['width'], full['height']] == [1024,1536], cid
    assert [hand['width'], hand['height']] == [256,384], cid
    for meta in [full, hand]:
        assert max(meta['corner_alpha']) <= 5, cid + ': rounded corners not transparent'
        with Image.open(ROOT / meta['path']) as im:
            w, h = im.size
            inset = max(3, w // 64)
            positions = [(w//2,inset),(inset,h//2),(w-1-inset,h//2),(w//2,h-1-inset),(w//2,h//2)]
            assert min(im.getpixel(p)[3] for p in positions) > 242, cid + ': missing/translucent card edge or center'
    entries.append(dict(id=cid, title=card['name'], visual_role=card['role'],
                        generation=dict(generator='built-in image_gen', generated_file=results[cid]['generated'],
                                        project_source=source['path'], prompt_set='art/cards/role-format-v02/generation-plan.json',
                                        prompt_id=cid, reference=card['reference']),
                        source=source, full=full, hand=hand, visual_review=results[cid].get('visualReview','')))
manifest = dict(schema_version=2, date='2026-10-16', status='production-deliverable',
                generator='built-in image_gen', design_reference='docs/card-design-guide.md',
                format_reference='art/concepts/cards/roles-individual-v02/',
                prompt_set='art/cards/role-format-v02/generation-plan.json',
                card_count=26, support_asset_count=1, source_png_count=27, shipping_png_count=54,
                catalog='godot/assets/cards/catalog.json', verification='godot/assets/cards/verification.json',
                catalog_sha256=hashlib.sha256(catalog.read_bytes()).hexdigest(),
                visual_review='docs/card-role-format-rollout-v02.md',
                gallery='godot/screenshots/cards/asset-gallery.png',
                packaging='Godot crop and Lanczos resize only; generated alpha preserved',
                multilingual_status='Text space reserved; Korean printed assets, dynamic localization remains separate',
                assets=entries)
export_path = OUT / 'export-verification.json'
if export_path.exists():
    export = read(export_path)
    wanted = {'res://' + e[key]['path'].removeprefix('godot/'): e[key]['opaque_pixel_sha256']
              for e in entries for key in ['full', 'hand']}
    assert export['passed'] and len(export['checked']) == 54, 'Export verification incomplete'
    assert all(c['matches'] and wanted[c['path']] == c['pixel_sha256'] for c in export['checked']), 'Export evidence stale'
    live = ROOT / 'build/WitchsLodge.pck'
    candidate = OUT / 'WitchsLodge-role-format-v02.pck'
    live_hash = hashlib.sha256(live.read_bytes()).hexdigest()
    assert live_hash == hashlib.sha256(candidate.read_bytes()).hexdigest(), 'Live pack differs from verified candidate'
    manifest.update(export_verification='output/role-format-v02/export-verification.json',
                    export_pack=dict(path='build/WitchsLodge.pck', sha256=live_hash,
                                     bytes=live.stat().st_size, status='verified-and-applied'))
    write(ROOT / 'art/cards/export-verification.json', export)
write(ROOT / 'art/cards/manifest.json', manifest)
write(ART / 'delivery-manifest.json', manifest)
write(ROOT / 'art/cards/generation.json', [dict(id=e['id'], **e['generation']) for e in entries])
global_path = ROOT / 'art/manifest.json'
global_entries = read(global_path)
by_path = {e['source']['path']: e for e in entries}
for entry in global_entries:
    if entry.get('path') in by_path:
        asset = by_path.pop(entry['path'])
        entry.update(asset['source'], title=asset['title'], status='production-deliverable',
                     provenance='role-format-v02; built-in image_gen; see art/cards/manifest.json')
for asset in by_path.values():
    global_entries.append(dict(**asset['source'], title=asset['title'], status='production-deliverable',
                               provenance='role-format-v02; built-in image_gen; see art/cards/manifest.json'))
write(global_path, global_entries)
print('ROLE_FORMAT_DELIVERY 27 new sources; 54 shipping PNGs; catalog unchanged')
