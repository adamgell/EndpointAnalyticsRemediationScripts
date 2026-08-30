@{
    SchemaVersion = '1.0'
    Id = '86ec8a6d-4c8c-57cf-9173-b4a2a6334273'
    Identity = @{
        PackageName = 'Set-DefaultBrowser'
        ScriptName = 'Detect-Set-DefaultBrowser'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if the default browser is set to the corporate standard (Edge).'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Set-DefaultBrowser/detection_detect-defaultbrowser.ps1'
        Counterpart = 'Set-DefaultBrowser/Remediate-Set-DefaultBrowser.ps1'
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
            'Get-ItemProperty'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @(
            'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice'
        )
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
            'Registry'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
