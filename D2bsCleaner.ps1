##################################
#  @filename    D2bsCleaner.sp1  #
#  @author      Butterz          #
##################################

# Set Window Title
$host.UI.RawUI.WindowTitle = "D2BS Management & Cleanup Tool"

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

# Global Variables
$jsonFilePath = Join-Path $PSScriptRoot "Config.json"
$global:config = @{}
$global:confirmAllTasks = $false

# JSON Functions
# Check if the JSON file exists and read it
function CheckAndReadJsonFile {
  if (Test-Path $jsonFilePath) {
    $global:config = Read-JsonFile $jsonFilePath

    # Check if any configuration details are missing
    if ($null -eq $global:config.CoreCount -or
        $null -eq $global:config.DriveType -or
        $null -eq $global:config.DiabloIIFolderPath) {
      # Run SetupWizard if any details are missing
      SetupWizard
    }
  } else {
    # Run SetupWizard if JSON file does not exist
    SetupWizard
  }
}

# Read-JsonFile Function
function Read-JsonFile($FilePath) {
  $jsonContent = Get-Content $FilePath | Out-String | ConvertFrom-Json

  # Remove extra quotes from the DiabloIIFolderPath if present
  if ($jsonContent.DiabloIIFolderPath.StartsWith('"') -and $jsonContent.DiabloIIFolderPath.EndsWith('"')) {
    $jsonContent.DiabloIIFolderPath = $jsonContent.DiabloIIFolderPath.Trim('"')
  }

  return $jsonContent
}

# Write-JsonFile Function
function Write-JsonFile($FilePath, $config) {
  $jsonContent = $config | ConvertTo-Json -Depth 5
  Set-Content -Path $FilePath -Value $jsonContent
}

# Setup Wizard Function
function SetupWizard() {
  Clear-Host
  $coreCount = Get-CoreCount
  $driveType = Get-DriveType
  $inputPath = Set-DiabloIIFolderPath
  Write-Host "`n`n  Configuration Wizard Is Now Complete." -ForegroundColor Green; Start-Sleep -Seconds 5

  # Update global config
  $global:config.CoreCount = $coreCount
  $global:config.DriveType = $driveType
  $global:config.DiabloIIFolderPath = $inputPath
}

# Base Config Functions
function Get-DriveType() {
  if ($null -ne $global:config.DriveType) {
    return $global:config.DriveType
  }

  $driveType = $null
  while ($null -eq $driveType) {
    Write-Host "`n Is the Kolbot or Diablo II directory saved on an HDD or an SSD?`n" -ForegroundColor Yellow
    Write-Host "  1: HDD`n"
    Write-Host "  2: SSD`n"
    $input = Read-Host "  Enter your choice (1 for HDD, 2 for SSD)"
    
    if ($input -eq "1" -or $input -eq "2") {
      $driveTypeInput = if ($input -eq "1") { "HDD" } else { "SSD" }
      Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
      Write-Host " You entered: $driveTypeInput. Press 'Enter' to confirm or 'R' to re-enter your choice."
      Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray

      $confirmation = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
      if ($confirmation.Character -eq [char]13) { # Enter key
        $driveType = $driveTypeInput
      } elseif ($confirmation.Character -eq 'R' -or $confirmation.Character -eq 'r') {
        Write-Host "`n Re-enter your choice." -ForegroundColor Yellow
      } else {
        Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        Write-Host " Invalid key. Please press 'Enter' to confirm or 'R' to re-enter your choice." -ForegroundColor Red
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      }
      Clear-Host
    } else {
      Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      Write-Host " Invalid input. Please enter '1' for HDD or '2' for SSD." -ForegroundColor DarkRed
      Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      WaitForRToReturn
    }
  }

  # Update global config
  $global:config.DriveType = $driveType

  # Write to JSON file
  Write-JsonFile $jsonFilePath $global:config

  return $driveType
}

