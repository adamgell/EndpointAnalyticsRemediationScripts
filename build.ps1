[CmdletBinding()]
param(
    [ValidateSet(
        'Bootstrap',
        'Validate',
        'Analyze',
        'Test',
        'CheckFormat',
        'ValidateRewrite'
    )]
    [string] $Task = 'Validate',
    [string] $BaseRevision,
    [string] $PathMap,
    [string] $SymbolMap,
    [string] $ReportPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
$scriptRoot = Join-Path $repositoryRoot 'scripts'
$requiredModulesPath = Join-Path $repositoryRoot 'tools/RequiredModules.psd1'

function Resolve-RepositoryPath {
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [string] $Description
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "$Description is required."
    }
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $Path))
}

function Get-RequiredModuleVersion {
    param(
        [Parameter(Mandatory)] [System.Collections.IDictionary] $Requirement,
        [Parameter(Mandatory)] [string] $ModuleName
    )

    try {
        return [version] $Requirement.Version
    }
    catch {
        throw "Required module '$ModuleName' has an invalid pinned version."
    }
}

function Install-PinnedModule {
    param(
        [Parameter(Mandatory)] [string] $ModuleName,
        [Parameter(Mandatory)] [System.Collections.IDictionary] $Requirement
    )

    $version = Get-RequiredModuleVersion `
        -Requirement $Requirement `
        -ModuleName $ModuleName
    $installParameters = @{
        Name = $ModuleName
        RequiredVersion = $version
        Repository = [string] $Requirement.Repository
        Scope = 'CurrentUser'
        ErrorAction = 'Stop'
    }

    try {
        Install-Module @installParameters
    }
    catch {
        $message = [string] $_.Exception.Message
        $publisherMismatch = (
            ([string] $_.FullyQualifiedErrorId -match '(?i)publisher.*mismatch') -or
            ($message -match '(?i)publisher\s*.*mismatch|mismatch\s*.*publisher')
        )
        if (-not $publisherMismatch) {
            throw
        }

        # A signed Windows PowerShell inbox module can have a different
        # publisher from PSGallery. Retry only this package and keep the
        # install in CurrentUser so the inbox module is never overwritten.
        $installParameters.SkipPublisherCheck = $true
        Install-Module @installParameters
    }
}

function Import-PinnedModule {
    param(
        [Parameter(Mandatory)] [string] $ModuleName,
        [Parameter(Mandatory)] [System.Collections.IDictionary] $Requirement
    )

    $version = Get-RequiredModuleVersion `
        -Requirement $Requirement `
        -ModuleName $ModuleName
    $installed = @(
        foreach ($module in @(Get-Module -ListAvailable -Name $ModuleName)) {
            if ($module.Version -eq $version) {
                $module
            }
        }
    )
    if ($installed.Count -eq 0) {
        throw "Pinned module '$ModuleName' version '$version' is not installed."
    }
    Import-Module -Name $ModuleName -RequiredVersion $version -Force -ErrorAction Stop
}

function Import-QualityModules {
    param([Parameter(Mandatory)] [string[]] $Names)

    $requiredModules = Import-PowerShellDataFile -LiteralPath $requiredModulesPath
    foreach ($moduleName in $Names) {
        if (-not $requiredModules.Contains($moduleName)) {
            throw "Required module '$moduleName' is not declared in RequiredModules.psd1."
        }
        Import-PinnedModule `
            -ModuleName $moduleName `
            -Requirement $requiredModules[$moduleName]
    }
}

