@{
    SchemaVersion = '1.0'
    Id = 'f99c98c6-e7c0-56b4-9d70-d2da457f389b'
    Identity = @{
        PackageName = 'Invoke-CurrentUserLoggedOff'
        ScriptName = 'Detect-Invoke-CurrentUserLoggedOff'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Invoke CurrentUserLoggedOff condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Invoke-CurrentUserLoggedOff/detection_Get-CurrentUserLoggedOffDetection.ps1'
        Counterpart = 'Invoke-CurrentUserLoggedOff/Remediate-Invoke-CurrentUserLoggedOff.ps1'
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
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
