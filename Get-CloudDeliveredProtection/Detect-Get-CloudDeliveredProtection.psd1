@{
    SchemaVersion = '1.0'
    Id = '48d100de-e3ba-5b29-8a3b-7d66f4291568'
    Identity = @{
        PackageName = 'Get-CloudDeliveredProtection'
        ScriptName = 'Detect-Get-CloudDeliveredProtection'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Get CloudDeliveredProtection condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Get-CloudDeliveredProtection/detection_Detect_CloudDeliveredProtection.ps1'
        Counterpart = 'Get-CloudDeliveredProtection/Remediate-Get-CloudDeliveredProtection.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-MpPreference', 'Write-Output')
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
        Categories = @('Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
