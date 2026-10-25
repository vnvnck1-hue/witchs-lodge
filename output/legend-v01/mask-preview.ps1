$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -Path (Join-Path $PSScriptRoot 'package.cs') -ReferencedAssemblies System.Drawing
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
[LegendPackage]::Preview((Join-Path $root 'art/cards/legendary-v01/drunken_erin_legendary_blank.png'),(Join-Path $PSScriptRoot 'legend-mask-preview.png'),$false)
[LegendPackage]::Preview((Join-Path $root 'godot/assets/cards/timber.png'),(Join-Path $PSScriptRoot 'resource-mask-preview.png'),$true)
