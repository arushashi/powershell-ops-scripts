# powershell-ops-scripts

A small library of safe, reusable PowerShell tools for Windows operations.
Read-only by default; anything destructive supports `-WhatIf`.

| Script | Purpose |
|---|---|
| `scripts/Get-DiskReport.ps1` | Disk usage across one or many servers with a low-space flag |
| `scripts/Get-PatchStatus.ps1` | Last installed hotfixes and pending-reboot detection |
| `scripts/Get-ExpiringCertificates.ps1` | Certificates in the local store expiring soon |
| `scripts/Get-ServiceHealthReport.ps1` | Automatic services that are stopped |
| `scripts/Remove-OldLogs.ps1` | Delete log files older than N days (supports `-WhatIf`) |
| `tests/` | Pester tests |

## Usage

```powershell
.\scripts\Get-DiskReport.ps1 -ComputerName localhost -MinFreePercent 15
.\scripts\Remove-OldLogs.ps1 -Path D:\Logs -OlderThanDays 30 -WhatIf
Invoke-Pester .\tests      # requires Pester 5+ (Install-Module Pester -MinimumVersion 5.0 -Scope CurrentUser)
```

## Conventions
- `[CmdletBinding()]`, typed parameters, comment-based help
- Return objects (not text) so output can be piped, filtered and exported
- Destructive actions use `SupportsShouldProcess`
- Meaningful exit codes for use in schedulers and pipelines

## License

MIT
