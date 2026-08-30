BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Enforce-CredentialGuard/Detect-Enforce-CredentialGuard.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Enforce-CredentialGuard/Remediate-Enforce-CredentialGuard.ps1')
}

Describe 'Enforce-CredentialGuard function contract' {
    BeforeEach {
        $deviceGuard = [pscustomobject]@{
            SecurityServicesRunning = @(0)
            EnableVirtualizationBasedSecurity = 0
            RequirePlatformSecurityFeatures = 0
            LsaCfgFlags = 0
            UnrelatedValue = 'preserve'
            SetCalls = 0
        }
        $getState = {
            [pscustomobject]@{
                SecurityServicesRunning = @($deviceGuard.SecurityServicesRunning)
                EnableVirtualizationBasedSecurity = $deviceGuard.EnableVirtualizationBasedSecurity
                RequirePlatformSecurityFeatures = $deviceGuard.RequirePlatformSecurityFeatures
                LsaCfgFlags = $deviceGuard.LsaCfgFlags
            }
        }
        $setState = {
            param($desired)
            $deviceGuard.SetCalls++
            $deviceGuard.EnableVirtualizationBasedSecurity = [int]$desired.EnableVirtualizationBasedSecurity
            $deviceGuard.RequirePlatformSecurityFeatures = [int]$desired.RequirePlatformSecurityFeatures
            $deviceGuard.LsaCfgFlags = [int]$desired.LsaCfgFlags
        }
    }

    It 'detects running Credential Guard as compliant with the legacy output' {
        $deviceGuard.SecurityServicesRunning = @(1)

        $result = Test-EnforceCredentialGuard -GetState $getState

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant - Credential Guard is running'
        $result.State.SecurityServicesRunning | Should -Contain 1
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects a non-running Credential Guard service as noncompliant' {
        $result = Test-EnforceCredentialGuard -GetState $getState

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant - Credential Guard is not running'
        $deviceGuard.UnrelatedValue | Should -Be 'preserve'
    }

    It 'reports missing and failed Device Guard dependencies as structured errors' {
        $missing = Test-EnforceCredentialGuard -GetState $null
        $failed = Test-EnforceCredentialGuard -GetState { throw 'Device Guard query failed' }

        $missing.Error.Type | Should -Be 'MissingDependency'
        $missing.ExitCode | Should -Be 1
        $failed.Error.Type | Should -Be 'DependencyFailure'
        $failed.Error.Message | Should -Match 'Device Guard query failed'
    }

    It 'does not rewrite an already compliant Credential Guard configuration' {
        $deviceGuard.SecurityServicesRunning = @(1)

        $result = Repair-EnforceCredentialGuard -GetState $getState -SetState $setState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Credential Guard has been enabled. A reboot is required.'
        $result.State.Status | Should -Be 'Compliant'
        $deviceGuard.SetCalls | Should -Be 0
        $deviceGuard.UnrelatedValue | Should -Be 'preserve'
    }

    It 'verifies registry values and defers detection compliance until reboot' {
        $result = Repair-EnforceCredentialGuard -GetState $getState -SetState $setState
        $beforeReboot = Test-EnforceCredentialGuard -GetState $getState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.State.Status | Should -Be 'PendingReboot'
        $result.State.Kind | Should -Be 'PendingReboot'
        $result.State.Convergence | Should -Be 'DeferredUntilReboot'
        $result.State.After.EnableVirtualizationBasedSecurity | Should -Be 1
        $result.State.After.RequirePlatformSecurityFeatures | Should -Be 1
        $result.State.After.LsaCfgFlags | Should -Be 1
        $beforeReboot.Compliant | Should -BeFalse

        $deviceGuard.SecurityServicesRunning = @(1)
        $afterReboot = Test-EnforceCredentialGuard -GetState $getState

        $afterReboot.Compliant | Should -BeTrue
        $deviceGuard.UnrelatedValue | Should -Be 'preserve'
    }

    It 'reports a failed registry write without claiming success' {
        $result = Repair-EnforceCredentialGuard `
            -GetState $getState `
            -SetState { throw 'Credential Guard registry update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Match 'Failed to enable Credential Guard'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Credential Guard registry update failed'
        (Test-EnforceCredentialGuard -GetState $getState).Compliant | Should -BeFalse
    }

    It 'is idempotent after reboot enables Credential Guard' {
        $first = Repair-EnforceCredentialGuard -GetState $getState -SetState $setState
        $deviceGuard.SecurityServicesRunning = @(1)
        $second = Repair-EnforceCredentialGuard -GetState $getState -SetState {
            throw 'setter should not be called'
        }

        $first.Changed | Should -BeTrue
        $first.State.Status | Should -Be 'PendingReboot'
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
        $second.State.Status | Should -Be 'Compliant'
        $deviceGuard.SecurityServicesRunning | Should -Be 1
    }
}
