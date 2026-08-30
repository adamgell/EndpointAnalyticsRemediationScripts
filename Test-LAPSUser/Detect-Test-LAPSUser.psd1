@{
    SchemaVersion = '1.0'
    Id = '3961595d-dab4-5066-8c29-759c63849279'
    Identity = @{
        PackageName = 'Test-LAPSUser'
        ScriptName = 'Detect-Test-LAPSUser'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Checks custom LAPS user, installation, and backup-directory configuration.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Sascha Stumpler'
        )
        Source = 'Test-LAPSUser/detection_detect-LAPSUser.ps1'
        Counterpart = 'Test-LAPSUser/Remediate-Test-LAPSUser.ps1'
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
            'Get-Item'
            'Get-ItemProperty'
            'Get-LocalUser'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Policies\LAPS'
            'HKLM:\SOFTWARE\Policies\LAPS'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Handles credential or token material at runtime; secret values are not stored in the manifest.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
