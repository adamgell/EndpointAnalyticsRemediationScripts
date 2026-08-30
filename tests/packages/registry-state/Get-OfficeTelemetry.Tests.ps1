BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Get-OfficeTelemetry/Detect-Get-OfficeTelemetry.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Get-OfficeTelemetry/Remediate-Get-OfficeTelemetry.ps1')
}

Describe 'Get-OfficeTelemetry registry contract' {
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

    It 'detects DisableTelemetry DWORD 1 as compliant with structured state' {
        $registry.Value = 1

        $result = Test-GetOfficeTelemetry -GetRegistry $getRegistry

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant'
        $result.State.Path | Should -Be 'HKCU:\Software\Policies\Microsoft\office\common\clienttelemetry'
        $result.State.Name | Should -Be 'DisableTelemetry'
        $result.State.ExpectedValue | Should -Be 1
        $result.State.ExpectedType | Should -Be 'DWORD'
        $result.State.ObservedValue | Should -Be 1
        $result.State.ObservedType | Should -Be 'DWord'
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects telemetry as noncompliant without mutating the user registry fake' {
        $result = Test-GetOfficeTelemetry -GetRegistry $getRegistry

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant'
        $result.State.ObservedValue | Should -Be 0
        $registry.SetCalls | Should -Be 0
    }

    It 'reports missing and failed registry dependencies' {
        $missing = Test-GetOfficeTelemetry -GetRegistry $null
        $failed = Test-GetOfficeTelemetry -GetRegistry { throw 'Office telemetry query failed' }

        $missing.Compliant | Should -BeFalse
        $missing.ExitCode | Should -Be 1
        $missing.Error.Type | Should -Be 'MissingDependency'
        $failed.Compliant | Should -BeFalse
        $failed.ExitCode | Should -Be 1
        $failed.Error.Type | Should -Be 'DependencyFailure'
        $failed.Error.Message | Should -Match 'Office telemetry query failed'
    }


    It 'reports a missing remediation setter dependency' {
        $result = Repair-GetOfficeTelemetry -GetRegistry $getRegistry -SetRegistry $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
    }
    It 'does not write when Office telemetry is already disabled' {
        $registry.Value = 1

        $result = Repair-GetOfficeTelemetry -GetRegistry $getRegistry -SetRegistry $setRegistry

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.State.Before.ObservedValue | Should -Be 1
        $result.State.After.ObservedValue | Should -Be 1
        $registry.SetCalls | Should -Be 0
    }

    It 'sets DisableTelemetry at the exact user path and converges detection' {
        $result = Repair-GetOfficeTelemetry -GetRegistry $getRegistry -SetRegistry $setRegistry
        $after = Test-GetOfficeTelemetry -GetRegistry $getRegistry

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'R1 Remediated'
        $result.State.After.ObservedValue | Should -Be 1
        $registry.LastPath | Should -Be 'HKCU:\Software\Policies\Microsoft\office\common\clienttelemetry'
        $registry.LastName | Should -Be 'DisableTelemetry'
        $registry.LastValue | Should -Be 1
        $registry.LastType | Should -Be 'DWORD'
        $after.Compliant | Should -BeTrue
    }

    It 'is idempotent after disabling Office telemetry' {
        $first = Repair-GetOfficeTelemetry -GetRegistry $getRegistry -SetRegistry $setRegistry
        $second = Repair-GetOfficeTelemetry `
            -GetRegistry $getRegistry `
            -SetRegistry { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
        $registry.SetCalls | Should -Be 1
    }

    It 'returns a truthful remediation error when updating Office telemetry fails' {
        $result = Repair-GetOfficeTelemetry `
            -GetRegistry $getRegistry `
            -SetRegistry { throw 'Office telemetry update failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'R1 Failed'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Office telemetry update failed'
        (Test-GetOfficeTelemetry -GetRegistry $getRegistry).Compliant | Should -BeFalse
    }
}
