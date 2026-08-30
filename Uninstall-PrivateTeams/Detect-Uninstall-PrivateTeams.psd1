@{
    SchemaVersion = '1.0'
    Id = '64564245-efd9-5c64-9f39-7e9f51475e2b'
    Identity = @{
        PackageName = 'Uninstall-PrivateTeams'
        ScriptName = 'Detect-Uninstall-PrivateTeams'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Uninstall PrivateTeams condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Uninstall-PrivateTeams/detection_Uninstall-PrivateTeamsDetection.ps1'
        Counterpart = 'Uninstall-PrivateTeams/Remediate-Uninstall-PrivateTeams.ps1'
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
            'Get-AppxPackage'
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
            'Appx'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
