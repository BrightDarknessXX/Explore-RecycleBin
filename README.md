# Explore Recycle Bin

This script helps you inspect, review, and clean up the Windows Recycle Bin folders on local drives.

## What it does

The script checks whether it is running with administrator privileges. If not, it asks for elevation (UAC) and relaunches itself as an elevated process so it can access the system-level `$RECYCLE.BIN` folders.

After startup, it presents a small interactive menu with these options:

1. Find and list Recycle Bin folders
   - Scans all local logical disks
   - Reports each disk's `$RECYCLE.BIN` directory if it exists

2. List Recycle Bin contents
   - Lets you enter one or more drive letters (for example: `C D`)
   - Optionally lists all drives if you leave it blank
   - Shows each file's name, path, and size in MB

3. Remove all `$RECYCLE.BIN` folders
   - Deletes the Recycle Bin folders from all detected drives
   - Prompts for confirmation before doing so

4. Exit
   - Closes the script

## How it works

The script uses Windows Management Instrumentation (WMI/CIM) to enumerate logical disks via `Get-CimInstance -ClassName Win32_LogicalDisk`. For each disk, it checks whether a `$RECYCLE.BIN` directory exists and operates on it as needed.

## Example usage

Run the script from PowerShell:

```powershell
.\Explore-RecycleBin.ps1
```

Then choose an option from the menu:

- `1` to find Recycle Bin locations
- `2` to inspect contents
- `3` to remove all Recycle Bin folders
- `4` to exit

## Notes

- This script is intended for Windows systems.
- Administrative privileges are required to access and remove `$RECYCLE.BIN` directories.
- Removing the Recycle Bin folders permanently deletes their contents, so use option 3 with caution.

## Safety warning

This script deletes files from the Windows Recycle Bin directories. Before using the removal option, make sure you understand the consequences and have a backup if needed.
