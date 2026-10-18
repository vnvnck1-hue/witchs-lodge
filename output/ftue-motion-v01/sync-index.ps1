$ErrorActionPreference='Stop'
$entries=New-Object System.Collections.ArrayList
function Expand-Records($records){
 foreach($record in $records){
  if($record.PSObject.Properties.Name -contains 'value'){Expand-Records $record.value}
  elseif($record.PSObject.Properties.Name -contains 'cut'){[void]$entries.Add($record)}
 }
}
Expand-Records (Get-Content -Encoding UTF8 -Raw "$PSScriptRoot/generation-index-v02.json"|ConvertFrom-Json)
$resume=Get-Content -Encoding UTF8 -Raw "$PSScriptRoot/resume-generated-index.json"|ConvertFrom-Json
foreach($record in $resume){
 for($i=$entries.Count-1;$i -ge 0;$i--){if($entries[$i].cut -eq $record.cut -and $entries[$i].id -eq $record.id -and $entries[$i].kind -notin @('master-v02','repair-v02','draft')){$entries.RemoveAt($i)}}
 [void]$entries.Add($record)
}
foreach($a in $entries){
 if($a.cut -eq 1){switch($a.id){
  'village' {$a.box=@(680,430,600,180)}
  'smoke' {$a.box=@(220,0,1050,560)}
  'witch_1' {$a.box=@(670,805,140,220)}
  'witch_2' {$a.box=@(490,775,65,110)}
  'witch_3' {$a.box=@(900,840,58,95)}
 }}
 if($a.cut -eq 2 -and $a.id -eq 'witch'){$a.box=@(650,535,460,540)}
 if($a.cut -eq 2 -and $a.id -eq 'lantern_glow'){$a.box=@(950,795,290,300);$a|Add-Member -NotePropertyName opacity -NotePropertyValue 0.2 -Force}
 if($a.cut -eq 4 -and $a.id -eq 'traveler_fore'){$a.box=@(0,170,1090,1126);$a.full_canvas=$false}
 if($a.cut -eq 4 -and $a.id -eq 'spider_legs'){$a.box=@(1050,0,1254,650);$a.full_canvas=$false}
 if($a.cut -eq 4 -and $a.id -eq 'spider'){$a.box=@(1830,0,474,330)}
}
ConvertTo-Json -InputObject $entries.ToArray() -Depth 16|Set-Content -Encoding UTF8 "$PSScriptRoot/generation-index-v02.json"
Write-Output "Synchronized $($entries.Count) source records."
