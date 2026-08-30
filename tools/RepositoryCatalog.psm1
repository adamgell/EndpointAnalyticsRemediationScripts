function Test-ManifestStatusTransition {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [ValidateSet('PendingMigration', 'Covered')] [string] $Before,
        [Parameter(Mandatory)] [ValidateSet('PendingMigration', 'Covered')] [string] $After
    )

    return -not ($Before -eq 'Covered' -and $After -eq 'PendingMigration')
}

function Test-ScriptManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [string] $SchemaPath
    )

    $schema = Import-PowerShellDataFile -Path $SchemaPath
    $manifest = Import-PowerShellDataFile -Path $Path
    $errors = [System.Collections.Generic.List[string]]::new()

    $requiredValues = [ordered]@{
        'SchemaVersion' = $manifest.SchemaVersion
        'Id' = $manifest.Id
        'Identity.PackageName' = $manifest.Identity.PackageName
        'Identity.ScriptName' = $manifest.Identity.ScriptName
        'Identity.Role' = $manifest.Identity.Role
        'Identity.Version' = $manifest.Identity.Version
        'Identity.Description' = $manifest.Identity.Description
        'Identity.Authors' = $manifest.Identity.Authors
        'Identity.Source' = $manifest.Identity.Source
        'Identity.Counterpart' = $manifest.Identity.Counterpart
        'Runtime.PowerShellVersion' = $manifest.Runtime.PowerShellVersion
        'Runtime.Architecture' = $manifest.Runtime.Architecture
        'Runtime.RunAs' = $manifest.Runtime.RunAs
        'Runtime.RequiresElevation' = $manifest.Runtime.RequiresElevation
        'Runtime.SignatureCheck' = $manifest.Runtime.SignatureCheck
        'Runtime.SupportedWindows' = $manifest.Runtime.SupportedWindows
        'Runtime.Reboot' = $manifest.Runtime.Reboot
        'Behavior.DetectionMode' = $manifest.Behavior.DetectionMode
        'Dependencies.Modules' = $manifest.Dependencies.Modules
        'Dependencies.Cmdlets' = $manifest.Dependencies.Cmdlets
        'Dependencies.Executables' = $manifest.Dependencies.Executables
        'Dependencies.Policies' = $manifest.Dependencies.Policies
        'Dependencies.Endpoints' = $manifest.Dependencies.Endpoints
        'Configuration' = $manifest.Configuration
        'Risk.Level' = $manifest.Risk.Level
        'Risk.Destructive' = $manifest.Risk.Destructive
        'Risk.UserImpact' = $manifest.Risk.UserImpact
        'Risk.Rollback' = $manifest.Risk.Rollback
        'Risk.DataHandling' = $manifest.Risk.DataHandling
        'Test.Categories' = $manifest.Test.Categories
        'Test.Status' = $manifest.Test.Status
        'Test.CoverageFloor' = $manifest.Test.CoverageFloor
        'Test.IntegrationLevel' = $manifest.Test.IntegrationLevel
        'Test.RequiresIntunePilot' = $manifest.Test.RequiresIntunePilot
        'Test.RequiresInteractiveUser' = $manifest.Test.RequiresInteractiveUser
    }

    foreach ($entry in $requiredValues.GetEnumerator()) {
        if ($null -eq $entry.Value) {
            $errors.Add("$($entry.Key) is required.")
            continue
        }

        if ($entry.Value -is [string] -and [string]::IsNullOrEmpty($entry.Value)) {
            $allowsEmptyValue = $entry.Key -eq 'Identity.Source' -or
            ($entry.Key -eq 'Identity.Counterpart' -and $manifest.Identity.Role -eq 'Detection')
            if (-not $allowsEmptyValue) {
                $errors.Add("$($entry.Key) is required.")
            }
        }
    }

    foreach ($setting in @($manifest.Configuration)) {
        foreach ($key in 'Name', 'Required', 'Secret', 'Description') {
            if (-not $setting.ContainsKey($key)) {
                $errors.Add("Configuration.*.$key is required.")
            }
        }
    }

    $booleanValues = @{
        'Runtime.RequiresElevation' = $manifest.Runtime.RequiresElevation
        'Risk.Destructive' = $manifest.Risk.Destructive
        'Test.RequiresIntunePilot' = $manifest.Test.RequiresIntunePilot
        'Test.RequiresInteractiveUser' = $manifest.Test.RequiresInteractiveUser
    }

    foreach ($entry in $booleanValues.GetEnumerator()) {
        if ($entry.Value -isnot [bool]) {
            $errors.Add("$($entry.Key) must be Boolean.")
        }
    }

    foreach ($setting in @($manifest.Configuration)) {
        if ($setting.Required -isnot [bool]) { $errors.Add('Configuration.*.Required must be Boolean.') }
        if ($setting.Secret -isnot [bool]) { $errors.Add('Configuration.*.Secret must be Boolean.') }
    }

    if ($manifest.Test.CoverageFloor -isnot [byte] -and
        $manifest.Test.CoverageFloor -isnot [int] -and
        $manifest.Test.CoverageFloor -isnot [long] -and
        $manifest.Test.CoverageFloor -isnot [single] -and
        $manifest.Test.CoverageFloor -isnot [double] -and
        $manifest.Test.CoverageFloor -isnot [decimal]) {
        $errors.Add('Test.CoverageFloor must be numeric.')
    }

    if ($manifest.SchemaVersion -ne $schema.SchemaVersion) { $errors.Add('SchemaVersion is unsupported.') }
    if ($manifest.Identity.Role -notin $schema.Enums.Role) { $errors.Add('Identity.Role is invalid.') }
    if ($manifest.Runtime.Architecture -notin $schema.Enums.Architecture) {
        $errors.Add('Runtime.Architecture is invalid.')
    }
    if ($manifest.Runtime.RunAs -notin $schema.Enums.RunAs) { $errors.Add('Runtime.RunAs is invalid.') }
    if ($manifest.Behavior.DetectionMode -notin $schema.Enums.DetectionMode) {
        $errors.Add('Behavior.DetectionMode is invalid.')
    }
    if ($manifest.Risk.Level -notin $schema.Enums.RiskLevel) { $errors.Add('Risk.Level is invalid.') }
    if ($manifest.Test.Status -notin $schema.Enums.TestStatus) { $errors.Add('Test.Status is invalid.') }
    if ($manifest.Runtime.SignatureCheck -notin $schema.Enums.SignatureCheck) {
        $errors.Add('Runtime.SignatureCheck is invalid.')
    }
    if ($manifest.Runtime.Reboot -notin $schema.Enums.Reboot) { $errors.Add('Runtime.Reboot is invalid.') }
    if ($manifest.Test.IntegrationLevel -notin $schema.Enums.IntegrationLevel) {
        $errors.Add('Test.IntegrationLevel is invalid.')
    }
    foreach ($category in @($manifest.Test.Categories)) {
        if ($category -notin $schema.Enums.TestCategory) { $errors.Add("Test category '$category' is invalid.") }
    }
    if ($manifest.Test.CoverageFloor -lt 0 -or $manifest.Test.CoverageFloor -gt 100) {
        $errors.Add('Test.CoverageFloor must be between 0 and 100.')
    }
    $parsedGuid = [guid]::Empty
    if (-not [guid]::TryParse([string] $manifest.Id, [ref] $parsedGuid)) {
        $errors.Add('Id must be a GUID.')
    }
    $parsedVersion = [version] '0.0'
    if (-not [version]::TryParse([string] $manifest.Identity.Version, [ref] $parsedVersion)) {
        $errors.Add('Identity.Version must be a semantic version.')
    }
    if ($manifest.Identity.Role -eq 'Detection' -and $manifest.Behavior.DetectionMode -eq 'NotApplicable') {
        $errors.Add('Detection scripts require an applicable DetectionMode.')
    }
    if ($manifest.Identity.Role -eq 'Remediation' -and $manifest.Behavior.DetectionMode -ne 'NotApplicable') {
        $errors.Add("Remediation scripts require DetectionMode 'NotApplicable'.")
    }

    [pscustomobject]@{
        Valid = $errors.Count -eq 0
        Errors = @($errors)
        Manifest = $manifest
    }
}

