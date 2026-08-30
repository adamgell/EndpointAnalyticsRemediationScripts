# Task 7 report: Typed manifests for every runtime script

## Status

`DONE`

Implementation commit `18395ce8ec7a7c5948dfdbdba61abf04f8ce3daf` adds the reviewed manifest registry, deterministic generator, focused tests, and all 271 same-basename sidecars.

Focused test-quality follow-up commit `6f81d269113b548df570adc476c7abc3ffdb7d24` isolates the sentinel-description and quoted-Boolean generator failure paths.

## Scope

- Created `tools/New-ScriptManifest.ps1`.
- Extended `standards/FoundationPackages.psd1` with repository namespace GUID `f5d90edc-dac2-5918-8a09-77c7387264ab` and complete reviewed metadata for all 271 mapped scripts.
- Created exactly 271 deployment `.psd1` sidecars, one beside each deployment `.ps1`.
- Expanded `tests/Manifest.Tests.ps1` with catalog, type, identity, scenario, pairing, metadata, determinism, failure-path, and no-execution coverage.
- Kept the approved 264 paired scripts and seven detection-only scenarios unchanged.
- Did not import, dot-source, or execute any deployment script. Source auditing used text reads and PowerShell AST parsing only.
- Did not change the Task 5 path-map or symbol-map generator logic.

## Metadata audit

Seven nonoverlapping read-only audits covered the authoritative ranges:

| Range | Packages | Scripts |
| --- | ---: | ---: |
| `0` through `Clear-*` | 26 | 50 |
| `Collect-*` through `Get-ConnectedDevices` | 40 | 78 |
| `Get-Device*` through `Invoke-*` | 20 | 38 |
| `Make-*` through `Remove-ConsumerApps` | 9 | 18 |
| `Remove-ProxySettings` through `Reset-*` | 14 | 28 |
| `Restart-*` through `Uninstall-*` | 24 | 47 |
| `Unpin-*` through `Winget-*` | 6 | 12 |
| **Total** | **139** | **271** |

The integration pass reconciled source-backed descriptions, authors, run identity, elevation, signature expectations, Windows support, reboot behavior, detection modes, dependencies, configuration settings, secrets, risk, and test evidence. Evidence-sensitive corrections included native executable classification, explicit reboot operations, destructive behavior, interactive-user requirements, copied header descriptions, and detection-only data handling.

Configuration entries identify secret inputs without storing values. Examples include Autologon passwords, local administrator passwords, blob SAS tokens, Log Analytics shared keys, and Canary Token values.

## Registry and Windows PowerShell 5.1 compatibility

The first large-registry implementation used `Import-PowerShellDataFile -SkipLimitCheck`. CodeRabbit identified that this parameter is unavailable in Windows PowerShell 5.1. The finding was verified against the Microsoft PowerShell 5.1 command reference, which exposes only `Path` and `LiteralPath` and enforces the data-file size limit.

That compatibility path was rejected before commit. The final implementation:

- Removes every `-SkipLimitCheck` use.
- Stores the 271 reviewed records as typed JSON in one single-quoted data-file value.
- Keeps JSON booleans native when parsed.
- Uses fixed 10-field records for deterministic, bounded representation.
- Imports `FoundationPackages.psd1` with ordinary `Import-PowerShellDataFile`.
- Parses the JSON without invoking code.
- Strictly validates every converted field before planning any write.
- Retains a focused Windows-only test that launches the real generator with Windows PowerShell 5.1 and requires 271 outputs.

The Windows PowerShell 5.1 test is skipped on this Darwin workstation and will execute on Windows.

## Deterministic generation

The generator derives only mechanically certain fields:

- UUIDv5 ID from the reviewed pre-cutover `BasePath` and repository namespace.
- Package, script, role, source, and counterpart from `PathMap.psd1`.
- PowerShell `5.1`, `x64`, `PendingMigration`, and numeric `0.0` from the approved standard.
- All other manifest metadata from the reviewed registry.

It rejects:

- Missing mapped metadata.
- Orphan or duplicate metadata.
- Incomplete positional records.
- Missing required nested fields.
- Empty required strings.
- Sentinel values.
- Quoted booleans.
- Invalid enum values.
- Secret configuration values.
- Invalid role or package scenarios.

It validates the entire plan before writing, orders paths with the ordinal comparer, and writes UTF-8 without BOM with LF line endings.

Known stable UUIDv5 checks include:

- `Activate-Numlock/Detect-Activate-Numlock.psd1`: `b82ba3eb-f5f1-5aa1-87bc-8934240b8cdd`
- `Remove-New-Outlook/Detect-Remove-New-Outlook.psd1`: `433c1557-c869-5a1f-9721-4625700f2976`
- `Remove-Silverlight/Detect-Remove-Silverlight.psd1`: `4317dd12-54dc-5265-9bcf-c91e5af8757d`
- `Winget-Update-All/Remediate-Winget-Update-All.psd1`: `f55579b6-afde-5849-80fa-422395418742`

## Test-first evidence

### RED

Command:

```text
pwsh -NoProfile -Command 'Invoke-Pester -Path tests/Manifest.Tests.ps1 -Output Normal'
```

