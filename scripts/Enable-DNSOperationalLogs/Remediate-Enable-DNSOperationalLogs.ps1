<#
Version: 1.0
Author:
- Jannik Reinhard (jannikreinhard.com)
Script: Enable-DNSOperationalLogsRemediation
Description: Enables DNS Client Operational logs
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

function Repair-EnableDNSOperationalLogs {
    [CmdletBinding()]
    param(
        [scriptblock] $GetLog = {
            Get-WinEvent -ListLog 'Microsoft-Windows-DNS-Client/Operational' -ErrorAction Stop
        },
        [scriptblock] $SetLog = {
            param($name)
            $configuration = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $name
            $configuration.IsEnabled = $true
            $configuration.SaveChanges()
        }
    )

    $before = Test-EnableDNSOperationalLogs -GetLog $GetLog
    if ($null -ne $before.Error) {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to enable DNS Operational Log.'
            State = [pscustomobject]@{ Before = $before.State; After = $null; Desired = $true }
            Error = $before.Error
            Evidence = $before.Error
        }
    }

    if ($before.Compliant) {
        return [pscustomobject]@{
            Succeeded = $true
            Changed = $false
            ExitCode = 0
            Message = 'DNS Operational Log has been enabled.'
            State = [pscustomobject]@{ Before = $before.State; After = $before.State; Desired = $true }
            Error = $null
            Evidence = [pscustomobject]@{ AlreadyCompliant = $true }
        }
    }

    if ($null -eq $SetLog) {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to enable DNS Operational Log.'
            State = [pscustomobject]@{ Before = $before.State; After = $null; Desired = $true }
            Error = [pscustomobject]@{ Type = 'MissingDependency'; Message = 'DNS event log setter is required.' }
            Evidence = $null
        }
    }

    try {
        $null = & $SetLog 'Microsoft-Windows-DNS-Client/Operational'
    }
    catch {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to enable DNS Operational Log.'
            State = [pscustomobject]@{ Before = $before.State; After = $null; Desired = $true }
            Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
            Evidence = $null
        }
    }

    $after = Test-EnableDNSOperationalLogs -GetLog $GetLog
    if ($null -ne $after.Error -or -not $after.Compliant) {
        $error = if ($null -ne $after.Error) {
            $after.Error
        }
        else {
            [pscustomobject]@{
                Type = 'PostconditionFailure'
                Message = 'DNS Operational Log remained disabled after remediation.'
            }
        }
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $true
            ExitCode = 1
            Message = 'Failed to enable DNS Operational Log.'
            State = [pscustomobject]@{ Before = $before.State; After = $after.State; Desired = $true }
            Error = $error
            Evidence = $after.State
        }
    }

    return [pscustomobject]@{
        Succeeded = $true
        Changed = $true
        ExitCode = 0
        Message = 'DNS Operational Log has been enabled.'
        State = [pscustomobject]@{ Before = $before.State; After = $after.State; Desired = $true }
        Error = $null
        Evidence = $after.State
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-EnableDNSOperationalLogs
    if ($null -ne $result.Error) {
        Write-Error ('Failed to enable DNS Operational Log: ' + $result.Error.Message)
    }
    else {
        Write-Output $result.Message
    }
    exit $result.ExitCode
}
