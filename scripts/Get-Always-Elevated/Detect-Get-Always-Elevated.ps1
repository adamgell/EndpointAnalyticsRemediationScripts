<#
Version: 1.0
Author:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: Get-Always_Elevated
Description:
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: Admin
Context: 32 & 64 Bit
#>

function ConvertTo-AlwaysElevatedState {
    param(
        [Parameter(Mandatory = $false)]
        $Record,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $state = [ordered]@{
        Exists = $false
        ExpectedValue = 0
        ExpectedType = 'DWORD'
        ObservedValue = $null
        ObservedType = $null
    }

    if ($null -eq $Record) {
        return [pscustomobject]$state
    }

    if ($null -ne $Record.PSObject.Properties['Exists']) {
        $state.Exists = [bool]$Record.Exists
    }
    else {
        $state.Exists = $true
    }

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

    return [pscustomobject]$state
}

function Test-GetAlwaysElevated {
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
        }
    )
    $path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer'
    $name = 'AlwaysInstallElevated'

    $state = [pscustomobject][ordered]@{
        Path = $path
        Name = $name
        ExpectedValue = 0
        ExpectedType = 'DWORD'
        DesiredValue = 0
        Value = $null
        Status = 'Unknown'
        Exists = $false
        ObservedValue = $null
        ObservedType = $null
        Error = $null
    }

    if ($null -eq $GetRegistry) {
        $state.Error = [pscustomobject]@{ Type = 'MissingDependency'; Message = 'A registry getter is required.' }
        $state.Status = 'MissingDependency'
        $state.Value = $null

        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant'
            State = $state
            Error = $state.Error
        }
    }

    try {
        $records = @(& $GetRegistry $path $name)
        if ($records.Count -gt 1) {
            throw 'The registry getter returned multiple states.'
        }
        $observed = if ($records.Count -eq 0) { $null } else { $records[0] }
        $normalized = ConvertTo-AlwaysElevatedState -Record $observed -Name $name
        $state.Exists = $normalized.Exists
        $state.ObservedValue = $normalized.ObservedValue
        $state.ObservedType = $normalized.ObservedType
        $state.Value = $state.ObservedValue
        $compliant = $state.Exists -and ($state.ObservedValue -eq 0)
        $state.Status = if ($compliant) { 'Compliant' } else { 'NonCompliant' }
        return [pscustomobject][ordered]@{
            Compliant = $compliant
            ExitCode = if ($compliant) { 0 } else { 1 }
            Message = if ($compliant) { 'Compliant' } else { 'Not Compliant' }
            State = $state
            Error = $null
        }
    }
    catch {
        $state.Error = [pscustomobject]@{ Type = 'DependencyFailure'; Message = $_.Exception.Message }
        $state.Status = 'DependencyFailure'
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant'
            State = $state
            Error = $state.Error
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = Test-GetAlwaysElevated
    if ($result.Compliant) {
        Write-Output $result.Message
    }
    else {
        Write-Warning $result.Message
    }
    exit $result.ExitCode
}
