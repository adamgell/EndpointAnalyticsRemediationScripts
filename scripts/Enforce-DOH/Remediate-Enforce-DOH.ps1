<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: enforce-doh.ps1
Description: Enables DNS over HTTPS (DoH) system-wide
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

$EnforceDOHPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
$EnforceDOHName = "EnableAutoDoh"
$EnforceDOHValue = 2
$EnforceDOHType = "DWord"

function Get-EnforceDOHRegistryState {
    [CmdletBinding()]
    param()

    $property = Get-ItemProperty -Path $EnforceDOHPath -Name $EnforceDOHName -ErrorAction SilentlyContinue
    [pscustomobject][ordered]@{
        EnableAutoDoh = if ($property) { $property.EnableAutoDoh } else { $null }
    }
}

function Set-EnforceDOHRegistryState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$Value
    )

    if (-not (Test-Path -LiteralPath $EnforceDOHPath)) {
        New-Item -Path $EnforceDOHPath -Force -ErrorAction Stop | Out-Null
    }
    New-ItemProperty -Path $EnforceDOHPath -Name $EnforceDOHName -Value $Value `
        -PropertyType $EnforceDOHType -Force -ErrorAction Stop | Out-Null
}

function Repair-EnforceDOH {
    [CmdletBinding()]
    param(
        [Alias('GetRegistry', 'GetDnsState')]
        [scriptblock]$GetState = { Get-EnforceDOHRegistryState },
        [Alias('SetRegistry', 'SetDnsState')]
        [scriptblock]$SetState = { param($value) Set-EnforceDOHRegistryState -Value $value }
    )

    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to enable DoH: a DNS registry state reader is required.'
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'MissingDependency'
                Message = 'A DNS registry state reader is required.'
            }
        }
    }

    $before = $null
    try {
        $before = & $GetState
        $alreadyCompliant = $null -ne $before -and
        ($before.PSObject.Properties.Name -contains $EnforceDOHName) -and
        $null -ne $before.EnableAutoDoh -and
        ([int]$before.EnableAutoDoh -eq $EnforceDOHValue)
        if ($alreadyCompliant) {
            return [pscustomobject][ordered]@{
                Succeeded = $true
                Changed = $false
                ExitCode = 0
                Message = 'DNS over HTTPS has been enabled. A reboot may be required.'
                State = [pscustomobject][ordered]@{ Before = $before; After = $before }
                Error = $null
            }
        }

        if ($null -eq $SetState) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = 1
                Message = 'Failed to enable DoH: a registry state writer is required.'
                State = [pscustomobject][ordered]@{ Before = $before; After = 'Unknown' }
                Error = [pscustomobject]@{
                    Type = 'MissingDependency'
                    Message = 'A registry state writer is required.'
                }
            }
        }

        & $SetState $EnforceDOHValue | Out-Null
        $after = & $GetState
        $verified = $null -ne $after -and
        ($after.PSObject.Properties.Name -contains $EnforceDOHName) -and
        $null -ne $after.EnableAutoDoh -and
        ([int]$after.EnableAutoDoh -eq $EnforceDOHValue)
        if (-not $verified) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $true
                ExitCode = 1
                Message = 'Failed to enable DoH: registry value did not converge.'
                State = [pscustomobject][ordered]@{
                    Before = $before
                    After = if ($null -eq $after) { 'Unknown' } else { $after }
                }
                Error = [pscustomobject]@{
                    Type = 'VerificationFailure'
                    Message = 'The DoH registry value did not converge to the required value.'
                }
            }
        }

        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = 'DNS over HTTPS has been enabled. A reboot may be required.'
            State = [pscustomobject][ordered]@{ Before = $before; After = $after }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = "Failed to enable DoH: $($_.Exception.Message)"
            State = [pscustomobject][ordered]@{
                Before = if ($null -eq $before) { 'Unknown' } else { $before }
                After = 'Unknown'
            }
            Error = [pscustomobject]@{
                Type = 'DependencyFailure'
                Message = $_.Exception.Message
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-EnforceDOH
    if ($result.Succeeded) {
        Write-Output $result.Message
    }
    else {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
