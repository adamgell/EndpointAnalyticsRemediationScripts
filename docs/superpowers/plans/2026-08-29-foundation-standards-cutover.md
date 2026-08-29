# Foundation Standards Cutover Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Standardize every catalog path and nonbehavioral PowerShell style rule, add a typed sidecar manifest for every deployment script, and establish non-destructive Windows PowerShell 5.1 quality gates without changing detection or remediation behavior.

**Architecture:** The foundation has two independent validation lanes. Normal CI validates the current tree through inventory, manifests, parsing, formatting, references, PSScriptAnalyzer, and migration state. A cutover-only rewrite lane compares all 271 pre-cutover scripts to their mapped replacements using Windows PowerShell 5.1 AST, token, comment, here-string, dynamic-invocation, alias, and function-reference fingerprints; its fixed baseline retires after merge and remains only as evidence.

**Tech Stack:** Windows PowerShell 5.1, Pester 5.7.1, PSScriptAnalyzer 1.25.0, PowerShell data files (`.psd1`), GitHub Actions `windows-2022`, Git.

---

## Scope and invariants

This plan implements only the foundation described in `docs/superpowers/specs/2026-08-29-repository-standards-and-package-testing-design.md`. It does not refactor deployment logic into import-safe functions and does not add package behavioral tests. Those changes use later category and risk-batch plans.

The foundation must preserve these invariants:

- The baseline contains 271 runtime candidates: 269 `.ps1` files and two extensionless PowerShell files.
- The cutover contains 271 `.ps1` deployment scripts and 271 same-basename `.psd1` manifests.
- Every baseline runtime path maps to exactly one destination, and every destination has exactly one source.
- Existing multi-pair directories split into one deployment unit per pair without changing script content.
- Every manifest begins with `Test.Status = 'PendingMigration'` and numeric `Test.CoverageFloor = 0.0`.
- New scripts added after the foundation must begin as `Covered` and include behavioral tests.
- No catalog script is invoked, imported, or dot-sourced by a foundation command or CI job.
- The fixed pre-cutover baseline is used only by the cutover pull request.

## File structure

### Root quality interface

- Create `.editorconfig`: encoding, line endings, indentation, trailing whitespace, and final-newline policy.
- Create `.gitattributes`: Git text normalization and binary asset rules.
- Create `PSScriptAnalyzerSettings.psd1`: approved static and formatting rules.
- Create `build.ps1`: the supported `Bootstrap`, `Validate`, `Analyze`, `Test`, `CheckFormat`, and opt-in `ValidateRewrite` interface.
- Create `.github/workflows/powershell-quality.yml`: Windows PowerShell 5.1 quality workflow.

### Tooling and schemas

- Create `tools/RequiredModules.psd1`: exact Pester and PSScriptAnalyzer pins.
- Create `tools/RepositoryCatalog.psm1`: runtime inventory, package discovery, manifest loading, and schema validation.
- Create `tools/New-FoundationPathMap.ps1`: deterministic path-map generator with explicit split and rename data.
- Create `tools/New-FoundationSymbolMap.ps1`: parser-authoritative alias, cmdlet-casing, and approved-function mapping generator.
- Create `tools/Invoke-FoundationMove.ps1`: apply only the reviewed path map.
- Create `tools/New-ScriptManifest.ps1`: generate structurally typed sidecars from reviewed script metadata.
- Create `tools/Test-PowerShellRewrite.ps1`: cutover and later opt-in rewrite equivalence gate.
- Create `tools/RewriteEquivalence.psm1`: reusable AST, token, comment, symbol, and path comparison functions.
- Create `standards/ManifestSchema.psd1`: required keys, enums, scalar types, and migration transitions.
- Create `standards/FoundationPackages.psd1`: reviewed package renames, multi-pair splits, roles, counterparts, and per-script metadata.

### Tests and fixtures

- Create `tests/Repository.Tests.ps1`: current-tree inventory, paths, manifests, parsing, formatting, references, and migration-state gates.
- Create `tests/Manifest.Tests.ps1`: manifest schema and type tests.
- Create `tests/RewriteEquivalence.Tests.ps1`: rewrite-gate unit tests.
- Create `tests/TestHelpers.psm1`: isolated test-only helpers.
- Create `tests/fixtures/manifests/ValidDetection.psd1` and `InvalidQuotedScalars.psd1`.
- Create `tests/fixtures/rewrite/` fixture pairs for trivia, parser errors, aliases, functions, comments, here-strings, backticks, and dynamic calls.

### Persisted cutover evidence

- Create `evidence/foundation/BaseRevision.txt`.
- Create `evidence/foundation/PathMap.psd1`.
- Create `evidence/foundation/SymbolRenames.psd1`.
- Create `evidence/foundation/RewriteReport.json`.

### Documentation

- Create `CONTRIBUTING.md`.
- Create or update `AGENTS.md`.
- Modify `README.md`.
- Modify package README paths affected by the cutover.

---

### Task 1: Create the isolated foundation branch and freeze the baseline

**Files:**
- Create: `evidence/foundation/BaseRevision.txt`

- [ ] **Step 1: Create an isolated worktree before changing catalog files**

Run from the current repository:

```bash
git worktree add ../EndpointAnalyticsRemediationScripts-foundation -b feat/foundation-standards-cutover
git -C ../EndpointAnalyticsRemediationScripts-foundation rev-parse HEAD
```

Expected: the worktree is created from the approved design commit, and `rev-parse` prints one 40-character SHA.

- [ ] **Step 2: Record the exact pre-cutover revision**

Run in the foundation worktree:

```powershell
$baseRevision = (git rev-parse HEAD).Trim()
if ($baseRevision -notmatch '^[0-9a-f]{40}$') { throw 'Base revision is not a full Git SHA.' }
New-Item -ItemType Directory -Path evidence/foundation -Force | Out-Null
Set-Content -Path evidence/foundation/BaseRevision.txt -Value $baseRevision -Encoding ascii -NoNewline
```

Expected: `evidence/foundation/BaseRevision.txt` contains only the full SHA and no newline.

- [ ] **Step 3: Prove the baseline inventory before any move**

Run:

```powershell
$ps1 = @(Get-ChildItem -Path . -Recurse -File -Filter '*.ps1' | Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]|[\\/]docs[\\/]|[\\/]tests[\\/]|[\\/]tools[\\/]' })
$extensionless = @(
    Get-Item '0 - Template/Detect-Silverlight'
    Get-Item '0 - Template/Remediate_Silverlight'
)
if ($ps1.Count -ne 269) { throw "Expected 269 .ps1 files; found $($ps1.Count)." }
if ($extensionless.Count -ne 2) { throw "Expected 2 extensionless scripts; found $($extensionless.Count)." }
```

Expected: command exits `0` and prints no error.

- [ ] **Step 4: Commit the immutable baseline marker**

```bash
git add evidence/foundation/BaseRevision.txt
git commit -m "chore: record foundation cutover baseline"
```

Expected: one commit containing only the baseline marker.

### Task 2: Pin PowerShell quality modules and add bootstrap

**Files:**
- Create: `tools/RequiredModules.psd1`
- Create: `build.ps1`

- [ ] **Step 1: Create exact module pins**

Create `tools/RequiredModules.psd1`:

```powershell
@{
    Pester = @{
        Version    = '5.7.1'
        Repository = 'PSGallery'
    }
    PSScriptAnalyzer = @{
        Version    = '1.25.0'
        Repository = 'PSGallery'
    }
}
```

- [ ] **Step 2: Add the first executable build task**

Create `build.ps1` with only the working `Bootstrap` task at this stage:

```powershell
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
```

This script installs tooling only. It does not enumerate or execute catalog scripts.

