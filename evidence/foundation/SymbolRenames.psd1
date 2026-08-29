@{
    Commands = @(
        @{ Path = 'Add-Winget-App/Detect-Add-Winget-App.ps1'; OldName = 'start-sleep'; NewName = 'Start-Sleep'; Occurrence = 1 }
        @{ Path = 'Add-Winget-App/Detect-Add-Winget-App.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Add-Winget-App/Remediate-Add-Winget-App.ps1'; OldName = 'out-null'; NewName = 'Out-Null'; Occurrence = 1 }
        @{ Path = 'Clear-DownloadFolder-SingleUser/Detect-Clear-DownloadFolder-SingleUser.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Clear-DownloadFolder-SingleUser/Detect-Clear-DownloadFolder-SingleUser.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 2 }
        @{ Path = 'Clear-TeamsCache/Remediate-Clear-TeamsCache.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Create-Laps-LocalAdmin/Detect-Create-Laps-LocalAdmin.ps1'; OldName = 'where-Object'; NewName = 'Where-Object'; Occurrence = 1 }
        @{ Path = 'Create-LocalAdmin/Detect-Create-LocalAdmin.ps1'; OldName = 'where-Object'; NewName = 'Where-Object'; Occurrence = 1 }
        @{ Path = 'Delete-LocalAdmin/Detect-Delete-LocalAdmin.ps1'; OldName = 'where-Object'; NewName = 'Where-Object'; Occurrence = 1 }
        @{ Path = 'Device-Auto-Syncer/Detect-Device-Auto-Syncer.ps1'; OldName = 'GET-DATE'; NewName = 'Get-Date'; Occurrence = 1 }
        @{ Path = 'Disable-SMBv1/Detect-Disable-SMBv1.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Disable-SMBv1/Detect-Disable-SMBv1.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 2 }
        @{ Path = 'Disk-Repair/Detect-Disk-Repair.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Disk-Repair/Detect-Disk-Repair.ps1'; OldName = 'write-output'; NewName = 'Write-Output'; Occurrence = 1 }
        @{ Path = 'Disk-Repair/Detect-Disk-Repair.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 2 }
        @{ Path = 'Enable-DotNet-35/Remediate-Enable-DotNet-35.ps1'; OldName = 'Write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Enable-SignatureValidation/Remediate-Enable-SignatureValidation.ps1'; OldName = 'Out-null'; NewName = 'Out-Null'; Occurrence = 1 }
        @{ Path = 'Enable-SignatureValidation/Remediate-Enable-SignatureValidation.ps1'; OldName = 'new-itemproperty'; NewName = 'New-ItemProperty'; Occurrence = 1 }
        @{ Path = 'Enable-SignatureValidation/Remediate-Enable-SignatureValidation.ps1'; OldName = 'out-null'; NewName = 'Out-Null'; Occurrence = 1 }
        @{ Path = 'Get-Device-Uptime-And-Reboot/Detect-Get-Device-Uptime-And-Reboot.ps1'; OldName = 'get-computerinfo'; NewName = 'Get-ComputerInfo'; Occurrence = 1 }
        @{ Path = 'Get-Device-Uptime-And-Reboot/Remediate-Get-Device-Uptime-And-Reboot.ps1'; OldName = 'get-computerinfo'; NewName = 'Get-ComputerInfo'; Occurrence = 1 }
        @{ Path = 'Install-CMTrace/Remediate-Install-CMTrace.ps1'; OldName = 'invoke-webrequest'; NewName = 'Invoke-WebRequest'; Occurrence = 1 }
        @{ Path = 'Install-WinGet-Apps-From-Url/Detect-Install-WinGet-Apps-From-Url.ps1'; OldName = 'get-content'; NewName = 'Get-Content'; Occurrence = 1 }
        @{ Path = 'Install-WinGet-Apps-From-Url/Detect-Install-WinGet-Apps-From-Url.ps1'; OldName = 'remove-item'; NewName = 'Remove-Item'; Occurrence = 1 }
        @{ Path = 'Install-WinGet-Apps-From-Url/Detect-Install-WinGet-Apps-From-Url.ps1'; OldName = 'select-object'; NewName = 'Select-Object'; Occurrence = 1 }
        @{ Path = 'Install-WinGet-Apps-From-Url/Detect-Install-WinGet-Apps-From-Url.ps1'; OldName = 'get-content'; NewName = 'Get-Content'; Occurrence = 2 }
        @{ Path = 'Install-WinGet-Apps-From-Url/Detect-Install-WinGet-Apps-From-Url.ps1'; OldName = 'remove-item'; NewName = 'Remove-Item'; Occurrence = 2 }
        @{ Path = 'Install-WinGet-Apps-From-Url/Detect-Install-WinGet-Apps-From-Url.ps1'; OldName = 'select-object'; NewName = 'Select-Object'; Occurrence = 2 }
        @{ Path = 'Install-WinGet-Apps-From-Url/Detect-Install-WinGet-Apps-From-Url.ps1'; OldName = 'remove-item'; NewName = 'Remove-Item'; Occurrence = 3 }
        @{ Path = 'Install-WinGet-Apps-From-Url/Remediate-Install-WinGet-Apps-From-Url.ps1'; OldName = 'get-content'; NewName = 'Get-Content'; Occurrence = 1 }
        @{ Path = 'Install-WinGet-Apps-From-Url/Remediate-Install-WinGet-Apps-From-Url.ps1'; OldName = 'remove-item'; NewName = 'Remove-Item'; Occurrence = 1 }
        @{ Path = 'Install-WinGet-Apps-From-Url/Remediate-Install-WinGet-Apps-From-Url.ps1'; OldName = 'rename-item'; NewName = 'Rename-Item'; Occurrence = 1 }
        @{ Path = 'Install-WinGet-Apps-From-Url/Remediate-Install-WinGet-Apps-From-Url.ps1'; OldName = 'select-object'; NewName = 'Select-Object'; Occurrence = 1 }
        @{ Path = 'Install-WinGet-Apps-From-Url/Remediate-Install-WinGet-Apps-From-Url.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Invoke-TeamsInstallation/Remediate-Invoke-TeamsInstallation.ps1'; OldName = 'new-object'; NewName = 'New-Object'; Occurrence = 1 }
        @{ Path = 'Invoke-TeamsReinstallation/Remediate-Invoke-TeamsReinstallation.ps1'; OldName = 'new-object'; NewName = 'New-Object'; Occurrence = 1 }
        @{ Path = 'Profile-Backup/Detect-Profile-Backup.ps1'; OldName = 'get-date'; NewName = 'Get-Date'; Occurrence = 1 }
        @{ Path = 'Profile-Backup/Detect-Profile-Backup.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Profile-Backup/Remediate-Profile-Backup.ps1'; OldName = 'set-Content'; NewName = 'Set-Content'; Occurrence = 1 }
        @{ Path = 'Profile-Cleanup/Detect-Profile-Cleanup.ps1'; OldName = 'get-CimInstance'; NewName = 'Get-CimInstance'; Occurrence = 1 }
        @{ Path = 'Profile-Cleanup/Detect-Profile-Cleanup.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Profile-Cleanup/Detect-Profile-Cleanup.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 2 }
        @{ Path = 'Profile-Cleanup/Remediate-Profile-Cleanup.ps1'; OldName = 'get-CimInstance'; NewName = 'Get-CimInstance'; Occurrence = 1 }
        @{ Path = 'Profile-Cleanup/Remediate-Profile-Cleanup.ps1'; OldName = 'remove-item'; NewName = 'Remove-Item'; Occurrence = 1 }
        @{ Path = 'Profile-Cleanup/Remediate-Profile-Cleanup.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Profile-Cleanup/Remediate-Profile-Cleanup.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 2 }
        @{ Path = 'Remove-New-Outlook/Detect-Remove-New-Outlook.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Remove-New-Outlook/Detect-Remove-New-Outlook.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 2 }
        @{ Path = 'Remove-Teams-Chat/Detect-Remove-Teams-Chat.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Remove-Teams-Chat/Detect-Remove-Teams-Chat.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 2 }
        @{ Path = 'Remove-Teams-Chat/Remediate-Remove-Teams-Chat.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Remove-WindowsBackup/Detect-Remove-WindowsBackup.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Remove-WindowsBackup/Detect-Remove-WindowsBackup.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 2 }
        @{ Path = 'Toast-RebootMessage/Detect-Toast-RebootMessage.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Toast-RebootMessage/Detect-Toast-RebootMessage.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 2 }
        @{ Path = 'Uninstall-Application/Detect-Uninstall-Application.ps1'; OldName = 'write-output'; NewName = 'Write-Output'; Occurrence = 1 }
        @{ Path = 'Uninstall-Application/Detect-Uninstall-Application.ps1'; OldName = 'write-output'; NewName = 'Write-Output'; Occurrence = 2 }
        @{ Path = 'Uninstall-Application/Remediate-Uninstall-Application.ps1'; OldName = 'start-process'; NewName = 'Start-Process'; Occurrence = 1 }
        @{ Path = 'Uninstall-Application/Remediate-Uninstall-Application.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Uninstall-Application/Remediate-Uninstall-Application.ps1'; OldName = 'start-process'; NewName = 'Start-Process'; Occurrence = 2 }
        @{ Path = 'Uninstall-Application/Remediate-Uninstall-Application.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 2 }
        @{ Path = 'Uninstall-Application/Remediate-Uninstall-Application.ps1'; OldName = 'start-process'; NewName = 'Start-Process'; Occurrence = 3 }
        @{ Path = 'Uninstall-Application/Remediate-Uninstall-Application.ps1'; OldName = 'start-process'; NewName = 'Start-Process'; Occurrence = 4 }
        @{ Path = 'Uninstall-UserChrome/Detect-Uninstall-UserChrome.ps1'; OldName = 'write-output'; NewName = 'Write-Output'; Occurrence = 1 }
        @{ Path = 'Uninstall-UserChrome/Detect-Uninstall-UserChrome.ps1'; OldName = 'write-output'; NewName = 'Write-Output'; Occurrence = 2 }
        @{ Path = 'Uninstall-UserChrome/Remediate-Uninstall-UserChrome.ps1'; OldName = 'start-process'; NewName = 'Start-Process'; Occurrence = 1 }
        @{ Path = 'Uninstall-UserChrome/Remediate-Uninstall-UserChrome.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Uninstall-UserChrome/Remediate-Uninstall-UserChrome.ps1'; OldName = 'start-process'; NewName = 'Start-Process'; Occurrence = 2 }
        @{ Path = 'Uninstall-WinGet-Apps-From-Url/Detect-Uninstall-WinGet-Apps-From-Url.ps1'; OldName = 'get-content'; NewName = 'Get-Content'; Occurrence = 1 }
        @{ Path = 'Uninstall-WinGet-Apps-From-Url/Detect-Uninstall-WinGet-Apps-From-Url.ps1'; OldName = 'remove-item'; NewName = 'Remove-Item'; Occurrence = 1 }
        @{ Path = 'Uninstall-WinGet-Apps-From-Url/Detect-Uninstall-WinGet-Apps-From-Url.ps1'; OldName = 'select-object'; NewName = 'Select-Object'; Occurrence = 1 }
        @{ Path = 'Uninstall-WinGet-Apps-From-Url/Detect-Uninstall-WinGet-Apps-From-Url.ps1'; OldName = 'get-content'; NewName = 'Get-Content'; Occurrence = 2 }
        @{ Path = 'Uninstall-WinGet-Apps-From-Url/Detect-Uninstall-WinGet-Apps-From-Url.ps1'; OldName = 'remove-item'; NewName = 'Remove-Item'; Occurrence = 2 }
        @{ Path = 'Uninstall-WinGet-Apps-From-Url/Detect-Uninstall-WinGet-Apps-From-Url.ps1'; OldName = 'select-object'; NewName = 'Select-Object'; Occurrence = 2 }
        @{ Path = 'Uninstall-WinGet-Apps-From-Url/Detect-Uninstall-WinGet-Apps-From-Url.ps1'; OldName = 'remove-item'; NewName = 'Remove-Item'; Occurrence = 3 }
        @{ Path = 'Uninstall-WinGet-Apps-From-Url/Remediate-Uninstall-WinGet-Apps-From-Url.ps1'; OldName = 'get-content'; NewName = 'Get-Content'; Occurrence = 1 }
        @{ Path = 'Uninstall-WinGet-Apps-From-Url/Remediate-Uninstall-WinGet-Apps-From-Url.ps1'; OldName = 'remove-item'; NewName = 'Remove-Item'; Occurrence = 1 }
        @{ Path = 'Uninstall-WinGet-Apps-From-Url/Remediate-Uninstall-WinGet-Apps-From-Url.ps1'; OldName = 'rename-item'; NewName = 'Rename-Item'; Occurrence = 1 }
        @{ Path = 'Uninstall-WinGet-Apps-From-Url/Remediate-Uninstall-WinGet-Apps-From-Url.ps1'; OldName = 'select-object'; NewName = 'Select-Object'; Occurrence = 1 }
        @{ Path = 'Uninstall-WinGet-Apps-From-Url/Remediate-Uninstall-WinGet-Apps-From-Url.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
        @{ Path = 'Unpin-Store/Detect-Unpin-Store.ps1'; OldName = 'write-host'; NewName = 'Write-Host'; Occurrence = 1 }
    )

    Aliases = @(
        @{ Path = 'Check-DiskHealth/Detect-Check-DiskHealth.ps1'; OldName = '?'; NewName = 'Where-Object'; Occurrence = 1 }
        @{ Path = 'Clear-TeamsCache/Remediate-Clear-TeamsCache.ps1'; OldName = 'echo'; NewName = 'Write-Output'; Occurrence = 1 }
        @{ Path = 'Clear-TeamsCache/Remediate-Clear-TeamsCache.ps1'; OldName = 'echo'; NewName = 'Write-Output'; Occurrence = 2 }
        @{ Path = 'Device-Auto-Syncer/Remediate-Device-Auto-Syncer.ps1'; OldName = '?'; NewName = 'Where-Object'; Occurrence = 1 }
        @{ Path = 'Get-CleanUpDisk/Detect-Get-CleanUpDisk.ps1'; OldName = 'Where'; NewName = 'Where-Object'; Occurrence = 1 }
        @{ Path = 'Get-ConnectedDevices/Detect-Get-ConnectedDevices.ps1'; OldName = '%'; NewName = 'ForEach-Object'; Occurrence = 1 }
        @{ Path = 'Remove-ConsumerApps/Detect-Remove-ConsumerApps.ps1'; OldName = 'Where'; NewName = 'Where-Object'; Occurrence = 1 }
        @{ Path = 'Remove-ConsumerApps/Remediate-Remove-ConsumerApps.ps1'; OldName = 'Where'; NewName = 'Where-Object'; Occurrence = 1 }
        @{ Path = 'Remove-ConsumerApps/Remediate-Remove-ConsumerApps.ps1'; OldName = 'Where'; NewName = 'Where-Object'; Occurrence = 2 }
        @{ Path = 'Run-Browser/Remediate-Run-Browser.ps1'; OldName = 'Start'; NewName = 'Start-Process'; Occurrence = 1 }
        @{ Path = 'Toast-RebootMessage/Remediate-Toast-RebootMessage.ps1'; OldName = 'where'; NewName = 'Where-Object'; Occurrence = 1 }
        @{ Path = 'Toast-RebootMessage/Remediate-Toast-RebootMessage.ps1'; OldName = 'where'; NewName = 'Where-Object'; Occurrence = 2 }
    )

    Functions = @(
        @{ Path = 'Enable-RDP/Detect-Enable-RDP.ps1'; OldName = 'IsMember'; NewName = 'Test-GroupMembership' }
        @{ Path = 'Enable-RDP/Remediate-Enable-RDP.ps1'; OldName = 'IsMember'; NewName = 'Test-GroupMembership' }
        @{ Path = 'Get-Device-Uptime-And-Reboot/Remediate-Get-Device-Uptime-And-Reboot.ps1'; OldName = 'Display-ToastNotification'; NewName = 'Show-ToastNotification' }
        @{ Path = 'Make-Speedtest/Remediate-Make-Speedtest.ps1'; OldName = 'Build-Signature'; NewName = 'New-LogAnalyticsSignature' }
        @{ Path = 'Make-Speedtest/Remediate-Make-Speedtest.ps1'; OldName = 'Post-LogAnalyticsData'; NewName = 'Send-LogAnalyticsData' }
    )
}
