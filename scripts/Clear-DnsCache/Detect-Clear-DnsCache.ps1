<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: Clear-DnsCache
Description:
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: Admin
Context: 64 Bit
#>

# Detection for this package is intentionally unconditional.  The function is
# import-safe so tests and callers can evaluate the decision without exiting.
function Get-ClearDnsCacheDetectionDecision {
    [CmdletBinding()]
    param()

    [pscustomobject][ordered]@{
        Compliant = $false
        ExitCode = 1
        Message = 'Script will always be triggered'
        State = 'AlwaysRemediate'
        Error = $null
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Get-ClearDnsCacheDetectionDecision
    Write-Host $decision.Message
    exit $decision.ExitCode
}
