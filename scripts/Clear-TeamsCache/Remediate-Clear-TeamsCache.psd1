@{
    SchemaVersion = '1.0'
    Id = '9e964a5b-f822-5fe3-99f9-e8a70babc926'
    Identity = @{
        PackageName = 'Clear-TeamsCache'
        ScriptName = 'Remediate-Clear-TeamsCache'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Source https://www.solutions2share.com/clear-microsoft-teams-cache.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Michael Oliveri'
        )
        Source = 'Clear-TeamsCache/remediation_Clear-TeamsCacheRemedaiton.ps1'
        Counterpart = 'Clear-TeamsCache/Detect-Clear-TeamsCache.ps1'
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
            'Get-Process'
            'Remove-Item'
            'Start-Sleep'
            'Stop-Process'
            'Write-Host'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Clear TeamsCache operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'File'
            'Process'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
