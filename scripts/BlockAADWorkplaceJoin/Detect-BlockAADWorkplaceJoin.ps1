<#
Description: Detects whether AAD workplace join is blocked through registry policy.
Run as: Admin
Context: 64 Bit
#>

function Get-BlockAADWorkplaceJoinRegistryState {
    [CmdletBinding()]
    param()

    $path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin'
    $name = 'BlockAADWorkplaceJoin'
    if (-not (Test-Path -LiteralPath $path)) {
        return [pscustomobject][ordered]@{ Value = $null; Path = $path; Name = $name }
    }
    $item = Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
    $value = $null
    if ($null -ne $item) {
        $value = $item.$name
    }
    [pscustomobject][ordered]@{ Value = $value; Path = $path; Name = $name }
}

function Resolve-BlockAADWorkplaceJoinValue {
    param($State)

    if ($null -eq $State) {
        return $null
    }
    if ($null -ne $State.PSObject.Properties['Value']) {
        return $State.Value
    }
    if ($null -ne $State.PSObject.Properties['BlockAADWorkplaceJoin']) {
        return $State.BlockAADWorkplaceJoin
    }
    return $State
}

function New-BlockAADWorkplaceJoinError {
    param(
        [string]$Type,
        [string]$Message
    )

    [pscustomobject][ordered]@{ Type = $Type; Message = $Message }
}

function Test-BlockAADWorkplaceJoin {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [scriptblock]$GetState = { Get-BlockAADWorkplaceJoinRegistryState }
    )

    $path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin'
    $name = 'BlockAADWorkplaceJoin'
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
                New-BlockAADWorkplaceJoinError `
                    -Type 'MissingDependency' `
                    -Message 'A registry state provider is required.'
            )
        }
    }

    try {
        $value = Resolve-BlockAADWorkplaceJoinValue -State (& $GetState)
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
            Error = (New-BlockAADWorkplaceJoinError -Type 'DependencyFailure' -Message $_.Exception.Message)
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    # The legacy script emitted no stdout; retain that channel while preserving its exit mapping.
    $decision = Test-BlockAADWorkplaceJoin
    exit $decision.ExitCode
}
