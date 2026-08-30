@{
    SchemaVersion = '1.0'
    Id = 'c29efb66-89d3-53ba-9501-0ebd06c78528'
    Identity = @{
        PackageName = 'Enable-DNSOperationalLogs'
        ScriptName = 'Detect-Enable-DNSOperationalLogs'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if DNS Client Operational logs are enabled.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Enable-DNSOperationalLogs/detection_Enable-DNSOperationalLogsDetection.ps1'
        Counterpart = 'Enable-DNSOperationalLogs/Remediate-Enable-DNSOperationalLogs.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Get-WinEvent'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @(
            'Microsoft-Windows-DNS-Client/Operational'
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
            'Network'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
