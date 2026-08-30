@{
    SchemaVersion = '1.0'
    Id = 'c9669100-bd32-57e4-8904-b2cd06ceff95'
    Identity = @{
        PackageName = 'Reset-StartMenu'
        ScriptName = 'Detect-Reset-StartMenu'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if the Start Menu database is corrupted or oversized.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Reset-StartMenu/detection_detect-startmenu.ps1'
        Counterpart = 'Reset-StartMenu/Remediate-Reset-StartMenu.ps1'
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
            'Join-Path'
            'Measure-Object'
            'Test-Path'
            'Write-Output'
            'Write-Warning'
        )
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
        Categories = @(
            'File'
            'Appx'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
