<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: Invoke-DnsClearCache
Description:
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: Admin
Context: 64 Bit
#>

function Invoke-InvokeDnsClearCacheCommand {
    [CmdletBinding()]
    param()

    Clear-DnsClientCache -ErrorAction Stop
}

function Invoke-InvokeDnsClearCacheRemediation {
    [CmdletBinding()]
    param(
        [scriptblock]$ClearDns
    )

    if ($null -eq $ClearDns) {
        $ClearDns = { Invoke-InvokeDnsClearCacheCommand }
    }

    try {
        $output = @(& $ClearDns)
        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = 'DNS client cache clear completed.'
            State = 'Cleared'
            Output = $output
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = "Failed to clear DNS client cache: $($_.Exception.Message)"
            State = 'Unknown'
            Output = @()
            Error = $_.Exception.Message
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Invoke-InvokeDnsClearCacheRemediation
    if (@($result.Output).Count -gt 0) {
        $result.Output | Write-Output
    }
    if (-not $result.Succeeded) {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
