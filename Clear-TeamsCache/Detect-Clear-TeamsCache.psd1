@{
    SchemaVersion = '1.0'
    Id = '8ae42f53-691c-50d5-84a5-beba13debdc6'
    Identity = @{
        PackageName = 'Clear-TeamsCache'
        ScriptName = 'Detect-Clear-TeamsCache'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Clear TeamsCache condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Michael Oliveri'
        )
        Source = 'Clear-TeamsCache/detection_Clear-TeamsCacheDetection.ps1'
        Counterpart = 'Clear-TeamsCache/Remediate-Clear-TeamsCache.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
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
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
