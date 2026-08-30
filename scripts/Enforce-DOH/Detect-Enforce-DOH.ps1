<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: detect-doh.ps1
Description: Detects if DNS over HTTPS (DoH) is enabled
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

$EnforceDOHPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
$EnforceDOHName = "EnableAutoDoh"
$EnforceDOHValue = 2

function Get-EnforceDOHRegistryState {
    [CmdletBinding()]
    param()

    $property = Get-ItemProperty -Path $EnforceDOHPath -Name $EnforceDOHName -ErrorAction SilentlyContinue
    [pscustomobject][ordered]@{
        EnableAutoDoh = if ($property) { $property.EnableAutoDoh } else { $null }
    }
}

function Test-EnforceDOH {
    [CmdletBinding()]
    param(
        [Alias('GetRegistry', 'GetDnsState')]
        [scriptblock]$GetState = { Get-EnforceDOHRegistryState }
    )

    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant - DNS over HTTPS is not enabled'
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'MissingDependency'
                Message = 'A DNS registry state reader is required.'
            }
        }
    }

    try {
        $state = & $GetState
        $compliant = $null -ne $state -and
        ($state.PSObject.Properties.Name -contains $EnforceDOHName) -and
        $null -ne $state.EnableAutoDoh -and
        ([int]$state.EnableAutoDoh -eq $EnforceDOHValue)
        if ($compliant) {
            $message = 'Compliant - DNS over HTTPS is enabled'
        }
        else {
            $message = 'Not Compliant - DNS over HTTPS is not enabled'
        }
        [pscustomobject][ordered]@{
            Compliant = $compliant
            ExitCode = if ($compliant) { 0 } else { 1 }
            Message = $message
            State = if ($null -eq $state) { 'Unknown' } else { $state }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = "Not Compliant - Error checking DoH: $($_.Exception.Message)"
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'DependencyFailure'
                Message = $_.Exception.Message
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Test-EnforceDOH
    if ($decision.Compliant) {
        Write-Output $decision.Message
    }
    else {
        Write-Warning $decision.Message
    }
    exit $decision.ExitCode
}
