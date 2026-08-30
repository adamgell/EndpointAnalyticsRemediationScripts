@{
    SchemaVersion = '1.0'
    Id = 'fcb33810-4f18-5df9-ae07-43b38b63e53e'
    Identity = @{
        PackageName = 'Restart-Windows-Update-Service'
        ScriptName = 'Detect-Restart-Windows-Update-Service'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if Windows Update exists and is running.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Restart-Windows-Update-Service/detection_detect-wu-service.ps1'
        Counterpart = 'Restart-Windows-Update-Service/Remediate-Restart-Windows-Update-Service.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
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
            'Get-Service'
            'Where-Object'
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
            'Service'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
