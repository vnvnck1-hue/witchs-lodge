# 회색 늑대인간 v03 — 몸과 꼬리 분리 시트

- 제작일: 2026-10-21 (Asia/Seoul).
- 요청서 `docs/handoff/codex-werewolf-witch-model-3q-v03.md`를 UTF-8로 읽고 수행했다.
- 실제 편집 입력: `art/concepts/characters/werewolf-witch-model-v02/werewolf-3q-b-v02.png`. `view_image`로 열람한 뒤 내장 `image_gen`의 `referenced_image_paths`에 이 파일을 직접 전달했다.
- 입력 SHA256: `6E9B026F2B60291A12665E334EA57CF2610D4881E21D108FC6AFC98905A909C3`.
- 도구: 내장 `image_gen` 편집 1회, `transparent_background=true`. CLI/API 대체 경로는 사용하지 않았다. 크기 조정·잘라내기·기존 픽셀 보존 합성·알파 검사에는 PowerShell + System.Drawing을 사용했다.
- 중세 기반 판타지, 중세의 생활감과 분위기를 유지하면서 판타지적 각색을 허용한다는 프로젝트 기준과 기존 가죽·천·버클·점토 무광 마감을 유지했다.
- 프로젝트 파일은 **이 v03 폴더 안에만** 생성했다. 기존 원화·docs·godot·실행파일 수정 및 커밋은 하지 않았다. 내장 도구가 자동 저장한 `$CODEX_HOME/generated_images/` 결과는 원래 위치에 두고, `raw/werewolf-split-generated.png`에 바이트 그대로 복사했다.

## 납품

| 파일 | 크기 | 내용 |
| --- | --- | --- |
| `werewolf-sheet-v03.png` | 2048×1536 RGBA | 왼쪽~가운데 꼬리 없는 몸, 오른쪽 완전히 분리된 꼬리 |
| `werewolf-body-v03.png` | 1536×1536 RGBA | 시트와 정확히 같은 몸, 원본 몸의 픽셀 배율·위치 유지 |
| `werewolf-tail-v03.png` | 1536×1536 RGBA | 시트와 정확히 같은 꼬리, 배율 변경 없이 가운데 배치 |
| `werewolf-v03-contact.png` | 1872×900 RGB | v02와 v03 시트를 50% 동일 배율로 나란히 비교 |
| `raw/werewolf-split-generated.png` | 1448×1086 | 내장 도구의 생성 원본, 수정 없이 보존 |

몸의 alpha>0 경계는 `[263,168,1362,1367)`이며 높이 1199px이다. 원본 몸을 확대·축소·이동하지 않았다. 시트의 꼬리 경계는 `[1471,951,1949,1242)`이고, 몸의 가장 오른쪽 경계 1362와 꼬리의 가장 왼쪽 경계 1471 사이에는 **109개의 완전히 투명한 열**이 있다. 마지막 몸 픽셀 x1361과 첫 꼬리 픽셀 x1471 사이의 좌표 차는 110px이다. 팔·다리 사이 기존 여백을 유지했다.

## 몸 유지와 국소 편집 방법

1. 내장 도구로 꼬리 없는 몸과 분리된 꼬리를 생성했다. 생성 도구는 요청한 2048×1536 대신 1448×1086 원본을 반환했다. 생성 원본은 보존하고 최종 파일을 정확한 요구 치수로 구성했다.
2. 생성 몸을 원본과 정합했다. 정합 배율은 1.2800, 이동량은 `(175,13)`이며 이는 **생성 패치를 원본 좌표로 맞추는 값**이다. 납품 몸 전체를 이 배율로 바꾼 것이 아니다.
3. v02 원본의 BGRA 픽셀을 그대로 기반으로 삼았다. 꼬리 제거·왼쪽 엉덩이/허벅지 뒤의 복원·해당 경계 알파 정리는 보수적으로 잡은 국소 범위 `x<710, 890≤y<1300` 안에서만 했다. 꼬리와 왼손은 원본 알파 연결을 구분해 꼬리만 제거했다. 생성 패치의 엉덩이·다리 외곽을 적용하고 안쪽은 원본 픽셀로 부드럽게 이어 붙였다.
4. 이 범위 **밖의 BGRA 픽셀 변경은 0개**이며 가시 픽셀 651,748개를 완전히 보존했다. 머리·얼굴·갈기·상체·망토·오른쪽 몸 전체, 검사한 왼손 불투명 영역과 두 발은 원본과 채널 단위로 일치했다. 국소 범위 안의 총 변경 픽셀은 93,364개이며 꼬리 제거로 투명해진 픽셀과 경계 정리를 포함한다.
5. 외곽 2px 범위의 안티에일리어싱만 남기고 본체 안쪽은 alpha255, 바깥은 alpha0으로 검사했다. 미세 경계 RGB도 정리했다. 원본 전체를 재생성한 그림으로 대체하지 않았다.
6. 시트와 단독 파일은 완성된 동일한 몸·꼬리 RGBA 배열을 복사하여 구성했다. 시트/몸 및 시트/꼬리 픽셀 비교 차이는 각각 0이다. 몸과 꼬리의 의미 있는 불투명 실루엣 연결 성분은 각각 1개, 시트는 2개다.

