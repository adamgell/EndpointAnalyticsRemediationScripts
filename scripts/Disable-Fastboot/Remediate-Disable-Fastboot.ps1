<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: remediate-fastboot.ps1
Description: Disables Fastboot via registry key
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

function Set-DisableFastbootRegistryState {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Value)

    $path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -Path $path -Force -ErrorAction Stop | Out-Null
    }
    New-ItemProperty `
        -LiteralPath $path `
        -Name 'HiberbootEnabled' `
        -Value ([int]$Value) `
        -PropertyType DWord `
        -Force `
        -ErrorAction Stop | Out-Null
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

function Repair-DisableFastboot {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [scriptblock]$GetState = { Get-DisableFastbootRegistryState },
        [AllowNull()]
        [scriptblock]$SetState = { param($value) Set-DisableFastbootRegistryState -Value $value }
    )

    $path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
    $name = 'HiberbootEnabled'
    $desiredValue = 0
    $successMessage = 'Compliant'
    $failurePrefix = 'Failed to disable Fastboot: '

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
                New-DisableFastbootError `
                    -Type 'MissingDependency' `
                    -Message 'Registry state and update providers are required.'
            )
        }
    }

    $before = $null
    try {
        $before = Resolve-DisableFastbootValue -State (& $GetState)
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
        $after = Resolve-DisableFastbootValue -State (& $GetState)
        if ($null -eq $after -or [int]$after -ne $desiredValue) {
            throw 'Registry state did not converge to HiberbootEnabled=0.'
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
            Error = (New-DisableFastbootError -Type 'DependencyFailure' -Message $_.Exception.Message)
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-DisableFastboot
    if ($result.Succeeded) {
        Write-Output $result.Message
    }
    else {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
