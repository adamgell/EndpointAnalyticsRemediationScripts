@{
    SchemaVersion = '1.0'
    Id = 'b9c6d1c1-de39-505c-beb2-82ecf3362ac3'
    Identity = @{
        PackageName = 'Clear-DownloadFolder'
        ScriptName = 'Remediate-Clear-DownloadFolder'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Clear DownloadFolder condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Clear-DownloadFolder/remediation_Clear-DownloadFolderRemediaton.ps1'
        Counterpart = 'Clear-DownloadFolder/Detect-Clear-DownloadFolder.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-ChildItem', 'Remove-Item')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Clear DownloadFolder operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @('File', 'Destructive')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
