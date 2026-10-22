Add-Type -AssemblyName System.Drawing
$taskRoot = (Get-Location).Path
$taskSheet = Join-Path $taskRoot 'art/ui/speech-notification-v02/sheet.png'
$taskImage = [System.Drawing.Bitmap]::FromFile($taskSheet)
$taskCanvas = New-Object System.Drawing.Bitmap($taskImage.Width, $taskImage.Height)
$taskGraphics = [System.Drawing.Graphics]::FromImage($taskCanvas)
$taskGraphics.DrawImageUnscaled($taskImage, 0, 0)
$taskImage.Dispose()
$taskGraphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$taskInk = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(48, 32, 59))
$taskMuted = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(89, 80, 102))
$taskTitle = New-Object System.Drawing.Font('Malgun Gothic', 31, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$taskHeading = New-Object System.Drawing.Font('Malgun Gothic', 24, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$taskText = New-Object System.Drawing.Font('Malgun Gothic', 21, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
function Label($text, $x, $y, $font = $taskHeading, $brush = $taskInk) { $taskGraphics.DrawString($text, $font, $brush, [single]$x, [single]$y) }
Label '말풍선 v02 · 시안 직접 대조' 48 20 $taskTitle
Label '01  승인 시안 발췌 · 3배' 48 68
Label '02  새 몸통 + 꼬리 + 꺾쇠 · 같은 크기 / 글자 자리 비움' 48 518
Label '03  밝은 눈밭 배경 합성 · 알림 자리 바로 위의 실제 배경 사용' 48 910
Label '04  9분할 확대 · 몸통 1536×384 (가로 2배 · 세로 1.5배)' 48 1440
Label '중앙은 잔잔한 종이 결만 유지 · 먹선 / 보라 빛 / 비네트는 40px 가장자리 안에 유지' 65 1890 $taskText $taskMuted
Label '게임용 PNG 3장' 1210 78
Label '몸통 768×256 · RGBA' 1227 320 $taskText
Label '꼬리 96×96' 1220 575 $taskText
Label '꺾쇠 64×64' 1490 575 $taskText
Label '제작 / 검수' 1220 660
$taskLines = @('시안 그림을 실제 편집 입력으로 사용', '먹선·외곽: 원본 시안에서 복원', '글자 없는 종이: 생성본의 미세 결 반영', '꺾쇠: 시안 픽셀에서 직접 분리', '몸통 / 꺾쇠: 캔버스 바깥 alpha 0', '꼬리 x60~95: 먹선 없는 종이 겹침부', '9분할 여백: 상하좌우 40px')
$taskY = 708
foreach ($taskLine in $taskLines) { Label $taskLine 1220 $taskY $taskText $taskMuted; $taskY += 34 }
Label '꼬리 접합부 · 3배 확대' 1220 960
Label '눈밭은 기존 알림에 가려지지 않은' 1210 1385 $taskText $taskMuted
Label '인접 배경을 발췌·반사 연장했습니다.' 1210 1418 $taskText $taskMuted
Label '이 시트는 합성 검수용입니다.' 1210 1460 $taskText $taskMuted
Label 'Godot 임포트 / 게임 적용은 하지 않았습니다.' 48 1400 $taskText $taskMuted
$taskGraphics.Dispose()
$taskCanvas.Save($taskSheet, [System.Drawing.Imaging.ImageFormat]::Png)
$taskCanvas.Dispose()
$taskTitle.Dispose(); $taskHeading.Dispose(); $taskText.Dispose(); $taskInk.Dispose(); $taskMuted.Dispose()
