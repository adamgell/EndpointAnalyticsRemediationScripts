BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Get-LSA-Protection/Detect-Get-LSA-Protection.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Get-LSA-Protection/Remediate-Get-LSA-Protection.ps1')
}

Describe 'Get-LSA-Protection registry contract' {
    BeforeEach {
        $registry = @{
            Exists = $true
            Value = 0
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

    It 'detects RunAsPPL DWORD 1 as compliant with structured state' {
        $registry.Value = 1

        $result = Test-GetLSAProtection -GetRegistry $getRegistry

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant'
        $result.State.Path | Should -Be 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
        $result.State.Name | Should -Be 'RunAsPPL'
        $result.State.ExpectedValue | Should -Be 1
        $result.State.ExpectedType | Should -Be 'DWORD'
        $result.State.ObservedValue | Should -Be 1
        $result.State.ObservedType | Should -Be 'DWord'
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects disabled LSA protection without changing registry state' {
        $result = Test-GetLSAProtection -GetRegistry $getRegistry

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant'
        $result.State.ObservedValue | Should -Be 0
        $registry.SetCalls | Should -Be 0
    }

    It 'reports missing and failed registry dependencies' {
        $missing = Test-GetLSAProtection -GetRegistry $null
        $failed = Test-GetLSAProtection -GetRegistry { throw 'LSA query failed' }

        $missing.Compliant | Should -BeFalse
        $missing.ExitCode | Should -Be 1
        $missing.Error.Type | Should -Be 'MissingDependency'
        $failed.Compliant | Should -BeFalse
        $failed.ExitCode | Should -Be 1
        $failed.Error.Type | Should -Be 'DependencyFailure'
        $failed.Error.Message | Should -Match 'LSA query failed'
    }


    It 'reports a missing remediation setter dependency' {
        $result = Repair-GetLSAProtection -GetRegistry $getRegistry -SetRegistry $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }
    It 'does not write when LSA protection is already enabled' {
        $registry.Value = 1

        $result = Repair-GetLSAProtection -GetRegistry $getRegistry -SetRegistry $setRegistry

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.State.Before.ObservedValue | Should -Be 1
        $result.State.After.ObservedValue | Should -Be 1
        $registry.SetCalls | Should -Be 0
    }

    It 'sets RunAsPPL at the exact package path and converges detection' {
        $result = Repair-GetLSAProtection -GetRegistry $getRegistry -SetRegistry $setRegistry
        $after = Test-GetLSAProtection -GetRegistry $getRegistry

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'R1 Remediated'
        $result.State.After.ObservedValue | Should -Be 1
        $registry.LastPath | Should -Be 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
        $registry.LastName | Should -Be 'RunAsPPL'
        $registry.LastValue | Should -Be 1
        $registry.LastType | Should -Be 'DWORD'
        $after.Compliant | Should -BeTrue
    }

    It 'is idempotent after enabling LSA protection' {
        $first = Repair-GetLSAProtection -GetRegistry $getRegistry -SetRegistry $setRegistry
        $second = Repair-GetLSAProtection -GetRegistry $getRegistry -SetRegistry { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
        $registry.SetCalls | Should -Be 1
    }

    It 'returns a truthful remediation error when updating LSA protection fails' {
        $result = Repair-GetLSAProtection -GetRegistry $getRegistry -SetRegistry { throw 'LSA update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'R1 Failed'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'LSA update failed'
        (Test-GetLSAProtection -GetRegistry $getRegistry).Compliant | Should -BeFalse
    }
}
