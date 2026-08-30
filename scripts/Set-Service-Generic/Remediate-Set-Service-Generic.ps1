<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
- Sascha Stumpler (sastu@master-client.com)
Script: set-service.ps1
Description: Restarts any service
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

function Get-SetServiceGenericServiceForRemediation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    try {
        Get-Service -Name $Name -ErrorAction Stop | Select-Object -First 1
    }
    catch {
        $message = $_.Exception.Message
        $errorId = [string]$_.FullyQualifiedErrorId
        if (($errorId -like 'NoServiceFoundForGivenName*') -or
            ($message -match 'Cannot find any service with service name')) {
            return $null
        }
        throw
    }
}

function Set-SetServiceGenericProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Option,
        [Parameter(Mandatory)]
        $Value
    )

    $parameters = @{
        Name = $Name
        $Option = $Value
        ErrorAction = 'Stop'
    }
    Set-Service @parameters
}

function Invoke-SetServiceGenericRemediation {
    [CmdletBinding()]
    param(
        [string]$ServiceName = 'ServiceName',
        [string]$ServiceOption = 'serviceOption',
        $ServiceOptionValue = 'serviceOptionValue',
        [scriptblock]$GetService,
        [scriptblock]$SetService
    )

    if ($null -eq $GetService) {
        $GetService = { param($Name) Get-SetServiceGenericServiceForRemediation -Name $Name }
    }
    if ($null -eq $SetService) {
        $SetService = {
            param($Name, $Option, $Value)
            Set-SetServiceGenericProperty -Name $Name -Option $Option -Value $Value
        }
    }

    $changed = $false
    try {
        $before = & $GetService $ServiceName
        if ($null -eq $before) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = 1
                Message = "Cannot configure service '$ServiceName': service was not found."
                State = 'Missing'
                Error = "Service '$ServiceName' was not found."
            }
        }

        $beforeProperty = $before.PSObject.Properties[$ServiceOption]
        if (($null -ne $beforeProperty) -and
            ($beforeProperty.Value -eq $ServiceOptionValue)) {
            return [pscustomobject][ordered]@{
                Succeeded = $true
                Changed = $false
                ExitCode = 0
                Message = "Service '$ServiceName' is already correctly configured."
                State = 'Configured'
                Error = $null
            }
        }

        & $SetService $ServiceName $ServiceOption $ServiceOptionValue | Out-Null
        $changed = $true
        $after = & $GetService $ServiceName
        $afterProperty = if ($null -eq $after) {
            $null
        }
        else {
            $after.PSObject.Properties[$ServiceOption]
        }
        if (($null -eq $after) -or ($null -eq $afterProperty) -or
            ($afterProperty.Value -ne $ServiceOptionValue)) {
            $state = if ($null -eq $after) {
                'Missing'
            }
            elseif ($null -eq $afterProperty) {
                'MissingOption'
            }
            else {
                'Misconfigured'
            }
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $changed
                ExitCode = 1
                Message = "Service '$ServiceName' did not reach the required configuration."
                State = $state
                Error = "Expected '$ServiceOption' to equal '$ServiceOptionValue'."
            }
        }

        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $changed
            ExitCode = 0
            Message = "Service '$ServiceName' configured successfully."
            State = 'Configured'
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $changed
            ExitCode = 1
            Message = "Failed to configure service '$ServiceName': $($_.Exception.Message)"
            State = 'Error'
            Error = $_.Exception.Message
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Invoke-SetServiceGenericRemediation
    if (-not $result.Succeeded) {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
