##################################
#  @filename    D2bsCleaner.sp1  #
#  @author      Butterz          #
##################################
$host.UI.RawUI.WindowTitle = "Kolbot Cleanup Tool"

# Set the buffer size first (width and height)
# Buffer size must be equal to or larger than (50)
$bufferSize = New-Object Management.Automation.Host.Size(140, 52)
$host.UI.RawUI.BufferSize = $bufferSize

# Set Console Size (width and height)
$windowSize = New-Object Management.Automation.Host.Size(140, 52)
$host.UI.RawUI.WindowSize = $windowSize

# Set Console Color
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "White"
$host.UI.RawUI.FlushInputBuffer()
Clear-Host

# Script Credits/Version
function ShowCredits {
  $consoleWidth = $host.UI.RawUI.WindowSize.Width
  $versionText = "Version: 2.1"
  $authorText = "Author: Butterz"

  # Calculate padding for right alignment
  $totalLength = $versionText.Length + $authorText.Length
  $padding = $consoleWidth - $totalLength
  $paddingText = " " * $padding

  Write-Host ""
  Write-Host ($authorText + $paddingText + $versionText) -ForegroundColor DarkGray
  Write-Host ""
}

# Script Information
function ShowVersion {
  ShowCredits
  Write-Host ""
  Write-Host " Version History:" -ForegroundColor DarkGray
  Write-Host ""
  Write-Host "    1.0 (05/08/2016) - Initial alpha release (private). Basic directory cleaning functionality, not released to the public." -ForegroundColor DarkGray
  Write-Host "    1.1 (01/12/2017) - Enhanced to support cleaning of multiple specific directories." -ForegroundColor DarkGray
  Write-Host "    1.2 (14/12/2017) - Introduced interactive menu for directory selection." -ForegroundColor DarkGray
  Write-Host "    1.3 (08/06/2018) - Implemented error handling for missing directories." -ForegroundColor DarkGray
  Write-Host "    1.4 (02/09/2019) - Upgraded with detailed logging and error messages." -ForegroundColor DarkGray
  Write-Host "    1.5 (01/11/2020) - Beta release to a closed group. Introduced execution delay for improved script visibility." -ForegroundColor DarkGray
  Write-Host "    1.6 (22/10/2022) - Included functionality to delete 'ScriptErrorLog.txt' file." -ForegroundColor DarkGray
  Write-Host "    1.7 (16/02/2023) - Improved error reporting and enhanced user menu clarity." -ForegroundColor DarkGray
  Write-Host "    1.8 (17/03/2023) - Transitioned script from Batch to PowerShell." -ForegroundColor DarkGray
  Write-Host "    1.9 (02/05/2023) - Updated with color enhancements and refined error messages." -ForegroundColor DarkGray
  Write-Host "    2.0 (15/08/2023) - Integrated 'Escape to quit' and 'any key to return to menu' functionality." -ForegroundColor DarkGray
  Write-Host "    2.1 (20/12/2023) - Public release. Included functionality to delete 'profile.json' file & improved script launcher." -ForegroundColor DarkGray
  Write-Host ""
  Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
  $script:errorOccurred = $false
  $script:stopOccurred = $true
}

function ShowDescription {
  ShowCredits
  Write-Host ""
  Write-Host " Description:"
  Write-Host ""
  Write-Host "   This script is designed to clean up specified directories in the Kolbot and"
  Write-Host ""
  Write-Host "     Kolbot-SoloPlay environments. It provides options for selective or complete"
  Write-Host ""
  Write-Host "     cleanup and reports detailed errors for better diagnostics. The user can"
  Write-Host ""
  Write-Host "     choose specific folders to clean or perform a full cleanup."
  Write-Host ""
  Write-Host ""
  Write-Host ""
  Write-Host " Usage:"
  Write-Host ""
  Write-Host "   Run the script and choose an option from the menu. Each option corresponds to"
  Write-Host ""
  Write-Host "     a specific directory or task."
  Write-Host ""
  Write-Host ""
  Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
}

# Base Directory
$baseDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$baseDir = Join-Path $baseDir ".."

