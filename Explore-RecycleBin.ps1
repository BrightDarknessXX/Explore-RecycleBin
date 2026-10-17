# Check administrative privileges
$isAdmin = (
    [Security.Principal.WindowsPrincipal]::new(
        [Security.Principal.WindowsIdentity]::GetCurrent()
        )).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator
            )

if (!$isAdmin) {
    Write-Host "**************************************"
    Write-Host "Invoking UAC for Privilege Escalation"
    Write-Host "**************************************"

    # Select PowerShell executable
    $PW = if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        "pwsh.exe"
    } else {
        "powershell.exe"
    }

    # Define script arguments for elevated process
    $PWarguments = @(
        '-NoProfile'
        '-ExecutionPolicy', 'Bypass'
        '-File'
        "`"$PSCommandPath`""
        )

    # Check if Windows Terminal (wt) is available and use it for elevation if possible
    if (Get-Command wt -ErrorAction SilentlyContinue) {
    Start-Process wt -Verb RunAs -ArgumentList @(
        $PW
        $PWarguments
        )
    } else {
        Start-Process $PW -Verb RunAs -ArgumentList $PWarguments
    }

    exit
}

function Get-LogicalDiskRecycleBin {
    param(
        [string[]]$Drives,
        [switch]$Contents
        )


    $disks = Get-CimInstance -ClassName Win32_LogicalDisk

    if ($Drives) {
        $disks = $disks | Where-Object { $Drives -contains $_.DeviceID }
    }

    $disks | ForEach-Object {
        $Path = Join-Path -Path $_.DeviceID -ChildPath '$RECYCLE.BIN'

        if (Test-Path -LiteralPath $Path -PathType Container) {
            if ($Contents) {
                Get-ChildItem -LiteralPath $Path -Force -Recurse -File | Select-Object Name, Directory, @{ Name="Size MB"; Expression= { [math]::Round($_.Length/1MB, 2) } } | Sort-Object "Size MB" | Format-Table -AutoSize
            } else {
                Get-Item -LiteralPath $Path -Force | Select-Object -ExpandProperty FullName
            }
        }
    }
}

do {
    # Interactive section
    Write-Host '[1] Find and list bins'
    Write-Host '[2] List bin contents'
    Write-Host '[3] Remove all $RECYCLE.BIN folders'
    Write-Host '[4] Exit'
    Write-Host ''

    $choice = Read-Host "Option"

    switch ($choice) {
        '1' {
            Get-LogicalDiskRecycleBin
            Write-Host ''
         }
        '2' {
            $Drives = Read-Host "Enter drive letters (space-separated) or leave blank for all drives"

            if ($Drives) {
                $Drives = $Drives -split '\s+'
            }

            Get-LogicalDiskRecycleBin -Drives $Drives -Contents
            Write-Host ''
        }
        '3' {
            $choice = Read-Host "Are you sure you want to remove all $RECYCLE.BIN folders? (y/n)"
            if ($choice -eq 'y') {
                Get-LogicalDiskRecycleBin | Remove-Item -Recurse -Force
                Write-Host ''
            }
        }
    }

} until ($choice -eq '4')
