<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: detect-darkmode.ps1
Description: Detects if system-wide dark mode is enabled
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

$EnableDarkModePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$EnableDarkModeAppsName = "AppsUseLightTheme"
$EnableDarkModeSystemName = "SystemUsesLightTheme"

function Get-EnableDarkModeRegistryState {
    [CmdletBinding()]
    param()

    $apps = Get-ItemProperty -Path $EnableDarkModePath -Name $EnableDarkModeAppsName -ErrorAction SilentlyContinue
    $system = Get-ItemProperty -Path $EnableDarkModePath -Name $EnableDarkModeSystemName -ErrorAction SilentlyContinue
    [pscustomobject][ordered]@{
        AppsUseLightTheme = if ($apps) { $apps.AppsUseLightTheme } else { $null }
        SystemUsesLightTheme = if ($system) { $system.SystemUsesLightTheme } else { $null }
    }
}

function Test-EnableDarkMode {
    [CmdletBinding()]
    param(
        [Alias('GetRegistry', 'GetPersonalizationState')]
        [scriptblock]$GetState = { Get-EnableDarkModeRegistryState }
    )

    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = 'Not Compliant - Dark mode is not fully enabled'
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'MissingDependency'
                Message = 'A registry state reader is required.'
            }
        }
    }

    try {
        $state = & $GetState
        $hasApps = $null -ne $state -and
        ($state.PSObject.Properties.Name -contains $EnableDarkModeAppsName) -and
        $null -ne $state.AppsUseLightTheme
        $hasSystem = $null -ne $state -and
        ($state.PSObject.Properties.Name -contains $EnableDarkModeSystemName) -and
        $null -ne $state.SystemUsesLightTheme
        $compliant = $hasApps -and $hasSystem -and
        ([int]$state.AppsUseLightTheme -eq 0) -and
        ([int]$state.SystemUsesLightTheme -eq 0)
        if ($compliant) {
            $message = 'Compliant - Dark mode is enabled'
        }
        else {
            $message = 'Not Compliant - Dark mode is not fully enabled'
        }
        [pscustomobject][ordered]@{
            Compliant = $compliant
            ExitCode = if ($compliant) { 0 } else { 1 }
            Message = $message
            State = if ($null -eq $state) { 'Unknown' } else { $state }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Compliant = $false
            ExitCode = 1
            Message = "Error checking dark mode: $($_.Exception.Message)"
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'DependencyFailure'
                Message = $_.Exception.Message
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $decision = Test-EnableDarkMode
    if ($decision.Compliant) {
        Write-Output $decision.Message
    }
    else {
        Write-Warning $decision.Message
    }
    exit $decision.ExitCode
}
