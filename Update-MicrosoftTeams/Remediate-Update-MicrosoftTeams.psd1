@{
    SchemaVersion = '1.0'
    Id = '68779163-c66d-53af-907b-4b75a6e51e71'
    Identity = @{
        PackageName = 'Update-MicrosoftTeams'
        ScriptName = 'Remediate-Update-MicrosoftTeams'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Updates Microsoft Teams using winget.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Update-MicrosoftTeams/remediation_Update-MicrosoftTeamsRemediation.ps1'
        Counterpart = 'Update-MicrosoftTeams/Detect-Update-MicrosoftTeams.ps1'
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
            'Join-Path'
            'Select-Object'
            'Sort-Object'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'AppInstallerCLI.exe'
            'winget.exe'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Update MicrosoftTeams state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'File'
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
