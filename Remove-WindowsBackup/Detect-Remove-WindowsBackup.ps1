$filepath = "C:\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\WindowsBackup\Assets"
if (Test-Path $filepath) {
    Write-Host "It's there, kill it"
    exit 1
}
else {
    Write-Host "All good, relax"
    exit 0
}
