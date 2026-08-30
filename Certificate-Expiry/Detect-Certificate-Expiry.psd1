@{
    SchemaVersion = '1.0'
    Id = 'f562b693-ca72-5c82-8d0e-9b5c41d70d11'
    Identity = @{
        PackageName = 'Certificate-Expiry'
        ScriptName = 'Detect-Certificate-Expiry'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects certificates expiring within the next 30 days.'
        Authors = @('Jannik Reinhard')
        Source = 'Detect-CertificateExpiry/detection_detect-certificateexpiry.ps1'
        Counterpart = 'Certificate-Expiry/Remediate-Certificate-Expiry.ps1'
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
        Cmdlets = @('Get-ChildItem', 'Get-Date', 'Where-Object', 'Write-Output', 'Write-Warning')
        Executables = @()
        Policies = @('Cert:\LocalMachine\My')
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'DaysBeforeExpiry'
            Required = $false
            Secret = $false
            Description = 'Certificate-expiry warning threshold in days.'
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
        Categories = @('Registry', 'File')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
