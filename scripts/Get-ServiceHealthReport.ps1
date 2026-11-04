<#
.SYNOPSIS
  Lists services set to Automatic start that are not running (excluding delayed one-shot services).
#>
[CmdletBinding()]
param([string[]]$Exclude = @('sppsvc', 'gupdate', 'gupdatem', 'MapsBroker', 'RemoteRegistry', 'edgeupdate', 'edgeupdatem'))

$stopped = Get-CimInstance Win32_Service -Filter "StartMode='Auto' AND State<>'Running'" |
    Where-Object { $Exclude -notcontains $_.Name } |
    Select-Object Name, DisplayName, State, ExitCode, StartName

$stopped
if ($stopped) { exit 1 } else { exit 0 }
