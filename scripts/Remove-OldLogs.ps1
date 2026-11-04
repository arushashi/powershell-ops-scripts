<#
.SYNOPSIS
  Deletes log files older than N days. Always preview first with -WhatIf.
.EXAMPLE
  .\Remove-OldLogs.ps1 -Path D:\Logs -OlderThanDays 30 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)][ValidateScript({ Test-Path $_ -PathType Container })][string]$Path,
    [ValidateRange(1, 3650)][int]$OlderThanDays = 30,
    [string[]]$Extensions = @('*.log', '*.log.gz', '*.txt')
)

# Safety: refuse to run against a drive root or the system folder.
$resolved = (Resolve-Path $Path).ProviderPath.TrimEnd('\')
if ($resolved -match '^[A-Za-z]:$' -or $resolved -like "$env:windir*") {
    throw "Refusing to clean '$resolved': choose a specific log folder."
}

$cutoff = (Get-Date).AddDays(-$OlderThanDays)
$files = Get-ChildItem -Path $resolved -Include $Extensions -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt $cutoff }

$freed = 0
foreach ($f in $files) {
    if ($PSCmdlet.ShouldProcess($f.FullName, 'Delete')) {
        Remove-Item -LiteralPath $f.FullName -Force
        $freed += $f.Length
    }
}

[pscustomobject]@{
    Path = $resolved; Candidates = @($files).Count; FreedMB = [math]::Round($freed / 1MB, 1); Cutoff = $cutoff
}
