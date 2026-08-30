# Repository guidelines

## Scope and safety

This repository is a catalog of standalone Windows PowerShell packages for Microsoft Intune Endpoint Analytics remediation. Each top-level scenario directory is one independent Intune deployment unit. Do not assume that scripts share code or behavior. Inspect the complete package, manifest, and README before changing a package.

Deployment scripts can change registry, files, services, packages, profiles, or operating-system state. Never execute detection or remediation scripts as a routine repository check. Do not embed credentials, SAS tokens, shared keys, passwords, tenant IDs, customer URLs, or other tenant secrets.

## Canonical package contract

Use these paths and names for new or migrated content:

- `Package-Name/Detect-<Scenario>.ps1` is the detection entry point.
- `Package-Name/Detect-<Scenario>.psd1` is the one same-basename manifest for that script.
- `Package-Name/Remediate-<Scenario>.ps1` is the optional remediation entry point.
- `Package-Name/Remediate-<Scenario>.psd1` is its one same-basename manifest.

A package is standalone upload content. Intune must run each `.ps1` without importing, dot-sourcing, or executing a repository catalog, shared module, or another package. Detection-only packages omit the remediation pair. Keep documentation links aligned with the actual post-cutover paths. The removed `0 - Template/` path is not a valid source or contribution path.

The authoritative standard paths are:

- `build.ps1`: the local quality task interface.
- `standards/ManifestSchema.psd1`: manifest schema, native scalar rules, and approved enum values.
- `standards/FoundationPackages.psd1`: reviewed package metadata used to create and review manifests.
- `tools/RequiredModules.psd1`: pinned Pester and PSScriptAnalyzer versions.
- `tools/RepositoryCatalog.psm1`: inventory, manifest, migration-state, and Markdown-reference validation only; it is never a script runner.
- `tools/RewriteEquivalence.psm1` and `tools/Test-PowerShellRewrite.ps1`: parser-only rewrite-equivalence validation.
- `tests/Repository.Tests.ps1`, `tests/Manifest.Tests.ps1`, and `tests/RewriteEquivalence.Tests.ps1`: repository, manifest, and rewrite behavior tests.
- `evidence/foundation/BaseRevision.txt`, `PathMap.psd1`, `SymbolRenames.psd1`, and `RewriteReport.json`: persisted one-time foundation evidence.
- `evidence/rewrites/<name>/`: opt-in evidence for a later formatting-only rewrite.

## Manifests and metadata

Every deployment `.ps1` must have exactly one `.psd1` sidecar with the same basename. The sidecar must validate against `standards/ManifestSchema.psd1` and describe identity, runtime, behavior, dependencies, configuration, risk, and test metadata.

Manifest files use PowerShell data syntax with native types. Write Boolean values as `$true` or `$false`, numeric coverage as `0.0` or another numeric literal, and arrays as arrays. Do not quote Boolean or numeric values. Required runtime metadata includes Windows PowerShell `5.1` and the supported architecture and run identity. Keep `Identity.Source` and `Identity.Counterpart` consistent with the reviewed package mapping and role.

`Test.Status` is either `PendingMigration` or `Covered`. New scripts require `Status = 'Covered'`, behavioral tests, and a numeric coverage floor. Existing `PendingMigration` scripts remain pending until a later behavior plan supplies appropriate Windows validation and tests. The allowed status transition is one way: `PendingMigration` to `Covered`; never regress a Covered script to PendingMigration. Preserve or raise an established coverage floor rather than silently lowering it.

## Windows PowerShell 5.1 and commands

Windows PowerShell 5.1 is authoritative for deployment behavior, manifest parsing, build tasks, and Pester validation. Use `powershell.exe` on Windows for authoritative results. `pwsh` can provide supplemental feedback, but does not replace the Windows PowerShell 5.1 result.

Bootstrap reads the exact versions from `tools/RequiredModules.psd1`:

```powershell
powershell.exe -NoProfile -File .\build.ps1 -Task Bootstrap
```

From the repository root, use these non-destructive commands:

```powershell
powershell.exe -NoProfile -File .\build.ps1 -Task Validate
powershell.exe -NoProfile -File .\build.ps1 -Task Analyze
powershell.exe -NoProfile -File .\build.ps1 -Task Test
powershell.exe -NoProfile -File .\build.ps1 -Task CheckFormat
```

`ValidateRewrite` is opt-in and requires `-BaseRevision`, `-PathMap`, `-SymbolMap`, and `-ReportPath`. Use the foundation evidence paths only for the one-time cutover, or the corresponding `evidence/rewrites/<name>/` paths for a declared later rewrite:

```powershell
$baseRevision = Get-Content .\evidence\foundation\BaseRevision.txt -Raw
powershell.exe -NoProfile -File .\build.ps1 `
    -Task ValidateRewrite `
    -BaseRevision $baseRevision `
    -PathMap .\evidence\foundation\PathMap.psd1 `
    -SymbolMap .\evidence\foundation\SymbolRenames.psd1 `
    -ReportPath .\evidence\foundation\RewriteReport.json
```

`Validate` inventories deployment scripts, validates every same-basename manifest, parses PowerShell, checks the foundation path and symbol maps, compares generated manifests, and resolves local Markdown links. `Analyze` invokes the pinned PSScriptAnalyzer settings. `Test` runs Pester and enables command coverage for `Covered` scripts. `CheckFormat` verifies formatting without rewriting files. None of these routes may execute a deployment script, and the catalog must never be used to execute one.

## Review and testing rules

For new behavior, add tests that defend observable behavior and boundaries, including compliant and noncompliant detection states and relevant errors. Set `Covered` only when those tests and the required Windows evidence exist. For an existing `PendingMigration` script, preserve the status and describe the later behavior plan instead of claiming coverage.

Review package-specific execution identity, bitness, external tools, policies, URLs, hashes, user impact, reboot behavior, destructive actions, and placeholders. Do not claim a remediation smoke test without a controlled Windows endpoint. Use the repository tests for static, manifest, parser, reference, and tooling checks; they must remain non-destructive.

## Rewrite-equivalence lifecycle

The foundation report is persisted under `evidence/foundation/` and is validated only when the one-time foundation pull request introduces that report. CI regenerates it from `BaseRevision.txt`, `PathMap.psd1`, and `SymbolRenames.psd1`, then compares it with the committed `RewriteReport.json`. Later behavior pull requests inherit the report and do not rerun the fixed baseline.

A later formatting-only rewrite must add its own `evidence/rewrites/<name>/` evidence set, run `ValidateRewrite` explicitly, and commit the deterministic maps and report. Rewrite evidence proves source and destination equivalence; it is not deployment input and must not trigger catalog or script execution.

## Contribution workflow

When adding a package, use the canonical paths, add one manifest per script, write native typed metadata, add behavioral tests, set new manifests to `Covered`, update package links, and run the applicable non-destructive build tasks. When working on an existing package, preserve `PendingMigration` until a behavior plan and Windows evidence support the transition. Keep deployment behavior unchanged when making documentation or standards changes.
