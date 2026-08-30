@{
    SchemaVersion = '1.0'
    Id = '6fa7ad18-723f-54b5-9d1a-fb4acd8f64a4'
    Identity = @{
        PackageName = 'Profile-Cleanup'
        ScriptName = 'Detect-Profile-Cleanup'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if there are profiles older than 30 days.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Profile-cleanup/detection_detect-old-profiles.ps1'
        Counterpart = 'Profile-Cleanup/Remediate-Profile-Cleanup.ps1'
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
            'get-CimInstance'
            'Get-Date'
            'Where-Object'
            'write-host'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'ProfileAgeDays'
            Required = $false
            Secret = $false
            Description = 'Minimum profile age in days for cleanup eligibility.'
        }
    )
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
