@{
    SchemaVersion = '1.0'
    Id = '78f5f8eb-1465-5fe7-b4f3-890a323a243f'
    Identity = @{
        PackageName = 'Invoke-TeamsReinstallation'
        ScriptName = 'Detect-Invoke-TeamsReinstallation'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Invoke TeamsReinstallation condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Invoke-TeamsReinstallation/detection_Invoke-TeamsReinstallationDetection.ps1'
        Counterpart = 'Invoke-TeamsReinstallation/Remediate-Invoke-TeamsReinstallation.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-WmiObject', 'Where-Object')
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
        Categories = @('Process', 'Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
