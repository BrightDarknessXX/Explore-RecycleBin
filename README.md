# Explore Recycle Bin

This PowerShell script lets you inspect and remove `$RECYCLE.BIN` folders on logical disks detected by Windows.

## Run

Run the script from PowerShell:

```
.\Explore-RecycleBin.ps1
```

If the script is not already running with administrator privileges, it requests elevation through User Account Control (UAC). Use the interactive menu to:

1. **Find and list bins** — show the path of each existing `$RECYCLE.BIN` directory on detected logical disks.
2. **List bin contents** — display files with their size in MB, name, and containing directory. With `EnterDrive` enabled, enter drive IDs separated by spaces (for example, `C: D:`), or leave the prompt blank to include all disks.
3. **Remove `$RECYCLE.BIN` folders** — with `EnterDrive` enabled, enter drive IDs or leave the prompt blank to target all detected disks. Type `y` at the confirmation prompt to proceed.
4. **Options** — toggle `More` output paging, `EnterDrive` prompts for listing and removal, and `RecurseDelete` recursive deletion.
`q` **Quit** — close the script.

The script enumerates disks with `Get-CimInstance -ClassName Win32_LogicalDisk`. When `RecurseDelete` is disabled, removal is attempted without the `-Recurse` option; you will be prompted to allow recurse deletion.

## Caution

Removal can permanently delete the selected `$RECYCLE.BIN` directories and their contents. Verify the target drives before confirming.