시트·몸·꼬리·비교판을 `view_image`로 직접 열어 검수했다. 꼬리 자체가 몸에 남지 않고, 복원된 엉덩이·허벅지가 회색 털 덩어리로 마감되어 있다. 분리 꼬리는 회색 뿌리가 왼쪽, 크림색 끝이 오른쪽 위로 휘는 측면 형태다.

## 꼬리 크기 측정과 한계

- 최종 꼬리 처리 캔버스는 480×293px, 실제 alpha>0 경계는 **478×291px**이다. 몸과 같은 1:1 픽셀 기준으로 시트와 단독 파일에 넣었다. 생성 꼬리 원본의 잘라낸 경계는 429×262px이며 종횡비를 유지했다.
- v02의 굽은 꼬리는 기저부 일부가 다리 뒤에 가려져 있어 단순 가로폭으로 길이를 비교하지 않았다. 뿌리~끝의 가시 중심선을 수동 표본점으로 근사했다. 원본은 약 **546px**, 최종 꼬리는 약 **546px**이며 대략 같은 크기가 되도록 설정했다. 세부 표본 좌표와 계산은 `raw/verification-report.txt`와 검수 스크립트에 보존했다. 소수점 수치는 계산 기록일 뿐 측정 정확도를 뜻하지 않는다.
- 꼬리의 회색·크림색 배색, 큰 털 덩어리와 무광 점토 재질을 유지했으나, 별도 측면으로 펼친 꼬리는 생성형 재구성이다. 털 덩어리의 미세 굴곡과 조명은 원본 꼬리의 픽셀 복제와 다르다.
- 중심선 측정은 2D 화면상의 수동 추정이다. 가려진 뿌리·깊이·원근을 포함한 실제 3D 길이를 증명하지 못한다. 몸과 꼬리를 별도 3D 생성한 뒤에는 Tripo 또는 DCC에서 연결부와 축척을 확인해야 한다. 이번 결과는 3D 메시·정밀 치수 도면이 아니다.
- 몸은 대부분 원본 픽셀을 보존했지만, 제거·복원 구역 내부의 엉덩이/허벅지 외곽과 안티에일리어싱은 달라졌다. 그 부위까지 픽셀 단위로 동일하다는 의미는 아니다.

## 원본·재현 파일

- `raw/prompt-01.txt`: 실제 전송한 프롬프트 전문.
- `raw/prepare-deliverables.ps1`: 정합, 국소 합성, 크기 정리, 비교판 생성 및 알파 검사.
- `raw/verify-deliverables.ps1`: 연결 성분, 시트/단독 픽셀 비교, 원본 보존 영역, 꼬리 길이 추정, 기존 입력 해시 검증.
- `raw/preparation-report.txt`, `raw/alpha-report.txt`, `raw/verification-report.txt`: 실제 검사 결과.
- `raw/protected-input-hashes.json`: 요청서·기준 문서·기존 v01/v02 파일의 작업 시작 해시. 24개 모두 마지막 검사에서 일치했다.
- `raw/input-tail-detail.png`, `raw/input-hip-grid.png`, `raw/body-aligned-preview.png`: 원본 부분 확대·좌표 확인·생성 패치 정합용 참고 파일. 최종 납품 시트와 구분한다.

## 실제 프롬프트 전문

