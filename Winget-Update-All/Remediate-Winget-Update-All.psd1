@{
    SchemaVersion = '1.0'
    Id = 'f55579b6-afde-5849-80fa-422395418742'
    Identity = @{
        PackageName = 'Winget-Update-All'
        ScriptName = 'Remediate-Winget-Update-All'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Updates all apps via Winget.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Winget-Update-All/remediation_winget-upgrade-remediate.ps1'
        Counterpart = 'Winget-Update-All/Detect-Winget-Update-All.ps1'
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
        Cmdlets = @('Get-ChildItem', 'Join-Path', 'Select-Object', 'Sort-Object')
        Executables = @('AppInstallerCLI.exe', 'winget.exe')
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Winget Update All state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('File', 'Process')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
