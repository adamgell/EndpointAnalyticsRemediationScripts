@{
    SchemaVersion = '1.0'
    Id = '406e455e-0f2a-5b32-8a2a-b275f85dac19'
    Identity = @{
        PackageName = 'Invoke-DiskRepair'
        ScriptName = 'Detect-Invoke-DiskRepair'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Invoke DiskRepair condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Invoke-DiskRepair/detection_Get-TemplateDetection.ps1'
        Counterpart = 'Invoke-DiskRepair/Remediate-Invoke-DiskRepair.ps1'
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
