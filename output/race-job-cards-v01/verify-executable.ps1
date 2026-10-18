param([string]$FileName='WitchsLodge.exe',[string]$ReportName='executable-verification.json')
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$path=Join-Path $root $FileName
$fs=[IO.File]::OpenRead($path);$reader=[IO.BinaryReader]::new($fs)
try {
 $mz=([Text.Encoding]::ASCII.GetString($reader.ReadBytes(2))-eq'MZ')
 $fs.Seek(-12,[IO.SeekOrigin]::End) | Out-Null
 $packBytes=$reader.ReadUInt64();$footerMagic=$reader.ReadUInt32()
 $start=$fs.Length-12-[long]$packBytes
 $fs.Seek($start,[IO.SeekOrigin]::Begin) | Out-Null
 $headerMagic=$reader.ReadUInt32()
 $format=$reader.ReadUInt32()
 $fs.Seek($start+24,[IO.SeekOrigin]::Begin) | Out-Null
 $fileBase=$reader.ReadUInt64();$directoryOffset=$reader.ReadUInt64()
 $fs.Seek($start+[long]$directoryOffset,[IO.SeekOrigin]::Begin) | Out-Null
 $head=$reader.ReadBytes([int]([long]$packBytes-[long]$directoryOffset))
 $directory=[Text.Encoding]::UTF8.GetString($head)
 $memory=[IO.MemoryStream]::new($head,$false);$index=[IO.BinaryReader]::new($memory);$entries=@{}
 try{$entryCount=$index.ReadUInt32();for($i=0;$i-lt$entryCount;$i++){$nameLength=$index.ReadUInt32();$name=[Text.Encoding]::UTF8.GetString($index.ReadBytes([int]$nameLength)).TrimEnd([char]0);$offset=$index.ReadUInt64();$size=$index.ReadUInt64();$md5=$index.ReadBytes(16);$flags=$index.ReadUInt32();$entries[$name]=@{offset=$offset;size=$size;flags=$flags}}}finally{$index.Dispose();$memory.Dispose()}
 $export=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'godot-export-result.json') | ConvertFrom-Json
 $files=@();foreach($race in @('dwarf','fairy','goblin','beastfolk','orc')){foreach($job in @('warrior','hunter','lumberjack','gatherer')){foreach($hand in @('','hand/')){
  $rel='assets/cards/races/'+$race+'/'+$hand+$job+'.png'
  $binding=@($export.final_card_bindings | Where-Object {$_.path-eq('res://'+$rel)})[0]
  $cache=$binding.cache.Substring(6);$entry=$entries[$cache];$actualHash='';$payloadOffset=-1
  if($null-ne$entry){foreach($candidate in @(($start+[long]$fileBase+[long]$entry.offset),($start+[long]$entry.offset),([long]$entry.offset))){if($candidate-ge0-and$candidate+[long]$entry.size-le$fs.Length){$fs.Seek($candidate,[IO.SeekOrigin]::Begin)|Out-Null;$data=$reader.ReadBytes([int]$entry.size);$sha=[Security.Cryptography.SHA256]::Create();try{$hash=([BitConverter]::ToString($sha.ComputeHash($data))).Replace('-','').ToLowerInvariant()}finally{$sha.Dispose()};if($hash-eq$binding.cache_sha256){$actualHash=$hash;$payloadOffset=$candidate;break}}}}
  $files+=@{path=('res://'+$rel);found_in_embedded_directory=$directory.Contains($rel);cache_path=$binding.cache;expected_ctex_sha256=$binding.cache_sha256;embedded_ctex_sha256=$actualHash;payload_offset=$payloadOffset;passed=($directory.Contains($rel)-and$actualHash-eq$binding.cache_sha256-and$actualHash-ne'')}
 }}}
 $embedded=($footerMagic-eq0x43504447-and$headerMagic-eq0x43504447-and$start-gt0)
 $passed=($mz-and$embedded-and@($files | Where-Object {-not $_.passed}).Count-eq0)
 $length=$fs.Length
}finally{$reader.Dispose();$fs.Dispose()}
[ordered]@{path=$FileName;bytes=$length;sha256=(Get-FileHash -LiteralPath $path).Hash.ToLowerInvariant();pe_mz=$mz;embedded_pck=$embedded;pack_format=$format;directory_entries=$entryCount;embedded_pck_start=$start;embedded_pck_bytes=$packBytes;card_paths=$files;found_count=@($files | Where-Object {$_.found_in_embedded_directory}).Count;matching_ctex_count=@($files | Where-Object {$_.passed}).Count;separate_root_pck_exists=(Test-Path -LiteralPath (Join-Path $root 'WitchsLodge.pck'));passed=$passed} | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot $ReportName)
Write-Output ('Executable: embedded PCK card paths '+@($files | Where-Object {$_.found_in_embedded_directory}).Count+'/40; passed='+$passed)
if(-not $passed){exit 1}
