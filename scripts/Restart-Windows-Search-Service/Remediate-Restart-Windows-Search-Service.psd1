@{
    SchemaVersion = '1.0'
    Id = '9a0db4b9-ace3-55a3-bf77-c7378eaf392b'
    Identity = @{
        PackageName = 'Restart-Windows-Search-Service'
        ScriptName = 'Remediate-Restart-Windows-Search-Service'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Restarts Windows Search service.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Restart-Windows-Search-Service/remediation_restart-search-service.ps1'
        Counterpart = 'Restart-Windows-Search-Service/Detect-Restart-Windows-Search-Service.ps1'
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
            'Get-Service'
            'Restart-Service'
            'Select-Object'
            'Write-Error'
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
        'The script changes the Restart Windows Search Service state and can briefly affect users or services.'
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
