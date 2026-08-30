<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: Remediate_NetworkProtection
Description:
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: Admin
Context: 32 & 64 Bit
#>

function Test-GetNetworkProtection {
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
        $compliant = ($preference.EnableNetworkProtection -eq 1)
        return [pscustomobject]@{
            Compliant = $compliant
            ExitCode = if ($compliant) { 0 } else { 1 }
            Message = if ($compliant) { 'C1 COMPLIANT' } else { 'C1 NON-COMPLIANT' }
            State = [pscustomobject]@{ EnableNetworkProtection = $preference.EnableNetworkProtection }
            Error = $null
            Evidence = [pscustomobject]@{ EnableNetworkProtection = $preference.EnableNetworkProtection }
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

function Repair-GetNetworkProtection {
    [CmdletBinding()]
    param(
        [scriptblock] $GetPreference = { Get-MpPreference -ErrorAction Stop },
        [scriptblock] $SetPreference = {
            param([hashtable]$values)
            Set-MpPreference -EnableNetworkProtection $values.EnableNetworkProtection -ErrorAction Stop
        }
    )

    $before = Test-GetNetworkProtection -GetPreference $GetPreference
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
                    EnableNetworkProtection = 1
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
                    EnableNetworkProtection = 1
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
                    EnableNetworkProtection = 1
                }
            }
            Error = [pscustomobject]@{ Type = 'MissingDependency'; Message = 'Defender preference setter is required.' }
            Evidence = $null
        }
    }

    try {
        $null = & $SetPreference ([ordered]@{ EnableNetworkProtection = 'Enabled' })
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
                    EnableNetworkProtection = 1
                }
            }
            Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
            Evidence = $null
        }
    }

    $after = Test-GetNetworkProtection -GetPreference $GetPreference
    if ($null -ne $after.Error -or -not $after.Compliant) {
        $error = if ($null -ne $after.Error) {
            $after.Error
        }
        else {
            [pscustomobject]@{
                Type = 'PostconditionFailure'
                Message = 'Network protection remained disabled after remediation.'
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
                    EnableNetworkProtection = 1
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
                EnableNetworkProtection = 1
            }
        }
        Error = $null
        Evidence = $after.State
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-GetNetworkProtection
    Write-Output $result.Message
    exit $result.ExitCode
}
