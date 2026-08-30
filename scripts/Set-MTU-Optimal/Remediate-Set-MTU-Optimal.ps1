<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: set-mtu.ps1
Description: Sets optimal MTU size on network adapters
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

function Get-SetMtuOptimalActiveAdaptersForRemediation {
    [CmdletBinding()]
    param()

    Get-NetIPInterface -AddressFamily IPv4 -ConnectionState Connected -ErrorAction Stop |
        Where-Object { $_.InterfaceAlias -notlike 'Loopback*' }
}

function Get-SetMtuOptimalRemediationTarget {
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

function Set-SetMtuOptimalInterface {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $InterfaceIndex,
        [Parameter(Mandatory)]
        [int]$TargetMtu
    )

    Set-NetIPInterface -InterfaceIndex $InterfaceIndex -NlMtuBytes $TargetMtu -ErrorAction Stop
}

function Invoke-SetMtuOptimalRemediation {
    [CmdletBinding()]
    param(
        [scriptblock]$GetInterfaces,
        [scriptblock]$SetInterface
    )

    if ($null -eq $GetInterfaces) {
        $GetInterfaces = { Get-SetMtuOptimalActiveAdaptersForRemediation }
    }
    if ($null -eq $SetInterface) {
        $SetInterface = {
            param($InterfaceIndex, $TargetMtu)
            Set-SetMtuOptimalInterface -InterfaceIndex $InterfaceIndex -TargetMtu $TargetMtu
        }
    }

    $changed = $false
    $output = @()
    try {
        $adapters = @(& $GetInterfaces | Where-Object {
                $_.InterfaceAlias -notlike 'Loopback*'
            })
        foreach ($adapter in $adapters) {
            $aliasProperty = $adapter.PSObject.Properties['InterfaceAlias']
            $mtuProperty = $adapter.PSObject.Properties['NlMtu']
            $indexProperty = $adapter.PSObject.Properties['InterfaceIndex']
            if (($null -eq $aliasProperty) -or ($null -eq $mtuProperty) -or
                ($null -eq $indexProperty)) {
                throw (
                    'Network-interface dependency returned an object without ' +
                    'InterfaceAlias, InterfaceIndex, or NlMtu.'
                )
            }

            $target = Get-SetMtuOptimalRemediationTarget -InterfaceAlias ([string]$aliasProperty.Value)
            if ($mtuProperty.Value -ne $target) {
                & $SetInterface $indexProperty.Value $target | Out-Null
                $changed = $true
                $output += "Set MTU to $target on $($aliasProperty.Value)"
            }
        }

        $postAdapters = @(& $GetInterfaces | Where-Object {
                $_.InterfaceAlias -notlike 'Loopback*'
            })
        $postStates = @()
        foreach ($adapter in $postAdapters) {
            $aliasProperty = $adapter.PSObject.Properties['InterfaceAlias']
            $mtuProperty = $adapter.PSObject.Properties['NlMtu']
            if (($null -eq $aliasProperty) -or ($null -eq $mtuProperty)) {
                throw (
                    'Network-interface dependency returned an object without ' +
                    'InterfaceAlias or NlMtu during postcondition verification.'
                )
            }
            $target = Get-SetMtuOptimalRemediationTarget -InterfaceAlias ([string]$aliasProperty.Value)
            $postStates += [pscustomobject][ordered]@{
                InterfaceAlias = [string]$aliasProperty.Value
                ActualMtu = $mtuProperty.Value
                ExpectedMtu = $target
                Compliant = $mtuProperty.Value -eq $target
            }
        }

        $failed = @($postStates | Where-Object { -not $_.Compliant })
        if ($failed.Count -gt 0) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $changed
                ExitCode = 1
                Message = 'MTU settings did not reach the required values.'
                State = 'NonCompliant'
                Error = 'One or more active adapters failed postcondition verification.'
                Output = $output
                Details = $postStates
            }
        }

        $message = 'MTU settings optimized successfully'
        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $changed
            ExitCode = 0
            Message = $message
            State = 'Compliant'
            Error = $null
            Output = $output
            Details = $postStates
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $changed
            ExitCode = 1
            Message = "Failed to set MTU: $($_.Exception.Message)"
            State = 'Error'
            Error = $_.Exception.Message
            Output = $output
            Details = @()
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Invoke-SetMtuOptimalRemediation
    if (@($result.Output).Count -gt 0) {
        $result.Output | Write-Output
    }
    if ($result.Succeeded) {
        Write-Output $result.Message
    }
    else {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
