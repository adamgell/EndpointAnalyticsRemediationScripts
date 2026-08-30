@{
    SchemaVersion = '1.0'
    Id = 'd5ff3c0b-433f-5702-8ab2-9c22b1815f83'
    Identity = @{
        PackageName = 'Create-LocalAdmin'
        ScriptName = 'Detect-Create-LocalAdmin'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Create LocalAdmin condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Simon Skotheimsvik'
            'Simon'
        )
        Source = 'Create-LocalAdmin/detection_Create-LocalAdminDetection.ps1'
        Counterpart = 'Create-LocalAdmin/Remediate-Create-LocalAdmin.ps1'
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
            'Get-LocalUser'
            'where-Object'
            'Write-Host'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'LocalAdminName'
            Required = $true
            Secret = $false
            Description = 'Local administrator account name.'
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
