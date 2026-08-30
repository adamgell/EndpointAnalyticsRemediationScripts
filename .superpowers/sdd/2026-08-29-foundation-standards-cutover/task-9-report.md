# Task 9 report: Complete local quality interface

## Status

The public quality interface now keeps normal current-tree validation independent of immutable
foundation Git history. The follow-up correction splits current-tree and baseline symbol-map test
tags, routes `Validate` only to current-tree assertions, and keeps `ValidateRewrite` focused on
the supplied rewrite-equivalence evidence.

## Scope

- `build.ps1` exposes exactly six public task names:
  `Bootstrap`, `Validate`, `Analyze`, `Test`, `CheckFormat`, and opt-in `ValidateRewrite`.
- `Validate` owns inventory, path-map, current symbol-map, manifest, parser, reference, and
  migration checks. Its map Pester invocation selects only `FoundationMapCurrentTree`, so it does
  not load the baseline marker or resolve historical Git blobs.
- `ValidateRewrite` preloads metadata and invokes only the supplied rewrite-equivalence gate.
  Baseline marker, generator, Git blob, replacement-object, and baseline regeneration tests remain
  under the tagged Pester suite rather than being run for every later rewrite.
- `Test` owns the complete Pester suite and command coverage; `Analyze` and `CheckFormat` retain
  their dedicated behavior.
- `tests/Repository.Tests.ps1` preserves the full 271-entry path-map/inventory assertions and
  imported `SymbolRenames.psd1` counts, source-exact values, and deterministic ordering under
  `FoundationMapCurrentTree`.
- The build-interface fixture instruments Pester test execution and a baseline generator sentinel,
  proving an archive-like `Validate` fixture succeeds without invoking baseline regeneration.
  
- An internally matching 270-entry inventory fixture removes one script, its manifest, and its
  path-map row, then must return nonzero with the exact
  `Expected 271 deployment scripts, found 270.` count error.
- The 270-entry fixture asserts that the inventory, manifest, and path-map sets each contain
  exactly 270 entries before invoking `Validate`; removing only the explicit count guard would
  therefore make this regression fail.

- A path-map mismatch fixture must return nonzero with the inventory/path-map error.
- Separate missing-manifest and invalid-manifest fixtures must return nonzero with the manifest
  validation error and controlled affected path.
- A parser-error fixture must return nonzero with the PowerShell parsing error.
- A migration-transition fixture must return nonzero with the invalid migration-state error.
- An unresolved-reference fixture must return nonzero with the unresolved-reference error.
- The Analyze fixture records the recursive `Invoke-ScriptAnalyzer` path, `-Recurse`, and the
  repository settings path.
- The Test fixture records `New-PesterConfiguration`/`Invoke-Pester`, checks the tests path,
  `Run.Exit = $false`, `Run.PassThru = $true`, and a `Covered` script coverage path.
- The CheckFormat fixture records the verification-only Pester invocation (`FoundationStyle`,
  `Detailed`, `PassThru`) and compares SHA256 hashes for both selected files and the complete
  disposable fixture tree before and after the route.
- A disposable Pester module is mutated to return one failed test; the CheckFormat child
  process must return nonzero and preserve the failure message.
- Existing Bootstrap publisher-mismatch and Windows-only fresh-session ValidateRewrite tests
  remain in the BuildInterface block.

## Test-first evidence

### RED

The correction adds a disposable archive-like `Validate` fixture whose `Repository.Tests.ps1`
invokes an instrumented `New-FoundationSymbolMap.ps1` only when the selected tag is
`FoundationMap` or `FoundationMapBaseline`; that generator writes the deployment sentinel and
throws because immutable Git history is intentionally absent. The RED contract is therefore
specific: the former `-Tag FoundationMap` route fails, while the required `-Tag
FoundationMapCurrentTree` route must return success and leave the sentinel absent.

The correction also adds a `ValidateRewrite` fixture that records the supplied
`BaseRevision`, `PathMap`, `SymbolMap`, and `ReportPath` at the rewrite-equivalence gate and
asserts that no map Pester invocation occurs. This keeps later rewrite evidence paths independent
of the fixed foundation baseline. The six supported task names remain accepted in their
documented order, while `ValidateStyle`, `ValidateMaps`, and `ValidateManifests` remain absent
from the `ValidateSet` and therefore rejected by PowerShell parameter binding.

The prior rejection fixtures deliberately make one validation category invalid at a time:
destination path-map mismatch, missing manifest, invalid manifest, parser error, invalid migration
transition, and unresolved reference. Each assertion requires a nonzero child-process exit and the
category-specific failure text, so removing the corresponding production check makes its
regression red.

### Current RED evidence and correction

The supplied `ValidateRewrite` fixture initially wrote an empty `@{}` symbol map. The
production metadata guard reads the contract's `Commands` and `Aliases` collections under
`StrictMode`, so the child process exited 1 before reaching the supplied rewrite-equivalence
gate; the failing assertion was the fixture's `$result.ExitCode | Should -Be 0` check at
`Repository.Tests.ps1:2188`. The route contract is correct, so the fixture now supplies the
valid empty shape `@{ Commands = @(); Aliases = @() }` and still asserts the exact four supplied
rewrite arguments.

