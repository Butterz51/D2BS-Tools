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

echo  Initializing Script Execution...
echo.
echo  [--------------------] 0%%
timeout /t 1 /nobreak >nul
echo  [#####---------------] 25%%
timeout /t 1 /nobreak >nul
echo  [##########----------] 50%%
timeout /t 2 /nobreak >nul
echo  [###############-----] 75%%
timeout /t 2 /nobreak >nul
echo  [####################] 100%%
timeout /t 1 /nobreak >nul
echo.
echo  Executing "D2bsCleaner.ps1"...
echo.

PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "D2bsCleaner.ps1"

echo.
echo Script Execution Completed.
