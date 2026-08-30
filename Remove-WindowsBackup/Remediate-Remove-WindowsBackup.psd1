@{
    SchemaVersion = '1.0'
    Id = 'fb12b222-cd75-5fd8-ac1b-a311a927bd90'
    Identity = @{
        PackageName = 'Remove-WindowsBackup'
        ScriptName = 'Remediate-Remove-WindowsBackup'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Remove WindowsBackup condition.'
        Authors = @(
            'EndpointAnalyticsRemediationScripts contributors'
        )
        Source = 'Remove-WindowsBackup/remediation_remediate-backup.ps1'
        Counterpart = 'Remove-WindowsBackup/Detect-Remove-WindowsBackup.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $false
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
            'Remove-WindowsPackage'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Remove WindowsBackup operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Native'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