function Get-CoreCount {
  if ($null -ne $global:config.CoreCount) {
    return $global:config.CoreCount
  }

  $coreCount = $null
  while ($null -eq $coreCount) {
    Write-Host "`n How many cores does your CPU have? (Maximum 64)`n" -ForegroundColor Yellow
    $input = Read-Host "  Enter the number of cores (1-64)"

    if ($input -match "^\d+$" -and [int]$input -ge 1 -and [int]$input -le 64) {
      $coreText = if ($input -eq "1") { "1 core" } else { "$input cores" }
      Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
      Write-Host " You entered: $coreText. Press 'Enter' to confirm or 'R' to re-enter your choice."
      Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
      
      $confirmation = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
      if ($confirmation.Character -eq [char]13) { # Enter key
        $coreCount = [int]$input
      } elseif ($confirmation.Character -eq 'R' -or $confirmation.Character -eq 'r') {
        Write-Host "`n Re-enter your choice." -ForegroundColor Yellow
      } else {
        Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
        Write-Host " Invalid key. Please press 'Enter' to confirm or 'R' to re-enter your choice." -ForegroundColor Red
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      }
      Clear-Host
    } else {
      Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      Write-Host " Invalid input. Please enter a number between 1 and 64." -ForegroundColor DarkRed
      Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      WaitForRToReturn
    }
  }

  # Update global config
  $global:config.CoreCount = $coreCount

  # Write to JSON file
  Write-JsonFile $jsonFilePath $global:config

  return $coreCount
}

function Set-DiabloIIFolderPath {
  if ($null -ne $global:config.DiabloIIFolderPath) {
    return $global:config.DiabloIIFolderPath
  }

  # Function to check if the required files exist in the directory
  function ValidateDiabloIIDirectory($directory) {
    $requiredFiles = @('Game.exe', 'BNUpdate.exe')
    foreach ($file in $requiredFiles) {
      if (-not (Test-Path (Join-Path $directory $file))) {
        return $false
      }
    }
    return $true
  }

  do {
    Write-Host "`n Please enter the path to your Diablo II installation directory or type 'back' to return:" -ForegroundColor Yellow
    $inputPath = Read-Host "`n Diablo II Path or 'back'"

    if ($inputPath -eq 'back') {
      return
    } elseif ((Test-Path $inputPath) -and (ValidateDiabloIIDirectory $inputPath)) {
      # Update global config
      $global:config.DiabloIIFolderPath = $inputPath
      Write-Host "`n Diablo II directory is correctly set to: $($global:config.DiabloIIFolderPath)" -ForegroundColor Green

      # Write to JSON file
      Write-JsonFile $jsonFilePath $global:config
      break
    } else {
      Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      Write-Host " Invalid path or required files not found. Please try again or type 'back' to return." -ForegroundColor Red
      Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      WaitForRToReturn
    }
  } while ($true)
}

function Calculate-Cooldown {
  param (
    [string]$path,
    [bool]$image = $false
  )

  # Use global variables for drive type and core count
  $CoreCount = $global:config.coreCount
  $DriveType = $global:config.driveType

  $totalSizeBytes = 0

  if ($image) { # Filter to only get .jpg files
    $jpgFiles = Get-ChildItem -Path $path -Recurse -File -Filter "*.jpg"
    $totalSizeBytes = ($jpgFiles | Measure-Object -Property Length -Sum).Sum
  }
  elseif (Test-Path -Path $path -PathType Container) {
    # It's a directory. Calculate total size of all files within the directory.
    $totalSizeBytes = (Get-ChildItem -Path $path -Recurse -File | Measure-Object -Property Length -Sum).Sum
  }
  elseif (Test-Path -Path $path) {
    # It's a file. Get the size of the file.
    $totalSizeBytes = (Get-Item -Path $path).Length
  }
  else {
    Write-Host "Path not found: $path" -ForegroundColor Red
    return 0
  }

  $totalSizeMB = [math]::Round($totalSizeBytes / 1MB)

  # Cooldown settings based on drive type
  $secondsPerMB_HDD = 0.5  # 0.5 = 500 ms
  $secondsPerMB_SSD = 0.05 # 0.05 = 50 ms

  # Base factor for a 4-core CPU
  $baseFactor = 0.2344

  # Adjust cooldown based on core count
  $cooldownAdjustmentFactor = $baseFactor / $coreCount
  
  if ($driveType -eq "SSD") {
    $secondsPerMB = $secondsPerMB_SSD
  } else {
    $secondsPerMB = $secondsPerMB_HDD
  }
  #$secondsPerMB = $driveType -eq "SSD" ? $secondsPerMB_SSD : $secondsPerMB_HDD # NEEDS A NEWER VERSION OF PS TO WORK
  $cooldown = [math]::Max(1, $totalSizeMB * $secondsPerMB * $cooldownAdjustmentFactor) 

  return $cooldown
}

