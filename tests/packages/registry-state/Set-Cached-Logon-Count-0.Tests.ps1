BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Set-Cached-Logon-Count-0/Detect-Set-Cached-Logon-Count-0.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Set-Cached-Logon-Count-0/Remediate-Set-Cached-Logon-Count-0.ps1')
}

Describe 'Set-Cached-Logon-Count-0 registry contract' {
    BeforeEach {
        $registry = @{
            Exists = $true
            Value = '10'
            Type = 'String'
            SetCalls = 0
            LastPath = $null
            LastName = $null
            LastValue = $null
            LastType = $null
        }
        $getRegistry = {
            param($path, $name)
            if (-not $registry.Exists) {
                return [pscustomobject]@{ Exists = $false; Value = $null; Type = $null }
            }
            [pscustomobject]@{ Exists = $true; Value = $registry.Value; Type = $registry.Type }
        }
        $setRegistry = {
            param($path, $name, $value, $type)
            $registry.SetCalls++
            $registry.LastPath = $path
            $registry.LastName = $name
            $registry.LastValue = $value
            $registry.LastType = $type
            $registry.Exists = $true
            $registry.Value = [string]$value
            $registry.Type = $type
        }
    }

    It 'detects CachedLogonsCount string zero as compliant with structured state' {
        $registry.Value = '0'

        $result = Test-SetCachedLogonCount0 -GetRegistry $getRegistry

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant'
        $result.State.Path | Should -Be 'HKLM:\Software\Microsoft\Windows Nt\CurrentVersion\Winlogon'
        $result.State.Name | Should -Be 'CachedLogonsCount'
        $result.State.ExpectedValue | Should -Be 0
        $result.State.ExpectedType | Should -Be 'REG_SZ'
        $result.State.ObservedValue | Should -Be '0'
        $result.State.ObservedType | Should -Be 'String'
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects a nonzero cached logon count without changing registry state' {
        $result = Test-SetCachedLogonCount0 -GetRegistry $getRegistry

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant'
        $result.State.ObservedValue | Should -Be '10'
        $registry.SetCalls | Should -Be 0
    }

    It 'reports missing and failed registry dependencies' {
        $missing = Test-SetCachedLogonCount0 -GetRegistry $null
        $failed = Test-SetCachedLogonCount0 -GetRegistry { throw 'cached logon query failed' }

        $missing.Compliant | Should -BeFalse
        $missing.ExitCode | Should -Be 1
        $missing.Error.Type | Should -Be 'MissingDependency'
        $failed.Compliant | Should -BeFalse
        $failed.ExitCode | Should -Be 1
        $failed.Error.Type | Should -Be 'DependencyFailure'
        $failed.Error.Message | Should -Match 'cached logon query failed'
    }


    It 'reports a missing remediation setter dependency' {
        $result = Repair-SetCachedLogonCount0 -GetRegistry $getRegistry -SetRegistry $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }
    It 'does not write when cached logon count is already zero' {
        $registry.Value = '0'

        $result = Repair-SetCachedLogonCount0 -GetRegistry $getRegistry -SetRegistry $setRegistry

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.State.Before.ObservedValue | Should -Be '0'
        $result.State.After.ObservedValue | Should -Be '0'
        $registry.SetCalls | Should -Be 0
    }

    It 'sets a string zero at the exact Winlogon path and converges detection' {
        $result = Repair-SetCachedLogonCount0 -GetRegistry $getRegistry -SetRegistry $setRegistry
        $after = Test-SetCachedLogonCount0 -GetRegistry $getRegistry

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'R1 Remediated'
        $result.State.After.ObservedValue | Should -Be '0'
        $registry.LastPath | Should -Be 'HKLM:\Software\Microsoft\Windows Nt\CurrentVersion\Winlogon'
        $registry.LastName | Should -Be 'CachedLogonsCount'
        $registry.LastValue | Should -Be 0
        $registry.LastType | Should -Be 'REG_SZ'
        $after.Compliant | Should -BeTrue
    }

    It 'is idempotent after setting cached logon count to zero' {
        $first = Repair-SetCachedLogonCount0 -GetRegistry $getRegistry -SetRegistry $setRegistry
        $second = Repair-SetCachedLogonCount0 `
            -GetRegistry $getRegistry `
            -SetRegistry { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
        $registry.SetCalls | Should -Be 1
    }

    It 'returns a truthful remediation error when updating cached logon count fails' {
        $result = Repair-SetCachedLogonCount0 `
            -GetRegistry $getRegistry `
            -SetRegistry { throw 'cached logon update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'R1 Failed'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'cached logon update failed'
        (Test-SetCachedLogonCount0 -GetRegistry $getRegistry).Compliant | Should -BeFalse
    }
}
