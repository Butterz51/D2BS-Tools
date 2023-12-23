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
  $versionText = "Version: 2.2 "
  $authorText = " Author: Butterz"

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
  Write-Host "`n Version History: `n" -ForegroundColor DarkGray
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
  Write-Host "    2.2 (22/12/2023) - Advanced Cooldown Optimization with dynamic calculation based on drive type and CPU core count." -ForegroundColor DarkGray
  Write-Host "                        Implemented global confirmation for 'Perform All Tasks' option to reduce repetitive confirmation prompts." -ForegroundColor DarkGray
  Write-Host "                        Improved error handling and script stability. Enhanced subfolder name validation to be case-insensitive." -ForegroundColor DarkGray
  Write-Host "                        Various bug fixes and performance improvements." -ForegroundColor DarkGray
  Write-Host ""
  Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
  $script:errorOccurred = $false
  $script:stopOccurred = $true
}

function ShowDescription {
  ShowCredits
  Write-Host "`n Description: `n"
  Write-Host "   This script is designed to clean up specified directories in the Kolbot and `n"
  Write-Host "     Kolbot-SoloPlay environments. It provides options for selective or complete `n"
  Write-Host "     cleanup and reports detailed errors for better diagnostics. The user can `n"
  Write-Host "     choose specific folders to clean or perform a full cleanup. `n`n`n"

  Write-Host " Usage: `n"
  Write-Host "   Run the script and choose an option from the menu. Each option corresponds to `n"
  Write-Host "     a specific directory or task. `n`n"
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

# Global Variables
$global:driveType = $null
$global:coreCount = $null
$global:confirmAllTasks = $false

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

function Get-DriveType {
  $driveType = $null

  while ($null -eq $driveType) {
    Write-Host "`n Is the Kolbot folder saved on an HDD or an SSD?`n" -ForegroundColor Yellow
    Write-Host "  1: HDD`n"
    Write-Host "  2: SSD`n"
    $input = Read-Host "  Enter your choice (1 or 2)"
      
    if ($input -eq "1" -or $input -eq "2") {
      $driveType = $input
    } else {
      Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      Write-Host " Invalid input. Please enter '1' for HDD or '2' for SSD." -ForegroundColor DarkRed
      Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
    }
  }
  Clear-Host
  return $driveType
}

function Get-CoreCount {
  $coreCount = $null

  while ($null -eq $coreCount) {
    Write-Host "`n How many cores does your CPU have? (Maximum 64)`n" -ForegroundColor Yellow
    $input = Read-Host "  Enter the number of cores (1-64)"

    if ($input -match "^\d+$" -and [int]$input -ge 1 -and [int]$input -le 64) {
      # Check if input is 1 for singular or more for plural
      $coreText = if ($input -eq "1") { "1 core" } else { "$input cores" }
      Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
      Write-Host " You entered: $coreText. If this is correct, press Enter. To re-enter, press Escape."
      Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
      $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

      if ($key.VirtualKeyCode -eq 13) { # Enter key
        $coreCount = [int]$input
      }
    } else {
      Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      Write-Host " Invalid input. Please enter a number between 1 and 64." -ForegroundColor DarkRed
      Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
    }
  }
  Clear-Host
  return $coreCount
}

function Calculate-Cooldown {
  param (
    [string]$path,
    [int]$driveType,
    [int]$coreCount
  )

  $totalSizeBytes = (Get-ChildItem -Path $path -File -Recurse | Measure-Object -Property Length -Sum).Sum
  $totalSizeMB = [math]::Round($totalSizeBytes / 1MB)

  # Cooldown settings based on drive type
  $secondsPerMB_HDD = 0.5
  $secondsPerMB_SSD = 0.05

  # Base factor for a 4-core CPU
  $baseFactor = 0.2344

  # Adjust cooldown based on core count (less time with more cores)
  # For SSD, the minimum cooldown is 0.1 seconds per MB with 64 cores.
  # For HDD, the cooldown is adjusted similarly but starts at a higher base rate.
  $cooldownAdjustmentFactor = $baseFactor / $coreCount
  
  if ($driveType -eq "2") {
    $secondsPerMB = $secondsPerMB_SSD
  } else {
    $secondsPerMB = $secondsPerMB_HDD
  }
  
  $cooldown = [math]::Max(1, $totalSizeMB * $secondsPerMB * $cooldownAdjustmentFactor) 

  return $cooldown
}

function Confirm-Deletion {
  param (
    [string]$message,
    [string]$itemPath
  )

  # Check if global confirmation for all tasks is set
  if ($global:confirmAllTasks) {
    return $true
  }

  while ($true) {
    Write-Host "`n`n $message $itemPath" -NoNewline -ForegroundColor Yellow
    Write-Host "`n ----------------------------------------------------------------------------------------------------------------------------------------`n" -ForegroundColor DarkGray
    $confirmation = Read-Host "    Type 'y' to continue or 'n' to cancel (y/n)"
    switch ($confirmation.ToLower()) {
      "y" { return $true }
      "n" {
        Clear-Host
        return $false
      }
      default {
        Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
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
    $cooldown = Calculate-Cooldown -path $path -driveType $global:driveType -coreCount $global:coreCount

    if (Confirm-Deletion " Are you sure you want to delete all files and subfolders in:`n`n" $path) {
      Write-Host "`n Cleaning up: $path`n" -ForegroundColor Green

      # Perform deletion
      Remove-Item "$path\*" -Recurse -Force

      # Start countdown timer
      Start-Countdown -DurationInSeconds $cooldown
    } else {
      Write-Host "`n Deletion canceled for $path" -ForegroundColor Yellow
      Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------`n" -ForegroundColor DarkGray
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
    if ($subfolderNames.ToLower() -eq "all") { 
      return $validSubfolderNames 
    }
      
    $subfolderNameArray = $subfolderNames.Split(' ')
    $isValid = $true

    foreach ($name in $subfolderNameArray) {
      if (-not (IsValidSubfolderName $name)) {
        $isValid = $false
        break
      }
    }

    if ($isValid) { 
      return $subfolderNameArray 
    } else {
      Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
    Write-Host " Invalid input." -ForegroundColor DarkRed -NoNewline
    Write-Host " Please enter valid subfolder names (USEast, USWest, Asia, Europe) or 'all'." -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
    }
  } while ($true)
}

# Arrays
$validSubfolderNames = @("USEast", "USWest", "Asia", "Europe")

# Main script starts here
$global:driveType = Get-DriveType
$global:coreCount = Get-CoreCount

# Main Menu
do {
  ShowDescription
  Write-Host "`n  Choose an action:"
  Write-Host "`n        0. Version History - Displays the script's version history." -ForegroundColor Gray
  Write-Host "`n        1. Clean Folder (logs) - Permanently deletes all files in the 'logs' folder." -ForegroundColor Green
  Write-Host "`n        2. Clean Folder (d2bs\logs) - Permanently deletes all files in 'd2bs\logs'." -ForegroundColor Green
  Write-Host "`n        3. Clean Subfolders (d2bs\kolbot\logs\Kolbot-SoloPlay) - Permanently deletes files in specified subfolders." -ForegroundColor Green -NoNewline
  Write-Host "  INPUT REQUIRED" -ForegroundColor Yellow
  Write-Host "`n        4. Clean Subfolders (d2bs\kolbot\mules) - Permanently deletes files in specified subfolders." -ForegroundColor Green -NoNewline
  Write-Host "  INPUT REQUIRED" -ForegroundColor Yellow
  Write-Host "`n        5. Clean Folder (d2bs\kolbot\data) - Permanently deletes all files in 'd2bs\kolbot\data'." -ForegroundColor Green
  Write-Host "`n        6. Clean Folder (d2bs\kolbot\libs\SoloPlay\Data) - Permanently deletes all files in 'd2bs\kolbot\libs\SoloPlay\Data'." -ForegroundColor Green
  Write-Host "`n        7. Delete ScriptErrorLog.txt (d2bs\kolbot\logs) - Permanently deletes the 'd2bs\kolbot\logs\ScriptErrorLog.txt' file." -ForegroundColor Green
  Write-Host "`n        8. Delete Profile.json - Permanently deletes the 'profile.json' file (data). Use with caution." -ForegroundColor DarkRed
  Write-Host "`n        9. Perform All Tasks - Executes all cleaning tasks, including subfolder deletions."  -ForegroundColor DarkRed -NoNewline
  Write-Host "  INPUT IS REQUIRED for specific subfolders." -ForegroundColor Yellow
  Write-Host "`n        10. Exit (Close Program)`n`n" -ForegroundColor Red
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
      Write-Host "`n`n Please enter valid subfolder names (e.g., 'useast', 'uswest', 'asia', 'europe') for Kolbot-SoloPlay, or type 'all' for all subfolders."
      $subfolders3 = GetValidSubfolderNames "  separated by spaces, or type 'all' to remove all subfolders."
      $soloPlayBasePath = Join-Path $baseDir "d2bs\kolbot\logs\Kolbot-SoloPlay"

      if ($subfolders3 -contains "all") {
        # Get all subfolders and clean them up
        $subfolderPaths = Get-ChildItem -Path $soloPlayBasePath -Directory
        foreach ($subfolderPath in $subfolderPaths) {
          CleanUp $subfolderPath.FullName
        }
      } else {
        foreach ($subfolder in $subfolders3) {
          $subfolderPath = Join-Path $soloPlayBasePath $subfolder
          CleanUp $subfolderPath
        }
      }

      if ($errorOccurred) {
        Write-Host "`n`n`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        Write-Host " Errors occurred in: $($errorList -join ', ')" -ForegroundColor DarkRed
        Write-Host " Please enter valid subfolder names (e.g., 'USEast', 'USWest', 'Asia', 'Europe') for Kolbot-SoloPlay," -ForegroundColor DarkRed
        Write-Host " separated by spaces, or type 'all' to remove all subfolders." -ForegroundColor DarkRed
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------`n" -ForegroundColor DarkRed
      }
    }

    "4" {
      Write-Host "`n Please enter valid subfolder names (e.g., 'USEast', 'USWest', 'Asia', 'Europe') for Kolbot-SoloPlay, or type 'all' for all subfolders."
      $subfolders4 = GetValidSubfolderNames "  separated by spaces, or type 'all' to remove all subfolders."
      $mulesBasePath = Join-Path $baseDir "d2bs\kolbot\mules"

      if ($subfolders4 -contains "all") {
        # Get all subfolders and clean them up
        $subfolderPaths = Get-ChildItem -Path $mulesBasePath -Directory
        foreach ($subfolderPath in $subfolderPaths) {
          CleanUp $subfolderPath.FullName
        }
      } else {
        foreach ($subfolder in $subfolders4) {
          $subfolderPath = Join-Path $mulesBasePath $subfolder
          CleanUp $subfolderPath
        }
      }

      if ($errorOccurred) {
        Write-Host "`n`n`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        Write-Host " Errors occurred in: $($errorList -join ', ')" -ForegroundColor DarkRed
        Write-Host " Please enter valid subfolder names (e.g., 'USEast', 'USWest', 'Asia', 'Europe') for Kolbot\mules," -ForegroundColor DarkRed
        Write-Host " separated by spaces, or type 'all' to remove all subfolders." -ForegroundColor DarkRed
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------`n" -ForegroundColor DarkRed
      }
    }


    "5" { CleanUp $folder5 }

    "6" { CleanUp $folder6 }

    "7" {
      if (Test-Path $fileToDelete1) {
        if (Confirm-Deletion (" Are you sure you want to delete the file:`n`n" + " $fileToDelete1" + "?`n`n")) {
          Write-Host "`n`n File deleted: $fileToDelete1`n" -ForegroundColor Green
          Remove-Item $fileToDelete1 -Force
          $cooldown = Calculate-Cooldown -path $path -driveType $global:driveType -coreCount $global:coreCount
          Start-Countdown -DurationInSeconds $cooldown
        } else {
          Write-Host "`n Deletion canceled for $fileToDelete1" -ForegroundColor Yellow
          Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
          $stopOccurred = $true
        }
      } else {
        Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        Write-Host " File not found: $fileToDelete1" -ForegroundColor DarkRed
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        $stopOccurred = $true
      }
    }

    "8" {
      if (Test-Path $fileToDelete1) {
        if (Confirm-Deletion ("Are you sure you want to delete the file:`n" + $fileToDelete2 + "`n?")) {
          Write-Host "`n`n File deleted: $fileToDelete2`n" -ForegroundColor Green
          Remove-Item $fileToDelete1 -Force
          $cooldown = Calculate-Cooldown -path $path -driveType $global:driveType -coreCount $global:coreCount
          Start-Countdown -DurationInSeconds $cooldown
        } else {
          Write-Host "`n Deletion canceled for $fileToDelete2" -ForegroundColor Yellow
          Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
          $stopOccurred = $true
        }
      } else {
        Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        Write-Host " File not found: $fileToDelete2" -ForegroundColor DarkRed
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        $stopOccurred = $true
      }
    }

    "9" {
      Write-Host "`n`n You have chosen to perform all tasks. This will delete files in multiple directories.`n" -ForegroundColor Red
      $confirmAll = Read-Host "  Are you sure you want to proceed? (y/n)"
      if ($confirmAll -eq 'y') {
        $global:confirmAllTasks = $true
        $errorOccurred = $false

        CleanUp $folder1
        CleanUp $folder2

        Write-Host "`n`n Please enter valid subfolder names (e.g., 'USEast', 'USWest', 'Asia', 'Europe') for Kolbot-SoloPlay, or type 'all' for all subfolders."
        $subfolders3 = GetValidSubfolderNames "  separated by spaces, or type 'all' to remove all subfolders."
        $soloPlayBasePath = Join-Path $baseDir "d2bs\kolbot\logs\Kolbot-SoloPlay"

        if ($subfolders3 -contains "all") {
          # Get all subfolders and clean them up
          $subfolderPaths = Get-ChildItem -Path $soloPlayBasePath -Directory
          foreach ($subfolderPath in $subfolderPaths) {
            CleanUp $subfolderPath.FullName
          }
        } else {
          foreach ($subfolder in $subfolders3) {
            $subfolderPath = Join-Path $soloPlayBasePath $subfolder
            CleanUp $subfolderPath
          }
        }

        Write-Host "`n`n Please enter valid subfolder names (e.g., 'USEast', 'USWest', 'Asia', 'Europe') for Kolbot-SoloPlay, or type 'all' for all subfolders."
        $subfolders4 = GetValidSubfolderNames "  separated by spaces, or type 'all' to remove all subfolders."
        $mulesBasePath = Join-Path $baseDir "d2bs\kolbot\mules"

        if ($subfolders4 -contains "all") {
          # Get all subfolders and clean them up
          $subfolderPaths = Get-ChildItem -Path $mulesBasePath -Directory
          foreach ($subfolderPath in $subfolderPaths) {
            CleanUp $subfolderPath.FullName
          }
        } else {
          foreach ($subfolder in $subfolders4) {
            $subfolderPath = Join-Path $mulesBasePath $subfolder
            CleanUp $subfolderPath
          }
        }

        CleanUp $folder5
        CleanUp $folder6

        if (Test-Path $fileToDelete1) { Remove-Item $fileToDelete1 -Force }
        if (Test-Path $fileToDelete2) { Remove-Item $fileToDelete2 -Force }

        $global:confirmAllTasks = $false
        
        Write-Host "`n ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host " All tasks have been completed." -ForegroundColor Green
        Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
      } else {
        Write-Host "`n ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host " Operation canceled. Returning to main menu." -ForegroundColor Yellow
        Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
        $stopOccurred = $true
      }
    }

    "10" {
      Write-Host "`n Closing the application.`n"
      Start-Countdown -DurationInSeconds 5
      exit
    }

    "exit" {
      Write-Host "`n Closing the application.`n"
      Start-Countdown -DurationInSeconds 5
      exit
    }

    default {
      Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      Write-Host " Invalid option selected. " -ForegroundColor DarkRed -NoNewline
      Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      Write-Host "`n Please enter a valid choice from the menu." -ForegroundColor Yellow
      $errorOccurred = $false
      $stopOccurred = $true
    }
  }

  if ($errorOccurred) {
    Write-Host "`n`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
    Write-Host " Errors occurred in: $($errorList -join ', ')" -ForegroundColor DarkRed
    Write-Host "----------------------------------------------------------------------------------------------------------------------------------------`n" -ForegroundColor DarkRed
  } elseif ($stopOccurred) {
    Write-Host ""
  } else {
    Write-Host "`n ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " All operations completed successfully." -ForegroundColor Green
    Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------`n" -ForegroundColor DarkGray
  }

  # Prompt to return to the menu or exit
  Write-Host "`n Press " -NoNewline -ForegroundColor Green
  Write-Host "'Escape'" -NoNewline -ForegroundColor DarkRed
  Write-Host " to exit or any other key to return to the menu..." -ForegroundColor Green

  $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

  if ($key.VirtualKeyCode -eq 27) { # 27 is the virtual key code for Escape
    break # Exit the loop, which ends the script
  }

  Clear-Host
} while ($true) # changed to 'true' to ensure the loop continues unless 'Escape' is pressed
