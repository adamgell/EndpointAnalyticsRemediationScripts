<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: restart-search-service.ps1
Description: Restarts Windows Search service
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>


function Get-RestartWindowsSearchServiceForRemediation {
    [CmdletBinding()]
    param()

    try {
        Get-Service -Name 'WSearch' -ErrorAction Stop | Select-Object -First 1
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

function Restart-RestartWindowsSearchService {
    [CmdletBinding()]
    param()

    Restart-Service -Name 'WSearch' -Force -ErrorAction Stop
}

function Invoke-RestartWindowsSearchServiceRemediation {
    [CmdletBinding()]
    param(
        [scriptblock]$GetService,
        [scriptblock]$RestartService
    )

    if ($null -eq $GetService) {
        $GetService = { Get-RestartWindowsSearchServiceForRemediation }
    }
    if ($null -eq $RestartService) {
        $RestartService = { Restart-RestartWindowsSearchService }
    }

    try {
        $before = & $GetService
        if ($null -eq $before) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = 1
                Message = "Cannot restart Windows Search service: service was not found."
                State = 'Missing'
                Error = "Service 'WSearch' was not found."
            }
        }

        @(& $RestartService) | Out-Null
        $after = & $GetService
        if (($null -eq $after) -or ([string]$after.Status -ne 'Running')) {
            $afterState = if ($null -eq $after) { 'Missing' } else { [string]$after.Status }
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $true
                ExitCode = 1
                Message = 'Windows Search service restart did not result in a running service.'
                State = $afterState
                Error = "Expected service 'WSearch' to be Running after restart."
            }
        }

        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = 'Windows Search service restarted successfully.'
            State = 'Running'
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = "Failed to restart Windows Search service: $($_.Exception.Message)"
            State = 'Error'
            Error = $_.Exception.Message
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Invoke-RestartWindowsSearchServiceRemediation
    if (-not $result.Succeeded) {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
