@{
    SchemaVersion = '1.0'
    Id = '80f83d73-826c-58cd-ad36-6f8c2f758312'
    Identity = @{
        PackageName = 'Set-Cached-Logon-Count-0'
        ScriptName = 'Remediate-Set-Cached-Logon-Count-0'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Manages cached interactive domain logons when a domain controller is unavailable.'
        Authors = @(
            'EndpointAnalyticsRemediationScripts contributors'
        )
        Source = 'Set-Cached-Logon-Count-0/remediation_Remediate_Cached_Logon_Count.ps1'
        Counterpart = 'Set-Cached-Logon-Count-0/Detect-Set-Cached-Logon-Count-0.ps1'
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
            'HKLM:\Software\Microsoft\Windows Nt\CurrentVersion\Winlogon'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Set Cached Logon Count 0 state and can briefly affect users or services.'
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
