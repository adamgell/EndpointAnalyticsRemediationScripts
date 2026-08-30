@{
    SchemaVersion = '1.0'
    Id = '9665c183-7558-5d44-8ad8-37e959f08100'
    Identity = @{
        PackageName = 'Suspicious-Scheduled-Tasks'
        ScriptName = 'Detect-Suspicious-Scheduled-Tasks'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects suspicious scheduled tasks not created by known vendors.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Detect-SuspiciousScheduledTasks/detection_detect-suspiciousscheduledtasks.ps1'
        Counterpart = 'Suspicious-Scheduled-Tasks/Remediate-Suspicious-Scheduled-Tasks.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'ForEach-Object'
            'Get-ScheduledTask'
            'Where-Object'
            'Write-Output'
            'Write-Warning'
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
