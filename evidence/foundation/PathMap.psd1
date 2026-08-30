@{
    Paths = @(
        @{
            BasePath = 'Activate-Numlock/detection_Activate-Numlock.ps1'
            NewPath = 'Activate-Numlock/Detect-Activate-Numlock.ps1'
        }
        @{
            BasePath = 'Activate-Numlock/remediation_Activate-Numlock.ps1'
            NewPath = 'Activate-Numlock/Remediate-Activate-Numlock.ps1'
        }
        @{
            BasePath = 'Add-Winget-App/detection_detect-app.ps1'
            NewPath = 'Add-Winget-App/Detect-Add-Winget-App.ps1'
        }
        @{
            BasePath = 'Add-Winget-App/remediation_remediate-app.ps1'
            NewPath = 'Add-Winget-App/Remediate-Add-Winget-App.ps1'
        }
        @{
            BasePath = 'Detect-AdminUsers/detection_detect-adminusers.ps1'
            NewPath = 'Admin-Users/Detect-Admin-Users.ps1'
        }
        @{
            BasePath = 'Detect-AdminUsers/remediation_remove-adminusers.ps1'
            NewPath = 'Admin-Users/Remediate-Admin-Users.ps1'
        }
        @{
            BasePath = 'Detect-Autologon/detection_Detect-AutologonDetection.ps1'
            NewPath = 'Autologon/Detect-Autologon.ps1'
        }
        @{
            BasePath = 'Detect-Autologon/remediation_Detect-AutologonRemediation.ps1'
            NewPath = 'Autologon/Remediate-Autologon.ps1'
        }
        @{
            BasePath = 'AutomaticTimezone/detection_detect-automatictimezone.ps1'
            NewPath = 'AutomaticTimezone/Detect-AutomaticTimezone.ps1'
        }
        @{
            BasePath = 'AutomaticTimezone/remediation_remediate-automatictimezone.ps1'
            NewPath = 'AutomaticTimezone/Remediate-AutomaticTimezone.ps1'
        }
        @{
            BasePath = 'BlackLotus-Mitigation/detection_BlackLotus-MitigationDetection.ps1'
            NewPath = 'BlackLotus-Mitigation/Detect-BlackLotus-Mitigation.ps1'
        }
        @{
            BasePath = 'BlackLotus-Mitigation/remediation_BlackLotus-MitigationRemediation.ps1'
            NewPath = 'BlackLotus-Mitigation/Remediate-BlackLotus-Mitigation.ps1'
        }
        @{
            BasePath = 'BlockAADWorkplaceJoin/detection_Detection-BlockAADWorkplaceJoin.ps1'
            NewPath = 'BlockAADWorkplaceJoin/Detect-BlockAADWorkplaceJoin.ps1'
        }
        @{
            BasePath = 'BlockAADWorkplaceJoin/remediation_Remediation-BlockAADWorkplaceJoin.ps1'
            NewPath = 'BlockAADWorkplaceJoin/Remediate-BlockAADWorkplaceJoin.ps1'
        }
        @{
            BasePath = 'Detect-BlueScreenHistory/detection_detect-bluescreenhistory.ps1'
            NewPath = 'Blue-Screen-History/Detect-Blue-Screen-History.ps1'
        }
        @{
            BasePath = 'Detect-BlueScreenHistory/remediation_analyze-bluescreens.ps1'
            NewPath = 'Blue-Screen-History/Remediate-Blue-Screen-History.ps1'
        }
        @{
            BasePath = 'Detect-Browser-Passwords/Detect-Browser-Passwords.ps1'
            NewPath = 'Browser-Passwords/Detect-Browser-Passwords.ps1'
        }
        @{
            BasePath = 'Detect-CertificateExpiry/detection_detect-certificateexpiry.ps1'
            NewPath = 'Certificate-Expiry/Detect-Certificate-Expiry.ps1'
        }
        @{
            BasePath = 'Detect-CertificateExpiry/remediation_remove-expiredcertificates.ps1'
            NewPath = 'Certificate-Expiry/Remediate-Certificate-Expiry.ps1'
        }
        @{
            BasePath = 'Change-MultipleRegistryKeys/detection_Change-MultipleRegistryKeysDetection.ps1'
            NewPath = 'Change-MultipleRegistryKeys/Detect-Change-MultipleRegistryKeys.ps1'
        }
        @{
            BasePath = 'Change-MultipleRegistryKeys/remediation_Change-MultipleRegistryKeysRemediaton.ps1'
            NewPath = 'Change-MultipleRegistryKeys/Remediate-Change-MultipleRegistryKeys.ps1'
        }
        @{
            BasePath = 'Change-Registry-Key-Generic/detection_detect-regkey.ps1'
            NewPath = 'Change-Registry-Key-Generic/Detect-Change-Registry-Key-Generic.ps1'
        }
        @{
            BasePath = 'Change-Registry-Key-Generic/remediation_remediate-regkey.ps1'
            NewPath = 'Change-Registry-Key-Generic/Remediate-Change-Registry-Key-Generic.ps1'
        }
        @{
            BasePath = 'Check-DiskHealth/detection_Get-TemplateDetection.ps1'
            NewPath = 'Check-DiskHealth/Detect-Check-DiskHealth.ps1'
        }
        @{
            BasePath = 'Check-PNPDevices/detection_Check-PNPDevicesDetection.ps1'
            NewPath = 'Check-PNPDevices/Detect-Check-PNPDevices.ps1'
        }
        @{
            BasePath = 'Check-PNPDevices/remediation_Check-PNPDevicesRemediation.ps1'
            NewPath = 'Check-PNPDevices/Remediate-Check-PNPDevices.ps1'
        }
        @{
            BasePath = 'Clear-BrowserCache/detection_Clear-BrowserCacheDetection.ps1'
            NewPath = 'Clear-BrowserCache/Detect-Clear-BrowserCache.ps1'
        }
        @{
            BasePath = 'Clear-BrowserCache/remediation_Clear-BrowserCacheRemediation.ps1'
            NewPath = 'Clear-BrowserCache/Remediate-Clear-BrowserCache.ps1'
        }
        @{
            BasePath = 'Clear-BrowserExtensions/detection_detect-browserextensions.ps1'
            NewPath = 'Clear-BrowserExtensions/Detect-Clear-BrowserExtensions.ps1'
        }
        @{
            BasePath = 'Clear-BrowserExtensions/remediation_clear-browserextensions.ps1'
            NewPath = 'Clear-BrowserExtensions/Remediate-Clear-BrowserExtensions.ps1'
        }
        @{
            BasePath = 'Clear-DnsCache/detection_Clear-DnsCacheDetection.ps1'
            NewPath = 'Clear-DnsCache/Detect-Clear-DnsCache.ps1'
        }
        @{
            BasePath = 'Clear-DnsCache/remediation_Clear-DnsCacheRemediation.ps1'
            NewPath = 'Clear-DnsCache/Remediate-Clear-DnsCache.ps1'
        }
        @{
            BasePath = 'Clear-DownloadFolder-SingleUser/detection_Clear-DownloadFolderDetection.ps1'
            NewPath = 'Clear-DownloadFolder-SingleUser/Detect-Clear-DownloadFolder-SingleUser.ps1'
        }
        @{
            BasePath = 'Clear-DownloadFolder-SingleUser/remediation_Clear-DownloadFolderRemediaton.ps1'
            NewPath = 'Clear-DownloadFolder-SingleUser/Remediate-Clear-DownloadFolder-SingleUser.ps1'
        }
        @{
            BasePath = 'Clear-DownloadFolder/detection_Clear-DownloadFolderDetection.ps1'
            NewPath = 'Clear-DownloadFolder/Detect-Clear-DownloadFolder.ps1'
        }
        @{
            BasePath = 'Clear-DownloadFolder/remediation_Clear-DownloadFolderRemediaton.ps1'
            NewPath = 'Clear-DownloadFolder/Remediate-Clear-DownloadFolder.ps1'
        }
        @{
            BasePath = 'Clear-FontCache/detection_detect-fontcache.ps1'
            NewPath = 'Clear-FontCache/Detect-Clear-FontCache.ps1'
        }
        @{
            BasePath = 'Clear-FontCache/remediation_clear-fontcache.ps1'
            NewPath = 'Clear-FontCache/Remediate-Clear-FontCache.ps1'
        }
        @{
            BasePath = 'Clear-OutlookCache/detection_Clear-OutlookCacheDetection.ps1'
            NewPath = 'Clear-OutlookCache/Detect-Clear-OutlookCache.ps1'
        }
        @{
            BasePath = 'Clear-OutlookCache/remediation_Clear-OutlookCacheRemedaiton.ps1'
            NewPath = 'Clear-OutlookCache/Remediate-Clear-OutlookCache.ps1'
        }
        @{
            BasePath = 'Clear-TeamsCache/detection_Clear-TeamsCacheDetection.ps1'
            NewPath = 'Clear-TeamsCache/Detect-Clear-TeamsCache.ps1'
        }
        @{
            BasePath = 'Clear-TeamsCache/remediation_Clear-TeamsCacheRemedaiton.ps1'
            NewPath = 'Clear-TeamsCache/Remediate-Clear-TeamsCache.ps1'
        }
        @{
            BasePath = 'Clear-TempFiles-Advanced/detection_detect-tempfiles.ps1'
            NewPath = 'Clear-TempFiles-Advanced/Detect-Clear-TempFiles-Advanced.ps1'
        }
        @{
            BasePath = 'Clear-TempFiles-Advanced/remediation_clear-tempfiles.ps1'
            NewPath = 'Clear-TempFiles-Advanced/Remediate-Clear-TempFiles-Advanced.ps1'
        }
        @{
            BasePath = 'Clear-WindowsUpdateCache/detection_detect-windowsupdatecache.ps1'
            NewPath = 'Clear-WindowsUpdateCache/Detect-Clear-WindowsUpdateCache.ps1'
        }
        @{
            BasePath = 'Clear-WindowsUpdateCache/remediation_clear-windowsupdatecache.ps1'
            NewPath = 'Clear-WindowsUpdateCache/Remediate-Clear-WindowsUpdateCache.ps1'
        }
        @{
            BasePath = 'Collect-EventLogErrors/detection_detect-eventlogerrors.ps1'
            NewPath = 'Collect-EventLogErrors/Detect-Collect-EventLogErrors.ps1'
        }
        @{
            BasePath = 'Collect-EventLogErrors/remediation_collect-eventlogerrors.ps1'
            NewPath = 'Collect-EventLogErrors/Remediate-Collect-EventLogErrors.ps1'
        }
        @{
            BasePath = 'Copy-FilesToBlobStorage/detection_Copy-FilesToBlobStorageDetection.ps1'
            NewPath = 'Copy-FilesToBlobStorage/Detect-Copy-FilesToBlobStorage.ps1'
        }
        @{
            BasePath = 'Copy-FilesToBlobStorage/remediation_Copy-FilesToBlobStorageRemediation.ps1'
            NewPath = 'Copy-FilesToBlobStorage/Remediate-Copy-FilesToBlobStorage.ps1'
        }
        @{
            BasePath = 'Create-LocalAdmin/detection_Create-LocalAdminLAPSDetection.ps1'
            NewPath = 'Create-Laps-LocalAdmin/Detect-Create-Laps-LocalAdmin.ps1'
        }
        @{
            BasePath = 'Create-LocalAdmin/remediation_Create-LocalAdminLAPSRemediation.ps1'
            NewPath = 'Create-Laps-LocalAdmin/Remediate-Create-Laps-LocalAdmin.ps1'
        }
        @{
            BasePath = 'Create-LocalAdmin/detection_Create-LocalAdminDetection.ps1'
            NewPath = 'Create-LocalAdmin/Detect-Create-LocalAdmin.ps1'
        }
        @{
            BasePath = 'Create-LocalAdmin/remediation_Create-LocalAdminRemediation.ps1'
            NewPath = 'Create-LocalAdmin/Remediate-Create-LocalAdmin.ps1'
        }
        @{
            BasePath = 'Defrag-SSD-Trim/detection_detect-diskoptimization.ps1'
            NewPath = 'Defrag-SSD-Trim/Detect-Defrag-SSD-Trim.ps1'
        }
        @{
            BasePath = 'Defrag-SSD-Trim/remediation_optimize-disk.ps1'
            NewPath = 'Defrag-SSD-Trim/Remediate-Defrag-SSD-Trim.ps1'
        }
        @{
            BasePath = 'Create-LocalAdmin/detection_Delete-LocalAdminDetection.ps1'
            NewPath = 'Delete-LocalAdmin/Detect-Delete-LocalAdmin.ps1'
        }
        @{
            BasePath = 'Create-LocalAdmin/remediation_Delete-LocalAdminRemediation.ps1'
            NewPath = 'Delete-LocalAdmin/Remediate-Delete-LocalAdmin.ps1'
        }
        @{
            BasePath = 'Device Auto-Syncer/detection_AutoSyncDetect.ps1'
            NewPath = 'Device-Auto-Syncer/Detect-Device-Auto-Syncer.ps1'
        }
        @{
            BasePath = 'Device Auto-Syncer/remediation_AutoSyncRemediate.ps1'
            NewPath = 'Device-Auto-Syncer/Remediate-Device-Auto-Syncer.ps1'
        }
        @{
            BasePath = 'Disable-Coinstaller/detection_detect-coinstaller.ps1'
            NewPath = 'Disable-Coinstaller/Detect-Disable-Coinstaller.ps1'
        }
        @{
            BasePath = 'Disable-Coinstaller/remediation_remediate-coinstaller.ps1'
            NewPath = 'Disable-Coinstaller/Remediate-Disable-Coinstaller.ps1'
        }
        @{
            BasePath = 'Enable-DeliveryOptimizationVerboseLogging/detection_Disable-VerboseLoggingDetection.ps1'
            NewPath =
            'Disable-Delivery-Optimization-Verbose-Logging/Detect-Disable-Delivery-Optimization-Verbose-Logging.ps1'
        }
        @{
            BasePath = 'Enable-DeliveryOptimizationVerboseLogging/remediation_Disable-VerboseLoggingRemedaiton.ps1'
            NewPath =
            'Disable-Delivery-Optimization-Verbose-Logging/Remediate-Disable-Delivery-Optimization-Verbose-Logging.ps1'
        }
        @{
            BasePath = 'Disable-Fastboot/detection_detect-fastboot.ps1'
            NewPath = 'Disable-Fastboot/Detect-Disable-Fastboot.ps1'
        }
        @{
            BasePath = 'Disable-Fastboot/remediation_remediate-fastboot.ps1'
            NewPath = 'Disable-Fastboot/Remediate-Disable-Fastboot.ps1'
        }
        @{
            BasePath = 'Disable-LegacyTLS/detection_detect-legacytls.ps1'
            NewPath = 'Disable-LegacyTLS/Detect-Disable-LegacyTLS.ps1'
        }
        @{
            BasePath = 'Disable-LegacyTLS/remediation_disable-legacytls.ps1'
            NewPath = 'Disable-LegacyTLS/Remediate-Disable-LegacyTLS.ps1'
        }
        @{
            BasePath = 'Disable-SMBv1/detection_detect-smbv1.ps1'
            NewPath = 'Disable-SMBv1/Detect-Disable-SMBv1.ps1'
        }
        @{
            BasePath = 'Disable-SMBv1/remediation_remediate-smbv1.ps1'
            NewPath = 'Disable-SMBv1/Remediate-Disable-SMBv1.ps1'
        }
        @{
            BasePath = 'Disable-StartMenuWebSearch/detection_detect-WebSearch.ps1'
            NewPath = 'Disable-StartMenuWebSearch/Detect-Disable-StartMenuWebSearch.ps1'
        }
        @{
            BasePath = 'Disable-StartMenuWebSearch/remediation_remediate-WebSearch.ps1'
            NewPath = 'Disable-StartMenuWebSearch/Remediate-Disable-StartMenuWebSearch.ps1'
        }
        @{
            BasePath = 'Disk-Repair/detection_detect-diskrepair.ps1'
            NewPath = 'Disk-Repair/Detect-Disk-Repair.ps1'
        }
        @{
            BasePath = 'Detect-DriverIssues/detection_detect-driverissues.ps1'
            NewPath = 'Driver-Issues/Detect-Driver-Issues.ps1'
        }
        @{
            BasePath = 'Detect-DriverIssues/remediation_fix-driverissues.ps1'
            NewPath = 'Driver-Issues/Remediate-Driver-Issues.ps1'
        }
        @{
            BasePath = 'Enable-DNSOperationalLogs/detection_Enable-DNSOperationalLogsDetection.ps1'
            NewPath = 'Enable-DNSOperationalLogs/Detect-Enable-DNSOperationalLogs.ps1'
        }
        @{
            BasePath = 'Enable-DNSOperationalLogs/remediation_Enable-DNSOperationalLogsRemediation.ps1'
            NewPath = 'Enable-DNSOperationalLogs/Remediate-Enable-DNSOperationalLogs.ps1'
        }
        @{
            BasePath = 'Enable-DarkMode/detection_detect-darkmode.ps1'
            NewPath = 'Enable-DarkMode/Detect-Enable-DarkMode.ps1'
        }
        @{
            BasePath = 'Enable-DarkMode/remediation_enable-darkmode.ps1'
            NewPath = 'Enable-DarkMode/Remediate-Enable-DarkMode.ps1'
        }
        @{
            BasePath = 'Enable-DeliveryOptimizationVerboseLogging/detection_Enable-VerboseLoggingDetection.ps1'
            NewPath =
            'Enable-Delivery-Optimization-Verbose-Logging/Detect-Enable-Delivery-Optimization-Verbose-Logging.ps1'
        }
        @{
            BasePath = 'Enable-DeliveryOptimizationVerboseLogging/remediation_Enable-VerboseLoggingRemedaiton.ps1'
            NewPath =
            'Enable-Delivery-Optimization-Verbose-Logging/Remediate-Enable-Delivery-Optimization-Verbose-Logging.ps1'
        }
        @{
            BasePath = 'Enable-DotNet-35/detection_DetectDotNet35.ps1'
            NewPath = 'Enable-DotNet-35/Detect-Enable-DotNet-35.ps1'
        }
        @{
            BasePath = 'Enable-DotNet-35/remediation_RemediateDotNet35.ps1'
            NewPath = 'Enable-DotNet-35/Remediate-Enable-DotNet-35.ps1'
        }
        @{
            BasePath = 'Enable-RDP/detection_Enable-RDPDetection.ps1'
            NewPath = 'Enable-RDP/Detect-Enable-RDP.ps1'
        }
        @{
            BasePath = 'Enable-RDP/remediation_Enable-RDPRemedaiton.ps1'
            NewPath = 'Enable-RDP/Remediate-Enable-RDP.ps1'
        }
        @{
            BasePath = 'Enable-SignatureValidation/detection_Detect_Signature_Validation.ps1'
            NewPath = 'Enable-SignatureValidation/Detect-Enable-SignatureValidation.ps1'
        }
        @{
            BasePath = 'Enable-SignatureValidation/remediation_Remediate_Signature_Validation.ps1'
            NewPath = 'Enable-SignatureValidation/Remediate-Enable-SignatureValidation.ps1'
        }
        @{
            BasePath = 'Enforce-BitLocker/detection_detect-bitlocker.ps1'
            NewPath = 'Enforce-BitLocker/Detect-Enforce-BitLocker.ps1'
        }
        @{
            BasePath = 'Enforce-BitLocker/remediation_enforce-bitlocker.ps1'
            NewPath = 'Enforce-BitLocker/Remediate-Enforce-BitLocker.ps1'
        }
        @{
            BasePath = 'Enforce-CredentialGuard/detection_detect-credentialguard.ps1'
            NewPath = 'Enforce-CredentialGuard/Detect-Enforce-CredentialGuard.ps1'
        }
        @{
            BasePath = 'Enforce-CredentialGuard/remediation_enforce-credentialguard.ps1'
            NewPath = 'Enforce-CredentialGuard/Remediate-Enforce-CredentialGuard.ps1'
        }
        @{
            BasePath = 'Enforce-DOH/detection_detect-doh.ps1'
            NewPath = 'Enforce-DOH/Detect-Enforce-DOH.ps1'
        }
        @{
            BasePath = 'Enforce-DOH/remediation_enforce-doh.ps1'
            NewPath = 'Enforce-DOH/Remediate-Enforce-DOH.ps1'
        }
        @{
            BasePath = 'Enforce-SMB-Signing/detection_Detect_SMBSigning.ps1'
            NewPath = 'Enforce-SMB-Signing/Detect-Enforce-SMB-Signing.ps1'
        }
        @{
            BasePath = 'Enforce-SMB-Signing/remediation_Remediate-SMB-Signing.ps1'
            NewPath = 'Enforce-SMB-Signing/Remediate-Enforce-SMB-Signing.ps1'
        }
        @{
            BasePath = 'Enforce-WindowsFirewall/detection_detect-windowsfirewall.ps1'
            NewPath = 'Enforce-WindowsFirewall/Detect-Enforce-WindowsFirewall.ps1'
        }
        @{
            BasePath = 'Enforce-WindowsFirewall/remediation_enforce-windowsfirewall.ps1'
            NewPath = 'Enforce-WindowsFirewall/Remediate-Enforce-WindowsFirewall.ps1'
        }
        @{
            BasePath = 'Fix-FileAssociations/detection_detect-fileassociations.ps1'
            NewPath = 'Fix-FileAssociations/Detect-Fix-FileAssociations.ps1'
        }
        @{
            BasePath = 'Fix-FileAssociations/remediation_fix-fileassociations.ps1'
            NewPath = 'Fix-FileAssociations/Remediate-Fix-FileAssociations.ps1'
        }
        @{
            BasePath = 'Fix-OfficeActivation/detection_detect-officeactivation.ps1'
            NewPath = 'Fix-OfficeActivation/Detect-Fix-OfficeActivation.ps1'
        }
        @{
            BasePath = 'Fix-OfficeActivation/remediation_fix-officeactivation.ps1'
            NewPath = 'Fix-OfficeActivation/Remediate-Fix-OfficeActivation.ps1'
        }
        @{
            BasePath = 'Fix-SearchIndex/detection_detect-searchindex.ps1'
            NewPath = 'Fix-SearchIndex/Detect-Fix-SearchIndex.ps1'
        }
        @{
            BasePath = 'Fix-SearchIndex/remediation_fix-searchindex.ps1'
            NewPath = 'Fix-SearchIndex/Remediate-Fix-SearchIndex.ps1'
        }
        @{
            BasePath = 'Fix-WMI-Repository/detection_detect-wmirepository.ps1'
            NewPath = 'Fix-WMI-Repository/Detect-Fix-WMI-Repository.ps1'
        }
        @{
            BasePath = 'Fix-WMI-Repository/remediation_fix-wmirepository.ps1'
            NewPath = 'Fix-WMI-Repository/Remediate-Fix-WMI-Repository.ps1'
        }
        @{
            BasePath = 'Fortinet-VPN-Profile/detection_FortinetVPNProfile-Detect.ps1'
            NewPath = 'Fortinet-VPN-Profile/Detect-Fortinet-VPN-Profile.ps1'
        }
        @{
            BasePath = 'Fortinet-VPN-Profile/remediation_FortinetVPNProfile-Remediation.ps1'
            NewPath = 'Fortinet-VPN-Profile/Remediate-Fortinet-VPN-Profile.ps1'
        }
        @{
            BasePath = 'Get-AdobeDC_Java/detection_Detect_AdobeDC_Java.ps1'
            NewPath = 'Get-AdobeDC-Java/Detect-Get-AdobeDC-Java.ps1'
        }
        @{
            BasePath = 'Get-AdobeDC_Java/remediation_Remediate_AdobeDC_Java.ps1'
            NewPath = 'Get-AdobeDC-Java/Remediate-Get-AdobeDC-Java.ps1'
        }
        @{
            BasePath = 'Get-AdobeReader_Flash/detection_Detect_AdobeReader_Flash.ps1'
            NewPath = 'Get-AdobeReader-Flash/Detect-Get-AdobeReader-Flash.ps1'
        }
        @{
            BasePath = 'Get-AdobeReader_Flash/remediation_Remediate_AdobeReader_Flash.ps1'
            NewPath = 'Get-AdobeReader-Flash/Remediate-Get-AdobeReader-Flash.ps1'
        }
        @{
            BasePath = 'Get-AdobeReader-Java/detection_Detect_AdobeReader_Java.ps1'
            NewPath = 'Get-AdobeReader-Java/Detect-Get-AdobeReader-Java.ps1'
        }
        @{
            BasePath = 'Get-AdobeReader-Java/remediation_Remediate_AdobeReader_Java.ps1'
            NewPath = 'Get-AdobeReader-Java/Remediate-Get-AdobeReader-Java.ps1'
        }
        @{
            BasePath = 'Get-Always_Elevated/detection_Detect_Always_Elevated.ps1'
            NewPath = 'Get-Always-Elevated/Detect-Get-Always-Elevated.ps1'
        }
        @{
            BasePath = 'Get-Always_Elevated/remediation_Remediate_Always_Elevated.ps1'
            NewPath = 'Get-Always-Elevated/Remediate-Get-Always-Elevated.ps1'
        }
        @{
            BasePath = 'Get-BatteryHealth/detection_detect-batteryhealth.ps1'
            NewPath = 'Get-BatteryHealth/Detect-Get-BatteryHealth.ps1'
        }
        @{
            BasePath = 'Get-BatteryHealth/remediation_generate-batteryreport.ps1'
            NewPath = 'Get-BatteryHealth/Remediate-Get-BatteryHealth.ps1'
        }
        @{
            BasePath = 'Get-BitlockerRecoveryKey/detection_BitlockerRecoveryKey.ps1'
            NewPath = 'Get-BitlockerRecoveryKey/Detect-Get-BitlockerRecoveryKey.ps1'
        }
        @{
            BasePath = 'Get-BitlockerRecoveryKey/remediation_BitlockerRecoveryKey.ps1'
            NewPath = 'Get-BitlockerRecoveryKey/Remediate-Get-BitlockerRecoveryKey.ps1'
        }
        @{
            BasePath = 'Get-CleanUpDisk/detection_Get-CleanUpDiskDetection.ps1'
            NewPath = 'Get-CleanUpDisk/Detect-Get-CleanUpDisk.ps1'
        }
        @{
            BasePath = 'Get-CleanUpDisk/remediation_Get-CleanUpDiskRemedaiton.ps1'
            NewPath = 'Get-CleanUpDisk/Remediate-Get-CleanUpDisk.ps1'
        }
        @{
            BasePath = 'Get-CloudDeliveredProtection/detection_Detect_CloudDeliveredProtection.ps1'
            NewPath = 'Get-CloudDeliveredProtection/Detect-Get-CloudDeliveredProtection.ps1'
        }
        @{
            BasePath = 'Get-CloudDeliveredProtection/remediation_Remediate_CloudDeliveredProtection.ps1'
            NewPath = 'Get-CloudDeliveredProtection/Remediate-Get-CloudDeliveredProtection.ps1'
        }
        @{
            BasePath = 'Get-ConnectedDevices/detection_Get-ConnectedDevicesDetection.ps1'
            NewPath = 'Get-ConnectedDevices/Detect-Get-ConnectedDevices.ps1'
        }
        @{
            BasePath = 'Get-DeviceUptime_and_Reboot/detection_Detect_DeviceUptime7.ps1'
            NewPath = 'Get-Device-Uptime-And-Reboot/Detect-Get-Device-Uptime-And-Reboot.ps1'
        }
        @{
            BasePath = 'Get-DeviceUptime_and_Reboot/remediation_Remediate_DeviceUptime7.ps1'
            NewPath = 'Get-Device-Uptime-And-Reboot/Remediate-Get-Device-Uptime-And-Reboot.ps1'
        }
        @{
            BasePath = 'Get-LSA-Protection/detection_Detect_LSA_Protection.ps1'
            NewPath = 'Get-LSA-Protection/Detect-Get-LSA-Protection.ps1'
        }
        @{
            BasePath = 'Get-LSA-Protection/remediation_Remediate_LSA_Protection.ps1'
            NewPath = 'Get-LSA-Protection/Remediate-Get-LSA-Protection.ps1'
        }
        @{
            BasePath = 'Get-NetworkProtection/detection_Detect_NetworkProtection.ps1'
            NewPath = 'Get-NetworkProtection/Detect-Get-NetworkProtection.ps1'
        }
        @{
            BasePath = 'Get-NetworkProtection/remediation_Remediate_NetworkProtection.ps1'
            NewPath = 'Get-NetworkProtection/Remediate-Get-NetworkProtection.ps1'
        }
        @{
            BasePath = 'Get-OfficeTelemetry/detection_Detect_Office_Telemetry.ps1'
            NewPath = 'Get-OfficeTelemetry/Detect-Get-OfficeTelemetry.ps1'
        }
        @{
            BasePath = 'Get-OfficeTelemetry/remediation_Remediate_Office_Telemetry.ps1'
            NewPath = 'Get-OfficeTelemetry/Remediate-Get-OfficeTelemetry.ps1'
        }
        @{
            BasePath = 'Get-PUA-Protection/detection_Detect_PUA-Protection.ps1'
            NewPath = 'Get-PUA-Protection/Detect-Get-PUA-Protection.ps1'
        }
        @{
            BasePath = 'Get-PUA-Protection/remediation_Remediate_PUA-Protection.ps1'
            NewPath = 'Get-PUA-Protection/Remediate-Get-PUA-Protection.ps1'
        }
        @{
            BasePath = 'Get-RealTimeBehaviour/detection_Detect_RealTimeBehavior.ps1'
            NewPath = 'Get-RealTimeBehaviour/Detect-Get-RealTimeBehaviour.ps1'
        }
        @{
            BasePath = 'Get-RealTimeBehaviour/remediation_Remediate_RealTimeBehavior.ps1'
            NewPath = 'Get-RealTimeBehaviour/Remediate-Get-RealTimeBehaviour.ps1'
        }
        @{
            BasePath = 'Get-RealTimeProtection/detection_Detect_RealTimeProtection.ps1'
            NewPath = 'Get-RealTimeProtection/Detect-Get-RealTimeProtection.ps1'
        }
        @{
            BasePath = 'Get-RealTimeProtection/remediation_Remediate_RealTimeProtection.ps1'
            NewPath = 'Get-RealTimeProtection/Remediate-Get-RealTimeProtection.ps1'
        }
        @{
            BasePath = 'Get-TimeZone_W_Europe/detection_Get-TimeZone_W_Europe.ps1'
            NewPath = 'Get-TimeZone-W-Europe/Detect-Get-TimeZone-W-Europe.ps1'
        }
        @{
            BasePath = 'Get-TimeZone_W_Europe/remediation_Remediate_TimeZone_W_Europe.ps1'
            NewPath = 'Get-TimeZone-W-Europe/Remediate-Get-TimeZone-W-Europe.ps1'
        }
        @{
            BasePath = 'Get-WH4BEnrolledMethods/detection_Get-WH4BEnrolledMethodsDetection.ps1'
            NewPath = 'Get-WH4BEnrolledMethods/Detect-Get-WH4BEnrolledMethods.ps1'
        }
        @{
            BasePath = 'Get-WH4BLastUsedMethod/detection_Get-WH4BLastUsedMethodDetection.ps1'
            NewPath = 'Get-WH4BLastUsedMethod/Detect-Get-WH4BLastUsedMethod.ps1'
        }
        @{
            BasePath = 'Install-CMTrace/detection_detect-cmtrace.ps1'
            NewPath = 'Install-CMTrace/Detect-Install-CMTrace.ps1'
        }
        @{
            BasePath = 'Install-CMTrace/remediation_install-cmtrace-remediate.ps1'
            NewPath = 'Install-CMTrace/Remediate-Install-CMTrace.ps1'
        }
        @{
            BasePath = 'Winget Management/detection_detect-install-url-changes.ps1'
            NewPath = 'Install-WinGet-Apps-From-Url/Detect-Install-WinGet-Apps-From-Url.ps1'
        }
        @{
            BasePath = 'Winget Management/remediation_remediate-install-apps-from-url.ps1'
            NewPath = 'Install-WinGet-Apps-From-Url/Remediate-Install-WinGet-Apps-From-Url.ps1'
        }
        @{
            BasePath = 'Install-WindowsUpdates/detection_Install-WindowsUpdatesDetection.ps1'
            NewPath = 'Install-WindowsUpdates/Detect-Install-WindowsUpdates.ps1'
        }
        @{
            BasePath = 'Install-WindowsUpdates/remediation_Install-WindowsUpdatesRemediation.ps1'
            NewPath = 'Install-WindowsUpdates/Remediate-Install-WindowsUpdates.ps1'
        }
        @{
            BasePath = 'Invoke-ClearRecycleBin/detection_Invoke-ClearRecycleBinDetection.ps1'
            NewPath = 'Invoke-ClearRecycleBin/Detect-Invoke-ClearRecycleBin.ps1'
        }
        @{
            BasePath = 'Invoke-ClearRecycleBin/remediation_Invoke-ClearRecycleBinRemedaiton.ps1'
            NewPath = 'Invoke-ClearRecycleBin/Remediate-Invoke-ClearRecycleBin.ps1'
        }
        @{
            BasePath = 'Invoke-CurrentUserLoggedOff/detection_Get-CurrentUserLoggedOffDetection.ps1'
            NewPath = 'Invoke-CurrentUserLoggedOff/Detect-Invoke-CurrentUserLoggedOff.ps1'
        }
        @{
            BasePath = 'Invoke-CurrentUserLoggedOff/remediation_Get-CurrentUserLoggedOffRemedaiton.ps1'
            NewPath = 'Invoke-CurrentUserLoggedOff/Remediate-Invoke-CurrentUserLoggedOff.ps1'
        }
        @{
            BasePath = 'Invoke-DiskRepair/detection_Get-TemplateDetection.ps1'
            NewPath = 'Invoke-DiskRepair/Detect-Invoke-DiskRepair.ps1'
        }
        @{
            BasePath = 'Invoke-DiskRepair/remediation_Get-TemplateRemedaiton.ps1'
            NewPath = 'Invoke-DiskRepair/Remediate-Invoke-DiskRepair.ps1'
        }
        @{
            BasePath = 'Invoke-DnsClearCache/detection_Invoke-DnsClearCacheDetection.ps1'
            NewPath = 'Invoke-DnsClearCache/Detect-Invoke-DnsClearCache.ps1'
        }
        @{
            BasePath = 'Invoke-DnsClearCache/remediation_Invoke-DnsClearCacheRemedaiton.ps1'
            NewPath = 'Invoke-DnsClearCache/Remediate-Invoke-DnsClearCache.ps1'
        }
        @{
            BasePath = 'Invoke-Shutdown/detection_Invoke-ShutdownDetection.ps1'
            NewPath = 'Invoke-Shutdown/Detect-Invoke-Shutdown.ps1'
        }
        @{
            BasePath = 'Invoke-Shutdown/remediation_Invoke-ShutdownRemedaiton.ps1'
            NewPath = 'Invoke-Shutdown/Remediate-Invoke-Shutdown.ps1'
        }
        @{
            BasePath = 'Invoke-TeamsInstallation/detection_Invoke-TeamsInstallationDetection.ps1'
            NewPath = 'Invoke-TeamsInstallation/Detect-Invoke-TeamsInstallation.ps1'
        }
        @{
            BasePath = 'Invoke-TeamsInstallation/remediation_Invoke-TeamsInstallationRemedaiton.ps1'
            NewPath = 'Invoke-TeamsInstallation/Remediate-Invoke-TeamsInstallation.ps1'
        }
        @{
            BasePath = 'Invoke-TeamsReinstallation/detection_Invoke-TeamsReinstallationDetection.ps1'
            NewPath = 'Invoke-TeamsReinstallation/Detect-Invoke-TeamsReinstallation.ps1'
        }
        @{
            BasePath = 'Invoke-TeamsReinstallation/remediation_Invoke-TeamsReinstallationRemedaiton.ps1'
            NewPath = 'Invoke-TeamsReinstallation/Remediate-Invoke-TeamsReinstallation.ps1'
        }
        @{
            BasePath = 'Make-Speedtest/detection_Run-SpeedttestDetection.ps1'
            NewPath = 'Make-Speedtest/Detect-Make-Speedtest.ps1'
        }
        @{
            BasePath = 'Make-Speedtest/remediation_Run-SpeedttestRemediation.ps1'
            NewPath = 'Make-Speedtest/Remediate-Make-Speedtest.ps1'
        }
        @{
            BasePath = 'Monitor-DiskSpace-Trend/detection_detect-diskspacetrend.ps1'
            NewPath = 'Monitor-DiskSpace-Trend/Detect-Monitor-DiskSpace-Trend.ps1'
        }
        @{
            BasePath = 'Monitor-DiskSpace-Trend/remediation_free-diskspace.ps1'
            NewPath = 'Monitor-DiskSpace-Trend/Remediate-Monitor-DiskSpace-Trend.ps1'
        }
        @{
            BasePath = 'OneDrive Folder - Always Offline/detection_detection-ODFolderOffline.ps1'
            NewPath = 'OneDrive-Folder-Always-Offline/Detect-OneDrive-Folder-Always-Offline.ps1'
        }
        @{
            BasePath = 'OneDrive Folder - Always Offline/remediation_remediation-ODFolderOffline.ps1'
            NewPath = 'OneDrive-Folder-Always-Offline/Remediate-OneDrive-Folder-Always-Offline.ps1'
        }
        @{
            BasePath = 'Optimize-StartupPrograms/detection_detect-startupprograms.ps1'
            NewPath = 'Optimize-StartupPrograms/Detect-Optimize-StartupPrograms.ps1'
        }
        @{
            BasePath = 'Optimize-StartupPrograms/remediation_optimize-startupprograms.ps1'
            NewPath = 'Optimize-StartupPrograms/Remediate-Optimize-StartupPrograms.ps1'
        }
        @{
            BasePath = 'Profile-Backup/detection_detect-backup.ps1'
            NewPath = 'Profile-Backup/Detect-Profile-Backup.ps1'
        }
        @{
            BasePath = 'Profile-Backup/remediation_remediate-backup.ps1'
            NewPath = 'Profile-Backup/Remediate-Profile-Backup.ps1'
        }
        @{
            BasePath = 'Profile-cleanup/detection_detect-old-profiles.ps1'
            NewPath = 'Profile-Cleanup/Detect-Profile-Cleanup.ps1'
        }
        @{
            BasePath = 'Profile-cleanup/remediation_remediate-old-profiles.ps1'
            NewPath = 'Profile-Cleanup/Remediate-Profile-Cleanup.ps1'
        }
        @{
            BasePath = 'Reinstall-Office/detection_Reinstall-OfficeDetection.ps1'
            NewPath = 'Reinstall-Office/Detect-Reinstall-Office.ps1'
        }
        @{
            BasePath = 'Reinstall-Office/remediation_Reinstall-OfficeRemediation.ps1'
            NewPath = 'Reinstall-Office/Remediate-Reinstall-Office.ps1'
        }
        @{
            BasePath = 'Remove-BloatwareAdvanced/detection_detect-bloatware.ps1'
            NewPath = 'Remove-BloatwareAdvanced/Detect-Remove-BloatwareAdvanced.ps1'
        }
        @{
            BasePath = 'Remove-BloatwareAdvanced/remediation_remove-bloatware.ps1'
            NewPath = 'Remove-BloatwareAdvanced/Remediate-Remove-BloatwareAdvanced.ps1'
        }
        @{
            BasePath = 'Remove-ConsumerApps/detection_Remove-ConsumerAppsDetection.ps1'
            NewPath = 'Remove-ConsumerApps/Detect-Remove-ConsumerApps.ps1'
        }
        @{
            BasePath = 'Remove-ConsumerApps/remediation_Remove-ConsumerAppsRemediation.ps1'
            NewPath = 'Remove-ConsumerApps/Remediate-Remove-ConsumerApps.ps1'
        }
        @{
            BasePath = '0 - Template/detection_Get-TemplateDetection.ps1'
            NewPath = 'Remove-New-Outlook/Detect-Remove-New-Outlook.ps1'
        }
        @{
            BasePath = '0 - Template/remediation_Get-TemplateRemediaton.ps1'
            NewPath = 'Remove-New-Outlook/Remediate-Remove-New-Outlook.ps1'
        }
        @{
            BasePath = 'Remove-ProxySettings/detection_Remove-ProxySettingsDetection.ps1'
            NewPath = 'Remove-ProxySettings/Detect-Remove-ProxySettings.ps1'
        }
        @{
            BasePath = 'Remove-ProxySettings/remediation_Remove-ProxySettingsRemedaiton.ps1'
            NewPath = 'Remove-ProxySettings/Remediate-Remove-ProxySettings.ps1'
        }
        @{
            BasePath = 'Remove-ReinstallMSI/detection_Remove-ReinstallMSIDetection.ps1'
            NewPath = 'Remove-ReinstallMSI/Detect-Remove-ReinstallMSI.ps1'
        }
        @{
            BasePath = 'Remove-ReinstallMSI/remediation_Remove-ReinstallMSIRemediation.ps1'
            NewPath = 'Remove-ReinstallMSI/Remediate-Remove-ReinstallMSI.ps1'
        }
        @{
            BasePath = 'Remove-SavedWifiProfiles/detection_detect-savedwifiprofiles.ps1'
            NewPath = 'Remove-SavedWifiProfiles/Detect-Remove-SavedWifiProfiles.ps1'
        }
        @{
            BasePath = 'Remove-SavedWifiProfiles/remediation_remove-savedwifiprofiles.ps1'
            NewPath = 'Remove-SavedWifiProfiles/Remediate-Remove-SavedWifiProfiles.ps1'
        }
        @{
            BasePath = '0 - Template/Detect-Silverlight'
            NewPath = 'Remove-Silverlight/Detect-Remove-Silverlight.ps1'
        }
        @{
            BasePath = '0 - Template/Remediate_Silverlight'
            NewPath = 'Remove-Silverlight/Remediate-Remove-Silverlight.ps1'
        }
        @{
            BasePath = 'Remove-StaticRoutes/detection_detect-staticroutes.ps1'
            NewPath = 'Remove-StaticRoutes/Detect-Remove-StaticRoutes.ps1'
        }
        @{
            BasePath = 'Remove-StaticRoutes/remediation_remove-staticroutes.ps1'
            NewPath = 'Remove-StaticRoutes/Remediate-Remove-StaticRoutes.ps1'
        }
        @{
            BasePath = 'Remove Teams Chat/detection_detect-teams-chat.ps1'
            NewPath = 'Remove-Teams-Chat/Detect-Remove-Teams-Chat.ps1'
        }
        @{
            BasePath = 'Remove Teams Chat/remediation_remediate-teams-chat.ps1'
            NewPath = 'Remove-Teams-Chat/Remediate-Remove-Teams-Chat.ps1'
        }
        @{
            BasePath = 'Remove-WindowsBackup/detection_detect-backup.ps1'
            NewPath = 'Remove-WindowsBackup/Detect-Remove-WindowsBackup.ps1'
        }
        @{
            BasePath = 'Remove-WindowsBackup/remediation_remediate-backup.ps1'
            NewPath = 'Remove-WindowsBackup/Remediate-Remove-WindowsBackup.ps1'
        }
        @{
            BasePath = 'Reset-NetworkStack/detection_detect-networkstack.ps1'
            NewPath = 'Reset-NetworkStack/Detect-Reset-NetworkStack.ps1'
        }
        @{
            BasePath = 'Reset-NetworkStack/remediation_reset-networkstack.ps1'
            NewPath = 'Reset-NetworkStack/Remediate-Reset-NetworkStack.ps1'
        }
        @{
            BasePath = 'Reset-NotificationCenter/detection_detect-notificationcenter.ps1'
            NewPath = 'Reset-NotificationCenter/Detect-Reset-NotificationCenter.ps1'
        }
        @{
            BasePath = 'Reset-NotificationCenter/remediation_reset-notificationcenter.ps1'
            NewPath = 'Reset-NotificationCenter/Remediate-Reset-NotificationCenter.ps1'
        }
        @{
            BasePath = 'Reset-OneDriveSync/detection_detect-onedrivesync.ps1'
            NewPath = 'Reset-OneDriveSync/Detect-Reset-OneDriveSync.ps1'
        }
        @{
            BasePath = 'Reset-OneDriveSync/remediation_reset-onedrivesync.ps1'
            NewPath = 'Reset-OneDriveSync/Remediate-Reset-OneDriveSync.ps1'
        }
        @{
            BasePath = 'Reset-OutlookProfile/detection_detect-outlookprofile.ps1'
            NewPath = 'Reset-OutlookProfile/Detect-Reset-OutlookProfile.ps1'
        }
        @{
            BasePath = 'Reset-OutlookProfile/remediation_reset-outlookprofile.ps1'
            NewPath = 'Reset-OutlookProfile/Remediate-Reset-OutlookProfile.ps1'
        }
        @{
            BasePath = 'Reset-PrintSpooler/detection_detect-printspooler.ps1'
            NewPath = 'Reset-PrintSpooler/Detect-Reset-PrintSpooler.ps1'
        }
        @{
            BasePath = 'Reset-PrintSpooler/remediation_reset-printspooler.ps1'
            NewPath = 'Reset-PrintSpooler/Remediate-Reset-PrintSpooler.ps1'
        }
        @{
            BasePath = 'Reset-SoftwareDistributionFolder/detection_Detect-Reset-SoftwareDistributionFolder.ps1'
            NewPath = 'Reset-SoftwareDistributionFolder/Detect-Reset-SoftwareDistributionFolder.ps1'
        }
        @{
            BasePath = 'Reset-SoftwareDistributionFolder/remediation_Remediate-Reset-SoftwareDistributionFolder.ps1'
            NewPath = 'Reset-SoftwareDistributionFolder/Remediate-Reset-SoftwareDistributionFolder.ps1'
        }
        @{
            BasePath = 'Reset-StartMenu/detection_detect-startmenu.ps1'
            NewPath = 'Reset-StartMenu/Detect-Reset-StartMenu.ps1'
        }
        @{
            BasePath = 'Reset-StartMenu/remediation_reset-startmenu.ps1'
            NewPath = 'Reset-StartMenu/Remediate-Reset-StartMenu.ps1'
        }
        @{
            BasePath = 'Reset Windows Update/detection_ResetWindowsUpdateDetection.ps1'
            NewPath = 'Reset-Windows-Update/Detect-Reset-Windows-Update.ps1'
        }
        @{
            BasePath = 'Reset Windows Update/remediation_ResetWindowsUpdateRemediation.ps1'
            NewPath = 'Reset-Windows-Update/Remediate-Reset-Windows-Update.ps1'
        }
        @{
            BasePath = 'Restart-Service-Generic/detection_detect-service.ps1'
            NewPath = 'Restart-Service-Generic/Detect-Restart-Service-Generic.ps1'
        }
        @{
            BasePath = 'Restart-Service-Generic/remediation_restart-service.ps1'
            NewPath = 'Restart-Service-Generic/Remediate-Restart-Service-Generic.ps1'
        }
        @{
            BasePath = 'Restart-Windows-Search-Service/detection_detect-search-service.ps1'
            NewPath = 'Restart-Windows-Search-Service/Detect-Restart-Windows-Search-Service.ps1'
        }
        @{
            BasePath = 'Restart-Windows-Search-Service/remediation_restart-search-service.ps1'
            NewPath = 'Restart-Windows-Search-Service/Remediate-Restart-Windows-Search-Service.ps1'
        }
        @{
            BasePath = 'Restart-Windows-Update-Service/detection_detect-wu-service.ps1'
            NewPath = 'Restart-Windows-Update-Service/Detect-Restart-Windows-Update-Service.ps1'
        }
        @{
            BasePath = 'Restart-Windows-Update-Service/remediation_restart-wu-service.ps1'
            NewPath = 'Restart-Windows-Update-Service/Remediate-Restart-Windows-Update-Service.ps1'
        }
        @{
            BasePath = 'Rotate-LocalAdminPassword/detection_detect-localadminpasswordage.ps1'
            NewPath = 'Rotate-LocalAdminPassword/Detect-Rotate-LocalAdminPassword.ps1'
        }
        @{
            BasePath = 'Rotate-LocalAdminPassword/remediation_rotate-localadminpassword.ps1'
            NewPath = 'Rotate-LocalAdminPassword/Remediate-Rotate-LocalAdminPassword.ps1'
        }
        @{
            BasePath = 'Run-Browser/detection_Get-TemplateDetection.ps1'
            NewPath = 'Run-Browser/Detect-Run-Browser.ps1'
        }
        @{
            BasePath = 'Run-Browser/remediation_Get-TemplateRemedaiton.ps1'
            NewPath = 'Run-Browser/Remediate-Run-Browser.ps1'
        }
        @{
            BasePath = 'Run-ConnectionTest/detection_Run-ConnectionTestDetection.ps1'
            NewPath = 'Run-ConnectionTest/Detect-Run-ConnectionTest.ps1'
        }
        @{
            BasePath = 'Run-DiskDiagnostic/detection_Run-DiskDiagnosticDetection.ps1'
            NewPath = 'Run-DiskDiagnostic/Detect-Run-DiskDiagnostic.ps1'
        }
        @{
            BasePath = 'Run-DiskDiagnostic/remediation_Run-DiskDiagnosticRemediation.ps1'
            NewPath = 'Run-DiskDiagnostic/Remediate-Run-DiskDiagnostic.ps1'
        }
        @{
            BasePath = 'Detect-SCCM/detection_Detect.ps1'
            NewPath = 'SCCM/Detect-SCCM.ps1'
        }
        @{
            BasePath = 'Detect-SCCM/remediation_RemoveSCCM.ps1'
            NewPath = 'SCCM/Remediate-SCCM.ps1'
        }
        @{
            BasePath = 'Set-Cached-Logon-Count-0/detection_Detect_Cached_Logon_Count.ps1'
            NewPath = 'Set-Cached-Logon-Count-0/Detect-Set-Cached-Logon-Count-0.ps1'
        }
        @{
            BasePath = 'Set-Cached-Logon-Count-0/remediation_Remediate_Cached_Logon_Count.ps1'
            NewPath = 'Set-Cached-Logon-Count-0/Remediate-Set-Cached-Logon-Count-0.ps1'
        }
        @{
            BasePath = 'Set-CanaryToken-RegistryKey/detection_DetectCanaryToken.ps1'
            NewPath = 'Set-CanaryToken-RegistryKey/Detect-Set-CanaryToken-RegistryKey.ps1'
        }
        @{
            BasePath = 'Set-CanaryToken-RegistryKey/remediation_RemediateCanaryToken.ps1'
            NewPath = 'Set-CanaryToken-RegistryKey/Remediate-Set-CanaryToken-RegistryKey.ps1'
        }
        @{
            BasePath = 'Set-DefaultBrowser/detection_detect-defaultbrowser.ps1'
            NewPath = 'Set-DefaultBrowser/Detect-Set-DefaultBrowser.ps1'
        }
        @{
            BasePath = 'Set-DefaultBrowser/remediation_set-defaultbrowser.ps1'
            NewPath = 'Set-DefaultBrowser/Remediate-Set-DefaultBrowser.ps1'
        }
        @{
            BasePath = 'Set-MTU-Optimal/detection_detect-mtu.ps1'
            NewPath = 'Set-MTU-Optimal/Detect-Set-MTU-Optimal.ps1'
        }
        @{
            BasePath = 'Set-MTU-Optimal/remediation_set-mtu.ps1'
            NewPath = 'Set-MTU-Optimal/Remediate-Set-MTU-Optimal.ps1'
        }
        @{
            BasePath = 'Set-Service-Generic/detection_detect-service.ps1'
            NewPath = 'Set-Service-Generic/Detect-Set-Service-Generic.ps1'
        }
        @{
            BasePath = 'Set-Service-Generic/remediation_set-service.ps1'
            NewPath = 'Set-Service-Generic/Remediate-Set-Service-Generic.ps1'
        }
        @{
            BasePath = 'Show-MessageCenterMessage/detection_Show-MessageCenterMessageDetection.ps1'
            NewPath = 'Show-MessageCenterMessage/Detect-Show-MessageCenterMessage.ps1'
        }
        @{
            BasePath = 'Show-MessageCenterMessage/remediation_Show-MessageCenterMessageRemediation.ps1'
            NewPath = 'Show-MessageCenterMessage/Remediate-Show-MessageCenterMessage.ps1'
        }
        @{
            BasePath = 'Detect-SuspiciousScheduledTasks/detection_detect-suspiciousscheduledtasks.ps1'
            NewPath = 'Suspicious-Scheduled-Tasks/Detect-Suspicious-Scheduled-Tasks.ps1'
        }
        @{
            BasePath = 'Detect-SuspiciousScheduledTasks/remediation_remove-suspiciousscheduledtasks.ps1'
            NewPath = 'Suspicious-Scheduled-Tasks/Remediate-Suspicious-Scheduled-Tasks.ps1'
        }
        @{
            BasePath = 'Test-LAPSUser/detection_detect-LAPSUser.ps1'
            NewPath = 'Test-LAPSUser/Detect-Test-LAPSUser.ps1'
        }
        @{
            BasePath = 'Test-LAPSUser/remediation_new-LAPSUser.ps1'
            NewPath = 'Test-LAPSUser/Remediate-Test-LAPSUser.ps1'
        }
        @{
            BasePath = 'Toast-RebootMessage/detection_detect-reboot.ps1'
            NewPath = 'Toast-RebootMessage/Detect-Toast-RebootMessage.ps1'
        }
        @{
            BasePath = 'Toast-RebootMessage/remediation_remediate-reboot.ps1'
            NewPath = 'Toast-RebootMessage/Remediate-Toast-RebootMessage.ps1'
        }
        @{
            BasePath = 'Toast-UpdateReminder/detection_detect-pendingupdates.ps1'
            NewPath = 'Toast-UpdateReminder/Detect-Toast-UpdateReminder.ps1'
        }
        @{
            BasePath = 'Toast-UpdateReminder/remediation_toast-updatereminder.ps1'
            NewPath = 'Toast-UpdateReminder/Remediate-Toast-UpdateReminder.ps1'
        }
        @{
            BasePath = 'Uninstall-Application/detection_detect.ps1'
            NewPath = 'Uninstall-Application/Detect-Uninstall-Application.ps1'
        }
        @{
            BasePath = 'Uninstall-Application/remediation_remediate.ps1'
            NewPath = 'Uninstall-Application/Remediate-Uninstall-Application.ps1'
        }
        @{
            BasePath = 'Uninstall-DellSupportAssist/detection_Detect_DellSupportassist.ps1'
            NewPath = 'Uninstall-DellSupportAssist/Detect-Uninstall-DellSupportAssist.ps1'
        }
        @{
            BasePath = 'Uninstall-DellSupportAssist/remediation_Remediate_DellSupportassist.ps1'
            NewPath = 'Uninstall-DellSupportAssist/Remediate-Uninstall-DellSupportAssist.ps1'
        }
        @{
            BasePath = 'Uninstall-PrivateTeams/detection_Uninstall-PrivateTeamsDetection.ps1'
            NewPath = 'Uninstall-PrivateTeams/Detect-Uninstall-PrivateTeams.ps1'
        }
        @{
            BasePath = 'Uninstall-PrivateTeams/remediation_Uninstall-PrivateTeamsRemedaiton.ps1'
            NewPath = 'Uninstall-PrivateTeams/Remediate-Uninstall-PrivateTeams.ps1'
        }
        @{
            BasePath = 'Uninstall-UserChrome/detection_detect.ps1'
            NewPath = 'Uninstall-UserChrome/Detect-Uninstall-UserChrome.ps1'
        }
        @{
            BasePath = 'Uninstall-UserChrome/remediation_remediate.ps1'
            NewPath = 'Uninstall-UserChrome/Remediate-Uninstall-UserChrome.ps1'
        }
        @{
            BasePath = 'Uninstall-C++2010/detection_Detect_C++2010.ps1'
            NewPath = 'Uninstall-Visual-Cpp-2010/Detect-Uninstall-Visual-Cpp-2010.ps1'
        }
        @{
            BasePath = 'Uninstall-C++2010/remediation_Remediate_C++2010.ps1'
            NewPath = 'Uninstall-Visual-Cpp-2010/Remediate-Uninstall-Visual-Cpp-2010.ps1'
        }
        @{
            BasePath = 'Winget Management/detection_detect-uninstall-url-changes.ps1'
            NewPath = 'Uninstall-WinGet-Apps-From-Url/Detect-Uninstall-WinGet-Apps-From-Url.ps1'
        }
        @{
            BasePath = 'Winget Management/remediation_remediate-uninstall-apps-from-url.ps1'
            NewPath = 'Uninstall-WinGet-Apps-From-Url/Remediate-Uninstall-WinGet-Apps-From-Url.ps1'
        }
        @{
            BasePath = 'Unpin Store/detection_detect-store.ps1'
            NewPath = 'Unpin-Store/Detect-Unpin-Store.ps1'
        }
        @{
            BasePath = 'Unpin Store/remediation_remediate-store.ps1'
            NewPath = 'Unpin-Store/Remediate-Unpin-Store.ps1'
        }
        @{
            BasePath = 'Update-ChocolateyApps/detection_detection-choco-upgrade.ps1'
            NewPath = 'Update-ChocolateyApps/Detect-Update-ChocolateyApps.ps1'
        }
        @{
            BasePath = 'Update-ChocolateyApps/remediation_remediation-choco-upgrade.ps1'
            NewPath = 'Update-ChocolateyApps/Remediate-Update-ChocolateyApps.ps1'
        }
        @{
            BasePath = 'Update-DefenderAntivirus/detection_Update-DefenderAntivirusDetection.ps1'
            NewPath = 'Update-DefenderAntivirus/Detect-Update-DefenderAntivirus.ps1'
        }
        @{
            BasePath = 'Update-DefenderAntivirus/remediation_Update-DefenderAntivirusRemediation.ps1'
            NewPath = 'Update-DefenderAntivirus/Remediate-Update-DefenderAntivirus.ps1'
        }
        @{
            BasePath = 'Update-MicrosoftTeams/detection_Update-MicrosoftTeamsDetection.ps1'
            NewPath = 'Update-MicrosoftTeams/Detect-Update-MicrosoftTeams.ps1'
        }
        @{
            BasePath = 'Update-MicrosoftTeams/remediation_Update-MicrosoftTeamsRemediation.ps1'
            NewPath = 'Update-MicrosoftTeams/Remediate-Update-MicrosoftTeams.ps1'
        }
        @{
            BasePath = 'Detect-VPNSplitTunnel/detection_detect-vpnsplittunnel.ps1'
            NewPath = 'VPN-Split-Tunnel/Detect-VPN-Split-Tunnel.ps1'
        }
        @{
            BasePath = 'Detect-VPNSplitTunnel/remediation_disable-vpnsplittunnel.ps1'
            NewPath = 'VPN-Split-Tunnel/Remediate-VPN-Split-Tunnel.ps1'
        }
        @{
            BasePath = 'Winget-Update-All/detection_winget-update-detect.ps1'
            NewPath = 'Winget-Update-All/Detect-Winget-Update-All.ps1'
        }
        @{
            BasePath = 'Winget-Update-All/remediation_winget-upgrade-remediate.ps1'
            NewPath = 'Winget-Update-All/Remediate-Winget-Update-All.ps1'
        }
    )
}
