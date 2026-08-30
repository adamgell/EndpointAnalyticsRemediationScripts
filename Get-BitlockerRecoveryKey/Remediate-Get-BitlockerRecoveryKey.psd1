@{
    SchemaVersion = '1.0'
    Id = '43bba5d1-6e99-520c-98e6-09b77b7adc50'
    Identity = @{
        PackageName = 'Get-BitlockerRecoveryKey'
        ScriptName = 'Remediate-Get-BitlockerRecoveryKey'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Get BitlockerRecoveryKey condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Get-BitlockerRecoveryKey/remediation_BitlockerRecoveryKey.ps1'
        Counterpart = 'Get-BitlockerRecoveryKey/Detect-Get-BitlockerRecoveryKey.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @(
            'AllSupported'
        )
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Get-Bitlockervolume'
            'Write-Output'
            'Write-Warning'
        )
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
        UserImpact = 'The script changes the Get BitlockerRecoveryKey state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Handles credential or token material at runtime; secret values are not stored in the manifest.'
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
