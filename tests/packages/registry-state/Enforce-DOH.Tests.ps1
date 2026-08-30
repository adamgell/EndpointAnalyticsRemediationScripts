BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Enforce-DOH/Detect-Enforce-DOH.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Enforce-DOH/Remediate-Enforce-DOH.ps1')
}

Describe 'Enforce-DOH function contract' {
    BeforeEach {
        $registry = [pscustomobject]@{
            EnableAutoDoh = 0
            UnrelatedValue = 'preserve'
            SetCalls = 0
        }
        $getState = {
            [pscustomobject]@{
                EnableAutoDoh = $registry.EnableAutoDoh
            }
        }
        $setState = {
            param($value)
            $registry.SetCalls++
            $registry.EnableAutoDoh = [int]$value
        }
    }

    It 'detects enabled DNS over HTTPS as compliant with the legacy output' {
        $registry.EnableAutoDoh = 2

        $result = Test-EnforceDOH -GetState $getState

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant - DNS over HTTPS is enabled'
        $result.State.EnableAutoDoh | Should -Be 2
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects a non-enabled DoH value as noncompliant' {
        $result = Test-EnforceDOH -GetState $getState

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant - DNS over HTTPS is not enabled'
        $registry.UnrelatedValue | Should -Be 'preserve'
    }

    It 'reports missing and failed DNS registry dependencies as structured errors' {
        $missing = Test-EnforceDOH -GetState $null
        $failed = Test-EnforceDOH -GetState { throw 'DoH registry query failed' }

        $missing.Error.Type | Should -Be 'MissingDependency'
        $missing.ExitCode | Should -Be 1
        $failed.Error.Type | Should -Be 'DependencyFailure'
        $failed.Error.Message | Should -Match 'DoH registry query failed'
    }

    It 'does not rewrite an already enabled DoH value' {
        $registry.EnableAutoDoh = 2

        $result = Repair-EnforceDOH -GetState $getState -SetState $setState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'DNS over HTTPS has been enabled. A reboot may be required.'
        $registry.SetCalls | Should -Be 0
        $registry.UnrelatedValue | Should -Be 'preserve'
    }

    It 'enables DoH and converges to compliant detection' {
        $result = Repair-EnforceDOH -GetState $getState -SetState $setState
        $after = Test-EnforceDOH -GetState $getState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.State.After.EnableAutoDoh | Should -Be 2
        $after.Compliant | Should -BeTrue
        $registry.UnrelatedValue | Should -Be 'preserve'
    }

    It 'reports a failed registry write without claiming success' {
        $result = Repair-EnforceDOH -GetState $getState -SetState { throw 'DoH registry update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Match 'Failed to enable DoH'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'DoH registry update failed'
        (Test-EnforceDOH -GetState $getState).Compliant | Should -BeFalse
    }

    It 'is idempotent after enabling DoH' {
        $first = Repair-EnforceDOH -GetState $getState -SetState $setState
        $second = Repair-EnforceDOH -GetState $getState -SetState { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
        $registry.EnableAutoDoh | Should -Be 2
    }
}
