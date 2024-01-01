# D2BS Management & Cleanup Tool (D2bsCleaner)

## Overview
The Diablo II Bot Management & Cleanup Tool, previously known as D2bsCleaner, is a sophisticated PowerShell script designed for the efficient management and cleanup of directories within the Diablo II, Kolbot, and Kolbot-SoloPlay environments. Featuring dynamic cooldown optimization based on drive type and CPU core count, this tool adapts to various system specifications, ensuring efficient operations.

## Version
3.0

## Key Features
- Expanded functionality for comprehensive management of Diablo II and Kolbot directories.
- Dynamic cooldown optimization tailored to system specifications.
- Enhanced user interface for improved readability and interaction.
- Streamlined confirmation method for file deletion.
- Advanced error handling with detailed feedback.
- Efficient execution and resource management.
- Regular updates for bug fixes and performance optimization.

## System Requirements
- PowerShell version 5.0 or higher.
- Access to Diablo II and Kolbot directories.

## Installation and Setup
1. Create a folder named 'Tools' in the same directory as your D2Bot.exe file.
2. Place the `D2bsCleaner.ps1` script inside the 'Tools' folder.
3. Run the script using PowerShell or through the `D2bsCleanerLauncher` for easy access.

## Configuration Wizard and `config.json`
On the first run, the Configuration Wizard will automatically launch to guide you through the initial setup. It will create a `config.json` file to store your preferences and system specifications. This file will be used in subsequent runs of the tool. If you need to update your configuration, simply delete the `config.json` file, and the wizard will reappear on the next run to assist you in setting up again.

## Usage Instructions
1. Run the script directly using PowerShell or via the `D2bsCleanerLauncher`.
2. Choose an option from the main menu corresponding to specific directories or tasks.
3. Follow the on-screen prompts for confirmations and required inputs.

## Available Options
- **Version History** - View the comprehensive version history of the script.
- **Clean up Diablo II Folder** - Manage and clean various aspects of the Diablo II directory.
- **Clean up Kolbot Folders** - Execute cleanup tasks for Kolbot-related directories.
- **Exit** - Close the application.
- **Configuration Wizard** - Guide through the setup and configuration process.

## Version History
- **1.0 to 2.2** - Initial releases, enhancements, and optimizations.
- **3.0** - Major update with UI overhaul, Diablo II directory management, and various optimizations.

## Author
Butterz

## Disclaimer
This script is provided "as is" without any warranties. Users assume all risks associated with its use. The author is not responsible for any potential damage or data loss.

## License
GNU General Public License

## Discord
[Join our community](https://discord.gg/ZJpBrkgwA7) for support, updates, and discussions.
