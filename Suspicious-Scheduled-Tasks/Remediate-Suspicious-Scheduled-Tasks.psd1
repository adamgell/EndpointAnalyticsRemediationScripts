@{
    SchemaVersion = '1.0'
    Id = 'c886a055-44e8-50c8-972d-cbdce884d0e4'
    Identity = @{
        PackageName = 'Suspicious-Scheduled-Tasks'
        ScriptName = 'Remediate-Suspicious-Scheduled-Tasks'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Disables suspicious scheduled tasks not created by known vendors.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Detect-SuspiciousScheduledTasks/remediation_remove-suspiciousscheduledtasks.ps1'
        Counterpart = 'Suspicious-Scheduled-Tasks/Detect-Suspicious-Scheduled-Tasks.ps1'
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
            'Disable-ScheduledTask'
            'Get-ScheduledTask'
            'Where-Object'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Suspicious Scheduled Tasks state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
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
