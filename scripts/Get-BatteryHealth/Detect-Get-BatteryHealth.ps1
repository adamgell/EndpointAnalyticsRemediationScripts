<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: detect-batteryhealth.ps1
Description: Detects battery health status on laptops
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

$MinHealthPercent = 40

function Invoke-GetBatteryHealthReport {
    [CmdletBinding()]
    param(
        [string]$ReportPath,
        [switch]$Xml
    )

    if ($Xml) {
        $null = & powercfg /batteryreport /xml /output $ReportPath 2>$null
    }
    else {
        $null = & powercfg /batteryreport /output $ReportPath 2>$null
    }
    if ($LASTEXITCODE -ne 0) {
        throw "powercfg battery report failed with exit code $LASTEXITCODE."
    }
}

function Test-GetBatteryHealth {
    [CmdletBinding()]
    param(
        [scriptblock]$GetBattery,
        [scriptblock]$GenerateReport,
        [scriptblock]$TestFile,
        [scriptblock]$ReadFile,
        [scriptblock]$RemoveFile,
        [string]$ReportPath,
        [int]$MinimumHealthPercent = 40
    )

    if ([string]::IsNullOrWhiteSpace($ReportPath)) {
        $tempRoot = [Environment]::GetEnvironmentVariable('TEMP')
        if ([string]::IsNullOrWhiteSpace($tempRoot)) {
            $tempRoot = [System.IO.Path]::GetTempPath()
        }
        $ReportPath = Join-Path $tempRoot 'battery-report.xml'
    }

    if ($null -eq $GetBattery) {
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Error checking battery health: battery query dependency is missing.'
            State = [pscustomobject]@{ Kind = 'DependencyMissing'; ReportPath = $ReportPath }
            Error = [pscustomobject][ordered]@{
                Type = 'MissingDependency'
                Message = 'A GetBattery scriptblock is required.'
            }
        }
    }

    try {
        $battery = & $GetBattery
        if (-not $battery) {
            return [pscustomobject][ordered]@{
                Compliant = $true
                ExitCode = 0
                Message = 'Compliant - No battery detected (desktop)'
                State = [pscustomobject]@{ Kind = 'NoBattery'; ReportPath = $ReportPath }
                Error = $null
            }
        }

        if ($null -eq $GenerateReport -or $null -eq $TestFile -or $null -eq $ReadFile -or $null -eq $RemoveFile) {
            return [pscustomobject][ordered]@{
                Compliant = $false
                ExitCode = 1
                Message = 'Error checking battery health: report dependency is missing.'
                State = [pscustomobject]@{ Kind = 'DependencyMissing'; ReportPath = $ReportPath }
                Error = [pscustomobject][ordered]@{
                    Type = 'MissingDependency'
                    Message = 'GenerateReport, TestFile, ReadFile, and RemoveFile scriptblocks are required ' +
                    'for battery health.'
                }
            }
        }

        $null = & $GenerateReport $ReportPath
        if (-not (& $TestFile $ReportPath)) {
            # Preserve the original adapter contract: an unavailable report
            # falls back to the generic compliant status.
            return [pscustomobject][ordered]@{
                Compliant = $true
                ExitCode = 0
                Message = 'Compliant - Battery status OK'
                State = [pscustomobject]@{ Kind = 'ReportUnavailable'; ReportPath = $ReportPath }
                Error = $null
            }
        }

        $rawReport = & $ReadFile $ReportPath
        [xml]$report = ($rawReport -join [Environment]::NewLine)
        $batteryReport = @($report.BatteryReport.Batteries.Battery)[0]
        $designCapacity = $batteryReport.DesignCapacity
        $fullChargeCapacity = $batteryReport.FullChargeCapacity

        if ($designCapacity -and $fullChargeCapacity -and [double]$designCapacity -gt 0) {
            $healthPercent = [math]::Round(([double]$fullChargeCapacity / [double]$designCapacity) * 100, 2)
            $null = & $RemoveFile $ReportPath

            $stateKind = if ($healthPercent -lt $MinimumHealthPercent) { 'LowHealth' } else { 'Healthy' }
            $messagePrefix = if ($healthPercent -lt $MinimumHealthPercent) { 'Not Compliant' } else { 'Compliant' }
            return [pscustomobject][ordered]@{
                Compliant = ($healthPercent -ge $MinimumHealthPercent)
                ExitCode = if ($healthPercent -lt $MinimumHealthPercent) { 1 } else { 0 }
                Message = "$messagePrefix - Battery health: $healthPercent%"
                State = [pscustomobject][ordered]@{
                    Kind = $stateKind
                    HealthPercent = $healthPercent
                    DesignCapacity = [double]$designCapacity
                    FullChargeCapacity = [double]$fullChargeCapacity
                    ReportPath = $ReportPath
                }
                Error = $null
            }
        }

        [pscustomobject][ordered]@{
            Compliant = $true
            ExitCode = 0
            Message = 'Compliant - Battery status OK'
            State = [pscustomobject]@{ Kind = 'ReportIncomplete'; ReportPath = $ReportPath }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = "Error checking battery health: $($_.Exception.Message)"
            State = [pscustomobject]@{ Kind = 'Error'; ReportPath = $ReportPath }
            Error = [pscustomobject][ordered]@{
                Type = 'DependencyFailure'
                Message = $_.Exception.Message
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Test-GetBatteryHealth `
        -GetBattery { Get-CimInstance -ClassName Win32_Battery -ErrorAction Stop } `
        -GenerateReport { param($Path) Invoke-GetBatteryHealthReport -ReportPath $Path -Xml } `
        -TestFile { param($Path) Test-Path -LiteralPath $Path } `
        -ReadFile { param($Path) Get-Content -LiteralPath $Path } `
        -RemoveFile { param($Path) Remove-Item -LiteralPath $Path -Force -ErrorAction Stop }
    if ($decision.Compliant) {
        Write-Output $decision.Message
    }
    else {
        Write-Warning $decision.Message
    }
    exit $decision.ExitCode
}
