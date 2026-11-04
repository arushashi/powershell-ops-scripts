<#
.SYNOPSIS
  Lists certificates in the local machine store that expire within the given number of days.
.EXAMPLE
  .\Get-ExpiringCertificates.ps1 -WithinDays 45
#>
[CmdletBinding()]
param(
    [int]$WithinDays = 30,
    [string]$StorePath = 'Cert:\LocalMachine\My'
)

$limit = (Get-Date).AddDays($WithinDays)
$certs = Get-ChildItem -Path $StorePath | Where-Object { $_.NotAfter -lt $limit } |
    Sort-Object NotAfter |
    ForEach-Object {
        [pscustomobject]@{
            Subject    = $_.Subject
            NotAfter   = $_.NotAfter
            DaysLeft   = [math]::Floor(($_.NotAfter - (Get-Date)).TotalDays)
            Thumbprint = $_.Thumbprint
            Expired    = $_.NotAfter -lt (Get-Date)
        }
    }

$certs
if ($certs) { exit 1 } else { exit 0 }
