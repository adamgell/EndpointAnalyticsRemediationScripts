<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: detect-legacytls.ps1
Description: Detects if legacy TLS 1.0 or TLS 1.1 protocols are enabled
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

function Get-DisableLegacyTLSRegistryState {
    [CmdletBinding()]
    param()

    $state = [ordered]@{}
    foreach ($protocol in @('TLS 1.0', 'TLS 1.1')) {
        foreach ($type in @('Server', 'Client')) {
            $path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\$type"
            $key = "$protocol/$type"
            $entry = [ordered]@{ Path = $path; Exists = $false; Enabled = $null; DisabledByDefault = $null }
            if (Test-Path -LiteralPath $path) {
                $entry.Exists = $true
                $item = Get-ItemProperty -Path $path -Name 'Enabled', 'DisabledByDefault' -ErrorAction SilentlyContinue
                if ($null -ne $item) {
                    $entry.Enabled = $item.Enabled
                    $entry.DisabledByDefault = $item.DisabledByDefault
                }
            }
            $state[$key] = [pscustomobject]$entry
        }
    }
    $state
}

function Get-DisableLegacyTLSEntry {
    param(
        $State,
        [string]$Key
    )

    if ($null -eq $State) {
        return $null
    }
    if ($State -is [System.Collections.IDictionary]) {
        return $State[$Key]
    }
    $property = $State.PSObject.Properties[$Key]
    if ($null -ne $property) {
        return $property.Value
    }
    if ($null -ne $State.PSObject.Properties['Entries']) {
        $entries = $State.Entries
        if ($entries -is [System.Collections.IDictionary]) {
            return $entries[$Key]
        }
        $property = $entries.PSObject.Properties[$Key]
        if ($null -ne $property) {
            return $property.Value
        }
    }
    return $null
}

function Get-DisableLegacyTLSProperty {
    param(
        $Entry,
        [string]$Name
    )

    if ($null -eq $Entry) {
        return $null
    }
    if ($Entry -is [System.Collections.IDictionary]) {
        return $Entry[$Name]
    }
    $property = $Entry.PSObject.Properties[$Name]
    if ($null -ne $property) {
        return $property.Value
    }
    return $null
}

function New-DisableLegacyTLSError {
    param(
        [string]$Type,
        [string]$Message
    )

    [pscustomobject][ordered]@{ Type = $Type; Message = $Message }
}

function Test-DisableLegacyTLS {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [scriptblock]$GetState = { Get-DisableLegacyTLSRegistryState }
    )

    $paths = [ordered]@{}
    foreach ($protocol in @('TLS 1.0', 'TLS 1.1')) {
        foreach ($type in @('Server', 'Client')) {
            $paths["$protocol/$type"] = (
                "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\$type"
            )
        }
    }
    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant - Legacy TLS protocols are enabled'
            State = [pscustomobject][ordered]@{ Status = 'MissingDependency'; Entries = $null; Paths = $paths }
            Error = (
                New-DisableLegacyTLSError `
                    -Type 'MissingDependency' `
                    -Message 'A registry state provider is required.'
            )
        }
    }

    try {
        $observed = & $GetState
        $compliant = $true
        $entries = [ordered]@{}
        foreach ($key in $paths.Keys) {
            $entry = Get-DisableLegacyTLSEntry -State $observed -Key $key
            $enabled = Get-DisableLegacyTLSProperty -Entry $entry -Name 'Enabled'
            $exists = Get-DisableLegacyTLSProperty -Entry $entry -Name 'Exists'
            if ($null -eq $exists) {
                $exists = $null -ne $entry
            }
            if (-not $exists -or $null -eq $enabled -or [int]$enabled -ne 0) {
                $compliant = $false
            }
            $entries[$key] = $entry
        }
        $exitCode = 1
        $message = 'Not Compliant - Legacy TLS protocols are enabled'
        $status = 'NonCompliant'
        if ($compliant) {
            $exitCode = 0
            $message = 'Compliant - Legacy TLS protocols are disabled'
            $status = 'Compliant'
        }
        [pscustomobject][ordered]@{
            Compliant = $compliant
            ExitCode = $exitCode
            Message = $message
            State = [pscustomobject][ordered]@{ Status = $status; Entries = $entries; Paths = $paths }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant - Legacy TLS protocols are enabled'
            State = [pscustomobject][ordered]@{ Status = 'DependencyFailure'; Entries = $null; Paths = $paths }
            Error = (New-DisableLegacyTLSError -Type 'DependencyFailure' -Message $_.Exception.Message)
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Test-DisableLegacyTLS
    if ($decision.Compliant) {
        Write-Output $decision.Message
    }
    else {
        Write-Warning $decision.Message
    }
    exit $decision.ExitCode
}