function Start-Countdown {
  param (
    [int]$DurationInSeconds,
    [bool]$IsCleanupInProgress = $false,
    [bool]$IsCleanupCompleted = $false
  )

  foreach ($second in $DurationInSeconds..1) {
    # Calculate the length of the string to overwrite
    $overwriteLength = (" Waiting for $second second(s)...").Length

    # Overwrite the entire line
    Write-Host ("`r" + " Waiting for $second second(s)..." + (" " * $overwriteLength)) -NoNewline -ForegroundColor Green

    Start-Sleep -Seconds 1
  }

  Write-Host "`r" + (" " * $overwriteLength) -NoNewline

  if ($IsCleanupInProgress) {
    Write-Host "`n  Proceeding..." -ForegroundColor Green
  }

  if ($IsCleanupCompleted) {
    Write-Host "`n Cleanup Finished!" -ForegroundColor Green
  }
}

# JSON Directory/File Checks
CheckAndReadJsonFile

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
$errorList = @()

# Base Functions
function ShowCredits {
  $consoleWidth = $host.UI.RawUI.WindowSize.Width
  $versionText = "Version: 3.0 "
  $authorText = " Author: Butterz"

  # Calculate padding for right alignment
  $totalLength = $versionText.Length + $authorText.Length
  $padding = $consoleWidth - $totalLength
  $paddingText = " " * $padding

  Write-Host ""
  Write-Host ($authorText + $paddingText + $versionText) -ForegroundColor DarkGray
  Write-Host ""
}

# Waits for user to press 'R' to return to the main menu
function WaitForRToReturn {
  Write-Host "`n Press 'R' to return to the menu..." -ForegroundColor Yellow

  do {
    $input = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($input.Character -eq 'R' -or $input.Character -eq 'r') {
      Write-Host "`n Returning to the main menu..."
      ShowMainMenu
      break
    }
  } while ($true)
}

# Waits for user to press 'ANY KEY' to return to the menu
function Prompt2Return($DirectoryName, $CustomMessage = $null) {
  Write-Host "`n Press any key to return to the $DirectoryName menu$CustomMessage..." -NoNewline -ForegroundColor Green
  $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
  Clear-Host
}

# Waits for user to press 'ESCAPE' to exit or 'ANY KEY' to return to the menu
function Prompt2QuitReturn($DirectoryName, $CustomMessage = $null) {
  Write-Host "`n Press " -NoNewline -ForegroundColor Green
  Write-Host "'Escape'" -NoNewline -ForegroundColor DarkRed
  Write-Host " to exit, or press any other key to return to the $DirectoryName menu$CustomMessage..." -ForegroundColor Green
  $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

  if ($key.VirtualKeyCode -eq 27) {
    Write-Host "`n Exiting the application.`n"
    Start-Countdown -DurationInSeconds 5
    exit
  }

  Clear-Host
  break
}

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
  Write-Host "    3.0 (01/01/2024) - Comprehensive user interface overhaul, enhancing readability and user interaction." -ForegroundColor DarkGray
  Write-Host "                        Expanded script functionality to include new cleaning operations for both Diablo II and Kolbot directories." -ForegroundColor DarkGray
  Write-Host "                        Added specific functionality for .jpg file management and BlizzardError folder cleanup in Diablo II directory." -ForegroundColor DarkGray
  Write-Host "                        Improved global configuration management and user input validation for a more streamlined setup process." -ForegroundColor DarkGray
  Write-Host "                        Enhanced error handling and user feedback, providing more detailed and helpful error messages." -ForegroundColor DarkGray
  Write-Host "                        Refined script logic for more efficient execution and resource management." -ForegroundColor DarkGray
  Write-Host "                        Bug fixes and performance optimizations to ensure smoother operation and reliability." -ForegroundColor DarkGray
  Write-Host "                        Updated and expanded script documentation for better clarity and ease of maintenance." -ForegroundColor DarkGray
  Write-Host ""
  Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
  Prompt2Return "Main"
  Clear-Host
}

