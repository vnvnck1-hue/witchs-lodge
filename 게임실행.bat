@echo off
rem Witch's Lodge launcher - runs the latest source in godot/ with the bundled Godot 4.7.2
setlocal
cd /d "%~dp0"
set "GODOT=%~dp0.tools\Godot-4.7.2.exe"

if not exist "%GODOT%" (
  echo [ERROR] .tools\Godot-4.7.2.exe not found. Run: git lfs pull
  pause
  exit /b 1
)

if not exist "%~dp0godot\.godot\imported" (
  echo First run: importing assets. This can take a few minutes...
  "%GODOT%" --headless --path "%~dp0godot" --import
)

start "" "%GODOT%" --path "%~dp0godot"
endlocal
