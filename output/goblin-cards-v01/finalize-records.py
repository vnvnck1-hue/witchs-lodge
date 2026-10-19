from pathlib import Path
import json
OUT=Path(__file__).resolve().parent
records=[r for r in json.loads((OUT/'generation-results.json').read_text('utf-8')) if r['attempt']=='v01']
repairs=[json.loads(p.read_text('utf-8')) for p in sorted((OUT/'repairs').glob('*.json'))]
assert len(repairs)==13,len(repairs)
assert {r['id'] for r in repairs}=={r['id'] for r in records}
for r in records:
    r['selected']=False
    r['reason']='제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정.'
    if r['id']=='goblin_gang': r['reason']+=' 인물 종족 배지 누락 보완.'
    if r['id'] in ['scrap','junk_sack']: r['reason']+=' 잘못 복제된 목재 표식을 카드 주제 표식으로 교체.'
typography=[json.loads(p.read_text('utf-8')) for p in sorted((OUT/'typography').glob('*.json'))]
assert len(typography)==5,len(typography)
gang=json.loads((OUT/'gang-final.json').read_text('utf-8'))
geometry=[json.loads(p.read_text('utf-8')) for p in sorted((OUT/'geometry').glob('*.json'))]
assert len(geometry)==4,len(geometry)
gang_title=json.loads((OUT/'gang-title-final.json').read_text('utf-8'))
records += repairs+typography+[gang]+geometry+[gang_title]
latest={r['id']:r for r in records}
for r in records:
    r['selected']=r is latest[r['id']]
    if r['attempt']=='layout-v02' and not r['selected']:
        r['reason']+='; 분류 위치 추가 보완본 선택'
    if r['attempt']=='typography-v03' and not r['selected']:
        r['reason']+='; '+('작은 산세리프 제목을 먹선 화풍으로 재보완' if r['id']=='goblin_gang' else '원화창 하단 안전 여백 복구본 선택')
    if r['attempt']=='brush-v04':
        r['reason']+='; 제목·본문이 과대 확대돼 미채택'
(OUT/'generation-results.json').write_text(json.dumps(records,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'Merged {len(records)} generation records, {len(latest)} selected.')
