BeforeAll {
    $scriptPath = Join-Path $PSScriptRoot '../../../scripts/Disable-SMBv1/Detect-Disable-SMBv1.ps1'
    . $scriptPath
    $remediationPath = Join-Path $PSScriptRoot '../../../scripts/Disable-SMBv1/Remediate-Disable-SMBv1.ps1'
    . $remediationPath
}

Describe 'Disable-SMBv1 function contract' {
    BeforeEach {
        $smbState = [pscustomobject]@{ Enabled = $true }
        $getState = { [pscustomobject]@{ EnableSMB1Protocol = $smbState.Enabled } }
        $setState = {
            param($enabled)
            $smbState.Enabled = [bool]$enabled
        }
    }

    It 'detects disabled SMBv1 as compliant with the stable message and exit mapping' {
        $smbState.Enabled = $false

        $result = Test-DisableSMBv1 -GetState $getState

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'SMBv1 is disabled'
        $result.State.EnableSMB1Protocol | Should -BeFalse
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects enabled SMBv1 as noncompliant without changing state' {
        $result = Test-DisableSMBv1 -GetState $getState

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'SMBv1 is enabled'
        $smbState.Enabled | Should -BeTrue
    }

    It 'reports a missing state dependency as a noncompliant detection error' {
        $result = Test-DisableSMBv1 -GetState $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'SMBv1 detection failed.'
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a state dependency failure with truthful error evidence' {
        $result = Test-DisableSMBv1 -GetState { throw 'SMB query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'SMB query failed'
    }

    It 'does nothing when SMBv1 is already disabled' {
        $smbState.Enabled = $false
        $setCalls = 0
        $set = {
            param($enabled)
            $setCalls++
            $smbState.Enabled = [bool]$enabled
        }

        $result = Repair-DisableSMBv1 -GetState $getState -SetState $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'R1 Remediated'
        $setCalls | Should -Be 0
        $smbState.Enabled | Should -BeFalse
    }

    It 'disables SMBv1 and detection converges to compliant' {
        $result = Repair-DisableSMBv1 -GetState $getState -SetState $setState
        $after = Test-DisableSMBv1 -GetState $getState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State.After.EnableSMB1Protocol | Should -BeFalse
        $after.Compliant | Should -BeTrue
        $smbState.Enabled | Should -BeFalse
    }

    It 'returns a nonzero truthful failure when SMB remediation cannot change state' {
        $result = Repair-DisableSMBv1 -GetState $getState -SetState { throw 'SMB update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'R1 Failed'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'SMB update failed'
        (Test-DisableSMBv1 -GetState $getState).Compliant | Should -BeFalse
    }

    It 'reports a missing setter dependency without changing SMB state' {
        $before = $smbState.Enabled
        $result = Repair-DisableSMBv1 -GetState $getState -SetState $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
        $smbState.Enabled | Should -Be $before
    }

    It 'is idempotent after the first successful remediation' {
        $first = Repair-DisableSMBv1 -GetState $getState -SetState $setState
        $second = Repair-DisableSMBv1 -GetState $getState -SetState $setState

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
        $smbState.Enabled | Should -BeFalse
    }
}
