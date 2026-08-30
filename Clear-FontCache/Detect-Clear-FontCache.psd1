@{
    SchemaVersion = '1.0'
    Id = 'c5bf84cf-8cad-5079-a4a6-7cbef8236d3f'
    Identity = @{
        PackageName = 'Clear-FontCache'
        ScriptName = 'Detect-Clear-FontCache'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if the font cache is larger than 100MB.'
        Authors = @('Jannik Reinhard')
        Source = 'Clear-FontCache/detection_detect-fontcache.ps1'
        Counterpart = 'Clear-FontCache/Remediate-Clear-FontCache.ps1'
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
        Cmdlets = @('Get-ChildItem', 'Get-Item', 'Measure-Object', 'Test-Path', 'Write-Output', 'Write-Warning')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'MaxSizeMB'
            Required = $false
            Secret = $false
            Description = 'Maximum acceptable font-cache size in megabytes.'
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
        Categories = @('File')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
