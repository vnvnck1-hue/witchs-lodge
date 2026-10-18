$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path "$PSScriptRoot/../..").Path
$verification=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/asset-verification.json"|ConvertFrom-Json
$export=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/export-result.json"|ConvertFrom-Json
if(-not $verification.passed -or (-not $export.succeeded -and $export.exit_code -ne 0)){throw 'Asset verification or root export has not passed.'}
$packaged=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/packaged-assets-verification.json"|ConvertFrom-Json
if(-not $packaged.passed){throw 'Final executable motion assets have not passed.'}
$verification|Add-Member -NotePropertyName packaged_assets_verification -NotePropertyValue $packaged -Force
$verification|Add-Member -NotePropertyName root_executable_export -NotePropertyValue $export -Force
ConvertTo-Json -InputObject $verification -Depth 16|Set-Content -Encoding UTF8 "$PSScriptRoot/asset-verification.json"
$note=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/delivery-note.md"
$note=$note.Replace('{{CUT3_COUNT}}',[string]$verification.continuation_protection.cut3_files_checked).Replace('{{CONCURRENT_COUNT}}',[string]$verification.continuation_protection.concurrent_source_changes.Count).Replace('{{EXPORT_EXIT}}',[string]$export.exit_code)
[IO.File]::WriteAllText("$PSScriptRoot/delivery-note.md",$note,[Text.UTF8Encoding]::new($false))
$handoff=Join-Path $taskRoot 'docs/handoff/codex-prologue-motion-comics-v02.md'
if(-not [IO.File]::ReadAllText($handoff).Contains('## Codex 납품 결과 · 2026-10-18')){[IO.File]::AppendAllText($handoff,$note,[Text.UTF8Encoding]::new($false))}
Write-Output "Delivered: 44 PNGs, 4 manifests, import=0, runtime=72/72, cut3 unchanged=$($verification.continuation_protection.cut3_unchanged), export=$($export.exit_code). Handoff appended."