$script:InfrastructureDirectories = @(
    '.git', '.github', 'assets', 'docs', 'evidence', 'standards', 'tests', 'tools'
)

function Get-DeploymentScript {
    [CmdletBinding()]
    param([Parameter(Mandatory)] [string] $Root)

    foreach ($directory in Get-ChildItem -LiteralPath $Root -Directory) {
        if ($directory.Name -notin $script:InfrastructureDirectories) {
            Get-ChildItem -LiteralPath $directory.FullName -File -Filter '*.ps1'
        }
    }
}

function Get-ExtensionlessPowerShellCandidate {
    [CmdletBinding()]
    param([Parameter(Mandatory)] [string] $Root)

    foreach ($directory in Get-ChildItem -LiteralPath $Root -Directory) {
        if ($directory.Name -notin $script:InfrastructureDirectories) {
            Get-ChildItem -LiteralPath $directory.FullName -File |
                Where-Object Extension -EQ ''
        }
    }
}

function Get-UnresolvedRepositoryReference {
    [CmdletBinding()]
    param([Parameter(Mandatory)] [string] $Root)

    $linkPattern = [regex]'\[[^\]]+\]\((?<target>[^)#]+)(?:#[^)]+)?\)'
    foreach ($markdown in Get-ChildItem -LiteralPath $Root -Recurse -File -Include '*.md') {
        $content = Get-Content -LiteralPath $markdown.FullName -Raw
        foreach ($match in $linkPattern.Matches($content)) {
            $target = $match.Groups['target'].Value.Trim().Trim('<', '>')
            if ($target -match '^(?:https?|mailto):' -or $target.StartsWith('#')) { continue }
            $decoded = [uri]::UnescapeDataString($target)
            $resolved = Join-Path $markdown.DirectoryName $decoded
            if (-not (Test-Path -LiteralPath $resolved)) {
                [pscustomobject]@{ Markdown = $markdown.FullName; Target = $target }
            }
        }
    }
}

