@echo off

echo.
echo  Author: Butterz
echo  Version: 1.1
echo.
echo  Description: This batch file launches "D2bsCleaner.ps1", a comprehensive PowerShell script for
echo               managing and cleaning directories within Diablo II, Kolbot, and Kolbot-SoloPlay environments.
echo               It bypasses the default PowerShell execution policy for streamlined execution.
echo               Ensure "D2bsCleaner.ps1" is located in the same directory as this batch file.
echo.

REM Log file
set LOGFILE=D2bsCleanerReport.LOG
set ERRORFOUND=0

echo Checking for D2bsCleaner.ps1...

if not exist "D2bsCleaner.ps1" (
  echo Error: D2bsCleaner.ps1 not found in the current directory.
  for /f "tokens=1-5 delims=/: " %%a in ('echo %date%') do (
    echo Date: %%c/%%b/%%d  -  Error: D2bsCleaner.ps1 not found in the current directory. >> %LOGFILE%
  )
  echo Error occurred during script execution. See %LOGFILE% for details.
  pause
  exit /b 1
)

echo Executing D2bsCleaner.ps1...
echo.

timeout /t 1 /nobreak >nul

REM Script execution
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "D2bsCleaner.ps1" 2> %LOGFILE% && set ERRORFOUND=1

if %ERRORLEVEL% neq 0 (
  echo Error occurred during script execution. See %LOGFILE% for details.
  pause
  exit /b 1
) else (
  echo Script executed successfully.