- [ ] **Step 3: Run bootstrap under Windows PowerShell 5.1**

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1 -Task Bootstrap
powershell.exe -NoProfile -Command "Import-Module Pester -RequiredVersion 5.7.1; Import-Module PSScriptAnalyzer -RequiredVersion 1.25.0; Get-Module Pester,PSScriptAnalyzer | Select-Object Name,Version"
```

Expected: output lists `Pester 5.7.1` and `PSScriptAnalyzer 1.25.0`.

- [ ] **Step 4: Commit the reproducible bootstrap**

```bash
git add build.ps1 tools/RequiredModules.psd1
git commit -m "build: pin PowerShell quality tools"
```

### Task 3: Define and test the typed manifest schema

**Files:**
- Create: `standards/ManifestSchema.psd1`
- Create: `tools/RepositoryCatalog.psm1`
- Create: `tests/Manifest.Tests.ps1`
- Create: `tests/fixtures/manifests/ValidDetection.psd1`
- Create: `tests/fixtures/manifests/InvalidQuotedScalars.psd1`
- Modify: `build.ps1`

- [ ] **Step 1: Write manifest fixtures**

Create `tests/fixtures/manifests/ValidDetection.psd1` using the complete schema example from the approved design, with these concrete test values:

```powershell
@{
    SchemaVersion = '1.0'
    Id = '11111111-1111-1111-1111-111111111111'
    Identity = @{
        PackageName = 'Example-Package'
        ScriptName = 'Detect-Example-Package'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the example state.'
        Authors = @('Repository Test')
        Source = 'tests/fixtures/manifests/ValidDetection.psd1'
        Counterpart = ''
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('Windows 11')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Inventory' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-Item')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None'
        Rollback = 'Not required; detection only.'
        DataHandling = 'None'
    }
    Test = @{
        Categories = @('File')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'None'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
```

Create `tests/fixtures/manifests/InvalidQuotedScalars.psd1` with the same structure but these deliberately invalid fields:

```powershell
Runtime = @{ RequiresElevation = 'true' }
Risk = @{ Destructive = 'false' }
Test = @{
    CoverageFloor = '0.0'
    RequiresIntunePilot = 'false'
    RequiresInteractiveUser = 'false'
}
```

The invalid fixture must be a complete importable data file, not a fragment; copy the valid fixture and replace only those scalar values.

- [ ] **Step 2: Write failing schema tests**

Create `tests/Manifest.Tests.ps1`:

```powershell
BeforeAll {
    Import-Module "$PSScriptRoot/../tools/RepositoryCatalog.psm1" -Force
    $schemaPath = "$PSScriptRoot/../standards/ManifestSchema.psd1"
}

Describe 'Script manifest schema' {
    It 'accepts native boolean and numeric scalar types' {
        $result = Test-ScriptManifest `
            -Path "$PSScriptRoot/fixtures/manifests/ValidDetection.psd1" `
            -SchemaPath $schemaPath

        $result.Valid | Should -BeTrue
        $result.Errors | Should -BeNullOrEmpty
    }

    It 'rejects quoted booleans and coverage values' {
        $result = Test-ScriptManifest `
            -Path "$PSScriptRoot/fixtures/manifests/InvalidQuotedScalars.psd1" `
            -SchemaPath $schemaPath

        $result.Valid | Should -BeFalse
        $result.Errors | Should -Contain 'Runtime.RequiresElevation must be Boolean.'
        $result.Errors | Should -Contain 'Risk.Destructive must be Boolean.'
        $result.Errors | Should -Contain 'Test.CoverageFloor must be numeric.'
    }

    It 'rejects a Covered to PendingMigration transition' {
        Test-ManifestStatusTransition -Before Covered -After PendingMigration |
            Should -BeFalse
    }
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run:

```powershell
powershell.exe -NoProfile -Command "Invoke-Pester -Path tests/Manifest.Tests.ps1 -Output Detailed"
```

Expected: FAIL because `RepositoryCatalog.psm1` and schema functions do not exist.

- [ ] **Step 4: Implement the schema and validator**

Create `standards/ManifestSchema.psd1`:

```powershell
@{
    SchemaVersion = '1.0'
    Enums = @{
        Role = @('Detection', 'Remediation')
        Architecture = @('x64')
        RunAs = @('System', 'User', 'Either')
        SignatureCheck = @('Required', 'NotRequired', 'Either')
        Reboot = @('None', 'Possible', 'Required')
        DetectionMode = @('Compliance', 'AlwaysRemediate', 'Inventory', 'NotApplicable')
        RiskLevel = @('Low', 'Medium', 'High', 'Critical')
        TestStatus = @('PendingMigration', 'Covered')
        IntegrationLevel = @('None', 'WindowsVm', 'InteractiveWindows', 'IntunePilot')
        TestCategory = @('Registry', 'Service', 'File', 'Process', 'Network', 'Rest', 'Native', 'Appx', 'Ui', 'Destructive')
    }
    BooleanPaths = @(
        'Runtime.RequiresElevation'
        'Configuration.*.Required'
        'Configuration.*.Secret'
        'Risk.Destructive'
        'Test.RequiresIntunePilot'
        'Test.RequiresInteractiveUser'
    )
    NumericPaths = @('Test.CoverageFloor')
}
```

Create `tools/RepositoryCatalog.psm1` with these exported functions and exact contracts:

```powershell
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
    if ($manifest.Runtime.Architecture -notin $schema.Enums.Architecture) { $errors.Add('Runtime.Architecture is invalid.') }
    if ($manifest.Runtime.RunAs -notin $schema.Enums.RunAs) { $errors.Add('Runtime.RunAs is invalid.') }
    if ($manifest.Behavior.DetectionMode -notin $schema.Enums.DetectionMode) { $errors.Add('Behavior.DetectionMode is invalid.') }
    if ($manifest.Risk.Level -notin $schema.Enums.RiskLevel) { $errors.Add('Risk.Level is invalid.') }
    if ($manifest.Test.Status -notin $schema.Enums.TestStatus) { $errors.Add('Test.Status is invalid.') }
    if ($manifest.Runtime.SignatureCheck -notin $schema.Enums.SignatureCheck) { $errors.Add('Runtime.SignatureCheck is invalid.') }
    if ($manifest.Runtime.Reboot -notin $schema.Enums.Reboot) { $errors.Add('Runtime.Reboot is invalid.') }
    if ($manifest.Test.IntegrationLevel -notin $schema.Enums.IntegrationLevel) { $errors.Add('Test.IntegrationLevel is invalid.') }
    foreach ($category in @($manifest.Test.Categories)) {
        if ($category -notin $schema.Enums.TestCategory) { $errors.Add(\"Test category '$category' is invalid.\") }
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
        $errors.Add(\"Remediation scripts require DetectionMode 'NotApplicable'.\")
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

Export-ModuleMember -Function @(
    'Test-ScriptManifest'
    'Test-ManifestStatusTransition'
    'Get-DeploymentScript'
    'Get-ExtensionlessPowerShellCandidate'
    'Get-UnresolvedRepositoryReference'
)
```

Before the scalar and enum checks, add this exact required-path validation:

```powershell
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
        $errors.Add(\"$($entry.Key) is required.\")
    }
}

foreach ($setting in @($manifest.Configuration)) {
    foreach ($key in 'Name', 'Required', 'Secret', 'Description') {
        if (-not $setting.ContainsKey($key)) {
            $errors.Add(\"Configuration.*.$key is required.\")
        }
    }
}
```

Validate every enum declared in `ManifestSchema.psd1`, validate `Id` with `[guid]::TryParse`, and validate `Identity.Version` with `[version]::TryParse`. Empty strings are allowed only for `Identity.Source` and detection-only `Identity.Counterpart`.

- [ ] **Step 5: Run manifest tests**

Run:

```powershell
powershell.exe -NoProfile -Command "Invoke-Pester -Path tests/Manifest.Tests.ps1 -Output Detailed"
```

Expected: all manifest tests PASS.

- [ ] **Step 6: Commit schema enforcement**

```bash
git add standards/ManifestSchema.psd1 tools/RepositoryCatalog.psm1 tests/Manifest.Tests.ps1 tests/fixtures/manifests
git commit -m "test: enforce typed script manifests"
```

### Task 4: Build the cutover rewrite-equivalence gate test-first

**Files:**
- Create: `tools/RewriteEquivalence.psm1`
- Create: `tools/Test-PowerShellRewrite.ps1`
- Create: `tests/RewriteEquivalence.Tests.ps1`
- Create: `tests/fixtures/rewrite/*`
- Modify: `build.ps1`

- [ ] **Step 1: Create focused rewrite fixtures**

Create fixture pairs with these exact observable differences:

- `Trivia.Before.ps1` and `Trivia.After.ps1`: indentation, LF, trailing whitespace, and same-line brace changes only.
- `ParserError.Before.ps1` and `ParserError.After.ps1`: the after file omits a closing brace.
- `Alias.Before.ps1`: `Get-Process | ? Name -EQ 'explorer'`; `Alias.After.ps1`: `Get-Process | Where-Object Name -EQ 'explorer'`.
- `Function.Before.ps1`: defines and calls `IsMember`; `Function.After.ps1`: defines and calls `Test-GroupMembership` with an otherwise identical body.
- `Backtick.Before.ps1`: a multi-line command using a backtick; `Backtick.After.ps1`: changes the continuation's neighboring parameter.
- `Comment.Before.ps1`: `Get-Item . | Out-Null #-Force`; `Comment.After.ps1`: moves `#-Force` before `Out-Null`.
- `HereString.Before.ps1` and `HereString.After.ps1`: differ inside the here-string body.
- `Dynamic.Before.ps1` and `Dynamic.After.ps1`: change `& $tool --check` to `& $otherTool --check`.

- [ ] **Step 2: Write failing gate tests**

Create `tests/RewriteEquivalence.Tests.ps1` with one `It` per invariant:

```powershell
BeforeAll {
    Import-Module \"$PSScriptRoot/../tools/RewriteEquivalence.psm1\" -Force
    $fixtureRoot = \"$PSScriptRoot/fixtures/rewrite\"
}

Describe 'PowerShell rewrite equivalence' {
    It 'accepts trivia-only formatting with identical AST and semantic tokens' {
        $result = Compare-PowerShellSource -BeforePath \"$fixtureRoot/Trivia.Before.ps1\" -AfterPath \"$fixtureRoot/Trivia.After.ps1\"
        $result.Passed | Should -BeTrue
    }

    It 'rejects a parser error on either side' {
        $result = Compare-PowerShellSource -BeforePath \"$fixtureRoot/ParserError.Before.ps1\" -AfterPath \"$fixtureRoot/ParserError.After.ps1\"
        $result.Passed | Should -BeFalse
        $result.Failures | Should -Contain 'After source contains parser errors.'
    }

    It 'accepts an alias only through an explicit canonical-command map' {
        $map = @{ Aliases = @(@{ OldName = '?'; NewName = 'Where-Object'; Occurrence = 1 }); Functions = @() }
        $result = Compare-PowerShellSource -BeforePath \"$fixtureRoot/Alias.Before.ps1\" -AfterPath \"$fixtureRoot/Alias.After.ps1\" -SymbolMap $map
        $result.Passed | Should -BeTrue
    }

    It 'accepts a function rename only when definition and all static callsites map' {
        $map = @{ Aliases = @(); Functions = @(@{ OldName = 'IsMember'; NewName = 'Test-GroupMembership' }) }
        $result = Compare-PowerShellSource -BeforePath \"$fixtureRoot/Function.Before.ps1\" -AfterPath \"$fixtureRoot/Function.After.ps1\" -SymbolMap $map
        $result.Passed | Should -BeTrue
    }

    It 'rejects a changed backtick continuation neighbor' {
        (Compare-PowerShellSource -BeforePath \"$fixtureRoot/Backtick.Before.ps1\" -AfterPath \"$fixtureRoot/Backtick.After.ps1\").Passed | Should -BeFalse
    }

    It 'rejects movement of a pipeline-adjacent comment' {
        (Compare-PowerShellSource -BeforePath \"$fixtureRoot/Comment.Before.ps1\" -AfterPath \"$fixtureRoot/Comment.After.ps1\").Passed | Should -BeFalse
    }

    It 'rejects a changed here-string value' {
        (Compare-PowerShellSource -BeforePath \"$fixtureRoot/HereString.Before.ps1\" -AfterPath \"$fixtureRoot/HereString.After.ps1\").Passed | Should -BeFalse
    }

    It 'rejects a changed dynamic invocation target' {
        (Compare-PowerShellSource -BeforePath \"$fixtureRoot/Dynamic.Before.ps1\" -AfterPath \"$fixtureRoot/Dynamic.After.ps1\").Passed | Should -BeFalse
    }

    It 'rejects a path map that is not a total bijection' {
        $rows = @(
            @{ BasePath = 'A.ps1'; NewPath = 'One.ps1' }
            @{ BasePath = 'B.ps1'; NewPath = 'One.ps1' }
        )
        Test-PathMapBijection -Rows $rows -ExpectedCount 2 | Should -BeFalse
    }
}
```

These tests call exported functions in `tools/RewriteEquivalence.psm1`; the wrapper script is tested separately with a two-file Git fixture and its JSON report.

- [ ] **Step 3: Run tests to verify they fail**

Run:

```powershell
powershell.exe -NoProfile -Command "Invoke-Pester -Path tests/RewriteEquivalence.Tests.ps1 -Output Detailed"
```

Expected: FAIL because the rewrite tool does not exist.

- [ ] **Step 4: Implement the fail-closed comparator**

Implement `tools/RewriteEquivalence.psm1` and a thin `tools/Test-PowerShellRewrite.ps1` wrapper. The wrapper has these mandatory parameters:

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $BaseRevision,
    [Parameter(Mandatory)] [string] $PathMap,
    [Parameter(Mandatory)] [string] $SymbolMap,
    [Parameter(Mandatory)] [string] $ReportPath
)
```

Export these functions from `tools/RewriteEquivalence.psm1`:

```powershell
Compare-PowerShellSource
Test-PathMapBijection
```

Keep these helpers private to the module:

```powershell
ConvertFrom-ScriptBytes
Get-ParsedScript
Get-AstShapeFingerprint
Get-SemanticTokenFingerprint
Get-CommentAnchorFingerprint
Get-HereStringFingerprint
Get-LineContinuationFingerprint
Get-DynamicInvocationFingerprint
Resolve-AliasMapping
Test-FunctionRenameMapping
New-RewriteReportRow
```

The wrapper alone implements `Resolve-FullGitRevision` and `Get-GitBlobBytes`, imports the module, validates the full inventory map, calls `Compare-PowerShellSource` for every pair, writes stable JSON, and sets the process exit code.

Implement the comparison algorithm from the approved design, including:

- Full 40-character base SHA resolution.
- Total source/destination inventory equality.
- Windows PowerShell 5.1 parser errors on both sides.
- Ordered AST node type, parent index, and child order.
- Token kind, flags, value, and order after only approved normalization.
- Comment text and semantic-token anchors.
- Help association and help keyword structure.
- Here-string kind, mode, value, and delimiters.
- Backtick continuation tokens and neighboring semantic tokens.
- Dynamic invocation operator, target, arguments, and redirections.
- Alias resolution to one canonical command.
- Function definition, parameter/body fingerprint, and static callsite bijection.
- No unresolved old symbol in strings, dynamic targets, manifests, or Markdown.
- Stable JSON output sorted by destination path.

The script exits `0` only when every report row passes and exits `1` for every unclassified or partial comparison.

- [ ] **Step 5: Run gate tests**

Run:

```powershell
powershell.exe -NoProfile -Command "Invoke-Pester -Path tests/RewriteEquivalence.Tests.ps1 -Output Detailed"
```

Expected: all rewrite-equivalence tests PASS.

- [ ] **Step 6: Add the opt-in build task**

Extend `build.ps1` to accept `ValidateRewrite`, `BaseRevision`, `PathMap`, `SymbolMap`, and `ReportPath`. The `ValidateRewrite` branch calls `tools/Test-PowerShellRewrite.ps1` with those values. It does not run for any other task.

- [ ] **Step 7: Commit the reusable rewrite gate**

```bash
git add build.ps1 tools/RewriteEquivalence.psm1 tools/Test-PowerShellRewrite.ps1 tests/RewriteEquivalence.Tests.ps1 tests/fixtures/rewrite
git commit -m "test: add PowerShell rewrite equivalence gate"
```

### Task 5: Generate and review the complete package and path map

**Files:**
- Create: `standards/FoundationPackages.psd1`
- Create: `tools/New-FoundationPathMap.ps1`
- Create: `tools/New-FoundationSymbolMap.ps1`
- Create: `evidence/foundation/PathMap.psd1`
- Create: `evidence/foundation/SymbolRenames.psd1`
- Test: `tests/Repository.Tests.ps1`

- [ ] **Step 1: Write a failing path-map inventory test**

Add to `tests/Repository.Tests.ps1`:

```powershell
Describe 'Foundation path map' {
    BeforeAll {
        $map = Import-PowerShellDataFile "$PSScriptRoot/../evidence/foundation/PathMap.psd1"
    }

    It 'maps all 271 baseline runtime candidates exactly once' {
        @($map.Paths).Count | Should -Be 271
        @($map.Paths.BasePath | Sort-Object -Unique).Count | Should -Be 271
        @($map.Paths.NewPath | Sort-Object -Unique).Count | Should -Be 271
    }

    It 'maps every destination to a ps1 file with a standard basename' {
        $invalid = $map.Paths.NewPath | Where-Object {
            $_ -notmatch '/(Detect|Remediate)-[A-Z][A-Za-z0-9]*(?:-[A-Z0-9][A-Za-z0-9]*)*\.ps1$'
        }
        $invalid | Should -BeNullOrEmpty
    }
}
```

Run the test and expect FAIL because the map does not exist.

- [ ] **Step 2: Encode explicit package renames and multi-pair splits**

Create `standards/FoundationPackages.psd1`. Use identity mappings for already-valid package directories. Include these explicit canonicalizations:

```powershell
PackageRenames = @{
    'Detect-AdminUsers' = 'Admin-Users'
    'Detect-Autologon' = 'Autologon'
    'Detect-BlueScreenHistory' = 'Blue-Screen-History'
    'Detect-Browser-Passwords' = 'Browser-Passwords'
    'Detect-CertificateExpiry' = 'Certificate-Expiry'
    'Detect-DriverIssues' = 'Driver-Issues'
    'Detect-SCCM' = 'SCCM'
    'Detect-SuspiciousScheduledTasks' = 'Suspicious-Scheduled-Tasks'
    'Detect-VPNSplitTunnel' = 'VPN-Split-Tunnel'
    'Device Auto-Syncer' = 'Device-Auto-Syncer'
    'Get-AdobeDC_Java' = 'Get-AdobeDC-Java'
    'Get-AdobeReader_Flash' = 'Get-AdobeReader-Flash'
    'Get-Always_Elevated' = 'Get-Always-Elevated'
    'Get-DeviceUptime_and_Reboot' = 'Get-Device-Uptime-And-Reboot'
    'Get-TimeZone_W_Europe' = 'Get-TimeZone-W-Europe'
    'OneDrive Folder - Always Offline' = 'OneDrive-Folder-Always-Offline'
    'Profile-cleanup' = 'Profile-Cleanup'
    'Remove Teams Chat' = 'Remove-Teams-Chat'
    'Reset Windows Update' = 'Reset-Windows-Update'
    'Uninstall-C++2010' = 'Uninstall-Visual-Cpp-2010'
    'Unpin Store' = 'Unpin-Store'
}
```

Encode these explicit split units:

```powershell
SplitPackages = @(
    @{ SourcePackage = '0 - Template'; DestinationPackage = 'Remove-New-Outlook'; Detection = 'detection_Get-TemplateDetection.ps1'; Remediation = 'remediation_Get-TemplateRemediaton.ps1' }
    @{ SourcePackage = '0 - Template'; DestinationPackage = 'Remove-Silverlight'; Detection = 'Detect-Silverlight'; Remediation = 'Remediate_Silverlight' }
    @{ SourcePackage = 'Create-LocalAdmin'; DestinationPackage = 'Create-LocalAdmin'; Detection = 'detection_Create-LocalAdminDetection.ps1'; Remediation = 'remediation_Create-LocalAdminRemediation.ps1' }
    @{ SourcePackage = 'Create-LocalAdmin'; DestinationPackage = 'Create-Laps-LocalAdmin'; Detection = 'detection_Create-LocalAdminLAPSDetection.ps1'; Remediation = 'remediation_Create-LocalAdminLAPSRemediation.ps1' }
    @{ SourcePackage = 'Create-LocalAdmin'; DestinationPackage = 'Delete-LocalAdmin'; Detection = 'detection_Delete-LocalAdminDetection.ps1'; Remediation = 'remediation_Delete-LocalAdminRemediation.ps1' }
    @{ SourcePackage = 'Enable-DeliveryOptimizationVerboseLogging'; DestinationPackage = 'Disable-Delivery-Optimization-Verbose-Logging'; Detection = 'detection_Disable-VerboseLoggingDetection.ps1'; Remediation = 'remediation_Disable-VerboseLoggingRemedaiton.ps1' }
    @{ SourcePackage = 'Enable-DeliveryOptimizationVerboseLogging'; DestinationPackage = 'Enable-Delivery-Optimization-Verbose-Logging'; Detection = 'detection_Enable-VerboseLoggingDetection.ps1'; Remediation = 'remediation_Enable-VerboseLoggingRemedaiton.ps1' }
    @{ SourcePackage = 'Winget Management'; DestinationPackage = 'Install-WinGet-Apps-From-Url'; Detection = 'detection_detect-install-url-changes.ps1'; Remediation = 'remediation_remediate-install-apps-from-url.ps1' }
    @{ SourcePackage = 'Winget Management'; DestinationPackage = 'Uninstall-WinGet-Apps-From-Url'; Detection = 'detection_detect-uninstall-url-changes.ps1'; Remediation = 'remediation_remediate-uninstall-apps-from-url.ps1' }
)
```

Verify these source filenames against the repository before accepting the data file. A mismatch is a planning defect and must be corrected in the data file, not ignored by the generator.

- [ ] **Step 3: Generate deterministic destinations**

Implement `tools/New-FoundationPathMap.ps1` so ordinary packages use their canonical package directory and map role-prefixed files to:

```text
<CanonicalPackage>/Detect-<CanonicalPackage>.ps1
<CanonicalPackage>/Remediate-<CanonicalPackage>.ps1
```

The three legacy discovery forms are explicit inputs:

```text
0 - Template/Detect-Silverlight             -> Remove-Silverlight/Detect-Remove-Silverlight.ps1
0 - Template/Remediate_Silverlight          -> Remove-Silverlight/Remediate-Remove-Silverlight.ps1
Detect-Browser-Passwords/Detect-Browser-Passwords.ps1 -> Browser-Passwords/Detect-Browser-Passwords.ps1
```

The generator must reject unclassified scripts, duplicate roles within an unsplit package, destination collisions, invalid package regex, and any result other than 271 rows.

- [ ] **Step 4: Generate and review the map**

Run:

```powershell
powershell.exe -NoProfile -File .\tools\New-FoundationPathMap.ps1 `
    -PackageData .\standards\FoundationPackages.psd1 `
    -OutputPath .\evidence\foundation\PathMap.psd1
```

Expected: 271 mappings, every destination ends in `.ps1`, and the two extensionless inputs map correctly.

- [ ] **Step 5: Record exact symbol mappings**

Add these reviewed alias and function rows to `standards/FoundationPackages.psd1`:

```powershell
AliasMappings = @(
    @{ Path = 'Toast-RebootMessage/Remediate-Toast-RebootMessage.ps1'; OldName = 'Where'; NewName = 'Where-Object'; Occurrence = 1 }
    @{ Path = 'Toast-RebootMessage/Remediate-Toast-RebootMessage.ps1'; OldName = 'Where'; NewName = 'Where-Object'; Occurrence = 2 }
    @{ Path = 'Check-DiskHealth/Detect-Check-DiskHealth.ps1'; OldName = '?'; NewName = 'Where-Object'; Occurrence = 1 }
    @{ Path = 'Device-Auto-Syncer/Remediate-Device-Auto-Syncer.ps1'; OldName = '?'; NewName = 'Where-Object'; Occurrence = 1 }
    @{ Path = 'Clear-TeamsCache/Remediate-Clear-TeamsCache.ps1'; OldName = 'echo'; NewName = 'Write-Output'; Occurrence = 1 }
    @{ Path = 'Clear-TeamsCache/Remediate-Clear-TeamsCache.ps1'; OldName = 'echo'; NewName = 'Write-Output'; Occurrence = 2 }
    @{ Path = 'Get-CleanUpDisk/Detect-Get-CleanUpDisk.ps1'; OldName = 'Where'; NewName = 'Where-Object'; Occurrence = 1 }
    @{ Path = 'Get-ConnectedDevices/Detect-Get-ConnectedDevices.ps1'; OldName = '%'; NewName = 'ForEach-Object'; Occurrence = 1 }
    @{ Path = 'Remove-ConsumerApps/Detect-Remove-ConsumerApps.ps1'; OldName = 'Where'; NewName = 'Where-Object'; Occurrence = 1 }
    @{ Path = 'Remove-ConsumerApps/Remediate-Remove-ConsumerApps.ps1'; OldName = 'Where'; NewName = 'Where-Object'; Occurrence = 1 }
    @{ Path = 'Remove-ConsumerApps/Remediate-Remove-ConsumerApps.ps1'; OldName = 'Where'; NewName = 'Where-Object'; Occurrence = 2 }
    @{ Path = 'Run-Browser/Remediate-Run-Browser.ps1'; OldName = 'Start'; NewName = 'Start-Process'; Occurrence = 1 }
)

FunctionMappings = @(
    @{ Path = 'Enable-RDP/Detect-Enable-RDP.ps1'; OldName = 'IsMember'; NewName = 'Test-GroupMembership' }
    @{ Path = 'Enable-RDP/Remediate-Enable-RDP.ps1'; OldName = 'IsMember'; NewName = 'Test-GroupMembership' }
    @{ Path = 'Get-Device-Uptime-And-Reboot/Remediate-Get-Device-Uptime-And-Reboot.ps1'; OldName = 'Display-ToastNotification'; NewName = 'Show-ToastNotification' }
    @{ Path = 'Make-Speedtest/Remediate-Make-Speedtest.ps1'; OldName = 'Build-Signature'; NewName = 'New-LogAnalyticsSignature' }
    @{ Path = 'Make-Speedtest/Remediate-Make-Speedtest.ps1'; OldName = 'Post-LogAnalyticsData'; NewName = 'Send-LogAnalyticsData' }
)
```

Run the parser-authoritative generator:

```powershell
powershell.exe -NoProfile -File .\tools\New-FoundationSymbolMap.ps1 `
    -PathMap .\evidence\foundation\PathMap.psd1 `
    -PackageData .\standards\FoundationPackages.psd1 `
    -OutputPath .\evidence\foundation\SymbolRenames.psd1
```

The generated file contains `Commands`, `Aliases`, and `Functions` arrays sorted by destination path and occurrence. `Commands` contains every cmdlet whose source casing differs from the canonical Windows PowerShell 5.1 command name. The expected alias aggregate is 12 occurrences across 9 files, and the expected function aggregate is 5 definitions with all static callsites resolved.

- [ ] **Step 6: Run map tests**

Run:

```powershell
powershell.exe -NoProfile -Command "Invoke-Pester -Path tests/Repository.Tests.ps1 -Output Detailed -Tag FoundationMap"
```

Expected: all path-map and symbol-map tests PASS.

- [ ] **Step 7: Commit reviewed cutover maps**

```bash
git add standards/FoundationPackages.psd1 tools/New-FoundationPathMap.ps1 tools/New-FoundationSymbolMap.ps1 evidence/foundation/PathMap.psd1 evidence/foundation/SymbolRenames.psd1 tests/Repository.Tests.ps1
git commit -m "chore: define foundation package path map"
```

### Task 6: Apply the clean path cutover

**Files:**
- Create: `tools/Invoke-FoundationMove.ps1`
- Move: all 271 runtime candidates according to `evidence/foundation/PathMap.psd1`
- Remove: empty legacy package directories
- Modify: all Markdown path references

- [ ] **Step 1: Write failing post-cutover inventory tests**

Add tests that require:

```powershell
BeforeAll {
    Import-Module \"$PSScriptRoot/../tools/RepositoryCatalog.psm1\" -Force
    $repoRoot = (Resolve-Path \"$PSScriptRoot/..\").Path
    $pathMap = Import-PowerShellDataFile \"$repoRoot/evidence/foundation/PathMap.psd1\"
}

Describe 'Post-cutover repository inventory' {
    It 'contains exactly 271 standard ps1 deployment scripts' {
        $scripts = @(Get-DeploymentScript -Root $repoRoot)
        $scripts.Count | Should -Be 271
        $invalid = $scripts | Where-Object {
            $_.Name -notmatch '^(Detect|Remediate)-[A-Z][A-Za-z0-9]*(?:-[A-Z0-9][A-Za-z0-9]*)*\\.ps1$'
        }
        $invalid | Should -BeNullOrEmpty
    }

    It 'contains no extensionless PowerShell candidates' {
        @(Get-ExtensionlessPowerShellCandidate -Root $repoRoot) | Should -BeNullOrEmpty
    }

    It 'contains no lowercase legacy role prefixes' {
        $legacy = Get-ChildItem -Path $repoRoot -Recurse -File |
            Where-Object Name -Match '^(detection_|remediation_)'
        $legacy | Should -BeNullOrEmpty
    }

    It 'contains no legacy script path from the path map' {
        $remaining = $pathMap.Paths.BasePath | Where-Object {
            Test-Path -LiteralPath (Join-Path $repoRoot $_)
        }
        $remaining | Should -BeNullOrEmpty
    }

    It 'resolves every Markdown repository reference' {
        @(Get-UnresolvedRepositoryReference -Root $repoRoot) | Should -BeNullOrEmpty
    }
}
```

Run and expect FAIL on the legacy tree.

- [ ] **Step 2: Implement the map-only mover**

`tools/Invoke-FoundationMove.ps1` must:

- Import the reviewed path map.
- Refuse a dirty working tree outside known foundation files.
- Create destination directories.
- Use `git mv` for tracked files and ordinary move for untracked files.
- Verify the source byte hash after the move matches the pre-move hash.
- Reject any destination that already exists.
- Remove only directories made empty by mapped moves.
- Never edit file content.

- [ ] **Step 3: Apply all moves once**

Run:

```powershell
powershell.exe -NoProfile -File .\tools\Invoke-FoundationMove.ps1 `
    -PathMap .\evidence\foundation\PathMap.psd1
```

Expected: exactly 271 moved scripts and no content-hash changes.

- [ ] **Step 4: Update repository references through the same path map**

Update `README.md`, `AGENTS.md`, package READMEs, and the design documents. Resolve Markdown links against the destination path set. Do not rewrite external URLs that do not target this repository.

- [ ] **Step 5: Run inventory tests**

Run:

```powershell
powershell.exe -NoProfile -Command "Invoke-Pester -Path tests/Repository.Tests.ps1 -Output Detailed"
```

Expected: path and reference tests PASS; manifest tests still fail because sidecars are not created yet.

- [ ] **Step 6: Commit only the path cutover**

```bash
git add -A
git commit -m "refactor: standardize package and script paths"
```

### Task 7: Generate and curate all 271 script manifests

**Files:**
- Create: `tools/New-ScriptManifest.ps1`
- Create: one same-basename `.psd1` beside every deployment `.ps1`
- Modify: `standards/FoundationPackages.psd1`
- Test: `tests/Manifest.Tests.ps1`

- [ ] **Step 1: Add failing catalog-wide manifest tests**

Require:

```powershell
BeforeAll {
    Import-Module \"$PSScriptRoot/../tools/RepositoryCatalog.psm1\" -Force
    $repoRoot = (Resolve-Path \"$PSScriptRoot/..\").Path
    $schemaPath = \"$repoRoot/standards/ManifestSchema.psd1\"
    $scripts = @(Get-DeploymentScript -Root $repoRoot)
}

Describe 'Catalog script manifests' {
    It 'pairs every ps1 with one same-basename psd1' {
        $missing = $scripts | Where-Object {
            -not (Test-Path -LiteralPath ([IO.Path]::ChangeExtension($_.FullName, '.psd1')))
        }
        $missing | Should -BeNullOrEmpty
    }

    It 'validates every sidecar against ManifestSchema.psd1' {
        $invalid = foreach ($script in $scripts) {
            $path = [IO.Path]::ChangeExtension($script.FullName, '.psd1')
            $result = Test-ScriptManifest -Path $path -SchemaPath $schemaPath
            if (-not $result.Valid) { [pscustomobject]@{ Path = $path; Errors = $result.Errors } }
        }
        $invalid | Should -BeNullOrEmpty
    }

    It 'uses native scalar types in every sidecar' {
        foreach ($script in $scripts) {
            $manifest = Import-PowerShellDataFile ([IO.Path]::ChangeExtension($script.FullName, '.psd1'))
            $manifest.Runtime.RequiresElevation | Should -BeOfType [bool]
            $manifest.Risk.Destructive | Should -BeOfType [bool]
            $manifest.Test.CoverageFloor | Should -BeOfType [double]
            $manifest.Test.RequiresIntunePilot | Should -BeOfType [bool]
            $manifest.Test.RequiresInteractiveUser | Should -BeOfType [bool]
        }
    }

    It 'uses immutable unique GUIDs for all 271 script IDs' {
        $ids = foreach ($script in $scripts) {
            $manifest = Import-PowerShellDataFile ([IO.Path]::ChangeExtension($script.FullName, '.psd1'))
            ([guid] $manifest.Id).Guid
        }
        $ids.Count | Should -Be 271
        @($ids | Sort-Object -Unique).Count | Should -Be 271
    }

    It 'starts every existing script at PendingMigration and numeric zero coverage' {
        foreach ($script in $scripts) {
            $manifest = Import-PowerShellDataFile ([IO.Path]::ChangeExtension($script.FullName, '.psd1'))
            $manifest.Test.Status | Should -Be 'PendingMigration'
            $manifest.Test.CoverageFloor | Should -Be 0.0
        }
    }

    It 'uses symmetric counterpart paths for paired scripts' {
        foreach ($script in $scripts) {
            $manifest = Import-PowerShellDataFile ([IO.Path]::ChangeExtension($script.FullName, '.psd1'))
            if ($manifest.Identity.Counterpart) {
                $counterpartPath = Join-Path $repoRoot $manifest.Identity.Counterpart
                Test-Path -LiteralPath $counterpartPath | Should -BeTrue
                $counterpart = Import-PowerShellDataFile ([IO.Path]::ChangeExtension($counterpartPath, '.psd1'))
                $counterpart.Identity.Counterpart | Should -Be ($script.FullName.Substring($repoRoot.Length + 1) -replace '\\\\', '/')
            }
        }
    }

    It 'does not store secret values in manifests' {
        foreach ($script in $scripts) {
            $manifest = Import-PowerShellDataFile ([IO.Path]::ChangeExtension($script.FullName, '.psd1'))
            foreach ($setting in @($manifest.Configuration | Where-Object Secret)) {
                $setting.ContainsKey('Value') | Should -BeFalse
            }
        }
    }
}
```

Run and expect FAIL because no catalog manifests exist.

- [ ] **Step 2: Implement deterministic structural generation**

`tools/New-ScriptManifest.ps1` must derive only facts that are mechanically certain:

- `Id`: UUIDv5 derived from the original pre-cutover repository-relative path and a repository namespace GUID stored in `standards/FoundationPackages.psd1`.
- Package name, script name, role, counterpart, and source path: from the reviewed path map.
- PowerShell version `5.1`, architecture `x64`, status `PendingMigration`, and coverage `0.0`: from the approved standard.
- Version, description, authors, run identity, signature expectation, supported Windows versions, reboot behavior, dependencies, configuration, risk, and integration evidence: from reviewed `standards/FoundationPackages.psd1` metadata, never from silent defaults.

The generator exits nonzero if any required metadata field is absent. It rejects sentinel metadata, empty required descriptions, quoted booleans, and quoted numeric values.

- [ ] **Step 3: Audit manifest metadata in parallel read-only batches**

Assign nonoverlapping top-level package ranges to research agents. Each agent returns exact metadata for every script in its range with source-line evidence. Use these ranges:

```text
0 through Clear-*
Collect-* through Get-ConnectedDevices
Get-Device* through Invoke-*
Make-* through Remove-ConsumerApps
Remove-ProxySettings through Reset-*
Restart-* through Uninstall-*
Unpin-* through Winget-*
```

An integration owner merges results into `standards/FoundationPackages.psd1` and rejects conflicting or unsupported claims. Runtime identity, destructive risk, secrets, external endpoints, and reboot behavior require explicit evidence.

- [ ] **Step 4: Generate sidecars**

Run:

```powershell
powershell.exe -NoProfile -File .\tools\New-ScriptManifest.ps1 `
    -PathMap .\evidence\foundation\PathMap.psd1 `
    -Metadata .\standards\FoundationPackages.psd1 `
    -Schema .\standards\ManifestSchema.psd1
```

Expected: 271 new `.psd1` files and no unresolved metadata.

- [ ] **Step 5: Run all manifest tests**

Run:

```powershell
powershell.exe -NoProfile -Command "Invoke-Pester -Path tests/Manifest.Tests.ps1,tests/Repository.Tests.ps1 -Output Detailed"
```

Expected: all schema, pairing, type, GUID, counterpart, and migration-state tests PASS.

- [ ] **Step 6: Commit manifests and their reviewed metadata**

```bash
git add standards/FoundationPackages.psd1 tools/New-ScriptManifest.ps1 tests *.psd1
git commit -m "docs: add typed manifests for every script"
```

### Task 8: Normalize static style through the equivalence gate

**Files:**
- Create: `.editorconfig`
- Create: `.gitattributes`
- Create: `PSScriptAnalyzerSettings.psd1`
- Modify: all 271 deployment `.ps1` files
- Test: `tests/Repository.Tests.ps1`

- [ ] **Step 1: Add formatting policy files**

Create `.editorconfig`:

```ini
root = true

[*]
charset = utf-8-bom
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{ps1,psm1,psd1}]
indent_style = space
indent_size = 4

[*.md]
trim_trailing_whitespace = false
```

Create `.gitattributes`:

```gitattributes
* text=auto
*.ps1 text eol=lf
*.psm1 text eol=lf
*.psd1 text eol=lf
*.md text eol=lf
*.png binary
*.webp binary
```

- [ ] **Step 2: Configure exact analyzer rules**

Create `PSScriptAnalyzerSettings.psd1`:

```powershell
@{
    Severity = @('Error', 'Warning')
    IncludeRules = @(
        'PSAvoidUsingCmdletAliases'
        'PSUseApprovedVerbs'
        'PSAvoidUsingInvokeExpression'
        'PSUseConsistentIndentation'
        'PSUseConsistentWhitespace'
        'PSPlaceOpenBrace'
        'PSPlaceCloseBrace'
        'PSAvoidLongLines'
    )
    Rules = @{
        PSAvoidUsingCmdletAliases = @{ allowlist = @() }
        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind = 'space'
        }
        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckInnerBrace = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckPipe = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator = $true
            CheckParameter = $false
            IgnoreAssignmentOperatorInsideHashTable = $false
        }
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }
        PSPlaceCloseBrace = @{
            Enable = $true
            NoEmptyLineBefore = $false
            IgnoreOneLineBlock = $true
            NewLineAfter = $true
        }
        PSAvoidLongLines = @{
            Enable = $true
            MaximumLineLength = 120
        }
    }
}
```

- [ ] **Step 3: Write failing static-style tests**

Tests must detect aliases, unapproved local function verbs, cmdlet casing drift, tabs, trailing whitespace, missing final newlines, non-LF line endings, non-BOM UTF-8, and lines over 120 characters except URLs and integrity hashes.

Run them before formatting and expect failures matching the audited legacy counts.

- [ ] **Step 4: Normalize source in controlled classes**

Apply changes in this order:

1. Encoding, LF, final newline, indentation, and trailing whitespace.
2. Canonical cmdlet casing.
3. The 12 explicitly mapped aliases.
4. Explicitly mapped local function definitions and every static callsite.
5. Brace and whitespace formatting.

Do not automatically alter the 23 backtick continuations, four here-string bodies or delimiters, two help blocks, the inline pipeline comment, or dynamic invocation targets. Any changed sensitive construct must be explicitly represented and pass the comparator.

- [ ] **Step 5: Run the cutover comparator before accepting formatting**

Run:

```powershell
$base = Get-Content .\evidence\foundation\BaseRevision.txt -Raw
powershell.exe -NoProfile -File .\build.ps1 `
    -Task ValidateRewrite `
    -BaseRevision $base `
    -PathMap .\evidence\foundation\PathMap.psd1 `
    -SymbolMap .\evidence\foundation\SymbolRenames.psd1 `
    -ReportPath .\evidence\foundation\RewriteReport.json
```

Expected: 271 passing rows, zero unclassified differences, and exit `0`.

- [ ] **Step 6: Run static checks**

Run:

```powershell
powershell.exe -NoProfile -Command "Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1"
powershell.exe -NoProfile -Command "Invoke-Pester -Path tests/Repository.Tests.ps1 -Output Detailed"
```

Expected: no analyzer findings and all current-tree style tests PASS.

- [ ] **Step 7: Commit only proven-equivalent source normalization**

```bash
git add .editorconfig .gitattributes PSScriptAnalyzerSettings.psd1 evidence/foundation/RewriteReport.json tests *.ps1
git commit -m "style: normalize PowerShell catalog"
```

### Task 9: Complete normal current-tree quality commands

**Files:**
- Modify: `build.ps1`
- Modify: `tools/RepositoryCatalog.psm1`
- Modify: `tests/Repository.Tests.ps1`

- [ ] **Step 1: Add failing build-interface tests**

Add Pester tests that invoke each task and assert:

```text
Validate      -> current inventory, paths, manifests, parsing, references, migration state
Analyze       -> PSScriptAnalyzer with repository settings
Test          -> all Pester tests with coverage enabled
CheckFormat   -> verification only; no file bytes change
ValidateRewrite -> requires explicit base revision and maps
```

Also assert that no default task invokes a deployment `.ps1`.

- [ ] **Step 2: Implement the final build interface**

Extend `build.ps1` parameters:

```powershell
[ValidateSet('Bootstrap', 'Validate', 'Analyze', 'Test', 'CheckFormat', 'ValidateRewrite')]
[string] $Task = 'Validate',
[string] $BaseRevision,
[string] $PathMap,
[string] $SymbolMap,
[string] $ReportPath
```

Use a `switch ($Task)` that imports the pinned module versions and invokes only the corresponding command. `Test` uses `New-PesterConfiguration`, enables command coverage for scripts whose manifests are `Covered`, and fails when any result is failed. During foundation, coverage input is empty because all catalog scripts are `PendingMigration`; repository/tooling tests still run.

- [ ] **Step 3: Run every non-destructive task**

Run:

```powershell
powershell.exe -NoProfile -File .\build.ps1 -Task Validate
powershell.exe -NoProfile -File .\build.ps1 -Task Analyze
powershell.exe -NoProfile -File .\build.ps1 -Task Test
powershell.exe -NoProfile -File .\build.ps1 -Task CheckFormat
```

Expected: each command exits `0`; no deployment script output or endpoint mutation occurs.

- [ ] **Step 4: Commit the supported local interface**

```bash
git add build.ps1 tools/RepositoryCatalog.psm1 tests
git commit -m "build: add repository quality commands"
```

### Task 10: Add cutover-aware Windows PowerShell 5.1 CI

**Files:**
- Create: `.github/workflows/powershell-quality.yml`

- [ ] **Step 1: Create the complete Windows PowerShell 5.1 workflow**

Create `.github/workflows/powershell-quality.yml`:

```yaml
name: PowerShell quality

on:
  pull_request:
  push:
    branches:
      - main

permissions:
  contents: read

defaults:
  run:
    shell: powershell

jobs:
  quality:
    runs-on: windows-2022
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Bootstrap pinned modules
        run: .\\build.ps1 -Task Bootstrap
      - name: Validate repository
        run: .\\build.ps1 -Task Validate
      - name: Analyze PowerShell
        run: .\\build.ps1 -Task Analyze
      - name: Run Pester
        run: .\\build.ps1 -Task Test
      - name: Check formatting
        run: .\\build.ps1 -Task CheckFormat

  foundation-rewrite:
    if: github.event_name == 'pull_request'
    runs-on: windows-2022
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - id: scope
        name: Detect one-time foundation cutover
        env:
          BASE_SHA: ${{ github.event.pull_request.base.sha }}
        run: |
          git cat-file -e \"$env:BASE_SHA`:evidence/foundation/RewriteReport.json\" 2>$null
          $baseHasReport = $LASTEXITCODE -eq 0
          $headHasReport = Test-Path '.\\evidence\\foundation\\RewriteReport.json'
          $runGate = $headHasReport -and -not $baseHasReport
          \"run=$($runGate.ToString().ToLowerInvariant())\" |
              Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding ascii
      - name: Bootstrap pinned modules
        if: steps.scope.outputs.run == 'true'
        run: .\\build.ps1 -Task Bootstrap
      - name: Regenerate foundation rewrite evidence
        if: steps.scope.outputs.run == 'true'
        run: |
          $baseRevision = Get-Content '.\\evidence\\foundation\\BaseRevision.txt' -Raw
          .\\build.ps1 `
              -Task ValidateRewrite `
              -BaseRevision $baseRevision `
              -PathMap '.\\evidence\\foundation\\PathMap.psd1' `
              -SymbolMap '.\\evidence\\foundation\\SymbolRenames.psd1' `
              -ReportPath \"$env:RUNNER_TEMP\\RewriteReport.json\"
          $actual = (Get-FileHash \"$env:RUNNER_TEMP\\RewriteReport.json\").Hash
          $expected = (Get-FileHash '.\\evidence\\foundation\\RewriteReport.json').Hash
          if ($actual -ne $expected) {
              throw 'Committed foundation rewrite report does not match regenerated evidence.'
          }
      - uses: actions/upload-artifact@v4
        if: steps.scope.outputs.run == 'true'
        with:
          name: foundation-rewrite-report
          path: ${{ runner.temp }}\\RewriteReport.json

  declared-rewrites:
    if: github.event_name == 'pull_request'
    runs-on: windows-2022
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Bootstrap pinned modules
        run: .\\build.ps1 -Task Bootstrap
      - name: Validate newly declared formatting rewrites
        env:
          BASE_SHA: ${{ github.event.pull_request.base.sha }}
        run: |
          $baseFiles = @(git diff --diff-filter=A --name-only $env:BASE_SHA HEAD -- 'evidence/rewrites/*/BaseRevision.txt')
          foreach ($baseFile in $baseFiles) {
              $directory = Split-Path $baseFile
              $baseRevision = Get-Content $baseFile -Raw
              $reportPath = Join-Path $env:RUNNER_TEMP \"$(Split-Path $directory -Leaf)-RewriteReport.json\"
              .\\build.ps1 `
                  -Task ValidateRewrite `
                  -BaseRevision $baseRevision `
                  -PathMap (Join-Path $directory 'PathMap.psd1') `
                  -SymbolMap (Join-Path $directory 'SymbolRenames.psd1') `
                  -ReportPath $reportPath
          }
```

The one-time job runs only when the pull request introduces the persisted foundation report. Later behavior pull requests inherit that report in their base and therefore skip the fixed baseline. Later formatting-only rewrites opt in by adding a new evidence directory.

- [ ] **Step 2: Validate workflow syntax and run it on the branch**

Push the branch and inspect the GitHub Actions result.

Expected: normal quality job PASS; foundation rewrite job PASS with 271 rows; no deployment scripts execute.

- [ ] **Step 3: Commit CI**

```bash
git add .github/workflows/powershell-quality.yml
git commit -m "ci: enforce PowerShell foundation standards"
```

### Task 11: Document the enforced contributor workflow

**Files:**
- Create: `CONTRIBUTING.md`
- Create or modify: `AGENTS.md`
- Modify: `README.md`
- Modify: affected package README files

- [ ] **Step 1: Write contributor guidance**

`CONTRIBUTING.md` must document:

- One package directory per Intune deployment unit.
- `Detect-<Scenario>.ps1/.psd1` and optional `Remediate-<Scenario>.ps1/.psd1`.
- Standalone upload requirement.
- Native manifest scalar types.
- Windows PowerShell 5.1 authority.
- Exact `build.ps1` commands.
- New scripts require `Status = 'Covered'` and behavioral tests.
- Existing `PendingMigration` scripts migrate only through later behavior plans.
- Normal CI versus opt-in rewrite-equivalence validation.
- No embedded credentials or tenant secrets.

- [ ] **Step 2: Update AI-assistant guidance**

Update `AGENTS.md` so it no longer says the repository has no tooling or tests. Add exact standard paths, manifest rules, non-destructive commands, pending-versus-covered behavior, and the prohibition against normal remediation execution.

- [ ] **Step 3: Update root and package documentation links**

Update `README.md` contribution instructions and every package README reference using `evidence/foundation/PathMap.psd1`. Repository reference tests must resolve every local link and named script.

- [ ] **Step 4: Run documentation and repository tests**

Run:

```powershell
powershell.exe -NoProfile -File .\build.ps1 -Task Validate
```

Expected: all Markdown references resolve and validation exits `0`.

- [ ] **Step 5: Commit documentation**

```bash
git add CONTRIBUTING.md AGENTS.md README.md */README.md */README.MD */readme.md
git commit -m "docs: document repository standards workflow"
```

### Task 12: Regenerate evidence and verify the complete foundation

**Files:**
- Modify: `evidence/foundation/RewriteReport.json`
- Verify: all foundation files and 271 script/manifest pairs

- [ ] **Step 1: Regenerate cutover evidence from the frozen baseline**

Run under 64-bit Windows PowerShell 5.1:

```powershell
$base = Get-Content .\evidence\foundation\BaseRevision.txt -Raw
.\build.ps1 `
    -Task ValidateRewrite `
    -BaseRevision $base `
    -PathMap .\evidence\foundation\PathMap.psd1 `
    -SymbolMap .\evidence\foundation\SymbolRenames.psd1 `
    -ReportPath .\evidence\foundation\RewriteReport.json
```

Expected: 271 passing rows and exit `0`.

- [ ] **Step 2: Run the full current-tree quality suite**

Run:

```powershell
.\build.ps1 -Task Validate
.\build.ps1 -Task Analyze
.\build.ps1 -Task Test
.\build.ps1 -Task CheckFormat
```

Expected:

```text
271 standard .ps1 deployment scripts
271 valid same-basename .psd1 manifests
0 parser errors
0 unresolved repository references
0 aliases
0 unapproved local function verbs
0 analyzer findings
0 failed Pester tests
271 PendingMigration manifests
```

- [ ] **Step 3: Confirm the persisted report is stable**

Regenerate the report to a temporary file and compare hashes:

```powershell
$tempReport = Join-Path $env:TEMP 'foundation-rewrite-report.json'
.\build.ps1 -Task ValidateRewrite -BaseRevision $base -PathMap .\evidence\foundation\PathMap.psd1 -SymbolMap .\evidence\foundation\SymbolRenames.psd1 -ReportPath $tempReport
if ((Get-FileHash $tempReport).Hash -ne (Get-FileHash .\evidence\foundation\RewriteReport.json).Hash) {
    throw 'Rewrite report is not deterministic.'
}
```

Expected: hashes match.

- [ ] **Step 4: Run the actual CI workflow and inspect all job results**

Push the final branch. Expected: normal quality and one-time foundation rewrite jobs both PASS. Treat skipped or cancelled required jobs as failure.

- [ ] **Step 5: Commit final evidence if regeneration changed it**

```bash
git add evidence/foundation/RewriteReport.json
git commit -m "chore: finalize foundation rewrite evidence"
```

Do not create an empty commit when the report is unchanged.

- [ ] **Step 6: Request code review before merge**

Review the complete cutover with focus on:

- Path-map completeness and split-package intent.
- Manifest claims with source evidence.
- Rewrite report failures or normalizations.
- CI proof that the fixed baseline runs only for the foundation pull request.
- Absence of behavior, output, exit, error-flow, or endpoint-mutation changes.
