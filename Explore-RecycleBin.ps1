# Check if admin with .NET
$isAdmin = (
    [Security.Principal.WindowsPrincipal]::new(
        [Security.Principal.WindowsIdentity]::GetCurrent()
        )).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator
            )

if (!$isAdmin) {
    # Elevate and restart script
    Write-Host "**************************************"
    Write-Host "Invoking UAC for Privilege Escalation"
    Write-Host "**************************************"
    Start-Process powershell.exe -Verb RunAs -ArgumentList @(
        '-NoProfile'
        '-ExecutionPolicy Bypass' 
        '-File'
        "`"$PSCommandPath`""
        )
    exit
}

    read-host "asd"
