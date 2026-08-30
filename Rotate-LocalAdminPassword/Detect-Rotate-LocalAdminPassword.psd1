@{
    SchemaVersion = '1.0'
    Id = '75446c0a-e251-5f22-ace6-ec79ae92954e'
    Identity = @{
        PackageName = 'Rotate-LocalAdminPassword'
        ScriptName = 'Detect-Rotate-LocalAdminPassword'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if the local administrator password is older than 90 days.'
        Authors = @('Jannik Reinhard')
        Source = 'Rotate-LocalAdminPassword/detection_detect-localadminpasswordage.ps1'
        Counterpart = 'Rotate-LocalAdminPassword/Remediate-Rotate-LocalAdminPassword.ps1'
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
        Cmdlets = @('Get-Date', 'Get-LocalUser', 'Where-Object', 'Write-Output', 'Write-Warning')
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
        DataHandling = 'Handles credential or token material at runtime; secret values are not stored in the manifest.'
    }
    Test = @{
        Categories = @('Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
