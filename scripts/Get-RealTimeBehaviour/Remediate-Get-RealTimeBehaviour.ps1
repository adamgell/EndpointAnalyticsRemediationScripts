<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: Detect-RealTimeBehaviour
Description:
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: Admin
Context: 32 & 64 Bit
#>

function Test-GetRealTimeBehaviour {
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
        $value = $status.BehaviorMonitorEnabled
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
            State = [pscustomobject]@{ BehaviorMonitorEnabled = $enabled }
            Error = $null
            Evidence = [pscustomobject]@{ BehaviorMonitorEnabled = $enabled }
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

function Repair-GetRealTimeBehaviour {
    [CmdletBinding()]
    param(
        [scriptblock] $GetStatus = { Get-MpComputerStatus -ErrorAction Stop },
        [scriptblock] $SetPreference = {
            param([hashtable]$values)
            Set-MpPreference -DisableBehaviorMonitoring $false -ErrorAction Stop
        }
    )

    $before = Test-GetRealTimeBehaviour -GetStatus $GetStatus
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
                    BehaviorMonitorEnabled = $true
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
                    BehaviorMonitorEnabled = $true
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
                    BehaviorMonitorEnabled = $true
                }
            }
            Error = [pscustomobject]@{ Type = 'MissingDependency'; Message = 'Defender preference setter is required.' }
            Evidence = $null
        }
    }

    try {
        $null = & $SetPreference ([ordered]@{ DisableBehaviorMonitoring = $false })
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
                    BehaviorMonitorEnabled = $true
                }
            }
            Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
            Evidence = $null
        }
    }

    $after = Test-GetRealTimeBehaviour -GetStatus $GetStatus
    if ($null -ne $after.Error -or -not $after.Compliant) {
        $error = if ($null -ne $after.Error) {
            $after.Error
        }
        else {
            [pscustomobject]@{
                Type = 'PostconditionFailure'
                Message = 'Behavior monitoring remained disabled after remediation.'
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
                    BehaviorMonitorEnabled = $true
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
                BehaviorMonitorEnabled = $true
            }
        }
        Error = $null
        Evidence = $after.State
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-GetRealTimeBehaviour
    Write-Output $result.Message
    exit $result.ExitCode
}
