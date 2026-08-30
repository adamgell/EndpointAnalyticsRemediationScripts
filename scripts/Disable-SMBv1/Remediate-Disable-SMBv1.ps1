<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: remediate-fastboot.ps1
Description: Disables SMBv1 via registry key
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

function Test-DisableSMBv1 {
    [CmdletBinding()]
    param(
        [scriptblock] $GetState = { Get-SmbServerConfiguration -ErrorAction Stop }
    )

    if ($null -eq $GetState) {
        return [pscustomobject]@{
            Compliant = $false
            ExitCode = 1
            Message = 'SMBv1 detection failed.'
            State = $null
            Error = [pscustomobject]@{ Type = 'MissingDependency'; Message = 'SMB state provider is required.' }
            Evidence = $null
        }
    }

    try {
        $configuration = & $GetState
        if ($null -eq $configuration -or $null -eq $configuration.PSObject.Properties['EnableSMB1Protocol']) {
            throw 'SMB state provider returned no EnableSMB1Protocol value.'
        }
        $enabled = [bool]$configuration.EnableSMB1Protocol
        return [pscustomobject]@{
            Compliant = (-not $enabled)
            ExitCode = if ($enabled) { 1 } else { 0 }
            Message = if ($enabled) { 'SMBv1 is enabled' } else { 'SMBv1 is disabled' }
            State = [pscustomobject]@{ EnableSMB1Protocol = $enabled }
            Error = $null
            Evidence = [pscustomobject]@{ EnableSMB1Protocol = $enabled }
        }
    }
    catch {
        return [pscustomobject]@{
            Compliant = $false
            ExitCode = 1
            Message = 'SMBv1 detection failed.'
            State = $null
            Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
            Evidence = $null
        }
    }
}

function Repair-DisableSMBv1 {
    [CmdletBinding()]
    param(
        [scriptblock] $GetState = { Get-SmbServerConfiguration -ErrorAction Stop },
        [scriptblock] $SetState = {
            param($enabled)
            Set-SmbServerConfiguration -EnableSMB1Protocol $enabled -ErrorAction Stop
        }
    )

    $before = Test-DisableSMBv1 -GetState $GetState
    if ($null -ne $before.Error) {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'R1 Failed'
            State = [pscustomobject]@{ Before = $before.State; After = $null; Desired = $false }
            Error = $before.Error
            Evidence = $before.Error
        }
    }

    if ($before.Compliant) {
        return [pscustomobject]@{
            Succeeded = $true
            Changed = $false
            ExitCode = 0
            Message = 'R1 Remediated'
            State = [pscustomobject]@{ Before = $before.State; After = $before.State; Desired = $false }
            Error = $null
            Evidence = [pscustomobject]@{ AlreadyCompliant = $true }
        }
    }

    if ($null -eq $SetState) {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'R1 Failed'
            State = [pscustomobject]@{ Before = $before.State; After = $null; Desired = $false }
            Error = [pscustomobject]@{ Type = 'MissingDependency'; Message = 'SMB state setter is required.' }
            Evidence = $null
        }
    }

    try {
        $null = & $SetState $false
    }
    catch {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'R1 Failed'
            State = [pscustomobject]@{ Before = $before.State; After = $null; Desired = $false }
            Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
            Evidence = $null
        }
    }

    $after = Test-DisableSMBv1 -GetState $GetState
    if ($null -ne $after.Error) {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $true
            ExitCode = 1
            Message = 'R1 Failed'
            State = [pscustomobject]@{ Before = $before.State; After = $after.State; Desired = $false }
            Error = $after.Error
            Evidence = $after.Error
        }
    }
    if (-not $after.Compliant) {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $true
            ExitCode = 1
            Message = 'R1 Failed'
            State = [pscustomobject]@{ Before = $before.State; After = $after.State; Desired = $false }
            Error = [pscustomobject]@{
                Type = 'PostconditionFailure'
                Message = 'SMBv1 remained enabled after remediation.'
            }
            Evidence = $after.State
        }
    }

    return [pscustomobject]@{
        Succeeded = $true
        Changed = $true
        ExitCode = 0
        Message = 'R1 Remediated'
        State = [pscustomobject]@{ Before = $before.State; After = $after.State; Desired = $false }
        Error = $null
        Evidence = $after.State
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-DisableSMBv1
    if ($null -ne $result.Error) {
        Write-Error $result.Error.Message
    }
    exit $result.ExitCode
}
