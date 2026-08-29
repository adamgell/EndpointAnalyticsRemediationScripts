[CmdletBinding()]
param(
    [ValidateSet('Bootstrap')]
    [string] $Task = 'Bootstrap'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$requiredModules = Import-PowerShellDataFile -Path "$PSScriptRoot/tools/RequiredModules.psd1"

foreach ($moduleName in $requiredModules.Keys) {
    $requirement = $requiredModules[$moduleName]
    $installed = Get-Module -ListAvailable -Name $moduleName |
        Where-Object Version -EQ ([version] $requirement.Version)

    if (-not $installed) {
        Install-Module `
            -Name $moduleName `
            -RequiredVersion $requirement.Version `
            -Repository $requirement.Repository `
            -Scope CurrentUser `
            -Force `
            -AllowClobber
    }
}
