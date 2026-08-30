@{
    SchemaVersion = '1.0'
    Id = '7076b9ac-cf7d-5ce9-abd4-cd59ab0744bb'
    Identity = @{
        PackageName = 'Reset-OutlookProfile'
        ScriptName = 'Detect-Reset-OutlookProfile'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects Outlook profile issues (oversized OST files).'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Reset-OutlookProfile/detection_detect-outlookprofile.ps1'
        Counterpart = 'Reset-OutlookProfile/Remediate-Reset-OutlookProfile.ps1'
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
