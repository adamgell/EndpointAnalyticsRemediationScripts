BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Disable-LegacyTLS/Detect-Disable-LegacyTLS.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Disable-LegacyTLS/Remediate-Disable-LegacyTLS.ps1')
}

Describe 'Disable-LegacyTLS registry contract' {
    BeforeEach {
        $state = [ordered]@{
            'TLS 1.0/Server' = [pscustomobject]@{ Enabled = 1; DisabledByDefault = 0 }
            'TLS 1.0/Client' = [pscustomobject]@{ Enabled = 1; DisabledByDefault = 0 }
            'TLS 1.1/Server' = [pscustomobject]@{ Enabled = 1; DisabledByDefault = 0 }
            'TLS 1.1/Client' = [pscustomobject]@{ Enabled = 1; DisabledByDefault = 0 }
        }
        $getState = {
            [ordered]@{
                'TLS 1.0/Server' = [pscustomobject]@{
                    Enabled = $state['TLS 1.0/Server'].Enabled
                    DisabledByDefault = $state['TLS 1.0/Server'].DisabledByDefault
                }
                'TLS 1.0/Client' = [pscustomobject]@{
                    Enabled = $state['TLS 1.0/Client'].Enabled
                    DisabledByDefault = $state['TLS 1.0/Client'].DisabledByDefault
                }
                'TLS 1.1/Server' = [pscustomobject]@{
                    Enabled = $state['TLS 1.1/Server'].Enabled
                    DisabledByDefault = $state['TLS 1.1/Server'].DisabledByDefault
                }
                'TLS 1.1/Client' = [pscustomobject]@{
                    Enabled = $state['TLS 1.1/Client'].Enabled
                    DisabledByDefault = $state['TLS 1.1/Client'].DisabledByDefault
                }
            }
        }
        $setState = {
            param($updates)
            foreach ($key in $updates.Keys) {
                $state[$key].Enabled = [int]$updates[$key].Enabled
                $state[$key].DisabledByDefault = [int]$updates[$key].DisabledByDefault
            }
        }
    }

    It 'detects all legacy TLS protocol values as compliant' {
        foreach ($key in $state.Keys) {
            $state[$key].Enabled = 0
            $state[$key].DisabledByDefault = 1
        }
        $result = Test-DisableLegacyTLS -GetState $getState

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant - Legacy TLS protocols are disabled'
        $result.State.Entries['TLS 1.0/Server'].Enabled | Should -Be 0
    }

    It 'detects an enabled or incomplete protocol as noncompliant without changing state' {
        $before = $state['TLS 1.0/Server'].Enabled
        $result = Test-DisableLegacyTLS -GetState $getState

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant - Legacy TLS protocols are enabled'
        $state['TLS 1.0/Server'].Enabled | Should -Be $before
    }

    It 'reports a missing detection dependency' {
        $result = Test-DisableLegacyTLS -GetState $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a missing remediation dependency' {
        $result = Repair-DisableLegacyTLS -GetState $getState -SetState $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a detection dependency failure' {
        $result = Test-DisableLegacyTLS -GetState { throw 'TLS query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'TLS query failed'
    }

    It 'does not write already disabled protocol values' {
        foreach ($key in $state.Keys) {
            $state[$key].Enabled = 0
            $state[$key].DisabledByDefault = 1
        }
        $setCalls = 0
        $set = {
            param($updates)
            $setCalls++
            & $setState $updates
        }

        $result = Repair-DisableLegacyTLS -GetState $getState -SetState $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $setCalls | Should -Be 0
    }

    It 'disables all legacy TLS values and detection converges' {
        $result = Repair-DisableLegacyTLS -GetState $getState -SetState $setState
        $after = Test-DisableLegacyTLS -GetState $getState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State.After['TLS 1.1/Client'].Enabled | Should -Be 0
        $after.Compliant | Should -BeTrue
    }

    It 'reports a remediation dependency failure' {
        $result = Repair-DisableLegacyTLS -GetState $getState -SetState { throw 'TLS update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'TLS update failed'
    }

    It 'is idempotent after successful remediation' {
        $first = Repair-DisableLegacyTLS -GetState $getState -SetState $setState
        $second = Repair-DisableLegacyTLS -GetState $getState -SetState $setState

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $state['TLS 1.0/Server'].Enabled | Should -Be 0
    }

    It 'is safe to import without changing the fake registry state' {
        $before = $state['TLS 1.0/Server'].Enabled
        Get-Command Test-DisableLegacyTLS -CommandType Function | Should -Not -BeNullOrEmpty
        $state['TLS 1.0/Server'].Enabled | Should -Be $before
    }
}
