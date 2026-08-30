@{
    SchemaVersion = '1.0'
    Id = 'e1be34d8-9998-5c8f-bdd1-010ed8a37234'
    Identity = @{
        PackageName = 'Disable-LegacyTLS'
        ScriptName = 'Remediate-Disable-LegacyTLS'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Disables TLS 1.0 and TLS 1.1 protocols.'
        Authors = @('Jannik Reinhard')
        Source = 'Disable-LegacyTLS/remediation_disable-legacytls.ps1'
        Counterpart = 'Disable-LegacyTLS/Detect-Disable-LegacyTLS.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('New-Item', 'New-ItemProperty', 'Out-Null', 'Test-Path', 'Write-Error', 'Write-Output')
        Executables = @()
        Policies = @('HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$Protocol\$Type')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $false
        UserImpact = 'The script changes the Disable LegacyTLS state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Registry', 'File')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
