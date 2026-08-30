@{
    SchemaVersion = '1.0'
    Id = 'd5f03c8b-46d1-55bf-ac18-52a5d1249b53'
    Identity = @{
        PackageName = 'Clear-DnsCache'
        ScriptName = 'Remediate-Clear-DnsCache'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Clear DnsCache condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Clear-DnsCache/remediation_Clear-DnsCacheRemediation.ps1'
        Counterpart = 'Clear-DnsCache/Detect-Clear-DnsCache.ps1'
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
        Cmdlets = @()
        Executables = @(
            'ipconfig'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $false
        UserImpact = 'The script changes the Clear DnsCache state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Process'
            'Network'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
