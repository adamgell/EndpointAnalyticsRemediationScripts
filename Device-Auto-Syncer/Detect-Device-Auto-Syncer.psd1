@{
    SchemaVersion = '1.0'
    Id = 'a4cb3076-e8ba-50df-80e7-ae1eb59e2f8f'
    Identity = @{
        PackageName = 'Device-Auto-Syncer'
        ScriptName = 'Detect-Device-Auto-Syncer'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Device Auto Syncer condition.'
        Authors = @(
            'EndpointAnalyticsRemediationScripts contributors'
        )
        Source = 'Device Auto-Syncer/detection_AutoSyncDetect.ps1'
        Counterpart = 'Device-Auto-Syncer/Remediate-Device-Auto-Syncer.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'GET-DATE'
            'Get-ScheduledTask'
            'Get-ScheduledTaskInfo'
            'New-TimeSpan'
            'Write-Host'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Service'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
