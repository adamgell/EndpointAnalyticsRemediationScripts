@{
    SchemaVersion = '1.0'
    Id = '24ec9dd5-5ebc-5a1a-976a-6ed703081ab1'
    Identity = @{
        PackageName = 'Reset-PrintSpooler'
        ScriptName = 'Detect-Reset-PrintSpooler'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if the Print Spooler has stuck jobs or is not running.'
        Authors = @('Jannik Reinhard')
        Source = 'Reset-PrintSpooler/detection_detect-printspooler.ps1'
        Counterpart = 'Reset-PrintSpooler/Remediate-Reset-PrintSpooler.ps1'
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
        Cmdlets = @('Get-ChildItem', 'Get-Service', 'Test-Path', 'Write-Output', 'Write-Warning')
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
        Categories = @('Service', 'File')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
