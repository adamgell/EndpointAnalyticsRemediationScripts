@{
    SchemaVersion = '1.0'
    Id = '6a38f5a1-71d1-56f1-a22e-e98e28f2a541'
    Identity = @{
        PackageName = 'Reset-NetworkStack'
        ScriptName = 'Detect-Reset-NetworkStack'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects network connectivity issues.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Reset-NetworkStack/detection_detect-networkstack.ps1'
        Counterpart = 'Reset-NetworkStack/Remediate-Reset-NetworkStack.ps1'
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
            'Resolve-DnsName'
            'Test-Connection'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @()
        Endpoints = @(
            'microsoft.com'
        )
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
