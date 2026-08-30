<#
  .NOTES
  ===========================================================================
   Created on:   	27.06.2022
   Created by:   	Simon Skotheimsvik
   Filename:     	FortinetVPNProfile-Remediation.ps1
   Instructions:    https://skotheimsvik.no/fortinet-vpn-profile-distribution-with-mdm
  ===========================================================================
  
  .DESCRIPTION
    This script will create a VPN profile

#>

$FortinetVPNProfileName = "Simons VPN"
$FortinetVPNProfileServer = "vpn.skotheimsvik.no:443"
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

function Set-FortinetVPNProfileRegistryState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]$DesiredState
    )

    New-Item -Path $FortinetVPNProfilePath -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -LiteralPath $FortinetVPNProfilePath -Name 'Description' `
        -Value $DesiredState.Description -PropertyType String -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -LiteralPath $FortinetVPNProfilePath -Name 'Server' `
        -Value $DesiredState.Server -PropertyType String -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -LiteralPath $FortinetVPNProfilePath -Name 'promptusername' `
        -Value $DesiredState.promptusername -PropertyType DWord -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -LiteralPath $FortinetVPNProfilePath -Name 'promptcertificate' `
        -Value $DesiredState.promptcertificate -PropertyType DWord -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -LiteralPath $FortinetVPNProfilePath -Name 'ServerCert' `
        -Value $DesiredState.ServerCert -PropertyType String -Force -ErrorAction Stop | Out-Null
}

function Repair-FortinetVPNProfile {
    [CmdletBinding()]
    param(
        [Alias('GetProfile', 'GetRegistry')]
        [scriptblock]$GetState = { Get-FortinetVPNProfileState },
        [Alias('SetProfile', 'SetRegistry')]
        [scriptblock]$SetState = { param($desired) Set-FortinetVPNProfileRegistryState -DesiredState $desired }
    )

    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = -1
            Message = ''
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'MissingDependency'
                Message = 'A Fortinet VPN profile state reader is required.'
            }
        }
    }

    $before = $null
    try {
        $before = & $GetState
        $hasDesiredState = $null -ne $before -and
        ($before.PSObject.Properties.Name -contains 'Exists') -and
        [bool]$before.Exists -and
        ($before.PSObject.Properties.Name -contains 'Description') -and
        ($before.PSObject.Properties.Name -contains 'Server') -and
        ($before.PSObject.Properties.Name -contains 'promptusername') -and
        ($before.PSObject.Properties.Name -contains 'promptcertificate') -and
        ($before.PSObject.Properties.Name -contains 'ServerCert') -and
        ([string]$before.Description -eq $FortinetVPNProfileName) -and
        ([string]$before.Server -eq $FortinetVPNProfileServer) -and
        ([int]$before.promptusername -eq 1) -and
        ([int]$before.promptcertificate -eq 0) -and
        ([string]$before.ServerCert -eq '1')
        if ($hasDesiredState) {
            return [pscustomobject][ordered]@{
                Succeeded = $true
                Changed = $false
                ExitCode = 0
                Message = ''
                State = [pscustomobject][ordered]@{ Before = $before; After = $before }
                Error = $null
            }
        }

        if ($null -eq $SetState) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = -1
                Message = ''
                State = [pscustomobject][ordered]@{ Before = $before; After = 'Unknown' }
                Error = [pscustomobject]@{
                    Type = 'MissingDependency'
                    Message = 'A Fortinet VPN profile state writer is required.'
                }
            }
        }

        $desired = [pscustomobject][ordered]@{
            Exists = $true
            Description = $FortinetVPNProfileName
            Server = $FortinetVPNProfileServer
            promptusername = 1
            promptcertificate = 0
            ServerCert = '1'
        }
        & $SetState $desired | Out-Null
        $after = & $GetState
        $verified = $null -ne $after -and
        ($after.PSObject.Properties.Name -contains 'Exists') -and
        [bool]$after.Exists -and
        ($after.PSObject.Properties.Name -contains 'Description') -and
        ($after.PSObject.Properties.Name -contains 'Server') -and
        ($after.PSObject.Properties.Name -contains 'promptusername') -and
        ($after.PSObject.Properties.Name -contains 'promptcertificate') -and
        ($after.PSObject.Properties.Name -contains 'ServerCert') -and
        ([string]$after.Description -eq $FortinetVPNProfileName) -and
        ([string]$after.Server -eq $FortinetVPNProfileServer) -and
        ([int]$after.promptusername -eq 1) -and
        ([int]$after.promptcertificate -eq 0) -and
        ([string]$after.ServerCert -eq '1')
        if (-not $verified) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $true
                ExitCode = -1
                Message = ''
                State = [pscustomobject][ordered]@{
                    Before = $before
                    After = if ($null -eq $after) { 'Unknown' } else { $after }
                }
                Error = [pscustomobject]@{
                    Type = 'VerificationFailure'
                    Message = 'The Fortinet VPN profile did not converge to the required configuration.'
                }
            }
        }

        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = ''
            State = [pscustomobject][ordered]@{ Before = $before; After = $after }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = -1
            Message = ''
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
    $result = Repair-FortinetVPNProfile
    if (-not $result.Succeeded -and $result.Error) {
        Write-Error $result.Error.Message
    }
    elseif ($result.Message) {
        Write-Output $result.Message
    }
    exit $result.ExitCode
}
