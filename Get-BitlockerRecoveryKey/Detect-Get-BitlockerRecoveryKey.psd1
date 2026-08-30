@{
    SchemaVersion = '1.0'
    Id = '3174e5a7-75e6-590d-9235-76655252bdf2'
    Identity = @{
        PackageName = 'Get-BitlockerRecoveryKey'
        ScriptName = 'Detect-Get-BitlockerRecoveryKey'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Get BitlockerRecoveryKey condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Get-BitlockerRecoveryKey/detection_BitlockerRecoveryKey.ps1'
        Counterpart = 'Get-BitlockerRecoveryKey/Remediate-Get-BitlockerRecoveryKey.ps1'
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
        Cmdlets = @('Get-BitLockerVolume', 'Write-Output', 'Write-Warning')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'MountPoint'
            Required = $false
            Secret = $false
            Description = 'BitLocker volume mount point to inspect.'
        }
    )
    Risk = @{
        Level = 'Critical'
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
