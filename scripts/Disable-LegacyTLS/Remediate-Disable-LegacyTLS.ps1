<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: disable-legacytls.ps1
Description: Disables TLS 1.0 and TLS 1.1 protocols
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

function Set-DisableLegacyTLSRegistryState {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Updates)

    foreach ($key in $Updates.Keys) {
        $parts = $key -split '/', 2
        $path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$($parts[0])\$($parts[1])"
        if (-not (Test-Path -LiteralPath $path)) {
            New-Item -Path $path -Force -ErrorAction Stop | Out-Null
        }
        New-ItemProperty -Path $path -Name 'Enabled' -Value 0 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        New-ItemProperty `
            -Path $path `
            -Name 'DisabledByDefault' `
            -Value 1 `
            -PropertyType DWord `
            -Force `
            -ErrorAction Stop | Out-Null
    }
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

function New-DisableLegacyTLSDesiredState {
    $updates = [ordered]@{}
    foreach ($protocol in @('TLS 1.0', 'TLS 1.1')) {
        foreach ($type in @('Server', 'Client')) {
            $updates["$protocol/$type"] = [pscustomobject][ordered]@{ Enabled = 0; DisabledByDefault = 1 }
        }
    }
    $updates
}

function New-DisableLegacyTLSError {
    param(
        [string]$Type,
        [string]$Message
    )

    [pscustomobject][ordered]@{ Type = $Type; Message = $Message }
}

function Test-DisableLegacyTLSStateCompliance {
    param($State)

    foreach ($key in @('TLS 1.0/Server', 'TLS 1.0/Client', 'TLS 1.1/Server', 'TLS 1.1/Client')) {
        $entry = Get-DisableLegacyTLSEntry -State $State -Key $key
        $enabled = Get-DisableLegacyTLSProperty -Entry $entry -Name 'Enabled'
        $exists = Get-DisableLegacyTLSProperty -Entry $entry -Name 'Exists'
        if ($null -eq $exists) {
            $exists = $null -ne $entry
        }
        if (-not $exists -or $null -eq $enabled -or [int]$enabled -ne 0) {
            return $false
        }
    }
    return $true
}

function Test-DisableLegacyTLSStateComplete {
    param($State)

    foreach ($key in @('TLS 1.0/Server', 'TLS 1.0/Client', 'TLS 1.1/Server', 'TLS 1.1/Client')) {
        $entry = Get-DisableLegacyTLSEntry -State $State -Key $key
        $enabled = Get-DisableLegacyTLSProperty -Entry $entry -Name 'Enabled'
        $disabledByDefault = Get-DisableLegacyTLSProperty -Entry $entry -Name 'DisabledByDefault'
        if (
            $null -eq $enabled -or
            [int]$enabled -ne 0 -or
            $null -eq $disabledByDefault -or
            [int]$disabledByDefault -ne 1
        ) {
            return $false
        }
    }
    return $true
}

function Repair-DisableLegacyTLS {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [scriptblock]$GetState = { Get-DisableLegacyTLSRegistryState },
        [AllowNull()]
        [scriptblock]$SetState = { param($updates) Set-DisableLegacyTLSRegistryState -Updates $updates }
    )

    $desired = New-DisableLegacyTLSDesiredState
    $successMessage = 'Legacy TLS protocols disabled successfully'
    $failurePrefix = 'Failed to disable legacy TLS: '
    if ($null -eq $GetState -or $null -eq $SetState) {
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = ($failurePrefix + 'registry state and update providers are required.')
            State = [pscustomobject][ordered]@{
                Status = 'MissingDependency'
                Before = $null
                After = $null
                Desired = $desired
            }
            Error = (
                New-DisableLegacyTLSError `
                    -Type 'MissingDependency' `
                    -Message 'Registry state and update providers are required.'
            )
        }
    }

    $before = $null
    try {
        $before = & $GetState
        if (Test-DisableLegacyTLSStateComplete -State $before) {
            return [pscustomobject][ordered]@{
                Succeeded = $true
                Changed = $false
                ExitCode = 0
                Message = $successMessage
                State = [pscustomobject][ordered]@{
                    Status = 'Compliant'
                    Before = $before
                    After = $before
                    Desired = $desired
                }
                Error = $null
            }
        }

        [void](& $SetState $desired)
        $after = & $GetState
        if (-not (Test-DisableLegacyTLSStateComplete -State $after)) {
            throw 'Registry state did not converge to the desired legacy TLS values.'
        }
        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = $successMessage
            State = [pscustomobject][ordered]@{
                Status = 'Compliant'
                Before = $before
                After = $after
                Desired = $desired
            }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = ($failurePrefix + $_.Exception.Message)
            State = [pscustomobject][ordered]@{
                Status = 'DependencyFailure'
                Before = $before
                After = $null
                Desired = $desired
            }
            Error = (New-DisableLegacyTLSError -Type 'DependencyFailure' -Message $_.Exception.Message)
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-DisableLegacyTLS
    if ($result.Succeeded) {
        Write-Output $result.Message
    }
    else {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
