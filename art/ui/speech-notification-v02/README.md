# 말 걸기 말풍선 v02

작업 기준: `docs/handoff/codex-speech-notification-v02.md` (2026-10-22).
중세 기반 판타지의 따뜻한 양피지, 짙은 자두색 먹선, 가는 보라색 외곽 빛을 시안과 직접 대조해 제작했다.

## 최종 산출물

| 파일 | 크기 / 형식 | 용도 |
| --- | --- | --- |
| `godot/assets/ui/moon_runes/common/speech_paper.png` | 768×256 / RGBA8 | 글자·꼬리·꺾쇠 없는 몸통 |
| `godot/assets/ui/moon_runes/common/speech_paper_tail.png` | 96×96 / RGBA8 | 왼쪽 꼬리, 오른쪽은 먹선 없는 종이 겹침부 |
| `godot/assets/ui/moon_runes/common/speech_chevron.png` | 64×64 / RGBA8 | 원본 시안에서 분리한 가는 꺾쇠 |
| `sheet.png` | 1800×1940 | 시안 3배 발췌, 같은 크기 합성, 눈밭, 확대, 접합부 대조 |
| `validation.json` | JSON | 최종 PNG 크기·알파·종이 결·꼬리 겹침부 검사 |
| `prompts.md` | Markdown | 실제 이미지 편집 입력과 프롬프트, 후처리 기록 |

## 원본 보존과 수정

- `docs/handoff/refs/speech-bubble-concept-crop3x.png`를 내장 imagegen 도구의 **실제 편집 입력**으로 사용했다. 생성 원본은 `drafts/01-imagegen-blank-body.png`에 보존했다. 별도 API/CLI 생성은 사용하지 않았다.
- 생성본 전체를 그대로 축소하면 시안과 먹선·색·종이 결이 달라져, 최종 외곽에는 시안 픽셀을 우선 사용했다. 초상에 가려진 왼쪽 경계는 시안 오른쪽 외곽을 반사해 복원했다. 완전한 픽셀 동일 복사는 아니며, 글자 삭제·독립 PNG 분리·9분할에 필요한 부분을 복원한 결과다.
- 종이 중앙색은 시안의 깨끗한 종이 영역을 기준으로 `#F6E0B9` 부근에 맞췄다. 생성본에서 큰 음영·방향성 결을 제거하고 미세한 색소 결만 반영했다. 중앙 RGB 평균은 약 `(246, 224, 185)`, 표준편차는 약 `(0.7, 1.3, 2.3)`이다.
- 먹선과 가장자리의 황토색 비네트는 시안에서 복원했다. 먹선 바깥 보라색 알파는 6px 이내에서 끝나고, 그 밖은 alpha 0이다. 글자와 오른쪽의 작은 검은 점은 제거했다.
- 꺾쇠는 원본의 실제 먹선 실루엣을 추출했다. 첫 추출의 가로 확대를 수정해 시안의 가늘고 세로로 긴 비율을 유지했다.
- 꼬리는 시안의 짧은 왼쪽 삼각형 비율과 먹선 색에 맞춰 분리했다. 겹침부의 사각 흔적을 없애도록 경사 실루엣·종이색·알파를 다듬었다. `x60~95`의 보이는 픽셀에는 먹선이 없다. 오른쪽 캔버스 끝까지 종이가 이어지는 것은 **열린 겹침부의 의도된 구조**다.

## 합성 및 9분할 정보

