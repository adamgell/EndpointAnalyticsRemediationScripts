@{
    SchemaVersion = '1.0'
    Id = 'd341a55f-2d5f-558b-9de0-e6b31e9623c6'
    Identity = @{
        PackageName = 'Remove-SavedWifiProfiles'
        ScriptName = 'Remediate-Remove-SavedWifiProfiles'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Removes saved WiFi profiles that use insecure authentication (Open/WEP).'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Remove-SavedWifiProfiles/remediation_remove-savedwifiprofiles.ps1'
        Counterpart = 'Remove-SavedWifiProfiles/Detect-Remove-SavedWifiProfiles.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @(
            'AllSupported'
        )
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'ForEach-Object'
            'Out-Null'
            'Select-Object'
            'Select-String'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'netsh.exe'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Remove SavedWifiProfiles operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Native'
            'Network'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
