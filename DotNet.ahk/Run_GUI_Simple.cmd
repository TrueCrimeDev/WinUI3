@echo off
cd /d "%~dp0"
"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut "DotNet_GUI_Simple.ahk"
if errorlevel 1 pause
