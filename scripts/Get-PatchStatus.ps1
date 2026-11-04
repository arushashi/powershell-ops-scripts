<#
.SYNOPSIS
  Shows the most recent hotfixes and whether the local machine is waiting for a reboot.
#>
[CmdletBinding()]
param([int]$Latest = 10)

function Test-PendingReboot {
    $keys = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    )
    foreach ($k in $keys) { if (Test-Path $k) { return $true } }
    $pfro = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
    return [bool]$pfro
}

[pscustomobject]@{
    Computer      = $env:COMPUTERNAME
    OS            = (Get-CimInstance Win32_OperatingSystem).Caption
    LastBoot      = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    PendingReboot = Test-PendingReboot
}

Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First $Latest HotFixID, Description, InstalledOn
