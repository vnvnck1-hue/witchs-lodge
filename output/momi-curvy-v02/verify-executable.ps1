$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$exe=Join-Path $root 'WitchsLodge.exe'
$stream=[IO.File]::OpenRead($exe)
$reader=[IO.BinaryReader]::new($stream)
try {
  $mz=([Text.Encoding]::ASCII.GetString($reader.ReadBytes(2)) -eq 'MZ')
  $stream.Seek(-12,[IO.SeekOrigin]::End) | Out-Null
  $packBytes=$reader.ReadUInt64(); $footerMagic=$reader.ReadUInt32()
  $start=$stream.Length-12-[long]$packBytes
  $stream.Seek($start,[IO.SeekOrigin]::Begin) | Out-Null
  $headerMagic=$reader.ReadUInt32(); $format=$reader.ReadUInt32()
  if($headerMagic -ne 0x43504447 -or $footerMagic -ne 0x43504447 -or -not $mz) { throw 'Invalid embedded PCK' }
  $stream.Seek($start+24,[IO.SeekOrigin]::Begin) | Out-Null
  $fileBase=$reader.ReadUInt64(); $directoryOffset=$reader.ReadUInt64()
  $stream.Seek($start+[long]$directoryOffset,[IO.SeekOrigin]::Begin) | Out-Null
  $head=$reader.ReadBytes([int]([long]$packBytes-[long]$directoryOffset))
  $memory=[IO.MemoryStream]::new($head,$false); $index=[IO.BinaryReader]::new($memory); $entries=@{}
  try {
    $entryCount=$index.ReadUInt32()
    for($i=0;$i -lt $entryCount;$i++) {
      $nameLength=$index.ReadUInt32(); $name=[Text.Encoding]::UTF8.GetString($index.ReadBytes([int]$nameLength)).TrimEnd([char]0)
      $offset=$index.ReadUInt64(); $size=$index.ReadUInt64(); $null=$index.ReadBytes(16); $flags=$index.ReadUInt32()
      $entries[$name]=@{offset=$offset;size=$size;flags=$flags}
    }
  } finally { $index.Dispose();$memory.Dispose() }
  $results=@()
  foreach($variant in @('','hand/')) {
    $relative='assets/cards/races/beastfolk/'+$variant+'gatherer.png'
    $import=Get-Content -LiteralPath (Join-Path $root ('godot/'+$relative+'.import')) -Raw
    $cache=[regex]::Match($import,'(?m)^path="res://([^"]+)"').Groups[1].Value
    $expected=(Get-FileHash -LiteralPath (Join-Path $root ('godot/'+$cache)) -Algorithm SHA256).Hash
    $entry=$entries[$cache]; $actual=''
    if($null -ne $entry) {
      foreach($offset in @(($start+[long]$fileBase+[long]$entry.offset),($start+[long]$entry.offset),([long]$entry.offset))) {
        if($offset -ge 0 -and $offset+[long]$entry.size -le $stream.Length) {
          $stream.Seek($offset,[IO.SeekOrigin]::Begin) | Out-Null
          $data=$reader.ReadBytes([int]$entry.size)
          $sha=[Security.Cryptography.SHA256]::Create()
          try { $hash=([BitConverter]::ToString($sha.ComputeHash($data))).Replace('-','') } finally { $sha.Dispose() }
          if($hash -eq $expected) { $actual=$hash;break }
        }
      }
    }
    $ok=$actual -eq $expected -and $actual -ne ''
    $results += [ordered]@{source=$relative;cache=$cache;expectedSha256=$expected;embeddedSha256=$actual;passed=$ok}
    Write-Output "EMBEDDED_MATCH=$ok $relative"
  }
  $passed=@($results | Where-Object { -not $_.passed }).Count -eq 0
  $length=$stream.Length
} finally { $reader.Dispose();$stream.Dispose() }
[ordered]@{passed=$passed;executable='WitchsLodge.exe';bytes=$length;updated=(Get-Item -LiteralPath $exe).LastWriteTime.ToString('o');embeddedPck=$true;format=$format;files=$results} | ConvertTo-Json -Depth 7 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'executable-verification.json') -Encoding utf8
if(-not $passed) { throw 'Final executable does not contain the current Momi textures' }
