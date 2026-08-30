@{
    SchemaVersion = '1.0'
    Id = 'ba8d3b3a-565d-5f39-8483-904068472f62'
    Identity = @{
        PackageName = 'Clear-BrowserCache'
        ScriptName = 'Detect-Clear-BrowserCache'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if Chrome or Edge browser cache exceeds a specified size threshold.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Clear-BrowserCache/detection_Clear-BrowserCacheDetection.ps1'
        Counterpart = 'Clear-BrowserCache/Remediate-Clear-BrowserCache.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $false
        SignatureCheck = 'NotRequired'
        SupportedWindows = @(
            'AllSupported'
        )
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Get-ChildItem'
            'Measure-Object'
            'Test-Path'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'ThresholdMB'
            Required = $false
            Secret = $false
            Description = 'Browser-cache size threshold in megabytes.'
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
            'File'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
