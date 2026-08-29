# Repository standards and package testing design

## Status

Approved design for introducing enforceable PowerShell standards and meaningful detection/remediation tests across the repository.

## Context

The repository contains 134 independent Intune script packages and 271 runtime-script candidates: 269 `.ps1` files and two extensionless PowerShell scripts. Current packages include 124 ordinary detection/remediation pairs, multi-pair directories, detection-only packages, and legacy naming exceptions.

The repository has no build entry point, dependency manifest, formatter settings, PSScriptAnalyzer configuration, Pester tests, coverage configuration, or CI workflow. Most scripts execute endpoint logic at top level, and 202 of 269 `.ps1` files call `exit`. That prevents safe in-process testing and makes broad remediation execution unsafe on hosted runners.

Existing naming and behavior are inconsistent:

- 13 package folders do not follow the dominant PascalCase hyphenated pattern.
- 22 script filenames are visibly exceptional or misspelled.
- 105 scripts lack a final newline, 159 contain trailing whitespace, and encoding and line endings vary.
- Detection output, exit behavior, remediation exits, error handling, and headers are not uniform.
- Existing exact paths can appear in Intune operations, raw GitHub URLs, runbooks, bookmarks, and package documentation.

Repository-local naming and static style do not justify permanent legacy exceptions. The approved strategy performs one clean foundation cutover for folders, filenames, extensions, manifests, formatting, cmdlet style, and in-repository references. Runtime behavior, import safety, error semantics, and behavioral tests then migrate in risk-ranked batches.

## Goals

- Define one enforceable package, script, function, formatting, error, output, and exit-code standard.
- Keep every deployment script independently uploadable to Intune.
- Standardize all repository package paths and nonbehavioral code style in one foundation cutover.
- Add one machine-readable `.psd1` manifest for every deployment script during that cutover.
- Add meaningful Pester tests for every detection and remediation script through staged behavioral migration.
- Make 64-bit Windows PowerShell 5.1 the required compatibility authority.
- Prevent new untested scripts and monotonically reduce the scripts pending behavioral migration to zero.

## Non-goals

- Do not introduce a runtime shared module or require multiple files in an Intune upload.
- Do not generate deployment scripts from different source files.
- Do not execute remediation entry points against hosted CI runners.
- Do not treat source-text assertions or mock-call counts as proof of behavior.
- Do not require PowerShell 7 compatibility.
- Do not preserve obsolete repository paths through duplicate files, aliases, or shims after the foundation naming cutover.

## Package architecture

A package is one top-level PascalCase, hyphen-separated scenario directory and represents one Intune deployment unit.

After the foundation naming cutover, every paired package has this shape:

```text
<Scenario>/
  Detect-<Scenario>.ps1
  Detect-<Scenario>.psd1
  Remediate-<Scenario>.ps1
  Remediate-<Scenario>.psd1
```

A detection-only package omits both remediation files. The foundation splits directories that currently contain multiple independent detection/remediation pairs into separate package directories.

Each `.ps1` file is the exact standalone artifact uploaded to Intune. It contains all runtime logic and never imports its sidecar manifest, a repository module, or a sibling script. Repository test helpers and quality tooling can be shared because they are not deployment dependencies.

### Script execution boundary

Each script contains definitions followed by one guarded entry point:

```powershell
Set-StrictMode -Version Latest

function Test-ScenarioName {
    # Return structured compliance data. Do not exit or write host output.
}

function Invoke-DetectionEntryPoint {
    # Convert the structured result to one operator message and an exit code.
}

if ($MyInvocation.InvocationName -ne '.') {
    $entryPointResult = Invoke-DetectionEntryPoint
    Write-Output $entryPointResult.Message
    exit $entryPointResult.ExitCode
}
```

Dot-sourcing loads definitions without querying or changing endpoint state and without terminating the caller. Normal `-File` execution invokes the guarded entry point.

Tests load each deployment script into an isolated dynamic module. This prevents same-named self-contained functions in detection and remediation files from colliding and lets Pester inject mocks into the script's command scope.

### Detection contract

The core `Test-<Scenario>` function returns one object with these properties:

- `Compliant`: Boolean desired-state result.
- `Message`: concise operator-facing summary.
- `Evidence`: structured diagnostic data that supports the decision.
- `Error`: `$null` or structured failure evidence.

