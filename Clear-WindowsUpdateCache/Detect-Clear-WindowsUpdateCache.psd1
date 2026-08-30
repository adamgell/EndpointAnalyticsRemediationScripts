@{
    SchemaVersion = '1.0'
    Id = '4c257cc8-68e0-5d9c-8bee-4bb2ffc994f5'
    Identity = @{
        PackageName = 'Clear-WindowsUpdateCache'
        ScriptName = 'Detect-Clear-WindowsUpdateCache'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if Windows Update cache is larger than 1GB.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Clear-WindowsUpdateCache/detection_detect-windowsupdatecache.ps1'
        Counterpart = 'Clear-WindowsUpdateCache/Remediate-Clear-WindowsUpdateCache.ps1'
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
            'Get-ChildItem'
            'Measure-Object'
            'Test-Path'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'MaxSizeMB'
            Required = $false
            Secret = $false
            Description = 'Maximum acceptable Windows Update cache size in megabytes.'
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
