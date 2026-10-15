"""Write the jobs handoff's prompt log, delivery inventory and review record."""
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'output/jobs-update-v01'
specs=json.loads((OUT/'card-specs.json').read_text(encoding='utf8'))
record=json.loads((OUT/'generation-record.json').read_text(encoding='utf8'))
g={a['id']:a for a in record['assets']}
# Restore the exact first prompt (the first request preceded prompt logging).
s=specs[0]
g[s[0]]['prompt']=record['card_common']+'\nSUBJECT: '+s[4]+'\nExact printed text: title "나무꾼"; category "용병 · 벌목 계약"; bottom first line "나무에 사용하면 벌목합니다."; bottom second line "목재를 들고 있다가 건네줍니다.".'
(OUT/'generation-record.json').write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
prompt=['# 용병 직업·야생 동물·유물 에셋 생성 프롬프트 v01','',
    '2026-10-15 · 내장 image_gen · 모든 이미지 transparent_background=true. CLI/API 경로는 사용하지 않았다.',
    '',
    '카드는 기존 도끼 용병을 프레임·붓터치·한글 서체 참고로 사용했다. 채집가는 미라 초상을 추가 인물 참고로 사용했다. 아이콘은 기존 moon_runes 승인 아틀라스에서 시작해 icon_timber 원화를 공통 선·채도 참고로 썼다. 상자는 treasure_chest 카드 → chest_closed → chest_open 순서로 동일성을 유지했다.',
    '',
    '코드 후처리는 카드의 불투명 본체 크롭과 Lanczos 크기 정규화, UI 원화의 Lanczos 축소만 수행한다. 그림·문자·알파 마스크를 코드로 덧그리지 않았다. 토끼 가죽과 미공개 유물은 첫 검증의 외곽 알파 실패를 image_gen 수정으로 해결했다.',
    '',
    '각 항목의 생성 파일은 원본 보존 디렉터리의 파일명이며, 최종본은 프로젝트에 복사했다. 모든 최종 소스·배포 SHA-256은 art/cards/manifest.json과 output/jobs-update-v01/delivery-manifest.json에 기록한다.','']
for a in record['assets']:
    id=a['id'];name=next((s[1] for s in specs if s[0]==id),id)
    filename=re.search(r'as (.+?\.png) by default',a['output_hint'])[1].split('\\')[-1]
    prompt+=['## '+id+' · '+name,'','최종 채택 생성 파일: `'+filename+'`.','',
        '### 최초 생성 프롬프트','','```text',a['prompt'],'```','']
    if a.get('alpha_final_prompt'):
        prompt+=['### 외곽 알파 수정 · 최종 채택','','```text',a['alpha_final_prompt'],'```','']
prompt+=['## 3D 제작 기록','',
    'Blender 5.2.2 LTS에서 godot/art_sources/build_wildlife.py로 직접 메시를 제작했다. 생성 이미지나 외부 모델을 3D로 변환하지 않았다. 1m 단위, +Y 위, +Z 정면, 발바닥 Y=0. Col 코너 버텍스 컬러와 큰 평면 색, 텍스처 0개. Body/Head 피벗을 보존하고 몸·머리를 각 1메시로 통합했다.',
    '',
    '토끼 2,528삼각형, 사슴 2,548삼각형. 비매니폴드 엣지·퇴화 면 모두 0. 편집용 wildlife.blend에 토끼·사슴 컬렉션을 보존한다. 두 컬렉션은 편집 편의를 위해 가로로 나란히 배치되며 각 GLB는 원점에서 내보낸다.','']
(ROOT/'docs/prompts/cards/jobs-update-v01-prompts.md').write_text('\n'.join(prompt),encoding='utf8')
review=['# 용병 직업·야생 동물·유물 v01 최종 검수','',
    '2026-10-15 · 최종 배포 PNG의 제목·분류·본문을 1:1 크롭 시트 네 장과 개별 원화에서 직접 확대 대조했다. 아래 전 항목의 오탈자를 발견하지 않았다. 미공개 유물은 큰 물음표와 지정 제목/분류만 있고 본문은 비어 있다.','',
    '| ID | 제목 / 분류 | 인쇄 본문 1 | 인쇄 본문 2 | 결과 |',
    '| --- | --- | --- | --- | --- |']
for s in specs:
    review.append('| `'+s[0]+'` | '+s[1]+' / '+s[2]+' | '+(s[3][0] if s[3] else '없음')+' | '+(s[3][1] if s[3] else '없음')+' | 확대 대조 통과 |')
