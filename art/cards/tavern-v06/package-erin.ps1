param([string]$ProjectRoot=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$helperPath=Join-Path $ProjectRoot 'art/cards/tavern-v02/package.ps1'
$helperText=[regex]::Match((Get-Content -LiteralPath $helperPath -Raw),"(?s)@'\r?\n(.*?)\r?\n'@").Groups[1].Value
Add-Type -ReferencedAssemblies System.Drawing.Common,System.Drawing.Primitives,System.Private.Windows.GdiPlus,System.Private.Windows.Core -TypeDefinition $helperText
New-Item -ItemType Directory -Force -Path (Join-Path $PSScriptRoot 'hand'),(Join-Path $PSScriptRoot 'before') | Out-Null
$previousFiles=@(@{Path='art/cards/tavern-v01/drunken_erin.png';Backup='before/art-v01.png'},@{Path='godot/assets/cards/drunken_erin.png';Backup='before/runtime.png'},@{Path='godot/assets/cards/hand/drunken_erin.png';Backup='before/hand.png'})
foreach($file in $previousFiles) { $backup=Join-Path $PSScriptRoot $file.Backup; if(-not (Test-Path -LiteralPath $backup)) { Copy-Item -LiteralPath (Join-Path $ProjectRoot $file.Path) -Destination $backup } }
$master=Join-Path $PSScriptRoot 'drunken_erin.png'
$image=[System.Drawing.Bitmap]::new($master)
if($image.Width -ne 1024 -or $image.Height -ne 1536 -or $image.GetPixel(0,0).A -ne 0 -or $image.GetPixel(512,768).A -ne 255) { throw 'Invalid final master' }
$small=[TavernCardPackaging]::Resize($image,256,384)
$smallPath=Join-Path $PSScriptRoot 'hand/drunken_erin.png'
$small.Save($smallPath,[System.Drawing.Imaging.ImageFormat]::Png)
foreach($dest in @('art/cards/tavern-v01/drunken_erin.png','godot/assets/cards/drunken_erin.png')) { Copy-Item -LiteralPath $master -Destination (Join-Path $ProjectRoot $dest) -Force }
Copy-Item -LiteralPath $smallPath -Destination (Join-Path $ProjectRoot 'godot/assets/cards/hand/drunken_erin.png') -Force
$verification=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'pixel-verification.json') -Raw | ConvertFrom-Json
[ordered]@{width=1024;height=1536;handWidth=256;handHeight=384;format='RGBA';masterSha256=(Get-FileHash -LiteralPath $master -Algorithm SHA256).Hash;handSha256=(Get-FileHash -LiteralPath $smallPath -Algorithm SHA256).Hash;mode='deterministic composition; no image generation';visualRarity='legendary';allPrintedTextRemoved=$true;originalPixelVerification=$verification} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'manifest.json') -Encoding utf8
$image.Dispose();$small.Dispose()
Write-Output 'PASS original master copied unchanged; hand resized; runtime assets updated'
