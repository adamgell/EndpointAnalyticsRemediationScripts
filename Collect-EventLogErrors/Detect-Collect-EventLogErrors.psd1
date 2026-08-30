@{
    SchemaVersion = '1.0'
    Id = 'bbfd6917-b460-5dac-8efb-f95f86a0fd80'
    Identity = @{
        PackageName = 'Collect-EventLogErrors'
        ScriptName = 'Detect-Collect-EventLogErrors'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects critical and error events in the last 24 hours.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Collect-EventLogErrors/detection_detect-eventlogerrors.ps1'
        Counterpart = 'Collect-EventLogErrors/Remediate-Collect-EventLogErrors.ps1'
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
            'Get-Date'
            'Get-WinEvent'
            'Measure-Object'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'MaxCriticalEvents'
            Required = $false
            Secret = $false
            Description = 'Maximum accepted critical-event count.'
        }
        @{
            Name = 'HoursBack'
            Required = $false
            Secret = $false
            Description = 'Event-log lookback interval in hours.'
        }
    )
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
