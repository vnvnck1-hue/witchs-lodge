param([string]$ProjectRoot=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$helperPath=Join-Path $ProjectRoot 'art/cards/tavern-v02/package.ps1'
$helperText=[regex]::Match((Get-Content -LiteralPath $helperPath -Raw),"(?s)@'\r?\n(.*?)\r?\n'@").Groups[1].Value
Add-Type -ReferencedAssemblies System.Drawing.Common,System.Drawing.Primitives,System.Private.Windows.GdiPlus,System.Private.Windows.Core -TypeDefinition $helperText
$source=Join-Path $PSScriptRoot 'generated.png'
$master=Join-Path $PSScriptRoot 'beastfolk-gatherer.png'
$handPath=Join-Path $PSScriptRoot 'hand/gatherer.png'
$image=[System.Drawing.Bitmap]::new($source)
$mask=[System.Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'before/gatherer.png'))
if($image.Width -ne 1024 -or $image.Height -ne 1536) { throw 'Unexpected generated image dimensions' }
# Production alpha packaging only: retain generated RGB, use existing card silhouette.
[TavernCardPackaging]::ApplyExistingAlpha($image,$mask)
$image.Save($master,[System.Drawing.Imaging.ImageFormat]::Png)
$small=[TavernCardPackaging]::Resize($image,256,384)
$small.Save($handPath,[System.Drawing.Imaging.ImageFormat]::Png)
Copy-Item -LiteralPath $master -Destination (Join-Path $ProjectRoot 'godot/assets/cards/races/beastfolk/gatherer.png') -Force
Copy-Item -LiteralPath $handPath -Destination (Join-Path $ProjectRoot 'godot/assets/cards/races/beastfolk/hand/gatherer.png') -Force
$records=@()
foreach($relative in @('art/cards/momi-curvy-v02/beastfolk-gatherer.png','art/cards/momi-curvy-v02/hand/gatherer.png','godot/assets/cards/races/beastfolk/gatherer.png','godot/assets/cards/races/beastfolk/hand/gatherer.png')) {
  $path=Join-Path $ProjectRoot $relative
  $bitmap=[System.Drawing.Bitmap]::new($path)
  $corners=@($bitmap.GetPixel(0,0).A,$bitmap.GetPixel($bitmap.Width-1,0).A,$bitmap.GetPixel(0,$bitmap.Height-1).A,$bitmap.GetPixel($bitmap.Width-1,$bitmap.Height-1).A)
  if(($corners | Where-Object { $_ -gt 12 }).Count -ne 0 -or $bitmap.GetPixel([int]($bitmap.Width/2),[int]($bitmap.Height/2)).A -ne 255) { throw "Alpha validation failed: $relative" }
  $records += [ordered]@{path=$relative;width=$bitmap.Width;height=$bitmap.Height;format='RGBA';cornerAlpha=$corners;centerAlpha=255;sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash}
  $bitmap.Dispose()
}
[ordered]@{date='2026-10-20';character='momi';method='built-in image_gen edit; original card alpha restored; hand resized only';prompt='docs/prompts/cards/momi-curvy-v02.md';passed=$true;files=$records} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'manifest.json') -Encoding utf8
$image.Dispose();$mask.Dispose();$small.Dispose()
Write-Output 'PASS master and hand packaged; runtime updated; dimensions and alpha verified'
