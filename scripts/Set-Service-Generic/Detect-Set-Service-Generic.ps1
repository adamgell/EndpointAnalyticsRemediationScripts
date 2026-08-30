<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
- Sascha Stumpler (sastu@master-client.com)
Script: detect-service.ps1
Description: Detects if service exists and is configured as expected
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

function Get-SetServiceGenericService {
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

function Get-SetServiceGenericDetectionDecision {
    [CmdletBinding()]
    param(
        [string]$ServiceName = 'ServiceName',
        [string]$ServiceOption = 'serviceOption',
        $ServiceOptionValue = 'serviceOptionValue',
        [scriptblock]$GetService
    )

    if ($null -eq $GetService) {
        $GetService = { param($Name) Get-SetServiceGenericService -Name $Name }
    }

    try {
        $service = & $GetService $ServiceName
        if ($null -eq $service) {
            return [pscustomobject][ordered]@{
                Compliant = $false
                ExitCode = 1
                Message = 'Service is not available or correctly configured'
                State = 'Missing'
                Error = $null
            }
        }

        $property = $service.PSObject.Properties[$ServiceOption]
        if (($null -ne $property) -and ($property.Value -eq $ServiceOptionValue)) {
            return [pscustomobject][ordered]@{
                Compliant = $true
                ExitCode = 0
                Message = 'Service is available and correctly configured'
                State = 'Configured'
                Error = $null
            }
        }

        $state = if ($null -eq $property) { 'MissingOption' } else { 'Misconfigured' }
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Service is not available or correctly configured'
            State = $state
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = "Failed to inspect service '$ServiceName': $($_.Exception.Message)"
            State = 'Error'
            Error = $_.Exception.Message
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Get-SetServiceGenericDetectionDecision
    Write-Host $decision.Message
    exit $decision.ExitCode
}
