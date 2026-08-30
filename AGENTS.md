# Repository Guidelines

## Project Overview

- This repository is a community catalog of standalone Windows PowerShell packages for Microsoft Intune Endpoint Analytics remediation. Each `scripts/<Package>/` directory is an independent deployment unit with detection and remediation scripts, manifests, and optional package documentation. Review every package before use: several scripts require tenant-specific values, external tools, or destructive endpoint changes.

## Architecture & Data Flow

Intune provides the orchestration layer:

```text
Intune assignment
  -> `scripts/<Package>/Detect-*.ps1` reads endpoint or user state and writes a short result
     -> exit 0: compliant; stop
     -> exit 1: noncompliant; run the paired remediation script
        -> `scripts/<Package>/Remediate-*.ps1` changes local state or calls an external service
  -> a later detection run verifies the resulting state
```

Deployment package discovery and manifest generation are repository concerns. `build.ps1` treats `scripts/` as the deployment root; every deployable `.ps1` has a sibling `.psd1` manifest. Scripts execute top to bottom and do not import shared repository code. Dependencies point outward to Windows cmdlets and providers, registry and file state, AppX, services, WinRT or .NET APIs, local executables such as WinGet or Chocolatey, and package-specific HTTP services. Data normally remains endpoint-local; upload and telemetry packages such as `scripts/Copy-FilesToBlobStorage/` and `scripts/Make-Speedtest/` are explicit exceptions.

## Key Directories

- `scripts/`: deployable Intune packages. Each package directory contains one or more scripts and matching manifests.
- `assets/`: documentation images only. It contains no runtime or deployment assets.
- `evidence/foundation/`: immutable historical evidence for the earlier repository standards cutover.
- `evidence/rewrites/`: declared evidence for later path or formatting rewrites.
- `standards/`: manifest schema, package metadata, and repository policy data.
- `tests/`: Pester tests, fixtures, and repository-contract checks.
- `tools/`: catalog, manifest, and rewrite-validation modules.
- `.github/workflows/`: Windows PowerShell 5.1 quality and rewrite gates.

Keep changes scoped to one package directory unless root documentation or repository tooling also needs updating. Inspect every file in that package before changing shared values or behavior.

## Development Commands