function ShowMainDescription {
  Write-Host "`n Description:`n`n"
  Write-Host "     Diablo II Bot Maintenance Tool:`n`n"
  Write-Host "        This user-friendly tool simplifies the maintenance of Diablo II bots by keeping the game environment tidy.`n"
  Write-Host "        Key features include automated cleanup of error logs and redundant image files,`n"
  Write-Host "        along with customizable settings for optimized performance.`n"
  Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
}

function ShowKolbotDescription {
  Write-Host "`n Description:`n`n"
  Write-Host "     This script is designed to clean up specified directories in the Kolbot and `n"
  Write-Host "     Kolbot-SoloPlay environments. It provides options for selective or complete `n"
  Write-Host "     cleanup and reports detailed errors for better diagnostics. The user can `n"
  Write-Host "     choose specific folders to clean or perform a full cleanup.`n"
  Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
}

function ShowDiabloDesription {
  Write-Host "`n Description:`n`n"
  Write-Host "     Clean Blizzard Error Folder Function:`n"
  Write-Host "        Manages the cleanup of the BlizzardError folder in the Diablo II directory. It deletes all files in this folder after`n"
  Write-Host "        user confirmation, helping to maintain the game's environment. The function includes error handling and a calculated`n"
  Write-Host "        cooldown period based on system specs.`n`n`n"
  Write-Host "     CleanImageFiles Function:`n`n"
  Write-Host "        Targets and removes unnecessary .jpg files from the Diablo II main directory. After user confirmation, it cleans up these`n"
  Write-Host "        image files and calculates a cooldown period for system efficiency. The function provides feedback in case no files`n"
  Write-Host "        are found or if an error occurs.`n"
  Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
}

function ShowUsage {
  Write-Host "`n Usage:`n"
  Write-Host "   Run the script and choose an option from the menu. Each option corresponds to `n"
  Write-Host "     a specific directory or task.`n"
  Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
}

function ExitScript {
  Write-Host "`n Exiting the application."
  Start-Countdown -DurationInSeconds 5
  exit
}

function ShowMainMenu {
  Clear-Host
  ShowCredits
  ShowMainDescription
  Write-Host "`n Main Menu - Please Choose an Option:`n" -ForegroundColor Cyan
  Write-Host "     1. View Version History" -ForegroundColor Gray
  Write-Host "        - Displays the script's comprehensive version history."
  Write-Host "     2. Clean up Diablo II Folder" -ForegroundColor Green
  Write-Host "        - Initiates the cleanup process for the Diablo II directory."
  Write-Host "     3. Clean up Kolbot Folders" -ForegroundColor Green
  Write-Host "        - Executes cleanup tasks for Kolbot related folders."
  Write-Host "     4. Exit" -ForegroundColor Red
  Write-Host "        - Exits the tool and closes the window."
  Write-Host "     5. Run Configuration Wizard" -ForegroundColor Blue
  Write-Host "        - Guides through the initial setup and configuration process.`n"
  $mainChoice = Read-Host " Enter your choice (1-5)"
  Clear-Host

  return $mainChoice
}

function ShowSetupWizardMenu {
  Clear-Host
  ShowCredits
  Write-Host "`n Configuration Wizard Menu`n" -ForegroundColor Cyan
  Write-Host " Select an option to proceed:`n" -ForegroundColor White
  Write-Host "     1. Initialize Setup" -ForegroundColor Green
  Write-Host "        - Start the setup process to configure necessary settings."
  Write-Host "     2. Return to Main Menu" -ForegroundColor Blue
  Write-Host "        - Go back to the main menu of the tool.`n"
  $setupChoice = Read-Host " Enter your choice (1 or 2)"
  Clear-Host

  return $setupChoice
}

