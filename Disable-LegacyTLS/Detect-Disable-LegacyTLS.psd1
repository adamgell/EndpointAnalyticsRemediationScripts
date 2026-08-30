@{
    SchemaVersion = '1.0'
    Id = 'e202fd01-f734-5959-966f-e1e88e32b964'
    Identity = @{
        PackageName = 'Disable-LegacyTLS'
        ScriptName = 'Detect-Disable-LegacyTLS'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if legacy TLS 1.0 or TLS 1.1 protocols are enabled.'
        Authors = @('Jannik Reinhard')
        Source = 'Disable-LegacyTLS/detection_detect-legacytls.ps1'
        Counterpart = 'Disable-LegacyTLS/Remediate-Disable-LegacyTLS.ps1'
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
        Cmdlets = @('Get-ItemProperty', 'Test-Path', 'Write-Output', 'Write-Warning')
        Executables = @()
        Policies = @('HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$Protocol\Client', 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$Protocol\Server')
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
        Categories = @('Registry', 'File')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