# Folders
$folder1 = Join-Path $baseDir "\logs"
$folder2 = Join-Path $baseDir "\d2bs\logs"
$folder5 = Join-Path $baseDir "\d2bs\kolbot\data"
$folder6 = Join-Path $baseDir "\d2bs\kolbot\libs\SoloPlay\Data"
$fileToDelete1 = Join-Path $baseDir "\d2bs\kolbot\logs\ScriptErrorLog.txt"
$fileToDelete2 = Join-Path $baseDir "\data\profile.json"
$errorOccurred = $false
$errorList = @()

# Base Functions
function Start-Countdown {
  param (
    [int]$DurationInSeconds
  )
  foreach ($second in $DurationInSeconds..1) {
    Write-Host " Waiting for $second second(s)..." -NoNewline -ForegroundColor Green
    Start-Sleep -Seconds 1
    Write-Host "`r" -NoNewline
  }

  Write-Host " Proceeding..." -ForegroundColor Green
}

function Confirm-Deletion {
  param (
    [string]$message,
    [string]$itemPath
  )
  while ($true) {
    Write-Host ""
    Write-Host ""
    Write-Host "$message $itemPath" -NoNewline -ForegroundColor Yellow
    Write-Host "`n ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    $confirmation = Read-Host "    Type 'y' to continue or 'n' to cancel (y/n)"
    switch ($confirmation.ToLower()) {
      "y" { return $true }
      "n" {
        Clear-Host
        return $false
      }
      default {
        Write-Host ""
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        Write-Host " Invalid input. Please enter 'y' for yes or 'n' for no." -ForegroundColor DarkRed
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      }
    }
  }
}

function CleanUp {
  param (
      [string]$path
  )
  if (Test-Path $path) {
    if (Confirm-Deletion " Are you sure you want to delete all files in:`n`n" $path) {
      Write-Host ""
      Write-Host " Cleaning up: $path" -ForegroundColor Green
      Write-Host ""
      Remove-Item "$path\*" -Recurse -Force
      Start-Countdown -DurationInSeconds 5
    } else {
      Write-Host ""
      Write-Host " Deletion canceled for $path" -ForegroundColor Yellow
      Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
      Write-Host ""
      $script:stopOccurred = $true
    }
  } else {
    Write-Host " Folder not found: $path" -ForegroundColor DarkRed
    $script:errorOccurred = $true
    $script:errorList += $path
  }
}

function CleanUpMultiple {
  param (
    [string]$basePath,
    [string]$subfolders
  )
  $subfolders.Split(' ') | ForEach-Object {
    $subfolderPath = Join-Path $basePath $_
    CleanUp $subfolderPath
    Start-Countdown -DurationInSeconds 10
  }
}

function IsValidSubfolderName {
  param ([string]$name)
  return $validSubfolderNames -contains $name.ToLower()
}

function GetValidSubfolderNames {
  param ([string]$promptMessage)
  do {
    $subfolderNames = Read-Host $promptMessage
    if ($subfolderNames.ToLower() -eq "all") { return $validSubfolderNames }
    $isValid = $subfolderNames.Split(' ') | ForEach-Object { IsValidSubfolderName $_ }
    if (-not $isValid.Contains($false)) { return $subfolderNames.Split(' ') }
    Write-Host ""
    Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
    Write-Host " Invalid input. Please enter valid subfolder names (useast, uswest, asia, europe) or 'all'." -ForegroundColor DarkRed
    Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
  } while ($true)
}

# Arrays
$validSubfolderNames = @("useast", "uswest", "asia", "europe")