function Get-RelativeRepositoryPath {
    param([Parameter(Mandatory)] [string] $Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $relativePath = $fullPath.Substring($repositoryRoot.Length)
    return $relativePath.TrimStart('\', '/').Replace('\', '/')
}

function Invoke-RepositoryValidation {
    Import-Module (Join-Path $repositoryRoot 'tools/RepositoryCatalog.psm1') -Force
    $schemaPath = Join-Path $repositoryRoot 'standards/ManifestSchema.psd1'
    $pathMap = Import-PowerShellDataFile -LiteralPath (
        Join-Path $repositoryRoot 'evidence/foundation/PathMap.psd1'
    )
    $scripts = @(Get-DeploymentScript -Root $scriptRoot)
    if ($scripts.Count -ne 271) {
        throw "Expected 271 deployment scripts, found $($scripts.Count)."
    }

    $scriptPaths = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal
    )
    $manifestFailures = New-Object 'System.Collections.Generic.List[string]'
    $parseFailures = New-Object 'System.Collections.Generic.List[string]'
    $statuses = New-Object 'System.Collections.Generic.List[string]'
    foreach ($script in $scripts) {
        $relativePath = Get-RelativeRepositoryPath -Path $script.FullName
        $scriptRelativePath = $script.FullName.Substring($scriptRoot.Length).
        TrimStart('\', '/').
        Replace('\', '/')
        $null = $scriptPaths.Add($scriptRelativePath)
        $manifestPath = [System.IO.Path]::ChangeExtension($script.FullName, '.psd1')
        if (-not [System.IO.File]::Exists($manifestPath)) {
            $manifestFailures.Add("$relativePath is missing its manifest.")
        }
        else {
            $result = Test-ScriptManifest `
                -Path $manifestPath `
                -SchemaPath $schemaPath
            if (-not $result.Valid) {
                foreach ($errorText in @($result.Errors)) {
                    $manifestFailures.Add("$relativePath`: $errorText")
                }
            }
            $statuses.Add([string] $result.Manifest.Test.Status)
            if (-not (Test-ManifestStatusTransition `
                        -Before ([string] $result.Manifest.Test.Status) `
                        -After ([string] $result.Manifest.Test.Status))) {
                $manifestFailures.Add("$relativePath has an invalid migration state.")
            }
        }

        $tokens = $null
        $parseErrors = $null
        $null = [System.Management.Automation.Language.Parser]::ParseFile(
            $script.FullName,
            [ref] $tokens,
            [ref] $parseErrors
        )
        foreach ($parseError in @($parseErrors)) {
            $parseFailures.Add(
                "$relativePath`:$($parseError.Extent.StartLineNumber): $($parseError.Message)"
            )
        }
    }
    if ($manifestFailures.Count -gt 0) {
        throw "Manifest validation failed: $($manifestFailures -join '; ')"
    }
    if ($parseFailures.Count -gt 0) {
        throw "PowerShell parsing failed: $($parseFailures -join '; ')"
    }
    $mappedPaths = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal
    )
    foreach ($row in @($pathMap.Paths)) {
        $null = $mappedPaths.Add([string] $row.NewPath)
    }
    if ($mappedPaths.Count -ne $scriptPaths.Count -or
        @(
            Compare-Object `
                -ReferenceObject ([string[]] $mappedPaths) `
                -DifferenceObject ([string[]] $scriptPaths) `
                -CaseSensitive
        ).Count -gt 0) {
        throw 'Current deployment inventory does not match the destination path map.'
    }


    $unresolvedReferences = @(
        Get-UnresolvedRepositoryReference -Root $repositoryRoot
    )
    if ($unresolvedReferences.Count -gt 0) {
        throw (
            'Unresolved repository references: ' +
            (($unresolvedReferences | ForEach-Object {
                    "$($_.Markdown): $($_.Target)"
                }) -join '; ')
        )
    }

    $statusSummary = @($statuses | Group-Object | ForEach-Object {
            '{0}={1}' -f $_.Name, $_.Count
        })
    Write-Output (
        "Validated $($scripts.Count) deployment scripts and manifests; " +
        "migration states: $($statusSummary -join ', ')."
    )
}

function Invoke-RepositoryAnalyzer {
    Import-QualityModules -Names @('PSScriptAnalyzer')
    $settingsPath = Join-Path $repositoryRoot 'PSScriptAnalyzerSettings.psd1'
    $findings = @(
        Invoke-ScriptAnalyzer `
            -Path $repositoryRoot `
            -Recurse `
            -Settings $settingsPath
    )
    if ($findings.Count -gt 0) {
        $findings | Write-Output
        throw "PSScriptAnalyzer found $($findings.Count) findings."
    }
    Write-Output 'PSScriptAnalyzer recursive analysis passed with zero findings.'
}

function Get-CoveredScriptPaths {
    Import-Module (Join-Path $repositoryRoot 'tools/RepositoryCatalog.psm1') -Force
    $schemaPath = Join-Path $repositoryRoot 'standards/ManifestSchema.psd1'
    $paths = New-Object 'System.Collections.Generic.List[string]'
    foreach ($script in @(Get-DeploymentScript -Root $scriptRoot)) {
        $manifestPath = [System.IO.Path]::ChangeExtension($script.FullName, '.psd1')
        $manifest = (Test-ScriptManifest `
                -Path $manifestPath `
                -SchemaPath $schemaPath).Manifest
        if ([string] $manifest.Test.Status -eq 'Covered') {
            $paths.Add($script.FullName)
        }
    }
    return $paths.ToArray()
}

function Test-PesterResultSuccess {
    param([Parameter(Mandatory)] [psobject] $Result)

    $resultProperty = $Result.PSObject.Properties['Result']
    $failedCountProperty = $Result.PSObject.Properties['FailedCount']
    $resultState = if ($null -ne $resultProperty) {
        [string] $resultProperty.Value
    }
    else {
        ''
    }
    $failedCount = if ($null -ne $failedCountProperty -and
        $null -ne $failedCountProperty.Value) {
        [int] $failedCountProperty.Value
    }
    else {
        -1
    }
    return ($resultState -eq 'Passed' -and $failedCount -eq 0)
}

function Invoke-RepositoryTests {
    param([switch] $EnableCoverage)

    Import-QualityModules -Names @('Pester')
    $configuration = New-PesterConfiguration
    $configuration.Run.Path = @(Join-Path $repositoryRoot 'tests')
    $configuration.Run.Exit = $false
    $configuration.Run.PassThru = $true
    $coveragePaths = @()
    if ($EnableCoverage) {
        # PendingMigration scripts intentionally produce an empty coverage
        # input during foundation; repository and tooling tests still run.
        $coveragePaths = @(Get-CoveredScriptPaths)
    }
    $configuration.CodeCoverage.Enabled = (
        $EnableCoverage.IsPresent -and $coveragePaths.Count -gt 0
    )
    if ($configuration.CodeCoverage.Enabled) {
        $configuration.CodeCoverage.Path = $coveragePaths
    }
    $result = Invoke-Pester -Configuration $configuration
    if (-not (Test-PesterResultSuccess -Result $result)) {
        if ($result.FailedCount -gt 0) {
            throw "Pester reported $($result.FailedCount) failed tests."
        }
        throw "Pester reported non-success result '$([string] $result.Result)'."
    }
    Write-Output (
        "Pester passed: $($result.PassedCount) passed, " +
        "$($result.SkippedCount) skipped."
    )
}

function Invoke-FormatCheck {
    Import-QualityModules -Names @('Pester')
    $result = Invoke-Pester `
        -Path (Join-Path $repositoryRoot 'tests/Repository.Tests.ps1') `
        -Tag FoundationStyle `
        -Output Detailed `
        -PassThru
    if (-not (Test-PesterResultSuccess -Result $result)) {
        if ($result.FailedCount -gt 0) {
            throw "Formatting verification reported $($result.FailedCount) failed tests."
        }
        throw (
            "Formatting verification reported non-success result " +
            "'$([string] $result.Result)'."
        )
    }
    Write-Output 'Formatting verification passed without rewriting files.'
}

function Invoke-MapValidation {
    Import-QualityModules -Names @('Pester')
    $result = Invoke-Pester `
        -Path (Join-Path $repositoryRoot 'tests/Repository.Tests.ps1') `
        -Tag FoundationMapCurrentTree `
        -Output Detailed `
        -PassThru
    if (-not (Test-PesterResultSuccess -Result $result)) {
        if ($result.FailedCount -gt 0) {
            throw "Map validation reported $($result.FailedCount) failed tests."
        }
        throw "Map validation reported non-success result '$([string] $result.Result)'."
    }
    Write-Output 'Path-map and symbol-map validation passed.'
}

function Invoke-ManifestValidation {
    $tempName = 'EndpointAnalyticsRemediationScripts-' + [guid]::NewGuid().ToString('N')
    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) $tempName
    try {
        $pathMap = Import-PowerShellDataFile -LiteralPath (
            Join-Path $repositoryRoot 'evidence/foundation/PathMap.psd1'
        )
        $expectedPaths = @($pathMap.Paths | ForEach-Object {
                [System.IO.Path]::ChangeExtension([string] $_.NewPath, '.psd1')
            })
        $generator = Join-Path $repositoryRoot 'tools/New-ScriptManifest.ps1'
        $global:LASTEXITCODE = 0
        & $generator `
            -PathMap (Join-Path $repositoryRoot 'evidence/foundation/PathMap.psd1') `
            -Metadata (Join-Path $repositoryRoot 'standards/FoundationPackages.psd1') `
            -Schema (Join-Path $repositoryRoot 'standards/ManifestSchema.psd1') `
            -OutputRoot $tempRoot
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0) {
            throw "Manifest generation failed with exit code $exitCode."
        }

        $generatedPaths = @(
            Get-ChildItem -LiteralPath $tempRoot -Recurse -File -Filter '*.psd1' |
                ForEach-Object {
                    $_.FullName.Substring($tempRoot.Length).
                    TrimStart('\', '/').Replace('\', '/')
                }
        )
        if ($generatedPaths.Count -ne 271 -or
            @(
                Compare-Object `
                    -ReferenceObject ([string[]] $expectedPaths) `
                    -DifferenceObject ([string[]] $generatedPaths) `
                    -CaseSensitive
            ).Count -gt 0) {
            throw 'Generated manifest inventory does not match the path map.'
        }
        foreach ($relativePath in $expectedPaths) {
            $generatedPath = Join-Path $tempRoot $relativePath
            $expectedPath = Join-Path $scriptRoot $relativePath
            $generatedBytes = [System.IO.File]::ReadAllBytes($generatedPath)
            $expectedBytes = [System.IO.File]::ReadAllBytes($expectedPath)
            if (-not [System.Linq.Enumerable]::SequenceEqual(
                    $generatedBytes,
                    $expectedBytes
                )) {
                throw "Generated manifest '$relativePath' is not byte-identical."
            }
        }
        Write-Output 'Manifest generation passed 271 byte-identical checks.'
    }
    finally {
        if ([System.IO.Directory]::Exists($tempRoot)) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Import-RewriteCommandModules {
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
        return
    }

    if (@(Get-Module -ListAvailable -Name CimCmdlets).Count -eq 0) {
        throw "Required Windows PowerShell module 'CimCmdlets' is unavailable."
    }
    Import-Module CimCmdlets -Force -ErrorAction Stop
}

function Assert-RewriteCommandMetadata {
    param([Parameter(Mandatory)] [string] $SymbolMapPath)

    $symbolMap = Import-PowerShellDataFile -LiteralPath $SymbolMapPath
    $requiredCommands = @(
        (
            @($symbolMap.Commands | ForEach-Object { [string] $_.NewName }) +
            @($symbolMap.Aliases | ForEach-Object { [string] $_.NewName })
        ) | Sort-Object -Unique
    )
    $missing = @(
        foreach ($name in $requiredCommands) {
            $commands = @(Get-Command `
                    -Name $name `
                    -CommandType Cmdlet `
                    -ListImported `
                    -ErrorAction SilentlyContinue)
            if ($commands.Count -ne 1) {
                $name
            }
        }
    )
    if ($missing.Count -gt 0) {
        throw (
            'Rewrite command metadata is incomplete for imported cmdlets: ' +
            ($missing -join ', ')
        )
    }
}

switch ($Task) {
    'Bootstrap' {
        $requiredModules = Import-PowerShellDataFile -LiteralPath $requiredModulesPath
        foreach ($moduleName in $requiredModules.Keys) {
            $requirement = $requiredModules[$moduleName]
            $version = Get-RequiredModuleVersion `
                -Requirement $requirement `
                -ModuleName $moduleName
            $installed = @(
                foreach ($module in @(Get-Module -ListAvailable -Name $moduleName)) {
                    if ($module.Version -eq $version) {
                        $module
                    }
                }
            )
            if ($installed.Count -eq 0) {
                Install-PinnedModule `
                    -ModuleName $moduleName `
                    -Requirement $requirement
            }
        }
    }
    'Validate' {
        Invoke-RepositoryValidation
        Invoke-MapValidation
        Invoke-ManifestValidation
    }
    'Analyze' {
        Invoke-RepositoryAnalyzer
    }
    'Test' {
        Invoke-RepositoryTests -EnableCoverage
    }
    'CheckFormat' {
        Invoke-FormatCheck
    }
    'ValidateRewrite' {
        foreach ($parameter in 'BaseRevision', 'PathMap', 'SymbolMap', 'ReportPath') {
            if ([string]::IsNullOrWhiteSpace((Get-Variable -Name $parameter -ValueOnly))) {
                throw "-$parameter is required when -Task ValidateRewrite is used."
            }
        }
        $resolvedPathMap = Resolve-RepositoryPath `
            -Path $PathMap `
            -Description '-PathMap'
        $resolvedSymbolMap = Resolve-RepositoryPath `
            -Path $SymbolMap `
            -Description '-SymbolMap'
        $resolvedReportPath = Resolve-RepositoryPath `
            -Path $ReportPath `
            -Description '-ReportPath'
        Import-RewriteCommandModules
        Assert-RewriteCommandMetadata -SymbolMapPath $resolvedSymbolMap
        & (Join-Path $repositoryRoot 'tools/Test-PowerShellRewrite.ps1') `
            -BaseRevision $BaseRevision `
            -PathMap $resolvedPathMap `
            -SymbolMap $resolvedSymbolMap `
            -ReportPath $resolvedReportPath
        $exitCode = $LASTEXITCODE
        if ($null -eq $exitCode) {
            $exitCode = 0
        }
        exit $exitCode
    }
}
