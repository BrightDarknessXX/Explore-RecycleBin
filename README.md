# Explore Recycle Bin

This script helps you inspect, review, and clean up the Windows Recycle Bin folders on local drives.

## What it does

The script checks whether it is running with administrator privileges. If not, it asks for elevation (UAC) and relaunches itself as an elevated process so it can access the system-level `$RECYCLE.BIN` folders.

After startup, it presents a small interactive menu with these options:

1. Find and list Recycle Bin folders
   - Scans all local logical disks
   - Reports each disk's `$RECYCLE.BIN` directory if it exists

2. List Recycle Bin contents
   - Lets you enter one or more drive letters (for example: `C: D:`)
   - Optionally lists all drives if you leave it blank
   - Shows each file's name, path, and size in MB

3. Remove all `$RECYCLE.BIN` folders
   - Deletes the Recycle Bin folders from all detected drives
   - Prompts for confirmation before doing so

4. Exit
   - Closes the script

## How it works

The script uses Windows Management Instrumentation (WMI/CIM) to enumerate logical disks via `Get-CimInstance -ClassName Win32_LogicalDisk`. For each disk, it checks whether a `$RECYCLE.BIN` directory exists and operates on it as needed.

## Run

Run the script from PowerShell:

```powershell
.\Explore-RecycleBin.ps1
```

Use the menu to:

1. **Find and list bins** — show the path of each existing `$RECYCLE.BIN` directory found on detected logical disks.
2. **List bin contents** — list files with their size in MB, name, and containing directory. When `EnterDrive` is enabled, enter drive IDs separated by spaces (for example, `C: D:`), or leave the prompt blank to include all disks.
3. **Remove all `$RECYCLE.BIN` folders** — when `EnterDrive` is enabled, enter drive IDs or leave the prompt blank to target all disks. Type `y` at the confirmation prompt to proceed.
4. **Options** — toggle `More` output paging, `EnterDrive` drive prompts for listing and removal, and `RecurseDelete` recursive deletion.
`q` **Quit** — close the script.

When `RecurseDelete` is disabled, removal is attempted without recursive deletion; you will be prompted for extra confirmation.

## How it works

The script enumerates disks with `Get-CimInstance -ClassName Win32_LogicalDisk` and checks each disk for a `$RECYCLE.BIN` directory.

## Caution

Option 3 permanently deletes the selected `$RECYCLE.BIN` directories and their contents. Verify the target drives before confirming.
