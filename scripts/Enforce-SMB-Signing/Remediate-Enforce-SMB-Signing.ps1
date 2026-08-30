<#
Version: 1.0
Author:
Tom Coleman
Script: Detect SMB Signing
Description: Background https://learn.microsoft.com/en-GB/troubleshoot/windows-server/networking/overview-server-message-block-signing
Version 1.0: Init
Run as: Admin
Context: 64 Bit
#>

# The legacy path omitted the registry-provider drive separator.  Keep the
# same hive/key while using the explicit provider path required by PowerShell.
$EnforceSMBSigningPath = 'HKLM:\System\CurrentControlSet\Services\LanManWorkstation\Parameters'
$EnforceSMBSigningName = 'RequireSecuritySignature'
$EnforceSMBSigningType = "DWORD"
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

function Set-EnforceSMBSigningRegistryState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$Value
    )

    if (-not (Test-Path -LiteralPath $EnforceSMBSigningPath)) {
        New-Item -Path $EnforceSMBSigningPath -Force -ErrorAction Stop | Out-Null
    }
    New-ItemProperty -LiteralPath $EnforceSMBSigningPath -Name $EnforceSMBSigningName `
        -Value $Value -PropertyType $EnforceSMBSigningType -Force -ErrorAction Stop | Out-Null
}

function Repair-EnforceSMBSigning {
    [CmdletBinding()]
    param(
        [Alias('GetRegistry', 'GetSmbState')]
        [scriptblock]$GetState = { Get-EnforceSMBSigningRegistryState },
        [Alias('SetRegistry', 'SetSmbState')]
        [scriptblock]$SetState = { param($value) Set-EnforceSMBSigningRegistryState -Value $value }
    )

    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = ''
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'MissingDependency'
                Message = 'An SMB signing state reader is required.'
            }
        }
    }

    $before = $null
    try {
        $before = & $GetState
        $alreadyCompliant = $null -ne $before -and
        ($before.PSObject.Properties.Name -contains $EnforceSMBSigningName) -and
        $null -ne $before.RequireSecuritySignature -and
        ([int]$before.RequireSecuritySignature -eq $EnforceSMBSigningValue)
        if ($alreadyCompliant) {
            return [pscustomobject][ordered]@{
                Succeeded = $true
                Changed = $false
                ExitCode = 0
                Message = ''
                State = [pscustomobject][ordered]@{ Before = $before; After = $before }
                Error = $null
            }
        }

        if ($null -eq $SetState) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = 1
                Message = ''
                State = [pscustomobject][ordered]@{ Before = $before; After = 'Unknown' }
                Error = [pscustomobject]@{
                    Type = 'MissingDependency'
                    Message = 'A registry state writer is required.'
                }
            }
        }

        & $SetState $EnforceSMBSigningValue | Out-Null
        $after = & $GetState
        $verified = $null -ne $after -and
        ($after.PSObject.Properties.Name -contains $EnforceSMBSigningName) -and
        $null -ne $after.RequireSecuritySignature -and
        ([int]$after.RequireSecuritySignature -eq $EnforceSMBSigningValue)
        if (-not $verified) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $true
                ExitCode = 1
                Message = ''
                State = [pscustomobject][ordered]@{
                    Before = $before
                    After = if ($null -eq $after) { 'Unknown' } else { $after }
                }
                Error = [pscustomobject]@{
                    Type = 'VerificationFailure'
                    Message = 'The SMB signing registry value did not converge to the required value.'
                }
            }
        }

        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = ''
            State = [pscustomobject][ordered]@{ Before = $before; After = $after }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = ''
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
    $result = Repair-EnforceSMBSigning
    if (-not $result.Succeeded -and $result.Error) {
        Write-Error $result.Error.Message
    }
    elseif ($result.Message) {
        Write-Output $result.Message
    }
    exit $result.ExitCode
}
