<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: enable-darkmode.ps1
Description: Enables system-wide dark mode
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: System
Context: 64 Bit
#>

$EnableDarkModePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$EnableDarkModeAppsName = "AppsUseLightTheme"
$EnableDarkModeSystemName = "SystemUsesLightTheme"
$EnableDarkModeValue = 0
$EnableDarkModeType = "DWord"

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

function Set-EnableDarkModeRegistryState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$AppsUseLightTheme,
        [Parameter(Mandatory)]
        [int]$SystemUsesLightTheme
    )

    if (-not (Test-Path -LiteralPath $EnableDarkModePath)) {
        New-Item -Path $EnableDarkModePath -Force -ErrorAction Stop | Out-Null
    }
    New-ItemProperty -Path $EnableDarkModePath -Name $EnableDarkModeAppsName `
        -Value $AppsUseLightTheme -PropertyType $EnableDarkModeType -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -Path $EnableDarkModePath -Name $EnableDarkModeSystemName `
        -Value $SystemUsesLightTheme -PropertyType $EnableDarkModeType -Force -ErrorAction Stop | Out-Null
}

function Repair-EnableDarkMode {
    [CmdletBinding()]
    param(
        [Alias('GetRegistry', 'GetPersonalizationState')]
        [scriptblock]$GetState = { Get-EnableDarkModeRegistryState },
        [Alias('SetRegistry', 'SetPersonalizationState')]
        [scriptblock]$SetState = {
            param($appsUseLightTheme, $systemUsesLightTheme)
            Set-EnableDarkModeRegistryState `
                -AppsUseLightTheme $appsUseLightTheme `
                -SystemUsesLightTheme $systemUsesLightTheme
        }
    )

    if ($null -eq $GetState) {
        return [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = 'Failed to enable dark mode: a registry state reader is required.'
            State = 'Unknown'
            Error = [pscustomobject]@{
                Type = 'MissingDependency'
                Message = 'A registry state reader is required.'
            }
        }
    }

    $before = $null
    try {
        $before = & $GetState
        $alreadyCompliant = $null -ne $before -and
        ($before.PSObject.Properties.Name -contains $EnableDarkModeAppsName) -and
        ($before.PSObject.Properties.Name -contains $EnableDarkModeSystemName) -and
        $null -ne $before.AppsUseLightTheme -and
        $null -ne $before.SystemUsesLightTheme -and
        ([int]$before.AppsUseLightTheme -eq $EnableDarkModeValue) -and
        ([int]$before.SystemUsesLightTheme -eq $EnableDarkModeValue)
        if ($alreadyCompliant) {
            return [pscustomobject][ordered]@{
                Succeeded = $true
                Changed = $false
                ExitCode = 0
                Message = 'Dark mode has been enabled system-wide'
                State = [pscustomobject][ordered]@{ Before = $before; After = $before }
                Error = $null
            }
        }

        if ($null -eq $SetState) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $false
                ExitCode = 1
                Message = 'Failed to enable dark mode: a registry state writer is required.'
                State = [pscustomobject][ordered]@{ Before = $before; After = 'Unknown' }
                Error = [pscustomobject]@{
                    Type = 'MissingDependency'
                    Message = 'A registry state writer is required.'
                }
            }
        }

        & $SetState $EnableDarkModeValue $EnableDarkModeValue | Out-Null
        $after = & $GetState
        $verified = $null -ne $after -and
        ($after.PSObject.Properties.Name -contains $EnableDarkModeAppsName) -and
        ($after.PSObject.Properties.Name -contains $EnableDarkModeSystemName) -and
        $null -ne $after.AppsUseLightTheme -and
        $null -ne $after.SystemUsesLightTheme -and
        ([int]$after.AppsUseLightTheme -eq $EnableDarkModeValue) -and
        ([int]$after.SystemUsesLightTheme -eq $EnableDarkModeValue)
        if (-not $verified) {
            return [pscustomobject][ordered]@{
                Succeeded = $false
                Changed = $true
                ExitCode = 1
                Message = 'Failed to enable dark mode: registry values did not converge.'
                State = [pscustomobject][ordered]@{
                    Before = $before
                    After = if ($null -eq $after) { 'Unknown' } else { $after }
                }
                Error = [pscustomobject]@{
                    Type = 'VerificationFailure'
                    Message = 'The registry values did not converge to dark mode.'
                }
            }
        }

        [pscustomobject][ordered]@{
            Succeeded = $true
            Changed = $true
            ExitCode = 0
            Message = 'Dark mode has been enabled system-wide'
            State = [pscustomobject][ordered]@{ Before = $before; After = $after }
            Error = $null
        }
    }
    catch {
        [pscustomobject][ordered]@{
            Succeeded = $false
            Changed = $false
            ExitCode = 1
            Message = "Failed to enable dark mode: $($_.Exception.Message)"
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
    $result = Repair-EnableDarkMode
    if ($result.Succeeded) {
        Write-Output $result.Message
    }
    else {
        Write-Error $result.Message
    }
    exit $result.ExitCode
}
