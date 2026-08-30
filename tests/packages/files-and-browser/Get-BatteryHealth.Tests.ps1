BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Get-BatteryHealth/Detect-Get-BatteryHealth.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Get-BatteryHealth/Remediate-Get-BatteryHealth.ps1')

    $testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('Get-BatteryHealth-' + [guid]::NewGuid().ToString('N'))
    New-Item -Path $testRoot -ItemType Directory -Force | Out-Null
}

AfterAll {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Describe 'Get-BatteryHealth function contract' {
    BeforeEach {
        $reportPath = Join-Path $testRoot ('battery-' + [guid]::NewGuid().ToString('N') + '.xml')
        $reportDirectory = Join-Path $testRoot ('reports-' + [guid]::NewGuid().ToString('N'))
        $batteryState = [pscustomobject]@{ Present = $true; Health = 35; ReportCalls = 0; PowerCalls = 0 }

        $getBattery = {
            if (-not $batteryState.Present) { return $null }
            [pscustomobject]@{ DeviceID = 'Battery0' }
        }
        $generateXmlReport = {
            param([string]$Path)
            $batteryState.ReportCalls++
            $xml = (
                "`n" +
                '<BatteryReport><Batteries><Battery><DesignCapacity>100</DesignCapacity>' +
                "<FullChargeCapacity>$($batteryState.Health)</FullChargeCapacity></Battery>" +
                "</Batteries></BatteryReport>`n"
            )
            Set-Content -LiteralPath $Path -Value $xml -Encoding UTF8
        }

        $testFile = { param([string]$Path) Test-Path -LiteralPath $Path }
        $readFile = { param([string]$Path) Get-Content -LiteralPath $Path -Raw }
        $removeFile = { param([string]$Path) Remove-Item -LiteralPath $Path -Force }
    }

    It 'reports a desktop with no battery as compliant without generating a report' {
        $batteryState.Present = $false
        $result = Test-GetBatteryHealth `
            -GetBattery $getBattery `
            -GenerateReport $generateXmlReport `
            -TestFile $testFile `
            -ReadFile $readFile `
            -RemoveFile $removeFile `
            -ReportPath $reportPath

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant - No battery detected (desktop)'
        $result.State.Kind | Should -Be 'NoBattery'
        $batteryState.ReportCalls | Should -Be 0
    }

    It 'reports a healthy battery as compliant and removes the temporary XML report' {
        $batteryState.Health = 80
        $result = Test-GetBatteryHealth `
            -GetBattery $getBattery `
            -GenerateReport $generateXmlReport `
            -TestFile $testFile `
            -ReadFile $readFile `
            -RemoveFile $removeFile `
            -ReportPath $reportPath

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant - Battery health: 80%'
        $result.State.HealthPercent | Should -Be 80
        (Test-Path -LiteralPath $reportPath) | Should -BeFalse
    }

    It 'reports a battery below the threshold as noncompliant' {
        $result = Test-GetBatteryHealth `
            -GetBattery $getBattery `
            -GenerateReport $generateXmlReport `
            -TestFile $testFile `
            -ReadFile $readFile `
            -RemoveFile $removeFile `
            -ReportPath $reportPath

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant - Battery health: 35%'
        $result.State.HealthPercent | Should -Be 35
    }

    It 'preserves the legacy compliant result when the report is not produced' {
        $result = Test-GetBatteryHealth `
            -GetBattery $getBattery `
            -GenerateReport { } `
            -TestFile $testFile `
            -ReadFile $readFile `
            -RemoveFile $removeFile `
            -ReportPath $reportPath

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant - Battery status OK'
        $result.State.Kind | Should -Be 'ReportUnavailable'
    }

    It 'reports a missing report dependency without running other boundaries' {
        $result = Test-GetBatteryHealth `
            -GetBattery $getBattery `
            -GenerateReport $null `
            -TestFile $testFile `
            -ReadFile $readFile `
            -RemoveFile $removeFile `
            -ReportPath $reportPath

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'DependencyMissing'
        $result.Error.Type | Should -Be 'MissingDependency'
        $batteryState.ReportCalls | Should -Be 0
    }

    It 'reports a battery report generation failure with truthful dependency evidence' {
        $result = Test-GetBatteryHealth `
            -GetBattery $getBattery `
            -GenerateReport { throw 'powercfg report failed' } `
            -TestFile $testFile `
            -ReadFile $readFile `
            -RemoveFile $removeFile `
            -ReportPath $reportPath

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'Error'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'powercfg report failed'
    }

    It 'does not apply power settings when remediation is already compliant' {
        $batteryState.Health = 80
        $getDetection = {
            Test-GetBatteryHealth `
                -GetBattery $getBattery `
                -GenerateReport $generateXmlReport `
                -TestFile $testFile `
                -ReadFile $readFile `
                -RemoveFile $removeFile `
                -ReportPath $reportPath
        }
        $result = Invoke-GetBatteryHealthRemediation `
            -GetDetection $getDetection `
            -GenerateReport $generateXmlReport `
            -SetPowerSetting { $batteryState.PowerCalls++ } `
            -TestFile $testFile `
            -ReportDirectory $reportDirectory `
            -ReportFile (Join-Path $reportDirectory 'battery.html')

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.State.Kind | Should -Be 'AlreadyCompliant'
        $batteryState.PowerCalls | Should -Be 0
    }

    It 'generates the report and applies settings without claiming health convergence' {
        $getDetection = {
            Test-GetBatteryHealth `
                -GetBattery $getBattery `
                -GenerateReport $generateXmlReport `
                -TestFile $testFile `
                -ReadFile $readFile `
                -RemoveFile $removeFile `
                -ReportPath $reportPath
        }
        $setPower = {
            $batteryState.PowerCalls++
        }
        $reportFile = Join-Path $reportDirectory 'battery.html'
        $result = Invoke-GetBatteryHealthRemediation -GetDetection $getDetection -GenerateReport {
            param([string]$Path)
            $batteryState.ReportCalls++
            Set-Content -LiteralPath $Path -Value '<html>battery</html>' -Encoding UTF8
        } -SetPowerSetting $setPower -TestFile $testFile -ReportDirectory $reportDirectory -ReportFile $reportFile

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Match 'Battery health detection remains deferred/unchanged'
        $result.State.Kind | Should -Be 'OptimizationApplied'
        $result.State.Before.Compliant | Should -BeFalse
        $result.State.DetectionStatus | Should -Be 'Deferred/Unchanged'
        $result.State.ReportPostcondition | Should -Be 'Passed'
        $result.State.PowerSettingCalls | Should -Be 3
        (Test-Path -LiteralPath $reportFile) | Should -BeTrue
        $batteryState.Health | Should -Be 35
        $batteryState.PowerCalls | Should -Be 3
    }

    It 'returns a truthful failure when the generated report postcondition is missing' {
        $getDetection = {
            [pscustomobject]@{
                Compliant = $false
                ExitCode = 1
                Message = 'Not Compliant'
                State = @{ Kind = 'LowHealth' }
                Error = $null
            }
        }
        $setPower = { $batteryState.PowerCalls++ }
        $result = Invoke-GetBatteryHealthRemediation `
            -GetDetection $getDetection `
            -GenerateReport { } `
            -SetPowerSetting $setPower `
            -TestFile $testFile `
            -ReportDirectory $reportDirectory `
            -ReportFile (Join-Path $reportDirectory 'battery.html')

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'PostconditionFailed'
        $result.Error.Type | Should -Be 'PostconditionFailure'
        $batteryState.PowerCalls | Should -Be 0
    }

    It 'returns a truthful nonzero failure when a power setting fails' {
        $getDetection = {
            [pscustomobject]@{
                Compliant = $false
                ExitCode = 1
                Message = 'Not Compliant'
                State = @{ Kind = 'LowHealth' }
                Error = $null
            }
        }
        $result = Invoke-GetBatteryHealthRemediation `
            -GetDetection $getDetection `
            -GenerateReport $generateXmlReport `
            -SetPowerSetting { throw 'power setting failed' } `
            -TestFile $testFile `
            -ReportDirectory $reportDirectory `
            -ReportFile (Join-Path $reportDirectory 'battery.html')

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'Error'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Message | Should -Match 'Failed to apply battery optimization settings'
        $result.Error.Message | Should -Match 'power setting failed'
    }

    It 'reports missing remediation dependencies without creating files' {
        $reportFile = Join-Path $reportDirectory 'battery.html'
        $result = Invoke-GetBatteryHealthRemediation `
            -GetDetection { [pscustomobject]@{ Compliant = $false } } `
            -GenerateReport $null `
            -SetPowerSetting { $batteryState.PowerCalls++ } `
            -TestFile $testFile `
            -ReportDirectory $reportDirectory `
            -ReportFile $reportFile

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
        (Test-Path -LiteralPath $reportFile) | Should -BeFalse
    }

    It 'repeats successful report and settings commands while health remains unchanged' {
        $batteryIdempotenceState = [pscustomobject]@{
            Compliant = $false
            ReportCalls = 0
            PowerCalls = 0
        }
        $batteryIdempotenceGet = { $batteryIdempotenceState }
        $batteryIdempotenceGenerate = {
            param([string]$Path)
            $batteryIdempotenceState.ReportCalls++
            Set-Content -LiteralPath $Path -Value '<html />' -Encoding UTF8
        }
        $batteryIdempotenceSet = {
            $batteryIdempotenceState.PowerCalls++
        }
        $batteryIdempotenceTestFile = {
            param([string]$Path)
            Test-Path -LiteralPath $Path
        }
        $batteryTempRoot = [System.IO.Path]::GetTempPath()
        $batteryIdempotenceDirectory = Join-Path `
            $batteryTempRoot ('Battery-' + [guid]::NewGuid().ToString('N'))
        New-Item -Path $batteryIdempotenceDirectory -ItemType Directory -Force | Out-Null
        $batteryIdempotenceReport = Join-Path $batteryIdempotenceDirectory 'battery.html'
        $first = Invoke-GetBatteryHealthRemediation `
            -GetDetection $batteryIdempotenceGet `
            -GenerateReport $batteryIdempotenceGenerate `
            -SetPowerSetting $batteryIdempotenceSet `
            -TestFile $batteryIdempotenceTestFile `
            -ReportDirectory $batteryIdempotenceDirectory `
            -ReportFile $batteryIdempotenceReport
        $second = Invoke-GetBatteryHealthRemediation `
            -GetDetection $batteryIdempotenceGet `
            -GenerateReport $batteryIdempotenceGenerate `
            -SetPowerSetting $batteryIdempotenceSet `
            -TestFile $batteryIdempotenceTestFile `
            -ReportDirectory $batteryIdempotenceDirectory `
            -ReportFile $batteryIdempotenceReport

        $first.Succeeded | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $first.Changed | Should -BeTrue
        $second.Changed | Should -BeTrue
        $second.State.DetectionStatus | Should -Be 'Deferred/Unchanged'
        $batteryIdempotenceState.Compliant | Should -BeFalse
        $batteryIdempotenceState.ReportCalls | Should -Be 2
        $batteryIdempotenceState.PowerCalls | Should -Be 6
    }

    It 'rejects a relative report directory before invoking dependencies' {
        $result = Invoke-GetBatteryHealthRemediation `
            -GetDetection { [pscustomobject]@{ Compliant = $false } } `
            -GenerateReport { throw 'should not run' } `
            -SetPowerSetting { throw 'should not run' } `
            -TestFile $testFile `
            -ReportDirectory 'reports' `
            -ReportFile 'reports/battery.html'

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.State.Kind | Should -Be 'SafetyRejected'
        $result.Error.Type | Should -Be 'InvalidPath'
    }
}
