BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Enable-DarkMode/Detect-Enable-DarkMode.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Enable-DarkMode/Remediate-Enable-DarkMode.ps1')
}

Describe 'Enable-DarkMode function contract' {
    BeforeEach {
        $registry = [pscustomobject]@{
            AppsUseLightTheme = 1
            SystemUsesLightTheme = 1
            UnrelatedValue = 'preserve'
            SetCalls = 0
        }
        $getState = {
            [pscustomobject]@{
                AppsUseLightTheme = $registry.AppsUseLightTheme
                SystemUsesLightTheme = $registry.SystemUsesLightTheme
            }
        }
        $setState = {
            param($appsUseLightTheme, $systemUsesLightTheme)
            $registry.SetCalls++
            $registry.AppsUseLightTheme = [int]$appsUseLightTheme
            $registry.SystemUsesLightTheme = [int]$systemUsesLightTheme
        }
    }

    It 'detects fully enabled dark mode with the legacy output' {
        $registry.AppsUseLightTheme = 0
        $registry.SystemUsesLightTheme = 0

        $result = Test-EnableDarkMode -GetState $getState

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant - Dark mode is enabled'
        $result.State.AppsUseLightTheme | Should -Be 0
        $result.State.SystemUsesLightTheme | Should -Be 0
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects partially enabled dark mode as noncompliant' {
        $registry.AppsUseLightTheme = 0

        $result = Test-EnableDarkMode -GetState $getState

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant - Dark mode is not fully enabled'
        $registry.UnrelatedValue | Should -Be 'preserve'
    }

    It 'reports missing and failed registry dependencies as structured errors' {
        $missing = Test-EnableDarkMode -GetState $null
        $failed = Test-EnableDarkMode -GetState { throw 'dark mode query failed' }

        $missing.Error.Type | Should -Be 'MissingDependency'
        $missing.ExitCode | Should -Be 1
        $failed.Error.Type | Should -Be 'DependencyFailure'
        $failed.Error.Message | Should -Match 'dark mode query failed'
    }

    It 'does not rewrite an already compliant dark mode configuration' {
        $registry.AppsUseLightTheme = 0
        $registry.SystemUsesLightTheme = 0

        $result = Repair-EnableDarkMode -GetState $getState -SetState $setState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Dark mode has been enabled system-wide'
        $registry.SetCalls | Should -Be 0
        $registry.UnrelatedValue | Should -Be 'preserve'
    }

    It 'enables both dark mode values and converges to compliant detection' {
        $result = Repair-EnableDarkMode -GetState $getState -SetState $setState
        $after = Test-EnableDarkMode -GetState $getState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.State.After.AppsUseLightTheme | Should -Be 0
        $result.State.After.SystemUsesLightTheme | Should -Be 0
        $after.Compliant | Should -BeTrue
        $registry.UnrelatedValue | Should -Be 'preserve'
    }

    It 'reports a failed registry write without claiming success' {
        $result = Repair-EnableDarkMode -GetState $getState -SetState { throw 'dark mode update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Match 'Failed to enable dark mode'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'dark mode update failed'
        (Test-EnableDarkMode -GetState $getState).Compliant | Should -BeFalse
    }

    It 'is idempotent after enabling dark mode' {
        $first = Repair-EnableDarkMode -GetState $getState -SetState $setState
        $second = Repair-EnableDarkMode -GetState $getState -SetState { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
        $registry.AppsUseLightTheme | Should -Be 0
        $registry.SystemUsesLightTheme | Should -Be 0
    }
}
