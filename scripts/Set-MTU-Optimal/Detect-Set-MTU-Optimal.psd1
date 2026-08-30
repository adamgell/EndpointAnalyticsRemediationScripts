@{
    SchemaVersion = '1.0'
    Id = '9ff687b9-42ba-5130-bf14-65348946467f'
    Identity = @{
        PackageName = 'Set-MTU-Optimal'
        ScriptName = 'Detect-Set-MTU-Optimal'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if the MTU size is optimal.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Set-MTU-Optimal/detection_detect-mtu.ps1'
        Counterpart = 'Set-MTU-Optimal/Remediate-Set-MTU-Optimal.ps1'
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
            'Get-NetIPInterface'
            'Where-Object'
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
            'Network'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
