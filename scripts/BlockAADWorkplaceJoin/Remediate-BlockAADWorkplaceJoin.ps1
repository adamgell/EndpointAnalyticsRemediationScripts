<#
Description: Applies the BlockAADWorkplaceJoin registry policy.
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

function Set-BlockAADWorkplaceJoinRegistryState {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Value)

    $path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin'
    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -Path $path -Force -ErrorAction Stop | Out-Null
    }
    New-ItemProperty `
        -Path $path `
        -Name 'BlockAADWorkplaceJoin' `
        -Value ([int]$Value) `
        -PropertyType DWord `
        -Force `
        -ErrorAction Stop | Out-Null
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

function Repair-BlockAADWorkplaceJoin {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [scriptblock]$GetState = { Get-BlockAADWorkplaceJoinRegistryState },
        [AllowNull()]
        [scriptblock]$SetState = { param($value) Set-BlockAADWorkplaceJoinRegistryState -Value $value }
    )

    $path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin'
    $name = 'BlockAADWorkplaceJoin'
    $desiredValue = 1
    $successMessage = 'BlockAADWorkplaceJoin policy applied.'
    $failurePrefix = 'Failed to apply BlockAADWorkplaceJoin policy: '

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
                New-BlockAADWorkplaceJoinError `
                    -Type 'MissingDependency' `
                    -Message 'Registry state and update providers are required.'
            )
        }
    }

    $before = $null
    try {
        $before = Resolve-BlockAADWorkplaceJoinValue -State (& $GetState)
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
        $after = Resolve-BlockAADWorkplaceJoinValue -State (& $GetState)
        if ($null -eq $after -or [int]$after -ne $desiredValue) {
            throw 'Registry state did not converge to BlockAADWorkplaceJoin=1.'
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
            Error = (New-BlockAADWorkplaceJoinError -Type 'DependencyFailure' -Message $_.Exception.Message)
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-BlockAADWorkplaceJoin
    if (-not $result.Succeeded) {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
