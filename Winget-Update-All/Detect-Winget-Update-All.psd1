@{
    SchemaVersion = '1.0'
    Id = '2809ecf7-5e72-57b2-bfeb-1d66cbe53eae'
    Identity = @{
        PackageName = 'Winget-Update-All'
        ScriptName = 'Detect-Winget-Update-All'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects for any updates via Winget.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Winget-Update-All/detection_winget-update-detect.ps1'
        Counterpart = 'Winget-Update-All/Remediate-Winget-Update-All.ps1'
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
        Cmdlets = @('Get-ChildItem', 'Join-Path', 'Select-Object', 'Sort-Object', 'Write-Output', 'Write-Warning')
        Executables = @('AppInstallerCLI.exe', 'winget.exe')
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
        Categories = @('File', 'Process')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
