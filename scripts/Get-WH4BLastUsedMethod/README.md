# WH4B last used method

[`Detect-Get-WH4BLastUsedMethod.ps1`](Detect-Get-WH4BLastUsedMethod.ps1) detects the last authentication method used for Windows Hello for Business. This package contains a detection-only script.

Normal states (exit 0)

- `Pin authentication`
- `Fingerprint authentication`
- `Facial authentication`
- `Password authentication`
- `FIDO authentication`

Error states: (exit 1)

- `LastLoggedOnProvider Value is not there`
- `Authentication method cannot be checked`
- `Something went wrong:`

## Usage and examples

In [`Detect-Get-WH4BLastUsedMethod.ps1`](Detect-Get-WH4BLastUsedMethod.ps1), set `$LogDirSubFolderName` to your log folder name. Configure the Intune script to run with logged-on credentials and in 64-bit PowerShell.

Schedule it to run repeatedly, e.g. daily.

## Troubleshooting/Logs

The log file is created in the users temp folder, e.g. `C:\Users\username\AppData\Local\Temp\YOURFOLDERNAME\_WHfB_lastused_method.log`
