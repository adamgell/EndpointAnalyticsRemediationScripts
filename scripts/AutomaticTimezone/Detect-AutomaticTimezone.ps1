<#
Version: 1.0
Author:
- Adam Gell
Script: detect-automatictimezone.ps1
Description: Sets up Automatic Timezone and Time Sync
Release notes:
Version 1.0: Init
Run as: Admin
Context: 64 Bit
#>

function Get-AutomaticTimezoneRegistryState {
    [CmdletBinding()]
    param()

    $locationPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'
    $timeZonePath = 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate'
    $location = $null
    $timeZone = $null
    if (Test-Path -LiteralPath $locationPath) {
        $location = (Get-ItemProperty -Path $locationPath -Name 'Value' -ErrorAction SilentlyContinue).Value
    }
    if (Test-Path -LiteralPath $timeZonePath) {
        $timeZone = (Get-ItemProperty -Path $timeZonePath -Name 'start' -ErrorAction SilentlyContinue).start
    }
    [pscustomobject][ordered]@{
        Location = $location
        TimeZone = $timeZone
        LocationPath = $locationPath
        TimeZonePath = $timeZonePath
    }
}

function Resolve-AutomaticTimezoneState {
    param($State)

    if ($null -eq $State) {
        return [pscustomobject][ordered]@{ Location = $null; TimeZone = $null }
    }
    $location = $null
    $timeZone = $null
    if ($null -ne $State.PSObject.Properties['Location']) {
        $location = $State.Location
    }
    elseif ($null -ne $State.PSObject.Properties['Value']) {
        $location = $State.Value
    }
    if ($null -ne $State.PSObject.Properties['TimeZone']) {
        $timeZone = $State.TimeZone
    }
    elseif ($null -ne $State.PSObject.Properties['Value2']) {
        $timeZone = $State.Value2
    }
    elseif ($null -ne $State.PSObject.Properties['start']) {
        $timeZone = $State.start
    }
    [pscustomobject][ordered]@{ Location = $location; TimeZone = $timeZone }
}

function New-AutomaticTimezoneError {
    param(
        [string]$Type,
        [string]$Message
    )

    [pscustomobject][ordered]@{ Type = $Type; Message = $Message }
}

function Test-AutomaticTimezone {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [scriptblock]$GetState = { Get-AutomaticTimezoneRegistryState }
    )

    $locationPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'
    $timeZonePath = 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate'
    $desiredLocation = 'Allow'
    $desiredTimeZone = '3'

    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant'
            State = [pscustomobject][ordered]@{
                Status = 'MissingDependency'
                Location = $null
                TimeZone = $null
                DesiredLocation = $desiredLocation
                DesiredTimeZone = $desiredTimeZone
                LocationPath = $locationPath
                TimeZonePath = $timeZonePath
            }
            Error = (
                New-AutomaticTimezoneError `
                    -Type 'MissingDependency' `
                    -Message 'A registry state provider is required.'
            )
        }
    }

    try {
        $state = Resolve-AutomaticTimezoneState -State (& $GetState)
        $compliant = $null -ne $state.Location -and $null -ne $state.TimeZone -and
        ([string]$state.Location -eq $desiredLocation) -and ([string]$state.TimeZone -eq $desiredTimeZone)
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
                Location = $state.Location
                TimeZone = $state.TimeZone
                DesiredLocation = $desiredLocation
                DesiredTimeZone = $desiredTimeZone
                LocationPath = $locationPath
                TimeZonePath = $timeZonePath
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
                Location = $null
                TimeZone = $null
                DesiredLocation = $desiredLocation
                DesiredTimeZone = $desiredTimeZone
                LocationPath = $locationPath
                TimeZonePath = $timeZonePath
            }
            Error = (New-AutomaticTimezoneError -Type 'DependencyFailure' -Message $_.Exception.Message)
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Test-AutomaticTimezone
    if ($decision.Compliant) {
        Write-Output $decision.Message
    }
    else {
        Write-Warning $decision.Message
    }
    exit $decision.ExitCode
}
