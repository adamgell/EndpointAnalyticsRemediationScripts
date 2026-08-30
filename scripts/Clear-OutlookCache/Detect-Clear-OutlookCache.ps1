<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: Clear-OutlookCache
Description:
Hint: This is a community script. There is no guarantee for this.
Please check thoroughly before running.
Version 1.0: Init
Run as: Admin
Context: 64 Bit
#>

function Test-ClearOutlookCache {
    [CmdletBinding()]
    param(
        [scriptblock]$TestOutlookPath,
        [string]$OutlookPath = 'C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE'
    )

    if ($null -eq $TestOutlookPath) {
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Failed to check Outlook cache state.'
            State = [pscustomobject][ordered]@{
                Kind = 'DependencyMissing'
                OutlookExecutablePresent = $null
                CacheState = 'Unknown'
            }
            Error = [pscustomobject][ordered]@{
                Type = 'MissingDependency'
                Message = 'A TestOutlookPath scriptblock is required.'
            }
        }
    }

    try {
        $exists = [bool](& $TestOutlookPath $OutlookPath)
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Outlook cache state is unknown; remediation is required.'
            State = [pscustomobject][ordered]@{
                Kind = 'Unknown'
                OutlookExecutablePresent = $exists
                CacheState = 'Unknown'
            }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Failed to check Outlook cache state.'
            State = [pscustomobject][ordered]@{
                Kind = 'Error'
                OutlookExecutablePresent = $null
                CacheState = 'Unknown'
            }
            Error = [pscustomobject][ordered]@{
                Type = 'DependencyFailure'
                Message = $_.Exception.Message
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    # Keep the legacy adapter silent while preserving exit 0/1 behavior.
    $decision = Test-ClearOutlookCache `
        -TestOutlookPath { param($Path) Test-Path -LiteralPath $Path } `
        -OutlookPath 'C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE'
    exit $decision.ExitCode
}