The detection adapter emits one stable line of operator output and maps results according to the manifest's detection mode:

- `Compliance`: compliant state exits `0`; noncompliance or a detection error exits `1`.
- `AlwaysRemediate`: a successful trigger evaluation exits `1` to request remediation; an evaluation error also exits `1` but returns explicit error evidence.
- `Inventory`: successful collection exits `0`; a collection error exits `1`.

Intentional modes are explicit metadata, not filename or source-code exceptions. Tests apply the matching contract and verify that output distinguishes successful triggers from errors.

### Remediation contract

The core `Repair-<Scenario>` function returns one object with these properties:

- `Succeeded`: Boolean verified outcome.
- `Changed`: Boolean indicating whether endpoint state changed.
- `Message`: concise operator-facing summary.
- `Evidence`: structured change and postcondition data.
- `Error`: `$null` or structured failure evidence.

A remediation file includes its own self-contained state-query function. After mutation, remediation reuses that function to verify the desired postcondition. It does not report success from attempted cmdlet or executable calls alone.

The remediation adapter maps verified success to exit `0` and failure to exit `1`. A second remediation against compliant state returns success with `Changed = $false`.

## Per-script manifest

Every `.ps1` has a same-basename `.psd1`. The manifest is authoritative repository metadata for exactly one script. The deployment script never reads it at runtime.

The manifest is a PowerShell data file containing literals, arrays, and hashtables only. CI rejects executable expressions.

### Required schema

```powershell
@{
    SchemaVersion = '1.0'
    Id            = '<immutable-guid>'

    Identity = @{
        PackageName = '<Scenario>'
        ScriptName  = '<Detect-or-Remediate-Scenario>'
        Role        = '<Detection-or-Remediation>'
        Version     = '<semantic-version>'
        Description = '<operator-facing-purpose>'
        Authors     = @('<author-or-source>')
        Source      = '<source-reference-or-empty-string>'
        Counterpart = '<relative-counterpart-path-or-empty-string>'
    }

    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture      = 'x64'
        RunAs             = '<System-User-or-Either>'
        RequiresElevation = $true
        SignatureCheck    = '<Required-NotRequired-or-Either>'
        SupportedWindows  = @('<documented-version-or-AllSupported>')
        Reboot            = '<None-Possible-or-Required>'
    }

    Behavior = @{
        DetectionMode = '<Compliance-AlwaysRemediate-Inventory-or-NotApplicable>'
    }

    Dependencies = @{
        Modules     = @()
        Cmdlets     = @()
        Executables = @()
        Policies    = @()
        Endpoints   = @()
    }

    Configuration = @(
        @{
            Name        = '<setting-name>'
            Required    = $true
            Secret      = $false
            Description = '<configuration-purpose>'
        }
    )

    Risk = @{
        Level         = '<Low-Medium-High-or-Critical>'
        Destructive   = $false
        UserImpact    = '<impact-or-None>'
        Rollback      = '<rollback-procedure-or-NotAvailable-with-reason>'
        DataHandling  = '<data-handling-summary-or-None>'
    }

    Test = @{
        Categories             = @('<Registry-Service-File-Process-Network-Rest-Native-Appx-Ui-or-Destructive>')
        Status                 = '<PendingMigration-or-Covered>'
        CoverageFloor          = 0.0
        IntegrationLevel       = '<None-WindowsVm-InteractiveWindows-or-IntunePilot>'
        RequiresIntunePilot    = $false
        RequiresInteractiveUser = $false
    }
}
```
Boolean and numeric values in this example are deliberately native PowerShell values, not quoted placeholders. Generated manifests must preserve these types even when their scenario-specific values differ.


`Id` never changes when a path or script name changes. `Counterpart` must resolve within the same package when present. A detection-only manifest uses an empty counterpart. Remediation uses `DetectionMode = 'NotApplicable'`.

Foundation manifests use `Status = 'PendingMigration'` and `CoverageFloor = 0` until their script receives behavioral tests. New scripts must start as `Covered`. Once a script becomes `Covered`, it cannot return to `PendingMigration`.

CI validates required keys, types, enum values, semantic versions, path agreement, one-to-one `.ps1` and `.psd1` pairing, counterpart symmetry, migration-state transitions, and data-only content.

## Coding standard

### Naming and structure

