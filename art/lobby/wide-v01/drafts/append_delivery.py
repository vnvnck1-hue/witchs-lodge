"""Append only to the handoff; refuse if its pre-existing bytes changed."""
from pathlib import Path

ROOT=Path(__file__).resolve().parents[4]
D=Path(__file__).resolve().parent
doc=ROOT/'docs/handoff/codex-lobby-wide-v01.md'
original=(D/'handoff-original.bin').read_bytes()
section='''

## Codex 납품 결과 · 2026-10-24

요청 문서를 끝까지 읽고 왼쪽 720px 확장 에셋과 검수·제작 기록을 납품했다.

### 납품 파일

- [배경](../../godot/assets/ui/lobby/lobby_bg_wide.png), [인물](../../godot/assets/ui/lobby/lobby_characters_wide.png), [구역 지도](../../godot/assets/ui/lobby/lobby_character_ids_wide.png): 모두 **2640×1080**. 배경·지도는 RGB, 인물은 RGBA다. 기존 세 파일은 덮어쓰지 않았다.
- [검수 시트](../../art/lobby/wide-v01/sheet.png): 5280×2248, 전체 재합성·이음매 x=600~840의 2배 확대(상하 분할)·오른쪽 기준 21:9·구역 지도 50% 겹침의 네 칸. 기존 타이틀·메뉴를 x+720에 얹었다.
- [검증 수치](../../art/lobby/wide-v01/verification.json), [README](../../art/lobby/wide-v01/README.md), [실제 프롬프트](../../art/lobby/wide-v01/prompts.md), [초안·재현 및 검증 스크립트](../../art/lobby/wide-v01/drafts/)를 함께 제공한다. 내장 image_gen 편집 3회를 사용했으며 CLI/API 대체 생성은 사용하지 않았다.

### 검증·시각 검수

저장된 파일을 다시 읽는 독립 검사 **34/34 통과**. 세 파일 각각 원본 자리 **x≥720의 2,073,600픽셀**, **차이 0픽셀**, **최대 채널 차이 0**이다. 현재 원본 파일의 내용 해시도 작업 전과 같다. 인물의 알파와 숨은 RGB까지 원본 영역을 그대로 유지했다.

확장부는 기존 인간의 털·초록 망토·가죽끈과 금장식, 드워프 어깨 갑옷·털과 천, 요정의 원래 작은 날개 끝을 이어 그렸다. 초안의 과장된 추가 날개는 제거했다. 새 얼굴·새 인물을 넣지 않았으며 맨 왼쪽은 자두·남색 그림자로 살짝 낮췄다. 중세 기반 판타지와 원화의 먹선·색면·인쇄 질감을 유지했다.

구역 지도는 R=G=B의 지정 정수만 사용하고, 확장부는 20(인간 및 가장 가까운 얼굴 없는 털·천), 160(드워프), 220(요정 날개 끝)이다. 인물 alpha 0과 ID 0이 정확히 대응한다. 새 인물 영역의 불투명 내부를 복원하고 바깥은 투명하게 유지했으며 배경에는 인물 없는 숲을 채웠다.

전체·이음매 확대·체크무늬 위 인물·배경 단독·구역 겹침·인물 (-6,-4) 이동 결과를 열어 확인했다. 21:9는 x=80~2639의 2560×1080, 3440×1440 상당은 x=60~2639의 2580×1080으로 잘라 위아래 보존과 오른쪽 메뉴 배치를 확인했다. 최종 합성에서 확장 경계의 직선 접합과 새 얼굴은 보이지 않았다.

### 범위 준수와 병행 변경 관측

이 작업의 직접 쓰기는 지정 세 `_wide.png`, `art/lobby/wide-v01/`, 이 문서의 본 납품 절에 한정했다. 기존 로비 PNG·게임 스크립트·씬·셰이더·도구·다른 자산·다른 문서·루트 실행파일에 쓰기 명령을 실행하지 않았다. 커밋·Godot 실행·임포트 명령·내보내기도 수행하지 않았다. 이 문서의 기존 바이트는 작업 전 스냅샷과 같은 접두부로 유지한다.

보호 파일 **8,788개**를 관측했다. 1차 대조에서 **기존 파일 18개 갱신, 누락 0개**와 별도의 새 코드·도구·문서·스크린샷 및 Godot 임포트 산출물이 확인됐다. 문서와 `WitchsLodge.exe`의 별도 내용 해시 변경도 관측했으므로 작업 공간 전체가 불변이라고 주장하지 않는다. 이 작업은 그 경로들을 편집·삭제·되돌리지 않았다. 기존 로비 PNG의 내용 해시 변동은 없다. `.import`와 캐시는 외부 감시 프로세스가 만들었을 가능성이 있으며 정확한 실행 주체는 확인하지 않았다.

최종 경로별 관측과 직접 쓰기 허용 목록은 [보호 경로 기록](../../art/lobby/wide-v01/drafts/protected-verification.json)에 남겼다. 요청서에 따라 게임 적용·임포트·실행파일 내보내기는 구현 담당자에게 남긴다.
'''
if doc.read_bytes()!=original:
    raise SystemExit('Handoff changed since baseline; refusing to overwrite or append twice')
with doc.open('ab') as f:
    f.write(section.encode('utf-8'))
assert doc.read_bytes().startswith(original)
print('Appended delivery section; original prefix preserved.')
