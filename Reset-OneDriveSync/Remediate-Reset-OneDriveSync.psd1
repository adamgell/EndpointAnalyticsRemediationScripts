@{
    SchemaVersion = '1.0'
    Id = 'b9209f84-3a75-5c73-a789-af15f73cb37c'
    Identity = @{
        PackageName = 'Reset-OneDriveSync'
        ScriptName = 'Remediate-Reset-OneDriveSync'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Resets OneDrive sync client.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Reset-OneDriveSync/remediation_reset-onedrivesync.ps1'
        Counterpart = 'Reset-OneDriveSync/Detect-Reset-OneDriveSync.ps1'
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
            'Get-ChildItem'
            'Select-Object'
            'Start-Process'
            'Start-Sleep'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'onedrive.exe'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $true
        UserImpact = 'The Reset OneDriveSync operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Process'
            'File'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
