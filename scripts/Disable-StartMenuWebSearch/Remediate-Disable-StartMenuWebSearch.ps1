<#
Version: 1.0
Author:
Tom Coleman
Script: Stop Web Search
Description: Disabling web search on the start menu makes it so much faster and effective. No lag at all anymore!
Version 1.0: Init
Run as: Admin
Context: 64 Bit
#>

$DisableStartMenuWebSearchPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
$DisableStartMenuWebSearchName = "BingSearchEnabled"
$DisableStartMenuWebSearchType = "DWORD"
$DisableStartMenuWebSearchValue = 0

function Get-DisableStartMenuWebSearchRegistryState {
    [CmdletBinding()]
    param()

    $value = Get-ItemProperty `
        -Path $DisableStartMenuWebSearchPath `
        -Name $DisableStartMenuWebSearchName `
        -ErrorAction Stop |
        Select-Object -ExpandProperty $DisableStartMenuWebSearchName
    [pscustomobject][ordered]@{
        BingSearchEnabled = $value
    }
}

function Set-DisableStartMenuWebSearchRegistryState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$Value
    )

    if (-not (Test-Path -LiteralPath $DisableStartMenuWebSearchPath)) {
        New-Item -Path $DisableStartMenuWebSearchPath -Force -ErrorAction Stop | Out-Null
    }
    New-ItemProperty -Path $DisableStartMenuWebSearchPath -Name $DisableStartMenuWebSearchName `
        -Value $Value -PropertyType $DisableStartMenuWebSearchType -Force -ErrorAction Stop | Out-Null
}

function Repair-DisableStartMenuWebSearch {
    [CmdletBinding()]
    param(
        [Alias('GetRegistry', 'GetSearchState')]
        [scriptblock]$GetState = { Get-DisableStartMenuWebSearchRegistryState },
        [Alias('SetRegistry', 'SetSearchState')]
        [scriptblock]$SetState = { param($value) Set-DisableStartMenuWebSearchRegistryState -Value $value }
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
                Message = 'A registry state reader is required.'
            }
        }
    }

    try {
        $before = & $GetState
        $alreadyCompliant = $null -ne $before -and
        ($before.PSObject.Properties.Name -contains $DisableStartMenuWebSearchName) -and
        $null -ne $before.BingSearchEnabled -and
        ([int]$before.BingSearchEnabled -eq $DisableStartMenuWebSearchValue)
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

        & $SetState $DisableStartMenuWebSearchValue | Out-Null
        $after = & $GetState
        $verified = $null -ne $after -and
        ($after.PSObject.Properties.Name -contains $DisableStartMenuWebSearchName) -and
        $null -ne $after.BingSearchEnabled -and
        ([int]$after.BingSearchEnabled -eq $DisableStartMenuWebSearchValue)
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
                    Message = 'The registry value did not converge to the required value.'
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
    $result = Repair-DisableStartMenuWebSearch
    if (-not $result.Succeeded) {
        $errorMessage = if ($result.Error) { $result.Error.Message } else { $result.Message }
        if ($errorMessage) {
            Write-Error $errorMessage
        }
    }
    elseif ($result.Message) {
        Write-Output $result.Message
    }
    exit $result.ExitCode
}
