@{
    SchemaVersion = '1.0'
    Id = 'c588ebfd-9a13-5693-9fc5-1163b959be37'
    Identity = @{
        PackageName = 'Reset-NotificationCenter'
        ScriptName = 'Detect-Reset-NotificationCenter'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if the Notification Center database is oversized.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Reset-NotificationCenter/detection_detect-notificationcenter.ps1'
        Counterpart = 'Reset-NotificationCenter/Remediate-Reset-NotificationCenter.ps1'
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
            'Get-ChildItem'
            'Join-Path'
            'Measure-Object'
            'Test-Path'
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
            'File'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
