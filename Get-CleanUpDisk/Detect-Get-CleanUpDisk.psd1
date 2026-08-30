@{
    SchemaVersion = '1.0'
    Id = '7e52a210-9ed0-5830-bcaa-e0d216dd5a86'
    Identity = @{
        PackageName = 'Get-CleanUpDisk'
        ScriptName = 'Detect-Get-CleanUpDisk'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Get CleanUpDisk condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Get-CleanUpDisk/detection_Get-CleanUpDiskDetection.ps1'
        Counterpart = 'Get-CleanUpDisk/Remediate-Get-CleanUpDisk.ps1'
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
            'Get-PSDrive'
            'Where-Object'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'StorageThresholdPercent'
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