# Main Menu
do {
  ShowDescription
  Write-Host ""
  Write-Host "  Choose an action:"
  Write-Host ""
  Write-Host "        0. Version History - Displays the script's version history." -ForegroundColor Gray
  Write-Host ""
  Write-Host "        1. Clean Folder (logs) - Permanently deletes all files in the 'logs' folder." -ForegroundColor Green
  Write-Host ""
  Write-Host "        2. Clean Folder (d2bs\logs) - Permanently deletes all files in 'd2bs\logs'." -ForegroundColor Green
  Write-Host ""
  Write-Host "        3. Clean Subfolders (d2bs\kolbot\logs\Kolbot-SoloPlay) - Permanently deletes files in specified subfolders." -ForegroundColor Green -NoNewline
  Write-Host "  INPUT REQUIRED" -ForegroundColor Yellow
  Write-Host ""
  Write-Host "        4. Clean Subfolders (d2bs\kolbot\mules) - Permanently deletes files in specified subfolders." -ForegroundColor Green -NoNewline
  Write-Host "  INPUT REQUIRED" -ForegroundColor Yellow
  Write-Host ""
  Write-Host "        5. Clean Folder (d2bs\kolbot\data) - Permanently deletes all files in 'd2bs\kolbot\data'." -ForegroundColor Green
  Write-Host ""
  Write-Host "        6. Clean Folder (d2bs\kolbot\libs\SoloPlay\Data) - Permanently deletes all files in 'd2bs\kolbot\libs\SoloPlay\Data'." -ForegroundColor Green
  Write-Host ""
  Write-Host "        7. Delete ScriptErrorLog.txt (d2bs\kolbot\logs) - Permanently deletes the 'd2bs\kolbot\logs\ScriptErrorLog.txt' file." -ForegroundColor Green
  Write-Host ""
  Write-Host "        8. Delete Profile.json - Permanently deletes the 'profile.json' file (data). Use with caution." -ForegroundColor DarkRed
  Write-Host ""
  Write-Host "        9. Perform All Tasks - Executes all cleaning tasks, including subfolder deletions."  -ForegroundColor DarkRed -NoNewline
  Write-Host "  INPUT IS REQUIRED for specific subfolders." -ForegroundColor Yellow
  Write-Host ""
  Write-Host "        10. Exit (Close Program)" -ForegroundColor DarkGray
  Write-Host ""
  Write-Host ""
  $choice = Read-Host "  Enter your choice (0-10 or type 'exit' to quit)"
  Clear-Host

  switch ($choice) {
    "0" {
        ShowVersion
    }

    "1" {
        CleanUp $folder1
    }

    "2" {
        CleanUp $folder2
    }

    "3" {
      Write-Host ""
      Write-Host ""
      Write-Host " Please enter valid subfolder names (e.g., 'useast', 'uswest', 'asia', 'europe') for Kolbot-SoloPlay,"
      $subfolders3 = GetValidSubfolderNames "  separated by spaces, or type 'all' to remove all subfolders."
      $errorOccurred = $false
      CleanUpMultiple (Join-Path $baseDir "kolbot\logs\Kolbot-SoloPlay") $subfolders3
      if ($errorOccurred) {
        Write-Host ""
        Write-Host ""
        Write-Host ""
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        Write-Host " Errors occurred in: $($errorList -join ', ')" -ForegroundColor DarkRed
        Write-Host " Please enter valid subfolder names (e.g., 'useast', 'uswest', 'asia', 'europe') for Kolbot-SoloPlay," -ForegroundColor DarkRed
        Write-Host " separated by spaces, or type 'all' to remove all subfolders." -ForegroundColor DarkRed
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        Write-Host ""
      }
    }
    "4" {
      Write-Host ""
      Write-Host ""
      Write-Host " Please enter valid subfolder names (e.g., 'useast', 'uswest', 'asia', 'europe') for in the Mules folder,"
      $subfolders4 = GetValidSubfolderNames "  separated by spaces, or type 'all' to remove all subfolders."
      $errorOccurred = $false
      CleanUpMultiple (Join-Path $baseDir "kolbot\mules") $subfolders4
      if ($errorOccurred) {
        Write-Host ""
        Write-Host ""
        Write-Host ""
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        Write-Host " Errors occurred in: $($errorList -join ', ')" -ForegroundColor DarkRed
        Write-Host " Please enter valid subfolder names (e.g., 'useast', 'uswest', 'asia', 'europe') for Kolbot\mule," -ForegroundColor DarkRed
        Write-Host " separated by spaces, or type 'all' to remove all subfolders." -ForegroundColor DarkRed
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        Write-Host ""
      }
    }

    "5" { CleanUp $folder5 }

    "6" { CleanUp $folder6 }

    "7" {
      if (Test-Path $fileToDelete1) {
        if (Confirm-Deletion (" Are you sure you want to delete the file:`n`n" + " $fileToDelete1" + "?`n`n")) {
          Write-Host ""
          Write-Host ""
          Write-Host " File deleted: $fileToDelete1" -ForegroundColor Green
          Write-Host ""
          Remove-Item $fileToDelete1 -Force
          Start-Countdown -DurationInSeconds 3
        } else {
          Write-Host ""
          Write-Host " Deletion canceled for $fileToDelete1" -ForegroundColor Yellow
          Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
          $stopOccurred = $true
        }
      } else {
        Write-Host ""
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        Write-Host " File not found: $fileToDelete1" -ForegroundColor DarkRed
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        $stopOccurred = $true
      }
    }

    "8" {
      if (Test-Path $fileToDelete1) {
        if (Confirm-Deletion ("Are you sure you want to delete the file:`n" + $fileToDelete2 + "`n?")) {
          Write-Host ""
          Write-Host ""
          Write-Host " File deleted: $fileToDelete2" -ForegroundColor Green
          Write-Host ""
          Remove-Item $fileToDelete1 -Force
          Start-Countdown -DurationInSeconds 3
        } else {
          Write-Host ""
          Write-Host " Deletion canceled for $fileToDelete2" -ForegroundColor Yellow
          Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
          $stopOccurred = $true
        }
      } else {
        Write-Host ""
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        Write-Host " File not found: $fileToDelete2" -ForegroundColor DarkRed
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        $stopOccurred = $true
      }
    }

    "9" {
      Write-Host " You have chosen to perform all tasks. This will delete files in multiple directories." -ForegroundColor Red
      $confirmAll = Read-Host "  Are you sure you want to proceed? (y/n)"
      if ($confirmAll -eq 'y') {
        $errorOccurred = $false

        CleanUp $folder1
        CleanUp $folder2

        Write-Host ""
        Write-Host " Please enter valid subfolder names (e.g., 'useast', 'uswest', 'asia', 'europe') for Kolbot-SoloPlay,"
        $subfolders3 = GetValidSubfolderNames "  separated by spaces, or type 'all' to remove all subfolders."
        CleanUpMultiple (Join-Path $baseDir "kolbot\logs\Kolbot-SoloPlay") $subfolders3

        Write-Host ""
        Write-Host " Please enter valid subfolder names (e.g., 'useast', 'uswest', 'asia', 'europe') for in the Mules folder,"
        $subfolders4 = GetValidSubfolderNames "  separated by spaces, or type 'all' to remove all subfolders."
        CleanUpMultiple (Join-Path $baseDir "kolbot\mules") $subfolders4

        CleanUp $folder5
        CleanUp $folder6

        if (Test-Path $fileToDelete1) { Remove-Item $fileToDelete1 -Force }
        if (Test-Path $fileToDelete2) { Remove-Item $fileToDelete2 -Force }
        
        Write-Host ""
        Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host " All tasks have been completed." -ForegroundColor Green
        Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
      } else {
        Write-Host ""
        Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host " Operation canceled. Returning to main menu." -ForegroundColor Yellow
        Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
        $stopOccurred = $true
      }
    }

    "10" {
      Write-Host ""
      Write-Host " Closing the application."
      Write-Host ""
      Start-Countdown -DurationInSeconds 5
      exit
    }

    "exit" {
      Write-Host ""
      Write-Host " Closing the application."
      Write-Host ""
      Start-Countdown -DurationInSeconds 5
      exit
    }

    default {
      Write-Host ""
      Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      Write-Host " Invalid option selected. " -ForegroundColor DarkRed -NoNewline
      Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      Write-Host ""
      Write-Host " Please enter a valid choice from the menu." -ForegroundColor Yellow
      $errorOccurred = $false
      $stopOccurred = $true
    }
  }

  if ($errorOccurred) {
    Write-Host ""
    Write-Host ""
    Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
    Write-Host " Errors occurred in: $($errorList -join ', ')" -ForegroundColor DarkRed
    Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
    Write-Host ""
  } elseif ($stopOccurred) {
    Write-Host ""
  } else {
    Write-Host ""
    Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " All operations completed successfully." -ForegroundColor Green
    Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
  }

  # Prompt to return to the menu or exit
  Write-Host " Press 'Escape' to exit or any other key to return to the menu..." -ForegroundColor Green

  $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
  if ($key.VirtualKeyCode -eq 27) { # 27 is the virtual key code for Escape
    break # Exit the loop, which ends the script
  }

  Clear-Host
} while ($true) # changed to 'true' to ensure the loop continues unless 'Escape' is pressed
