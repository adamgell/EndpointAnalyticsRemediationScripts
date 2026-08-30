@{
    SchemaVersion = '1.0'
    Id = '3c0ae70e-0574-5ef2-b975-c1c8aa7d196d'
    Identity = @{
        PackageName = 'Clear-DownloadFolder-SingleUser'
        ScriptName = 'Remediate-Clear-DownloadFolder-SingleUser'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Clears the download folder.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Clear-DownloadFolder-SingleUser/remediation_Clear-DownloadFolderRemediaton.ps1'
        Counterpart = 'Clear-DownloadFolder-SingleUser/Detect-Clear-DownloadFolder-SingleUser.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
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
            'Get-ChildItem'
            'Remove-Item'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact =
        'The Clear DownloadFolder SingleUser operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'File'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
