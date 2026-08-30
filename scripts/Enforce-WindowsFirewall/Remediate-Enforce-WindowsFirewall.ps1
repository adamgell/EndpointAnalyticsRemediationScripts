<#
Version: 1.0
Author: Jannik Reinhard (jannik.reinhard.com)
Script: enforce-windowsfirewall.ps1
Description: Enables Windows Firewall on all profiles
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

function Test-EnforceWindowsFirewall {
    [CmdletBinding()]
    param(
        [scriptblock] $GetProfiles = { Get-NetFirewallProfile -ErrorAction Stop }
    )

    if ($null -eq $GetProfiles) {
        return [pscustomobject]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant - Error checking firewall'
            State = $null
            Error = [pscustomobject]@{ Type = 'MissingDependency'; Message = 'Firewall profile provider is required.' }
            Evidence = $null
        }
    }

    try {
        $profiles = @(& $GetProfiles)
        $disabled = @(
            $profiles |
                Where-Object { $_.Enabled -ne $true } |
                ForEach-Object { [string]$_.Name }
        )
        $compliant = ($disabled.Count -eq 0)
        $message = if ($compliant) {
            'Compliant - All firewall profiles are enabled'
        }
        else {
            'Not Compliant - ' + ($disabled -join ', ') + ' firewall profile(s) are disabled'
        }
        return [pscustomobject]@{
            Compliant = $compliant
            ExitCode = if ($compliant) { 0 } else { 1 }
            Message = $message
            State = [pscustomobject]@{
                Profiles = @($profiles | ForEach-Object {
                        [pscustomobject]@{ Name = [string]$_.Name; Enabled = [bool]$_.Enabled }
                    })
                DisabledProfiles = @($disabled)
            }
            Error = $null
            Evidence = [pscustomobject]@{ DisabledProfiles = @($disabled) }
        }
    }
    catch {
        return [pscustomobject]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant - Error checking firewall'
            State = $null
            Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
            Evidence = $null
        }
    }
}

function Repair-EnforceWindowsFirewall {
    [CmdletBinding()]
    param(
        [scriptblock] $GetProfiles = { Get-NetFirewallProfile -ErrorAction Stop },
        [scriptblock] $SetProfiles = {
            param($profiles)
            Set-NetFirewallProfile -Profile $profiles -Enabled $true -ErrorAction Stop
        }
    )

    $before = Test-EnforceWindowsFirewall -GetProfiles $GetProfiles
    if ($null -ne $before.Error) {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to enable Windows Firewall'
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
            Message = 'Windows Firewall enabled on all profiles successfully'
            State = [pscustomobject]@{ Before = $before.State; After = $before.State; Desired = $true }
            Error = $null
            Evidence = [pscustomobject]@{ AlreadyCompliant = $true }
        }
    }

    if ($null -eq $SetProfiles) {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to enable Windows Firewall'
            State = [pscustomobject]@{ Before = $before.State; After = $null; Desired = $true }
            Error = [pscustomobject]@{ Type = 'MissingDependency'; Message = 'Firewall profile setter is required.' }
            Evidence = $null
        }
    }

    try {
        $null = & $SetProfiles @('Domain', 'Public', 'Private')
    }
    catch {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to enable Windows Firewall'
            State = [pscustomobject]@{ Before = $before.State; After = $null; Desired = $true }
            Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
            Evidence = $null
        }
    }

    $after = Test-EnforceWindowsFirewall -GetProfiles $GetProfiles
    if ($null -ne $after.Error -or -not $after.Compliant) {
        $error = if ($null -ne $after.Error) {
            $after.Error
        }
        else {
            [pscustomobject]@{
                Type = 'PostconditionFailure'
                Message = 'One or more firewall profiles remained disabled after remediation.'
            }
        }
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $true
            ExitCode = 1
            Message = 'Failed to enable Windows Firewall'
            State = [pscustomobject]@{ Before = $before.State; After = $after.State; Desired = $true }
            Error = $error
            Evidence = $after.State
        }
    }

    return [pscustomobject]@{
        Succeeded = $true
        Changed = $true
        ExitCode = 0
        Message = 'Windows Firewall enabled on all profiles successfully'
        State = [pscustomobject]@{ Before = $before.State; After = $after.State; Desired = $true }
        Error = $null
        Evidence = $after.State
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-EnforceWindowsFirewall
    if ($null -ne $result.Error) {
        Write-Error ($result.Message + ': ' + $result.Error.Message)
    }
    else {
        Write-Output $result.Message
    }
    exit $result.ExitCode
}
