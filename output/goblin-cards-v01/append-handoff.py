from pathlib import Path
import json,hashlib
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'output/goblin-cards-v01'
plan=json.loads((OUT/'generation-plan.json').read_text('utf-8'))
verify=json.loads((OUT/'verification.json').read_text('utf-8'))
assert verify['passed']
p=ROOT/'docs/handoff/codex-goblin-cards-v01.md'
before=p.read_bytes()
assert not any(line.startswith('## Codex 납품 결과') for line in before.decode('utf-8-sig').splitlines())
lines=['', '', '## Codex 납품 결과 · 2026-10-19', '',
'- **납품:** 고블린 카드 13종의 보존 원본·게임용 **RGBA 1024×1536**, 손패용 **RGBA 256×384**, 총 **39개 PNG**를 아래 지정 경로에 저장했다. 네 모서리를 라운드 처리하고 바깥은 투명하게 만들었다. 손패는 동일 그림의 정확한 1/4 균등 축소다.',
'- **실제 참고:** 내장 `image_gen`으로 **37회 생성/수정**했다. 모든 호출에 해당 역할 승인 PNG, 같은 역할의 게임 카드 1~2장, 고블린 외형 참고 시트를 실제 이미지 입력으로 전달했다. 참고 입력 최대 5장 제한 때문에 니브 원화와 그라즈·탁·피클·러스크·말라 초상 6개를 비율 유지 비교 시트로 묶었다. 후반에는 배치·마름모 도식을 보조 입력으로 추가했다. 승인 PNG·현재 게임 참고·외형 원본은 수정하지 않았다.',
'- **재생성·선정:** 13종 모두 첫 생성본의 큰 글자·부족한 여백을 보완했다. `goblin_gang`은 작은 종족 배지를 복구하고 분류 위치·제목 먹선을 추가 조정해 **4회 수정**, 스킬 4종(`goblin_firecracker`, `dud_bomb`, `goblin_rush`, `shiny_lure`)은 분류 위치와 마름모 하단·눈/장화 침범을 정리해 **각 3회 수정**했다. 나머지 8종은 **각 1회 수정**했으며, `junk_sack`·`scrap`의 잘못 복제된 목재 표식은 각각 자루·쇠붙이 표식으로 교정했다. `goblin_gang`의 `brush-v04`는 제목·본문이 과대 확대돼 미채택했다. 가공 전 **37개 생성본과 미채택본 모두 `drafts/`에 보존**했다.',
'- **후처리:** 채택한 원화의 RGB·프레임·인쇄 글자는 그대로 유지하고 카드지 알파와 라운드 외곽만 정규화했다. 코드로 그림이나 글자를 덧그리거나 바꾸지 않았다.',
'- **검증:** 13종의 제목·분류·두 줄 인쇄 문구를 원본 크기 크롭에서 직접 대조해 오탈자·누락 없음으로 확인했다. 역할별 골격, 제목 2줄·설명 4줄 여백, 중세 판타지 재료와 손패 실루엣을 승인 PNG 5종 비교 시트로 확인했다. 39개 PNG 규격·채널·모서리 알파·SHA-256, 원본/게임용 동일성·RGB 보존·손패 균등 축소 검증 **`passed=true`**. 이미지 전용 격리 프로젝트에서 Godot **`--import` 종료 코드 0**, 임포트 텍스처 규격·알파·픽셀 해시 **26/26 통과**. 해당 카드 26개의 `.import`와 텍스처 캐시만 게임 프로젝트로 반영했다.',
'- **기록:** [미리보기 시트](../../godot/screenshots/goblin-cards/sheet.png), [검증 JSON](../../output/goblin-cards-v01/verification.json), [실제 프롬프트·참고 입력·수정 사유](../prompts/cards/goblin-v01-prompts.md), [37회 생성 이력](../../output/goblin-cards-v01/generation-results.json), [원본 크기 시각 검수](../../output/goblin-cards-v01/visual-review.json), [임포트 로그](../../output/goblin-cards-v01/import.log).',
f'- **작업 경계:** 금지 경로에는 직접 쓰지 않았으며 다른 변경을 되돌리지 않았다. 시작 시점 보호 파일 {verify["protected_files_checked"]}개와 비교해 다른 세션의 변경 {len(verify["protected_changes_observed"])}개를 관찰 기록으로만 남기고 보존했다(게임 코드·씬·카탈로그·기획 문서·EXE 포함). 이 요청서는 기존 본문을 유지하고 이 절만 추가했다. **커밋·실행파일 내보내기는 하지 않았다.**',
'- **남은 문제:** 13종 모두 납품 기준 미달 사항 없음. Godot의 시스템 루트 인증서 저장소 오류 로그와 검증기의 원본 이미지 읽기 경고가 있었으나 로컬 이미지 임포트·텍스처 로드·픽셀 검증은 모두 통과했다. 다국어 동적 텍스트 구현은 이번 이미지 납품 범위 밖이다.',
'', '### 파일 목록', '', '| id | 보존 원본 | 게임용 | 손패용 |', '| --- | --- | --- | --- |']
for e in plan:
    id=e['id'];lines.append(f'| `{id}` | [PNG](../../art/cards/goblin-v01/{id}.png) | [PNG](../../godot/assets/cards/{id}.png) | [PNG](../../godot/assets/cards/hand/{id}.png) |')
lines += ['', '가공 전 생성본: `art/cards/goblin-v01/drafts/` · 보조 입력: `output/goblin-cards-v01/goblin-appearance-reference.png`, `layout-guides/`, `geometry-guides/` · 검증 재현 스크립트: `output/goblin-cards-v01/pipeline.py`, `run-import.ps1`.', '']
addition='\n'.join(lines).encode('utf-8')
with p.open('ab') as f: f.write(addition)
after=p.read_bytes()
proof=dict(path=p.relative_to(ROOT).as_posix(),original_bytes=len(before),original_sha256=hashlib.sha256(before).hexdigest(),original_prefix_preserved=after[:len(before)]==before,appended_section='## Codex 납품 결과 · 2026-10-19',passed=after==before+addition)
(OUT/'handoff-append.json').write_text(json.dumps(proof,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Appended delivery section; original handoff byte prefix preserved.')
