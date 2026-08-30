BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Disable-Coinstaller/Detect-Disable-Coinstaller.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Disable-Coinstaller/Remediate-Disable-Coinstaller.ps1')
}

Describe 'Disable-Coinstaller registry contract' {
    BeforeEach {
        $state = [pscustomobject]@{ Value = 0 }
        $getState = { [pscustomobject]@{ Value = $state.Value } }
        $setState = {
            param($value)
            $state.Value = [int]$value
        }
    }

    It 'detects the disabled value as compliant' {
        $state.Value = 1
        $result = Test-DisableCoinstaller -GetState $getState

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant'
        $result.State.Value | Should -Be 1
    }

    It 'detects an enabled value as noncompliant without changing state' {
        $result = Test-DisableCoinstaller -GetState $getState

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant'
        $state.Value | Should -Be 0
    }

    It 'reports a missing detection dependency' {
        $result = Test-DisableCoinstaller -GetState $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a missing remediation dependency' {
        $result = Repair-DisableCoinstaller -GetState $getState -SetState $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a detection dependency failure' {
        $result = Test-DisableCoinstaller -GetState { throw 'Coinstaller query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Coinstaller query failed'
    }

    It 'does not write an already disabled value' {
        $state.Value = 1
        $setCalls = 0
        $set = {
            param($value)
            $setCalls++
            $state.Value = [int]$value
        }

        $result = Repair-DisableCoinstaller -GetState $getState -SetState $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $setCalls | Should -Be 0
    }

    It 'disables coinstallers and detection converges' {
        $result = Repair-DisableCoinstaller -GetState $getState -SetState $setState
        $after = Test-DisableCoinstaller -GetState $getState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State.After.Value | Should -Be 1
        $after.Compliant | Should -BeTrue
    }

    It 'reports a remediation dependency failure' {
        $result = Repair-DisableCoinstaller -GetState $getState -SetState { throw 'Coinstaller update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Coinstaller update failed'
    }

    It 'is idempotent after successful remediation' {
        $first = Repair-DisableCoinstaller -GetState $getState -SetState $setState
        $second = Repair-DisableCoinstaller -GetState $getState -SetState $setState

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $state.Value | Should -Be 1
    }

    It 'is safe to import without changing the fake registry state' {
        $before = $state.Value
        Get-Command Test-DisableCoinstaller -CommandType Function | Should -Not -BeNullOrEmpty
        $state.Value | Should -Be $before
    }
}
