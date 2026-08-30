@{
    SchemaVersion = '1.0'
    Id = 'ca1fc13c-f240-515b-81dc-04cbeaebdc82'
    Identity = @{
        PackageName = 'Driver-Issues'
        ScriptName = 'Detect-Driver-Issues'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects devices with driver problems.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Detect-DriverIssues/detection_detect-driverissues.ps1'
        Counterpart = 'Driver-Issues/Remediate-Driver-Issues.ps1'
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
            'ForEach-Object'
            'Get-PnpDevice'
            'Write-Output'
            'Write-Warning'
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
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
