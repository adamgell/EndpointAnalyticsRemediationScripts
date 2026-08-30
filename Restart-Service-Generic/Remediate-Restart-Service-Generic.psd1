@{
    SchemaVersion = '1.0'
    Id = 'aec9cc3b-0f1b-599a-bc03-141dba267d18'
    Identity = @{
        PackageName = 'Restart-Service-Generic'
        ScriptName = 'Remediate-Restart-Service-Generic'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Restarts any service.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Restart-Service-Generic/remediation_restart-service.ps1'
        Counterpart = 'Restart-Service-Generic/Detect-Restart-Service-Generic.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Restart-Service')
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
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Restart Service Generic state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
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