function ShowDiabloIIMenu {
  Clear-Host
  ShowCredits
  ShowDiabloDesription
  Write-Host "`n Diablo II Management Menu`n" -ForegroundColor Cyan
  Write-Host " Select an option to proceed:`n" -ForegroundColor White
  Write-Host "     1. Clean Diablo II Blizzard Error Folder" -ForegroundColor Green
  Write-Host "        - Clears the BlizzardError folder in the Diablo II directory."
  Write-Host "     2. Clean Images from Diablo II Folder" -ForegroundColor Green
  Write-Host "        - Removes all .jpg files from the Diablo II main directory."
  Write-Host "     3. Return to Main Menu" -ForegroundColor Blue
  Write-Host "        - Go back to the main menu of the tool.`n"
  $diabloChoice = Read-Host " Enter your choice (1-3)"
  Clear-Host

  return $diabloChoice
}

function ShowKolbotMenu {
  Clear-Host
  ShowCredits
  ShowKolbotDescription
  ShowUsage
  Write-Host "`n Kolbot Cleanup Options`n" -ForegroundColor Cyan
  Write-Host " Select an option to proceed:`n" -ForegroundColor White
  Write-Host "     1. Clean 'logs' Folder" -ForegroundColor Green
  Write-Host "        - Deletes all files in the 'logs' folder."
  Write-Host "     2. Clean 'd2bs\logs' Folder" -ForegroundColor Green
  Write-Host "        - Deletes all files in 'd2bs\logs'."
  Write-Host "     3. Clean 'd2bs\kolbot\logs\Kolbot-SoloPlay' Subfolders" -ForegroundColor Green
  Write-Host "        - Deletes files in specified subfolders. [Input Required]" -ForegroundColor Yellow
  Write-Host "     4. Clean 'd2bs\kolbot\mules' Subfolders" -ForegroundColor Green
  Write-Host "        - Deletes files in specified subfolders. [Input Required]" -ForegroundColor Yellow
  Write-Host "     5. Clean 'd2bs\kolbot\data' Folder" -ForegroundColor Green
  Write-Host "        - Deletes all files in 'd2bs\kolbot\data'."
  Write-Host "     6. Clean 'd2bs\kolbot\libs\SoloPlay\Data' Folder" -ForegroundColor Green
  Write-Host "        - Deletes all files in 'd2bs\kolbot\libs\SoloPlay\Data'."
  Write-Host "     7. Delete 'ScriptErrorLog.txt'" -ForegroundColor Green
  Write-Host "        - Deletes 'ScriptErrorLog.txt' from 'd2bs\kolbot\logs'."
  Write-Host "     8. Delete 'Profile.json' [Use with Caution]" -ForegroundColor DarkRed
  Write-Host "        - Deletes 'profile.json' from 'data'. Critical action."
  Write-Host "     9. Perform All Tasks [Input Required]" -ForegroundColor DarkRed
  Write-Host "        - Executes all cleaning tasks, including subfolder deletions."
  Write-Host "    10. Return to Main Menu" -ForegroundColor Blue
  Write-Host "        - Go back to the main menu of the tool.`n"
  $kolbotChoice = Read-Host " Enter your choice (1-10 or type 'exit' to quit)"
  Clear-Host

  return $kolbotChoice
}

# Arrays
$validSubfolderNames = @("USEast", "USWest", "Asia", "Europe")

# Clean-Up Functions
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
    $cooldown = Calculate-Cooldown -path $path -image $false

    if (Confirm-Deletion " Are you sure you want to delete all files and subfolders in:`n`n" $path) {
      Write-Host "`n Cleaning up: $path`n" -ForegroundColor Green
      # Perform deletion
      Remove-Item "$path\*" -Recurse -Force
      # Start countdown timer
      if ($global:confirmAllTasks) {
        Start-Countdown -DurationInSeconds $cooldown -IsCleanupInProgress $true
      } else {
        Start-Countdown -DurationInSeconds $cooldown -IsCleanupCompleted $true
      }
    }
  } else {
    Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
    Write-Host " Folder not found: $path" -ForegroundColor DarkRed
    Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
    Prompt2QuitReturn "Kolbot"

    return $false
  }

  return $true
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
      Prompt2QuitReturn "Kolbot" " and try again"
    }
  } while ($true)
}

