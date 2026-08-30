# Contributing

This repository contains standalone Microsoft Intune Endpoint Analytics packages. Review the package contract and run the non-destructive quality checks before opening a pull request.

## Package and path conventions

- Put one Intune deployment unit in one top-level package directory. Do not make a package depend on another package or on repository code at deployment time.
- Use a scenario name that describes the endpoint behavior. Name the detection entry point `Detect-<Scenario>.ps1` and its same-basename manifest `Detect-<Scenario>.psd1`.
- Add `Remediate-<Scenario>.ps1` and `Remediate-<Scenario>.psd1` when the package changes endpoint state. Detection-only packages omit the remediation pair.
- Keep the `.ps1` and `.psd1` sidecars beside each other. Every deployable script has exactly one manifest with the same basename.
- Upload the scripts as standalone Intune content. Intune must be able to run a script without importing, dot-sourcing, or executing a repository catalog or shared module.
- Use the current path and script names in package READMEs. The authoritative post-cutover destinations are recorded in `evidence/foundation/PathMap.psd1`; do not add links to removed paths such as `0 - Template/`.

## Manifest metadata

Every manifest must validate against `standards/ManifestSchema.psd1`. Use the metadata generated or reviewed in `standards/FoundationPackages.psd1`, including the package name, script name, role, runtime, dependencies, configuration, risk, and test metadata.

Manifest data is PowerShell data, not JSON text. Preserve native scalar types:

```powershell
RequiresElevation = $true
Secret = $false
CoverageFloor = 0.0
```

Do not quote Boolean or numeric values. Use the approved enum values for `Role`, `Architecture`, `RunAs`, `SignatureCheck`, `Reboot`, `DetectionMode`, `Risk.Level`, `Test.Status`, `IntegrationLevel`, and `Test.Categories`. Do not put credentials, SAS tokens, shared keys, passwords, tenant IDs, customer URLs, or other tenant secrets in scripts, manifests, tests, or documentation.

## PowerShell authority and build tasks

Windows PowerShell 5.1 is the repository authority for scripts, manifests, build tasks, and Pester validation. Run authoritative checks with `powershell.exe` on Windows. PowerShell 7 can provide supplemental feedback, but a `pwsh` result does not replace the Windows PowerShell 5.1 result.

Bootstrap uses the exact versions in `tools/RequiredModules.psd1` and does not overwrite a different installed version:

```powershell
powershell.exe -NoProfile -File .\build.ps1 -Task Bootstrap
```

Run these non-destructive repository tasks from the repository root:

```powershell
powershell.exe -NoProfile -File .\build.ps1 -Task Validate
powershell.exe -NoProfile -File .\build.ps1 -Task Analyze
powershell.exe -NoProfile -File .\build.ps1 -Task Test
powershell.exe -NoProfile -File .\build.ps1 -Task CheckFormat
powershell.exe -NoProfile -File .\build.ps1 -Task ValidateStyle
powershell.exe -NoProfile -File .\build.ps1 -Task ValidateMaps
powershell.exe -NoProfile -File .\build.ps1 -Task ValidateManifests
```

`Validate` checks the deployment inventory, same-basename manifests, native metadata, PowerShell parsing, the foundation path map, and local Markdown references. `Analyze` runs the pinned PSScriptAnalyzer configuration. `Test` runs the Pester suite with coverage enabled for scripts whose manifests are `Covered`. `CheckFormat` verifies style without rewriting files. The map and manifest tasks run their focused checks.

Do not use the deployment catalog as a runner. `tools/RepositoryCatalog.psm1` is an inventory and validation module only. Normal validation, analysis, testing, formatting checks, and CI must not execute a detection or remediation script. Do not run remediation scripts as a routine smoke test because they can modify endpoint state.

## Coverage and migration status

A new script requires `Test.Status = 'Covered'` and behavioral tests that exercise its observable contract, boundaries, compliant and noncompliant states, and relevant errors. Set a numeric `Test.CoverageFloor` and preserve or raise that floor as coverage improves. A pull request must not lower an established coverage floor without an explicit behavior plan and evidence.

Existing cutover packages remain `PendingMigration` until a later behavior plan supplies appropriate Windows validation and behavioral coverage. Do not change an existing package from `PendingMigration` to `Covered` based only on parser, metadata, or path checks. The status transition is one way: `PendingMigration` can become `Covered`, but `Covered` must not return to `PendingMigration`.

## Rewrite-equivalence evidence

The foundation cutover evidence is stored in `evidence/foundation/`:

- `BaseRevision.txt` identifies the baseline commit.
- `PathMap.psd1` records source-to-destination path migrations.
- `SymbolRenames.psd1` records reviewed symbol migrations.
- `RewriteReport.json` records the accepted equivalence result.

The foundation rewrite check is one-time cutover-only CI work. It runs only when a pull request introduces the persisted foundation report, regenerates the report with the pinned Windows PowerShell 5.1 toolchain, and compares the generated report with the committed evidence. Later behavior pull requests inherit that report and do not rerun the fixed baseline. The foundation-only command is retained here for that cutover and must not be used for a declared later rewrite:

```powershell
$baseRevision = Get-Content .\evidence\foundation\BaseRevision.txt -Raw
powershell.exe -NoProfile -File .\build.ps1 `
    -Task ValidateRewrite `
    -BaseRevision $baseRevision `
    -PathMap .\evidence\foundation\PathMap.psd1 `
    -SymbolMap .\evidence\foundation\SymbolRenames.psd1 `
    -ReportPath .\evidence\foundation\RewriteReport.json
```

A later formatting-only rewrite must opt in with a new evidence directory under `evidence/rewrites/<name>/` containing its own `BaseRevision.txt`, `PathMap.psd1`, and `SymbolRenames.psd1`. Run the required `ValidateRewrite` command against that rewrite-specific evidence set and commit only the deterministic report and maps that belong to that rewrite. `ValidateRewrite` requires all four parameters:

```powershell
$baseRevision = Get-Content .\evidence\rewrites\<name>\BaseRevision.txt -Raw
powershell.exe -NoProfile -File .\build.ps1 `
    -Task ValidateRewrite `
    -BaseRevision $baseRevision `
    -PathMap .\evidence\rewrites\<name>\PathMap.psd1 `
    -SymbolMap .\evidence\rewrites\<name>\SymbolRenames.psd1 `
    -ReportPath .\evidence\rewrites\<name>\RewriteReport.json
```

Rewrite evidence proves source and destination equivalence. It is not a deployment input and must never cause the catalog or any deployment script to execute.

## Contribution steps

1. Choose a new scenario or an existing `PendingMigration` package. Inspect the entire package directory and its current manifest before editing.
2. Create or rename only to the canonical package and script paths. Keep each script standalone and add one same-basename manifest per script.
3. Add native, schema-valid metadata and update the package README with links to the current script paths. Keep secrets and tenant-specific values out of the repository.
4. Add behavioral tests for a new script and set its manifest status to `Covered`. For an existing `PendingMigration` script, record the required behavior work instead of claiming coverage.
5. Run `Bootstrap`, `Validate`, `Analyze`, `Test`, and `CheckFormat` with Windows PowerShell 5.1. Run `ValidateMaps` and `ValidateManifests` when paths or manifests change. Use `ValidateRewrite` only for an explicitly declared rewrite evidence set.
6. Confirm that no quality task or test executes a deployment script, then include the relevant test and endpoint evidence in the pull request.
