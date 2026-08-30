BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Enforce-WindowsFirewall/Detect-Enforce-WindowsFirewall.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Enforce-WindowsFirewall/Remediate-Enforce-WindowsFirewall.ps1')
}

Describe 'Enforce-WindowsFirewall function contract' {
    BeforeEach {
        $firewallState = @{
            Domain = $false
            Public = $true
            Private = $false
        }
        $getProfiles = {
            @(
                [pscustomobject]@{ Name = 'Domain'; Enabled = $firewallState.Domain }
                [pscustomobject]@{ Name = 'Public'; Enabled = $firewallState.Public }
                [pscustomobject]@{ Name = 'Private'; Enabled = $firewallState.Private }
            )
        }
        $setProfiles = {
            param($profiles)
            foreach ($profile in $profiles) { $firewallState[$profile] = $true }
        }
    }

    It 'detects all firewall profiles enabled as compliant' {
        $firewallState.Domain = $true
        $firewallState.Private = $true

        $result = Test-EnforceWindowsFirewall -GetProfiles $getProfiles

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant - All firewall profiles are enabled'
        $result.State.DisabledProfiles.Count | Should -Be 0
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects each disabled firewall profile as noncompliant' {
        $result = Test-EnforceWindowsFirewall -GetProfiles $getProfiles

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Match 'Domain'
        $result.Message | Should -Match 'Private'
        $result.State.DisabledProfiles | Should -Contain 'Domain'
        $result.State.DisabledProfiles | Should -Contain 'Private'
        $firewallState.Domain | Should -BeFalse
    }

    It 'reports a missing firewall dependency' {
        $result = Test-EnforceWindowsFirewall -GetProfiles $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant - Error checking firewall'
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a firewall query failure with truthful error evidence' {
        $result = Test-EnforceWindowsFirewall -GetProfiles { throw 'firewall query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'firewall query failed'
    }

    It 'does not call the firewall setter when all profiles are already enabled' {
        $firewallState.Domain = $true
        $firewallState.Private = $true
        $firewallState | Add-Member -NotePropertyName SetCalls -NotePropertyValue 0
        $set = {
            param($profiles)
            $firewallState.SetCalls++
            foreach ($profile in $profiles) { $firewallState[$profile] = $true }
        }

        $result = Repair-EnforceWindowsFirewall -GetProfiles $getProfiles -SetProfiles $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Windows Firewall enabled on all profiles successfully'
        $firewallState.SetCalls | Should -Be 0
    }

    It 'enables disabled profiles and detection converges to compliant' {
        $result = Repair-EnforceWindowsFirewall -GetProfiles $getProfiles -SetProfiles $setProfiles
        $after = Test-EnforceWindowsFirewall -GetProfiles $getProfiles

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.State.After.DisabledProfiles.Count | Should -Be 0
        $after.Compliant | Should -BeTrue
        $firewallState.Domain | Should -BeTrue
        $firewallState.Private | Should -BeTrue
    }

    It 'returns a nonzero truthful failure when firewall remediation fails' {
        $result = Repair-EnforceWindowsFirewall `
            -GetProfiles $getProfiles `
            -SetProfiles { throw 'firewall update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Failed to enable Windows Firewall'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'firewall update failed'
        (Test-EnforceWindowsFirewall -GetProfiles $getProfiles).Compliant | Should -BeFalse
    }

    It 'reports a missing setter dependency without changing profiles' {
        $before = @{} + $firewallState
        $result = Repair-EnforceWindowsFirewall -GetProfiles $getProfiles -SetProfiles $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
        $firewallState.Domain | Should -Be $before.Domain
        $firewallState.Private | Should -Be $before.Private
    }

    It 'is idempotent after the first successful firewall remediation' {
        $first = Repair-EnforceWindowsFirewall -GetProfiles $getProfiles -SetProfiles $setProfiles
        $second = Repair-EnforceWindowsFirewall `
            -GetProfiles $getProfiles `
            -SetProfiles { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
    }
}
