@echo off

echo.
echo  Author: Butterz
echo  Version: 1.0
echo.
echo  Description: This batch file launches "D2bsCleaner.ps1", a PowerShell script for cleaning
echo               specific directories in the Kolbot and Kolbot-SoloPlay environments. It ensures
echo               a streamlined execution by bypassing the default PowerShell execution policy.
echo               Place this batch file in the same directory as "D2bsCleaner.ps1" for proper functioning.
echo.
echo  Usage: Double-click this batch file to run the associated PowerShell script. Ensure "D2bsCleaner.ps1"
echo         is located in the same directory as this batch file.
echo.

REM Log file
set LOGFILE=D2bsCleaner.LOG

echo Executing D2bsCleaner.ps1...
echo.

REM Progress indicator
echo  [--------------------] 0%%
timeout /t 1 /nobreak >nul

REM Check if the PowerShell script exists
if not exist "D2bsCleaner.ps1" (
  echo Starting D2bsCleanerLauncher.bat > %LOGFILE%
  for /f "tokens=1-5 delims=/: " %%a in ('echo %date% %time%') do (
    echo %%a-%%b-%%c %%d:%%e >> %LOGFILE%
  )
  echo Error: D2bsCleaner.ps1 not found in the current directory >> %LOGFILE%
  echo Error: D2bsCleaner.ps1 not found in the current directory.
  pause
  exit /b 1
)

echo  [#####---------------] 25%%
timeout /t 1 /nobreak >nul
echo  [##########----------] 50%%
timeout /t 2 /nobreak >nul
echo  [###############-----] 75%%
timeout /t 2 /nobreak >nul
echo  [####################] 100%%
timeout /t 1 /nobreak >nul
echo.

REM Script execution
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "D2bsCleaner.ps1"

if %ERRORLEVEL% neq 0 (
  echo Error occurred during script execution. See %LOGFILE% for details.
  pause
  exit /b 1
) else (
  echo Script executed successfully.
)

echo Script Execution Completed.
