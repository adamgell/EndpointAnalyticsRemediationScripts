@{
    SchemaVersion = '1.0'
    Id = '29c9aea9-cdf5-509e-9788-48f5acc7c451'
    Identity = @{
        PackageName = 'Disable-StartMenuWebSearch'
        ScriptName = 'Detect-Disable-StartMenuWebSearch'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Disabling web search on the start menu makes it so much faster and effective. No lag at all anymore!.'
        Authors = @('EndpointAnalyticsRemediationScripts contributors')
        Source = 'Disable-StartMenuWebSearch/detection_detect-WebSearch.ps1'
        Counterpart = 'Disable-StartMenuWebSearch/Remediate-Disable-StartMenuWebSearch.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-ItemProperty', 'Select-Object', 'Write-Output', 'Write-Warning')
        Executables = @()
        Policies = @('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search')
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
        Categories = @('Registry')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
