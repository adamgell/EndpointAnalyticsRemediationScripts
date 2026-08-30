<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: detect-fastboot.ps1
Description: Detects if SMBv1 is enabled
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
        $detail = $_.Exception.Message
        return [pscustomobject]@{
            Compliant = $false
            ExitCode = 1
            Message = 'SMBv1 detection failed.'
            State = $null
            Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $detail }
            Evidence = $null
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Test-DisableSMBv1
    if ($null -ne $result.Error) {
        Write-Error $result.Error.Message
    }
    else {
        Write-Host $result.Message
    }
    exit $result.ExitCode
}
