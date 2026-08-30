@{
    SchemaVersion = '1.0'
    Id = '94243d4e-d2ff-5a1a-a647-a7e7d366267f'
    Identity = @{
        PackageName = 'Update-ChocolateyApps'
        ScriptName = 'Detect-Update-ChocolateyApps'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Update ChocolateyApps condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Update-ChocolateyApps/detection_detection-choco-upgrade.ps1'
        Counterpart = 'Update-ChocolateyApps/Remediate-Update-ChocolateyApps.ps1'
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
            'Where-Object'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'choco.exe'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'UpgradeExcludes'
            Required = $false
            Secret = $false
            Description = 'Chocolatey package identifiers excluded from upgrade detection.'
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
