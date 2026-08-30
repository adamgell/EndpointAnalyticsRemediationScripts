@{
    SchemaVersion = '1.0'
    Id = 'e4ed04b2-0171-5b03-be61-8acdb2e76e0d'
    Identity = @{
        PackageName = 'Enforce-BitLocker'
        ScriptName = 'Detect-Enforce-BitLocker'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if BitLocker is enabled on the OS drive.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Enforce-BitLocker/detection_detect-bitlocker.ps1'
        Counterpart = 'Enforce-BitLocker/Remediate-Enforce-BitLocker.ps1'
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
            'Get-BitLockerVolume'
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
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
