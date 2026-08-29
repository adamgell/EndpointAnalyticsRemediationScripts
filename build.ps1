[CmdletBinding()]
param(
    [ValidateSet('Bootstrap', 'ValidateRewrite')]
    [string] $Task = 'Bootstrap',
    [string] $BaseRevision,
    [string] $PathMap,
    [string] $SymbolMap,
    [string] $ReportPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

switch ($Task) {
    'Bootstrap' {
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
    }
    'ValidateRewrite' {
        foreach ($parameter in 'BaseRevision', 'PathMap', 'SymbolMap', 'ReportPath') {
            if ([string]::IsNullOrWhiteSpace((Get-Variable -Name $parameter -ValueOnly))) {
                throw "-$parameter is required when -Task ValidateRewrite is used."
            }
        }

        & "$PSScriptRoot/tools/Test-PowerShellRewrite.ps1" `
            -BaseRevision $BaseRevision `
            -PathMap $PathMap `
            -SymbolMap $SymbolMap `
            -ReportPath $ReportPath
        exit $LASTEXITCODE
    }
}
