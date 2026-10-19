from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'output/goblin-cards-v01'
plan=json.loads((OUT/'generation-plan.json').read_text('utf-8'))
source=(ROOT/'docs/handoff/codex-goblin-cards-v01.md').read_text('utf-8')
checks=[]
for e in plan:
    row=next(line for line in source.splitlines() if line.startswith('| `'+e['id']+'` |'))
    cells=[x.strip() for x in row.strip('|').split('|')]
    expected=[cells[2],cells[3],*cells[4].split(' / ')]
    actual=[e['title'],e['category'],*e['lines']]
    checks.append(dict(id=e['id'],expected=expected,actual=actual,passed=actual==expected))
result=dict(passed=all(c['passed'] for c in checks),scope='Prompt text vs handoff table only; printed glyphs are reviewed visually at original size separately.',cards=checks)
(OUT/'request-text-check.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
assert result['passed']
print('Prompt text matches handoff table exactly: 13/13.')
