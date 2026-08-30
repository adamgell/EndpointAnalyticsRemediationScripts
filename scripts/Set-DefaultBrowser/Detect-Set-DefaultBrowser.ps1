<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: detect-defaultbrowser.ps1
Description: Detects if the default browser is set to the corporate standard (Edge)
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

$TargetBrowser = 'MSEdgeHTM'

function Get-SetDefaultBrowserNativeValue {
    [CmdletBinding()]
    param()

    $userPath = 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice'
    Get-ItemProperty -Path $userPath -Name 'ProgId' -ErrorAction SilentlyContinue
}

function Test-SetDefaultBrowser {
    [CmdletBinding()]
    param(
        [scriptblock]$GetDefaultBrowser,
        [string]$ExpectedBrowser = 'MSEdgeHTM'
    )

    if ($null -eq $GetDefaultBrowser) {
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Error checking default browser: registry query dependency is missing.'
            State = [pscustomobject]@{ Kind = 'DependencyMissing' }
            Error = [pscustomobject][ordered]@{
                Type = 'MissingDependency'
                Message = 'A GetDefaultBrowser scriptblock is required.'
            }
        }
    }

    try {
        $value = & $GetDefaultBrowser
        $progId = if ($null -eq $value) { $null } else { [string]$value.ProgId }
        if ($progId -eq $ExpectedBrowser) {
            return [pscustomobject][ordered]@{
                Compliant = $true
                ExitCode = 0
                Message = "Compliant - Default browser is set to $ExpectedBrowser"
                State = [pscustomobject]@{ Kind = 'Compliant'; ProgId = $progId }
                Error = $null
            }
        }

        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = "Not Compliant - Default browser is $progId (expected: $ExpectedBrowser)"
            State = [pscustomobject]@{
                Kind = if ([string]::IsNullOrEmpty($progId)) { 'Missing' } else { 'NonCompliant' }
                ProgId = $progId
            }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = "Error checking default browser: $($_.Exception.Message)"
            State = [pscustomobject]@{ Kind = 'Error' }
            Error = [pscustomobject][ordered]@{
                Type = 'DependencyFailure'
                Message = $_.Exception.Message
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Test-SetDefaultBrowser `
        -GetDefaultBrowser { Get-SetDefaultBrowserNativeValue }
    if ($decision.Compliant) {
        Write-Output $decision.Message
    }
    else {
        Write-Warning $decision.Message
    }
    exit $decision.ExitCode
}
