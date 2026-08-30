[CmdletBinding()]
param(
    [switch] $SkipBootstrap
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$buildPath = Join-Path $PSScriptRoot 'build.ps1'
if (-not (Test-Path -LiteralPath $buildPath -PathType Leaf)) {
    throw "Build entry point not found: $buildPath"
}

$tasks = @('Validate', 'Analyze', 'Test', 'CheckFormat')
if (-not $SkipBootstrap) {
    $tasks = @('Bootstrap') + $tasks
}

foreach ($task in $tasks) {
    Write-Host "==> $task" -ForegroundColor Cyan
    try {
        if ($task -eq 'Bootstrap') {
            Set-PSRepository `
                -Name PSGallery `
                -InstallationPolicy Trusted `
                -ErrorAction Stop
        }
        & $buildPath -Task $task
    }
    catch {
        throw "Quality task '$task' failed: $($_.Exception.Message)"
    }
}
Write-Host 'All requested quality tasks passed.' -ForegroundColor Green
