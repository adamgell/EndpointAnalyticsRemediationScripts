@{
    SchemaVersion = '1.0'
    Id = 'd2db7185-f4ed-5131-9364-ac20158c36a5'
    Identity = @{
        PackageName = 'Restart-Service-Generic'
        ScriptName = 'Detect-Restart-Service-Generic'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if service exists and is running.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Restart-Service-Generic/detection_detect-service.ps1'
        Counterpart = 'Restart-Service-Generic/Remediate-Restart-Service-Generic.ps1'
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
    Configuration = @(
        @{
            Name = 'ServiceName'
            Required = $true
            Secret = $false
            Description = 'Windows service name to inspect or restart.'
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
        Categories = @('Service')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
