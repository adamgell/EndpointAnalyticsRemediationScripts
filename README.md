# Windows Endpoint Remediation Toolkit

A maintained collection of Windows PowerShell detection and remediation packages for Microsoft Intune Endpoint analytics and controlled endpoint administration.

The project is designed for administrators who need to:

- inspect endpoint state with a deterministic detection script;
- correct that state with a paired remediation script;
- review configuration, risk, dependencies, and user impact before deployment;
- validate repository quality with Windows PowerShell 5.1; and
- promote only behavior-tested packages into wider use.

## Project status

The repository currently contains:

- 134 package directories;
- 271 deployment scripts and manifests;
- a canonical package root at `scripts/`; and
- a behavior-coverage migration starting with 34 package directories, approximately 25% of the package inventory.

The foundation path and naming migration is complete. Existing scripts remain `PendingMigration` until their observable detection and remediation behavior has focused tests and the required Windows evidence. See the [25% behavior migration plan](docs/superpowers/plans/2026-08-30-25-percent-behavior-migration.md) for the selected batches and release gates.

## Requirements

- Windows PowerShell 5.1, 64-bit. This is the repository's authoritative validation runtime.
- Git.
- Internet access to install the pinned quality modules from PowerShell Gallery during the first bootstrap.
- Administrator or appropriate endpoint permissions when validating packages whose manifests require elevation.
- A revertible Windows VM for packages with the `WindowsVm` integration tier.
- A logged-on Windows session for packages with the `InteractiveWindows` integration tier.

The deployment packages themselves do not require PowerShell 7. The quality workflow and `go.ps1` target standard Windows PowerShell 5.1 so the validation environment matches the primary Intune administrator experience.

## Quick start

Clone the repository, open Windows PowerShell 5.1, and run from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\go.ps1
```

`go.ps1` runs the complete non-destructive quality sequence:

1. `Bootstrap` installs the pinned Pester and PSScriptAnalyzer versions for the current user.
2. `Validate` checks package discovery, manifests, parsing, path metadata, generated manifests, and repository references.
3. `Analyze` runs the pinned PSScriptAnalyzer configuration.
4. `Test` runs the Pester suite and any covered-package tests.
5. `CheckFormat` verifies the immutable style catalog without rewriting files.

The launcher trusts only the `PSGallery` repository before bootstrapping, so module installation does not prompt once per package. To skip module installation after bootstrap:

```powershell
.\go.ps1 -SkipBootstrap
```

Run the checks before opening a pull request and after changing package code, manifests, tests, or repository tooling.

## Repository layout

```text
scripts/<Package>/                 Deployment packages
  Detect-<Package>.ps1             Detection entry point
  Detect-<Package>.psd1             Detection manifest
  Remediate-<Package>.ps1          Remediation entry point, when applicable
  Remediate-<Package>.psd1          Remediation manifest, when applicable
