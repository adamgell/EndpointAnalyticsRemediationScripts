BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Fortinet-VPN-Profile/Detect-Fortinet-VPN-Profile.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Fortinet-VPN-Profile/Remediate-Fortinet-VPN-Profile.ps1')
}

Describe 'Fortinet-VPN-Profile function contract' {
    BeforeEach {
        $profile = [pscustomobject]@{
            Exists = $false
            Description = $null
            Server = $null
            promptusername = $null
            promptcertificate = $null
            ServerCert = $null
            UnrelatedValue = 'preserve'
            SetCalls = 0
        }
        $getState = {
            [pscustomobject]@{
                Exists = $profile.Exists
                Description = $profile.Description
                Server = $profile.Server
                promptusername = $profile.promptusername
                promptcertificate = $profile.promptcertificate
                ServerCert = $profile.ServerCert
            }
        }
        $setState = {
            param($desired)
            $profile.SetCalls++
            $profile.Exists = $true
            $profile.Description = [string]$desired.Description
            $profile.Server = [string]$desired.Server
            $profile.promptusername = [int]$desired.promptusername
            $profile.promptcertificate = [int]$desired.promptcertificate
            $profile.ServerCert = [string]$desired.ServerCert
        }
    }

    It 'detects an existing VPN profile as compliant with the legacy output' {
        $profile.Exists = $true

        $result = Test-FortinetVPNProfile -GetState $getState

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'OK'
        $result.State.Exists | Should -BeTrue
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects a missing VPN profile as noncompliant' {
        $result = Test-FortinetVPNProfile -GetState $getState

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not existing'
        $profile.UnrelatedValue | Should -Be 'preserve'
    }

    It 'reports missing and failed Fortinet registry dependencies as structured errors' {
        $missing = Test-FortinetVPNProfile -GetState $null
        $failed = Test-FortinetVPNProfile -GetState { throw 'Fortinet profile query failed' }

        $missing.Error.Type | Should -Be 'MissingDependency'
        $missing.ExitCode | Should -Be 1
        $failed.Error.Type | Should -Be 'DependencyFailure'
        $failed.Error.Message | Should -Match 'Fortinet profile query failed'
    }

    It 'does not rewrite an already complete VPN profile' {
        $profile.Exists = $true
        $profile.Description = 'Simons VPN'
        $profile.Server = 'vpn.skotheimsvik.no:443'
        $profile.promptusername = 1
        $profile.promptcertificate = 0
        $profile.ServerCert = '1'

        $result = Repair-FortinetVPNProfile -GetState $getState -SetState $setState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.Message | Should -BeNullOrEmpty
        $profile.SetCalls | Should -Be 0
        $profile.UnrelatedValue | Should -Be 'preserve'
    }

    It 'creates the configured VPN profile and converges to compliant detection' {
        $result = Repair-FortinetVPNProfile -GetState $getState -SetState $setState
        $after = Test-FortinetVPNProfile -GetState $getState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.State.After.Exists | Should -BeTrue
        $result.State.After.Description | Should -Be 'Simons VPN'
        $result.State.After.Server | Should -Be 'vpn.skotheimsvik.no:443'
        $result.State.After.promptusername | Should -Be 1
        $result.State.After.promptcertificate | Should -Be 0
        $result.State.After.ServerCert | Should -Be '1'
        $after.Compliant | Should -BeTrue
        $profile.UnrelatedValue | Should -Be 'preserve'
    }

    It 'repairs an existing but incomplete profile without touching unrelated state' {
        $profile.Exists = $true
        $profile.Description = 'old description'

        $result = Repair-FortinetVPNProfile -GetState $getState -SetState $setState

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $profile.Server | Should -Be 'vpn.skotheimsvik.no:443'
        $profile.UnrelatedValue | Should -Be 'preserve'
    }

    It 'reports a failed profile write with the legacy nonzero remediation mapping' {
        $result = Repair-FortinetVPNProfile -GetState $getState -SetState { throw 'Fortinet profile update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be -1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Fortinet profile update failed'
        (Test-FortinetVPNProfile -GetState $getState).Compliant | Should -BeFalse
    }

    It 'is idempotent after creating the VPN profile' {
        $first = Repair-FortinetVPNProfile -GetState $getState -SetState $setState
        $second = Repair-FortinetVPNProfile -GetState $getState -SetState { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
        $profile.Exists | Should -BeTrue
    }
}
