<#
Version: 1.0
Author:
- Adam Gell
Script: remediate-coinstaller.ps1
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

function Set-DisableCoinstallerRegistryState {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Value)

    $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer'
    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -Path $path -Force -ErrorAction Stop | Out-Null
    }
    New-ItemProperty `
        -LiteralPath $path `
        -Name 'DisableCoInstallers' `
        -Value ([int]$Value) `
        -PropertyType DWord `
        -Force `
        -ErrorAction Stop | Out-Null
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

function Repair-DisableCoinstaller {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [scriptblock]$GetState = { Get-DisableCoinstallerRegistryState },
        [AllowNull()]
        [scriptblock]$SetState = { param($value) Set-DisableCoinstallerRegistryState -Value $value }
    )

    $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer'
    $name = 'DisableCoInstallers'
    $desiredValue = 1
    $successMessage = 'Compliant'
    $failurePrefix = 'Failed to disable coinstallers: '

    if ($null -eq $GetState -or $null -eq $SetState) {
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = ($failurePrefix + 'registry state and update providers are required.')
            State = [pscustomobject][ordered]@{
                Status = 'MissingDependency'
                Before = $null
                After = $null
                DesiredValue = $desiredValue
                Path = $path
                Name = $name
            }
            Error = (
                New-DisableCoinstallerError `
                    -Type 'MissingDependency' `
                    -Message 'Registry state and update providers are required.'
            )
        }
    }

    $before = $null
    try {
        $before = Resolve-DisableCoinstallerValue -State (& $GetState)
        if ($null -ne $before -and [int]$before -eq $desiredValue) {
            return [pscustomobject][ordered]@{
                Succeeded = $true
                Changed = $false
                ExitCode = 0
                Message = $successMessage
                State = [pscustomobject][ordered]@{
                    Status = 'Compliant'
                    Before = [pscustomobject]@{ Value = $before }
                    After = [pscustomobject]@{ Value = $before }
                    DesiredValue = $desiredValue
                    Path = $path
                    Name = $name
                }
                Error = $null
            }
        }

        [void](& $SetState $desiredValue)
        $after = Resolve-DisableCoinstallerValue -State (& $GetState)
        if ($null -eq $after -or [int]$after -ne $desiredValue) {
            throw 'Registry state did not converge to DisableCoInstallers=1.'
        }

        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = $successMessage
            State = [pscustomobject][ordered]@{
                Status = 'Compliant'
                Before = [pscustomobject]@{ Value = $before }
                After = [pscustomobject]@{ Value = $after }
                DesiredValue = $desiredValue
                Path = $path
                Name = $name
            }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = ($failurePrefix + $_.Exception.Message)
            State = [pscustomobject][ordered]@{
                Status = 'DependencyFailure'
                Before = [pscustomobject]@{ Value = $before }
                After = $null
                DesiredValue = $desiredValue
                Path = $path
                Name = $name
            }
            Error = (New-DisableCoinstallerError -Type 'DependencyFailure' -Message $_.Exception.Message)
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-DisableCoinstaller
    if ($result.Succeeded) {
        Write-Output $result.Message
    }
    else {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