The repository uses Windows PowerShell 5.1 as the authoritative validation runtime:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1 -Task Bootstrap
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1 -Task Validate
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1 -Task Analyze
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1 -Task Test
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1 -Task CheckFormat
```

`Validate` requires every `scripts/<Package>/*.ps1` deployment script to have a matching manifest. `PendingMigration` packages are inventory- and manifest-valid but intentionally have no coverage requirement; `Covered` packages must satisfy the configured coverage gate. `ValidateRewrite` is used in pull requests with the declared base revision, path map, symbol map, and report path.

Run an individual deployment script only from a controlled Windows environment whose identity and bitness match its header:

```powershell
powershell.exe -NoProfile -File ".\scripts\<Package>\Detect-<Package>.ps1"
```

Do not execute remediation scripts as a routine smoke test: they intentionally change registry values, packages, services, files, profiles, or operating-system state.

## Code Conventions & Common Patterns

- Preserve the local `Detect-*.ps1` and `Remediate-*.ps1` naming. Every deployable script has a sibling `.psd1` manifest; preserve established package-specific spelling when renaming would break deployment references.
- Put deployment-sensitive settings near the top of each script. If both scripts use a value, keep it synchronized. Examples include `$appid` in `scripts/Add-Winget-App/` and `$RegistrySettingsToValidate` in `scripts/Change-MultipleRegistryKeys/`.
- Use PowerShell Verb-Noun names for local helpers, such as `Get-ConnectionTest`, `Save-VerifiedDownload`, and `Show-Notification`.
- Prefer explicit sequential control flow. Deployment scripts do not import shared repository code; repository tooling modules under `tools/` support cataloging, manifest generation, and validation.
- Represent local structured data with variables, arrays, hashtables, or `[pscustomobject]`. Persistent state, when required, belongs in an explicit endpoint path such as `%ProgramData%`, not in repository files.
- For operations that must fail predictably, use `try`/`catch` with `-ErrorAction Stop`, emit a useful `Write-Error` or `Write-Warning`, and set an explicit exit code. Match the neighboring package's output channel and behavior.
- Keep detection output short and operator-visible. Normally use exit `0` for compliant and exit `1` for remediation required, but preserve and document package-specific contracts.
- Match nearby formatting and repository gates. Do not apply repository-wide style normalization outside the requested change.
- Preserve integrity checks for downloaded executables. `scripts/Profile-Backup/` is the stronger pattern: terminating download errors, SHA-256 verification, cleanup, then execution.
- Never commit real SAS tokens, shared keys, passwords, tenant IDs, customer URLs, or similar environment-specific secrets. Leave clear placeholders and document required configuration.

## Important Files

- `README.md`: project purpose, Intune deployment workflow, contribution path, disclaimer, and license reference.
- `scripts/Change-MultipleRegistryKeys/README.md`: example of package-specific variable documentation.
- `scripts/AutomaticTimezone/readme.md`: example of an external Intune policy prerequisite.
- `scripts/Browser-Passwords/Detect-Browser-Passwords.ps1`: example of a package-specific `sqlite3.exe` prerequisite.
- `scripts/Copy-FilesToBlobStorage/Remediate-Copy-FilesToBlobStorage.ps1`: embedded configuration, secret placeholders, REST calls, and persistent marker state.
- `standards/ManifestSchema.psd1`: package manifest contract.
- `evidence/foundation/` and `evidence/rewrites/`: immutable and declared rewrite evidence, respectively.
- `LICENSE`: MIT terms and no-warranty conditions.

Package READMEs can contain stale filenames or paths. Confirm documentation against the actual script names and implementation before relying on it.

## Runtime/Tooling Preferences

- Target Windows and honor each script header's execution identity: System, admin, user, or logged-on user. Registry hive, profile access, toast visibility, and privileges depend on that context.
- Use the documented PowerShell bitness, commonly 64-bit. Repository validation is authoritative under Windows PowerShell 5.1; deployment behavior remains governed by each script header and does not imply PowerShell 7 compatibility.
- Bootstrap and validation dependencies are declared in `standards/RequiredModules.psd1`; do not add a repository package manager or commit generated module content.
- Configuration is script-local. There is no `.env`, centralized configuration layer, or generated deployment source.
- Before deployment, verify placeholders, external URLs, hashes, required policies, reboot or user impact, and support for the target Windows release.

## Testing & QA

Automated QA is defined in `build.ps1`, `tests/`, and `.github/workflows/powershell-quality.yml`. Run the repository gates under Windows PowerShell 5.1 before deployment. `Analyze` runs PSScriptAnalyzer; `Test` runs the Pester suite; `CheckFormat` verifies the immutable foundation style catalog; and `Validate` checks package discovery, manifests, path maps, and repository references.

Packages with `Test.Status = 'PendingMigration'` are inventory- and manifest-valid but intentionally have no coverage requirement. Packages with `Test.Status = 'Covered'` must satisfy the configured coverage gate before release.

For each changed package, also validate on an appropriate disposable or pilot Windows endpoint:

1. Match the script header's identity and PowerShell bitness.
2. Exercise compliant and noncompliant detection states; record output and process exit code.
3. Run remediation only from the noncompliant state and inspect its output and endpoint side effects.
4. Rerun detection and confirm convergence to the compliant state.
5. Check package-specific logs, external calls, destructive actions, reboot behavior, and user impact.

Do not execute remediation scripts as a routine repository smoke test. Record the tested Windows/Intune scenario, execution context, observed output, exit codes, and post-remediation state in the change or pull request.