build.ps1                          Quality task entry point
go.ps1                             One-command local quality launcher
standards/                          Manifest schema and reviewed package metadata
tests/                              Repository and package behavior tests
evidence/                           Immutable foundation and declared rewrite evidence
tools/                              Inventory, manifest, and rewrite tooling
.github/workflows/                  Windows PowerShell quality workflow
```

A package directory is the deployment unit. A detection-only package is valid when its manifest declares that shape. A package with a remediation script must keep detection and remediation manifests paired by `Identity.Counterpart`.

## Using a package

Every package must be reviewed before deployment. Start with the package directory under `scripts/` and read both manifests before copying either script into Intune.

Review:

- `Runtime.PowerShellVersion`, architecture, identity, and run context;
- `Configuration` values and required placeholders;
- `Dependencies` including cmdlets, executables, policies, and endpoints;
- `Risk` level, destructive behavior, user impact, reboot behavior, rollback, and data handling; and
- `Test.Status` and `Test.CoverageFloor`.

A typical Intune deployment flow is:

1. Create a detection and remediation package in Intune.
2. Upload the matching `Detect-*.ps1` and `Remediate-*.ps1` files.
3. Apply the configuration described by the manifest without adding secrets to the repository.
4. Assign the package to a small test group.
5. Confirm detection, remediation, the expected immediate or deferred postcondition, and the endpoint state at the appropriate lifecycle boundary.
6. Expand the assignment only after the pilot evidence and rollback path are understood.

`go.ps1`, `build.ps1`, and the repository catalog never execute deployment entry points. Do not use the quality suite as an endpoint smoke-test runner, and do not run remediation scripts directly on a production device.

## Behavior coverage

`PendingMigration` means the package is inventory- and manifest-valid but does not yet have the required behavioral evidence. It is not a claim that the package is safe for production deployment.

A package can move to `Covered` only after its tests and evidence prove the applicable contract:

- detection handles compliant and noncompliant state;
- missing dependencies and dependency failures produce truthful results;
- detection messages and exit codes match the declared adapter behavior;
- remediation is a no-op when state is already compliant;
- successful remediation converges immediately, or reports a declared deferred postcondition such as reboot or sign-in;
- failed remediation leaves the state noncompliant and reports a nonzero result;
- repeated remediation is idempotent; and
- package-specific safety bounds and failure aggregation are tested.

Lifecycle-deferred behavior must not be simulated as an immediate endpoint transition. In the current migration, `Enforce-CredentialGuard` is `PendingReboot`, `Set-DefaultBrowser` is `PendingSignIn`, `Clear-OutlookCache` reports an unknown cache state after its launch request, and `Get-BatteryHealth` reports optimization/report postconditions while physical health remains deferred/unchanged.

Behavior tests live under `tests/packages/<Scenario>/` and target package-relative paths. They use stateful fakes or disposable files for endpoint boundaries; they must not mutate the developer workstation.

The current migration is split into small batches:

- `registry-state` — registry and policy state packages;
- `security-state` — Defender, SMB, firewall, and event-log packages;
- `service-network` — service, DNS, MTU, and native-command packages; and
- `files-and-browser` — file, report, and default-browser packages.

The migration plan defines the required Windows VM and interactive-session evidence for those tiers. No selected package currently declares `RequiresIntunePilot = $true`; that does not remove Windows VM or logged-on-session requirements from the manifest integration tier.

## Contributing

Before changing a package:

1. Read the complete package directory and both manifests.
2. Keep scripts standalone and preserve the canonical package-relative paths.
3. Update manifests when behavior, dependencies, configuration, risk, or runtime requirements change.
4. Add or update tests under the appropriate `tests/packages/<Scenario>/` directory.
5. Keep secrets, tenant-specific values, and production identifiers out of the repository.
6. Run `Bootstrap`, `Validate`, `Analyze`, `Test`, and `CheckFormat` with Windows PowerShell 5.1.
7. Include the test output and required endpoint evidence in the pull request.

For an existing `PendingMigration` script, do not set `Test.Status = 'Covered'` based only on parsing, manifest, static-analysis, or path checks. Record the behavior work and evidence first. Coverage floors may stay the same or increase; they must not decrease.

Read [CONTRIBUTING.md](CONTRIBUTING.md) for the complete package, manifest, testing, migration, and review rules.

## Safety boundaries

These scripts can change registry settings, services, security controls, network configuration, files, user experience, and reboot state. Before deployment:

- validate the package in a revertible environment;
- confirm the run-as identity and PowerShell bitness;
- review every configured path, URL, executable, and hash;
- understand reboot, service interruption, user-session, and data-loss implications;
- test the remediation failure and rollback path; and
- use a limited Intune assignment ring when the manifest requires an Intune pilot.

The repository is a maintained toolset, not a guarantee that every package is appropriate for every Windows environment. Package owners are responsible for reviewing behavior and operational impact before deployment.

## License

See [LICENSE](LICENSE).
