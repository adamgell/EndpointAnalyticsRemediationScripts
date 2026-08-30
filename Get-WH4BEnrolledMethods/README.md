# WH4B enrolled methods

[`Detect-Get-WH4BEnrolledMethods.ps1`](Detect-Get-WH4BEnrolledMethods.ps1) detects the Windows Hello for Business enrolled or configured methods and writes pre-remediation detection output.
The output can be any of these states:

Normal states (exit 0)

- `PIN configured`
- `Face and Fingerprint configured`
- `Face configured`
- `Fingerprint configured`
- `Windows Hello not configured`

>If a biometric is configured a PIN is also configured. If a PIN is configured a biometric is not necessarily configured.

Error states: (exit 1)

- `LogonCredsAvailable Value is not there`
- `Unknown Biometric configured`
- `Something went wrong`
- `Uncaught error`

## Usage and examples

In [`Detect-Get-WH4BEnrolledMethods.ps1`](Detect-Get-WH4BEnrolledMethods.ps1), set `$LogDirSubFolderName` to your log folder name. Configure the Intune script to run with logged-on credentials and in 64-bit PowerShell.

Schedule it to run repeatedly, e.g. daily.

## Troubleshooting/Logs

The log file is created in the users temp folder, e.g. `C:\Users\username\AppData\Local\Temp\YOURFOLDERNAME\_WHfB_enrolled_method.log`
