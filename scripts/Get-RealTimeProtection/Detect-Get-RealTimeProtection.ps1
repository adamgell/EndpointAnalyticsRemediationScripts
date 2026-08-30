<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: Get-RealTimeProtection
Description:
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: Admin
Context: 32 & 64 Bit
#>

function Test-GetRealTimeProtection {
    [CmdletBinding()]
    param(
        [scriptblock] $GetStatus = { Get-MpComputerStatus -ErrorAction Stop }
    )

    if ($null -eq $GetStatus) {
        return [pscustomobject]@{
            Compliant = $false
            ExitCode = 1
            Message = 'C1 DETECTION FAILED'
            State = $null
            Error = [pscustomobject]@{ Type = 'MissingDependency'; Message = 'Defender status provider is required.' }
            Evidence = $null
        }
    }

    try {
        $status = & $GetStatus
        if ($null -eq $status) { throw 'Defender status provider returned no state.' }
        $value = $status.RealTimeProtectionEnabled
        $enabled = ($value -eq $true) -or (
            [string]::Equals(
                [string]$value,
                'True',
                [System.StringComparison]::OrdinalIgnoreCase
            )
        )
        return [pscustomobject]@{
            Compliant = $enabled
            ExitCode = if ($enabled) { 0 } else { 1 }
            Message = if ($enabled) { 'C1 COMPLIANT' } else { 'C1 NON-COMPLIANT' }
            State = [pscustomobject]@{ RealTimeProtectionEnabled = $enabled }
            Error = $null
            Evidence = [pscustomobject]@{ RealTimeProtectionEnabled = $enabled }
        }
    }
    catch {
        return [pscustomobject]@{
            Compliant = $false
            ExitCode = 1
            Message = 'C1 DETECTION FAILED'
            State = $null
            Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
            Evidence = $null
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Test-GetRealTimeProtection
    if ($null -ne $result.Error) {
        Write-Error $result.Error.Message
    }
    else {
        Write-Output $result.Message
    }
    exit $result.ExitCode
}
