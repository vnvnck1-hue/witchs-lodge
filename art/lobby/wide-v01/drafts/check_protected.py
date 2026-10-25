"""Read-only protected-path census; report only within authorized drafts."""
from pathlib import Path
import json,hashlib

ROOT=Path(__file__).resolve().parents[4]
D=Path(__file__).resolve().parent
DOC='docs/handoff/codex-lobby-wide-v01.md'
before=json.loads((D/'protected-before.json').read_text(encoding='utf-8'))
changed=[]; missing=[]; hashes=[]
for rel,old in before.items():
    p=ROOT/rel
    if not p.exists(): missing.append(rel); continue
    s=p.stat()
    if s.st_size!=old['size'] or s.st_mtime_ns!=old['mtime_ns']:
        changed.append({'path':rel,'authorized_handoff_append':rel==DOC,'size_before':old['size'],'size_after':s.st_size,'mtime_ns_before':old['mtime_ns'],'mtime_ns_after':s.st_mtime_ns})
    if old['sha256'] is not None and rel!=DOC:
        actual=hashlib.sha256(p.read_bytes()).hexdigest()
        if actual!=old['sha256']: hashes.append({'path':rel,'before':old['sha256'],'after':actual})
new=[]
allowed={'godot/assets/ui/lobby/'+n+'_wide.png' for n in ['lobby_bg','lobby_characters','lobby_character_ids']}
for folder in ['godot','docs']:
    for p in (ROOT/folder).rglob('*'):
        if p.is_file():
            rel=p.relative_to(ROOT).as_posix()
            if rel not in before: new.append({'path':rel,'authorized_wide_png':rel in allowed})
report={'protected_files_in_baseline':len(before),'changed_existing':changed,'missing':missing,'changed_content_hashes':hashes,'new_files_in_observed_roots':new,'direct_write_allowlist':['godot/assets/ui/lobby/lobby_bg_wide.png','godot/assets/ui/lobby/lobby_characters_wide.png','godot/assets/ui/lobby/lobby_character_ids_wide.png','art/lobby/wide-v01/**',DOC+' (append only)'],'godot_started_by_this_task':False,'imports_written_by_this_task':False,'export_or_commit_by_this_task':False,'notes':'Existing Godot/editor processes may observe PNG additions and create import sidecars/cache. Such paths are observed only: no import command, no delete or edit is issued by this task.'}
(D/'protected-verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'protected':len(before),'changed_existing':len(changed),'missing':len(missing),'changed_hashes':len(hashes),'new_files':len(new),'new_non_asset':len([x for x in new if not x['authorized_wide_png']])}))
