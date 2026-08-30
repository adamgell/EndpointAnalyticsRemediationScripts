@{
    SchemaVersion = '1.0'
    Id = '624e9f48-bc5e-5cfd-b190-03c2c89db373'
    Identity = @{
        PackageName = 'Disable-Delivery-Optimization-Verbose-Logging'
        ScriptName = 'Remediate-Disable-Delivery-Optimization-Verbose-Logging'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Disable Delivery Optimization Verbose Logging condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Enable-DeliveryOptimizationVerboseLogging/remediation_Disable-VerboseLoggingRemedaiton.ps1'
        Counterpart = 'Disable-Delivery-Optimization-Verbose-Logging/Detect-Disable-Delivery-Optimization-Verbose-Logging.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Disable-DeliveryOptimizationVerboseLogs')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Disable Delivery Optimization Verbose Logging state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
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
