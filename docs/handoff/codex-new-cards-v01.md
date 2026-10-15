# Codex에게 요청하는 에셋 작업 — 신규 카드 4종 (v01)

요청자: Claude (게임 구현 담당) · 2026-10-15

## 역할 분담

- **Codex 책임:** 아래 카드 4종의 원화 생성·라운드 처리·패키징·검증·문서화.
- **Claude 책임:** 카드 규칙·게임 로직·`godot/assets/cards/catalog.json` 항목·월드 모델(새끼양·등불)·VFX 구현.
- **수정 금지:** `godot/scripts/**`, `godot/assets/cards/catalog.json`, `godot/scenes/**`. Claude가 동시에 이 파일들을 고치고 있다. 다른 작업의 변경을 되돌리지 말 것. 커밋하지 말 것(사용자가 정리한다).

## 반드시 따를 기존 기준

먼저 읽기: `art/cards/README.md`, `docs/prompts/cards/production-rounded-v02-prompts.md`, `art/cards/manifest.json`, `godot/tools/package_card_assets.gd`, `godot/tools/verify_card_assets.gd`, 그리고 기존 카드 `godot/assets/cards/axe_mercenary.png`·`wool.png`·`timber.png`·`forest_monster.png`.

- 기존 네 카드와 **같은 프레임·같은 비대칭 S자 포맷·같은 붓터치 원화 스타일·같은 한글 서체 느낌**. 한 세트로 보여야 한다.
- 네 모서리 살짝 둥글게, 카드 밖은 투명 알파. 배경색·그림자 합성 금지.
- 가격·체력·지속시간 같은 시험 수치는 그림에 넣지 않는다.
- 산출물:
  - 원화: `art/cards/rounded/<id>.png`
  - 게임용: `godot/assets/cards/<id>.png` (RGBA, 1024×1536)
  - 손패용: `godot/assets/cards/hand/<id>.png` (RGBA, 256×384)
- `package_card_assets.gd`·`verify_card_assets.gd`가 기존 4종 ID만 다루면 **새 ID 4개를 추가**해서 총 8종+뒷면을 검증하도록 갱신한다(이 두 도구 파일은 Codex가 수정해도 된다).
- `art/cards/manifest.json`(파일 목록·해시), `art/cards/README.md` 표, 프롬프트 기록 `docs/prompts/cards/new-cards-v01-prompts.md` 갱신.
- 검증 결과 `godot/assets/cards/verification.json` 갱신, 갤러리 `godot/screenshots/cards/asset-gallery.png` 재생성(8종).
- Godot 실행 파일: `.tools/Godot-4.7.2.exe`. 실행법은 `art/cards/README.md`의 "재생성과 확인" 절.

## 카드 4종 사양 (인쇄 문구는 이 글자 그대로)

| id | 카드 이름 | 분류 띠 | 인쇄 문구 (2줄) |
|---|---|---|---|
| `frost_rune` | 서리 룬 | 주문 · 마녀의 룬 | 적이나 땅에 새기면 터집니다. / 주변 적을 얼려 느리게 합니다. |
| `ward_lantern` | 수호 등불 | 설치물 · 마녀의 등불 | 땅에 놓으면 불을 밝힙니다. / 빛 안의 적은 느려집니다. |
| `guest_invitation` | 숙박 초대장 | 산장 · 손님 초대 | 산장에 놓으면 손님이 옵니다. / 낮에만 사용할 수 있습니다. |
| `lamb` | 새끼양 | 가축 · 목장 입식 | 목장에 놓으면 새끼양이 옵니다. / 이틀 뒤 어른 양이 됩니다. |

### 원화 내용

- **서리 룬:** 눈 덮인 땅에 새겨진 둥근 달 룬 문양이 차가운 청백색으로 빛나며 터지는 순간. 문양에서 서리 결정이 방사형으로 뻗고, 차가운 김이 피어오른다. 마녀의 손(보라 소매)이 살짝 걸쳐 있어도 좋다. 색: 청백·옅은 보라·눈빛.
- **수호 등불:** 굽은 나무 장대에 매단 연철 마녀 등불. 눈밭에 꽂혀 있고, 호박색과 연보라가 섞인 따뜻한 빛이 둥근 보호막처럼 퍼진다. 빛 가장자리 밖은 어두운 숲·안개. 나방 한두 마리.
- **숙박 초대장:** 달·전나무 문장의 밀랍 봉인이 찍힌 양피지 편지와 리본. 뒤로 창문에 불이 켜진 눈 덮인 산장 실루엣, 해 질 녘의 하늘. 따뜻하고 반기는 분위기.
- **새끼양:** 크림색 털이 몽글몽글한 작은 새끼양. 건초 위에 웅크리거나 막 일어서는 자세이고, 목에 작은 방울. 울타리 일부와 눈. 귀엽지만 기존 원화의 붓터치 톤을 유지한다(과한 치비 금지).

## 완료 기준

1. 4종 × (원화·1024×1536·256×384) = 12개 PNG가 위 경로에 있음.
2. 검증 도구가 8종+뒷면 모두 통과하고 `verification.json`에 기록.
3. 갤러리 PNG 갱신, README·manifest·프롬프트 문서 갱신.
4. 마지막 메시지에 생성 파일 목록과 검증 결과를 요약. 인쇄 문구 오탈자가 없는지 직접 확대해서 확인한 결과도 적는다.
