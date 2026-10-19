$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskRaces=@{
 fairy=@('thistle','tilia','larch','fern','willow','pip','nivel'); dwarf=@('harald','brynhild','thorgrim','durga','ormu','ketil','signy'); orc=@('garok','kranya','moga','shaga','ulma','bardu','eshka'); beastfolk=@('fargh','saya','urso','momi','luka','tass','selen'); human=@('bram','mira','olaf','torbin','neri','oswin','sera')
}
foreach($taskRace in $taskRaces.Keys){
 $taskCanvas=New-Object System.Drawing.Bitmap 1600,900
 $taskGraphics=[System.Drawing.Graphics]::FromImage($taskCanvas)
 $taskGraphics.Clear([System.Drawing.Color]::FromArgb(45,36,55))
 $taskPaths=@($taskRaces[$taskRace] | ForEach-Object { 'godot/assets/portraits/guest_'+$_+'_cutout.png' })
 if($taskRace -eq 'beastfolk'){$taskPaths+='art/concepts/cards/roles-races-v01/04-beastfolk-luka-v01.png'}
 for($taskI=0;$taskI -lt $taskPaths.Count;$taskI++){
  $taskImage=[System.Drawing.Image]::FromFile((Join-Path $taskRoot $taskPaths[$taskI]))
  $taskScale=[Math]::Min(380.0/$taskImage.Width,420.0/$taskImage.Height)
  $taskWidth=[int]($taskImage.Width*$taskScale);$taskHeight=[int]($taskImage.Height*$taskScale)
  $taskGraphics.DrawImage($taskImage,[int](($taskI%4)*400+(400-$taskWidth)/2),[int]([Math]::Floor($taskI/4)*450+(440-$taskHeight)/2),$taskWidth,$taskHeight)
  $taskImage.Dispose()
 }
 $taskCanvas.Save((Join-Path $PSScriptRoot ('references/'+$taskRace+'.png')),[System.Drawing.Imaging.ImageFormat]::Png)
 $taskGraphics.Dispose();$taskCanvas.Dispose()
 $taskPaths | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot ('references/'+$taskRace+'.json'))
}
$taskEntries=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'catalog_entries.json') | ConvertFrom-Json
$taskTargets=@{};foreach($taskEntry in $taskEntries){foreach($taskBase in @('art/cards/race-cards-v01/','godot/assets/cards/','godot/assets/cards/hand/')){$taskPath=$taskBase+$taskEntry.id+'.png';$taskTargets[$taskPath]=$null;if(Test-Path -LiteralPath (Join-Path $taskRoot $taskPath)){$taskTargets[$taskPath]=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $taskRoot $taskPath)).Hash}}}
$taskTargets | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'targets-before.json')
$taskProtected=@{}
foreach($taskArea in @('godot/scripts','godot/scenes','godot/shaders','godot/tools','godot/assets/cards','art/cards/races-v01','docs')){
 Get-ChildItem -LiteralPath (Join-Path $taskRoot $taskArea) -Recurse -File | ForEach-Object {$taskRel=$_.FullName.Substring($taskRoot.Length+1).Replace('\','/');if(-not $taskTargets.ContainsKey($taskRel)){$taskProtected[$taskRel]=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}}
}
foreach($taskRel in @('godot/project.godot','WitchsLodge.exe','output/race-cards-v01/catalog_entries.json')){$taskProtected[$taskRel]=(Get-FileHash -LiteralPath (Join-Path $taskRoot $taskRel) -Algorithm SHA256).Hash}
$taskProtected | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'protected-before.json')
Write-Output ('Reference sheets ready; protected files: '+$taskProtected.Count+'; existing targets: '+@($taskTargets.Values | Where-Object {$_}).Count)