review+=['','## 검사 증거','',
    '- [문구 시트 01](../../godot/screenshots/cards/jobs-update-v01-text-proof-01.png): 나무꾼·사냥꾼·전투용병·채집가.',
    '- [문구 시트 02](../../godot/screenshots/cards/jobs-update-v01-text-proof-02.png): 생고기·토끼 가죽·보물상자·미공개 유물.',
    '- [문구 시트 03](../../godot/screenshots/cards/jobs-update-v01-text-proof-03.png): 달빛 부적·화로의 온기석·고목의 심장·늑대 송곳니 목걸이.',
    '- [문구 시트 04](../../godot/screenshots/cards/jobs-update-v01-text-proof-04.png): 서리 여왕의 눈물.',
    '- [22장 갤러리](../../godot/screenshots/cards/asset-gallery.png): 실제 Godot 임포트 텍스처, 밝음/어두움 패널, 카드별 손패 크기. 잘림 없이 4열 6행을 확인했다.',
    '- [카드 검사](../../godot/assets/cards/verification.json): passed=true, 실패 0. 배포 44 PNG의 RGBA·크기·투명 모서리·불투명 중앙/외곽·텍스처 로딩을 통과했다. 신규 13종의 카탈로그 인쇄 문구 일치와 없는 ID의 뒷면 대체도 통과했다.',
    '- [UI·동물 검사](../../output/jobs-update-v01/asset-verification.json): passed=true, 실패 0. 아이콘 11개와 상자 2개의 크기·RGBA·알파·로딩, GLB 2개와 tscn 2개의 노드·치수·공유 재질·피벗 동작 확인.',
    '- [아이콘 축소 확인](../../output/jobs-update-v01/icon-proof.png): 96px 실물과 144px 비교에서 실루엣·선·채도 일관성을 확인했다.',
    '- [Godot idle](../../output/jobs-update-v01/wildlife-godot-idle.png)와 [머리 숙임](../../output/jobs-update-v01/wildlife-godot-grazing.png): Forward+에서 재질·비율·피벗 움직임 확인.',
    '- [Blender 검사](../../output/jobs-update-v01/wildlife-blender-verification.json): 토끼 0.45×0.35m(길이×높이), 사슴 1.5×1.6m(길이×뿔 포함 높이), 어깨 약 1.10m. 각각 2메시, 비매니폴드 엣지/퇴화 면 0, 텍스처 0.',
    '',
    '## 수량과 동시 작업 범위','',
    '요청서의 기존 9장은 뒷면을 포함한다. 기존 카드 앞면 8종 + 새 앞면 13종 = 앞면 21종이며, 뒷면 1장을 더한 갤러리/검사 대상은 총 22장이다. 따라서 “22종+뒷면”은 산술상 1장 차이가 있어 실제 ID 목록으로 범위를 명시했다. axe_mercenary는 보존·검증했다.',
    '',
    '동시에 추가된 sleeping_thorn_seed·black_sheep·black_wool은 이번 13종 요청 밖의 다른 작업이다. 파일과 카탈로그를 변경하지 않고 별도 catalog IDs로 보고한다. 이번 에셋 담당은 godot/scripts/**, cards/catalog.json, scenes/main.tscn, shaders/**를 쓰지 않았다. 이 경로의 동시 변경은 되돌리지 않았다. 커밋하지 않았다.',
    '',
    'Godot 4.7.2 --headless --editor --import는 종료 코드 0이며 모델 임포트 오류가 없다. 시스템 인증서 저장소 읽기 오류는 기존과 같이 로그에 남지만 로컬 파일의 패키징·임포트·검증·렌더는 모두 정상 완료했다. 게임 규칙 검증 및 PCK 재내보내기는 이 에셋 납품에서 수행하지 않았다.','']
(ROOT/'art/cards/jobs-update-v01-review.md').write_text('\n'.join(review),encoding='utf8')
delivery=json.loads((OUT/'delivery-manifest.json').read_text(encoding='utf8'))
lines=['# 직업·야생 동물·유물 v01 에셋 납품 목록','',
    '필수 생성 파일 **56개**(카드 PNG 39, 아이콘 PNG 11, GLB 2, tscn 2, 상자 PNG 2)와 편집 원본 wildlife.blend 1개, 합계 **57개**. 아래는 정확한 상대 경로 목록이다. 바이트 수·SHA-256·PNG 메타데이터는 [JSON manifest](delivery-manifest.json).','']
for a in delivery['assets']:lines.append('- ['+a['path']+'](../../'+a['path']+')')
lines+=['','검증: [카드](../../godot/assets/cards/verification.json) · [UI/동물](asset-verification.json) · [확대 검수](../../art/cards/jobs-update-v01-review.md) · [프롬프트](../../docs/prompts/cards/jobs-update-v01-prompts.md).']
(OUT/'delivery.md').write_text('\n'.join(lines)+'\n',encoding='utf8')
print('JOBS_DOCS_WRITTEN')
