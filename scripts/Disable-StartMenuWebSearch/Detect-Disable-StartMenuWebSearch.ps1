<#
Version: 1.0
Author:
Tom Coleman
Script: Detect Web Search
Description: Disabling web search on the start menu makes it so much faster and effective. No lag at all anymore!
Version 1.0: Init
Run as: Admin
Context: 64 Bit
#>

$DisableStartMenuWebSearchPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
$DisableStartMenuWebSearchName = "BingSearchEnabled"
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

function Test-DisableStartMenuWebSearch {
    [CmdletBinding()]
    param(
        [Alias('GetRegistry', 'GetSearchState')]
        [scriptblock]$GetState = { Get-DisableStartMenuWebSearchRegistryState }
    )
    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant'
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'MissingDependency'
                Message = 'A registry state reader is required.'
            }
        }
    }

    try {
        $state = & $GetState
        $hasValue = $null -ne $state -and
        ($state.PSObject.Properties.Name -contains $DisableStartMenuWebSearchName) -and
        $null -ne $state.BingSearchEnabled
        $compliant = $hasValue -and ([int]$state.BingSearchEnabled -eq $DisableStartMenuWebSearchValue)
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
    $decision = Test-DisableStartMenuWebSearch
    if ($decision.Compliant) {
        Write-Output $decision.Message
    }
    else {
        Write-Warning $decision.Message
    }
    exit $decision.ExitCode
}
