@{
    SchemaVersion = '1.0'
    Id = 'aa3d3c53-0aa0-57c0-a488-577dbd9bafbc'
    Identity = @{
        PackageName = 'Reset-Windows-Update'
        ScriptName = 'Detect-Reset-Windows-Update'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Reset Windows Update condition.'
        Authors = @('EndpointAnalyticsRemediationScripts contributors')
        Source = 'Reset Windows Update/detection_ResetWindowsUpdateDetection.ps1'
        Counterpart = 'Reset-Windows-Update/Remediate-Reset-Windows-Update.ps1'
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
