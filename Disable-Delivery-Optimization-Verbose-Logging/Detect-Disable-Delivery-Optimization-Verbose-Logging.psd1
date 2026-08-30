@{
    SchemaVersion = '1.0'
    Id = '29c381a8-6fce-5109-b8cc-89f80ad5c785'
    Identity = @{
        PackageName = 'Disable-Delivery-Optimization-Verbose-Logging'
        ScriptName = 'Detect-Disable-Delivery-Optimization-Verbose-Logging'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Disable Delivery Optimization Verbose Logging condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Enable-DeliveryOptimizationVerboseLogging/detection_Disable-VerboseLoggingDetection.ps1'
        Counterpart = 'Disable-Delivery-Optimization-Verbose-Logging/Remediate-Disable-Delivery-Optimization-Verbose-Logging.ps1'
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
