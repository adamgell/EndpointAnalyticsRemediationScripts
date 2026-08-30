# 25% behavior migration plan

## Scope

Migrate 34 complete package directories from `PendingMigration` to `Covered` after focused behavior tests and required Windows validation pass.

- Repository inventory: 134 package directories and 271 deployment scripts.
- Selection denominator: package directories, not the 271 individual scripts.
- Rounding rule: round up to the next complete package directory, `ceil(134 * 0.25) = 34`.
- Selected scope: 34 package directories and 68 deployment scripts.
- Approximate coverage: 25.4% of package directories and 25.1% of deployment scripts.
- Manifest-driven cohort: all selected detection manifests declare `Risk = 'Low'`, `RequiresIntunePilot = $false`, and a `WindowsVm` or `InteractiveWindows` integration tier; the cohort contains 33 `WindowsVm` packages and the one logged-on-session `InteractiveWindows` package.
- Every selected directory has one detection script and one remediation script.
- Every selected manifest currently reports `Test.Status = 'PendingMigration'`.
- Every selected manifest reports `Test.RequiresIntunePilot = $false`.

The selection is partitioned by declared behavior surface into four test batches so registry, security, service/network, and file/browser boundaries can be validated coherently. It does not conflate package-directory coverage with script-count coverage.

## Selected packages

| Package | Primary behavior surface | Integration tier | Pilot |
|---|---|---|---|
| `Activate-Numlock` | HKU `.DEFAULT` keyboard registry state | InteractiveWindows | No |
| `AutomaticTimezone` | Location consent and time-zone registry state | WindowsVm | No |
| `BlockAADWorkplaceJoin` | Workplace-join registry policy state | WindowsVm | No |
| `Clear-DnsCache` | Unconditional noncompliant detection and `ipconfig` remediation | WindowsVm | No |
| `Clear-OutlookCache` | Outlook launch request and deferred cache observation | WindowsVm | No |
| `Disable-Coinstaller` | Device Installer registry state | WindowsVm | No |
| `Disable-Fastboot` | Hiberboot registry state | WindowsVm | No |
| `Disable-LegacyTLS` | SCHANNEL TLS 1.0/1.1 registry state | WindowsVm | No |
| `Disable-SMBv1` | SMB server configuration cmdlets | WindowsVm | No |
| `Disable-StartMenuWebSearch` | Current-user Start menu registry state | WindowsVm | No |
| `Enable-DarkMode` | Current-user personalization registry state | WindowsVm | No |
| `Enable-DNSOperationalLogs` | DNS event-log state and save operation | WindowsVm | No |
| `Enforce-CredentialGuard` | Device Guard registry state | WindowsVm | No |
| `Enforce-DOH` | DNS client DoH registry state | WindowsVm | No |
| `Enforce-SMB-Signing` | LanManWorkstation registry state | WindowsVm | No |
| `Enforce-WindowsFirewall` | Firewall profile state | WindowsVm | No |
| `Fortinet-VPN-Profile` | Fortinet VPN registry profile state | WindowsVm | No |
| `Get-Always-Elevated` | Installer elevation registry state | WindowsVm | No |
| `Get-BatteryHealth` | Battery report and power configuration commands | WindowsVm | No |
| `Get-CloudDeliveredProtection` | Defender MAPS and sample-submission state | WindowsVm | No |
| `Get-LSA-Protection` | LSA protection registry state | WindowsVm | No |
| `Get-NetworkProtection` | Defender network-protection state | WindowsVm | No |
| `Get-OfficeTelemetry` | Office telemetry registry state | WindowsVm | No |
| `Get-PUA-Protection` | Defender PUA protection state | WindowsVm | No |
| `Get-RealTimeBehaviour` | Defender behavior-monitor state | WindowsVm | No |
| `Get-RealTimeProtection` | Defender real-time protection state | WindowsVm | No |
| `Invoke-DnsClearCache` | Unconditional remediation and DNS cache clear cmdlet | WindowsVm | No |
| `Restart-Service-Generic` | Generic service state and restart operation | WindowsVm | No |
| `Restart-Windows-Search-Service` | Windows Search service state and restart operation | WindowsVm | No |
| `Restart-Windows-Update-Service` | Windows Update service state and restart operation | WindowsVm | No |
| `Set-Cached-Logon-Count-0` | Winlogon cached-logon registry state | WindowsVm | No |
| `Set-DefaultBrowser` | UserChoice registry state and default-association policy file | WindowsVm | No |
| `Set-MTU-Optimal` | Connected-interface MTU state | WindowsVm | No |
| `Set-Service-Generic` | Generic service property state | WindowsVm | No |

