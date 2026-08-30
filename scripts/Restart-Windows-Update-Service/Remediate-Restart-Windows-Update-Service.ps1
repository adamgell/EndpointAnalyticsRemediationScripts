<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: restart-wu-service.ps1
Description: Restarts Windows Update service
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>


function Get-RestartWindowsUpdateServiceForRemediation {
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

function Restart-RestartWindowsUpdateService {
    [CmdletBinding()]
    param()

    Restart-Service -Name 'wuauserv' -Force -ErrorAction Stop
}

function Invoke-RestartWindowsUpdateServiceRemediation {
    [CmdletBinding()]
    param(
        [scriptblock]$GetService,
        [scriptblock]$RestartService
    )

    if ($null -eq $GetService) {
        $GetService = { Get-RestartWindowsUpdateServiceForRemediation }
    }
    if ($null -eq $RestartService) {
        $RestartService = { Restart-RestartWindowsUpdateService }
    }

    try {
        $before = & $GetService
        if ($null -eq $before) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = 1
                Message = 'Cannot restart Windows Update service: service was not found.'
                State = 'Missing'
                Error = "Service 'wuauserv' was not found."
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
                Message = 'Windows Update service restart did not result in a running service.'
                State = $afterState
                Error = "Expected service 'wuauserv' to be Running after restart."
            }
        }

        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = 'Windows Update service restarted successfully.'
            State = 'Running'
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = "Failed to restart Windows Update service: $($_.Exception.Message)"
            State = 'Error'
            Error = $_.Exception.Message
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Invoke-RestartWindowsUpdateServiceRemediation
    if (-not $result.Succeeded) {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
