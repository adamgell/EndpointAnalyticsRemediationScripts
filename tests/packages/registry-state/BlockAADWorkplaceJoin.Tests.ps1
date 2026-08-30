BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/BlockAADWorkplaceJoin/Detect-BlockAADWorkplaceJoin.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/BlockAADWorkplaceJoin/Remediate-BlockAADWorkplaceJoin.ps1')
}

Describe 'BlockAADWorkplaceJoin registry contract' {
    BeforeEach {
        $state = [pscustomobject]@{ Value = 0 }
        $getState = { [pscustomobject]@{ Value = $state.Value } }
        $setState = {
            param($value)
            $state.Value = [int]$value
        }
    }

    It 'detects the blocking value as compliant' {
        $state.Value = 1
        $result = Test-BlockAADWorkplaceJoin -GetState $getState

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant'
        $result.State.Value | Should -Be 1
    }

    It 'detects an unblocked value as noncompliant without changing state' {
        $result = Test-BlockAADWorkplaceJoin -GetState $getState

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant'
        $state.Value | Should -Be 0
    }

    It 'reports a missing detection dependency' {
        $result = Test-BlockAADWorkplaceJoin -GetState $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a missing remediation dependency' {
        $result = Repair-BlockAADWorkplaceJoin -GetState $getState -SetState $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a detection dependency failure' {
        $result = Test-BlockAADWorkplaceJoin -GetState { throw 'Workplace Join query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Workplace Join query failed'
    }

    It 'does not write an already blocking value' {
        $state.Value = 1
        $setCalls = 0
        $set = {
            param($value)
            $setCalls++
            $state.Value = [int]$value
        }

        $result = Repair-BlockAADWorkplaceJoin -GetState $getState -SetState $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $setCalls | Should -Be 0
    }

    It 'blocks workplace join and detection converges' {
        $result = Repair-BlockAADWorkplaceJoin -GetState $getState -SetState $setState
        $after = Test-BlockAADWorkplaceJoin -GetState $getState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State.After.Value | Should -Be 1
        $after.Compliant | Should -BeTrue
    }

    It 'reports a remediation dependency failure' {
        $result = Repair-BlockAADWorkplaceJoin -GetState $getState -SetState { throw 'Workplace Join update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Workplace Join update failed'
    }

    It 'is idempotent after successful remediation' {
        $first = Repair-BlockAADWorkplaceJoin -GetState $getState -SetState $setState
        $second = Repair-BlockAADWorkplaceJoin -GetState $getState -SetState $setState

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $state.Value | Should -Be 1
    }

    It 'is safe to import without changing the fake registry state' {
        $before = $state.Value
        Get-Command Test-BlockAADWorkplaceJoin -CommandType Function | Should -Not -BeNullOrEmpty
        $state.Value | Should -Be $before
    }
}