The disposable Pester module now returns an authoritative `Result` state in addition to
`FailedCount`. A BuildInterface regression drives `Result = 'Failed'` with `FailedCount = 0`
through `Validate`, `Test`, and `CheckFormat`, requiring each child process to return nonzero.
Production routes accept only `Result = 'Passed'` with zero failed tests; skipped or NotRun counts
remain non-failing when the authoritative result is Passed.

### GREEN

The corrected route requires `Validate` to select only `FoundationMapCurrentTree` while retaining
the 271 inventory, current path-map, current symbol-map, manifest, parser, reference, and
migration checks. `ValidateRewrite` invokes only the supplied rewrite-equivalence gate; it does
not select `FoundationMapBaseline` on every later rewrite. No Pester or other validation command
was run in this worker, per the orchestration contract; controller verification must record the
executed GREEN result.

### Prior GREEN evidence

Focused command:

```text
pwsh -NoProfile -NonInteractive -Command "Import-Module Pester -RequiredVersion 5.7.1; Invoke-Pester -Path './tests/Repository.Tests.ps1' -Tag BuildInterface -Output Detailed"
Tests Passed: 12, Failed: 0, Skipped: 1, Inconclusive: 0, NotRun: 47
```

The prior focused run's one skip was the Windows PowerShell 5.1-only fresh-session
ValidateRewrite regression on Darwin. That run predates this current-tree isolation correction;
the controller must rerun the focused BuildInterface selection to verify the archive-like
`Validate` regression and supplied-evidence `ValidateRewrite` gate.

## Existing route evidence

- Darwin smoke evidence: `build.ps1 -Task Bootstrap` exit 0.
- Darwin smoke evidence: `build.ps1 -Task Analyze` exit 0; recursive analysis reported zero
  findings.
- Darwin smoke evidence: `build.ps1 -Task CheckFormat` exit 0; FoundationStyle reported 13
  passed and 0 failed.
- The complete `Test` route reaches Pester but remains blocked on the existing
  `powershell.exe`-only rewrite tests on Darwin (90 passed, 9 failed, 2 skipped in the prior
  run); this is deliberately not hidden or weakened.
- `Validate` remains correctly blocked by the pre-existing stale README link
  `./0%20-%20Template`; this is a documentation dependency and is deliberately left visible.

## Safety and determinism

- No deployment catalog script is imported, dot-sourced, or executed by the new tests.
- The archive-like regression's instrumented baseline generator writes the same disposable
  sentinel used by the child-process fixture and throws immediately; a successful `Validate`
  therefore proves the baseline generator was not invoked.
- The same malicious sentinel is generated into all 271 disposable deployment scripts. It is
  detected only by invoking the default build route; the test never executes a sentinel script
  itself.
- The 270-entry regression removes one script, its manifest, and its path-map row, and verifies
  the three resulting sets remain internally aligned before invoking the child process.
- Fixture command records are emitted by disposable fake modules, so assertions cover actual
  child-process command paths and arguments rather than source text or mock call counts. The
  success case requires exactly 271 manifest and migration calls and exact path/schema/status
  arguments.
- CheckFormat byte invariance is verified over selected interface files and every file in the
  disposable fixture tree.
- External route failure is asserted through the child-process exit code and category-specific
  error text.

## Final validation and concerns

Current Pester result-state correction:

`77a11d1` — `fix: honor authoritative Pester result state`
- Focused BuildInterface validation against `582aca7` was 12 passed, 0 failed, and 1 expected
  Darwin skip; the new exact-task and integrated-Validate assertions were not present in that
  result.
- No validation command was run for this integration correction, per the orchestration contract.
  Controller verification must run the focused BuildInterface tests and replace this note with
  the actual post-change GREEN result.
- The public build contract is now exactly `Bootstrap`, `Validate`, `Analyze`, `Test`, `CheckFormat`,
  and opt-in `ValidateRewrite`; map and manifest checks have no separate public routes.
- Darwin cannot supply the authoritative Windows PowerShell 5.1 fresh-session rewrite result.
- The complete Test and Validate routes remain subject to their existing platform and repository
  dependencies; these failures must remain visible rather than suppressed.
- The configured code-reviewer agent previously could not run because the organization rejected
  its OAuth request (HTTP 403); focused tests and diff checks were completed locally for
  `582aca7`.

Current baseline-routing correction:

`c46153a` — `build: isolate current-tree validation from baseline`

## Commit

`2696479` — `test: cover Validate inventory count regression`

Prior Task 9 follow-up under test:

`582aca7` — `test: strengthen Validate interface regressions`
Previous Task 9 implementation:

`182d21d` — `test: cover build quality interface contracts`

Parent production implementation:

`9c4cac6` — `build: add repository quality commands`

Current BuildInterface fixture-schema correction:

- The disposable `Invoke-Pester` recorder now emits a `Configuration` property initialized to
  `$null` for verification-style calls, then replaces it with the captured configuration for
  integrated test calls.
- This keeps strict-mode record filtering for the integrated `Validate` map invocation and
  `CheckFormat` invocation deterministic without allowing a missing property to masquerade as
  the wrong command or argument dispatch.
- No validation command was run in this worker, per the orchestration contract; controller
  verification must run the focused BuildInterface selection.

Windows PowerShell 5.1-only tests now skip when the required `powershell.exe` is absent, while
remaining active on Windows hosts that provide the executable. This applies to the fresh
`ValidateRewrite` preflight and deterministic manifest-generation coverage; non-Windows behavior
is unchanged.
