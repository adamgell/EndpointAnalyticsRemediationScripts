@{
    SchemaVersion = '1.0'
    Id = '11111111-1111-1111-1111-111111111111'
    Identity = @{
        PackageName = 'Example-Package'
        ScriptName = 'Detect-Example-Package'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the example state.'
        Authors = @('Repository Test')
        Source = 'tests/fixtures/manifests/ValidDetection.psd1'
        Counterpart = ''
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = 'true'
        SignatureCheck = 'Either'
        SupportedWindows = @('Windows 11')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Inventory' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-Item')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = 'false'
        UserImpact = 'None'
        Rollback = 'Not required; detection only.'
        DataHandling = 'None'
    }
    Test = @{
        Categories = @('File')
        Status = 'PendingMigration'
        CoverageFloor = '0.0'
        IntegrationLevel = 'None'
        RequiresIntunePilot = 'false'
        RequiresInteractiveUser = 'false'
    }
}
