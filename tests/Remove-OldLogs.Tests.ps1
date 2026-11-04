BeforeAll {
    $script:Script = Join-Path $PSScriptRoot '..\scripts\Remove-OldLogs.ps1'
}

Describe 'Remove-OldLogs' {
    BeforeEach {
        $script:dir = Join-Path ([IO.Path]::GetTempPath()) ("logs-" + [guid]::NewGuid())
        New-Item -ItemType Directory -Path $dir | Out-Null
        $old = New-Item -ItemType File -Path (Join-Path $dir 'old.log')
        $new = New-Item -ItemType File -Path (Join-Path $dir 'new.log')
        $old.LastWriteTime = (Get-Date).AddDays(-60)
    }
    AfterEach { Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue }

    It 'does not delete anything with -WhatIf' {
        & $Script -Path $dir -OlderThanDays 30 -WhatIf | Out-Null
        Test-Path (Join-Path $dir 'old.log') | Should -BeTrue
    }

    It 'deletes only files older than the cutoff' {
        & $Script -Path $dir -OlderThanDays 30 -Confirm:$false | Out-Null
        Test-Path (Join-Path $dir 'old.log') | Should -BeFalse
        Test-Path (Join-Path $dir 'new.log') | Should -BeTrue
    }

    It 'refuses to clean a drive root' {
        { & $Script -Path 'C:\' -OlderThanDays 30 -WhatIf } | Should -Throw
    }
}