- Every package folder uses PascalCase words separated by hyphens, with no spaces or underscores.
- Script and sidecar basenames are `Detect-<Scenario>` and `Remediate-<Scenario>`.
- Local functions use approved PowerShell Verb-Noun names. Behavior-migrated core functions are `Test-<Scenario>` and `Repair-<Scenario>`.
- Use full cmdlet names with canonical casing. Do not use aliases.
- Keep deployment configuration explicit and document every configurable value in the sidecar manifest.

### Formatting

- Use four spaces for indentation and same-line opening braces.
- Use LF line endings, one final newline, and no trailing whitespace.
- Use UTF-8 with BOM to preserve non-ASCII text under Windows PowerShell 5.1.
- Enforce a 120-character line limit, excluding unavoidable URLs and integrity hashes through narrow analyzer exceptions.
- Normalize all catalog scripts in the foundation cutover. Keep later formatting changes scoped to the package being changed.
- Preserve here-string bodies and delimiters exactly during foundation formatting.
- Do not automatically remove backtick continuations or relocate comments adjacent to pipelines. The foundation rewrite safety gate must prove any such change equivalent.

### State, output, and errors

- Use `Set-StrictMode -Version Latest` in behavior-migrated deployment scripts.
- Keep endpoint state behind functions and explicit parameters. Do not use unrelated global mutable state.
- Use arrays, hashtables, and `[pscustomobject]` results rather than introducing a class hierarchy.
- Use explicit `-ErrorAction Stop` when an operation's failure changes the reported result. Do not globally set `$ErrorActionPreference` as a substitute for boundary-specific handling.
- A caught dependency or endpoint error never becomes a compliant or successful result.
- Do not use `-ErrorAction SilentlyContinue` to hide a failure. It is permitted only for an expected absence that the surrounding logic handles explicitly.
- Core functions return data and do not call `exit`, `Write-Host`, or process-wide sleep directly.
- Wrap native processes, HTTP, time, static .NET or WinRT calls, and other difficult boundaries in local functions that return structured data.
- Preserve and verify cryptographic integrity checks for downloaded executable content.
- Never place real credentials, tokens, tenant-specific identifiers, or customer secrets in scripts, manifests, fixtures, or test output.

## Foundation rewrite safety

The foundation changes all catalog paths and static style before behavioral coverage exists. Therefore, every before/after script pair must pass an executable, fail-closed equivalence gate under 64-bit Windows PowerShell 5.1.

The repository audit found rewrite-sensitive syntax that the gate must handle explicitly:

- 23 effective backtick line continuations across 5 files.
- 4 expandable here-strings across 4 files.
- 2 comment-based-help blocks.
- 1 inline comment on a pipeline line and 40 additional comment-bearing lines adjacent to pipelines.
- 12 dynamic call-operator invocations across 10 files.
- 15 local function definitions with 22 static callsites.
- 12 aliases across 9 files.

### Gate inputs

`tools/Test-FoundationRewrite.ps1` requires:

- `BaseRevision`: the exact pre-cutover Git commit, resolved and reported as a full SHA.
- `evidence/foundation/PathMap.psd1`: a total one-to-one map from every baseline runtime path to every post-cutover runtime path.
- `evidence/foundation/SymbolRenames.psd1`: path-scoped alias and function renames. General text substitutions are forbidden.

The path map must cover all 271 baseline runtime candidates and all 271 post-cutover scripts. It rejects missing or duplicate paths, duplicate destinations, absolute paths, parent traversal, case-colliding destinations, and unmapped extensionless files.

### Parser and equivalence checks

For every mapped pair, the gate:

1. Reads baseline bytes from Git and destination bytes from the working tree without invoking either script.
2. Decodes both deterministically, accounting for their BOM, then parses both with `[System.Management.Automation.Language.Parser]` in Windows PowerShell 5.1.
3. Fails if either side has a parser error.
4. Compares an ordered AST-shape fingerprint consisting of each node's CLR type, parent index, and child order, excluding source extents. Inserted, removed, reordered, or retyped nodes fail.
5. Compares semantic token kind, flags, order, and value after excluding only BOM, ordinary whitespace, normalized newlines, and end-of-input. A changed command or function token normalizes only through an explicit symbol-map entry.
6. Preserves comment order, text after normalizing line endings and trailing whitespace, and each comment's anchors to surrounding semantic tokens. Comments on or adjacent to pipelines cannot move across pipeline elements. Comment-based help must remain associated with the same script or function and retain its help-keyword structure.
7. Requires identical here-string mode, semantic value, opener and terminator structure, and terminator count.
8. Preserves each line-continuation token and its neighboring semantic tokens unless an explicitly reviewed rewrite passes the same AST and token checks. Automatic formatting skips those continuations.
9. Preserves dynamic invocation operator, target expression, arguments, and redirections. A new dynamic invocation form, dot sourcing, or `Invoke-Expression` fails.
10. Emits a machine-readable result per file containing paths, byte hashes, parser errors, AST and token fingerprints, applied map entries, and sensitive-construct counts.

