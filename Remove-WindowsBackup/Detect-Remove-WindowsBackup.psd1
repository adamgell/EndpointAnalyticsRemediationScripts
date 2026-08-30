@{
    SchemaVersion = '1.0'
    Id = '9e7c4edc-1412-5fd4-b8d2-779c29476c66'
    Identity = @{
        PackageName = 'Remove-WindowsBackup'
        ScriptName = 'Detect-Remove-WindowsBackup'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Remove WindowsBackup condition.'
        Authors = @(
            'EndpointAnalyticsRemediationScripts contributors'
        )
        Source = 'Remove-WindowsBackup/detection_detect-backup.ps1'
        Counterpart = 'Remove-WindowsBackup/Remediate-Remove-WindowsBackup.ps1'
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
            'Test-Path'
            'write-host'
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
            'File'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
