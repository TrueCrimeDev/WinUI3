@echo off
setlocal

set "SCRIPT=%~dp0DotNet_Example.ahk"

set "AHK_V2=%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe"
if exist "%AHK_V2%" goto run

set "AHK_V2=%ProgramFiles%\AutoHotkey\v2\AutoHotkey32.exe"
if exist "%AHK_V2%" goto run

set "AHK_V2=%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe"
if exist "%AHK_V2%" goto run

set "AHK_V2=%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey32.exe"
if exist "%AHK_V2%" goto run

echo AutoHotkey v2 not found. Please install v2 or edit this file with the correct path.
pause
exit /b 1

:run
"%AHK_V2%" "%SCRIPT%"