function CleanBlizzardErrorFolder {
  $Path = $global:config.DiabloIIFolderPath + "\BlizzardError"
  Write-Host "`n`n Diablo II Folder Path: $Path"
  $blizzardErrorPath = Join-Path $global:config.DiabloIIFolderPath "BlizzardError"

  if (Test-Path $blizzardErrorPath) {
    $cooldown = Calculate-Cooldown -path $Path -image $false

    try {
      if (Confirm-Deletion " Are you sure you want to clean the BlizzardError folder?") {
        Write-Host "`n Cleaning BlizzardError folder..." -ForegroundColor Green
        Remove-Item "$blizzardErrorPath\*" -Recurse -Force
        Start-Countdown -DurationInSeconds $cooldown -IsCleanupCompleted $true
        Prompt2Return "Diablo II"
      } else {
        Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host " Cleanup canceled for BlizzardError folder." -ForegroundColor Yellow
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
        Prompt2Return "Diablo II"
      }
    } catch {
      Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      Write-Host " An error occurred: $_" -ForegroundColor Red
      Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      Prompt2QuitReturn "Diablo II"
    }
  } else {
    Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
    Write-Host " BlizzardError folder not found at $blizzardErrorPath" -ForegroundColor Red
    Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
    Prompt2QuitReturn "Diablo II"
  }
}

function CleanImageFiles {
  $Path = $global:config.DiabloIIFolderPath
  Write-Host "`n`n Diablo II Folder Path: $Path"
  $imageFiles = Get-ChildItem -Path $Path -Recurse -Filter *.jpg

  if ($imageFiles.Count -gt 0) {
    $totalSizeBytes = ($imageFiles | Measure-Object -Property Length -Sum).Sum
    $totalSizeMB = [math]::Round($totalSizeBytes / 1MB)
    $cooldown = Calculate-Cooldown -path $Path -image $true

    try {
      if (Confirm-Deletion "`n Are you sure you want to delete all .jpg files in the Diablo II directory?") {
        Write-Host "`n Deleting .jpg files..." -ForegroundColor Green
        $imageFiles | Remove-Item -Force
        Start-Countdown -DurationInSeconds $cooldown -IsCleanupCompleted $true
        Prompt2Return "Diablo II"
      } else {
        Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host " Cleanup canceled for .jpg files." -ForegroundColor Yellow
        Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
        Prompt2QuitReturn "Diablo II"
      }
    } catch {
      Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      Write-Host " An error occurred: $_" -ForegroundColor Red
      Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
      Prompt2QuitReturn "Diablo II"
    }
  } else {
    Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " No .jpg files found in the Diablo II directory." -ForegroundColor Green
    Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Prompt2QuitReturn "Diablo II"
  }
}

