$ErrorActionPreference = 'Stop'
$workspace = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$stage = Join-Path $PSScriptRoot 'import-stage'
$stageProject = Join-Path $stage 'godot'
$stageAssets = Join-Path $stageProject 'assets/ui/ftue'
New-Item -ItemType Directory -Force -Path $stageAssets | Out-Null
Copy-Item -LiteralPath (Join-Path $workspace 'godot/assets/ui/ftue') -Destination (Join-Path $stageProject 'assets/ui') -Recurse -Force
# A texture-only project avoids Godot generating .gd.uid files in protected
# source directories while another worker is creating new game scripts.
$config = @'
config_version=5

[application]
config/name="FTUE asset import verification"
config/features=PackedStringArray("4.7", "Forward Plus")
'@
[IO.File]::WriteAllText((Join-Path $stageProject 'project.godot'),$config,[Text.UTF8Encoding]::new($false))
$runtimeDir = Join-Path $PSScriptRoot 'godot-runtime'
New-Item -ItemType Directory -Force -Path $runtimeDir | Out-Null
$engine = Join-Path $runtimeDir 'Godot-4.7.2.exe'
$engineSource = Join-Path $workspace '.tools/Godot-4.7.2.exe'
if ((Get-Item -LiteralPath $engineSource).Length -lt 4096) {
    # A worktree may contain the LFS pointer while the primary checkout is hydrated.
    $primaryCheckout = (Resolve-Path (Join-Path $workspace '../../..')).Path
    $engineSource = Join-Path $primaryCheckout '.tools/Godot-4.7.2.exe'
}
if ((Get-FileHash -LiteralPath $engineSource -Algorithm SHA256).Hash.ToLowerInvariant() -ne 'ab1824f85bfd8e0e4128182c000c4003a3e042245b2967848d089b2a04b22424') { throw 'Godot executable does not match the requested LFS object.' }
Copy-Item -LiteralPath $engineSource -Destination $engine -Force
# Godot portable mode keeps editor settings inside this writable workspace.
[IO.File]::WriteAllText((Join-Path $runtimeDir '_sc_'),'')
$stdout = Join-Path $PSScriptRoot 'godot-import.stdout.log'
$stderr = Join-Path $PSScriptRoot 'godot-import.stderr.log'
$startInfo = [Diagnostics.ProcessStartInfo]::new()
$startInfo.FileName = $engine
$startInfo.Arguments = '--headless --path godot --import'
$startInfo.WorkingDirectory = $stage
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$process = [Diagnostics.Process]::new()
$process.StartInfo = $startInfo
try {
    [void]$process.Start()
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $process.WaitForExit()
    $exitCode = $process.ExitCode
    [IO.File]::WriteAllText($stdout,$stdoutTask.GetAwaiter().GetResult(),[Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText($stderr,$stderrTask.GetAwaiter().GetResult(),[Text.UTF8Encoding]::new($false))
} finally { $process.Dispose() }
$copied = @()
if ($exitCode -eq 0) {
    foreach ($file in Get-ChildItem -LiteralPath $stageAssets -Filter '*.png.import' -File) {
        Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $workspace ('godot/assets/ui/ftue/'+$file.Name)) -Force
        $copied += 'godot/assets/ui/ftue/'+$file.Name
    }
    $importDir = Join-Path $workspace 'godot/.godot/imported'
    New-Item -ItemType Directory -Force -Path $importDir | Out-Null
    foreach ($file in Get-ChildItem -LiteralPath (Join-Path $stageProject '.godot/imported') -File) {
        Copy-Item -LiteralPath $file.FullName -Destination $importDir -Force
    }
}
$record = [ordered]@{
    executable='output/ftue-prologue-v01/godot-runtime/Godot-4.7.2.exe'
    original_executable='.tools/Godot-4.7.2.exe'
    portable_mode=$true
    executable_sha256=(Get-FileHash -LiteralPath $engine -Algorithm SHA256).Hash.ToLowerInvariant()
    arguments=@('--headless','--path','godot','--import')
    working_directory='output/ftue-prologue-v01/import-stage'
    scope='Isolated texture-only Godot project; copied only FTUE .png.import and their compiled texture caches into the actual game.'
    reason='Avoid automatic .gd.uid creation or other writes in protected source paths during concurrent implementation.'
    environment_messages='Sandbox root-certificate and user-storage diagnostics are retained in stderr; texture import and subsequent texture loading are verified separately.'
    exit_code=$exitCode; copied_import_files=$copied
    stdout='output/ftue-prologue-v01/godot-import.stdout.log'
    stderr='output/ftue-prologue-v01/godot-import.stderr.log'
}
$record | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'godot-import-result.json') -Encoding UTF8
$record | ConvertTo-Json -Depth 6
if ($exitCode -ne 0 -or $copied.Count -ne 7) { exit 1 }
