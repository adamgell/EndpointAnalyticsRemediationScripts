<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: generate-batteryreport.ps1
Description: Generates a battery health report and applies power optimizations
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

function Invoke-GetBatteryHealthNativeReport {
    [CmdletBinding()]
    param(
        [string]$ReportPath
    )

    $null = & powercfg /batteryreport /output $ReportPath 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "powercfg battery report failed with exit code $LASTEXITCODE."
    }
}

function Invoke-GetBatteryHealthNativePowerSetting {
    [CmdletBinding()]
    param(
        [string[]]$Arguments
    )

    & powercfg @Arguments 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "powercfg $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }
}

function Get-GetBatteryHealthNativeDetection {
    [CmdletBinding()]
    param(
        [int]$MinimumHealthPercent = 40
    )

    $tempRoot = [Environment]::GetEnvironmentVariable('TEMP')
    if ([string]::IsNullOrWhiteSpace($tempRoot)) {
        $tempRoot = [System.IO.Path]::GetTempPath()
    }
    $reportPath = Join-Path $tempRoot 'battery-report.xml'
    try {
        $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction Stop
        if (-not $battery) {
            return [pscustomobject]@{
                Compliant = $true
                State = [pscustomobject]@{ Kind = 'NoBattery' }
                Error = $null
            }
        }
        $null = Invoke-GetBatteryHealthNativeReport -ReportPath $reportPath
        if (-not (Test-Path -LiteralPath $reportPath)) {
            return [pscustomobject]@{
                Compliant = $false
                State = [pscustomobject]@{ Kind = 'ReportUnavailable' }
                Error = [pscustomobject]@{ Type = 'PostconditionFailure'; Message = 'Battery report was not produced.' }
            }
        }
        [xml]$report = Get-Content -LiteralPath $reportPath -Raw
        $batteryReport = @($report.BatteryReport.Batteries.Battery)[0]
        $designCapacity = [double]$batteryReport.DesignCapacity
        $fullChargeCapacity = [double]$batteryReport.FullChargeCapacity
        Remove-Item -LiteralPath $reportPath -Force -ErrorAction Stop
        $healthPercent = [math]::Round(($fullChargeCapacity / $designCapacity) * 100, 2)
        [pscustomobject]@{
            Compliant = ($healthPercent -ge $MinimumHealthPercent)
            State = [pscustomobject]@{
                Kind = if ($healthPercent -lt $MinimumHealthPercent) { 'LowHealth' } else { 'Healthy' }
                HealthPercent = $healthPercent
            }
            Error = $null
        }
    }
    catch {
        if (Test-Path -LiteralPath $reportPath) {
            Remove-Item -LiteralPath $reportPath -Force -ErrorAction SilentlyContinue
        }
        [pscustomobject]@{
            Compliant = $false
            State = [pscustomobject]@{ Kind = 'Error' }
            Error = $_.Exception.Message
        }
    }
}

