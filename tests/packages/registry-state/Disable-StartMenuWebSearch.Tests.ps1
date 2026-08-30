BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Disable-StartMenuWebSearch/Detect-Disable-StartMenuWebSearch.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Disable-StartMenuWebSearch/Remediate-Disable-StartMenuWebSearch.ps1')
}

Describe 'Disable-StartMenuWebSearch function contract' {
    BeforeEach {
        $registry = [pscustomobject]@{
            BingSearchEnabled = 1
            UnrelatedValue = 'preserve'
            SetCalls = 0
        }
        $getState = {
            [pscustomobject]@{
                BingSearchEnabled = $registry.BingSearchEnabled
            }
        }
        $setState = {
            param($value)
            $registry.SetCalls++
            $registry.BingSearchEnabled = [int]$value
        }
    }

    It 'detects disabled web search as compliant with the legacy output' {
        $registry.BingSearchEnabled = 0

        $result = Test-DisableStartMenuWebSearch -GetState $getState

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant'
        $result.State.BingSearchEnabled | Should -Be 0
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects enabled web search as noncompliant without changing state' {
        $result = Test-DisableStartMenuWebSearch -GetState $getState

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant'
        $registry.BingSearchEnabled | Should -Be 1
    }

    It 'reports missing and failed registry dependencies as structured errors' {
        $missing = Test-DisableStartMenuWebSearch -GetState $null
        $failed = Test-DisableStartMenuWebSearch -GetState { throw 'registry query failed' }

        $missing.Error.Type | Should -Be 'MissingDependency'
        $missing.ExitCode | Should -Be 1
        $failed.Error.Type | Should -Be 'DependencyFailure'
        $failed.Error.Message | Should -Match 'registry query failed'
    }

    It 'does not write an already disabled value' {
        $registry.BingSearchEnabled = 0

        $result = Repair-DisableStartMenuWebSearch -GetState $getState -SetState $setState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $registry.SetCalls | Should -Be 0
        $registry.UnrelatedValue | Should -Be 'preserve'
    }

    It 'disables web search and converges to compliant detection' {
        $result = Repair-DisableStartMenuWebSearch -GetState $getState -SetState $setState
        $after = Test-DisableStartMenuWebSearch -GetState $getState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.State.After.BingSearchEnabled | Should -Be 0
        $after.Compliant | Should -BeTrue
        $registry.UnrelatedValue | Should -Be 'preserve'
    }

    It 'reports a failed registry write without claiming success' {
        $result = Repair-DisableStartMenuWebSearch -GetState $getState -SetState { throw 'registry update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'registry update failed'
        (Test-DisableStartMenuWebSearch -GetState $getState).Compliant | Should -BeFalse
    }

    It 'is idempotent after disabling web search' {
        $first = Repair-DisableStartMenuWebSearch -GetState $getState -SetState $setState
        $second = Repair-DisableStartMenuWebSearch -GetState $getState -SetState { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
        $registry.BingSearchEnabled | Should -Be 0
    }
}
