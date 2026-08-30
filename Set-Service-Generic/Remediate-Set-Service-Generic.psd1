@{
    SchemaVersion = '1.0'
    Id = 'f3c34b3f-7d85-57f0-ae7c-f6955d4f5a42'
    Identity = @{
        PackageName = 'Set-Service-Generic'
        ScriptName = 'Remediate-Set-Service-Generic'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Restarts any service.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Sascha Stumpler'
        )
        Source = 'Set-Service-Generic/remediation_set-service.ps1'
        Counterpart = 'Set-Service-Generic/Detect-Set-Service-Generic.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Set-Service'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'ServiceName'
            Required = $true
            Secret = $false
            Description = 'Windows service name.'
        }
        @{
            Name = 'ServiceOption'
            Required = $true
            Secret = $false
            Description = 'Set-Service parameter name.'
        }
        @{
            Name = 'ServiceOptionValue'
            Required = $true
            Secret = $false
            Description = 'Required Set-Service parameter value.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Set Service Generic state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
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
