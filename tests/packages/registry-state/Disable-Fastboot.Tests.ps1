BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Disable-Fastboot/Detect-Disable-Fastboot.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Disable-Fastboot/Remediate-Disable-Fastboot.ps1')
}

Describe 'Disable-Fastboot registry contract' {
    BeforeEach {
        $state = [pscustomobject]@{ Value = 1 }
        $getState = { [pscustomobject]@{ Value = $state.Value } }
        $setState = {
            param($value)
            $state.Value = [int]$value
        }
    }

    It 'detects disabled Fastboot as compliant' {
        $state.Value = 0
        $result = Test-DisableFastboot -GetState $getState

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant'
        $result.State.Value | Should -Be 0
    }

    It 'detects enabled Fastboot as noncompliant without changing state' {
        $result = Test-DisableFastboot -GetState $getState

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant'
        $state.Value | Should -Be 1
    }

    It 'reports a missing detection dependency' {
        $result = Test-DisableFastboot -GetState $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a missing remediation dependency' {
        $result = Repair-DisableFastboot -GetState $getState -SetState $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a detection dependency failure' {
        $result = Test-DisableFastboot -GetState { throw 'Fastboot query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Fastboot query failed'
    }

    It 'does not write an already disabled value' {
        $state.Value = 0
        $setCalls = 0
        $set = {
            param($value)
            $setCalls++
            $state.Value = [int]$value
        }

        $result = Repair-DisableFastboot -GetState $getState -SetState $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $setCalls | Should -Be 0
    }

    It 'disables Fastboot and detection converges' {
        $result = Repair-DisableFastboot -GetState $getState -SetState $setState
        $after = Test-DisableFastboot -GetState $getState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State.After.Value | Should -Be 0
        $after.Compliant | Should -BeTrue
    }

    It 'reports a remediation dependency failure' {
        $result = Repair-DisableFastboot -GetState $getState -SetState { throw 'Fastboot update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Fastboot update failed'
    }

    It 'is idempotent after successful remediation' {
        $first = Repair-DisableFastboot -GetState $getState -SetState $setState
        $second = Repair-DisableFastboot -GetState $getState -SetState $setState

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $state.Value | Should -Be 0
    }

    It 'is safe to import without changing the fake registry state' {
        $before = $state.Value
        Get-Command Test-DisableFastboot -CommandType Function | Should -Not -BeNullOrEmpty
        $state.Value | Should -Be $before
    }
}