Observed before the generator and sidecars existed:

```text
Tests Passed: 6, Failed: 13, Skipped: 0, Inconclusive: 0, NotRun: 0
```

The failures were the intended missing catalog contract: zero manifests instead of 271, zero reviewed metadata records, and no generator.

### Review-fix mutation RED

The quoted-Boolean validation call was temporarily bypassed without changing any other generator behavior, then only the new quoted-scalar test was run:

```text
pwsh -NoProfile -Command "Invoke-Pester -Path tests/Manifest.Tests.ps1 -FullNameFilter '*quoted Boolean scalar*' -Output Detailed"
```

The test failed on its nonzero-exit assertion, proving that the fixture otherwise passed earlier validation and that removal of the Boolean type rejection is detected:

```text
Expected 0 to be different from the actual value, but got the same value.
Tests Passed: 0, Failed: 1, Skipped: 0, Inconclusive: 0, NotRun: 20
```

The temporary generator mutation was then reverted; `tools/New-ScriptManifest.ps1` is unchanged by the follow-up commit.

### Final focused GREEN

Command:

```text
pwsh -NoProfile -Command 'Invoke-Pester -Path tests/Manifest.Tests.ps1 -Output Detailed'
```

Observed after the focused test-quality correction:

```text
Tests Passed: 20, Failed: 0, Skipped: 1, Inconclusive: 0, NotRun: 0
```

The one skipped test is the Windows PowerShell 5.1 real-generator test because the validation host is Darwin.

The focused suite proves:

- Exactly 271 scripts and 271 sidecars.
- No missing, orphan, or duplicate manifest.
- All 271 sidecars validate against `ManifestSchema.psd1`.
- Native Boolean fields and Double `CoverageFloor` values.
- Exact mapped package, script, role, source, and counterpart identities.
- 264 paired scripts and the exact seven reviewed detection-only scenarios.
- Symmetric counterpart paths.
- 271 unique immutable IDs and stable reviewed versions.
- `PendingMigration` and numeric `0.0` for every script.
- No stored secret values.
- 271 complete reviewed metadata records with no sentinel values.
- Two independent generation roots and the curated catalog are byte-identical by SHA-256.
- A malicious fixture deployment script is not executed.
- Missing metadata, sentinel descriptions, and quoted Boolean metadata each fail through independent inputs; the latter two assert their exact validation errors.

### Named Manifest and Repository validation

Command:

```text
pwsh -NoProfile -Command 'Invoke-Pester -Path tests/Manifest.Tests.ps1,tests/Repository.Tests.ps1 -Output Detailed'
```

Observed after the Windows PowerShell compatibility cutover:

```text
Tests Passed: 40, Failed: 2, Skipped: 1, Inconclusive: 0, NotRun: 0
```

Both remaining failures are the separate known Task 5 post-cutover source-path issue:

```text
Foundation symbol map
[-] regenerates byte-identically when live command discovery is unavailable
[-] regenerates byte-identically when live command discovery is polluted
RuntimeException: Mapped source 'Activate-Numlock/detection_Activate-Numlock.ps1' does not exist.
tools/New-FoundationSymbolMap.ps1:154
```

The expanded registry imports normally before those failures. Task 7 does not suppress or change them.

## Review

CodeRabbit review found the Windows PowerShell 5.1 incompatibility before commit. The implementation replaced that approach with bounded JSON registry storage and plain data-file import.

The subsequent Task 7 quality review found that one combined failure fixture could exit on the sentinel description before reaching the quoted Boolean. Commit `6f81d269113b548df570adc476c7abc3ffdb7d24` replaces it with independent sentinel-only and quoted-Boolean-only inputs and assertions. A temporary validation bypass produced the expected RED failure before the focused suite returned GREEN.

A staged follow-up review covered all 274 Task 7 files. Nine valid findings were applied:

- Recursive sentinel inspection now serializes complete records with sufficient JSON depth.
- The Message Center remediation runs as the logged-on user per its source header.
- Remediation descriptions now describe actual behavior for Uninstall Application, generic registry changes, Disable Coinstaller, and PUA protection.
- Detection-only data handling now distinguishes local reads from remediation transfers for blob copy and profile backup.
- SoftwareDistribution detection now describes its read-only condition.
- Shutdown user impact now states session, service, and unsaved-work consequences.

Eight suggestions were rejected after source verification because they conflicted with the reviewed path map, explicit source headers, the approved seven standalone scenarios, or Task 7 scope. In particular, Task 7 does not rewrite deployment scripts to replace Teams installers or pin external artifacts.

The configured code-simplifier and code-reviewer subagents could not run because their provider returned organization OAuth HTTP 403. CodeRabbit and direct evidence review supplied the independent review path instead.

## Concerns

1. Run the Windows PowerShell 5.1 focused generator test on a Windows host. It is intentionally skipped on Darwin.
2. The two Task 5 symbol-map regeneration failures remain visible and unchanged at `tools/New-FoundationSymbolMap.ps1:154`.
3. Project-wide lint, formatting, build, and unrelated test suites were intentionally skipped as assigned.
