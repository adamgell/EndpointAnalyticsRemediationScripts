@{
    SchemaVersion = '1.0'
    Id = '289dd751-6abe-5554-bd81-ab7585428fcd'
    Identity = @{
        PackageName = 'Clear-OutlookCache'
        ScriptName = 'Detect-Clear-OutlookCache'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Clear OutlookCache condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Clear-OutlookCache/detection_Clear-OutlookCacheDetection.ps1'
        Counterpart = 'Clear-OutlookCache/Remediate-Clear-OutlookCache.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
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
            'Test-Path'
        )
        Executables = @(
            'OUTLOOK.EXE'
        )
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
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
