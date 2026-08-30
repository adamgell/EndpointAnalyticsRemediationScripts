<#
Version: 1.0
Author:
- Adam Gell
Script: detect-coinstaller.ps1
Description: Detects if coinstallers is disabled via registry key
Release notes:
Version 1.0: Init
Run as: Admin
Context: 64 Bit
#>

function Get-DisableCoinstallerRegistryState {
    [CmdletBinding()]
    param()

    $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer'
    $name = 'DisableCoInstallers'
    $item = Get-ItemProperty -Path $path -Name $name -ErrorAction Stop
    [pscustomobject][ordered]@{ Value = $item.$name; Path = $path; Name = $name }
}

function Resolve-DisableCoinstallerValue {
    param($State)

    if ($null -eq $State) {
        return $null
    }
    if ($null -ne $State.PSObject.Properties['Value']) {
        return $State.Value
    }
    if ($null -ne $State.PSObject.Properties['DisableCoInstallers']) {
        return $State.DisableCoInstallers
    }
    return $State
}

function New-DisableCoinstallerError {
    param(
        [string]$Type,
        [string]$Message
    )

    [pscustomobject][ordered]@{ Type = $Type; Message = $Message }
}

function Test-DisableCoinstaller {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [scriptblock]$GetState = { Get-DisableCoinstallerRegistryState }
    )

    $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer'
    $name = 'DisableCoInstallers'
    $desiredValue = 1
    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant'
            State = [pscustomobject][ordered]@{
                Status = 'MissingDependency'
                Value = $null
                DesiredValue = $desiredValue
                Path = $path
                Name = $name
            }
            Error = (
                New-DisableCoinstallerError `
                    -Type 'MissingDependency' `
                    -Message 'A registry state provider is required.'
            )
        }
    }

    try {
        $value = Resolve-DisableCoinstallerValue -State (& $GetState)
        $compliant = $null -ne $value -and [int]$value -eq $desiredValue
        $exitCode = 1
        $message = 'Not Compliant'
        $status = 'NonCompliant'
        if ($compliant) {
            $exitCode = 0
            $message = 'Compliant'
            $status = 'Compliant'
        }
        [pscustomobject][ordered]@{
            Compliant = $compliant
            ExitCode = $exitCode
            Message = $message
            State = [pscustomobject][ordered]@{
                Status = $status
                Value = $value
                DesiredValue = $desiredValue
                Path = $path
                Name = $name
            }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant'
            State = [pscustomobject][ordered]@{
                Status = 'DependencyFailure'
                Value = $null
                DesiredValue = $desiredValue
                Path = $path
                Name = $name
            }
            Error = (New-DisableCoinstallerError -Type 'DependencyFailure' -Message $_.Exception.Message)
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Test-DisableCoinstaller
    if ($decision.Compliant) {
        Write-Output $decision.Message
    }
    else {
        Write-Warning $decision.Message
    }
    exit $decision.ExitCode
}
