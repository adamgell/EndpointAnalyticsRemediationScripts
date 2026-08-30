BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Get-Always-Elevated/Detect-Get-Always-Elevated.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Get-Always-Elevated/Remediate-Get-Always-Elevated.ps1')
}

Describe 'Get-Always-Elevated registry contract' {
    BeforeEach {
        $registry = @{
            Exists = $true
            Value = 1
            Type = 'DWord'
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
            $registry.Value = $value
            $registry.Type = $type
        }
    }

    It 'detects a zero DWORD as compliant and reports structured state' {
        $registry.Value = 0

        $result = Test-GetAlwaysElevated -GetRegistry $getRegistry

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant'
        $result.State.Path | Should -Be 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer'
        $result.State.Name | Should -Be 'AlwaysInstallElevated'
        $result.State.ExpectedValue | Should -Be 0
        $result.State.ExpectedType | Should -Be 'DWORD'
        $result.State.ObservedValue | Should -Be 0
        $result.State.ObservedType | Should -Be 'DWord'
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects a nonzero value without mutating the registry fake' {
        $result = Test-GetAlwaysElevated -GetRegistry $getRegistry

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant'
        $result.State.ObservedValue | Should -Be 1
        $registry.SetCalls | Should -Be 0
        $registry.Value | Should -Be 1
    }

    It 'reports missing and failed registry dependencies' {
        $missing = Test-GetAlwaysElevated -GetRegistry $null
        $failed = Test-GetAlwaysElevated -GetRegistry { throw 'registry query failed' }

        $missing.Compliant | Should -BeFalse
        $missing.ExitCode | Should -Be 1
        $missing.Error.Type | Should -Be 'MissingDependency'
        $failed.Compliant | Should -BeFalse
        $failed.ExitCode | Should -Be 1
        $failed.Error.Type | Should -Be 'DependencyFailure'
        $failed.Error.Message | Should -Match 'registry query failed'
    }

    It 'reports a missing remediation setter dependency' {
        $result = Repair-GetAlwaysElevated -GetRegistry $getRegistry -SetRegistry $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'does not write an already compliant value' {
        $registry.Value = 0

        $result = Repair-GetAlwaysElevated -GetRegistry $getRegistry -SetRegistry $setRegistry

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.State.Before.ObservedValue | Should -Be 0
        $result.State.After.ObservedValue | Should -Be 0
        $registry.SetCalls | Should -Be 0
    }

    It 'writes only the package registry value and converges detection' {
        $result = Repair-GetAlwaysElevated -GetRegistry $getRegistry -SetRegistry $setRegistry
        $after = Test-GetAlwaysElevated -GetRegistry $getRegistry

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'R1 Remediated'
        $result.State.After.ObservedValue | Should -Be 0
        $registry.LastPath | Should -Be 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer'
        $registry.LastName | Should -Be 'AlwaysInstallElevated'
        $registry.LastValue | Should -Be 0
        $registry.LastType | Should -Be 'DWORD'
        $after.Compliant | Should -BeTrue
    }

    It 'is idempotent after remediation' {
        $first = Repair-GetAlwaysElevated -GetRegistry $getRegistry -SetRegistry $setRegistry
        $second = Repair-GetAlwaysElevated `
            -GetRegistry $getRegistry `
            -SetRegistry { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
        $registry.SetCalls | Should -Be 1
    }

    It 'returns a truthful remediation error when the setter fails before convergence' {
        $result = Repair-GetAlwaysElevated -GetRegistry $getRegistry -SetRegistry { throw 'registry update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'R1 Failed'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'registry update failed'
        (Test-GetAlwaysElevated -GetRegistry $getRegistry).Compliant | Should -BeFalse
    }
}
