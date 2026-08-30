@{
    SchemaVersion = '1.0'
    Id = '13e5e786-1243-57da-ba60-bbc7d3a82799'
    Identity = @{
        PackageName = 'Invoke-TeamsInstallation'
        ScriptName = 'Detect-Invoke-TeamsInstallation'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Invoke TeamsInstallation condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Invoke-TeamsInstallation/detection_Invoke-TeamsInstallationDetection.ps1'
        Counterpart = 'Invoke-TeamsInstallation/Remediate-Invoke-TeamsInstallation.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'AlwaysRemediate' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Write-Host')
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
        Categories = @('Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