```text
Use case: precise-object-edit.
Asset type: Witch's Lodge 3D modeling reference sheet, separated body and tail.
Image 1 is the ACTUAL EDIT TARGET, approved werewolf-3q-b-v02.png. Open and edit this image itself. Preserve its body EXACTLY: same face, forelock, mane clumps, lavender eyes, cream muzzle/chest/belly/toes, slate gray fur, purple torn shoulder cloak, brown leather belt, gold buckle, cream hanging cloth, chunky muscular anatomy, empty hands, separated limbs, crouched pose, 3/4 camera, matte sculpted clay material, colors and studio lighting. Medieval-based fantasy, retaining medieval everyday atmosphere while allowing fantasy stylization.
ONLY CHANGE: detach the tail from the werewolf and display it separately to the right. Remove the ENTIRE existing low left-pointing tail, including all cream tail-tip shapes. Reconstruct only the previously occluded small area behind the left thigh/hip with natural gray fur clumps. No tail remains on body, no long stump. Keep the rest of body unchanged.
COMPOSITION: transparent LANDSCAPE canvas 2048 x 1536. Preserve the original body's pixel size and position from the 1536 square source, do not zoom or scale it; original ears top about y168, feet bottom y1367, right hand x1362. Body occupies left and center. Isolated tail occupies right, completely separate, with at least 100 transparent pixels between it and every body pixel.
TAIL: same original bushy sculpted gray tail with pale cream tip, same thickness and real-world attached size; about 500 pixels long and 260 pixels high at the body's original scale. Show the full tail side-on, root at LEFT, cream tip at RIGHT curling slightly UP. Root is rounded gray fur, not a wound. Tail tip has large smooth cream fur clumps like original. Position the tail on the far right in the lower-right clear area, roughly x1470 to1990, y950 to1250. It must not touch, overlap or hide any body part.
Exactly one full tailless body and exactly one detached tail. No extra views, no duplicate body, no labels, no text, no measurement lines, no watermark, no floor, no cast shadow. Genuinely transparent alpha background, opaque subject alpha255, outside alpha0, only 1-2px contour antialiasing. Do not paint a checkerboard. Keep all ears, hands, feet and tail fully inside generous transparent margins.
```

## 실제 알파 검사
```text
werewolf-sheet-v03.png: 2048x1536; bbox={X=263,Y=168,Width=1686,Height=1199}; alpha0=2338645; alpha255=773835; alpha1to254=33248; partial_outside_2px_boundary=0; corners=0/0/0/0
werewolf-body-v03.png: 1536x1536; bbox={X=263,Y=168,Width=1099,Height=1199}; alpha0=1634811; alpha255=696638; alpha1to254=27847; partial_outside_2px_boundary=0; corners=0/0/0/0
werewolf-tail-v03.png: 1536x1536; bbox={X=529,Y=622,Width=478,Height=291}; alpha0=2276698; alpha255=77197; alpha1to254=5401; partial_outside_2px_boundary=0; corners=0/0/0/0
```

## SHA256
generation.md 자체와 해시 목록 파일은 자기 참조를 피하기 위해 표에서 제외한다.

| 파일 | SHA256 |
| --- | --- |
| `werewolf-body-v03.png` | `20C33A398D41BC1862126CA1C236B9452964DA9C7A450E5A5E4D6FC05F983083` |
| `werewolf-sheet-v03.png` | `58C0822436911B4CA694D4F9A69F30BA4BB482C0A262E1365EC249F258502432` |
| `werewolf-tail-v03.png` | `D559F1F6C7E0A621B65B6AC84EB5D742172BA20D7FF1C092E53F52A03B2E9853` |
| `werewolf-v03-contact.png` | `9F6187661E42EE793585010F42E750522466DF71569F744A0CB22ACD6DFEF914` |
| `raw/alpha-report.txt` | `3D459B07FF7A45931A004C32A84E2D465E475F6E6CFE88FFFD0A5D6B8D5B0ABB` |
| `raw/body-aligned-preview.png` | `7DA1EA52997D997FC27A59817D6E5A3F12BD67E804DA80299B2F03CE21462306` |
| `raw/input-hip-grid.png` | `AE6F87B3A02A154DDBBE24B64DD4FF36C93AD8CAF211F4031F7A16A30FB53192` |
| `raw/input-tail-detail.png` | `715F0C397F714E06CC255A96E7EE9127B5FD87A15D9E929FD3A3B146615EB0ED` |
| `raw/preparation-report.txt` | `D780BDB76F50CDAC1E1289470F4C9B95F7255077F5D3D0095B7D4AC82F0E42EA` |
| `raw/prepare-deliverables.ps1` | `21E5F097783FBFE207112D59BEBFDBC7BD5ED9782C4F740064F9861D7A604661` |
| `raw/prompt-01.txt` | `5E152655E9AA1DFEC6C68AEC5614062F7C2010D3DCC61E2986A3D4721AF37F37` |
| `raw/protected-input-hashes.json` | `18534F3E2A5CE2242FAEE43CC26C3E063D17E051B536A835A38735E4D89D55F7` |
| `raw/verification-report.txt` | `19155BAF708EF11098181F80E9A3918E97DA22F69F4BA1A72D284B503427BFE8` |
| `raw/verify-deliverables.ps1` | `A044FE4FCC38E1F7B441727E4ED6BAD59263817A15E265D328EF9D0BA13582A3` |
| `raw/werewolf-split-generated.png` | `CB9AC14A892559F5E1FABA4065820AC986FFA0B596982498C23B2F3C145FF085` |