### Symbol-reference checks

Alias replacement is allowed only when Windows PowerShell 5.1 resolves the original alias and replacement to the same canonical command. The gate compares every remaining command element and rejects unexpected aliases or count drift.

Function renaming is alpha-equivalent only through a path-scoped map. For each rename, the gate requires:

- Exactly one old and one new `FunctionDefinitionAst`.
- Equivalent parameters and body fingerprints after normalizing the mapped name.
- A one-to-one mapping of all static `CommandAst` callsites.
- No unresolved old name in string constants, expandable strings, call-operator targets, member calls, manifests, or documentation.

Any dynamic or ambiguous function reference fails the foundation rewrite and moves that nontrivia code change to the behavior-migration phase.

### Pass condition

Formatting-only changes must pass without symbol mappings. Approved alias and function changes must pass with their exact mappings. Any unclassified content difference, unresolved reference, inventory drift, parser error, AST drift, token drift, sensitive-comment movement, here-string change, or dynamic-invocation change fails the entire foundation gate.

This gate parses source only. It never dot-sources, invokes, or imports a catalog script.

### Gate lifecycle

The fixed pre-cutover baseline applies only to the foundation cutover pull request. That pull request persists these evidence files:

```text
evidence/foundation/BaseRevision.txt
evidence/foundation/PathMap.psd1
evidence/foundation/SymbolRenames.psd1
evidence/foundation/RewriteReport.json
```

After the foundation merges, normal CI does not compare current scripts to the pre-cutover revision. It validates the current tree through parsing, style, manifests, references, PSScriptAnalyzer, package tests, and coverage. Intentional behavior migrations can then change ASTs and semantic tokens when their contract and regression tests prove the change.

A later formatting-only or symbol-normalization rewrite can opt into the same gate by declaring a new base revision and before/after maps for that change. Its dedicated rewrite job and report are scoped to that pull request. No persistent CI job reuses the foundation baseline.


## Quality tooling

The foundation adds:

```text
.editorconfig
.gitattributes
PSScriptAnalyzerSettings.psd1
build.ps1
tools/RequiredModules.psd1
standards/ManifestSchema.psd1
evidence/foundation/BaseRevision.txt
evidence/foundation/PathMap.psd1
evidence/foundation/SymbolRenames.psd1
evidence/foundation/RewriteReport.json
tools/Test-PowerShellRewrite.ps1
tests/Repository.Tests.ps1
tests/TestHelpers.psm1
tests/packages/<Scenario>/*.Tests.ps1
.github/workflows/powershell-quality.yml
CONTRIBUTING.md
```

`README.md` gains contributor setup and command summaries. `AGENTS.md` gains the enforceable architecture, path, manifest, and test rules.

`tools/RequiredModules.psd1` pins exact Pester 5 and PSScriptAnalyzer versions that support Windows PowerShell 5.1. Local development and CI use the same versions.

`build.ps1` is the only supported quality entry point and provides non-destructive tasks:

- `Bootstrap`: install the pinned test and analyzer modules for the current user or CI workspace.
- `Validate`: validate the current repository inventory, manifests, parsing, paths, documentation references, and migration state.
- `Analyze`: run PSScriptAnalyzer with repository settings.
- `Test`: run repository and package Pester tests with code coverage.
- `CheckFormat`: verify formatting without rewriting files.
- `ValidateRewrite`: opt into before/after AST and token equivalence with an explicit base revision and maps. The foundation cutover requires it; normal post-foundation CI does not run it.

No default or quality task executes deployment scripts normally. Format rewriting, if provided, requires an explicit package path and is never part of CI. A pull request that declares a formatting-only rewrite must run `ValidateRewrite` against that change's own base revision.

