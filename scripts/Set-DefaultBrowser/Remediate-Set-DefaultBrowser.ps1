<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: set-defaultbrowser.ps1
Description: Sets Microsoft Edge as the default browser via policy
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

function Get-SetDefaultBrowserAssociationXml {
    [CmdletBinding()]
    param()

    @'
<?xml version="1.0" encoding="UTF-8"?>
<DefaultAssociations>
  <Association Identifier=".htm" ProgId="MSEdgeHTM" ApplicationName="Microsoft Edge" />
  <Association Identifier=".html" ProgId="MSEdgeHTM" ApplicationName="Microsoft Edge" />
  <Association Identifier="http" ProgId="MSEdgeHTM" ApplicationName="Microsoft Edge" />
  <Association Identifier="https" ProgId="MSEdgeHTM" ApplicationName="Microsoft Edge" />
</DefaultAssociations>
'@
}

function Write-SetDefaultBrowserAssociations {
    [CmdletBinding()]
    param(
        [string]$Path,
        [string]$Content
    )

    $Content | Out-File -FilePath $Path -Encoding UTF8 -Force
}

function Set-SetDefaultBrowserNativePolicy {
    [CmdletBinding()]
    param(
        [string]$Path,
        [string]$AssociationPath
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    New-ItemProperty `
        -Path $Path `
        -Name 'DefaultAssociationsConfiguration' `
        -Value $AssociationPath `
        -PropertyType String `
        -Force | Out-Null
}

function Get-SetDefaultBrowserNativeValueForRemediation {
    [CmdletBinding()]
    param()

    $userPath = 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice'
    Get-ItemProperty -Path $userPath -Name 'ProgId' -ErrorAction SilentlyContinue
}

function Invoke-SetDefaultBrowserRemediation {
    [CmdletBinding()]
    param(
        [scriptblock]$GetDefaultBrowser,
        [scriptblock]$WriteAssociations,
        [scriptblock]$SetPolicy,
        [scriptblock]$TestFile,
        [string]$XmlPath,
        [string]$PolicyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System',
        [string]$ExpectedBrowser = 'MSEdgeHTM'
    )

    $missing = @(
        if ($null -eq $GetDefaultBrowser) { 'GetDefaultBrowser' }
        if ($null -eq $WriteAssociations) { 'WriteAssociations' }
        if ($null -eq $SetPolicy) { 'SetPolicy' }
        if ($null -eq $TestFile) { 'TestFile' }
    )
    if ($missing.Count -gt 0) {
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to set default browser: a required dependency is missing.'
            State = [pscustomobject]@{ Kind = 'DependencyMissing'; Missing = $missing }
            Error = [pscustomobject][ordered]@{
                Type = 'MissingDependency'
                Message = "Missing dependencies: $($missing -join ', ')."
            }
        }
    }
    if ([string]::IsNullOrWhiteSpace($XmlPath)) {
        $systemRoot = [Environment]::GetEnvironmentVariable('SystemRoot')
        if ([string]::IsNullOrWhiteSpace($systemRoot)) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = 1
                Message = 'Failed to set default browser: SystemRoot is unavailable.'
                State = [pscustomobject]@{ Kind = 'SafetyRejected' }
                Error = [pscustomobject][ordered]@{
                    Type = 'InvalidPath'
                    Message = 'XmlPath was not supplied and SystemRoot is unavailable.'
                }
            }
        }
        $XmlPath = Join-Path $systemRoot 'System32\DefaultAssociations.xml'
    }
    if (-not [System.IO.Path]::IsPathRooted($XmlPath)) {
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to set default browser: XmlPath must be rooted.'
            State = [pscustomobject]@{ Kind = 'SafetyRejected' }
            Error = [pscustomobject][ordered]@{ Type = 'InvalidPath'; Message = 'XmlPath must be a rooted path.' }
        }
    }

    $changed = $false
    try {
        $beforeValue = & $GetDefaultBrowser
        $beforeProgId = if ($null -eq $beforeValue) { $null } else { [string]$beforeValue.ProgId }
        if ($beforeProgId -eq $ExpectedBrowser) {
            return [pscustomobject][ordered]@{
                Succeeded = $true
                Changed = $false
                ExitCode = 0
                Message = 'Default browser has been set to Microsoft Edge'
                State = [pscustomobject]@{ Kind = 'AlreadyCompliant'; ProgId = $beforeProgId }
                Error = $null
            }
        }

        $xmlContent = Get-SetDefaultBrowserAssociationXml
        $null = & $WriteAssociations $XmlPath $xmlContent
        $changed = $true
        if (-not (& $TestFile $XmlPath)) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = 1
                Message = 'Failed to set default browser: associations file postcondition failed.'
                State = [pscustomobject]@{ Kind = 'PostconditionFailed'; XmlPath = $XmlPath }
                Error = [pscustomobject][ordered]@{
                    Type = 'PostconditionFailure'
                    Message = "Associations file was not created at '$XmlPath'."
                }
            }
        }

        $policyResult = & $SetPolicy $PolicyPath $XmlPath
        if (($policyResult -is [bool]) -and (-not $policyResult)) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $true
                ExitCode = 1
                Message = 'Failed to set default browser: policy setter reported failure.'
                State = [pscustomobject]@{
                    Kind = 'PostconditionFailed'
                    Before = [pscustomobject]@{ ProgId = $beforeProgId }
                    PolicyPath = $PolicyPath
                    XmlPath = $XmlPath
                }
                Error = [pscustomobject][ordered]@{
                    Type = 'PostconditionFailure'
                    Message = 'The default browser policy setter reported failure.'
                }
            }
        }

        $message = 'Default browser policy has been applied; ' +
        'Microsoft Edge will become the default browser after sign-in'
        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = $message
            State = [pscustomobject]@{
                Kind = 'PendingSignIn'
                Before = [pscustomobject]@{ ProgId = $beforeProgId }
                DeferredUntilSignIn = $true
                Convergence = 'DeferredUntilSignIn'
                PolicyApplied = $true
                XmlPath = $XmlPath
                PolicyPath = $PolicyPath
            }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $changed
            ExitCode = 1
            Message = "Failed to set default browser: $($_.Exception.Message)"
            State = [pscustomobject]@{ Kind = 'Error'; XmlPath = $XmlPath }
            Error = [pscustomobject][ordered]@{
                Type = 'DependencyFailure'
                Message = $_.Exception.Message
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Invoke-SetDefaultBrowserRemediation `
        -GetDefaultBrowser { Get-SetDefaultBrowserNativeValueForRemediation } `
        -WriteAssociations {
        param($Path, $Content)
        Write-SetDefaultBrowserAssociations -Path $Path -Content $Content
    } `
        -SetPolicy {
        param($Path, $AssociationPath)
        Set-SetDefaultBrowserNativePolicy -Path $Path -AssociationPath $AssociationPath
    } `
        -TestFile { param($Path) Test-Path -LiteralPath $Path }
    if (-not $result.Succeeded) {
        Write-Error $result.Message
    }
    else {
        Write-Output $result.Message
    }
    exit $result.ExitCode
}
