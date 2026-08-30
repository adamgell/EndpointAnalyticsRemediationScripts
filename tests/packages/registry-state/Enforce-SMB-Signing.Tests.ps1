BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Enforce-SMB-Signing/Detect-Enforce-SMB-Signing.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Enforce-SMB-Signing/Remediate-Enforce-SMB-Signing.ps1')
}

Describe 'Enforce-SMB-Signing function contract' {
    BeforeEach {
        $registry = [pscustomobject]@{
            RequireSecuritySignature = 0
            UnrelatedValue = 'preserve'
            SetCalls = 0
        }
        $getState = {
            [pscustomobject]@{
                RequireSecuritySignature = $registry.RequireSecuritySignature
            }
        }
        $setState = {
            param($value)
            $registry.SetCalls++
            $registry.RequireSecuritySignature = [int]$value
        }
    }

    It 'detects required SMB signing as compliant with the legacy output' {
        $registry.RequireSecuritySignature = 1

        $result = Test-EnforceSMBSigning -GetState $getState

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant'
        $result.State.RequireSecuritySignature | Should -Be 1
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects optional SMB signing as noncompliant without changing state' {
        $result = Test-EnforceSMBSigning -GetState $getState

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant'
        $registry.UnrelatedValue | Should -Be 'preserve'
    }

    It 'reports missing and failed SMB registry dependencies as structured errors' {
        $missing = Test-EnforceSMBSigning -GetState $null
        $failed = Test-EnforceSMBSigning -GetState { throw 'SMB signing query failed' }

        $missing.Error.Type | Should -Be 'MissingDependency'
        $missing.ExitCode | Should -Be 1
        $failed.Error.Type | Should -Be 'DependencyFailure'
        $failed.Error.Message | Should -Match 'SMB signing query failed'
    }

    It 'does not rewrite an already compliant SMB signing value' {
        $registry.RequireSecuritySignature = 1

        $result = Repair-EnforceSMBSigning -GetState $getState -SetState $setState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $registry.SetCalls | Should -Be 0
        $registry.UnrelatedValue | Should -Be 'preserve'
    }

    It 'enables SMB signing and converges to compliant detection' {
        $result = Repair-EnforceSMBSigning -GetState $getState -SetState $setState
        $after = Test-EnforceSMBSigning -GetState $getState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.State.After.RequireSecuritySignature | Should -Be 1
        $after.Compliant | Should -BeTrue
        $registry.UnrelatedValue | Should -Be 'preserve'
    }

    It 'reports a failed registry write without claiming success' {
        $result = Repair-EnforceSMBSigning -GetState $getState -SetState { throw 'SMB signing update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'SMB signing update failed'
        (Test-EnforceSMBSigning -GetState $getState).Compliant | Should -BeFalse
    }

    It 'is idempotent after enabling SMB signing' {
        $first = Repair-EnforceSMBSigning -GetState $getState -SetState $setState
        $second = Repair-EnforceSMBSigning -GetState $getState -SetState { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
        $registry.RequireSecuritySignature | Should -Be 1
    }
}
