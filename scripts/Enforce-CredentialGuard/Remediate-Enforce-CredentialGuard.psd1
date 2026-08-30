@{
    SchemaVersion = '1.0'
    Id = '227cc7d6-45fe-58cd-8718-bf123ec44eba'
    Identity = @{
        PackageName = 'Enforce-CredentialGuard'
        ScriptName = 'Remediate-Enforce-CredentialGuard'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Enables Credential Guard via registry.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Enforce-CredentialGuard/remediation_enforce-credentialguard.ps1'
        Counterpart = 'Enforce-CredentialGuard/Detect-Enforce-CredentialGuard.ps1'
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
        Reboot = 'Required'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'New-Item'
            'New-ItemProperty'
            'Out-Null'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard'
            'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Enforce CredentialGuard state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'File'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
