<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: detect-windowsfirewall.ps1
Description: Detects if Windows Firewall is enabled on all profiles
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

if ($MyInvocation.InvocationName -ne '.') {
    $result = Test-EnforceWindowsFirewall
    if ($null -ne $result.Error) {
        Write-Warning ($result.Message + ': ' + $result.Error.Message)
    }
    elseif ($result.Compliant) {
        Write-Output $result.Message
    }
    else {
        foreach ($profile in $result.State.DisabledProfiles) {
            Write-Warning "Not Compliant - $profile firewall profile is disabled"
        }
    }
    exit $result.ExitCode
}
