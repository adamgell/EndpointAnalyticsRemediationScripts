@{
    SchemaVersion = '1.0'
    Id = 'dc0345ae-71f8-5c8e-8647-26ee2bb68e59'
    Identity = @{
        PackageName = 'Enable-DNSOperationalLogs'
        ScriptName = 'Remediate-Enable-DNSOperationalLogs'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Enables DNS Client Operational logs.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Enable-DNSOperationalLogs/remediation_Enable-DNSOperationalLogsRemediation.ps1'
        Counterpart = 'Enable-DNSOperationalLogs/Detect-Enable-DNSOperationalLogs.ps1'
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
            'Get-WinEvent'
            'New-Object'
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
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Enable DNSOperationalLogs state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'Service'
            'Network'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
