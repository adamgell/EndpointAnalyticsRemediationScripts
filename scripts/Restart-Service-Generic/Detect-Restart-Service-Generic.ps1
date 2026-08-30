<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: detect-service.ps1
Description: Detects if service exists and is running
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>


function Get-RestartServiceGenericService {
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

function Get-RestartServiceGenericDetectionDecision {
    param(
        [string]$ServiceName = 'ServiceName',
        [scriptblock]$GetService
    )

    if ($null -eq $GetService) {
        $GetService = { param($Name) Get-RestartServiceGenericService -Name $Name }
    }

    try {
        $service = & $GetService $ServiceName
        if ($null -eq $service) {
            return [pscustomobject][ordered]@{
                Compliant = $false
                ExitCode = 1
                Message = 'Service is not there/running'
                State = 'Missing'
                Error = $null
            }
        }

        if ([string]$service.Status -eq 'Running') {
            return [pscustomobject][ordered]@{
                Compliant = $true
                ExitCode = 0
                Message = 'Service is available and running'
                State = 'Running'
                Error = $null
            }
        }

        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Service is not there/running'
            State = [string]$service.Status
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
    $decision = Get-RestartServiceGenericDetectionDecision
    Write-Host $decision.Message
    exit $decision.ExitCode
}