## Testing strategy

### Repository contract tests

`tests/Repository.Tests.ps1` verifies:

- Every package and runtime file follows the standard folder, basename, extension, and sidecar-pairing rules.
- Detection-only packages are valid; multiple independent pairs in one package are not.
- Manifests satisfy the schema and match paths and counterpart relationships.
- Every script parses under Windows PowerShell 5.1.
- Approved function verbs, full cmdlet names, and canonical cmdlet casing are used.
- Prohibited aliases are absent.
- Formatting, encoding, and final-newline rules hold.
- Markdown script references resolve.
- Every `Covered` runtime script is safe to dot-source and has the required core functions and package test file.
- No new script starts as `PendingMigration`, no `Covered` script regresses to `PendingMigration`, and no recorded coverage floor decreases.

The foundation records existing scripts as `PendingMigration` in their manifests. This is migration state, not a naming or style exception. CI requires the count to stay level or decrease until every script is `Covered`.

### Package behavioral tests

Tests live under `tests/packages/<Scenario>/` and identify targets by package-relative path, not basename.

Each applicable detection script tests:

- Compliant state.
- Noncompliant state.
- Missing dependency.
- Dependency failure.
- Stable operator message.
- Correct adapter exit mapping for its declared detection mode.

Each remediation script tests:

- Already-compliant no-op.
- Successful state change followed by compliant detection.
- Failed state change followed by noncompliance.
- Truthful error output and nonzero adapter mapping.
- Idempotence.
- Package-specific exclusions, safety bounds, and failure aggregation.

Tests assert structured decisions and resulting state. A test whose only evidence is `Should -Invoke` does not satisfy the contract. Prefer real temporary files for filesystem behavior and stateful fakes for registry, services, packages, and remote systems. Mock only explicit operating-system and external boundaries.

### Coverage ratchet

Each `Covered` script stores its achieved Pester command-coverage floor in its manifest. CI rejects coverage below that floor. A change can preserve or increase the floor but cannot reduce it. Behavioral cases remain mandatory regardless of percentage.

### Runtime validation tiers

Required CI runs on a Windows runner under 64-bit Windows PowerShell 5.1. It performs parsing, repository tests, PSScriptAnalyzer, package Pester tests, and coverage. It never runs remediation entry points against the runner host.

Manifest metadata defines additional evidence:

- `WindowsVm`: use a revertible Windows VM for provider, ACL, executable, service, AppX, registry-view, or destructive behavior.
- `InteractiveWindows`: validate WinRT, toast, COM, user-session, or UI behavior in a logged-on session.
- `IntunePilot`: validate System/user identity, policy, egress, assignments, reboot behavior, and real package convergence in a limited ring.

These tiers supplement automated tests. They are not replaced with source-only or mock-only assertions.

## Migration strategy

### Foundation

Perform one clean catalog cutover before behavioral migrations begin:

- Rename every package folder and script to the approved convention.
- Add `.ps1` extensions to extensionless runtime scripts.
- Split current multi-pair directories into separate deployment-unit packages.
- Update every in-repository path reference and add inventory tests that reject legacy names.
- Normalize approved function verbs, cmdlet names and casing, aliases, formatting, encoding, line endings, and final newlines without changing runtime semantics. Preserve comment text and help blocks except for trailing-whitespace normalization and explicit path-reference updates.
- Add an accurate sidecar manifest for every deployment script, initially using `Status = 'PendingMigration'` and `CoverageFloor = 0`.
- Add quality commands, manifest schema validation, Windows PowerShell 5.1 CI, and contributor documentation.
- Run the Windows PowerShell 5.1 rewrite gate against the exact pre-cutover commit, require all 271 path pairs to pass, and persist the base SHA, path map, symbol map, and machine-readable report as foundation evidence.

The cutover removes obsolete paths immediately and adds no compatibility files. It does not change detection exits, remediation exits, output streams, error semantics, endpoint mutations, or external dependency behavior.

### Category exemplars

Migrate one safe representative from each overlapping dependency category:

- Registry.
- Service.
- File.
- Process.
- Network.
- REST or HTTP.
- Native executable.
- AppX.
- UI or toast.
- Destructive remediation.

Use these packages to prove shared test-only helpers, manifest enums, boundary wrappers, and integration metadata before scaling.

