@{
    SchemaVersion = '1.0'
    Id = '8f25713d-1c7a-508f-9d3a-cb9e94081833'
    Identity = @{
        PackageName = 'Fix-WMI-Repository'
        ScriptName = 'Detect-Fix-WMI-Repository'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if the WMI repository is corrupted.'
        Authors = @('Jannik Reinhard')
        Source = 'Fix-WMI-Repository/detection_detect-wmirepository.ps1'
        Counterpart = 'Fix-WMI-Repository/Remediate-Fix-WMI-Repository.ps1'
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
        Cmdlets = @('Write-Output', 'Write-Warning')
        Executables = @('winmgmt')
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
        Categories = @('Process')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
