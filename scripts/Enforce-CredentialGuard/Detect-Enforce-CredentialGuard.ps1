<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: detect-credentialguard.ps1
Description: Detects if Credential Guard is enabled
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

$EnforceCredentialGuardDeviceGuardPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
$EnforceCredentialGuardLsaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

function Get-EnforceCredentialGuardState {
    [CmdletBinding()]
    param()

    $deviceGuard = Get-CimInstance -ClassName Win32_DeviceGuard `
        -Namespace root\Microsoft\Windows\DeviceGuard -ErrorAction Stop
    $deviceGuardRegistry = Get-ItemProperty -Path $EnforceCredentialGuardDeviceGuardPath -ErrorAction SilentlyContinue
    $lsaRegistry = Get-ItemProperty -Path $EnforceCredentialGuardLsaPath -ErrorAction SilentlyContinue
    $enableVirtualizationBasedSecurity = $null
    $requirePlatformSecurityFeatures = $null
    if ($deviceGuardRegistry) {
        $enableVirtualizationBasedSecurity = $deviceGuardRegistry.EnableVirtualizationBasedSecurity
        $requirePlatformSecurityFeatures = $deviceGuardRegistry.RequirePlatformSecurityFeatures
    }
    [pscustomobject][ordered]@{
        SecurityServicesRunning = @($deviceGuard.SecurityServicesRunning)
        EnableVirtualizationBasedSecurity = $enableVirtualizationBasedSecurity
        RequirePlatformSecurityFeatures = $requirePlatformSecurityFeatures
        LsaCfgFlags = if ($lsaRegistry) { $lsaRegistry.LsaCfgFlags } else { $null }
    }
}
function Get-EnforceCredentialGuardDetectionState {
    [CmdletBinding()]
    param()

    $deviceGuard = Get-CimInstance -ClassName Win32_DeviceGuard `
        -Namespace root\Microsoft\Windows\DeviceGuard -ErrorAction Stop
    [pscustomobject][ordered]@{
        SecurityServicesRunning = @($deviceGuard.SecurityServicesRunning)
    }
}


function Test-EnforceCredentialGuard {
    [CmdletBinding()]
    param(
        [Alias('GetDeviceGuard', 'GetCimState')]
        [scriptblock]$GetState = { Get-EnforceCredentialGuardDetectionState }
    )

    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant - Unable to check Credential Guard'
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'MissingDependency'
                Message = 'A Device Guard state reader is required.'
            }
        }
    }

    try {
        $state = & $GetState
        $running = $null -ne $state -and
        ($state.PSObject.Properties.Name -contains 'SecurityServicesRunning') -and
        ($state.SecurityServicesRunning -contains 1)
        if ($running) {
            $message = 'Compliant - Credential Guard is running'
        }
        else {
            $message = 'Not Compliant - Credential Guard is not running'
        }
        [pscustomobject][ordered]@{
            Compliant = $running
            ExitCode = if ($running) { 0 } else { 1 }
            Message = $message
            State = if ($null -eq $state) { 'Unknown' } else { $state }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = "Not Compliant - Unable to check Credential Guard: $($_.Exception.Message)"
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'DependencyFailure'
                Message = $_.Exception.Message
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Test-EnforceCredentialGuard
    if ($decision.Compliant) {
        Write-Output $decision.Message
    }
    else {
        Write-Warning $decision.Message
    }
    exit $decision.ExitCode
}
