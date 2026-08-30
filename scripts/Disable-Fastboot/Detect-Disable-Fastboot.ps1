<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: detect-fastboot.ps1
Description: Detects if Fastboot is enabled
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

function Get-DisableFastbootRegistryState {
    [CmdletBinding()]
    param()

    $path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
    $name = 'HiberbootEnabled'
    $item = Get-ItemProperty -Path $path -Name $name -ErrorAction Stop
    [pscustomobject][ordered]@{ Value = $item.$name; Path = $path; Name = $name }
}

function Resolve-DisableFastbootValue {
    param($State)

    if ($null -eq $State) {
        return $null
    }
    if ($null -ne $State.PSObject.Properties['Value']) {
        return $State.Value
    }
    if ($null -ne $State.PSObject.Properties['HiberbootEnabled']) {
        return $State.HiberbootEnabled
    }
    return $State
}

function New-DisableFastbootError {
    param(
        [string]$Type,
        [string]$Message
    )

    [pscustomobject][ordered]@{ Type = $Type; Message = $Message }
}

function Test-DisableFastboot {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [scriptblock]$GetState = { Get-DisableFastbootRegistryState }
    )

    $path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
    $name = 'HiberbootEnabled'
    $desiredValue = 0
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
                New-DisableFastbootError `
                    -Type 'MissingDependency' `
                    -Message 'A registry state provider is required.'
            )
        }
    }

    try {
        $value = Resolve-DisableFastbootValue -State (& $GetState)
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
            Error = (New-DisableFastbootError -Type 'DependencyFailure' -Message $_.Exception.Message)
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Test-DisableFastboot
    if ($decision.Compliant) {
        Write-Output $decision.Message
    }
    else {
        Write-Warning $decision.Message
    }
    exit $decision.ExitCode
}
