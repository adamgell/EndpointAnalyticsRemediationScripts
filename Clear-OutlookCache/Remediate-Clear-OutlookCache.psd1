@{
    SchemaVersion = '1.0'
    Id = '883c6b74-50a2-5cf5-930e-411ce6fc72d7'
    Identity = @{
        PackageName = 'Clear-OutlookCache'
        ScriptName = 'Remediate-Clear-OutlookCache'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Clear OutlookCache condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Clear-OutlookCache/remediation_Clear-OutlookCacheRemedaiton.ps1'
        Counterpart = 'Clear-OutlookCache/Detect-Clear-OutlookCache.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Start-Process'
        )
        Executables = @(
            'OUTLOOK.EXE'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $false
        UserImpact = 'The script changes the Clear OutlookCache state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
