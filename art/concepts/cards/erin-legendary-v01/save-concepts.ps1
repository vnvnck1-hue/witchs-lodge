$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot=(Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
$records=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'generated-sources.json') -Raw | ConvertFrom-Json
New-Item -ItemType Directory -Force -Path (Join-Path $PSScriptRoot 'references') | Out-Null
Copy-Item -LiteralPath (Join-Path $projectRoot 'art/cards/tavern-v04/drunken_erin.png') -Destination (Join-Path $PSScriptRoot 'references/erin-v04.png') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'art/concepts/cards/roles-individual-v02/01-character-nib.png') -Destination (Join-Path $PSScriptRoot 'references/approved-character-nib.png') -Force
$sheet=[System.Drawing.Bitmap]::new(1600,800,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g=[System.Drawing.Graphics]::FromImage($sheet)
$g.Clear([System.Drawing.Color]::FromArgb(37,28,45))
$g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$metadata=@()
for($i=0;$i -lt $records.Count;$i++) {
  $record=$records[$i]
  $destination=Join-Path $PSScriptRoot ($record.id+'.png')
  Copy-Item -LiteralPath $record.source -Destination $destination -Force
  $image=[System.Drawing.Bitmap]::new($destination)
  if($image.Width -ne 1024 -or $image.Height -ne 1536) { throw "Unexpected concept dimensions: $($record.id)" }
  $g.DrawImage($image,[System.Drawing.Rectangle]::new(16+$i*528,16,512,768))
  $metadata += [ordered]@{id=$record.id;name=$record.name;file=$destination;width=$image.Width;height=$image.Height;pixelFormat=$image.PixelFormat.ToString();cornerAlpha=$image.GetPixel(0,0).A;centerAlpha=$image.GetPixel(512,768).A;sha256=(Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash}
  $image.Dispose()
}
$g.Dispose()
$sheet.Save((Join-Path $PSScriptRoot 'comparison.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$sheet.Dispose()
$metadata | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'manifest.json') -Encoding utf8
Write-Output 'PASS three independent 1024x1536 concepts saved; comparison 1600x800'
