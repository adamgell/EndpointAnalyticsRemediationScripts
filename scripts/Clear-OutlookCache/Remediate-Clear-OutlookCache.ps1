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

function Start-ClearOutlookCacheProcess {
    [CmdletBinding()]
    param(
        [string]$Path,
        [string[]]$Arguments
    )

    Start-Process -FilePath $Path -ArgumentList $Arguments -ErrorAction Stop
}

function Get-ClearOutlookCacheRemediationDetection {
    [CmdletBinding()]
    param(
        [scriptblock]$TestOutlookPath,
        [string]$OutlookPath
    )

    try {
        $exists = [bool](& $TestOutlookPath $OutlookPath)
        [pscustomobject][ordered]@{
            Compliant = $false
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

function Invoke-ClearOutlookCacheRemediation {
    [CmdletBinding()]
    param(
        [scriptblock]$TestOutlookPath,
        [scriptblock]$StartOutlook,
        [string]$OutlookPath = 'C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE'
    )

    $errorResult = {
        param(
            [string]$StateKind,
            [string]$Type,
            [string]$Message,
            [bool]$Changed,
            [object]$Before
        )
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $Changed
            ExitCode = 1
            Message = $Message
            State = [pscustomobject][ordered]@{
                Kind = $StateKind
                Before = $Before
                After = 'Unknown'
            }
            Error = [pscustomobject][ordered]@{
                Type = $Type
                Message = $Message
            }
        }
    }

    if ($null -eq $TestOutlookPath -or $null -eq $StartOutlook) {
        return & $errorResult `
            'DependencyMissing' `
            'MissingDependency' `
            'Outlook cache remediation dependencies are required.' `
            $false `
            $null
    }
    if ([string]::IsNullOrWhiteSpace($OutlookPath) -or
        -not [System.IO.Path]::IsPathRooted($OutlookPath)) {
        return & $errorResult `
            'SafetyRejected' `
            'InvalidPath' `
            'OutlookPath must be a rooted path.' `
            $false `
            $null
    }

    $changed = $false
    try {
        $before = Get-ClearOutlookCacheRemediationDetection `
            -TestOutlookPath $TestOutlookPath `
            -OutlookPath $OutlookPath
        if ($before.Error) {
            return & $errorResult `
                'Error' `
                $before.Error.Type `
                "Failed to clear Outlook cache: $($before.Error.Message)" `
                $false `
                $before.State
        }

        $legacyArguments = @(
            '/cleanautocompletecache'
            '/recycle'
        )
        $null = & $StartOutlook $OutlookPath $legacyArguments
        $changed = $true

        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = 'Outlook cache clear launched; cache convergence is deferred.'
            State = [pscustomobject][ordered]@{
                Kind = 'Deferred'
                Before = $before.State
                LaunchSucceeded = $true
                After = 'Unknown'
            }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $changed
            ExitCode = 1
            Message = "Failed to clear Outlook cache: $($_.Exception.Message)"
            State = [pscustomobject][ordered]@{
                Kind = 'Error'
                Before = if ($before) { $before.State } else { $null }
                After = 'Unknown'
            }
            Error = [pscustomobject][ordered]@{
                Type = 'DependencyFailure'
                Message = $_.Exception.Message
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $startOutlook = {
        param($Path, $Arguments)
        Start-ClearOutlookCacheProcess -Path $Path -Arguments $Arguments
    }
    $result = Invoke-ClearOutlookCacheRemediation `
        -TestOutlookPath { param($Path) Test-Path -LiteralPath $Path } `
        -StartOutlook $startOutlook
    if (-not $result.Succeeded) {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
