BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Activate-Numlock/Detect-Activate-Numlock.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Activate-Numlock/Remediate-Activate-Numlock.ps1')
}

Describe 'Activate-Numlock registry contract' {
    BeforeEach {
        $state = [pscustomobject]@{ Value = '0' }
        $getState = { [pscustomobject]@{ Value = $state.Value } }
        $setState = {
            param($value)
            $state.Value = [string]$value
        }
    }

    It 'detects the activated value as compliant' {
        $state.Value = '2'
        $result = Test-ActivateNumlock -GetState $getState

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Numlock at Startup found'
        $result.State.Value | Should -Be '2'
    }

    It 'detects a nonactivated value without changing state' {
        $result = Test-ActivateNumlock -GetState $getState

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Numlock at Startup not found'
        $state.Value | Should -Be '0'
    }

    It 'reports a missing detection dependency' {
        $result = Test-ActivateNumlock -GetState $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a missing remediation dependency' {
        $result = Repair-ActivateNumlock -GetState $getState -SetState $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a detection dependency failure' {
        $result = Test-ActivateNumlock -GetState { throw 'Numlock query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Numlock query failed'
    }

    It 'does not write an already activated value' {
        $state.Value = '2'
        $setCalls = 0
        $set = {
            param($value)
            $setCalls++
            $state.Value = [string]$value
        }

        $result = Repair-ActivateNumlock -GetState $getState -SetState $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $setCalls | Should -Be 0
    }

    It 'activates Numlock and detection converges' {
        $result = Repair-ActivateNumlock -GetState $getState -SetState $setState
        $after = Test-ActivateNumlock -GetState $getState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State.After.Value | Should -Be '2'
        $after.Compliant | Should -BeTrue
    }

    It 'reports a remediation dependency failure' {
        $result = Repair-ActivateNumlock -GetState $getState -SetState { throw 'Numlock update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Numlock update failed'
    }

    It 'is idempotent after successful remediation' {
        $first = Repair-ActivateNumlock -GetState $getState -SetState $setState
        $second = Repair-ActivateNumlock -GetState $getState -SetState $setState

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $state.Value | Should -Be '2'
    }

    It 'is safe to import without changing the fake registry state' {
        $before = $state.Value
        Get-Command Test-ActivateNumlock -CommandType Function | Should -Not -BeNullOrEmpty
        $state.Value | Should -Be $before
    }
}
