<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: restart-service.ps1
Description: Restarts any service
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>


function Restart-RestartServiceGenericService {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    Restart-Service -Name $Name -Force -ErrorAction Stop
}

function Invoke-RestartServiceGenericRemediation {
    [CmdletBinding()]
    param(
        [string]$ServiceName = 'ServiceName',
        [scriptblock]$GetService,
        [scriptblock]$RestartService
    )

    if ($null -eq $GetService) {
        $GetService = { param($Name) Get-RestartServiceGenericService -Name $Name }
    }
    if ($null -eq $RestartService) {
        $RestartService = { param($Name) Restart-RestartServiceGenericService -Name $Name }
    }

    try {
        $before = & $GetService $ServiceName
        if ($null -eq $before) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = 1
                Message = "Cannot restart service '$ServiceName': service was not found."
                State = 'Missing'
                Error = "Service '$ServiceName' was not found."
            }
        }

        @(& $RestartService $ServiceName) | Out-Null
        $after = & $GetService $ServiceName
        if (($null -eq $after) -or ([string]$after.Status -ne 'Running')) {
            $afterState = if ($null -eq $after) { 'Missing' } else { [string]$after.Status }
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $true
                ExitCode = 1
                Message = "Service '$ServiceName' restart did not result in a running service."
                State = $afterState
                Error = "Expected service '$ServiceName' to be Running after restart."
            }
        }

        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = "Service '$ServiceName' restarted successfully."
            State = 'Running'
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = "Failed to restart service '$ServiceName': $($_.Exception.Message)"
            State = 'Error'
            Error = $_.Exception.Message
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Invoke-RestartServiceGenericRemediation
    if (-not $result.Succeeded) {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
