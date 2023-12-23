# D2bsCleaner

## Overview
D2bsCleaner is a sophisticated PowerShell script tailored for targeted and comprehensive cleanup of directories within the Kolbot and Kolbot-SoloPlay environments. It integrates an advanced cooldown optimization mechanism, adapting dynamically based on the drive type (HDD or SSD) and CPU core count. This optimization ensures efficient and adaptable operations across various system specifications.

## Version
2.2

## Key Features
- Selective and complete directory cleanup capabilities.
- Dynamic cooldown calculation tailored to drive type and CPU core count.
- Unified confirmation for the 'Perform All Tasks' option, minimizing repetitive confirmations.
- Robust error handling and script stability enhancements.
- Case-insensitive subfolder name validation.
- Continuous bug fixes and performance enhancements.

## System Requirements
- PowerShell version 5.0 or higher.
- Access to directories for script management.

## Installation and Setup
1. Create a folder named 'Tools' in the same directory where your D2Bot.exe file resides.
2. Place the `D2bsCleaner.ps1` script inside the 'Tools' folder.
3. Optionally, for ease of use, utilize the `D2bsCleanerLauncher`.

## Usage Instructions
1. Run the script using PowerShell or via the D2bsCleanerLauncher.
2. Select a desired action from the menu. Each option is linked to a specific directory or task.
3. Follow the prompts on your screen for confirmations and any required input.

## Available Options
1. **Clean Folder (logs)** - Purges all files in the 'logs' folder.
2. **Clean Folder (d2bs\logs)** - Removes all files within 'd2bs\logs'.
3. **Clean Subfolders (d2bs\kolbot\logs\Kolbot-SoloPlay)** - Cleans files in designated subfolders.
4. **Clean Subfolders (d2bs\kolbot\mules)** - Clears files in specified subfolders.
5. **Clean Folder (d2bs\kolbot\data)** - Eliminates all files in 'd2bs\kolbot\data'.
6. **Clean Folder (d2bs\kolbot\libs\SoloPlay\Data)** - Erases all files in 'd2bs\kolbot\libs\SoloPlay\Data'.
7. **Delete ScriptErrorLog.txt (d2bs\kolbot\logs)** - Deletes the 'ScriptErrorLog.txt' file.
8. **Delete Profile.json (data)** - Removes the 'profile.json' file. Exercise caution.
9. **Perform All Tasks** - Executes a comprehensive cleanup across all tasks.
10. **Exit (Close Program)** - Terminates the application.

## Version History
- **1.0** - Initial release.
- **1.1 to 2.1** - Series of enhancements and bug fixes.
- **2.2** - Introduction of Advanced Cooldown Optimization, consolidated task confirmation, enhanced error handling, subfolder name validation improvements, alongside various bug fixes and performance upgrades.

## Author
Butterz

## Disclaimer
This script is provided "as is" with no warranties of any kind. Users should operate it at their own risk. The author bears no responsibility for any potential damage or data loss resulting from script usage.

## License
GNU General Public License

## Discord
https://discord.gg/ZJpBrkgwA7

