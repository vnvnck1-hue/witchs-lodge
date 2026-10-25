$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -Path (Join-Path $PSScriptRoot 'package.cs') -ReferencedAssemblies System.Drawing
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$ids=@('frost_crown','lich_crown','wild_grimoire','fire_brazier','winter_bell','ore')
$legendBase=Join-Path $root 'art/cards/legendary-v01/drunken_erin_legendary_blank.png'
$resourceBase=Join-Path $root 'godot/assets/cards/timber.png'
New-Item -ItemType Directory -Force -Path (Join-Path $root 'godot/screenshots/legend-cards') | Out-Null
$records=@()
foreach($id in $ids){
  $resource=$id -eq 'ore'
  $base=if($resource){$resourceBase}else{$legendBase}
  $draft=Join-Path $root ('art/cards/legend-v01/drafts/'+$id+'-card-draft.png')
  $picture=if($resource){$draft}else{Join-Path $root ('output/legend-v01/sources/'+$id+'-illustration.png')}
  $artRel='art/cards/legend-v01/'+$id+'.png'
  $gameRel='godot/assets/cards/'+$id+'.png'
  $handRel='godot/assets/cards/hand/'+$id+'.png'
  $counts=[LegendPackage]::Compose($base,$picture,$draft,(Join-Path $root $artRel),$resource)
  Copy-Item -LiteralPath (Join-Path $root $artRel) -Destination (Join-Path $root $gameRel) -Force
  $full=[System.Drawing.Bitmap]::new((Join-Path $root $gameRel))
  $hand=[LegendPackage]::Scale($full,256,384)
  $hand.Save((Join-Path $root $handRel),[System.Drawing.Imaging.ImageFormat]::Png)
  $hand.Dispose();$full.Dispose()
  foreach($rel in @($artRel,$gameRel,$handRel)){
    $path=Join-Path $root $rel
    $bmp=[System.Drawing.Bitmap]::new($path)
    $isHand=$rel -eq $handRel
    $delta=if($isHand){[LegendPackage]::VerifyHand($base,$path,$resource)}else{[LegendPackage]::Verify($base,$path,$resource)}
    $expectedW=if($isHand){256}else{1024};$expectedH=if($isHand){384}else{1536}
    $corners=@($bmp.GetPixel(0,0).A,$bmp.GetPixel($bmp.Width-1,0).A,$bmp.GetPixel(0,$bmp.Height-1).A,$bmp.GetPixel($bmp.Width-1,$bmp.Height-1).A)
    $bytes=[System.IO.File]::ReadAllBytes($path)
    $pass=$bmp.Width -eq $expectedW -and $bmp.Height -eq $expectedH -and $bytes[25] -eq 6 -and $delta[0] -eq 0 -and $delta[1] -eq 0 -and ($corners | Measure-Object -Maximum).Maximum -le 2
    $records+= [ordered]@{id=$id;path=$rel;width=$bmp.Width;height=$bmp.Height;channels='RGBA';png_color_type=$bytes[25];corner_alpha=$corners;preserved_region_rgba_changed_pixels=$delta[0];alpha_changed_pixels=$delta[1];sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLower();bytes=$bytes.Length;passed=$pass}
    $bmp.Dispose()
    if(-not $pass){throw ('Validation failed: '+$rel+' '+($delta -join ','))}
  }
  Write-Output ('PACKAGED '+$id+' art='+$counts[0]+' badge='+$counts[1]+' protected_delta=0 alpha_delta=0')
}
[LegendPackage]::Preview($legendBase,(Join-Path $PSScriptRoot 'legend-mask-preview.png'),$false)
[LegendPackage]::Preview($resourceBase,(Join-Path $PSScriptRoot 'resource-mask-preview.png'),$true)
$sheet='godot/screenshots/legend-cards/sheet-v01.png'
[LegendPackage]::Sheet($root,(Join-Path $root $sheet))
$result=[ordered]@{date='2026-10-25';generator='built-in image_gen';passed=$true;visual_review_pending=$true;source_templates=@(@{path='art/cards/legendary-v01/drunken_erin_legendary_blank.png';sha256=(Get-FileHash -LiteralPath $legendBase -Algorithm SHA256).Hash.ToLower()},@{path='godot/assets/cards/timber.png';sha256=(Get-FileHash -LiteralPath $resourceBase -Algorithm SHA256).Hash.ToLower()});preservation_definition='All decoded RGBA pixels outside the saved art/badge masks must be identical to the source template. Whole-image alpha must be identical. Hand comparison excludes only bicubic-filter influence within 2px of the downscaled mask.';alpha_note='Timber source corner alpha is [1,0,2,0] in TL,TR,BL,BR order. These near-transparent values are copied exactly, prioritizing the requested source alpha/pixel preservation; no arbitrary alpha correction. Legend corners are fully transparent.';preview_sheet=$sheet;files=$records}
$result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'verification.json') -Encoding UTF8
