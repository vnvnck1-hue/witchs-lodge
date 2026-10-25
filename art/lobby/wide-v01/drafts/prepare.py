from pathlib import Path
from PIL import Image
import hashlib, json

ROOT = Path(__file__).resolve().parents[4]
OUT = ROOT / 'art/lobby/wide-v01'
D = OUT / 'drafts'
ASSETS = ROOT / 'godot/assets/ui/lobby'
D.mkdir(parents=True, exist_ok=True)

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

if __name__ == '__main__':
    baseline_path = D / 'protected-before.json'
    if baseline_path.exists():
        raise SystemExit('Baseline already exists; refusing to replace it')
    records = {}
    for folder in ['godot', 'docs']:
        for p in (ROOT / folder).rglob('*'):
            if p.is_file():
                rel = p.relative_to(ROOT).as_posix()
                s = p.stat()
                # Metadata census for all protected paths; hashes for handoff inputs.
                records[rel] = {'size': s.st_size, 'mtime_ns': s.st_mtime_ns,
                                'sha256': sha(p) if rel.startswith('godot/assets/ui/lobby/') or rel.startswith('docs/') else None}
    p = ROOT / 'WitchsLodge.exe'
    s = p.stat()
    records['WitchsLodge.exe'] = {'size': s.st_size, 'mtime_ns': s.st_mtime_ns, 'sha256': sha(p)}
    baseline_path.write_text(json.dumps(records, ensure_ascii=False, indent=2), encoding='utf-8')
    (D / 'handoff-original.bin').write_bytes((ROOT / 'docs/handoff/codex-lobby-wide-v01.md').read_bytes())
    for name in ['lobby_bg', 'lobby_characters', 'lobby_character_ids']:
        im = Image.open(ASSETS / (name + '.png'))
        im.save(D / (name + '-source.png'))
        if name == 'lobby_character_ids':
            continue
        canvas = Image.new(im.mode, (2640, 1080), (72, 56, 81) if im.mode == 'RGB' else (0, 0, 0, 0))
        canvas.paste(im, (720, 0))
        canvas.save(D / (name + '-outpaint-target.png'))
    print(json.dumps({'protected_files': len(records), 'prepared': True}))
