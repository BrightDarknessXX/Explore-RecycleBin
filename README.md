# Explore Recycle Bin

An interactive PowerShell script for finding, inspecting, and removing Windows `$RECYCLE.BIN` directories on logical disks.

## Requirements

- Windows PowerShell or PowerShell 7 on Windows.
- Administrator privileges. If the script is not elevated, it requests elevation through UAC and relaunches itself.

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
