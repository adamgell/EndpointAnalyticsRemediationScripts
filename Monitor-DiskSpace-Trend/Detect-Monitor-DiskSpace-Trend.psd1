@{
    SchemaVersion = '1.0'
    Id = '54fac4a6-9875-50a0-bfe4-dd47f1ed45c4'
    Identity = @{
        PackageName = 'Monitor-DiskSpace-Trend'
        ScriptName = 'Detect-Monitor-DiskSpace-Trend'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if disk space is below 10% free.'
        Authors = @('Jannik Reinhard')
        Source = 'Monitor-DiskSpace-Trend/detection_detect-diskspacetrend.ps1'
        Counterpart = 'Monitor-DiskSpace-Trend/Remediate-Monitor-DiskSpace-Trend.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-Volume', 'Where-Object', 'Write-Output', 'Write-Warning')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'MinFreePercent'
            Required = $false
            Secret = $false
            Description = 'Minimum accepted free disk-space percentage.'
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
        Categories = @('Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
