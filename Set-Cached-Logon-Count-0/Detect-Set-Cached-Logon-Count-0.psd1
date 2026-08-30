@{
    SchemaVersion = '1.0'
    Id = '52429d5a-93fb-5eb5-9510-3dc753111e2b'
    Identity = @{
        PackageName = 'Set-Cached-Logon-Count-0'
        ScriptName = 'Detect-Set-Cached-Logon-Count-0'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Manages cached interactive domain logons when a domain controller is unavailable.'
        Authors = @(
            'EndpointAnalyticsRemediationScripts contributors'
        )
        Source = 'Set-Cached-Logon-Count-0/detection_Detect_Cached_Logon_Count.ps1'
        Counterpart = 'Set-Cached-Logon-Count-0/Remediate-Set-Cached-Logon-Count-0.ps1'
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
            'Get-ItemProperty'
            'Select-Object'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @(
            'HKLM:\Software\Microsoft\Windows Nt\CurrentVersion\Winlogon'
        )
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
            'Registry'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
