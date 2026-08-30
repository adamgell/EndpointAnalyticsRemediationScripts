<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: remediation_Activate-Numlock
Description:
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: User
Context: 64 Bit
#>

function Get-ActivateNumlockRegistryState {
    [CmdletBinding()]
    param()

    $path = 'Registry::HKU\.DEFAULT\Control Panel\Keyboard'
    $name = 'InitialKeyboardIndicators'
    $item = Get-ItemProperty -Path $path -Name $name -ErrorAction Stop
    [pscustomobject][ordered]@{
        Value = $item.$name
        Path = $path
        Name = $name
    }
}

function Set-ActivateNumlockRegistryState {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Value)

    Set-ItemProperty `
        -Path 'Registry::HKU\.DEFAULT\Control Panel\Keyboard' `
        -Name 'InitialKeyboardIndicators' `
        -Value ([string]$Value) `
        -ErrorAction Stop
}

function Resolve-ActivateNumlockValue {
    param($State)

    if ($null -eq $State) {
        return $null
    }
    if ($null -ne $State.PSObject.Properties['Value']) {
        return $State.Value
    }
    if ($null -ne $State.PSObject.Properties['InitialKeyboardIndicators']) {
        return $State.InitialKeyboardIndicators
    }
    return $State
}

function New-ActivateNumlockError {
    param(
        [string]$Type,
        [string]$Message
    )

    [pscustomobject][ordered]@{
        Type = $Type
        Message = $Message
    }
}

function Repair-ActivateNumlock {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [scriptblock]$GetState = { Get-ActivateNumlockRegistryState },
        [AllowNull()]
        [scriptblock]$SetState = { param($value) Set-ActivateNumlockRegistryState -Value $value }
    )

    $path = 'Registry::HKU\.DEFAULT\Control Panel\Keyboard'
    $name = 'InitialKeyboardIndicators'
    $desiredValue = '2'
    $successMessage = 'Numlock at Startup successfully removed'
    $failureMessage = 'Error removing Numlock at Startup'

    if ($null -eq $GetState -or $null -eq $SetState) {
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = $failureMessage
            State = [pscustomobject][ordered]@{
                Status = 'MissingDependency'
                Before = $null
                After = $null
                DesiredValue = $desiredValue
                Path = $path
                Name = $name
            }
            Error = (
                New-ActivateNumlockError `
                    -Type 'MissingDependency' `
                    -Message 'Registry state and update providers are required.'
            )
        }
    }

    $before = $null
    try {
        $before = Resolve-ActivateNumlockValue -State (& $GetState)
        if ($null -ne $before -and [string]$before -eq $desiredValue) {
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
        $after = Resolve-ActivateNumlockValue -State (& $GetState)
        if ($null -eq $after -or [string]$after -ne $desiredValue) {
            throw 'Registry state did not converge to the desired Numlock value.'
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
            Message = $failureMessage
            State = [pscustomobject][ordered]@{
                Status = 'DependencyFailure'
                Before = [pscustomobject]@{ Value = $before }
                After = $null
                DesiredValue = $desiredValue
                Path = $path
                Name = $name
            }
            Error = (New-ActivateNumlockError -Type 'DependencyFailure' -Message $_.Exception.Message)
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-ActivateNumlock
    if ($result.Succeeded) {
        Write-Host $result.Message
    }
    else {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
