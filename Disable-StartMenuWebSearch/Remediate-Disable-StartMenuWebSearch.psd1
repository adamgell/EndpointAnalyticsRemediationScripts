@{
    SchemaVersion = '1.0'
    Id = 'd3a1882c-9091-5681-b7ba-af9ffc132b7b'
    Identity = @{
        PackageName = 'Disable-StartMenuWebSearch'
        ScriptName = 'Remediate-Disable-StartMenuWebSearch'
        Role = 'Remediation'
        Version = '1.0.0'
        Description =
        'Disabling web search on the start menu makes it so much faster and effective. No lag at all anymore!.'
        Authors = @(
            'EndpointAnalyticsRemediationScripts contributors'
        )
        Source = 'Disable-StartMenuWebSearch/remediation_remediate-WebSearch.ps1'
        Counterpart = 'Disable-StartMenuWebSearch/Detect-Disable-StartMenuWebSearch.ps1'
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
            'New-ItemProperty'
        )
        Executables = @()
        Policies = @(
            'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Disable StartMenuWebSearch state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Registry'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
