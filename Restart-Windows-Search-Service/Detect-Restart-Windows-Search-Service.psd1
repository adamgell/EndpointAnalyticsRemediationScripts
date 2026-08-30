@{
    SchemaVersion = '1.0'
    Id = 'a252b731-46d5-5a3d-bb62-9fb7aeebfa61'
    Identity = @{
        PackageName = 'Restart-Windows-Search-Service'
        ScriptName = 'Detect-Restart-Windows-Search-Service'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if Windows Search service exists and is running.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Restart-Windows-Search-Service/detection_detect-search-service.ps1'
        Counterpart = 'Restart-Windows-Search-Service/Remediate-Restart-Windows-Search-Service.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-Service', 'Where-Object', 'Write-Host')
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
        Categories = @('Service')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
