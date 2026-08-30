@{
    SchemaVersion = '1.0'
    Id = '0e96e3cb-4cc9-5837-89cb-294d4de86621'
    Identity = @{
        PackageName = 'Add-Winget-App'
        ScriptName = 'Detect-Add-Winget-App'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if app exists.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Add-Winget-App/detection_detect-app.ps1'
        Counterpart = 'Add-Winget-App/Remediate-Add-Winget-App.ps1'
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
            'Resolve-Path'
            'start-sleep'
            'Write-Host'
        )
        Executables = @(
            'winget.exe'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'AppId'
            Required = $true
            Secret = $false
            Description = 'Winget package identifier to detect or install.'
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
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
