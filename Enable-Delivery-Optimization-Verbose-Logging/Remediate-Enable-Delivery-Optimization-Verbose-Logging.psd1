@{
    SchemaVersion = '1.0'
    Id = 'ac9d9b4f-e421-55e1-9cf9-8084f81b8d6b'
    Identity = @{
        PackageName = 'Enable-Delivery-Optimization-Verbose-Logging'
        ScriptName = 'Remediate-Enable-Delivery-Optimization-Verbose-Logging'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Enable Delivery Optimization Verbose Logging condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Enable-DeliveryOptimizationVerboseLogging/remediation_Enable-VerboseLoggingRemedaiton.ps1'
        Counterpart =
        'Enable-Delivery-Optimization-Verbose-Logging/Detect-Enable-Delivery-Optimization-Verbose-Logging.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Enable-DeliveryOptimizationVerboseLogs'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'Briefly affects users or services while enabling Delivery Optimization verbose logging.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
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
