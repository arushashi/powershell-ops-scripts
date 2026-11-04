<#
.SYNOPSIS
  Reports fixed-disk usage for one or more computers and flags low free space.
.EXAMPLE
  .\Get-DiskReport.ps1 -ComputerName localhost -MinFreePercent 15
#>
[CmdletBinding()]
param(
    [string[]]$ComputerName = $env:COMPUTERNAME,
    [ValidateRange(1, 99)][int]$MinFreePercent = 15
)

$report = foreach ($computer in $ComputerName) {
    try {
        Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' -ComputerName $computer -ErrorAction Stop |
            ForEach-Object {
                $freePct = if ($_.Size) { [math]::Round($_.FreeSpace / $_.Size * 100, 1) } else { 0 }
                [pscustomobject]@{
                    Computer = $computer
                    Drive    = $_.DeviceID
                    SizeGB   = [math]::Round($_.Size / 1GB, 1)
                    FreeGB   = [math]::Round($_.FreeSpace / 1GB, 1)
                    FreePct  = $freePct
                    Low      = $freePct -lt $MinFreePercent
                }
            }
    } catch {
        [pscustomobject]@{ Computer = $computer; Drive = 'n/a'; SizeGB = $null; FreeGB = $null; FreePct = $null; Low = $true }
        Write-Warning "${computer}: $($_.Exception.Message)"
    }
}

$report
if ($report | Where-Object Low) { exit 1 } else { exit 0 }
