@{
    SchemaVersion = '1.0'
    Id = 'b82ba3eb-f5f1-5aa1-87bc-8934240b8cdd'
    Identity = @{
        PackageName = 'Activate-Numlock'
        ScriptName = 'Detect-Activate-Numlock'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Activate Numlock condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Activate-Numlock/detection_Activate-Numlock.ps1'
        Counterpart = 'Activate-Numlock/Remediate-Activate-Numlock.ps1'
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
            'Get-ItemProperty'
            'Write-Host'
        )
        Executables = @()
        Policies = @(
            'Registry::HKU\.DEFAULT\Control Panel\Keyboard'
        )
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
            'Registry'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
