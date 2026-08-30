BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Get-RealTimeBehaviour/Detect-Get-RealTimeBehaviour.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Get-RealTimeBehaviour/Remediate-Get-RealTimeBehaviour.ps1')
}

Describe 'Get-RealTimeBehaviour function contract' {
    BeforeEach {
        $defenderState = [pscustomobject]@{ BehaviorMonitorEnabled = $false }
        $getStatus = { [pscustomobject]@{ BehaviorMonitorEnabled = $defenderState.BehaviorMonitorEnabled } }
        $setPreference = {
            param([hashtable]$values)
            $defenderState.BehaviorMonitorEnabled = $true
        }
    }

    It 'detects behavior monitoring enabled as compliant' {
        $defenderState.BehaviorMonitorEnabled = $true

        $result = Test-GetRealTimeBehaviour -GetStatus $getStatus

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'C1 COMPLIANT'
        $result.State.BehaviorMonitorEnabled | Should -BeTrue
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects disabled behavior monitoring as noncompliant' {
        $result = Test-GetRealTimeBehaviour -GetStatus $getStatus

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'C1 NON-COMPLIANT'
        $defenderState.BehaviorMonitorEnabled | Should -BeFalse
    }

    It 'reports a missing Defender status dependency' {
        $result = Test-GetRealTimeBehaviour -GetStatus $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'C1 DETECTION FAILED'
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a Defender status query failure with truthful error evidence' {
        $result = Test-GetRealTimeBehaviour -GetStatus { throw 'behavior status query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'behavior status query failed'
    }

    It 'does not call the setter when behavior monitoring is already enabled' {
        $defenderState.BehaviorMonitorEnabled = $true
        $defenderState | Add-Member -NotePropertyName SetCalls -NotePropertyValue 0
        $set = {
            param([hashtable]$values)
            $defenderState.SetCalls++
        }

        $result = Repair-GetRealTimeBehaviour -GetStatus $getStatus -SetPreference $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'R1 Remediated'
        $defenderState.SetCalls | Should -Be 0
    }

    It 'enables behavior monitoring and detection converges to compliant' {
        $result = Repair-GetRealTimeBehaviour -GetStatus $getStatus -SetPreference $setPreference
        $after = Test-GetRealTimeBehaviour -GetStatus $getStatus

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.State.After.BehaviorMonitorEnabled | Should -BeTrue
        $after.Compliant | Should -BeTrue
    }

    It 'returns a truthful nonzero failure when behavior remediation fails' {
        $result = Repair-GetRealTimeBehaviour -GetStatus $getStatus -SetPreference { throw 'behavior update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'R1 Failed'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'behavior update failed'
        (Test-GetRealTimeBehaviour -GetStatus $getStatus).Compliant | Should -BeFalse
    }

    It 'reports a missing setter dependency without mutating Defender state' {
        $before = $defenderState.BehaviorMonitorEnabled
        $result = Repair-GetRealTimeBehaviour -GetStatus $getStatus -SetPreference $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
        $defenderState.BehaviorMonitorEnabled | Should -Be $before
    }

    It 'is idempotent after the first successful remediation' {
        $first = Repair-GetRealTimeBehaviour -GetStatus $getStatus -SetPreference $setPreference
        $second = Repair-GetRealTimeBehaviour `
            -GetStatus $getStatus `
            -SetPreference { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
    }
}
