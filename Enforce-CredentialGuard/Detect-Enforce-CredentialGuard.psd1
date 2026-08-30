@{
    SchemaVersion = '1.0'
    Id = '71a6d088-74c0-545e-bda7-ea3cdfb84f5f'
    Identity = @{
        PackageName = 'Enforce-CredentialGuard'
        ScriptName = 'Detect-Enforce-CredentialGuard'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if Credential Guard is enabled.'
        Authors = @('Jannik Reinhard')
        Source = 'Enforce-CredentialGuard/detection_detect-credentialguard.ps1'
        Counterpart = 'Enforce-CredentialGuard/Remediate-Enforce-CredentialGuard.ps1'
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
        Cmdlets = @('Get-CimInstance', 'Write-Output', 'Write-Warning')
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
