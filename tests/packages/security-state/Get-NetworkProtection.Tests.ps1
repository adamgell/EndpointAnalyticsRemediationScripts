BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Get-NetworkProtection/Detect-Get-NetworkProtection.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Get-NetworkProtection/Remediate-Get-NetworkProtection.ps1')
}

Describe 'Get-NetworkProtection function contract' {
    BeforeEach {
        $defenderState = [pscustomobject]@{ EnableNetworkProtection = 0 }
        $getPreference = { [pscustomobject]@{ EnableNetworkProtection = $defenderState.EnableNetworkProtection } }
        $setPreference = {
            param([hashtable]$values)
            $defenderState.EnableNetworkProtection = 1
        }
    }

    It 'detects enabled network protection as compliant' {
        $defenderState.EnableNetworkProtection = 1

        $result = Test-GetNetworkProtection -GetPreference $getPreference

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'C1 COMPLIANT'
        $result.State.EnableNetworkProtection | Should -Be 1
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects disabled network protection as noncompliant' {
        $result = Test-GetNetworkProtection -GetPreference $getPreference

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'C1 NON-COMPLIANT'
        $defenderState.EnableNetworkProtection | Should -Be 0
    }

    It 'reports a missing Defender preference dependency' {
        $result = Test-GetNetworkProtection -GetPreference $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'C1 DETECTION FAILED'
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a Defender preference query failure with truthful error evidence' {
        $result = Test-GetNetworkProtection -GetPreference { throw 'network preference query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'network preference query failed'
    }

    It 'does not call the setter when network protection is already enabled' {
        $defenderState.EnableNetworkProtection = 1
        $defenderState | Add-Member -NotePropertyName SetCalls -NotePropertyValue 0
        $set = {
            param([hashtable]$values)
            $defenderState.SetCalls++
        }

        $result = Repair-GetNetworkProtection -GetPreference $getPreference -SetPreference $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'R1 Remediated'
        $defenderState.SetCalls | Should -Be 0
    }

    It 'enables network protection and detection converges to compliant' {
        $result = Repair-GetNetworkProtection -GetPreference $getPreference -SetPreference $setPreference
        $after = Test-GetNetworkProtection -GetPreference $getPreference

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.State.After.EnableNetworkProtection | Should -Be 1
        $after.Compliant | Should -BeTrue
    }

    It 'returns a truthful nonzero failure when network remediation fails' {
        $result = Repair-GetNetworkProtection `
            -GetPreference $getPreference `
            -SetPreference { throw 'network protection update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'R1 Failed'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'network protection update failed'
        (Test-GetNetworkProtection -GetPreference $getPreference).Compliant | Should -BeFalse
    }

    It 'reports a missing setter dependency without mutating Defender state' {
        $before = $defenderState.EnableNetworkProtection
        $result = Repair-GetNetworkProtection -GetPreference $getPreference -SetPreference $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
        $defenderState.EnableNetworkProtection | Should -Be $before
    }

    It 'is idempotent after the first successful remediation' {
        $first = Repair-GetNetworkProtection -GetPreference $getPreference -SetPreference $setPreference
        $second = Repair-GetNetworkProtection `
            -GetPreference $getPreference `
            -SetPreference { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
    }
}
