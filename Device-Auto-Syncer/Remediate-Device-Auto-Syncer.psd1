@{
    SchemaVersion = '1.0'
    Id = 'bbb9a666-9d2f-553d-bf20-c485b27914fb'
    Identity = @{
        PackageName = 'Device-Auto-Syncer'
        ScriptName = 'Remediate-Device-Auto-Syncer'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Device Auto Syncer condition.'
        Authors = @('EndpointAnalyticsRemediationScripts contributors')
        Source = 'Device Auto-Syncer/remediation_AutoSyncRemediate.ps1'
        Counterpart = 'Device-Auto-Syncer/Detect-Device-Auto-Syncer.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $false
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-ScheduledTask', 'Start-ScheduledTask', 'Where-Object', 'Write-Error')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Device Auto Syncer state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Service')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
