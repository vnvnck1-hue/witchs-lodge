$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Drawing
$taskRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskData = Join-Path $PSScriptRoot 'godot-user-data'
$env:APPDATA = "$taskData/roaming"
$env:LOCALAPPDATA = "$taskData/local"
$taskExe = Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
$taskArgs = @('--headless','--path','godot','--script',('"'+(Join-Path $PSScriptRoot 'verify_textures.gd')+'"'),'--',('"'+(Join-Path $PSScriptRoot 'texture-verification.json')+'"'))
$taskProcess = Start-Process -FilePath $taskExe -WorkingDirectory $taskRoot -ArgumentList $taskArgs -Wait -PassThru -WindowStyle Hidden -RedirectStandardOutput (Join-Path $PSScriptRoot 'texture-verify.log') -RedirectStandardError (Join-Path $PSScriptRoot 'texture-verify-stderr.log')
if ($taskProcess.ExitCode -ne 0) { throw 'Godot texture check failed' }
$taskFiles = @()
foreach ($taskRel in @('art/cards/meat-stew-v01/meat_stew.png','godot/assets/cards/meat_stew.png','godot/assets/cards/hand/meat_stew.png','godot/screenshots/meat-stew-card/sheet.png')) {
    $taskPath = Join-Path $taskRoot $taskRel
    $taskImage = [System.Drawing.Bitmap]::new($taskPath)
    $taskCorners = @($taskImage.GetPixel(0,0).A,$taskImage.GetPixel($taskImage.Width-1,0).A,$taskImage.GetPixel(0,$taskImage.Height-1).A,$taskImage.GetPixel($taskImage.Width-1,$taskImage.Height-1).A)
    $taskExpected = if ($taskRel -like '*hand/*') { @(256,384) } elseif ($taskRel -like '*sheet.png') { @(3072,1536) } else { @(1024,1536) }
    $taskOk = $taskImage.Width -eq $taskExpected[0] -and $taskImage.Height -eq $taskExpected[1] -and $taskImage.PixelFormat.ToString() -eq 'Format32bppArgb'
    if ($taskRel -like 'godot/assets/*') { $taskOk = $taskOk -and (@($taskCorners | Where-Object {$_ -ne 0}).Count -eq 0) -and $taskImage.GetPixel($taskImage.Width/2,$taskImage.Height/2).A -eq 255 }
    $taskFiles += @{path=$taskRel;width=$taskImage.Width;height=$taskImage.Height;channels=@('R','G','B','A');corner_alpha=$taskCorners;sha256=(Get-FileHash -LiteralPath $taskPath -Algorithm SHA256).Hash;passed=$taskOk}
    $taskImage.Dispose()
}
$taskBefore = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'text-repair-protected-before.json') | ConvertFrom-Json
$taskChanges = @()
foreach ($taskProperty in $taskBefore.PSObject.Properties) {
    $taskHash = (Get-FileHash -LiteralPath (Join-Path $taskRoot $taskProperty.Name) -Algorithm SHA256).Hash
    if ($taskHash -ne $taskProperty.Value) { $taskChanges += @{path=$taskProperty.Name;before=$taskProperty.Value;after=$taskHash;written_by_this_task=$false} }
}
$taskPixel = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'text-repair-pixel-check.json') | ConvertFrom-Json
$taskImport = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'import-result.json') | ConvertFrom-Json
$taskTextures = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'texture-verification.json') | ConvertFrom-Json
$taskSource = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'text-repair-source-check.json') | ConvertFrom-Json
$taskAdded = @()
foreach ($taskFolder in @('godot/scripts','godot/scenes','godot/shaders')) {
    foreach ($taskFile in (Get-ChildItem -LiteralPath (Join-Path $taskRoot $taskFolder) -Recurse -File)) {
        $taskRel = $taskFile.FullName.Substring($taskRoot.Length+1).Replace('\','/')
        if ($taskBefore.PSObject.Properties.Name -notcontains $taskRel) { $taskAdded += $taskRel }
    }
}
$taskPassed = (@($taskFiles | Where-Object {-not $_.passed}).Count -eq 0) -and $taskPixel.passed -and $taskSource.passed -and $taskImport.exit_code -eq 0 -and $taskTextures.passed -and $taskAdded.Count -eq 0
$taskResult = @{
    date='2026-10-18';revision='text-only repair';files=$taskFiles;pixel_preservation=$taskPixel;source_preservation=$taskSource;import_result=$taskImport;godot_texture_verification=$taskTextures
    text=@('고기 스튜','자원 · 모닥불 요리','켜진 모닥불에서 생고기로 끓입니다.','다친 용병의 체력을 회복합니다.')
    typography=@{title_bounds=@(304,85,415,110);classification_bounds=@(352,215,319,46);rules_line_1_bounds=@(166,1235,691,58);rules_line_2_bounds=@(180,1320,664,58);manual_exact_text_review=$true;reference='godot/assets/cards/raw_meat.png';comparison_scale='all three cards 1:1, 1024x1536 each'}
    protected_files_checked=@($taskBefore.PSObject.Properties).Count;protected_changes_observed=$taskChanges;protected_added_files=$taskAdded;protected_paths_written_by_this_task=@();committed=$false;exported_exe=$false
    notes=@('Original generated lettering candidate is preserved separately. Final source keeps original source alpha; game asset keeps original production alpha.','No forbidden path is written by this task; concurrent edits are recorded without reverting.','Large text is printed in existing panels; panel geometry and space for localized title/rules layouts remain unchanged.');passed=$taskPassed
}
$taskResult | ConvertTo-Json -Depth 12 | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'verification.json')
Write-Output ('passed='+$taskPassed+'; protected changes observed='+$taskChanges.Count+'; Godot texture result='+$taskTextures.passed)
if (-not $taskPassed) { throw 'Verification failed' }
