"""Append only the explicitly authorized handoff section after successful QA."""
from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[4]
OUT=ROOT/'art/lobby/layers-v01'
DOC=ROOT/'docs/handoff/codex-lobby-layers-v01.md'
v=json.loads((OUT/'verification.json').read_text(encoding='utf-8'))
assert v['all_saved_file_checks_pass'], 'Saved-file validation must pass first'
assert v['visual_review']['status']=='reviewed', 'Native-resolution visual review must be recorded first'
original=(OUT/'drafts/handoff-original.bin').read_bytes()
current=DOC.read_bytes()
assert current.startswith(original),'Original handoff must stay unchanged'
heading='## Codex 납품 결과 · 2026-10-24'
assert heading not in current.decode('utf-8-sig'),'Delivery section already exists; refusing duplicate append'
c=v['comparison']; p=v['protected_paths']; count=sum(v['saved_file_checks'].values())
chapter=f'''

{heading}

요청 문서를 끝까지 읽고, 승인 원화(`57f0b75bff33e4c85755a030172a3cb9942ede345b41e717efa528c5820afbdf`)를 실제 입력으로 사용해 레이어를 분리했다.

### 납품 파일

- [게임용 폴더](../../godot/assets/ui/lobby/): 지정 PNG 11개와 `lobby_layout.json`. PNG는 모두 1920×1080이며 원본 좌표를 유지한다. 배경·구역 지도는 RGB, 인물·타이틀·메뉴 9개는 RGBA straight alpha다.
- [검수 시트](../../art/lobby/layers-v01/sheet.png): 원화, 재합성, 배경판, 체크무늬 위 인물, 체크무늬 위 UI, 인물 왼쪽 6px·위쪽 4px 이동 결과의 여섯 칸. 각 칸의 그림은 원본 해상도다.
- [구역 지도 50% 겹침](../../art/lobby/layers-v01/ids-overlay.png): 인물·모자·날개·더듬이·고블린 귀와 귀걸이를 구분했다. R=G=B의 지정 정수만 사용한다. 늑대 귀는 위로 잘려 선택 값 140을 생략했다.
- [검증 수치](../../art/lobby/layers-v01/verification.json), [README](../../art/lobby/layers-v01/README.md), [실제 프롬프트](../../art/lobby/layers-v01/prompts.md), [마스크·생성 원본·재현 스크립트](../../art/lobby/layers-v01/drafts/)를 함께 제공한다. 내장 image_gen 편집은 배경 복원에 1회 사용했으며, 인물과 글자는 원화에서 추출했다.

### 검증 결과

저장된 PNG·JSON을 다시 읽는 독립 검증 **{count}/{len(v['saved_file_checks'])} 통과**. 불투명한 인물·글자 픽셀의 원본 RGB 보존, 투명 바깥 RGB/알파 0, 실제 bbox, 구역 값과 투명 영역 대응, 산장·하단 설경·상단 하늘의 원본 픽셀 보존을 확인했다.

허용된 크림 상자 경계 띠를 제외한 **{c['included_pixels']:,}픽셀**에서 완전 일치 **{c['exact_pixels_percent']:.6f}%**, 최대 채널 차이 2 이하 **{c['within_2_percent']:.6f}%**, 8 초과 **{c['over_8_pixels']:,}픽셀 / {c['over_8_percent']:.6f}%**로 요청 기준 0.5% 미만을 통과했다. 0 오차라고 주장하지 않는다. 제외한 곳은 `(x,y,w,h)` 기준 `(1140,50,241,800)`과 `(1140,50,780,241)`의 합집합 **{c['excluded_pixels']:,}픽셀**뿐이며 [제외 마스크](../../art/lobby/layers-v01/drafts/verification-exclusion-mask.png)를 저장했다.

최종 배경, 체크무늬의 인물·UI 경계, 구역 겹침, `(-6,-4)` 이동 결과를 열어 검수했다. 가려졌던 숲을 복원하고 크림 상자 경계를 넓은 안개로 정리했으며, 글자가 놓일 밝은 크림 영역과 기존 산장의 중세 판타지 분위기를 유지했다.

### 범위 준수와 병행 변경 관측

이 작업의 직접 쓰기는 `godot/assets/ui/lobby/`, `art/lobby/layers-v01/`, 이 문서의 본 납품 절에 한정했다. 금지된 코드·씬·셰이더·도구·다른 자산·기존 원화·다른 문서·루트 실행파일에 쓰기 명령을 실행하지 않았고 커밋, Godot 실행, 임포트 파일 작성, 실행파일 내보내기도 하지 않았다. 요청 문서의 기존 바이트가 그대로 접두부로 남는 것을 검사했다.

작업 전후 보호 파일 **{p['files_compared']:,}개**의 크기·수정 시각 비교에서는 **{len(p['changed'])}개 갱신, {len(p['missing'])}개 누락**이 관측됐다. 게임 코드·셰이더·검증 기록·Godot 캐시·`WitchsLodge.exe`를 포함한 별도 진행 중 변경이며 이 작업에서 해당 경로에 직접 쓰지 않았다. `ui/lobby/` 안에서도 별도의 weight PNG 및 `.import` 파일이 확인됐으나 수정하거나 삭제하지 않았다. 경로별 관측과 작업의 쓰기 범위는 [보호 경로 기록](../../art/lobby/layers-v01/drafts/protected-paths-verification.json)에 남겼다. 임포트·실제 게임 적용·내보내기는 역할 분담대로 Claude가 담당한다.
'''
with DOC.open('ab') as f:f.write(chapter.encode('utf-8'))
assert DOC.read_bytes().startswith(original)
summary=f'''\n\n## 납품 검증 수치 · 2026-10-24\n\n독립 검사 {count}/{len(v['saved_file_checks'])} 통과. 허용 경계 띠 밖에서 채널 차이 2 이하 {c['within_2_percent']:.6f}%, 8 초과 {c['over_8_percent']:.6f}%로 기준을 통과했다. 배경 생성은 내장 image_gen 편집 1회이며 실제 프롬프트는 `prompts.md`에 있다.\n\n보호 파일 {p['files_compared']:,}개 관측 중 별도 갱신 {len(p['changed'])}개·누락 {len(p['missing'])}개가 있었다. 게임 코드·Godot 캐시·실행파일 등의 갱신 목록과 별도 생성된 임포트 파일은 `drafts/protected-paths-verification.json`에 기록했다. 이 작업은 이들 경로에 직접 쓰지 않았다.\n'''
with (OUT/'README.md').open('ab') as f:f.write(summary.encode('utf-8'))
print('Appended delivery section; original handoff prefix preserved.')
