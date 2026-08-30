<#
  .NOTES
  ===========================================================================
   Created on:   	27.06.2022
   Created by:   	Simon Skotheimsvik
   Filename:     	FortinetVPNProfile-Detect.ps1
   Instructions:      https://skotheimsvik.no/fortinet-vpn-profile-distribution-with-mdm
  ===========================================================================
  
  .DESCRIPTION
    This script will detect if VPN profile is present

#>

$FortinetVPNProfileName = "Simons VPN"
$FortinetVPNProfilePath = "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$FortinetVPNProfileName"

function Get-FortinetVPNProfileState {
    [CmdletBinding()]
    param()

    $exists = Test-Path -LiteralPath $FortinetVPNProfilePath
    $properties = if ($exists) {
        Get-ItemProperty -LiteralPath $FortinetVPNProfilePath -ErrorAction Stop
    }
    else {
        $null
    }
    [pscustomobject][ordered]@{
        Exists = [bool]$exists
        Description = if ($properties) { $properties.Description } else { $null }
        Server = if ($properties) { $properties.Server } else { $null }
        promptusername = if ($properties) { $properties.promptusername } else { $null }
        promptcertificate = if ($properties) { $properties.promptcertificate } else { $null }
        ServerCert = if ($properties) { $properties.ServerCert } else { $null }
    }
}
function Get-FortinetVPNProfilePresenceState {
    [CmdletBinding()]
    param()

    [pscustomobject][ordered]@{
        Exists = [bool](Test-Path -LiteralPath $FortinetVPNProfilePath)
    }
}


function Test-FortinetVPNProfile {
    [CmdletBinding()]
    param(
        [Alias('GetProfile', 'GetRegistry')]
        [scriptblock]$GetState = { Get-FortinetVPNProfilePresenceState }
    )

    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not existing'
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'MissingDependency'
                Message = 'A Fortinet VPN profile state reader is required.'
            }
        }
    }

    try {
        $state = & $GetState
        $exists = $null -ne $state -and
        ($state.PSObject.Properties.Name -contains 'Exists') -and
        [bool]$state.Exists
        [pscustomobject][ordered]@{
            Compliant = $exists
            ExitCode = if ($exists) { 0 } else { 1 }
            Message = if ($exists) { 'OK' } else { 'Not existing' }
            State = if ($null -eq $state) { 'Unknown' } else { $state }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = "Not existing: $($_.Exception.Message)"
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'DependencyFailure'
                Message = $_.Exception.Message
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Test-FortinetVPNProfile
    if ($decision.Compliant) {
        Write-Host $decision.Message
    }
    else {
        Write-Host $decision.Message
    }
    exit $decision.ExitCode
}