do {
  $mainChoice = ShowMainMenu

  switch ($mainChoice) {
    "1" { ShowVersion }

    "2" {
      do {
        $diabloChoice = ShowDiabloIIMenu
        Clear-Host
        switch ($diabloChoice) {
          "1" { CleanBlizzardErrorFolder }
          "2" { CleanImageFiles }
          "3" { ShowMainMenu }
          default { Write-Host "`n Invalid choice. Please try again." -ForegroundColor Red }
        }
      } while ($diabloChoice -ne "3")
    }

    "3" {
      do {
        $kolbotChoice = ShowKolbotMenu
        switch ($kolbotChoice) {
          "1" {
              CleanUp $folder1
          }

          "2" {
              CleanUp $folder2
          }

          "3" {
            Write-Host "`n`n Please enter valid subfolder names (e.g., 'useast', 'uswest', 'asia', 'europe') for Kolbot-SoloPlay, or type 'all' for all subfolders."
            $subfolders3 = GetValidSubfolderNames "  separated by spaces, or type 'all' to remove all subfolders"
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
          }

          "4" {
            Write-Host "`n Please enter valid subfolder names (e.g., 'USEast', 'USWest', 'Asia', 'Europe') for Kolbot-SoloPlay, or type 'all' for all subfolders."
            $subfolders4 = GetValidSubfolderNames "  separated by spaces, or type 'all' to remove all subfolders"
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
          }

          "5" { CleanUp $folder5 }

          "6" { CleanUp $folder6 }

          "7" {
            if (Test-Path $fileToDelete1) {
              if (Confirm-Deletion (" Are you sure you want to delete the file:`n`n" + " $fileToDelete1" + "?`n`n")) {
                Write-Host "`n`n File deleted: $fileToDelete1`n" -ForegroundColor Green
                Remove-Item $fileToDelete1 -Force
                $cooldown = Calculate-Cooldown -path $fileToDelete1 -image $false
                Start-Countdown -DurationInSeconds $cooldown
              } else {
                Write-Host "`n Deletion canceled for $fileToDelete1" -ForegroundColor Yellow
                Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
                Prompt2Return "Kolbot"
              }
            } else {
              Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
              Write-Host " File not found: $fileToDelete1" -ForegroundColor DarkRed
              Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
              Prompt2Return "Kolbot"
            }
          }

          "8" {
            if (Test-Path $fileToDelete2) {
              if (Confirm-Deletion (" Are you sure you want to delete the file:`n" + $fileToDelete2 + "`n?")) {
                Write-Host "`n`n File deleted: $fileToDelete2`n" -ForegroundColor Green
                Remove-Item $fileToDelete2 -Force
                $cooldown = Calculate-Cooldown -path $fileToDelete2 -image $false
                Start-Countdown -DurationInSeconds $cooldown
              } else {
                Write-Host "`n Deletion canceled for $fileToDelete2" -ForegroundColor Yellow
                Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
                Prompt2Return "Kolbot"
              }
            } else {
              Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
              Write-Host " File not found: $fileToDelete2" -ForegroundColor DarkRed
              Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
              Prompt2Return "Kolbot"
            }
          }

          "9" {
            Write-Host "`n`n You have chosen to perform all tasks. This will delete files in multiple directories.`n" -ForegroundColor Red
            $confirmAll = Read-Host "  Are you sure you want to proceed? (y/n)"
            if ($confirmAll -eq 'y') {
              $global:confirmAllTasks = $true

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

              if (Test-Path $fileToDelete1) {
                Remove-Item $fileToDelete1 -Force
                $cooldown = Calculate-Cooldown -path $fileToDelete1 -image $false
                Start-Countdown -DurationInSeconds $cooldown -IsCleanupInProgress $true
              }

              if (Test-Path $fileToDelete2) {
                Remove-Item $fileToDelete2 -Force
                $cooldown = Calculate-Cooldown -path $fileToDelete2 -image $false
                Start-Countdown -DurationInSeconds $cooldown -IsCleanupCompleted $true
              }

              $global:confirmAllTasks = $false
              
              Write-Host "`n ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
              Write-Host " All tasks have been completed." -ForegroundColor Green
              Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
              Prompt2QuitReturn "Kolbot"
            } else {
              Write-Host "`n ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
              Write-Host " Operation canceled. Returning to Kolbot menu." -ForegroundColor Yellow
              Write-Host " ----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
              Prompt2QuitReturn "Kolbot"
            }
          }

          "exit" { ExitScript }

          "10" { ShowMainMenu }

          default {
            Write-Host "`n----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
            Write-Host " Invalid option selected. " -ForegroundColor DarkRed
            Write-Host "----------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkRed
            Write-Host "`n Please enter a valid choice from the Kolbot menu." -ForegroundColor Yellow
          }
        }
      } while ($kolbotChoice -ne "10")
    }

    "4" { ExitScript }

    "5" {
      do {
        $setupChoice = ShowSetupWizardMenu
        Clear-Host
        switch ($setupChoice) {
          "1" { SetupWizard }
          "2" { ShowMainMenu }
          default { Write-Host "`n Invalid choice. Please try again." -ForegroundColor Red }
        }
      } while ($setupChoice -ne "2")
    }

    "exit" { ExitScript }

    default { Write-Host "`n Invalid choice. Please try again." -ForegroundColor Red }
  }
} while ($true)
