@{
    SchemaVersion = '1.0'
    Id = '7e878624-c9d9-5d84-91be-4652d95e5135'
    Identity = @{
        PackageName = 'Defrag-SSD-Trim'
        ScriptName = 'Detect-Defrag-SSD-Trim'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if scheduled disk optimization is enabled.'
        Authors = @('Jannik Reinhard')
        Source = 'Defrag-SSD-Trim/detection_detect-diskoptimization.ps1'
        Counterpart = 'Defrag-SSD-Trim/Remediate-Defrag-SSD-Trim.ps1'
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
        Cmdlets = @('Get-ScheduledTask', 'Write-Output', 'Write-Warning')
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
        Categories = @('Service')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
