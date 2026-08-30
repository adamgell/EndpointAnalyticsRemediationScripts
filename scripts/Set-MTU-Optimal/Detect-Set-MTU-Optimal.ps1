<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: detect-mtu.ps1
Description: Detects if the MTU size is optimal
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

function Get-SetMtuOptimalActiveAdapters {
    [CmdletBinding()]
    param()

    Get-NetIPInterface -AddressFamily IPv4 -ConnectionState Connected -ErrorAction Stop |
        Where-Object { $_.InterfaceAlias -notlike 'Loopback*' }
}

function Get-SetMtuOptimalExpectedMtu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$InterfaceAlias
    )

    if ($InterfaceAlias -match 'VPN|Tunnel') {
        return 1400
    }
    1500
}

function Get-SetMtuOptimalDetectionDecision {
    [CmdletBinding()]
    param(
        [scriptblock]$GetInterfaces
    )

    if ($null -eq $GetInterfaces) {
        $GetInterfaces = { Get-SetMtuOptimalActiveAdapters }
    }

    try {
        $adapters = @(& $GetInterfaces | Where-Object {
                $_.InterfaceAlias -notlike 'Loopback*'
            })
        $states = @()
        $warnings = @()
        foreach ($adapter in $adapters) {
            $aliasProperty = $adapter.PSObject.Properties['InterfaceAlias']
            $mtuProperty = $adapter.PSObject.Properties['NlMtu']
            if (($null -eq $aliasProperty) -or ($null -eq $mtuProperty)) {
                throw 'Network-interface dependency returned an object without InterfaceAlias or NlMtu.'
            }

            $expected = Get-SetMtuOptimalExpectedMtu -InterfaceAlias ([string]$aliasProperty.Value)
            $isCompliant = $mtuProperty.Value -eq $expected
            $states += [pscustomobject][ordered]@{
                InterfaceAlias = [string]$aliasProperty.Value
                InterfaceIndex = $adapter.InterfaceIndex
                ActualMtu = $mtuProperty.Value
                ExpectedMtu = $expected
                Compliant = $isCompliant
            }
            if (-not $isCompliant) {
                $warnings += (
                    "Not Compliant - $($aliasProperty.Value): MTU is $($mtuProperty.Value) " +
                    "(expected: $expected)"
                )
            }
        }

        if ($warnings.Count -gt 0) {
            return [pscustomobject][ordered]@{
                Compliant = $false
                ExitCode = 1
                Message = 'Network adapters are not configured with optimal MTU.'
                State = 'NonCompliant'
                Error = $null
                Details = $states
                Warnings = $warnings
            }
        }

        [pscustomobject][ordered]@{
            Compliant = $true
            ExitCode = 0
            Message = 'Compliant - All adapters have optimal MTU'
            State = 'Compliant'
            Error = $null
            Details = $states
            Warnings = @()
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = "Error checking MTU: $($_.Exception.Message)"
            State = 'Error'
            Error = $_.Exception.Message
            Details = @()
            Warnings = @("Error checking MTU: $($_.Exception.Message)")
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Get-SetMtuOptimalDetectionDecision
    if (@($decision.Warnings).Count -gt 0) {
        $decision.Warnings | Write-Warning
    }
    else {
        Write-Output $decision.Message
    }
    exit $decision.ExitCode
}
