<#
Version: 1.0
Author:
- Adam Gell
Script: remediate-automatictimezone.ps1
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

function Set-AutomaticTimezoneRegistryState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Location,
        [Parameter(Mandatory = $true)]$TimeZone
    )

    $locationPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'
    $timeZonePath = 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate'
    if (-not (Test-Path -LiteralPath $locationPath)) {
        New-Item -Path $locationPath -Force -ErrorAction Stop | Out-Null
    }
    if (-not (Test-Path -LiteralPath $timeZonePath)) {
        New-Item -Path $timeZonePath -Force -ErrorAction Stop | Out-Null
    }
    New-ItemProperty `
        -LiteralPath $locationPath `
        -Name 'Value' `
        -Value ([string]$Location) `
        -PropertyType String `
        -Force `
        -ErrorAction Stop | Out-Null
    New-ItemProperty `
        -LiteralPath $timeZonePath `
        -Name 'start' `
        -Value ([int]$TimeZone) `
        -PropertyType DWord `
        -Force `
        -ErrorAction Stop | Out-Null
}

function Resolve-AutomaticTimezoneState {
    param($State)

    if ($null -eq $State) {
        return [pscustomobject][ordered]@{ Location = $null; TimeZone = $null }
    }
    $location = $null
    if ($null -ne $State.PSObject.Properties['Location']) {
        $location = $State.Location
    }
    elseif ($null -ne $State.PSObject.Properties['Value']) {
        $location = $State.Value
    }
    $timeZone = $null
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

function Repair-AutomaticTimezone {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [scriptblock]$GetState = { Get-AutomaticTimezoneRegistryState },
        [AllowNull()]
        [scriptblock]$SetState = {
            param($location, $timeZone)
            Set-AutomaticTimezoneRegistryState `
                -Location $location `
                -TimeZone $timeZone
        }
    )

    $locationPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'
    $timeZonePath = 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate'
    $desiredLocation = 'Allow'
    $desiredTimeZone = '3'
    $successMessage = 'Automatic timezone and time sync settings updated.'
    $failurePrefix = 'Failed to configure automatic timezone and time sync: '

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
                DesiredLocation = $desiredLocation
                DesiredTimeZone = $desiredTimeZone
                LocationPath = $locationPath
                TimeZonePath = $timeZonePath
            }
            Error = (
                New-AutomaticTimezoneError `
                    -Type 'MissingDependency' `
                    -Message 'Registry state and update providers are required.'
            )
        }
    }

    $before = $null
    try {
        $before = Resolve-AutomaticTimezoneState -State (& $GetState)
        $beforeCompliant = $null -ne $before.Location -and $null -ne $before.TimeZone -and
        ([string]$before.Location -eq $desiredLocation) -and ([string]$before.TimeZone -eq $desiredTimeZone)
        if ($beforeCompliant) {
            return [pscustomobject][ordered]@{
                Succeeded = $true
                Changed = $false
                ExitCode = 0
                Message = $successMessage
                State = [pscustomobject][ordered]@{
                    Status = 'Compliant'
                    Before = $before
                    After = $before
                    DesiredLocation = $desiredLocation
                    DesiredTimeZone = $desiredTimeZone
                    LocationPath = $locationPath
                    TimeZonePath = $timeZonePath
                }
                Error = $null
            }
        }

        [void](& $SetState $desiredLocation ([int]$desiredTimeZone))
        $after = Resolve-AutomaticTimezoneState -State (& $GetState)
        $afterCompliant = $null -ne $after.Location -and $null -ne $after.TimeZone -and
        ([string]$after.Location -eq $desiredLocation) -and ([string]$after.TimeZone -eq $desiredTimeZone)
        if (-not $afterCompliant) {
            throw 'Registry state did not converge to the desired automatic timezone values.'
        }

        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = $successMessage
            State = [pscustomobject][ordered]@{
                Status = 'Compliant'
                Before = $before
                After = $after
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
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = ($failurePrefix + $_.Exception.Message)
            State = [pscustomobject][ordered]@{
                Status = 'DependencyFailure'
                Before = $before
                After = $null
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
    $result = Repair-AutomaticTimezone
    if (-not $result.Succeeded) {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
