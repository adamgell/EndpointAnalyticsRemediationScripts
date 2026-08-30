@{
    SchemaVersion = '1.0'
    Id = '5d46d5d9-2731-5a50-a22c-d101861f492b'
    Identity = @{
        PackageName = 'Uninstall-Visual-Cpp-2010'
        ScriptName = 'Detect-Uninstall-Visual-Cpp-2010'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Uninstall Visual Cpp 2010 condition.'
        Authors = @(
            'EndpointAnalyticsRemediationScripts contributors'
        )
        Source = 'Uninstall-C++2010/detection_Detect_C++2010.ps1'
        Counterpart = 'Uninstall-Visual-Cpp-2010/Remediate-Uninstall-Visual-Cpp-2010.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Get-AppxPackage'
            'Write-Host'
        )
        Executables = @()
        Policies = @()
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
        Categories = @(
            'Appx'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