- 몸통의 9분할 여백은 상하좌우 **40px**이다. 중앙 `x40~727, y40~215`는 불투명 종이 결만 있다.
- 검수 시트의 같은 크기 합성은 몸통을 958×290으로 9분할 렌더링하고 꼬리와 꺾쇠를 합쳤다. 실제 조립 PNG는 `drafts/02-composite-reference-size.png`다.
- 조립 기준: 몸통 좌상단 `(52,0)`, 꼬리 좌상단 `(0, 몸통높이/2-48)`, 꺾쇠 좌상단 `(몸통너비-74, 몸통높이/2-32)`. 즉 꼬리의 오른쪽 44px가 몸통 왼쪽과 겹친다. 원점은 전체 합성 캔버스 기준이다. 이는 검수용 픽셀 좌표이며 게임 레이아웃 수정은 하지 않았다.
- 가로 2배·세로 1.5배 검수는 몸통 **1536×384**, 모서리 여백 40px 유지 상태다. `drafts/03-ninepatch-2x-1_5x.png`에는 축소 없는 합성을 보존했다. 시트에서도 같은 확대 합성을 보여 준다.
- 눈밭 배경은 지정된 `godot/screenshots/speech-notification/1-graz-full.png`에서 기존 알림 바로 위의 가려지지 않은 영역 `(190,233)`부터 폭 400px·높이 73px를 발췌했다. 기존 알림이 덮은 배경은 복구할 수 없으므로 이 인접 영역을 반사 연장해 **검수 시트 안에서만** 합성했다. 원본 스크린샷은 수정하지 않았다.

## 검수 기록

1. 시안 3배 발췌와 같은 외곽 크기의 새 합성, 글자 없는 종이 영역을 확인했다.
2. 첫 후처리에서 생긴 외곽 단차·큰 세로 결·꼬리의 사각 색차를 수정했다. 중간 시트는 `drafts/04-review-before-refinement.png`에 남겼다.
3. 꼬리 접합부 3배 확대와 밝은 눈밭 합성을 확인했다.
4. 40px 9분할로 1536×384까지 늘려 중앙에 큰 얼룩·접힘·굵은 방향성 무늬가 생기지 않는지 확인했다.
5. 자동 검사는 지정 크기·RGBA8, 캔버스 외곽 alpha 0(꼬리 오른쪽 열린 겹침부 제외), 투명 픽셀 RGB 정리, 중앙 불투명도·작은 색 변화, 꼬리 겹침부의 먹선 부재를 검사한다. 결과는 `validation.json`을 따른다.

## 작업 범위 및 동시 변경

이번 제작에서 쓴 경로는 위의 게임용 PNG 3장과 `art/ui/speech-notification-v02/`뿐이다. 수정 금지 경로에는 쓰지 않았다. Godot 실행·임포트·내보내기·게임 스크립트 연결·커밋은 하지 않았다.

수정 금지 경로 1,358개 파일의 SHA-256을 작업 중 기록하고 대조했다. 대조 시점에 아래 5개 파일이 외부 작업으로 변경된 사실이 감지되었다. 이 제작의 도구 호출에는 해당 파일 쓰기가 없으며, 동시 작업의 변경은 되돌리지 않았다. 원본 해시는 `drafts/protected-before.json`, 관측 결과는 `protected-audit.json`에 보존했다. 이 기록은 해당 경로를 수정했다는 뜻이 아니라, 공유 작업 공간의 전후 해시 관측이다.

- `godot/scripts/ui/speech_medal.gd`
- `godot/scripts/world/grass_meadow.gd`
- `godot/shaders/grass_wind.gdshader`
- `docs/grass-wind.md`
- `WitchsLodge.exe`

## 재현

프로젝트 루트에서 실행한다. Node.js와 Windows PowerShell의 System.Drawing만 사용하며, Godot은 실행하지 않는다.

```powershell
node art/ui/speech-notification-v02/drafts/build.cjs
& ([scriptblock]::Create((Get-Content -LiteralPath 'art/ui/speech-notification-v02/drafts/label-sheet.ps1' -Raw -Encoding UTF8)))
node art/ui/speech-notification-v02/drafts/verify.cjs
```

`build.cjs`는 지정된 v02 게임용 PNG와 제작 폴더만 갱신한다. `--audit-only`는 수정 금지 파일을 읽어 해시만 비교하고 이 폴더에 결과를 저장한다.
