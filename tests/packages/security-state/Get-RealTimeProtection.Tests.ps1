BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Get-RealTimeProtection/Detect-Get-RealTimeProtection.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Get-RealTimeProtection/Remediate-Get-RealTimeProtection.ps1')
}

Describe 'Get-RealTimeProtection function contract' {
    BeforeEach {
        $defenderState = [pscustomobject]@{ RealTimeProtectionEnabled = $false }
        $getStatus = { [pscustomobject]@{ RealTimeProtectionEnabled = $defenderState.RealTimeProtectionEnabled } }
        $setPreference = {
            param([hashtable]$values)
            $defenderState.RealTimeProtectionEnabled = $true
        }
    }

    It 'detects real-time protection enabled as compliant' {
        $defenderState.RealTimeProtectionEnabled = $true

        $result = Test-GetRealTimeProtection -GetStatus $getStatus

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'C1 COMPLIANT'
        $result.State.RealTimeProtectionEnabled | Should -BeTrue
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects disabled real-time protection as noncompliant' {
        $result = Test-GetRealTimeProtection -GetStatus $getStatus

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'C1 NON-COMPLIANT'
        $defenderState.RealTimeProtectionEnabled | Should -BeFalse
    }

    It 'reports a missing Defender status dependency' {
        $result = Test-GetRealTimeProtection -GetStatus $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'C1 DETECTION FAILED'
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a Defender status query failure with truthful error evidence' {
        $result = Test-GetRealTimeProtection -GetStatus { throw 'real-time status query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'real-time status query failed'
    }

    It 'does not call the setter when real-time protection is already enabled' {
        $defenderState.RealTimeProtectionEnabled = $true
        $defenderState | Add-Member -NotePropertyName SetCalls -NotePropertyValue 0
        $set = {
            param([hashtable]$values)
            $defenderState.SetCalls++
        }

        $result = Repair-GetRealTimeProtection -GetStatus $getStatus -SetPreference $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'R1 Remediated'
        $defenderState.SetCalls | Should -Be 0
    }

    It 'enables real-time protection and detection converges to compliant' {
        $result = Repair-GetRealTimeProtection -GetStatus $getStatus -SetPreference $setPreference
        $after = Test-GetRealTimeProtection -GetStatus $getStatus

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.State.After.RealTimeProtectionEnabled | Should -BeTrue
        $after.Compliant | Should -BeTrue
    }

    It 'returns a truthful nonzero failure when real-time remediation fails' {
        $result = Repair-GetRealTimeProtection -GetStatus $getStatus -SetPreference { throw 'real-time update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'R1 Failed'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'real-time update failed'
        (Test-GetRealTimeProtection -GetStatus $getStatus).Compliant | Should -BeFalse
    }

    It 'reports a missing setter dependency without mutating Defender state' {
        $before = $defenderState.RealTimeProtectionEnabled
        $result = Repair-GetRealTimeProtection -GetStatus $getStatus -SetPreference $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
        $defenderState.RealTimeProtectionEnabled | Should -Be $before
    }

    It 'is idempotent after the first successful remediation' {
        $first = Repair-GetRealTimeProtection -GetStatus $getStatus -SetPreference $setPreference
        $second = Repair-GetRealTimeProtection `
            -GetStatus $getStatus `
            -SetPreference { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
    }
}
