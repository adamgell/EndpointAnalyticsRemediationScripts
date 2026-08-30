# Repository Guidelines

## Project Overview

This repository is a community catalog of standalone Windows PowerShell packages for Microsoft Intune Endpoint Analytics remediation. Each top-level scenario folder is an independent deployment unit, not part of a shared application or module. Review every package before use: several scripts require tenant-specific values, external tools, or destructive endpoint changes.

## Architecture & Data Flow

Intune provides the orchestration layer:

```text
Intune assignment
  -> detection_*.ps1 reads endpoint or user state and writes a short result
     -> exit 0: compliant; stop
     -> exit 1: noncompliant; run the paired remediation script
        -> remediation_*.ps1 changes local state or calls an external service
  -> a later detection run verifies the resulting state
```

The `0 - Template/` pair demonstrates this common contract, but it is a concrete Outlook example rather than a neutral framework. Verify each package because legacy exceptions exist. For example, `Toast-RebootMessage/detection_detect-reboot.ps1` reverses the usual exit behavior.

Scripts execute top to bottom and do not import shared repository code. Dependencies point outward to Windows cmdlets and providers, registry and file state, AppX, services, WinRT or .NET APIs, local executables such as WinGet or Chocolatey, and package-specific HTTP services. Data normally remains endpoint-local; upload and telemetry packages such as `Copy-FilesToBlobStorage/` and `Make-Speedtest/` are explicit exceptions.

## Key Directories

- `0 - Template/`: contribution examples for a detection/remediation pair. Copy the relevant pattern, then replace scenario-specific logic and header metadata.
- Top-level scenario folders such as `Enforce-BitLocker/`, `Add-Winget-App/`, and `Reset Windows Update/`: independent Intune packages. Most contain `detection_*.ps1` and `remediation_*.ps1`; some are detection-only.
- `Change-MultipleRegistryKeys/`: representative configurable pair with matching settings in both scripts and a package README.
- `assets/`: documentation images only. It contains no runtime or deployment assets.

Keep changes scoped to one scenario folder unless root documentation also needs updating. Inspect every file in that folder before changing shared values or behavior.

## Development Commands

The repository defines no install, restore, build, format, lint, type-check, test, packaging, aggregate run, or CI command. It has no manifest, lockfile, task runner, PSScriptAnalyzer settings, or workflow configuration.

Run an individual script only from a controlled Windows environment whose identity and bitness match its header:

```powershell
powershell.exe -NoProfile -File ".\0 - Template\detection_Get-TemplateDetection.ps1"
powershell.exe -NoProfile -File ".\0 - Template\remediation_Get-TemplateRemediaton.ps1"
```

These commands are invocation examples, not repository-defined validation. Do not execute remediation scripts as a routine smoke test: they intentionally change registry values, packages, services, files, profiles, or operating-system state.

## Code Conventions & Common Patterns

- Preserve the local `detection_*.ps1` and `remediation_*.ps1` naming, including established legacy spelling when renaming would break deployment references.
- Put deployment-sensitive settings near the top of each script. If both scripts use a value, keep it synchronized. Examples include `$appid` in `Add-Winget-App/` and `$RegistrySettingsToValidate` in `Change-MultipleRegistryKeys/`.
- Use PowerShell Verb-Noun names for local helpers, such as `Get-ConnectionTest`, `Save-VerifiedDownload`, and `Show-Notification`.
- Prefer explicit sequential control flow. The repository has no async/await, jobs, runspaces, parallel loops, dependency-injection container, shared state store, or common module layer.
- Represent local structured data with variables, arrays, hashtables, or `[pscustomobject]`. Persistent state, when required, belongs in an explicit endpoint path such as `%ProgramData%`, not in repository files.
- For operations that must fail predictably, use `try`/`catch` with `-ErrorAction Stop`, emit a useful `Write-Error` or `Write-Warning`, and set an explicit exit code. Match the neighboring pair's output channel and behavior.
- Keep detection output short and operator-visible. Normally use exit `0` for compliant and exit `1` for remediation required, but preserve and document package-specific contracts.
- Match nearby formatting. Existing brace style, indentation, keyword casing, output cmdlets, and filenames are inconsistent; do not apply repository-wide style normalization in a focused change.
- Preserve integrity checks for downloaded executables. `Profile-cleanup/remediation_remediate-old-profiles.ps1` is the stronger pattern: terminating download errors, SHA-256 verification, cleanup, then execution.
- Never commit real SAS tokens, shared keys, passwords, tenant IDs, customer URLs, or similar environment-specific secrets. Leave clear placeholders and document required configuration.

## Important Files

- `README.md`: project purpose, Intune deployment workflow, contribution path, disclaimer, and license reference.
- `0 - Template/detection_Get-TemplateDetection.ps1`: representative detection entry point and exit-code contract.
- `0 - Template/remediation_Get-TemplateRemediaton.ps1`: representative remediation and `try`/`catch` pattern.
- `Change-MultipleRegistryKeys/README.md`: example of package-specific variable documentation.
- `AutomaticTimezone/readme.md`: example of an external Intune policy prerequisite.
- `Detect-Browser-Passwords/Detect-Browser-Passwords.ps1`: example of a package-specific `sqlite3.exe` prerequisite.
- `Copy-FilesToBlobStorage/remediation_Copy-FilesToBlobStorageRemediation.ps1`: embedded configuration, secret placeholders, REST calls, and persistent marker state.
- `LICENSE`: MIT terms and no-warranty conditions.

Package READMEs can contain stale filenames or paths. Confirm documentation against the actual script names and implementation before relying on it.

## Runtime/Tooling Preferences

- Target Windows and honor each script header's execution identity: System, admin, user, or logged-on user. Registry hive, profile access, toast visibility, and privileges depend on that context.
- Use the documented PowerShell bitness, commonly 64-bit. The repository declares no minimum Windows or PowerShell version and does not establish Windows PowerShell 5.1 versus PowerShell 7 compatibility.
- There is no repository package manager. WinGet, Chocolatey, SQLite, and Office tools are target-machine dependencies of specific packages, not development dependencies.
- Configuration is script-local. There is no `.env`, centralized configuration layer, generated source, or build output.
- Before deployment, verify placeholders, external URLs, hashes, required policies, reboot or user impact, and support for the target Windows release.

## Testing & QA

No automated tests, Pester suite, fixtures, mocks, coverage configuration, or CI QA workflow exist. Directories with `Test` in their names, such as `Test-LAPSUser/` and `Run-ConnectionTest/`, contain deployable scripts rather than test suites.

For each changed package, validate on an appropriate disposable or pilot Windows endpoint:

1. Match the script header's identity and PowerShell bitness.
2. Exercise compliant and noncompliant detection states; record output and process exit code.
3. Run remediation only from the noncompliant state and inspect its output and endpoint side effects.
4. Rerun detection and confirm convergence to the compliant state.
5. Check package-specific logs, external calls, destructive actions, reboot behavior, and user impact.

Do not claim automated coverage. Record the tested Windows/Intune scenario, execution context, observed output, exit codes, and post-remediation state in the change or pull request.