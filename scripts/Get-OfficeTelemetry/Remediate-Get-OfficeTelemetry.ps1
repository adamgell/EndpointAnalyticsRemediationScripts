<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: Remediate-Office_Telemetry
Description: Disable O365 from sharing telemetry
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: User
Context: 32 & 64 Bit
#>

function ConvertTo-OfficeTelemetryRepairState {
    param(
        $Record,
        [string]$Name
    )
    $state = [ordered]@{
        Path = 'HKCU:\Software\Policies\Microsoft\office\common\clienttelemetry'
        Name = $Name
        ExpectedValue = 1
        ExpectedType = 'DWORD'
        Exists = $false
        ObservedValue = $null
        ObservedType = $null
        Error = $null
    }
    if ($null -eq $Record) {
        return [pscustomobject]$state
    }
    $state.Exists = if ($null -ne $Record.PSObject.Properties['Exists']) { [bool]$Record.Exists } else { $true }
    if ($null -ne $Record.PSObject.Properties['Value']) {
        $state.ObservedValue = $Record.Value
    }
    elseif ($null -ne $Record.PSObject.Properties[$Name]) {
        $state.ObservedValue = $Record.PSObject.Properties[$Name].Value
    }
    else {
        $state.ObservedValue = $Record
    }
    if ($null -ne $Record.PSObject.Properties['Type']) {
        $state.ObservedType = [string]$Record.Type
    }
    [pscustomobject]$state
}

function Get-OfficeTelemetryRepairObservation {
    param([scriptblock]$GetRegistry)
    $path = 'HKCU:\Software\Policies\Microsoft\office\common\clienttelemetry'
    $name = 'DisableTelemetry'
    $state = [pscustomobject][ordered]@{
        Path = $path
        Name = $name
        ExpectedValue = 1
        ExpectedType = 'DWORD'
        Exists = $false
        ObservedValue = $null
        ObservedType = $null
        Error = $null
    }
    if ($null -eq $GetRegistry) {
        $state.Error = [pscustomobject]@{ Type = 'MissingDependency'; Message = 'A registry getter is required.' }
        return [pscustomobject]@{ Compliant = $false; State = $state; Error = $state.Error }
    }
    try {
        $records = @(& $GetRegistry $path $name)
        if ($records.Count -gt 1) { throw 'The registry getter returned multiple states.' }
        $record = if ($records.Count -eq 0) { $null } else { $records[0] }
        $normalized = ConvertTo-OfficeTelemetryRepairState -Record $record -Name $name
        $state.Exists = $normalized.Exists
        $state.ObservedValue = $normalized.ObservedValue
        $state.ObservedType = $normalized.ObservedType
        $compliant = $state.Exists -and ($state.ObservedValue -eq 1)
        return [pscustomobject]@{ Compliant = $compliant; State = $state; Error = $null }
    }
    catch {
        $state.Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
        return [pscustomobject]@{ Compliant = $false; State = $state; Error = $state.Error }
    }
}

function Repair-GetOfficeTelemetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [Alias('GetState')]
        [AllowNull()]
        [scriptblock]$GetRegistry = {
            param($RegistryPath, $RegistryName)
            try {
                $key = Get-Item -LiteralPath $RegistryPath -ErrorAction Stop
            }
            catch [System.Management.Automation.ItemNotFoundException] {
                return [pscustomobject]@{ Exists = $false; Value = $null; Type = $null }
            }
            if (@($key.GetValueNames()) -notcontains $RegistryName) {
                return [pscustomobject]@{ Exists = $false; Value = $null; Type = $null }
            }
            [pscustomobject]@{
                Exists = $true
                Value = $key.GetValue($RegistryName)
                Type = [string]$key.GetValueKind($RegistryName)
            }
        },
        [Parameter(Mandatory = $false)]
        [Alias('SetState')]
        [AllowNull()]
        [scriptblock]$SetRegistry = {
            param($RegistryPath, $RegistryName, $RegistryValue, $RegistryType)
            $parentPath = 'HKCU:\Software\Policies\Microsoft\office\common\'
            New-Item -Path $parentPath -Name 'clienttelemetry' -Force -ErrorAction Stop | Out-Null
            New-ItemProperty `
                -Path $RegistryPath `
                -Name $RegistryName `
                -Value ([int]$RegistryValue) `
                -PropertyType DWord `
                -Force `
                -ErrorAction Stop | Out-Null
        }
    )
    $path = 'HKCU:\Software\Policies\Microsoft\office\common\clienttelemetry'
    $name = 'DisableTelemetry'
    $value = 1
    $type = 'DWORD'
    $before = Get-OfficeTelemetryRepairObservation -GetRegistry $GetRegistry
    $state = [pscustomobject][ordered]@{
        Path = $path
        Name = $name
        ExpectedValue = $value
        ExpectedType = $type
        Before = $before.State
        After = $before.State
        Error = $null
    }
    if ($null -ne $before.Error) {
        $state.Error = $before.Error
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'R1 Failed'
            State = $state
            Error = $before.Error
        }
    }
    if ($before.Compliant) {
        return [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $false
            ExitCode = 0
            Message = 'R1 Remediated'
            State = $state
            Error = $null
        }
    }
    if ($null -eq $SetRegistry) {
        $state.Error = [pscustomobject]@{ Type = 'MissingDependency'; Message = 'A registry setter is required.' }
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'R1 Failed'
            State = $state
            Error = $state.Error
        }
    }
    try {
        $null = & $SetRegistry $path $name $value $type
    }
    catch {
        $state.Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'R1 Failed'
            State = $state
            Error = $state.Error
        }
    }
    $after = Get-OfficeTelemetryRepairObservation -GetRegistry $GetRegistry
    $state.After = $after.State
    if ($null -ne $after.Error) {
        $state.Error = $after.Error
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $true
            ExitCode = 1
            Message = 'R1 Failed'
            State = $state
            Error = $after.Error
        }
    }
    if (-not $after.Compliant) {
        $state.Error = [pscustomobject]@{
            Type = 'VerificationFailure'
            Message = 'Registry remediation did not converge to the expected value.'
        }
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $true
            ExitCode = 1
            Message = 'R1 Failed'
            State = $state
            Error = $state.Error
        }
    }
    [pscustomobject][ordered]@{
        Succeeded = $true
        Changed = $true
        ExitCode = 0
        Message = 'R1 Remediated'
        State = $state
        Error = $null
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Repair-GetOfficeTelemetry
    if (-not $result.Succeeded) {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
