@{
    SchemaVersion = '1.0'
    Id = 'b65ae166-7995-5074-99db-dccb0af41541'
    Identity = @{
        PackageName = 'Activate-Numlock'
        ScriptName = 'Remediate-Activate-Numlock'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Activate Numlock condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Activate-Numlock/remediation_Activate-Numlock.ps1'
        Counterpart = 'Activate-Numlock/Detect-Activate-Numlock.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
        RequiresElevation = $false
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Set-ItemProperty', 'Write-Error', 'Write-Host')
        Executables = @()
        Policies = @('Registry::HKU\.DEFAULT\Control Panel\Keyboard')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Activate Numlock state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Registry')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
