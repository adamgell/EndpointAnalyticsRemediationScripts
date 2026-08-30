<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: detection_Activate-Numlock
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

function Test-ActivateNumlock {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [scriptblock]$GetState = { Get-ActivateNumlockRegistryState }
    )

    $path = 'Registry::HKU\.DEFAULT\Control Panel\Keyboard'
    $name = 'InitialKeyboardIndicators'
    $desiredValue = '2'
    $notFoundMessage = 'Numlock at Startup not found'
    $foundMessage = 'Numlock at Startup found'

    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = $notFoundMessage
            State = [pscustomobject][ordered]@{
                Status = 'MissingDependency'
                Value = $null
                DesiredValue = $desiredValue
                Path = $path
                Name = $name
            }
            Error = (
                New-ActivateNumlockError `
                    -Type 'MissingDependency' `
                    -Message 'A registry state provider is required.'
            )
        }
    }

    try {
        $observedState = & $GetState
        $value = Resolve-ActivateNumlockValue -State $observedState
        $compliant = $null -ne $value -and ([string]$value -eq $desiredValue)
        $exitCode = 1
        $message = $notFoundMessage
        $status = 'NonCompliant'
        if ($compliant) {
            $exitCode = 0
            $message = $foundMessage
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
            Message = $notFoundMessage
            State = [pscustomobject][ordered]@{
                Status = 'DependencyFailure'
                Value = $null
                DesiredValue = $desiredValue
                Path = $path
                Name = $name
            }
            Error = (New-ActivateNumlockError -Type 'DependencyFailure' -Message $_.Exception.Message)
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Test-ActivateNumlock
    Write-Host $decision.Message
    exit $decision.ExitCode
}
