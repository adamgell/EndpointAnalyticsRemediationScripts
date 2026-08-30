<#
Version: 1.0
Author:
Tom Coleman
Script: Detect SMB Signing
Description: Background https://learn.microsoft.com/en-GB/troubleshoot/windows-server/networking/overview-server-message-block-signing
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: Admin
Context: 64 Bit
#>

$EnforceSMBSigningPath = 'HKLM:\System\CurrentControlSet\Services\LanManWorkstation\Parameters'
$EnforceSMBSigningName = 'RequireSecuritySignature'
$EnforceSMBSigningValue = 1

function Get-EnforceSMBSigningRegistryState {
    [CmdletBinding()]
    param()

    $value = Get-ItemProperty -Path $EnforceSMBSigningPath -Name $EnforceSMBSigningName -ErrorAction Stop |
        Select-Object -ExpandProperty $EnforceSMBSigningName
    [pscustomobject][ordered]@{
        RequireSecuritySignature = $value
    }
}

function Test-EnforceSMBSigning {
    [CmdletBinding()]
    param(
        [Alias('GetRegistry', 'GetSmbState')]
        [scriptblock]$GetState = { Get-EnforceSMBSigningRegistryState }
    )

    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant'
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'MissingDependency'
                Message = 'An SMB signing state reader is required.'
            }
        }
    }

    try {
        $state = & $GetState
        $compliant = $null -ne $state -and
        ($state.PSObject.Properties.Name -contains $EnforceSMBSigningName) -and
        $null -ne $state.RequireSecuritySignature -and
        ([int]$state.RequireSecuritySignature -eq $EnforceSMBSigningValue)
        [pscustomobject][ordered]@{
            Compliant = $compliant
            ExitCode = if ($compliant) { 0 } else { 1 }
            Message = if ($compliant) { 'Compliant' } else { 'Not Compliant' }
            State = if ($null -eq $state) { 'Unknown' } else { $state }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant'
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'DependencyFailure'
                Message = $_.Exception.Message
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Test-EnforceSMBSigning
    if ($decision.Compliant) {
        Write-Output $decision.Message
    }
    else {
        Write-Warning $decision.Message
    }
    exit $decision.ExitCode
}
