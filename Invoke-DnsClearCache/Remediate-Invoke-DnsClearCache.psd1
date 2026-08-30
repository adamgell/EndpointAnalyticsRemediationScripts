@{
    SchemaVersion = '1.0'
    Id = '25fccd73-fda5-5242-b905-0c903dbc80d1'
    Identity = @{
        PackageName = 'Invoke-DnsClearCache'
        ScriptName = 'Remediate-Invoke-DnsClearCache'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Invoke DnsClearCache condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Invoke-DnsClearCache/remediation_Invoke-DnsClearCacheRemedaiton.ps1'
        Counterpart = 'Invoke-DnsClearCache/Detect-Invoke-DnsClearCache.ps1'
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
            'Clear-DnsClientCache'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'The script changes the Invoke DnsClearCache state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Network'
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
