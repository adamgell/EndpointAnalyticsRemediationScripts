BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Get-CloudDeliveredProtection/Detect-Get-CloudDeliveredProtection.ps1')
    . (
        Join-Path `
            $PSScriptRoot `
            '../../../scripts/Get-CloudDeliveredProtection/Remediate-Get-CloudDeliveredProtection.ps1'
    )
}

Describe 'Get-CloudDeliveredProtection function contract' {
    BeforeEach {
        $defenderState = [pscustomobject]@{
            MAPSReporting = 0
            SubmitSamplesConsent = 2
        }
        $getPreference = { [pscustomobject]@{
                MAPSReporting = $defenderState.MAPSReporting
                SubmitSamplesConsent = $defenderState.SubmitSamplesConsent
            } }
        $setPreference = {
            param([hashtable]$values)
            if ($values.ContainsKey('MAPSReporting')) { $defenderState.MAPSReporting = 2 }
            if ($values.ContainsKey('SubmitSamplesConsent')) { $defenderState.SubmitSamplesConsent = 3 }
        }
    }

    It 'detects advanced cloud reporting and all-sample submission as compliant' {
        $defenderState.MAPSReporting = 2
        $defenderState.SubmitSamplesConsent = 3

        $result = Test-GetCloudDeliveredProtection -GetPreference $getPreference

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'C1 COMPLIANT'
        $result.State.MAPSReporting | Should -Be 2
        $result.State.SubmitSamplesConsent | Should -Be 3
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects incomplete cloud protection as noncompliant' {
        $result = Test-GetCloudDeliveredProtection -GetPreference $getPreference

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'C1 NON-COMPLIANT'
        $defenderState.MAPSReporting | Should -Be 0
    }

    It 'reports a missing Defender preference dependency' {
        $result = Test-GetCloudDeliveredProtection -GetPreference $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'C1 DETECTION FAILED'
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a Defender preference query failure with truthful error evidence' {
        $result = Test-GetCloudDeliveredProtection -GetPreference { throw 'Defender preference query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Defender preference query failed'
    }

    It 'does not call the setter when cloud protection is already compliant' {
        $defenderState.MAPSReporting = 2
        $defenderState.SubmitSamplesConsent = 3
        $defenderState | Add-Member -NotePropertyName SetCalls -NotePropertyValue 0
        $set = {
            param([hashtable]$values)
            $defenderState.SetCalls++
        }

        $result = Repair-GetCloudDeliveredProtection -GetPreference $getPreference -SetPreference $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'R1 Remediated'
        $defenderState.SetCalls | Should -Be 0
    }

    It 'sets cloud protection and detection converges to compliant' {
        $result = Repair-GetCloudDeliveredProtection -GetPreference $getPreference -SetPreference $setPreference
        $after = Test-GetCloudDeliveredProtection -GetPreference $getPreference

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.State.After.MAPSReporting | Should -Be 2
        $result.State.After.SubmitSamplesConsent | Should -Be 3
        $after.Compliant | Should -BeTrue
    }

    It 'returns a truthful nonzero failure when Defender remediation fails' {
        $result = Repair-GetCloudDeliveredProtection `
            -GetPreference $getPreference `
            -SetPreference { throw 'Defender preference update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'R1 Failed'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Defender preference update failed'
        (Test-GetCloudDeliveredProtection -GetPreference $getPreference).Compliant | Should -BeFalse
    }

    It 'reports a missing setter dependency without mutating state' {
        $before = $defenderState | ConvertTo-Json
        $result = Repair-GetCloudDeliveredProtection -GetPreference $getPreference -SetPreference $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
        ($defenderState | ConvertTo-Json) | Should -Be $before
    }

    It 'is idempotent after the first successful remediation' {
        $first = Repair-GetCloudDeliveredProtection -GetPreference $getPreference -SetPreference $setPreference
        $second = Repair-GetCloudDeliveredProtection `
            -GetPreference $getPreference `
            -SetPreference { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
    }
}