## Behavior-test contract

Tests live under `tests/packages/<Scenario>/` and identify each target by its package-relative path. The selected set is delivered in four small batches:

1. `tests/packages/registry-state/`: Activate-Numlock, AutomaticTimezone, BlockAADWorkplaceJoin, Disable-Coinstaller, Disable-Fastboot, Disable-LegacyTLS, Disable-StartMenuWebSearch, Enable-DarkMode, Enforce-CredentialGuard, Enforce-DOH, Enforce-SMB-Signing, Fortinet-VPN-Profile, Get-Always-Elevated, Get-LSA-Protection, Get-OfficeTelemetry, Set-Cached-Logon-Count-0.
2. `tests/packages/security-state/`: Disable-SMBv1, Enable-DNSOperationalLogs, Enforce-WindowsFirewall, Get-CloudDeliveredProtection, Get-NetworkProtection, Get-PUA-Protection, Get-RealTimeBehaviour, Get-RealTimeProtection.
3. `tests/packages/service-network/`: Clear-DnsCache, Invoke-DnsClearCache, Restart-Service-Generic, Restart-Windows-Search-Service, Restart-Windows-Update-Service, Set-MTU-Optimal, Set-Service-Generic.
4. `tests/packages/files-and-browser/`: Clear-OutlookCache, Get-BatteryHealth, Set-DefaultBrowser.

Each applicable detection script tests:

- compliant state;
- noncompliant state;
- missing dependency;
- dependency failure;
- stable operator message;
- correct adapter exit mapping for its declared detection mode.

Each remediation script tests:

- already-compliant no-op;
- successful state change followed by compliant detection when convergence is immediate, or by its declared deferred postcondition;
- failed state change followed by noncompliance;
- truthful error output and nonzero adapter mapping;
- idempotence;
- package-specific exclusions, safety bounds, and failure aggregation.

Tests assert structured decisions and resulting state, not only command invocation. Use real temporary files for file behavior and stateful fakes for registry, services, Defender, event-log, and network-interface state. Mock only explicit operating-system or external boundaries. Never run a deployment entry point against the developer workstation.

The selected set includes lifecycle-deferred contracts that must not fabricate endpoint transitions:

- `Clear-OutlookCache` reports an unknown cache state after a successful Outlook launch request.
- `Enforce-CredentialGuard` reports `PendingReboot` after registry convergence; running services are verified only after reboot.
- `Get-BatteryHealth` reports optimization/report postconditions while physical battery health remains deferred/unchanged.
- `Set-DefaultBrowser` reports `PendingSignIn` after association-file and policy convergence; `UserChoice` is verified only after sign-in.

Known behavior observations belong in the plan and test evidence. A discovered defect that changes intended behavior requires a separate fix and regression test before coverage is claimed.

## Validation gate

Run from the repository root with Windows PowerShell 5.1:

```powershell
.\go.ps1
```

The result must pass `Bootstrap`, `Validate`, `Analyze`, `Test`, and `CheckFormat`. In addition, run the focused behavior tests directly if they are not already included in `Test`.

## Endpoint evidence gate

No selected manifest requires an Intune pilot, so Intune assignment evidence is not required for this set. The `WindowsVm` packages still require evidence from a revertible Windows VM for their declared registry, service, Defender, event-log, file, and native-command behavior. The `InteractiveWindows` package (`Activate-Numlock`) requires a logged-on Windows session; it must not be validated as a noninteractive `System` deployment.

Collect evidence per batch for the real endpoint state before and after the controlled operation, including a second detection pass proving convergence, a failed-operation result where the boundary can be safely fault-injected, and an idempotent second remediation pass. Preserve the VM snapshot/identity, PowerShell version, package-relative script paths, command output, exit codes, and rollback result in the pull request evidence. Do not run high-impact operations on a production device.

If a focused test or VM run reveals that the manifest's integration, user-context, configuration, or safety declaration is inaccurate, pause coverage for that script and correct the manifest or obtain the required additional evidence before marking it `Covered`.

## Coverage release gate

Only after the full behavior test matrix and Windows PowerShell 5.1 validation pass:

1. update the 68 selected manifests from `PendingMigration` to `Covered`;
2. set each selected manifest's `CoverageFloor` to the measured focused-test floor;
3. record the test command and result in the pull request;
4. rerun `Validate`, `Analyze`, `Test`, and `CheckFormat`;
5. leave all unselected scripts and manifests at `PendingMigration`.
