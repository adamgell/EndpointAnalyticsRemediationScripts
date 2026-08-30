@{
    SchemaVersion = '1.0'
    Id = 'dcc70211-96a8-5d70-82a7-90ee4d011e13'
    Identity = @{
        PackageName = 'Restart-Windows-Update-Service'
        ScriptName = 'Remediate-Restart-Windows-Update-Service'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Restarts Windows Update service.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Restart-Windows-Update-Service/remediation_restart-wu-service.ps1'
        Counterpart = 'Restart-Windows-Update-Service/Detect-Restart-Windows-Update-Service.ps1'
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
            'Restart-Service'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact =
        'The script changes the Restart Windows Update Service state and can briefly affect users or services.'
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