function Invoke-GetBatteryHealthRemediation {
    [CmdletBinding()]
    param(
        [scriptblock]$GetDetection,
        [scriptblock]$GenerateReport,
        [scriptblock]$SetPowerSetting,
        [scriptblock]$TestFile,
        [string]$ReportDirectory,
        [string]$ReportFile
    )

    $missing = @(
        if ($null -eq $GetDetection) { 'GetDetection' }
        if ($null -eq $GenerateReport) { 'GenerateReport' }
        if ($null -eq $SetPowerSetting) { 'SetPowerSetting' }
        if ($null -eq $TestFile) { 'TestFile' }
    )
    if ($missing.Count -gt 0) {
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to remediate battery health: a required dependency is missing.'
            State = [pscustomobject]@{ Kind = 'DependencyMissing'; Missing = $missing }
            Error = [pscustomobject][ordered]@{
                Type = 'MissingDependency'
                Message = "Missing dependencies: $($missing -join ', ')."
            }
        }
    }

    if ([string]::IsNullOrWhiteSpace($ReportDirectory) -or -not [System.IO.Path]::IsPathRooted($ReportDirectory)) {
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to remediate battery health: report directory must be rooted.'
            State = [pscustomobject]@{ Kind = 'SafetyRejected' }
            Error = [pscustomobject][ordered]@{
                Type = 'InvalidPath'
                Message = 'ReportDirectory must be a rooted path.'
            }
        }
    }
    if ([string]::IsNullOrWhiteSpace($ReportFile)) {
        $ReportFile = Join-Path $ReportDirectory ("battery-report_{0}.html" -f (Get-Date -Format 'yyyyMMdd'))
    }
    if (-not [System.IO.Path]::IsPathRooted($ReportFile)) {
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to remediate battery health: report file must be rooted.'
            State = [pscustomobject]@{ Kind = 'SafetyRejected' }
            Error = [pscustomobject][ordered]@{ Type = 'InvalidPath'; Message = 'ReportFile must be a rooted path.' }
        }
    }

    $changed = $false
    $operation = 'check battery health'
    try {
        $before = & $GetDetection
        if ($null -eq $before) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = 1
                Message = 'Failed to remediate battery health: detection returned no decision.'
                State = [pscustomobject]@{ Kind = 'DetectionFailure' }
                Error = [pscustomobject][ordered]@{
                    Type = 'DependencyFailure'
                    Message = 'GetDetection returned no decision.'
                }
            }
        }
        $errorProperty = $before.PSObject.Properties['Error']
        if ($null -ne $errorProperty -and $null -ne $errorProperty.Value) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = 1
                Message = "Failed to remediate battery health: $($errorProperty.Value.Message)"
                State = $before.State
                Error = $errorProperty.Value
            }
        }
        if ($before.Compliant) {
            return [pscustomobject][ordered]@{
                Succeeded = $true
                Changed = $false
                ExitCode = 0
                Message = 'Battery health is already compliant.'
                State = [pscustomobject]@{ Kind = 'AlreadyCompliant'; Before = $before.State }
                Error = $null
            }
        }

        if (-not (Test-Path -LiteralPath $ReportDirectory)) {
            New-Item -Path $ReportDirectory -ItemType Directory -Force | Out-Null
        }
        $operation = 'generate battery report'
        $null = & $GenerateReport $ReportFile
        $changed = $true
        if (-not (& $TestFile $ReportFile)) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = 1
                Message = 'Failed to remediate battery health: report postcondition failed.'
                State = [pscustomobject]@{ Kind = 'PostconditionFailed'; ReportPath = $ReportFile }
                Error = [pscustomobject][ordered]@{
                    Type = 'PostconditionFailure'
                    Message = "Battery report was not created at '$ReportFile'."
                }
            }
        }

        $settings = @(
            [pscustomobject]@{ Arguments = [string[]]@('/change', 'monitor-timeout-dc', '5') }
            [pscustomobject]@{ Arguments = [string[]]@('/change', 'standby-timeout-dc', '15') }
            [pscustomobject]@{
                Arguments = [string[]]@(
                    '/setdcvalueindex'
                    'SCHEME_CURRENT'
                    'SUB_ENERGYSAVER'
                    'ESBATTTHRESHOLD'
                    '20'
                )
            }
        )
        $operation = 'apply battery optimization settings'
        foreach ($setting in $settings) {
            $null = & $SetPowerSetting $setting.Arguments
        }
        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = "Battery report saved to: $ReportFile`n" +
            "Battery optimization settings applied`n" +
            'Battery health detection remains deferred/unchanged.'
            State = [pscustomobject]@{
                Kind = 'OptimizationApplied'
                Before = $before
                DetectionStatus = 'Deferred/Unchanged'
                ReportPath = $ReportFile
                ReportPostcondition = 'Passed'
                PowerSettingCalls = 3
            }
            Output = @(
                "Battery report saved to: $ReportFile"
                'Battery optimization settings applied'
                'Battery health detection remains deferred/unchanged.'
            )
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $changed
            ExitCode = 1
            Message = "Failed to $operation`: $($_.Exception.Message)"
            State = [pscustomobject]@{ Kind = 'Error'; ReportPath = $ReportFile }
            Error = [pscustomobject][ordered]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $reportDirectory = Join-Path $env:ProgramData 'BatteryHealth'
    $reportFile = Join-Path $reportDirectory ("battery-report_{0}.html" -f (Get-Date -Format 'yyyyMMdd'))
    $result = Invoke-GetBatteryHealthRemediation `
        -GetDetection { Get-GetBatteryHealthNativeDetection } `
        -GenerateReport { param($Path) Invoke-GetBatteryHealthNativeReport -ReportPath $Path } `
        -SetPowerSetting {
        param([string[]]$Arguments)
        Invoke-GetBatteryHealthNativePowerSetting -Arguments $Arguments
    } `
        -TestFile { param($Path) Test-Path -LiteralPath $Path } `
        -ReportDirectory $reportDirectory `
        -ReportFile $reportFile
    if ($result.Output) {
        $result.Output | Write-Output
    }
    if (-not $result.Succeeded) {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
