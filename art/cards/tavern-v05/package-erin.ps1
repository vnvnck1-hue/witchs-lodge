param([string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$helperPath=Join-Path $ProjectRoot 'art/cards/tavern-v02/package.ps1'
$helperText=[regex]::Match((Get-Content -LiteralPath $helperPath -Raw),"(?s)@'\r?\n(.*?)\r?\n'@").Groups[1].Value
Add-Type -ReferencedAssemblies System.Drawing.Common,System.Drawing.Primitives,System.Private.Windows.GdiPlus,System.Private.Windows.Core -TypeDefinition $helperText
$record=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'erin-final-prompt.json') -Raw | ConvertFrom-Json
New-Item -ItemType Directory -Force -Path (Join-Path $PSScriptRoot 'sources'),(Join-Path $PSScriptRoot 'before'),(Join-Path $PSScriptRoot 'hand') | Out-Null
Copy-Item -LiteralPath $record.source -Destination (Join-Path $PSScriptRoot 'sources/drunken_erin.png') -Force
Copy-Item -LiteralPath $record.selectedReference -Destination (Join-Path $PSScriptRoot 'sources/approved-legendary-concept.png') -Force
$previousFiles=@(@{Path='art/cards/tavern-v01/drunken_erin.png';Backup='before/art-v01.png'},@{Path='godot/assets/cards/drunken_erin.png';Backup='before/runtime.png'},@{Path='godot/assets/cards/hand/drunken_erin.png';Backup='before/hand.png'})
foreach($file in $previousFiles) { $backup=Join-Path $PSScriptRoot $file.Backup; if(-not (Test-Path -LiteralPath $backup)) { Copy-Item -LiteralPath (Join-Path $ProjectRoot $file.Path) -Destination $backup } }
$sourceImage=[System.Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'sources/drunken_erin.png'))
$mask=[System.Drawing.Bitmap]::new((Join-Path $ProjectRoot 'godot/assets/cards/dark_ale.png'))
$card=[TavernCardPackaging]::Resize($sourceImage,1024,1536)
[TavernCardPackaging]::ApplyExistingAlpha($card,$mask)
$master=Join-Path $PSScriptRoot 'drunken_erin.png'
$card.Save($master,[System.Drawing.Imaging.ImageFormat]::Png)
$small=[TavernCardPackaging]::Resize($card,256,384)
$smallPath=Join-Path $PSScriptRoot 'hand/drunken_erin.png'
$small.Save($smallPath,[System.Drawing.Imaging.ImageFormat]::Png)
foreach($dest in @('art/cards/tavern-v01/drunken_erin.png','godot/assets/cards/drunken_erin.png')) { Copy-Item -LiteralPath $master -Destination (Join-Path $ProjectRoot $dest) -Force }
Copy-Item -LiteralPath $smallPath -Destination (Join-Path $ProjectRoot 'godot/assets/cards/hand/drunken_erin.png') -Force
[ordered]@{width=$card.Width;height=$card.Height;handWidth=$small.Width;handHeight=$small.Height;cornerAlpha=$card.GetPixel(0,0).A;centerAlpha=$card.GetPixel(512,768).A;sha256=(Get-FileHash -LiteralPath $master -Algorithm SHA256).Hash;mode='built-in image_gen';title='술 주정뱅이 에린'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'manifest.json') -Encoding utf8
if($card.Width -ne 1024 -or $card.Height -ne 1536 -or $small.Width -ne 256 -or $small.Height -ne 384 -or $card.GetPixel(0,0).A -ne 0 -or $card.GetPixel(512,768).A -ne 255) { throw 'Invalid card packaging' }
$sourceImage.Dispose();$mask.Dispose();$card.Dispose();$small.Dispose()
Write-Output 'PASS legendary Erin final: 1024x1536 RGBA + 256x384; runtime assets replaced'


