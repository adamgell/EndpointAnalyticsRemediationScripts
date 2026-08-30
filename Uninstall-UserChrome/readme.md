# Uninstall user Chrome

Run [`Detect-Uninstall-UserChrome.ps1`](Detect-Uninstall-UserChrome.ps1) and, when remediation is required, [`Remediate-Uninstall-UserChrome.ps1`](Remediate-Uninstall-UserChrome.ps1) as the currently logged-on user.
This script looks and removes per-user Chrome installs. Prepare a GoogleChromeEnterprise win32 app and deploy this to the computers. 