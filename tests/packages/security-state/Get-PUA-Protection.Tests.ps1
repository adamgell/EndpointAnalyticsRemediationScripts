BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Get-PUA-Protection/Detect-Get-PUA-Protection.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Get-PUA-Protection/Remediate-Get-PUA-Protection.ps1')
}

Describe 'Get-PUA-Protection function contract' {
    BeforeEach {
        $defenderState = [pscustomobject]@{ PUAProtection = 0 }
        $getPreference = { [pscustomobject]@{ PUAProtection = $defenderState.PUAProtection } }
        $setPreference = {
            param([hashtable]$values)
            $defenderState.PUAProtection = 1
        }
    }

    It 'detects enabled PUA protection as compliant' {
        $defenderState.PUAProtection = 1

        $result = Test-GetPUAProtection -GetPreference $getPreference

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'C1 COMPLIANT'
        $result.State.PUAProtection | Should -Be 1
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects disabled PUA protection as noncompliant' {
        $result = Test-GetPUAProtection -GetPreference $getPreference

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'C1 NON-COMPLIANT'
        $defenderState.PUAProtection | Should -Be 0
    }

    It 'reports a missing Defender preference dependency' {
        $result = Test-GetPUAProtection -GetPreference $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'C1 DETECTION FAILED'
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a Defender preference query failure with truthful error evidence' {
        $result = Test-GetPUAProtection -GetPreference { throw 'PUA preference query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'PUA preference query failed'
    }

    It 'does not call the setter when PUA protection is already enabled' {
        $defenderState.PUAProtection = 1
        $defenderState | Add-Member -NotePropertyName SetCalls -NotePropertyValue 0
        $set = {
            param([hashtable]$values)
            $defenderState.SetCalls++
        }

        $result = Repair-GetPUAProtection -GetPreference $getPreference -SetPreference $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'R1 Remediated'
        $defenderState.SetCalls | Should -Be 0
    }

    It 'enables PUA protection and detection converges to compliant' {
        $result = Repair-GetPUAProtection -GetPreference $getPreference -SetPreference $setPreference
        $after = Test-GetPUAProtection -GetPreference $getPreference

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.State.After.PUAProtection | Should -Be 1
        $after.Compliant | Should -BeTrue
    }

    It 'returns a truthful nonzero failure when PUA remediation fails' {
        $result = Repair-GetPUAProtection -GetPreference $getPreference -SetPreference { throw 'PUA update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'R1 Failed'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'PUA update failed'
        (Test-GetPUAProtection -GetPreference $getPreference).Compliant | Should -BeFalse
    }

    It 'reports a missing setter dependency without mutating Defender state' {
        $before = $defenderState.PUAProtection
        $result = Repair-GetPUAProtection -GetPreference $getPreference -SetPreference $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
        $defenderState.PUAProtection | Should -Be $before
    }

    It 'is idempotent after the first successful remediation' {
        $first = Repair-GetPUAProtection -GetPreference $getPreference -SetPreference $setPreference
        $second = Repair-GetPUAProtection `
            -GetPreference $getPreference `
            -SetPreference { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
    }
}
