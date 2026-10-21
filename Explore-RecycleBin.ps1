# Check administrative privileges
$isAdmin = (
    [Security.Principal.WindowsPrincipal]::new(
        [Security.Principal.WindowsIdentity]::GetCurrent()
        )).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator
            )

if (!$isAdmin) {
    Write-Host '**************************************'
    Write-Host 'Invoking UAC for Privilege Escalation'
    Write-Host '**************************************'

    # Select PowerShell executable
    $PW = if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        'pwsh.exe'
    } else {
        'powershell.exe'
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

#Set default Parameter for the script
$param = [ordered]@{
    More = $false
    EnterDrive = $true
    RecurseDelete = $true
}

function Get-LogicalDiskRecycleBin {
    param(
        [string[]]$drives,
        [switch]$contents
        )


    $disks = Get-CimInstance -ClassName Win32_LogicalDisk

    if ($drives) {
        $disks = $disks | Where-Object { $drives -contains $_.DeviceID }
    }

    $disks | ForEach-Object {
        $Path = Join-Path -Path $_.DeviceID -ChildPath '$RECYCLE.BIN'

        if (Test-Path -LiteralPath $Path -PathType Container) {
            if ($contents) {
                Get-ChildItem -LiteralPath $Path -Force -Recurse -File |
                    Select-Object @{ Name='Size MB'; Expression= { [math]::Round($_.Length/1MB, 2) } },
                        Name,
                        Directory |
                    Sort-Object 'Size MB' |
                    Format-Table -AutoSize
            } else {
                Get-Item -LiteralPath $Path -Force | Select-Object -ExpandProperty FullName
            }
        }
    }
}

do {
    # Reinitialize variables for each iteration
    $drives = $null
    $choice = $null
    $confirmDelete = $null

    # Interactive section
    Write-Host '[1] Find and list bins'
    Write-Host '[2] List bin contents'
    Write-Host '[3] Remove all $RECYCLE.BIN folders'
    Write-Host '[4] Options'
    Write-Host '[q] Quit'
    Write-Host ''

    $choice = Read-Host 'Option'

    switch ($choice) {
        '1' {
            Get-LogicalDiskRecycleBin
            Write-Host ''
         }
        '2' {
            if ($param.EnterDrive) {
                $drives = Read-Host 'Enter drive letters (space-separated) or leave blank for all drives'

                if ($drives) {
                    $drives = $drives -split '\s+'
                }
            }

            $result = Get-LogicalDiskRecycleBin -Drives $drives -Contents
            if ($param.More) {$result | Out-Host -Paging} else {$result}
            Write-Host ''
        }
        '3' {

            if ($param.EnterDrive) {
                $drives = Read-Host 'Enter drive letters (space-separated) or leave blank for all drives'

                if ($drives) {
                    $drives = $drives -split '\s+'
                }
            }

            $confirmDeleteTarget = if ($drives) {
                "on drives: $($drives -join ', ')"
            } else {
                'on all drives'
            }

            $confirmDelete = Read-Host "Confirm deletion (y) ($confirmDeleteTarget)"
            if ($confirmDelete -eq 'y') {
                Get-LogicalDiskRecycleBin -Drives $drives | Remove-Item -Recurse -Force
            }
            Write-Host ''
        }
        '4' {
            Write-Host ''
            Write-Host '[1] Toggle More | More lets you page through output when it exceeds the window.'
            Write-Host '[2] Toggle EnterDrive | EnterDrive prompts you to enter drive letters when listing bin contents.'
            Write-Host '[3] Toggle RecurseDelete | RecurseDelete allows you to delete $RECYCLE.BIN folders recursively. Otherwise, it will ask for approval.'
            Write-Host '[x] Exit Options'
            do {
                $param.GetEnumerator() | ForEach-Object {
                    [pscustomobject]@{
                        Option = [array]::IndexOf(@($param.Keys), $_.Key) + 1
                        Name = $_.Key
                        Value = $_.Value
                    }
                } | Format-Table -AutoSize

                $choice = Read-Host 'Option'
                Write-Host ''

                switch ($choice) {
                    '1' {
                        $param.More = -not $param.More
                    }
                    '2' {
                        $param.EnterDrive = -not $param.EnterDrive
                    }
                    '3' {
                        $param.RecurseDelete = -not $param.RecurseDelete
                    }
                }
            } until ($choice -eq 'x')
        }
    }
} until ($choice -eq 'q')
