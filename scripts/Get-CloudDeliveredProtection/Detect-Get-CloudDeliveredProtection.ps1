<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: Get-CloudDeliveredProtection
Description:
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: Admin
Context: 32 & 64 Bit
#>

function Test-GetCloudDeliveredProtection {
    [CmdletBinding()]
    param(
        [scriptblock] $GetPreference = { Get-MpPreference -ErrorAction Stop }
    )

    if ($null -eq $GetPreference) {
        return [pscustomobject]@{
            Compliant = $false
            ExitCode = 1
            Message = 'C1 DETECTION FAILED'
            State = $null
            Error = [pscustomobject]@{
                Type = 'MissingDependency'
                Message = 'Defender preference provider is required.'
            }
            Evidence = $null
        }
    }

    try {
        $preference = & $GetPreference
        if ($null -eq $preference) {
            throw 'Defender preference provider returned no state.'
        }
        $compliant = ($preference.MAPSReporting -eq 2) -and ($preference.SubmitSamplesConsent -eq 3)
        return [pscustomobject]@{
            Compliant = $compliant
            ExitCode = if ($compliant) { 0 } else { 1 }
            Message = if ($compliant) { 'C1 COMPLIANT' } else { 'C1 NON-COMPLIANT' }
            State = [pscustomobject]@{
                MAPSReporting = $preference.MAPSReporting
                SubmitSamplesConsent = $preference.SubmitSamplesConsent
            }
            Error = $null
            Evidence = [pscustomobject]@{
                MAPSReporting = $preference.MAPSReporting
                SubmitSamplesConsent = $preference.SubmitSamplesConsent
            }
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
    $result = Test-GetCloudDeliveredProtection
    if ($null -ne $result.Error) {
        Write-Error $result.Error.Message
    }
    else {
        Write-Output $result.Message
    }
    exit $result.ExitCode
}