### Risk-ranked batches

After exemplars, migrate packages in small reviewable batches. Prioritize packages that contain:

- Broad deletion, uninstall, shutdown, service reset, security, or network changes.
- Embedded secret placeholders or tenant-specific identifiers.
- Remote downloads without integrity verification.
- Suppressed errors or success messages that do not prove state.
- Reversed or ambiguous exit behavior.
- Native executable output parsing without exit-code checks.

For each package:

1. Capture existing behavior through the safest available seam, then add intended-contract tests. If a top-level remediation cannot run safely, first isolate its smallest decision boundary without changing behavior and lock that boundary with characterization tests.
2. Refactor top-level logic into import-safe functions and guarded adapters.
3. Fix a behavior defect only with a failing regression test that captures the intended contract.
4. Refine the existing manifest with verified runtime, risk, dependency, and integration evidence.
5. Set manifest `Status = 'Covered'` and record the achieved coverage floor.
6. Run repository, analyzer, formatting, package, and coverage gates.
7. Record required Windows VM, interactive-session, or Intune pilot evidence.

A behavior-migrated package leaves no untested deployment script.

### Completion

The migration is complete when:

- All 134 original top-level package directories have been accounted for in the clean naming cutover; current multi-pair directories have been split, and every resulting deployment unit conforms.
- Every runtime script has one valid same-basename `.psd1`.
- Every manifest has `Status = 'Covered'`.
- Every detection and remediation script has behavioral Pester tests.
- Every paired remediation proves postcondition convergence and idempotence.
- Every manifest records an enforced coverage floor and required integration evidence.
- All repository references resolve.
- Windows PowerShell 5.1 CI passes all repository, analyzer, formatting, package, and coverage gates.

## Implementation planning boundary

This design governs the full migration program, but the implementation must not use one plan or pull request for all 134 existing package directories.

- The first implementation plan covers the foundation clean cutover: all path renames, package splits, static style normalization, manifests, tooling, documentation, local commands, and CI.
- Each category exemplar is a separate implementation plan after the foundation passes.
- Remaining packages use small risk-ranked batch plans whose members share test boundaries and integration requirements.
- A later batch cannot weaken foundation gates or introduce a new `PendingMigration` script.

## Risks and controls

- **Path breakage:** generate and review one complete old-to-new path map, update every repository reference in the same cutover, assert that no legacy path remains, and add no compatibility files.
- **Foundation semantic drift:** require before/after Windows PowerShell 5.1 parse success, AST-shape and semantic-token equivalence, sensitive-comment and here-string preservation, and explicit alias/function reference maps for all 271 scripts.
- **Stale baseline blocking intentional changes:** scope the fixed baseline to the foundation cutover job, retain it only as evidence, and require later rewrites to declare a new change-specific baseline.
- **Behavior drift during refactoring:** write characterization and contract tests first; separate deliberate defect fixes and prove them with failing regression tests.
- **False confidence from mocks:** assert structured decisions and post-state, require category-specific integration evidence, and prohibit mock-call-only completion.
- **Hosted-runner damage:** never execute remediation entry points in CI; use isolated functions, temporary resources, stateful fakes, and revertible Windows environments.
- **Manifest drift:** validate path agreement, counterpart symmetry, enum values, and required fields on every change.
- **PowerShell compatibility drift:** make 64-bit Windows PowerShell 5.1 the required CI runtime and use UTF-8 with BOM.
- **Unbounded migration:** require small risk-ranked batches and a monotonically shrinking count of manifests with `Status = 'PendingMigration'`.

## Acceptance criteria

- The standards are executable through `build.ps1`, not prose-only.
- The foundation cannot merge unless every mapped before/after script pair passes the Windows PowerShell 5.1 rewrite-equivalence gate and the cutover evidence is persisted.
- Normal post-foundation CI never compares behavior migrations to the fixed pre-cutover baseline.
- CI prevents new naming, formatting, analyzer, manifest, package-shape, import-safety, test, and coverage violations.
- Every new package is fully conforming and tested from its first change.
- Every deployment script remains a single independently uploadable Intune artifact.
- Every script has one validated sidecar manifest after the foundation cutover and meaningful behavioral tests by migration completion.
- Progress is measured by package coverage and the remaining `PendingMigration` manifest count until every script is `Covered`.