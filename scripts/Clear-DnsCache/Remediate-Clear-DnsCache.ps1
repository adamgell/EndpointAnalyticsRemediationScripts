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

function Invoke-ClearDnsCacheNativeCommand {
    [CmdletBinding()]
    param()

    $nativeOutput = & ipconfig.exe /flushdns
    if ($LASTEXITCODE -ne 0) {
        throw "ipconfig.exe /flushdns failed with exit code $LASTEXITCODE."
    }

    return $nativeOutput
}

function Invoke-ClearDnsCacheRemediation {
    [CmdletBinding()]
    param(
        [scriptblock]$FlushDns
    )

    if ($null -eq $FlushDns) {
        $FlushDns = { Invoke-ClearDnsCacheNativeCommand }
    }

    try {
        $output = @(& $FlushDns)
        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = 'DNS cache flush completed.'
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
            Message = "Failed to clear DNS cache: $($_.Exception.Message)"
            State = 'Unknown'
            Output = @()
            Error = $_.Exception.Message
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Invoke-ClearDnsCacheRemediation
    if ($result.Output.Count -gt 0) {
        $result.Output | Write-Output
    }
    if (-not $result.Succeeded) {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
