<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: enforce-credentialguard.ps1
Description: Enables Credential Guard via registry
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

$EnforceCredentialGuardDeviceGuardPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
$EnforceCredentialGuardLsaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$EnforceCredentialGuardValue = 1
$EnforceCredentialGuardType = "DWord"

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

function Set-EnforceCredentialGuardRegistryState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]$DesiredState
    )

    if (-not (Test-Path -LiteralPath $EnforceCredentialGuardDeviceGuardPath)) {
        New-Item -Path $EnforceCredentialGuardDeviceGuardPath -Force -ErrorAction Stop | Out-Null
    }
    if (-not (Test-Path -LiteralPath $EnforceCredentialGuardLsaPath)) {
        New-Item -Path $EnforceCredentialGuardLsaPath -Force -ErrorAction Stop | Out-Null
    }
    New-ItemProperty -Path $EnforceCredentialGuardDeviceGuardPath -Name 'EnableVirtualizationBasedSecurity' `
        -Value $DesiredState.EnableVirtualizationBasedSecurity -PropertyType $EnforceCredentialGuardType `
        -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -Path $EnforceCredentialGuardDeviceGuardPath -Name 'RequirePlatformSecurityFeatures' `
        -Value $DesiredState.RequirePlatformSecurityFeatures -PropertyType $EnforceCredentialGuardType `
        -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -Path $EnforceCredentialGuardLsaPath -Name 'LsaCfgFlags' `
        -Value $DesiredState.LsaCfgFlags -PropertyType $EnforceCredentialGuardType `
        -Force -ErrorAction Stop | Out-Null
}

function Repair-EnforceCredentialGuard {
    [CmdletBinding()]
    param(
        [Alias('GetDeviceGuard', 'GetRegistry')]
        [scriptblock]$GetState = { Get-EnforceCredentialGuardState },
        [Alias('SetDeviceGuard', 'SetRegistry')]
        [scriptblock]$SetState = { param($desired) Set-EnforceCredentialGuardRegistryState -DesiredState $desired }
    )

    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to enable Credential Guard: a Device Guard state reader is required.'
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'MissingDependency'
                Message = 'A Device Guard state reader is required.'
            }
        }
    }

    $before = $null
    try {
        $before = & $GetState
        $hasDesiredConfig = $null -ne $before -and
        ($before.PSObject.Properties.Name -contains 'EnableVirtualizationBasedSecurity') -and
        ($before.PSObject.Properties.Name -contains 'RequirePlatformSecurityFeatures') -and
        ($before.PSObject.Properties.Name -contains 'LsaCfgFlags') -and
        ([int]$before.EnableVirtualizationBasedSecurity -eq $EnforceCredentialGuardValue) -and
        ([int]$before.RequirePlatformSecurityFeatures -eq $EnforceCredentialGuardValue) -and
        ([int]$before.LsaCfgFlags -eq $EnforceCredentialGuardValue)
        $serviceRunning = $null -ne $before -and
        ($before.PSObject.Properties.Name -contains 'SecurityServicesRunning') -and
        ($before.SecurityServicesRunning -contains 1)
        $alreadyCompliant = $hasDesiredConfig -or $serviceRunning
        if ($alreadyCompliant) {
            $status = if ($serviceRunning) { 'Compliant' } else { 'PendingReboot' }
            $convergence = if ($serviceRunning) { 'Immediate' } else { 'DeferredUntilReboot' }
            return [pscustomobject][ordered]@{
                Succeeded = $true
                Changed = $false
                ExitCode = 0
                Message = 'Credential Guard has been enabled. A reboot is required.'
                State = [pscustomobject][ordered]@{
                    Status = $status
                    Kind = $status
                    Convergence = $convergence
                    Before = $before
                    After = $before
                }
                Error = $null
            }
        }

        if ($null -eq $SetState) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = 1
                Message = 'Failed to enable Credential Guard: a registry state writer is required.'
                State = [pscustomobject][ordered]@{ Before = $before; After = 'Unknown' }
                Error = [pscustomobject]@{
                    Type = 'MissingDependency'
                    Message = 'A registry state writer is required.'
                }
            }
        }

        $desired = [pscustomobject][ordered]@{
            EnableVirtualizationBasedSecurity = $EnforceCredentialGuardValue
            RequirePlatformSecurityFeatures = $EnforceCredentialGuardValue
            LsaCfgFlags = $EnforceCredentialGuardValue
        }
        & $SetState $desired | Out-Null
        $after = & $GetState
        $verified = $null -ne $after -and
        ($after.PSObject.Properties.Name -contains 'EnableVirtualizationBasedSecurity') -and
        ($after.PSObject.Properties.Name -contains 'RequirePlatformSecurityFeatures') -and
        ($after.PSObject.Properties.Name -contains 'LsaCfgFlags') -and
        ([int]$after.EnableVirtualizationBasedSecurity -eq $EnforceCredentialGuardValue) -and
        ([int]$after.RequirePlatformSecurityFeatures -eq $EnforceCredentialGuardValue) -and
        ([int]$after.LsaCfgFlags -eq $EnforceCredentialGuardValue)
        if (-not $verified) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $true
                ExitCode = 1
                Message = 'Failed to enable Credential Guard: registry values did not converge.'
                State = [pscustomobject][ordered]@{
                    Before = $before
                    After = if ($null -eq $after) { 'Unknown' } else { $after }
                }
                Error = [pscustomobject]@{
                    Type = 'VerificationFailure'
                    Message = 'Credential Guard registry values did not converge.'
                }
            }
        }

        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = 'Credential Guard has been enabled. A reboot is required.'
            State = [pscustomobject][ordered]@{
                Status = 'PendingReboot'
                Kind = 'PendingReboot'
                Convergence = 'DeferredUntilReboot'
                Before = $before
                After = $after
            }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = "Failed to enable Credential Guard: $($_.Exception.Message)"
            State = [pscustomobject][ordered]@{
                Before = if ($null -eq $before) { 'Unknown' } else { $before }
                After = 'Unknown'
            }
            Error = [pscustomobject]@{
                Type = 'DependencyFailure'
                Message = $_.Exception.Message
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-EnforceCredentialGuard
    if ($result.Succeeded) {
        Write-Output $result.Message
    }
    else {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
