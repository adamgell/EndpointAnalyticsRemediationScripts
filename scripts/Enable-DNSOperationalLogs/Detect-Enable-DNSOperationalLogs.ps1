<#
Version: 1.0
Author:
- Jannik Reinhard (jannikreinhard.com)
Script: Enable-DNSOperationalLogsDetection
Description: Detects if DNS Client Operational logs are enabled
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

function Test-EnableDNSOperationalLogs {
    [CmdletBinding()]
    param(
        [scriptblock] $GetLog = {
            Get-WinEvent -ListLog 'Microsoft-Windows-DNS-Client/Operational' -ErrorAction Stop
        }
    )

    if ($null -eq $GetLog) {
        return [pscustomobject]@{
            Compliant = $false
            ExitCode = 1
            Message = 'DNS Operational Log detection failed.'
            State = $null
            Error = [pscustomobject]@{ Type = 'MissingDependency'; Message = 'DNS event log provider is required.' }
            Evidence = $null
        }
    }

    try {
        $log = & $GetLog
        if ($null -eq $log -or $null -eq $log.PSObject.Properties['IsEnabled']) {
            throw 'DNS event log provider returned no IsEnabled value.'
        }

        $enabled = [bool]$log.IsEnabled
        return [pscustomobject]@{
            Compliant = $enabled
            ExitCode = if ($enabled) { 0 } else { 1 }
            Message = if ($enabled) { 'DNS Operational Log is enabled.' } else { 'DNS Operational Log is disabled.' }
            State = [pscustomobject]@{ IsEnabled = $enabled }
            Error = $null
            Evidence = [pscustomobject]@{ IsEnabled = $enabled }
        }
    }
    catch {
        return [pscustomobject]@{
            Compliant = $false
            ExitCode = 1
            Message = 'DNS Operational Log detection failed.'
            State = $null
            Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
            Evidence = $null
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Test-EnableDNSOperationalLogs
    if ($null -ne $result.Error) {
        Write-Error ('Failed to check DNS Operational Log status: ' + $result.Error.Message)
    }
    else {
        Write-Output $result.Message
    }
    exit $result.ExitCode
}
