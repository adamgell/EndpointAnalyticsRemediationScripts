@{
    SchemaVersion = '1.0'
    Id = 'c85cb92c-7ed2-54cd-8663-a07d3d0b50a1'
    Identity = @{
        PackageName = 'Make-Speedtest'
        ScriptName = 'Detect-Make-Speedtest'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Make Speedtest condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Make-Speedtest/detection_Run-SpeedttestDetection.ps1'
        Counterpart = 'Make-Speedtest/Remediate-Make-Speedtest.ps1'
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
    Behavior = @{ DetectionMode = 'AlwaysRemediate' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Write-Host'
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
        DataHandling = 'Transfers reviewed local diagnostic or profile data to the configured external endpoint.'
    }
    Test = @{
        Categories = @(
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'None'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
