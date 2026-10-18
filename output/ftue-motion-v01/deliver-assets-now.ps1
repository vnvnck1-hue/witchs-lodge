$ErrorActionPreference='Stop'
$root=(Resolve-Path "$PSScriptRoot/../..").Path
$v=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/asset-verification.json"|ConvertFrom-Json
if(-not $v.passed){throw 'Asset verification failed'}
$status=@{succeeded=$false;own_export_exit_code=1;concurrent_export_process=32036;note='Asset delivery complete. Root executable final replacement is pending because other release exports target the same file; copying their temporary output was rejected by automatic approval review.'}
$v|Add-Member -NotePropertyName root_executable_export -NotePropertyValue $status -Force
ConvertTo-Json -InputObject $v -Depth 16|Set-Content -Encoding UTF8 "$PSScriptRoot/asset-verification.json"
$note=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/delivery-note.md"
$note=$note.Replace('{{CUT3_COUNT}}',[string]$v.continuation_protection.cut3_files_checked).Replace('{{CONCURRENT_COUNT}}',[string]$v.continuation_protection.concurrent_source_changes.Count)
$lines=$note -split "`r?`n"
$lines=@($lines|Where-Object {$_ -notmatch '^- 사용자 프로젝트 실행파일 통일 지침에 따라'})
$pending='- **실행파일 갱신 미확정:** 루트 `WitchsLodge.exe` 대상 공식 릴리스 내보내기는 PCK 완성 후 최종 임시 파일 교체에서 실패했다(종료 코드 1). 다른 카드 작업의 동일 경로 내보내기도 진행되어 해당 작업을 중단하지 않았다. 그 별도 프로젝트의 44 PNG·4 JSON이 이번 납품과 SHA-256까지 같음은 확인했다(`concurrent-export-assets.json`). 자동 승인 검토는 동시 내보내기 중 임시 실행파일 복사를 불완전·충돌 파일 위험으로 거절했다. 기존 실행파일을 최신으로 갱신했다고 주장하지 않는다. 게임 에셋 납품·임포트·검수는 위 결과대로 완료이며, 실행파일 교체는 동시 내보내기 종료 후 별도 확인이 필요하다.'
$note=($lines -join "`n")+"`n"+$pending+"`n"
[IO.File]::WriteAllText("$PSScriptRoot/delivery-note.md",$note,[Text.UTF8Encoding]::new($false))
$handoff=Join-Path $root 'docs/handoff/codex-prologue-motion-comics-v02.md'
if(-not [IO.File]::ReadAllText($handoff).Contains('## Codex 납품 결과 · 2026-10-18')){[IO.File]::AppendAllText($handoff,$note,[Text.UTF8Encoding]::new($false))}
Write-Output 'Asset delivery complete and handoff appended; executable status explicitly pending.'
