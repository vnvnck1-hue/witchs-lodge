# 카드 인쇄 글자 제거 (card_text_strip)

카드 PNG에 그려진 제목·분류·설명·종족 이름표 글자를 **이미지 생성 없이** 지운다. 게임에서 글자를
`catalog.json`의 `name`·`category`·`printed_rules`로 직접 그리기 위한 빈 카드 바탕을 만든다.

## 원리

모든 카드는 글자가 **평평한 크림색 판 위의 검은 잉크**라는 공통점이 있다(프레임 모양은 카드마다 달라도 됨).

1. 카드별 크림색을 설명판에서 표본으로 잡고, 크림 픽셀 마스크를 만든다.
2. **크림에 완전히 둘러싸인 구멍 = 글자.** 프레임 선·그림 창은 바깥과 이어져 있어서 구멍이 아니다.
   - 판은 넓이가 충분하고 픽셀 60% 이상이 제목(y 20–420)·설명(y 1150–1525) 높이에 있는 크림 덩어리만 인정한다
     → 그림 속 양털·눈은 판이 아니다.
3. 프레임 테두리에 닿은 글자는 판 외곽의 '글자 크기 홈'으로 찾는다(글자 줄과 같은 높이일 때만).
4. 종족 이름표(인간·드워프 등)는 가운데·폭 150–420px·무채색 잉크일 때만 지운다 → 색 있는 배지 아이콘은 보존.
5. 글자 옆 옅은 그림자까지 포함해, 마스크 밖 주변 크림의 국소 평균(그라데이션 유지)과 같은 세기의 결로 채운다.

알파 채널은 건드리지 않는다. 원본은 덮어쓰지 않는다.

## 사용

```text
python tools/card_text_strip/strip_card_text.py godot/assets/cards/*.png --out output/card-text-strip-v01/cards --masks output/card-text-strip-v01/masks
python tools/card_text_strip/verify_strip.py      # 마스크 밖·알파 변화가 0인지 133장 검사
```

카드마다 로그에 `art_px_changed`(그림 띠에서 바뀐 픽셀, 0이어야 정상)가 찍힌다.
자동 검출이 놓친 카드가 생기면 `--overrides overrides.json`(`{"카드id": [[x,y,w,h], ...]}`, 1024×1536 기준)으로
사각형 안의 진한 잉크를 추가로 지운다. 2026-10-20 기준 133장 전체에서 수동 보정은 필요 없었다.

## 적용 상태 (2026-10-20)

게임 에셋 `godot/assets/cards/` 133장을 글자 없는 버전으로 교체했고, 글자는 게임이 실제 텍스트로 그린다
([docs/card-text-runtime.md](../../docs/card-text-runtime.md)). 전환 전 원본은 `output/card-text-strip-v01/before/`.
같은 폴더의 `measure_plates.py` 는 빈 카드에서 글자판 프로파일(`godot/assets/cards/text_layout.json`)을,
`compare_text_size.py` 는 원본 글자와 렌더 글자의 줄 높이 비교를 만든다.

## 새 카드

새로 만드는 카드는 처음부터 글자 없이 생성하는 편이 낫다. 기존 포맷 카드를 받았을 때는 이 스크립트로 처리한다.
