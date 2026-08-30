<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: Remediate-CloudDeliveredProtection
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
        if ($null -eq $preference) { throw 'Defender preference provider returned no state.' }
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

function Repair-GetCloudDeliveredProtection {
    [CmdletBinding()]
    param(
        [scriptblock] $GetPreference = { Get-MpPreference -ErrorAction Stop },
        [scriptblock] $SetPreference = {
            param([hashtable]$values)
            Set-MpPreference `
                -MAPSReporting $values.MAPSReporting `
                -SubmitSamplesConsent $values.SubmitSamplesConsent `
                -ErrorAction Stop
        }
    )

    $before = Test-GetCloudDeliveredProtection -GetPreference $GetPreference
    if ($null -ne $before.Error) {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'R1 Failed'
            State = [pscustomobject]@{
                Before = $before.State
                After = $null
                Desired = [pscustomobject]@{
                    MAPSReporting = 2
                    SubmitSamplesConsent = 3
                }
            }
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
            State = [pscustomobject]@{
                Before = $before.State
                After = $before.State
                Desired = [pscustomobject]@{
                    MAPSReporting = 2
                    SubmitSamplesConsent = 3
                }
            }
            Error = $null
            Evidence = [pscustomobject]@{ AlreadyCompliant = $true }
        }
    }

    if ($null -eq $SetPreference) {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'R1 Failed'
            State = [pscustomobject]@{
                Before = $before.State
                After = $null
                Desired = [pscustomobject]@{
                    MAPSReporting = 2
                    SubmitSamplesConsent = 3
                }
            }
            Error = [pscustomobject]@{ Type = 'MissingDependency'; Message = 'Defender preference setter is required.' }
            Evidence = $null
        }
    }

    try {
        $null = & $SetPreference ([ordered]@{ MAPSReporting = 'Advanced'; SubmitSamplesConsent = 'SendAllSamples' })
    }
    catch {
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'R1 Failed'
            State = [pscustomobject]@{
                Before = $before.State
                After = $null
                Desired = [pscustomobject]@{
                    MAPSReporting = 2
                    SubmitSamplesConsent = 3
                }
            }
            Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
            Evidence = $null
        }
    }

    $after = Test-GetCloudDeliveredProtection -GetPreference $GetPreference
    if ($null -ne $after.Error -or -not $after.Compliant) {
        $error = if ($null -ne $after.Error) {
            $after.Error
        }
        else {
            [pscustomobject]@{
                Type = 'PostconditionFailure'
                Message = 'Cloud-delivered protection remained noncompliant after remediation.'
            }
        }
        return [pscustomobject]@{
            Succeeded = $false
            Changed = $true
            ExitCode = 1
            Message = 'R1 Failed'
            State = [pscustomobject]@{
                Before = $before.State
                After = $after.State
                Desired = [pscustomobject]@{
                    MAPSReporting = 2
                    SubmitSamplesConsent = 3
                }
            }
            Error = $error
            Evidence = $after.State
        }
    }

    return [pscustomobject]@{
        Succeeded = $true
        Changed = $true
        ExitCode = 0
        Message = 'R1 Remediated'
        State = [pscustomobject]@{
            Before = $before.State
            After = $after.State
            Desired = [pscustomobject]@{
                MAPSReporting = 2
                SubmitSamplesConsent = 3
            }
        }
        Error = $null
        Evidence = $after.State
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-GetCloudDeliveredProtection
    Write-Output $result.Message
    exit $result.ExitCode
}
