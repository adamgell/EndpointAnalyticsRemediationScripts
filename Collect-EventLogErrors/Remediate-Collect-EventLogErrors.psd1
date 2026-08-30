@{
    SchemaVersion = '1.0'
    Id = '7d9b529a-831b-5570-aefc-ee707afcbf18'
    Identity = @{
        PackageName = 'Collect-EventLogErrors'
        ScriptName = 'Remediate-Collect-EventLogErrors'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Collects and exports critical event log entries for analysis.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Collect-EventLogErrors/remediation_collect-eventlogerrors.ps1'
        Counterpart = 'Collect-EventLogErrors/Detect-Collect-EventLogErrors.ps1'
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
            'Export-Csv'
            'Get-ChildItem'
            'Get-Date'
            'Get-WinEvent'
            'Join-Path'
            'New-Item'
            'Out-Null'
            'Remove-Item'
            'Select-Object'
            'Sort-Object'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'HoursBack'
            Required = $false
            Secret = $false
            Description = 'Event-log lookback interval in hours.'
        }
        @{
            Name = 'ExportPath'
            Required = $false
            Secret = $false
            Description = 'Directory used for exported event reports.'
        }
    )
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Collect EventLogErrors operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'File'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