function Get-FoundationAbsolutePath {
    param(
        [Parameter(Mandatory)] [string] $Path,
        [string] $BasePath
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    if ([string]::IsNullOrEmpty($BasePath)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $BasePath $Path))
}

function Test-FoundationPathEquality {
    param(
        [Parameter(Mandatory)] [string] $Left,
        [Parameter(Mandatory)] [string] $Right
    )

    $comparison = if (
        [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT
    ) {
        [System.StringComparison]::OrdinalIgnoreCase
    }
    else {
        [System.StringComparison]::Ordinal
    }
    return [string]::Equals(
        [System.IO.Path]::GetFullPath($Left).TrimEnd('\', '/'),
        [System.IO.Path]::GetFullPath($Right).TrimEnd('\', '/'),
        $comparison
    )
}

function Resolve-FoundationValidatedGitContext {
    param(
        [Parameter(Mandatory)] [string] $GitDirectory,
        [Parameter(Mandatory)] [string] $WorkTree
    )

    if (
        -not (Test-Path -LiteralPath $GitDirectory -PathType Container) -or
        -not (Test-Path -LiteralPath $WorkTree -PathType Container)
    ) {
        return $null
    }

    $output = @(& git `
            "--git-dir=$GitDirectory" `
            "--work-tree=$WorkTree" `
            rev-parse `
            --absolute-git-dir `
            --show-toplevel 2>&1)
    if ($LASTEXITCODE -ne 0 -or $output.Count -lt 2) {
        return $null
    }

    $resolvedGitDirectory = [string] $output[0]
    $resolvedWorkTree = [string] $output[1]
    if (-not (Test-FoundationPathEquality -Left $resolvedWorkTree -Right $WorkTree)) {
        return $null
    }

    return [pscustomobject]@{
        GitDirectory = [System.IO.Path]::GetFullPath($resolvedGitDirectory)
        WorkTree = [System.IO.Path]::GetFullPath($resolvedWorkTree)
    }
}

function Resolve-FoundationNativeGitContext {
    param([Parameter(Mandatory)] [string] $RepositoryRoot)

    $originalGitDirectory = $env:GIT_DIR
    $originalGitWorkTree = $env:GIT_WORK_TREE
    try {
        $env:GIT_DIR = $null
        $env:GIT_WORK_TREE = $null
        $output = @(& git `
                -C $RepositoryRoot `
                rev-parse `
                --absolute-git-dir `
                --show-toplevel 2>&1)
        if ($LASTEXITCODE -ne 0 -or $output.Count -lt 2) {
            return $null
        }
    }
    finally {
        $env:GIT_DIR = $originalGitDirectory
        $env:GIT_WORK_TREE = $originalGitWorkTree
    }

    $resolvedGitDirectory = [string] $output[0]
    $resolvedWorkTree = [string] $output[1]
    if (-not (Test-FoundationPathEquality -Left $resolvedWorkTree -Right $RepositoryRoot)) {
        return $null
    }
    return Resolve-FoundationValidatedGitContext `
        -GitDirectory $resolvedGitDirectory `
        -WorkTree $resolvedWorkTree
}

function Resolve-FoundationRepositoryGitContext {
    param([Parameter(Mandatory)] [string] $RepositoryRoot)

    $repositoryRootPath = [System.IO.Path]::GetFullPath($RepositoryRoot)
    if (-not (Test-Path -LiteralPath $repositoryRootPath -PathType Container)) {
        throw "Repository root '$repositoryRootPath' does not exist."
    }

    $attempts = [System.Collections.Generic.List[string]]::new()
    if (-not [string]::IsNullOrWhiteSpace($env:GIT_DIR)) {
        try {
            $explicitGitDirectory = Get-FoundationAbsolutePath -Path $env:GIT_DIR
            $explicitWorkTree = if ([string]::IsNullOrWhiteSpace($env:GIT_WORK_TREE)) {
                $repositoryRootPath
            }
            else {
                Get-FoundationAbsolutePath -Path $env:GIT_WORK_TREE
            }
            $context = Resolve-FoundationValidatedGitContext `
                -GitDirectory $explicitGitDirectory `
                -WorkTree $explicitWorkTree
            if ($null -ne $context) {
                return $context
            }
            $attempts.Add('the explicit GIT_DIR and GIT_WORK_TREE values were unusable')
        }
        catch {
            $attempts.Add("the explicit Git environment was invalid: $($_.Exception.Message)")
        }
    }

    $gitPath = Join-Path $repositoryRootPath '.git'
    if (Test-Path -LiteralPath $gitPath -PathType Container) {
        $context = Resolve-FoundationValidatedGitContext `
            -GitDirectory $gitPath `
            -WorkTree $repositoryRootPath
        if ($null -ne $context) {
            return $context
        }
        $attempts.Add("the Git directory '$gitPath' was unusable")
    }
    elseif (Test-Path -LiteralPath $gitPath -PathType Leaf) {
        $pointer = [System.IO.File]::ReadAllText($gitPath).Trim()
        if ($pointer -notmatch '^gitdir:\s+(.+)$') {
            $attempts.Add("the Git pointer '$gitPath' was invalid")
        }
        else {
            try {
                $pointerDirectory = Get-FoundationAbsolutePath `
                    -Path $Matches[1] `
                    -BasePath (Split-Path $gitPath -Parent)
                $context = Resolve-FoundationValidatedGitContext `
                    -GitDirectory $pointerDirectory `
                    -WorkTree $repositoryRootPath
                if ($null -ne $context) {
                    return $context
                }
                $attempts.Add("the Git pointer target '$pointerDirectory' was unusable")
            }
            catch {
                $attempts.Add("the Git pointer '$gitPath' was unusable: $($_.Exception.Message)")
            }
        }
    }
    else {
        $attempts.Add("the repository has no '.git' directory or pointer")
    }

    $context = Resolve-FoundationNativeGitContext -RepositoryRoot $repositoryRootPath
    if ($null -ne $context) {
        return $context
    }
    $attempts.Add('Git-native rev-parse could not resolve this repository root')
    throw "Unable to resolve repository Git context: $($attempts -join '; ')."
}

function Get-FoundationTrackedPowerShellPath {
    param([Parameter(Mandatory)] [string] $RepositoryRoot)

    $context = Resolve-FoundationRepositoryGitContext -RepositoryRoot $RepositoryRoot
    $paths = @(& git `
            "--git-dir=$($context.GitDirectory)" `
            "--work-tree=$($context.WorkTree)" `
            ls-files `
            -- `
            '*.ps1' `
            '*.psm1' `
            '*.psd1' 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to enumerate tracked PowerShell files: $($paths -join [Environment]::NewLine)"
    }
    return $paths
}
Export-ModuleMember -Function @(
    'Test-ScriptManifest'
    'Test-ManifestStatusTransition'
    'Get-DeploymentScript'
    'Get-ExtensionlessPowerShellCandidate'
    'Get-UnresolvedRepositoryReference'
    'Resolve-FoundationRepositoryGitContext'
    'Get-FoundationTrackedPowerShellPath'
)
