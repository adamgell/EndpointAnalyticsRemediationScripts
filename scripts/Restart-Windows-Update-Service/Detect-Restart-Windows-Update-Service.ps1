<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: detect-wu-service.ps1
Description: Detects if Windows Update exists and is running
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>


function Get-RestartWindowsUpdateService {
    [CmdletBinding()]
    param()

    try {
        Get-Service -Name 'wuauserv' -ErrorAction Stop | Select-Object -First 1
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

function Get-RestartWindowsUpdateServiceDetectionDecision {
    [CmdletBinding()]
    param(
        [scriptblock]$GetService
    )

    if ($null -eq $GetService) {
        $GetService = { Get-RestartWindowsUpdateService }
    }

    try {
        $service = & $GetService
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
            Message = "Failed to inspect Windows Update service: $($_.Exception.Message)"
            State = 'Error'
            Error = $_.Exception.Message
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Get-RestartWindowsUpdateServiceDetectionDecision
    Write-Host $decision.Message
    exit $decision.ExitCode
}
