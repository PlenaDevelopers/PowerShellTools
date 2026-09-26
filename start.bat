@echo off
setlocal EnableExtensions

REM PowerTool - preparation and launcher

net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo Requesting administrator permission...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

pushd "%~dp0"
set "targetDir=%CD%"

echo.
echo +------------------------------------------------------------------------------------------------------------------------+
echo ^| PowerTool                                                                                                             ^|
echo +------------------------------------------------------------------------------------------------------------------------+
echo Folder: "%targetDir%"
echo.

echo Unblocking downloaded files...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -LiteralPath '%targetDir%' -Recurse -File -Force | Unblock-File -ErrorAction SilentlyContinue"

echo Enabling PowerShell script execution...
powershell.exe -NoProfile -Command "try { Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Stop } catch { }; try { Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force -ErrorAction Stop } catch { }; try { Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction Stop } catch { }"

echo Opening PowerTool menu...
cd /d "%targetDir%"
start "" powershell.exe -STA -ExecutionPolicy Bypass -File "%targetDir%\start.ps1"

popd
endlocal
exit /b
