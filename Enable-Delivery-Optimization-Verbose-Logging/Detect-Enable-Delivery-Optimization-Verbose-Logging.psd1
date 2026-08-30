@{
    SchemaVersion = '1.0'
    Id = 'de3b0377-661b-5b1e-bc2d-eb1f4cb51696'
    Identity = @{
        PackageName = 'Enable-Delivery-Optimization-Verbose-Logging'
        ScriptName = 'Detect-Enable-Delivery-Optimization-Verbose-Logging'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Enable Delivery Optimization Verbose Logging condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Enable-DeliveryOptimizationVerboseLogging/detection_Enable-VerboseLoggingDetection.ps1'
        Counterpart = 'Enable-Delivery-Optimization-Verbose-Logging/Remediate-Enable-Delivery-Optimization-Verbose-Logging.ps1'
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
