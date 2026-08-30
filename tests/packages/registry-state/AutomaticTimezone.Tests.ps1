BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/AutomaticTimezone/Detect-AutomaticTimezone.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/AutomaticTimezone/Remediate-AutomaticTimezone.ps1')
}

Describe 'AutomaticTimezone registry contract' {
    BeforeEach {
        $state = [pscustomobject]@{ Location = 'Deny'; TimeZone = 4 }
        $getState = {
            [pscustomobject]@{
                Location = $state.Location
                TimeZone = $state.TimeZone
            }
        }
        $setState = {
            param($location, $timeZone)
            $state.Location = [string]$location
            $state.TimeZone = [int]$timeZone
        }
    }

    It 'detects both required values as compliant' {
        $state.Location = 'Allow'
        $state.TimeZone = 3
        $result = Test-AutomaticTimezone -GetState $getState

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant'
        $result.State.Location | Should -Be 'Allow'
        $result.State.TimeZone | Should -Be 3
    }

    It 'detects either incorrect value as noncompliant without changing state' {
        $result = Test-AutomaticTimezone -GetState $getState

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant'
        $state.Location | Should -Be 'Deny'
        $state.TimeZone | Should -Be 4
    }

    It 'reports a missing detection dependency' {
        $result = Test-AutomaticTimezone -GetState $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a missing remediation dependency' {
        $result = Repair-AutomaticTimezone -GetState $getState -SetState $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a detection dependency failure' {
        $result = Test-AutomaticTimezone -GetState { throw 'Timezone query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Timezone query failed'
    }

    It 'does not write already compliant values' {
        $state.Location = 'Allow'
        $state.TimeZone = 3
        $setCalls = 0
        $set = {
            param($location, $timeZone)
            $setCalls++
            $state.Location = [string]$location
            $state.TimeZone = [int]$timeZone
        }

        $result = Repair-AutomaticTimezone -GetState $getState -SetState $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $setCalls | Should -Be 0
    }

    It 'sets both values and detection converges' {
        $result = Repair-AutomaticTimezone -GetState $getState -SetState $setState
        $after = Test-AutomaticTimezone -GetState $getState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State.After.Location | Should -Be 'Allow'
        $result.State.After.TimeZone | Should -Be 3
        $after.Compliant | Should -BeTrue
    }

    It 'reports a remediation dependency failure' {
        $result = Repair-AutomaticTimezone -GetState $getState -SetState { throw 'Timezone update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Timezone update failed'
    }

    It 'is idempotent after successful remediation' {
        $first = Repair-AutomaticTimezone -GetState $getState -SetState $setState
        $second = Repair-AutomaticTimezone -GetState $getState -SetState $setState

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $state.Location | Should -Be 'Allow'
        $state.TimeZone | Should -Be 3
    }

    It 'is safe to import without changing the fake registry state' {
        $beforeLocation = $state.Location
        $beforeTimeZone = $state.TimeZone
        Get-Command Test-AutomaticTimezone -CommandType Function | Should -Not -BeNullOrEmpty
        $state.Location | Should -Be $beforeLocation
        $state.TimeZone | Should -Be $beforeTimeZone
    }
}
